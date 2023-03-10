// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGTUz_eBccUy8cLZtr-5ZZYJ-1PNA9nkU',
    appId: '1:954796230206:android:dcecdcb171a9a7ef93336f',
    messagingSenderId: '954796230206',
    projectId: 'flutter-chat-erick',
    databaseURL: 'https://flutter-chat-erick-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-chat-erick.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsEtp2Ti01pfCz5gTCZwtwX4VC0qgLztA',
    appId: '1:954796230206:ios:98d8011ea1b0e83a93336f',
    messagingSenderId: '954796230206',
    projectId: 'flutter-chat-erick',
    databaseURL: 'https://flutter-chat-erick-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-chat-erick.appspot.com',
    iosClientId:
        '954796230206-0queuq23ji3lric4k1uuu7f0u452b39p.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterChat',
  );
}
