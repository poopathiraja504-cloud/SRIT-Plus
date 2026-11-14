import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Firebase is configured for Android, iOS, and web only.',
      ),
    };
  }

  static const googleWebClientId =
      '609694857720-l8q8glmb7di5oe1oh19ifekbj548h3ld.apps.googleusercontent.com';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCAJ3WtfH0YyiaME-iqneQOeWpQ4HuMJN4',
    appId: '1:609694857720:web:13abbba212677757813e0d',
    messagingSenderId: '609694857720',
    projectId: 'srit-app-d51f4',
    authDomain: 'srit-app-d51f4.firebaseapp.com',
    storageBucket: 'srit-app-d51f4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvZavMpOLXYmwJqsfYqL8ZrVkEI1W_6Sg',
    appId: '1:609694857720:android:e5f86437027896fd813e0d',
    messagingSenderId: '609694857720',
    projectId: 'srit-app-d51f4',
    storageBucket: 'srit-app-d51f4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5cudDdDG3HUkqAajJFx1aTiUAkB4eM_s',
    appId: '1:609694857720:ios:faea8608e5327443813e0d',
    messagingSenderId: '609694857720',
    projectId: 'srit-app-d51f4',
    storageBucket: 'srit-app-d51f4.firebasestorage.app',
    iosClientId:
        '609694857720-nqgu2e0jffebmcllp3hlm8k3soc597es.apps.googleusercontent.com',
    iosBundleId: 'com.srit.app',
  );
}
