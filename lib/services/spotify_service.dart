import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bubble/models/compatibility_vector.dart';

/// Handles Spotify OAuth (PKCE) and data retrieval.
///
/// Flow:
///   1. authenticate()      — PKCE OAuth, stores tokens securely
///   2. fetchListeningData() — fetches top artists, tracks, audio features
///   3. buildVector()        — converts raw data into CompatibilityVector
///
/// Raw Spotify data is NOT persisted — only the derived vector is kept.
class SpotifyService {
  // ---------------------------------------------------------------------------
  // Configuration — replace with your Spotify Developer Dashboard values
  // ---------------------------------------------------------------------------
  static const String _clientId = 'd4ba8c2a98ac435d9b814322acc150cd'; // TODO: replace
  static const String _redirectUri = 'bubble://callback'; // Must match dashboard
  static const String _authEndpoint =
      'https://accounts.spotify.com/authorize';
  static const String _tokenEndpoint =
      'https://accounts.spotify.com/api/token';
  static const String _apiBase = 'https://api.spotify.com/v1';

  static const List<String> _scopes = [
    'user-top-read',
    'user-read-private',
  ];

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  // ---------------------------------------------------------------------------
  // 1) AUTHENTICATE — Spotify OAuth PKCE
  // ---------------------------------------------------------------------------
  Future<bool> authenticate() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _authEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: _scopes,
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken;

        // Store tokens securely
        await _secureStorage.write(
            key: 'spotify_access_token', value: _accessToken);
        if (_refreshToken != null) {
          await _secureStorage.write(
              key: 'spotify_refresh_token', value: _refreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Spotify auth error: $e');
      return false;
    }
  }

  /// Refresh the access token using the stored refresh token
  Future<bool> refreshAccessToken() async {
    final storedRefresh =
        await _secureStorage.read(key: 'spotify_refresh_token');
    if (storedRefresh == null) return false;

    try {
      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _authEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          refreshToken: storedRefresh,
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        await _secureStorage.write(
            key: 'spotify_access_token', value: _accessToken);
        if (result.refreshToken != null) {
          _refreshToken = result.refreshToken;
          await _secureStorage.write(
              key: 'spotify_refresh_token', value: _refreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Spotify token refresh error: $e');
      return false;
    }
  }

  /// Check if we have a valid stored token
  Future<bool> hasStoredToken() async {
    final token = await _secureStorage.read(key: 'spotify_access_token');
    return token != null;
  }

  // ---------------------------------------------------------------------------
  // 2) FETCH LISTENING DATA
  // ---------------------------------------------------------------------------

  /// Make an authenticated GET request to Spotify API
  Future<Map<String, dynamic>?> _apiGet(String endpoint) async {
    if (_accessToken == null) {
      final stored =
          await _secureStorage.read(key: 'spotify_access_token');
      if (stored == null) return null;
      _accessToken = stored;
    }

    var response = await http.get(
      Uri.parse('$_apiBase$endpoint'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    // If token expired, try to refresh
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (!refreshed) return null;
      response = await http.get(
        Uri.parse('$_apiBase$endpoint'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    debugPrint('Spotify API error ${response.statusCode}: ${response.body}');
    return null;
  }

  /// Fetch user's top artists (medium term ~6 months)
  Future<List<Map<String, dynamic>>> fetchTopArtists({int limit = 50}) async {
    final data =
        await _apiGet('/me/top/artists?time_range=medium_term&limit=$limit');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data['items'] ?? []);
  }

  /// Fetch user's top tracks (medium term)
  Future<List<Map<String, dynamic>>> fetchTopTracks({int limit = 50}) async {
    final data =
        await _apiGet('/me/top/tracks?time_range=medium_term&limit=$limit');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data['items'] ?? []);
  }

  /// Fetch audio features for a list of track IDs (max 100 per call)
  Future<List<Map<String, dynamic>>> fetchAudioFeatures(
      List<String> trackIds) async {
    if (trackIds.isEmpty) return [];
    // API accepts max 100 IDs per call
    final ids = trackIds.take(100).join(',');
    final data = await _apiGet('/audio-features?ids=$ids');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (data['audio_features'] as List).where((f) => f != null),
    );
  }

  /// Fetch the current user's Spotify profile
  Future<Map<String, dynamic>?> fetchProfile() async {
    return await _apiGet('/me');
  }

  // ---------------------------------------------------------------------------
  // 3) BUILD COMPATIBILITY VECTOR
  // ---------------------------------------------------------------------------

  /// Fetch all data and build the CompatibilityVector in one call
  Future<CompatibilityVector?> buildCompatibilityVector() async {
    try {
      // Fetch data in parallel
      final results = await Future.wait([
        fetchTopArtists(),
        fetchTopTracks(),
      ]);

      final artists = results[0];
      final tracks = results[1];

      if (artists.isEmpty && tracks.isEmpty) return null;

      // Extract artist info
      final artistIds = <String>[];
      final artistNames = <String>[];
      final genreCounts = <String, int>{};

      for (final artist in artists) {
        artistIds.add(artist['id'] as String);
        artistNames.add(artist['name'] as String);
        // Count genres
        final genres = List<String>.from(artist['genres'] ?? []);
        for (final genre in genres) {
          genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
        }
      }

      // Normalize genre frequencies
      final totalGenreCount =
          genreCounts.values.fold<int>(0, (sum, c) => sum + c);
      final genreFrequencies = <String, double>{};
      if (totalGenreCount > 0) {
        for (final entry in genreCounts.entries) {
          genreFrequencies[entry.key] = entry.value / totalGenreCount;
        }
      }

      // Extract track IDs
      final trackIds = tracks
          .map((t) => t['id'] as String)
          .toList();

      // Fetch audio features
      final audioFeatures = await fetchAudioFeatures(trackIds);

      // Average audio features
      double avgEnergy = 0, avgDanceability = 0, avgValence = 0;
      double avgAcousticness = 0, avgInstrumentalness = 0, avgTempo = 0;

      if (audioFeatures.isNotEmpty) {
        for (final f in audioFeatures) {
          avgEnergy += (f['energy'] as num?)?.toDouble() ?? 0;
          avgDanceability += (f['danceability'] as num?)?.toDouble() ?? 0;
          avgValence += (f['valence'] as num?)?.toDouble() ?? 0;
          avgAcousticness += (f['acousticness'] as num?)?.toDouble() ?? 0;
          avgInstrumentalness +=
              (f['instrumentalness'] as num?)?.toDouble() ?? 0;
          avgTempo += (f['tempo'] as num?)?.toDouble() ?? 0;
        }
        final n = audioFeatures.length.toDouble();
        avgEnergy /= n;
        avgDanceability /= n;
        avgValence /= n;
        avgAcousticness /= n;
        avgInstrumentalness /= n;
        avgTempo = (avgTempo / n) / 200.0; // Normalize BPM to 0-1
      }

      return CompatibilityVector(
        genreFrequencies: genreFrequencies,
        topArtistIds: artistIds,
        topTrackIds: trackIds,
        topArtistNames: artistNames,
        energy: avgEnergy,
        danceability: avgDanceability,
        valence: avgValence,
        acousticness: avgAcousticness,
        instrumentalness: avgInstrumentalness,
        tempo: avgTempo,
      );
    } catch (e) {
      debugPrint('Error building compatibility vector: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _secureStorage.delete(key: 'spotify_access_token');
    await _secureStorage.delete(key: 'spotify_refresh_token');
  }
}
