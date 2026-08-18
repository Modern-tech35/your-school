
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
    apiKey: 'AIzaSyDLqXBNkteYz1LM-3qcOmm3B1AVwOk_w_8',
    appId: '1:771176959094:android:8df713a23ec1f397d92357',
    messagingSenderId: '771176959094',
    projectId: 'fir-gemini-roocode',
    storageBucket: 'fir-gemini-roocode.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_Ea-VUH1EnlXbbA-gaw-aw9pdAx0WmEQ',
    appId: '1:771176959094:web:dcf9823631e764aed92357',
    messagingSenderId: '771176959094',
    projectId: 'fir-gemini-roocode',
    authDomain: 'fir-gemini-roocode.firebaseapp.com',
    storageBucket: 'fir-gemini-roocode.firebasestorage.app',
    measurementId: 'G-N8E3LFEDBM',
  );
}