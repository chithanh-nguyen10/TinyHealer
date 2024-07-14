// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkikNymv_98gs06TUbxINWEBNjZS4D2rc',
    appId: '1:286570350752:web:f4aac7152c7b2b0fb621c5',
    messagingSenderId: '286570350752',
    projectId: 'tinyhealer-30c94',
    authDomain: 'tinyhealer-30c94.firebaseapp.com',
    storageBucket: 'tinyhealer-30c94.appspot.com',
    measurementId: 'G-JVZPXL29N6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChTMWwR85OrVkwMcbF8pHzw-tAkaw9464',
    appId: '1:286570350752:android:5ec0911a1c5c58c7b621c5',
    messagingSenderId: '286570350752',
    projectId: 'tinyhealer-30c94',
    storageBucket: 'tinyhealer-30c94.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCC328vryFUxOhbZ6aXMXAfHUcRii5xp2A',
    appId: '1:286570350752:ios:d8eb2e1f0f52d167b621c5',
    messagingSenderId: '286570350752',
    projectId: 'tinyhealer-30c94',
    storageBucket: 'tinyhealer-30c94.appspot.com',
    androidClientId: '286570350752-bq6tdbt0alr0c5t69r7lkv079vb9iess.apps.googleusercontent.com',
    iosClientId: '286570350752-cgjnskvjfhdf3uobcjk2jfutjemeps43.apps.googleusercontent.com',
    iosBundleId: 'com.example.tinyhealer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCC328vryFUxOhbZ6aXMXAfHUcRii5xp2A',
    appId: '1:286570350752:ios:d8eb2e1f0f52d167b621c5',
    messagingSenderId: '286570350752',
    projectId: 'tinyhealer-30c94',
    storageBucket: 'tinyhealer-30c94.appspot.com',
    androidClientId: '286570350752-bq6tdbt0alr0c5t69r7lkv079vb9iess.apps.googleusercontent.com',
    iosClientId: '286570350752-cgjnskvjfhdf3uobcjk2jfutjemeps43.apps.googleusercontent.com',
    iosBundleId: 'com.example.tinyhealer',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkikNymv_98gs06TUbxINWEBNjZS4D2rc',
    appId: '1:286570350752:web:e270b9a8f76d1198b621c5',
    messagingSenderId: '286570350752',
    projectId: 'tinyhealer-30c94',
    authDomain: 'tinyhealer-30c94.firebaseapp.com',
    storageBucket: 'tinyhealer-30c94.appspot.com',
    measurementId: 'G-8ZS3RP4WYC',
  );
}