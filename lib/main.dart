import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:bubble/firebase_options.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/screens/login_screen.dart';
import 'package:bubble/screens/home_screen.dart';
import 'package:bubble/services/auth_service.dart';
import 'package:bubble/services/firestore_service.dart';
import 'package:bubble/services/spotify_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BubbleApp());
}

class BubbleApp extends StatelessWidget {
  const BubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => SpotifyService()),
      ],
      child: MaterialApp(
        title: 'Bubble',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            // If user is already signed in, go directly to HomeScreen
            if (auth.isSignedIn) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
