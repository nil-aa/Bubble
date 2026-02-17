import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';
import 'package:bubble/screens/onboarding_screen.dart';
import 'package:bubble/screens/sign_in_screen.dart';

/// Login screen for Bubble
/// - Hero image positioned freely
/// - Branding + buttons anchored to bottom
/// - No white hairlines
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRect(
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // -----------------------------
                  // HERO IMAGE (free positioned)
                  // -----------------------------
                  Positioned(
                    top: screenHeight * 0.12, // 🔑 pushes image slightly DOWN
                    left: 0,
                    right: 0,
                    child: _buildHeroImage(screenWidth),
                  ),

                  // ---------------------------------
                  // BOTTOM ANCHORED BRANDING + BUTTONS
                  // ---------------------------------
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBranding(),
                            const SizedBox(height: 28),
                            _buildButtons(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Wide hero illustration with horizontal overflow
  Widget _buildHeroImage(double screenWidth) {
    return SizedBox(
      height: screenWidth * 0.8,
      child: OverflowBox(
        maxWidth: screenWidth * 1.35,
        alignment: Alignment.topCenter,
        child: Image.asset(
          'assets/images/hero_illustration.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Branding section
  Widget _buildBranding() {
    return Column(
      children: [
        const Text(
          'Bubble',
          style: AppTheme.appName,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Find people on your wavelength',
          style: AppTheme.tagline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Your campus, your people',
          style: AppTheme.subtitle.copyWith(
            color: AppTheme.textLight.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Action buttons
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SimpleButton(
          text: 'Login',
          gradient: AppTheme.primaryGradient,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        SimpleButton(
          text: 'Sign Up',
          isOutlined: true,
          borderColor: AppTheme.primaryCoral,
          textColor: AppTheme.primaryCoral,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          },
        ),
      ],
    );
  }
}
