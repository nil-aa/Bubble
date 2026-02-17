// File generated manually — fill in values from Firebase Console.
// Go to: https://console.firebase.google.com → Project Settings → General
// Copy the config values for each platform from the registered apps.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia is not supported.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HOW TO FILL THESE IN:
  //
  // 1. Go to https://console.firebase.google.com
  // 2. Select project "bubble-friends-finding-app"
  // 3. Click the ⚙️ gear icon → "Project settings"
  // 4. Scroll down to "Your apps" section
  // 5. For ANDROID: click the Android icon, copy the values
  // 6. For WEB: click the </> web icon, copy the values from firebaseConfig
  //
  // The "apiKey", "appId", "messagingSenderId", and "projectId" are the
  // main values you need. You can find them in the config snippets.
  // ═══════════════════════════════════════════════════════════════════════════

  // TODO: Replace all 'YOUR_...' values with real values from Firebase Console

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'bubble-friends-finding-app',
    storageBucket: 'bubble-friends-finding-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'bubble-friends-finding-app',
    storageBucket: 'bubble-friends-finding-app.firebasestorage.app',
    iosBundleId: 'com.example.bubble',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'bubble-friends-finding-app',
    storageBucket: 'bubble-friends-finding-app.firebasestorage.app',
    iosBundleId: 'com.example.bubble',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'bubble-friends-finding-app',
    authDomain: 'bubble-friends-finding-app.firebaseapp.com',
    storageBucket: 'bubble-friends-finding-app.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'bubble-friends-finding-app',
    authDomain: 'bubble-friends-finding-app.firebaseapp.com',
    storageBucket: 'bubble-friends-finding-app.firebasestorage.app',
  );
}
