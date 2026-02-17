import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';
import 'package:bubble/screens/profile_detail_screen.dart';
import 'package:bubble/services/auth_service.dart';
import 'package:bubble/services/firestore_service.dart';
import 'package:bubble/models/user_model.dart';

/// Onboarding screen for collecting user details
/// Collects: college email, name, department, year
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _selectedYear;
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Graduate'];

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYear == null) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);

      // 1. Create Firebase Auth account
      final credential = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Derive campus ID from email domain
      final emailDomain =
          _emailController.text.trim().split('@').last.toLowerCase();

      // 3. Save initial user profile to Firestore
      final user = UserModel(
        uid: credential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        college: emailDomain, // will be refined in profile setup
        year: _selectedYear!,
        campusId: emailDomain, // campus = email domain
        createdAt: DateTime.now(),
      );
      await firestoreService.saveUser(user);

      if (!mounted) return;

      // 4. Navigate to Profile Detail setup
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileDetailScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                      onPressed: () => Navigator.pop(context),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    const Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Tell us a bit about yourself',
                      style: AppTheme.subtitle.copyWith(
                        color: AppTheme.textLight.withOpacity(0.8),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // College Email
                    _buildInputField(
                      label: 'College Email',
                      controller: _emailController,
                      hint: 'your.name@college.edu',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your college email';
                        }
                        if (!value.contains('@') || !value.contains('.edu')) {
                          return 'Please enter a valid college email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Name
                    _buildInputField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'John Doe',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Department
                    _buildInputField(
                      label: 'Department',
                      controller: _departmentController,
                      hint: 'Computer Science',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your department';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Password
                    _buildInputField(
                      label: 'Create Password',
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Year Dropdown
                    _buildYearDropdown(),
                    
                    const SizedBox(height: 48),
                    
                    // Continue Button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryCoral))
                        : SimpleButton(
                            text: 'Continue',
                            gradient: AppTheme.primaryGradient,
                            onPressed: _handleContinue,
                          ),
                    
                    const SizedBox(height: 24),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Year',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedYear,
          validator: (value) {
            if (value == null) {
              return 'Please select your year';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Select your year',
            hintStyle: TextStyle(
              color: AppTheme.textGray.withOpacity(0.5),
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          dropdownColor: AppTheme.backgroundNavy,
          style: const TextStyle(color: AppTheme.textWhite),
          items: _years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value;
            });
          },
        ),
      ],
    );
  }
}
