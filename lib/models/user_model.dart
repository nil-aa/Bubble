import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/models/compatibility_vector.dart';

/// User profile model stored in Firestore `users` collection
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String department;
  final String college;
  final String year;
  final String? bio;
  final String? gender;
  final String? height;
  final String? locationType;
  final String? personalityType;
  final List<String> interests;
  final List<String> lookingFor;
  final List<String> lifestyleTags;
  final List<Map<String, String>> prompts;
  final CompatibilityVector? musicVector;
  final String? vibeSummary;
  final String campusId;
  final bool spotifyConnected;
  final String? spotifyDisplayName;
  final List<String> topArtistNames;
  final List<String> selectedPromptQuestions;
  final Map<String, String>? preferences;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.college,
    required this.year,
    this.bio,
    this.gender,
    this.height,
    this.locationType,
    this.personalityType,
    this.interests = const [],
    this.lookingFor = const [],
    this.lifestyleTags = const [],
    this.prompts = const [],
    this.musicVector,
    this.vibeSummary,
    required this.campusId,
    this.spotifyConnected = false,
    this.spotifyDisplayName,
    this.topArtistNames = const [],
    this.selectedPromptQuestions = const [],
    this.preferences,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      college: data['college'] ?? '',
      year: data['year'] ?? '',
      bio: data['bio'],
      gender: data['gender'],
      height: data['height'],
      locationType: data['locationType'],
      personalityType: data['personalityType'],
      interests: List<String>.from(data['interests'] ?? []),
      lookingFor: List<String>.from(data['lookingFor'] ?? []),
      lifestyleTags: List<String>.from(data['lifestyleTags'] ?? []),
      prompts: (data['prompts'] as List<dynamic>?)
              ?.map((p) => Map<String, String>.from(p as Map))
              .toList() ??
          [],
      musicVector: data['musicVector'] != null
          ? CompatibilityVector.fromMap(
              Map<String, dynamic>.from(data['musicVector']))
          : null,
      vibeSummary: data['vibeSummary'],
      campusId: data['campusId'] ?? '',
      spotifyConnected: data['spotifyConnected'] ?? false,
      spotifyDisplayName: data['spotifyDisplayName'],
      topArtistNames: List<String>.from(data['topArtistNames'] ?? []),
      selectedPromptQuestions:
          List<String>.from(data['selectedPromptQuestions'] ?? []),
      preferences: data['preferences'] != null
          ? Map<String, String>.from(data['preferences'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'college': college,
      'year': year,
      'bio': bio,
      'gender': gender,
      'height': height,
      'locationType': locationType,
      'personalityType': personalityType,
      'interests': interests,
      'lookingFor': lookingFor,
      'lifestyleTags': lifestyleTags,
      'prompts': prompts,
      'musicVector': musicVector?.toMap(),
      'vibeSummary': vibeSummary,
      'campusId': campusId,
      'spotifyConnected': spotifyConnected,
      'spotifyDisplayName': spotifyDisplayName,
      'topArtistNames': topArtistNames,
      'selectedPromptQuestions': selectedPromptQuestions,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? bio,
    String? gender,
    String? height,
    String? locationType,
    String? personalityType,
    List<String>? interests,
    List<String>? lookingFor,
    List<String>? lifestyleTags,
    List<Map<String, String>>? prompts,
    CompatibilityVector? musicVector,
    String? vibeSummary,
    bool? spotifyConnected,
    String? spotifyDisplayName,
    List<String>? topArtistNames,
    List<String>? selectedPromptQuestions,
    Map<String, String>? preferences,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      department: department,
      college: college,
      year: year,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      locationType: locationType ?? this.locationType,
      personalityType: personalityType ?? this.personalityType,
      interests: interests ?? this.interests,
      lookingFor: lookingFor ?? this.lookingFor,
      lifestyleTags: lifestyleTags ?? this.lifestyleTags,
      prompts: prompts ?? this.prompts,
      musicVector: musicVector ?? this.musicVector,
      vibeSummary: vibeSummary ?? this.vibeSummary,
      campusId: campusId,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
      spotifyDisplayName: spotifyDisplayName ?? this.spotifyDisplayName,
      topArtistNames: topArtistNames ?? this.topArtistNames,
      selectedPromptQuestions:
          selectedPromptQuestions ?? this.selectedPromptQuestions,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
    );
  }
}
