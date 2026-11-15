import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleAccountLinkRequired extends AuthServiceException {
  const GoogleAccountLinkRequired({
    required this.email,
    required this.pendingCredential,
  }) : super(
         'An SRIT PORTAL account already exists for $email. Sign in with its '
         'password to securely link Google.',
       );

  final String email;
  final AuthCredential pendingCredential;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  static Future<void>? _googleInitialization;

  Stream<User?> get authStateChanges => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthServiceException(
        'Sign in to your SRIT PORTAL account before verifying your email.',
      );
    }
    if (!user.emailVerified) await user.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      } on FirebaseAuthException catch (error) {
        final email = error.email;
        final credential = error.credential;
        if (error.code == 'account-exists-with-different-credential' &&
            email != null &&
            credential != null) {
          throw GoogleAccountLinkRequired(
            email: email,
            pendingCredential: credential,
          );
        }
        rethrow;
      }
      return;
    }

    try {
      _googleInitialization ??= GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? DefaultFirebaseOptions.ios.iosClientId
            : null,
        serverClientId: DefaultFirebaseOptions.googleWebClientId,
      );
      await _googleInitialization;
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthServiceException(
          'Google authentication did not return a valid ID token. Verify the '
          'Android signing fingerprints and Google provider configuration in '
          'Firebase Console.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      try {
        await _firebaseAuth.signInWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'account-exists-with-different-credential') {
          throw GoogleAccountLinkRequired(
            email: error.email ?? googleUser.email,
            pendingCredential: error.credential ?? credential,
          );
        }
        rethrow;
      }
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Google Sign-In canceled or aborted.');
        return;
      }
      throw AuthServiceException(
        error.description ??
            'Google sign-in could not be completed (${error.code.name}).',
      );
    } on FirebaseAuthException {
      rethrow;
    } on GoogleAccountLinkRequired {
      rethrow;
    } on AuthServiceException {
      rethrow;
    } catch (error) {
      throw AuthServiceException('Google sign-in failed: $error');
    }
  }

  Future<void> linkGoogleToExistingAccount({
    required String email,
    required String password,
    required AuthCredential pendingCredential,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingAccount = await _firebaseAuth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final user = existingAccount.user;
    if (user == null || user.email?.trim().toLowerCase() != normalizedEmail) {
      throw const AuthServiceException(
        'The authenticated account does not match the Google account email. '
        'No accounts were linked.',
      );
    }

    try {
      await user.linkWithCredential(pendingCredential);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use') {
        throw const AuthServiceException(
          'This Google account is already linked to a different SRIT PORTAL '
          'account. Contact support to protect your existing student data.',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      if (_googleInitialization != null) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('Google sign-out cleanup error: $e');
    }
  }

  static String messageForFirebaseError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'account-exists-with-different-credential' =>
        'An account already exists for this email with a different sign-in '
            'method. Sign in with that method first; Firebase did not provide '
            'a credential that can be safely linked automatically.',
      'weak-password' => 'Choose a stronger password (at least 6 characters).',
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled in Firebase Console.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
}
