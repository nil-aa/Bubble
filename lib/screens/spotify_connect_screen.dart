import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';
import 'package:bubble/screens/home_screen.dart';

/// Spotify connection screen
/// Allows users to connect their Spotify account for music taste matching
class SpotifyConnectScreen extends StatelessWidget {
  const SpotifyConnectScreen({super.key});

  void _handleConnectSpotify(BuildContext context) {
    // TODO: Implement Spotify OAuth flow
    debugPrint('Connect Spotify pressed');
    
    // For now, navigate to home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _handleSkip(BuildContext context) {
    // Navigate to home
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
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Spotify Logo (Local Asset)
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
                          return const Icon(Icons.music_note, color: Colors.green, size: 60);
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
                
                const Spacer(flex: 3),
                
                // Connect Spotify Button
                SimpleButton(
                  text: 'Connect Spotify',
                  gradient: AppTheme.primaryGradient,
                  onPressed: () => _handleConnectSpotify(context),
                ),
                
                const SizedBox(height: 16),
                
                // Skip Button
                TextButton(
                  onPressed: () => _handleSkip(context),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppTheme.textLight.withOpacity(0.8),
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
