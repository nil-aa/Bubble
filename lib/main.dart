import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/screens/login_screen.dart';

void main() {
  runApp(const BubbleApp());
}

class BubbleApp extends StatelessWidget {
  const BubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
