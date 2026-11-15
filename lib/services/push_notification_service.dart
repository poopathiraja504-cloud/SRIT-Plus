import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationException implements Exception {
  const PushNotificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  static const _webVapidKey = String.fromEnvironment('FCM_WEB_VAPID_KEY');
  static const _webWorkerPath = 'firebase-messaging-sw.js';

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  String? _registeredUserId;
  String? _registeredToken;

  Future<String> enableForUser(User user) async {
    if (!await _messaging.isSupported()) {
      throw const PushNotificationException(
        'Push notifications are not supported by this browser or device.',
      );
    }

    if (kIsWeb && _webVapidKey.isEmpty) {
      throw const PushNotificationException(
        'Web push is not configured yet. Add the Firebase Web Push VAPID '
        'public key as FCM_WEB_VAPID_KEY and rebuild the website.',
      );
    }

    var settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      throw const PushNotificationException(
        'Notification permission was not granted. Change it in your browser '
        'or device settings to enable notifications.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await _messaging.getAPNSToken() == null) {
      throw const PushNotificationException(
        'Apple Push Notification service is not configured for this app. '
        'Ask the Firebase administrator to finish the APNs setup.',
      );
    }

    final token = await _messaging.getToken(
      vapidKey: kIsWeb ? _webVapidKey : null,
      serviceWorkerScriptPath: kIsWeb ? _webWorkerPath : null,
    );
    if (token == null || token.isEmpty) {
      throw const PushNotificationException(
        'Firebase did not provide a notification token. Check the Firebase '
        'Cloud Messaging configuration and try again.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _saveToken(user.uid, token);
    _listenForTokenRefresh(user.uid);
    return token;
  }

  Future<void> unregisterCurrentDevice(User? user) async {
    if (user == null) return;
    if (!await _messaging.isSupported()) return;
    final token = _registeredUserId == user.uid ? _registeredToken : null;
    if (token == null) {
      if (kIsWeb && _webVapidKey.isEmpty) return;
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          await _messaging.getAPNSToken() == null) {
        return;
      }
    }

    final currentToken =
        token ??
        await _messaging.getToken(
          vapidKey: kIsWeb ? _webVapidKey : null,
          serviceWorkerScriptPath: kIsWeb ? _webWorkerPath : null,
        );
    if (currentToken != null && currentToken.isNotEmpty) {
      await _deviceDocument(user.uid, currentToken).delete();
    }
    _registeredUserId = null;
    _registeredToken = null;
  }

  Future<void> _saveToken(String userId, String token) async {
    await _deviceDocument(userId, token).set({
      'platform': kIsWeb
          ? 'web'
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => 'android',
              TargetPlatform.iOS => 'ios',
              _ => 'other',
            },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _registeredUserId = userId;
    _registeredToken = token;
  }

  DocumentReference<Map<String, dynamic>> _deviceDocument(
    String userId,
    String token,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(token);
  }

  void _listenForTokenRefresh(String userId) {
    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen(
      (token) async {
        try {
          await _saveToken(userId, token);
        } on FirebaseException catch (error, stackTrace) {
          debugPrint('Could not update the FCM token: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM token refresh failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
  }
}
