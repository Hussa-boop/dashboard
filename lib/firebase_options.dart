// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHn3xh93bnOju9oAeYiQTEw7_hChrBCA0',
    appId: '1:1094510394317:web:1eafc573936900fb356284',
    messagingSenderId: '1094510394317',
    projectId: 'shipment-6b76f',
    authDomain: 'shipment-6b76f.firebaseapp.com',
    storageBucket: 'shipment-6b76f.firebasestorage.app',
    measurementId: 'G-2H6V0PWQGW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDb3g3OftVEVxXQ1dBwC5UP6R0Wqr2ay84',
    appId: '1:1094510394317:android:585b9bfa0649a114356284',
    messagingSenderId: '1094510394317',
    projectId: 'shipment-6b76f',
    storageBucket: 'shipment-6b76f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHn3xh93bnOju9oAeYiQTEw7_hChrBCA0',
    appId: '1:1094510394317:ios:2c83369b67f0bb26356284',
    messagingSenderId: '1094510394317',
    projectId: 'shipment-6b76f',
    storageBucket: 'shipment-6b76f.firebasestorage.app',
    iosBundleId: 'com.example.dashboard',
  );
}