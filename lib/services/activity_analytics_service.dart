import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityAnalyticsService {
  ActivityAnalyticsService._();

  static final instance = ActivityAnalyticsService._();
  static const _consentPreferenceKey = 'srit_portal_analytics_consent_v1';

  static const eventNames = <String>{
    'login_button_click',
    'google_sign_in_attempt',
    'google_sign_in_success',
    'google_sign_in_failure',
    'email_login_attempt',
    'email_login_success',
    'email_login_failure',
    'dashboard_visit',
    'attendance_visit',
    'results_visit',
    'timetable_visit',
    'profile_visit',
    'settings_visit',
    'navigation_click',
    'app_install_interaction',
    'logout',
  };

  static const pages = <String>{
    'login',
    'dashboard',
    'attendance',
    'results',
    'timetable',
    'profile',
    'settings',
    'navigation',
    'installation',
    'other',
  };

  static const features = <String>{
    'email',
    'google',
    'dashboard',
    'attendance',
    'results',
    'timetable',
    'profile',
    'settings',
    'navigation',
    'install_pwa',
    'download_apk',
    'ios_home_screen',
    'other',
  };

  final ValueNotifier<bool?> consent = ValueNotifier<bool?>(null);
  bool get isEnabled => consent.value == true;

  Future<void> initialize() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      final preferences = await SharedPreferences.getInstance();
      final savedConsent = preferences.getBool(_consentPreferenceKey);
      if (savedConsent == true) {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      }
      consent.value = savedConsent;
    } catch (error, stackTrace) {
      consent.value = false;
      debugPrint('Could not initialize privacy-safe analytics: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setConsent(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_consentPreferenceKey, enabled);
    consent.value = enabled;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  }

  Future<void> logActivity({
    required String eventName,
    required String page,
    String feature = 'other',
  }) async {
    if (!isEnabled) return;
    if (!eventNames.contains(eventName) ||
        !pages.contains(page) ||
        !features.contains(feature)) {
      throw ArgumentError('Analytics event contains an unsupported value.');
    }

    final platform = kIsWeb
        ? 'web'
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => 'android',
            TargetPlatform.iOS => 'ios',
            _ => 'other',
          };

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {'page': page, 'feature': feature, 'platform': platform},
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase Analytics event "$eventName" failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activity')
          .add({
            'eventName': eventName,
            'timestamp': FieldValue.serverTimestamp(),
            'platform': platform,
            'page': page,
            'feature': feature,
          });
    } catch (error, stackTrace) {
      debugPrint('Firestore activity event "$eventName" failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> logPageVisit(String route) async {
    final normalized = route.toLowerCase().replaceAll('_', '-');
    final (page, eventName) = switch (normalized) {
      'dashboard' || 'my-dashboard' || 'home' => (
        'dashboard',
        'dashboard_visit',
      ),
      final value when value.contains('attendance') => (
        'attendance',
        'attendance_visit',
      ),
      final value
          when value.contains('result') || value.contains('internal-mark') => (
            'results',
            'results_visit',
          ),
      final value when value.contains('timetable') || value.contains('time-table') => (
        'timetable',
        'timetable_visit',
      ),
      final value when value.contains('profile') => ('profile', 'profile_visit'),
      final value
          when value.contains('setting') ||
              value.contains('security') ||
              value.contains('password') => ('settings', 'settings_visit'),
      _ => (null, null),
    };
    if (page == null || eventName == null) return;
    await logActivity(
      eventName: eventName,
      page: page,
      feature: page,
    );
  }

  Future<void> logNavigationClick(String route) {
    final normalized = route.toLowerCase();
    final feature = switch (normalized) {
      final value when value.contains('attendance') => 'attendance',
      final value
          when value.contains('result') || value.contains('internal-mark') =>
        'results',
      final value when value.contains('timetable') || value.contains('time-table') =>
        'timetable',
      final value when value.contains('profile') => 'profile',
      final value
          when value.contains('setting') ||
              value.contains('security') ||
              value.contains('password') => 'settings',
      final value when value.contains('dashboard') || value == 'home' =>
        'dashboard',
      _ => 'navigation',
    };
    return logActivity(
      eventName: 'navigation_click',
      page: 'navigation',
      feature: feature,
    );
  }
}
