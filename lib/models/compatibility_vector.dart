/// Structured music compatibility vector derived from Spotify listening data.
/// 
/// This is the ONLY data retained from Spotify — raw tracks/artists are
/// NOT stored permanently. The vector is used for deterministic pairwise
/// similarity scoring.
class CompatibilityVector {
  /// Normalized genre frequencies (genre name → 0.0–1.0)
  final Map<String, double> genreFrequencies;

  /// Spotify artist IDs for overlap comparison
  final List<String> topArtistIds;

  /// Spotify track IDs (kept temporarily for audio feature fetch)
  final List<String> topTrackIds;

  /// Artist display names (for showing shared artists)
  final List<String> topArtistNames;

  /// Averaged audio features from top tracks (all 0.0–1.0 except tempo)
  final double energy;
  final double danceability;
  final double valence;
  final double acousticness;
  final double instrumentalness;
  final double tempo; // BPM normalized to 0-1 range (divided by 200)

  const CompatibilityVector({
    required this.genreFrequencies,
    required this.topArtistIds,
    required this.topTrackIds,
    required this.topArtistNames,
    required this.energy,
    required this.danceability,
    required this.valence,
    required this.acousticness,
    required this.instrumentalness,
    required this.tempo,
  });

  /// Audio feature values as a list for vector math
  List<double> get audioFeatureVector => [
        energy,
        danceability,
        valence,
        acousticness,
        instrumentalness,
        tempo,
      ];

  /// Create from Firestore map
  factory CompatibilityVector.fromMap(Map<String, dynamic> data) {
    return CompatibilityVector(
      genreFrequencies: Map<String, double>.from(
        (data['genreFrequencies'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ) ??
            {},
      ),
      topArtistIds: List<String>.from(data['topArtistIds'] ?? []),
      topTrackIds: List<String>.from(data['topTrackIds'] ?? []),
      topArtistNames: List<String>.from(data['topArtistNames'] ?? []),
      energy: (data['energy'] as num?)?.toDouble() ?? 0.0,
      danceability: (data['danceability'] as num?)?.toDouble() ?? 0.0,
      valence: (data['valence'] as num?)?.toDouble() ?? 0.0,
      acousticness: (data['acousticness'] as num?)?.toDouble() ?? 0.0,
      instrumentalness:
          (data['instrumentalness'] as num?)?.toDouble() ?? 0.0,
      tempo: (data['tempo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'genreFrequencies': genreFrequencies,
      'topArtistIds': topArtistIds,
      'topTrackIds': topTrackIds,
      'topArtistNames': topArtistNames,
      'energy': energy,
      'danceability': danceability,
      'valence': valence,
      'acousticness': acousticness,
      'instrumentalness': instrumentalness,
      'tempo': tempo,
    };
  }
}
