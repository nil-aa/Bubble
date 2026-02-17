import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/models/user_model.dart';
import 'package:bubble/models/compatibility_vector.dart';
import 'package:csv/csv.dart';

class SeedService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generate a deterministic ID from an email to prevent duplicate profiles
  static String _generateId(String email) {
    var bytes = utf8.encode(email.toLowerCase().trim());
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 20);
  }

  /// Get a high-quality avatar URL for a user
  static String _getAvatar(String email) {
    final seed = email.toLowerCase().trim();
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&backgroundColor=b6e3f4,c0aede,d1d4f9';
  }

  static Future<void> seedDemoData() async {
    const campusId = 'ssn.edu.in';
    
    // 1. Add the Hardcoded Demo User (a@ssn.edu.in)
    final demoEmail = 'a@ssn.edu.in';
    final demoUid = _generateId(demoEmail);

    final demoUser = UserModel(
      uid: demoUid,
      name: 'Nilaa (Demo)',
      email: demoEmail,
      department: 'CSE',
      college: 'SSN College',
      year: '3rd Year',
      bio: 'Building Bubble and loving every second! 🚀 Looking for music soulmates.',
      campusId: campusId,
      createdAt: DateTime.now(),
      spotifyConnected: true,
      gender: 'Male',
      locationType: 'Day Scholar',
      profileImageUrl: _getAvatar(demoEmail),
      topArtistNames: ['Arctic Monkeys', 'The Strokes', 'Radiohead'],
      musicVector: CompatibilityVector(
        genreFrequencies: {'indie': 0.7, 'rock': 0.8, 'alt': 0.6, 'modern rock': 0.5},
        topArtistIds: ['am1', 'ts1', 'rh1'],
        topTrackIds: ['t1', 't2'],
        topArtistNames: ['Arctic Monkeys', 'The Strokes', 'Radiohead'],
        energy: 0.6,
        danceability: 0.5,
        valence: 0.5,
        acousticness: 0.2,
        instrumentalness: 0.1,
        tempo: 0.6,
      ),
    );

    final batch = _db.batch();
    batch.set(_db.collection('users').doc(demoUid), demoUser.toFirestore());

    // 2. Add initial profiles (all on ssn.edu.in)
    final initialProfiles = [
      {
        'name': 'Maya Iyer', 'email': 'maya.i@ssn.edu.in', 'department': 'CSE', 'year': '3rd Year',
        'isFemale': true, 'bio': 'Indie music is my therapy. 🎸',
        'genres': {'indie': 0.8, 'dream pop': 0.6, 'shoegaze': 0.4},
        'artists': ['Beach House', 'Mac DeMarco', 'The Walters'],
        'energy': 0.4, 'danceability': 0.5, 'valence': 0.6,
      },
      {
        'name': 'Rahul Sharma', 'email': 'rahul.s@ssn.edu.in', 'department': 'Mech', 'year': '4th Year',
        'isFemale': false, 'bio': 'Headbanger. If it isn\'t loud, I\'m not listening. 🤘',
        'genres': {'heavy metal': 0.9, 'hard rock': 0.8, 'punk': 0.5},
        'artists': ['Metallica', 'Iron Maiden', 'AC/DC'],
        'energy': 0.9, 'danceability': 0.3, 'valence': 0.4,
      },
      {
        'name': 'Priyanka Das', 'email': 'priyanka.d@ssn.edu.in', 'department': 'IT', 'year': '3rd Year',
        'isFemale': true, 'bio': 'Pop princess. 🧣',
        'genres': {'pop': 0.9, 'dance pop': 0.8, 'bollywood': 0.6},
        'artists': ['Taylor Swift', 'Ariana Grande', 'Dua Lipa'],
        'energy': 0.7, 'danceability': 0.8, 'valence': 0.9,
      },
    ];

    for (var data in initialProfiles) {
      final email = data['email'] as String;
      final id = _generateId(email);
      final user = UserModel(
        uid: id,
        name: data['name'] as String,
        email: email,
        department: data['department'] as String,
        college: 'SSN College',
        year: data['year'] as String,
        bio: data['bio'] as String,
        campusId: campusId,
        createdAt: DateTime.now(),
        spotifyConnected: true,
        gender: (data['isFemale'] as bool) ? 'Female' : 'Male',
        profileImageUrl: _getAvatar(email),
        topArtistNames: List<String>.from(data['artists'] as List),
        musicVector: CompatibilityVector(
          genreFrequencies: Map<String, double>.from(data['genres'] as Map),
          topArtistIds: List<String>.from(data['artists'] as List).map((e) => 'id_$e').toList(),
          topTrackIds: ['track_1', 'track_2'],
          topArtistNames: List<String>.from(data['artists'] as List),
          energy: (data['energy'] as num).toDouble(),
          danceability: (data['danceability'] as num).toDouble(),
          valence: (data['valence'] as num).toDouble(),
          acousticness: 0.5, instrumentalness: 0.1, tempo: 0.6,
        ),
      );
      batch.set(_db.collection('users').doc(id), user.toFirestore());
    }

    await batch.commit();
    print('Initial seeding complete (all on $campusId).');
  }

  static Future<void> seedFromCsv(String csvContent) async {
    const defaultCampusId = 'ssn.edu.in'; // Force all to our demo campus
    final rng = Random();

    List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) return;
    rows.removeAt(0);

    final batch = _db.batch();
    int count = 0;

    for (var row in rows) {
      if (row.length < 10) continue;

      final name = row[0].toString();
      final email = row[1].toString().toLowerCase().trim();
      final yearStr = '${row[2]} Year';
      final department = row[3].toString();
      final gender = row[5].toString();
      final height = row[6].toString();
      final locationType = row[7].toString();
      final bio = row[8].toString();
      
      final interests = row[9].toString().split(';').map((e) => e.trim()).toList();
      final prompt1 = row[10].toString();
      final prompt1Resp = row[11].toString();
      final prompt2 = row[12].toString();
      final prompt2Resp = row[13].toString();
      final lookingFor = row[14].toString().split(';').map((e) => e.trim()).toList();
      final yearPref = row[15].toString().split(';').map((e) => e.trim()).toList();
      final deptPref = row[16].toString().split(';').map((e) => e.trim()).toList();
      final genderPref = row[17].toString().split(';').map((e) => e.trim()).toList();
      final lifestyleTags = row[18].toString().split(';').map((e) => e.trim()).toList();

      final uid = _generateId(email);
      final musicVector = _generateRandomVector(interests, rng);

      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        department: department,
        college: 'SSN College',
        year: yearStr,
        bio: bio,
        gender: gender,
        height: height,
        locationType: locationType,
        profileImageUrl: _getAvatar(email),
        interests: interests,
        lookingFor: lookingFor,
        lifestyleTags: lifestyleTags,
        prompts: [
          {'question': prompt1, 'answer': prompt1Resp},
          {'question': prompt2, 'answer': prompt2Resp}
        ],
        campusId: defaultCampusId, // ALL profiles on ssn.edu.in for demo
        createdAt: DateTime.now(),
        spotifyConnected: true,
        topArtistNames: musicVector.topArtistNames,
        musicVector: musicVector,
        preferences: {
          'yearPreference': yearPref.join(','),
          'departmentPreference': deptPref.join(','),
          'genderPreference': genderPref.join(','),
        },
      );

      batch.set(_db.collection('users').doc(uid), user.toFirestore());
      count++;

      if (count % 400 == 0) {
        await batch.commit();
      }
    }

    await batch.commit();
    print('Imported $count CSV profiles to $defaultCampusId.');
  }

  static CompatibilityVector _generateRandomVector(List<String> interests, Random rng) {
    final artists = ['Artist A', 'Artist B', 'Artist C'];
    final genres = {'indie': rng.nextDouble(), 'pop': rng.nextDouble(), 'rock': rng.nextDouble()};

    return CompatibilityVector(
      genreFrequencies: genres,
      topArtistIds: ['id1', 'id2', 'id3'],
      topTrackIds: ['t1', 't2'],
      topArtistNames: artists,
      energy: rng.nextDouble(),
      danceability: rng.nextDouble(),
      valence: rng.nextDouble(),
      acousticness: rng.nextDouble(),
      instrumentalness: rng.nextDouble(),
      tempo: rng.nextDouble(),
    );
  }
}
