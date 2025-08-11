# Android Configuration Notes

## Firebase Auth Compatibility

This project uses Firebase Auth version 23.2.0 or higher, which requires a minimum Android SDK version of 23. 

### Important Configuration Details

- **minSdkVersion**: Set to 23 in `android/app/build.gradle`
- **Firebase Auth**: Version ^4.17.8 specified in `pubspec.yaml`

### Background

Previously, the project was configured with minSdkVersion 21, which caused build failures with the following error:

```
uses-sdk:minSdkVersion 21 cannot be smaller than version 23 declared in library [com.google.firebase:firebase-auth:23.2.0]
```

### Implications

- The app will not run on Android devices with API level below 23 (Android 6.0 Marshmallow)
- According to Google's distribution dashboard, this covers approximately 94% of active Android devices as of 2023

### Alternative Solutions (Not Implemented)

1. **Use an older version of Firebase Auth**: Not recommended as it may lack security updates and features
2. **Use tools:overrideLibrary**: Could lead to runtime crashes on devices with API level below 23
3. **Split the app into multiple APKs**: More complex to maintain but would allow supporting older devices

### Testing

A test has been added to `test/firebase_config_test.dart` to remind developers about this requirement.