import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthStateProvider extends ChangeNotifier {
  AuthStateProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _subscription = _authService.authStateChanges.listen(
      (user) {
        _user = user;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _isLoading = false;
        _error = error;
        notifyListeners();
      },
    );
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  bool _isLoading = true;
  Object? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
