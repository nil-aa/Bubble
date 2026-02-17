import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';
import 'package:bubble/screens/home_screen.dart';
import 'package:bubble/services/spotify_service.dart';
import 'package:bubble/services/firestore_service.dart';
import 'package:bubble/services/auth_service.dart';

/// Spotify connection screen
/// Allows users to connect their Spotify account for music taste matching
class SpotifyConnectScreen extends StatefulWidget {
  const SpotifyConnectScreen({super.key});

  @override
  State<SpotifyConnectScreen> createState() => _SpotifyConnectScreenState();
}

class _SpotifyConnectScreenState extends State<SpotifyConnectScreen> {
  bool _isConnecting = false;
  String? _statusMessage;

  void _handleConnectSpotify() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Opening Spotify...';
    });

    try {
      final spotifyService =
          Provider.of<SpotifyService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.uid;
      if (uid == null) throw 'Not signed in';

      // 1. Authenticate with Spotify (PKCE flow)
      setState(() => _statusMessage = 'Connecting to Spotify...');
      final authSuccess = await spotifyService.authenticate();
      if (!authSuccess) {
        throw 'Failed to connect to Spotify. Please try again.';
      }

      // 2. Build compatibility vector from listening data
      setState(() => _statusMessage = 'Analyzing your music taste...');
      final vector = await spotifyService.buildCompatibilityVector();

      if (vector != null) {
        // 3. Get Spotify display name
        final profile = await spotifyService.fetchProfile();
        final displayName = profile?['display_name'] as String?;

        // 4. Save vector + metadata to Firestore
        setState(() => _statusMessage = 'Saving your music profile...');
        await firestoreService.updateUserFields(uid, {
          'spotifyConnected': true,
          'spotifyDisplayName': displayName,
          'musicVector': vector.toMap(),
          'topArtistNames': vector.topArtistNames.take(5).toList(),
        });
      }

      if (!mounted) return;

      // 5. Navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Spacer(flex: 2),

                // Spotify Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/images/spotify_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.music_note,
                              color: Colors.green, size: 60);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Connect Spotify',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Find friends who vibe with your music taste',
                  style: AppTheme.tagline.copyWith(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Privacy note
                Text(
                  'We only use your music taste to match you with compatible friends — we never post on your behalf.',
                  style: AppTheme.subtitle.copyWith(
                    color: AppTheme.textLight.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Status message (shown during connection)
                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _statusMessage!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(flex: 3),

                // Connect Spotify Button
                _isConnecting
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.green))
                    : SimpleButton(
                        text: 'Connect Spotify',
                        gradient: AppTheme.primaryGradient,
                        onPressed: _handleConnectSpotify,
                      ),

                const SizedBox(height: 16),

                // Skip Button
                TextButton(
                  onPressed: _isConnecting ? null : _handleSkip,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppTheme.textLight
                          .withOpacity(_isConnecting ? 0.3 : 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
