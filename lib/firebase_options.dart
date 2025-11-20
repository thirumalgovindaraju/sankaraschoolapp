// lib/firebase_options.dart
// Mock configuration for local development

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
      default:
        return windows;
    }
  }

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAGgcVckZNm2YUt9siAxHHZX0LBGH-OMe4',
    appId: '1:606194274691:web:ec64e655b272f473fd26b6',
    messagingSenderId: '606194274691',
    projectId: 'sankaraschoolapp',
    authDomain: 'sankaraschoolapp.firebaseapp.com',
    storageBucket: 'sankaraschoolapp.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalTesting123456789',
    appId: '1:123456789:web:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'sankaraschoolapp-test',
    authDomain: 'sankaraschoolapp-test.firebaseapp.com',
    storageBucket: 'sankaraschoolapp-test.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalTesting123456789',
    appId: '1:123456789:android:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'sankaraschoolapp-test',
    storageBucket: 'sankaraschoolapp-test.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalTesting123456789',
    appId: '1:123456789:ios:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'sankaraschoolapp-test',
    storageBucket: 'sankaraschoolapp-test.appspot.com',
    iosBundleId: 'com.sankara.schoolapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalTesting123456789',
    appId: '1:123456789:macos:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'sankaraschoolapp-test',
    storageBucket: 'sankaraschoolapp-test.appspot.com',
    iosBundleId: 'com.sankara.schoolapp',
  );
}