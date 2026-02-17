import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Auth operations (email/password).
/// Sign-in & sign-up screens call this instead of navigating directly.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _demoUid;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null || _demoUid != null;
  String? get uid => _demoUid ?? _auth.currentUser?.uid;

  /// Sign in as a demo user (fixed ID)
  void signInAsDemo() {
    _demoUid = 'demo_user_123';
    notifyListeners();
  }

  /// Stream of auth state changes for reactive UI
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Sign Up with email & password
  // ---------------------------------------------------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In with email & password
  // ---------------------------------------------------------------------------
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ── HARDCODED DEMO BYPASS ──────────────────────────────────────────────
      if (email.trim().toLowerCase() == 'a@ssn.edu.in' && password == 'abc123') {
        _demoUid = 'ac0ed1f542b9d74b1edd'; // deterministic hash of a@ssn.edu.in
        notifyListeners();
        return null; // Return null to indicate demo bypass success without real credential
      }
      // ───────────────────────────────────────────────────────────────────────

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------------------------------------------------------------------
  // Map Firebase exceptions to readable messages
  // ---------------------------------------------------------------------------
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
