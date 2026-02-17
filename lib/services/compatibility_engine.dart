import 'dart:math';
import 'package:bubble/models/compatibility_vector.dart';

/// Deterministic compatibility scoring engine.
///
/// Computes pairwise similarity between two users' CompatibilityVectors
/// using three components:
///   - Genre similarity  (cosine similarity)     — 40%
///   - Artist overlap     (Jaccard index)         — 30%
///   - Audio feature dist (1 − norm. Euclidean)   — 30%
///
/// No ML model is used — all calculations are rule-based.
class CompatibilityEngine {
  // Weights for each component (must sum to 1.0)
  static const double _genreWeight = 0.40;
  static const double _artistWeight = 0.30;
  static const double _audioWeight = 0.30;

  // ---------------------------------------------------------------------------
  // MAIN: Compute overall music similarity (0–100)
  // ---------------------------------------------------------------------------
  static double computeMusicSimilarity(
    CompatibilityVector a,
    CompatibilityVector b,
  ) {
    final genreScore = _genreSimilarity(a.genreFrequencies, b.genreFrequencies);
    final artistScore = _artistOverlap(a.topArtistIds, b.topArtistIds);
    final audioScore = _audioFeatureSimilarity(
      a.audioFeatureVector,
      b.audioFeatureVector,
    );

    final raw = (genreScore * _genreWeight) +
        (artistScore * _artistWeight) +
        (audioScore * _audioWeight);

    // Scale to 0–100 and round to 1 decimal
    return (raw * 100).clamp(0.0, 100.0);
  }

  // ---------------------------------------------------------------------------
  // Compute total compatibility (music + interaction)
  // Phase 2 will provide a real interaction score; for now it defaults to 0.
  // ---------------------------------------------------------------------------
  static double computeTotalCompatibility({
    required double musicSimilarity,
    double interactionScore = 0.0,
    double musicWeight = 0.70,
    double interactionWeight = 0.30,
  }) {
    // If no interaction data yet, use music score at full weight
    if (interactionScore == 0.0) return musicSimilarity;

    return (musicSimilarity * musicWeight) +
        (interactionScore * interactionWeight);
  }

  // ---------------------------------------------------------------------------
  // Find shared artists between two users (returns display names)
  // ---------------------------------------------------------------------------
  static List<String> findSharedArtists(
    CompatibilityVector a,
    CompatibilityVector b,
  ) {
    final sharedIds =
        a.topArtistIds.toSet().intersection(b.topArtistIds.toSet());

    // Map IDs back to names using user A's list (both should have the same names)
    final sharedNames = <String>[];
    for (int i = 0; i < a.topArtistIds.length; i++) {
      if (sharedIds.contains(a.topArtistIds[i]) &&
          i < a.topArtistNames.length) {
        sharedNames.add(a.topArtistNames[i]);
      }
    }
    return sharedNames;
  }

  // ---------------------------------------------------------------------------
  // Find shared genres between two users
  // ---------------------------------------------------------------------------
  static List<String> findSharedGenres(
    CompatibilityVector a,
    CompatibilityVector b,
  ) {
    final genresA = a.genreFrequencies.keys.toSet();
    final genresB = b.genreFrequencies.keys.toSet();
    final shared = genresA.intersection(genresB).toList();
    // Sort by highest combined frequency
    shared.sort((x, y) {
      final freqX =
          (a.genreFrequencies[x] ?? 0) + (b.genreFrequencies[x] ?? 0);
      final freqY =
          (a.genreFrequencies[y] ?? 0) + (b.genreFrequencies[y] ?? 0);
      return freqY.compareTo(freqX);
    });
    return shared.take(10).toList(); // Top 10 shared genres
  }

  // ===========================================================================
  // PRIVATE — Similarity calculations
  // ===========================================================================

  /// Cosine similarity between two genre frequency vectors
  static double _genreSimilarity(
    Map<String, double> a,
    Map<String, double> b,
  ) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Union of all genres
    final allGenres = {...a.keys, ...b.keys};

    double dotProduct = 0;
    double magnitudeA = 0;
    double magnitudeB = 0;

    for (final genre in allGenres) {
      final valA = a[genre] ?? 0.0;
      final valB = b[genre] ?? 0.0;
      dotProduct += valA * valB;
      magnitudeA += valA * valA;
      magnitudeB += valB * valB;
    }

    final denom = sqrt(magnitudeA) * sqrt(magnitudeB);
    if (denom == 0) return 0.0;

    return (dotProduct / denom).clamp(0.0, 1.0);
  }

  /// Jaccard index for artist overlap
  static double _artistOverlap(List<String> a, List<String> b) {
    if (a.isEmpty && b.isEmpty) return 0.0;

    final setA = a.toSet();
    final setB = b.toSet();
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Audio feature similarity: 1 − normalized Euclidean distance
  static double _audioFeatureSimilarity(
    List<double> a,
    List<double> b,
  ) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;

    double sumSquaredDiff = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sumSquaredDiff += diff * diff;
    }

    // Max possible distance = sqrt(n) where each diff = 1.0
    final maxDistance = sqrt(a.length.toDouble());
    final distance = sqrt(sumSquaredDiff);
    final normalized = distance / maxDistance;

    return (1.0 - normalized).clamp(0.0, 1.0);
  }
}
