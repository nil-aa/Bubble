import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/models/user_model.dart';
import 'package:bubble/models/match_model.dart';

/// Handles all Firestore CRUD operations for users and matches.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // USER OPERATIONS
  // ===========================================================================

  /// Reference to the users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  /// Create or update a user profile
  Future<void> saveUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Get a single user by UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream a single user (for reactive UI)
  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Get all users on the same campus (excluding the current user)
  Future<List<UserModel>> getCampusUsers({
    required String campusId,
    required String excludeUid,
  }) async {
    final snapshot = await _usersRef
        .where('campusId', isEqualTo: campusId)
        .get();

    return snapshot.docs
        .where((doc) => doc.id != excludeUid)
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  /// Update specific fields on a user document
  Future<void> updateUserFields(
      String uid, Map<String, dynamic> fields) async {
    await _usersRef.doc(uid).update(fields);
  }

  // ===========================================================================
  // MATCH OPERATIONS
  // ===========================================================================

  /// Reference to the matches collection
  CollectionReference<Map<String, dynamic>> get _matchesRef =>
      _db.collection('matches');

  /// Create a new match (when user swipes right)
  Future<void> createMatch(MatchModel match) async {
    await _matchesRef.doc(match.matchId).set(match.toFirestore());
  }

  /// Get a match by ID
  Future<MatchModel?> getMatch(String matchId) async {
    final doc = await _matchesRef.doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromFirestore(doc);
  }

  /// Find an existing match between two users (regardless of order)
  Future<MatchModel?> findMatchBetweenUsers(
      String userId1, String userId2) async {
    // Check both orderings
    var snapshot = await _matchesRef
        .where('userId1', isEqualTo: userId1)
        .where('userId2', isEqualTo: userId2)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await _matchesRef
          .where('userId1', isEqualTo: userId2)
          .where('userId2', isEqualTo: userId1)
          .limit(1)
          .get();
    }

    if (snapshot.docs.isEmpty) return null;
    return MatchModel.fromFirestore(snapshot.docs.first);
  }

  /// Update match status (e.g., to 'matched' when both swipe right)
  Future<void> updateMatchStatus(String matchId, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'matched') {
      updates['matchedAt'] = Timestamp.now();
    }
    await _matchesRef.doc(matchId).update(updates);
  }

  /// Get all confirmed matches for a user
  Stream<List<MatchModel>> streamUserMatches(String uid) {
    // We need to query both userId1 and userId2 fields
    // Firestore doesn't support OR queries across fields easily,
    // so we use two queries and merge locally
    final stream1 = _matchesRef
        .where('userId1', isEqualTo: uid)
        .where('status', isEqualTo: 'matched')
        .snapshots();

    final stream2 = _matchesRef
        .where('userId2', isEqualTo: uid)
        .where('status', isEqualTo: 'matched')
        .snapshots();

    // Merge both streams
    return stream1.asyncExpand((snap1) {
      return stream2.map((snap2) {
        final allDocs = [...snap1.docs, ...snap2.docs];
        return allDocs.map((doc) => MatchModel.fromFirestore(doc)).toList();
      });
    });
  }

  /// Check if the current user has already swiped right on someone
  Future<bool> hasSwipedRight(String currentUid, String targetUid) async {
    final match = await findMatchBetweenUsers(currentUid, targetUid);
    return match != null;
  }

  /// Get UIDs of users the current user has already seen/swiped
  Future<Set<String>> getSwipedUserIds(String uid) async {
    final snap1 = await _matchesRef
        .where('userId1', isEqualTo: uid)
        .get();
    final snap2 = await _matchesRef
        .where('userId2', isEqualTo: uid)
        .get();

    final ids = <String>{};
    for (final doc in snap1.docs) {
      ids.add(doc['userId2'] as String);
    }
    for (final doc in snap2.docs) {
      ids.add(doc['userId1'] as String);
    }
    return ids;
  }

  // ===========================================================================
  // MESSAGING (Basic — Phase 2 will expand)
  // ===========================================================================

  /// Send a message in a match conversation
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    await _matchesRef.doc(matchId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream messages for a match
  Stream<QuerySnapshot> streamMessages(String matchId) {
    return _matchesRef
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
