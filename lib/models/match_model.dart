import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a match relationship between two users
class MatchModel {
  final String matchId;
  final String userId1;
  final String userId2;
  final double musicSimilarity;     // 0–100
  final double interactionScore;    // 0–100 (Phase 2, defaults to 0)
  final double totalCompatibility;  // weighted combination
  final List<String> sharedArtists;
  final List<String> sharedGenres;
  final String status; // 'pending_1', 'pending_2', 'matched', 'rejected'
  final DateTime createdAt;
  final DateTime? matchedAt;

  const MatchModel({
    required this.matchId,
    required this.userId1,
    required this.userId2,
    required this.musicSimilarity,
    this.interactionScore = 0.0,
    required this.totalCompatibility,
    this.sharedArtists = const [],
    this.sharedGenres = const [],
    required this.status,
    required this.createdAt,
    this.matchedAt,
  });

  /// Whether both users have confirmed the match
  bool get isMatched => status == 'matched';

  /// Check if a user is part of this match
  bool hasUser(String uid) => userId1 == uid || userId2 == uid;

  /// Get the other user's ID
  String otherUser(String myUid) =>
      userId1 == myUid ? userId2 : userId1;

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      matchId: doc.id,
      userId1: data['userId1'] ?? '',
      userId2: data['userId2'] ?? '',
      musicSimilarity: (data['musicSimilarity'] as num?)?.toDouble() ?? 0.0,
      interactionScore:
          (data['interactionScore'] as num?)?.toDouble() ?? 0.0,
      totalCompatibility:
          (data['totalCompatibility'] as num?)?.toDouble() ?? 0.0,
      sharedArtists: List<String>.from(data['sharedArtists'] ?? []),
      sharedGenres: List<String>.from(data['sharedGenres'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      matchedAt: (data['matchedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'musicSimilarity': musicSimilarity,
      'interactionScore': interactionScore,
      'totalCompatibility': totalCompatibility,
      'sharedArtists': sharedArtists,
      'sharedGenres': sharedGenres,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'matchedAt':
          matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
    };
  }

  MatchModel copyWith({
    double? musicSimilarity,
    double? interactionScore,
    double? totalCompatibility,
    String? status,
    DateTime? matchedAt,
  }) {
    return MatchModel(
      matchId: matchId,
      userId1: userId1,
      userId2: userId2,
      musicSimilarity: musicSimilarity ?? this.musicSimilarity,
      interactionScore: interactionScore ?? this.interactionScore,
      totalCompatibility: totalCompatibility ?? this.totalCompatibility,
      sharedArtists: sharedArtists,
      sharedGenres: sharedGenres,
      status: status ?? this.status,
      createdAt: createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }
}
