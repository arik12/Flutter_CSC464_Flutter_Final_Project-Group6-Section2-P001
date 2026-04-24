// File generated based on google-services.json
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web config (same project, same API key)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGbsJd7KZg1o4Fgxczmi_eW5wutB12U1E',
    appId: '1:20103854007:web:d20ba82e31f0f136245a32',
    messagingSenderId: '20103854007',
    projectId: 'flutter-task-app-bd75e',
    databaseURL: 'https://flutter-task-app-bd75e-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-task-app-bd75e.firebasestorage.app',
    authDomain: 'flutter-task-app-bd75e.firebaseapp.com',
  );

  // Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGbsJd7KZg1o4Fgxczmi_eW5wutB12U1E',
    appId: '1:20103854007:android:d20ba82e31f0f136245a32',
    messagingSenderId: '20103854007',
    projectId: 'flutter-task-app-bd75e',
    databaseURL: 'https://flutter-task-app-bd75e-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-task-app-bd75e.firebasestorage.app',
  );
}
