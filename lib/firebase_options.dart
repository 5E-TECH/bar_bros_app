// This file is a manual fallback when FlutterFire CLI is unavailable.
// Source values are taken from android/app/google-services.json and
// ios/Runner/GoogleService-Info.plist.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjteSZiWC9X-KC65xkoRLLMYUe_S49gao',
    appId: '1:63352248047:android:2acaefdd1f4830955f2d1a',
    messagingSenderId: '63352248047',
    projectId: 'styleup-buisness',
    storageBucket: 'styleup-buisness.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoUEmIe9dmYq5-MNJT7Y8ugb0VeCEi4wk',
    appId: '1:63352248047:ios:bb7122970a475c4e5f2d1a',
    messagingSenderId: '63352248047',
    projectId: 'styleup-buisness',
    storageBucket: 'styleup-buisness.firebasestorage.app',
    iosBundleId: 'com.example.barBrosUser',
  );
}
