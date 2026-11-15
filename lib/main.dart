import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_state_provider.dart';
import 'providers/campus_content_provider.dart';
import 'providers/theme_provider.dart';
import 'services/activity_analytics_service.dart';
import 'screens/splash_screen.dart';
import 'services/campus_content_service.dart';
import 'utils/app_theme.dart';
import 'widgets/platform_install_banner.dart';
import 'widgets/analytics_consent_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    startupError = error;
    debugPrintStack(
      label: 'Firebase initialization failed: $error',
      stackTrace: stackTrace,
    );
  }

  if (startupError == null && !kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  if (startupError == null) {
    await ActivityAnalyticsService.instance.initialize();
  }

  runApp(SRITPortal(startupError: startupError));
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    'Received background push: ${message.messageId ?? 'no message id'}',
  );
}

class SRITPortal extends StatelessWidget {
  const SRITPortal({this.startupError, super.key});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        title: 'SRIT PORTAL | Sri Ramakrishna Institute of Technology',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: FirebaseStartupErrorScreen(error: startupError!),
        builder: (context, child) => Column(
          children: [
            const PlatformInstallBanner(),
            const AnalyticsConsentBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthStateProvider()),
        ChangeNotifierProvider(
          create: (_) => CampusContentProvider(service: CampusContentService()),
        ),
      ],
      child: const _ThemedApplication(),
    );
  }
}

class _ThemedApplication extends StatelessWidget {
  const _ThemedApplication();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      title: 'SRIT PORTAL | Sri Ramakrishna Institute of Technology',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
      builder: (context, child) => Column(
        children: [
          const PlatformInstallBanner(),
          const AnalyticsConsentBanner(),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class FirebaseStartupErrorScreen extends StatelessWidget {
  const FirebaseStartupErrorScreen({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56),
                const SizedBox(height: 20),
                Text(
                  'Could not connect to Firebase',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  'Check the Firebase configuration for this platform and '
                  'restart the app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
