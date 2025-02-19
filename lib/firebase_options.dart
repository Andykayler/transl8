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
    apiKey: 'AIzaSyBSBSZx5p2oALrwSef7u5iUL06-LvGMebM',
    appId: '1:107276607822:web:4a10f3421c782ef45dbe1f',
    messagingSenderId: '107276607822',
    projectId: 'transl8-55a6a',
    authDomain: 'transl8-55a6a.firebaseapp.com',
    databaseURL: 'https://transl8-55a6a-default-rtdb.firebaseio.com',
    storageBucket: 'transl8-55a6a.appspot.com',
    measurementId: 'G-VHH7CS8W1S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCq2ieGZHzalpSLidT4AQPWys5aDLnSOyk',
    appId: '1:107276607822:android:97a30ebcb4197eed5dbe1f',
    messagingSenderId: '107276607822',
    projectId: 'transl8-55a6a',
    databaseURL: 'https://transl8-55a6a-default-rtdb.firebaseio.com',
    storageBucket: 'transl8-55a6a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhQikyHdXF5WJZiQSDpZn0f0ELXgCWL3Y',
    appId: '1:107276607822:ios:e67c3e8cb2083df25dbe1f',
    messagingSenderId: '107276607822',
    projectId: 'transl8-55a6a',
    databaseURL: 'https://transl8-55a6a-default-rtdb.firebaseio.com',
    storageBucket: 'transl8-55a6a.appspot.com',
    iosClientId: '107276607822-1kc1li624ess3r7pc2pfc7ga75074el3.apps.googleusercontent.com',
    iosBundleId: 'com.ashu.flutterSamples',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhQikyHdXF5WJZiQSDpZn0f0ELXgCWL3Y',
    appId: '1:107276607822:ios:e67c3e8cb2083df25dbe1f',
    messagingSenderId: '107276607822',
    projectId: 'transl8-55a6a',
    databaseURL: 'https://transl8-55a6a-default-rtdb.firebaseio.com',
    storageBucket: 'transl8-55a6a.appspot.com',
    iosClientId: '107276607822-1kc1li624ess3r7pc2pfc7ga75074el3.apps.googleusercontent.com',
    iosBundleId: 'com.ashu.flutterSamples',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBSBSZx5p2oALrwSef7u5iUL06-LvGMebM',
    appId: '1:107276607822:web:8837ae637d84f2df5dbe1f',
    messagingSenderId: '107276607822',
    projectId: 'transl8-55a6a',
    authDomain: 'transl8-55a6a.firebaseapp.com',
    databaseURL: 'https://transl8-55a6a-default-rtdb.firebaseio.com',
    storageBucket: 'transl8-55a6a.appspot.com',
    measurementId: 'G-TN32CJRT4W',
  );
}
