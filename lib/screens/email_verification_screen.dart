import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_page_shell.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({required this.user, super.key});

  final User user;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isSending = false;
  bool _isChecking = false;
  String? _message;
  bool _hasError = false;

  Future<void> _resendVerification() async {
    setState(() {
      _isSending = true;
      _message = null;
      _hasError = false;
    });
    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        setState(() => _message = 'Verification email sent. Check your inbox.');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = AuthService.messageForFirebaseError(error);
          _hasError = true;
        });
      }
    } on AuthServiceException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _hasError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
      _hasError = false;
    });
    try {
      await _authService.reloadCurrentUser();
      final isVerified = _authService.currentUser?.emailVerified ?? false;
      if (mounted) {
        setState(() {
          _message = isVerified
              ? 'Email verified. Your portal is loading.'
              : 'Your email is not verified yet. Open the link in your inbox, '
                    'then check again.';
          _hasError = !isVerified;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = AuthService.messageForFirebaseError(error);
          _hasError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = AuthService.messageForFirebaseError(error);
          _hasError = true;
        });
      }
    } on AuthServiceException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: 'Verify your email',
      subtitle:
          'Use the verification link sent to ${widget.user.email ?? 'your email address'} '
          'to finish setting up your SRIT Plus account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFF2467CF),
            size: 52,
          ),
          const SizedBox(height: 16),
          const Text(
            'Email verification protects your SRIT Plus account. After '
            'verifying, return here and check again.',
            textAlign: TextAlign.center,
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(
              _message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _hasError
                    ? Theme.of(context).colorScheme.error
                    : const Color(0xFF168A50),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isChecking ? null : _checkVerification,
            child: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("I've verified my email"),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _isSending ? null : _resendVerification,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Resend verification email'),
          ),
          TextButton(onPressed: _signOut, child: const Text('Sign out')),
        ],
      ),
    );
  }
}
