import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/firebase_options.dart';

void main() {
  group('Firebase Configuration Tests', () {
    test('Android Firebase options are properly configured', () {
      final options = DefaultFirebaseOptions.android;
      
      // Verify that the Android Firebase options are properly configured
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
      expect(options.storageBucket, isNotEmpty);
      
      // Verify specific values
      expect(options.projectId, equals('shipment-6b76f'));
    });
    
    test('iOS Firebase options are properly configured', () {
      final options = DefaultFirebaseOptions.ios;
      
      // Verify that the iOS Firebase options are properly configured
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
      expect(options.storageBucket, isNotEmpty);
      expect(options.iosBundleId, isNotEmpty);
      
      // Verify specific values
      expect(options.projectId, equals('shipment-6b76f'));
    });
    
    test('Web Firebase options are properly configured', () {
      final options = DefaultFirebaseOptions.web;
      
      // Verify that the Web Firebase options are properly configured
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
      expect(options.authDomain, isNotEmpty);
      expect(options.storageBucket, isNotEmpty);
      expect(options.measurementId, isNotEmpty);
      
      // Verify specific values
      expect(options.projectId, equals('shipment-6b76f'));
    });
    
    // This test is a reminder that the minSdkVersion must be at least 23 for Firebase Auth compatibility
    test('Android minSdkVersion compatibility check', () {
      // This is a documentation test to remind developers that:
      // The minSdkVersion in android/app/build.gradle must be at least 23
      // for compatibility with Firebase Auth 23.2.0+
      
      // If this test is being read, it means someone is reviewing the Firebase configuration,
      // and they should be aware of this requirement.
      expect(true, isTrue, reason: 'Reminder: minSdkVersion must be at least 23 for Firebase Auth compatibility');
    });
  });
}