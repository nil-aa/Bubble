import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';

/// Sign In screen for existing users
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual login logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging in...'),
          backgroundColor: AppTheme.primaryCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your journey',
                      style: AppTheme.subtitle.copyWith(
                        color: AppTheme.textLight.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildInputField(
                      label: 'College Email',
                      controller: _emailController,
                      hint: 'your.name@college.edu',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textGray,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    SimpleButton(
                      text: 'Login',
                      gradient: AppTheme.primaryGradient,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textGray.withOpacity(0.5),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.backgroundDark.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textGray.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textGray.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryCoral,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
