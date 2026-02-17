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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDs8Y8SmS-0Ot-NJ0NZwJEiJIe3G1KtXCw',
    appId: '1:593574043092:android:45db29772a505ab792ca41',
    messagingSenderId: '593574043092',
    projectId: 'bubble-ff561',
    storageBucket: 'bubble-ff561.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDs8Y8SmS-0Ot-NJ0NZwJEiJIe3G1KtXCw',
    appId: '1:593574043092:android:45db29772a505ab792ca41',
    messagingSenderId: '593574043092',
    projectId: 'bubble-ff561',
    storageBucket: 'bubble-ff561.firebasestorage.app',
    iosBundleId: 'com.example.bubble',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDs8Y8SmS-0Ot-NJ0NZwJEiJIe3G1KtXCw',
    appId: '1:593574043092:android:45db29772a505ab792ca41',
    messagingSenderId: '593574043092',
    projectId: 'bubble-ff561',
    storageBucket: 'bubble-ff561.firebasestorage.app',
    iosBundleId: 'com.example.bubble',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDy3Acs2GHFH2fvd44vMxbgBjE0CrEleSM',
    appId: '1:593574043092:web:7de61c8e604f1eb692ca41',
    messagingSenderId: '593574043092',
    projectId: 'bubble-ff561',
    authDomain: 'bubble-ff561.firebaseapp.com',
    storageBucket: 'bubble-ff561.firebasestorage.app',
    measurementId: 'G-LFRJQN9KZ7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDy3Acs2GHFH2fvd44vMxbgBjE0CrEleSM',
    appId: '1:593574043092:web:7de61c8e604f1eb692ca41',
    messagingSenderId: '593574043092',
    projectId: 'bubble-ff561',
    authDomain: 'bubble-ff561.firebaseapp.com',
    storageBucket: 'bubble-ff561.firebasestorage.app',
    measurementId: 'G-LFRJQN9KZ7',
  );
}
