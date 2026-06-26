# Firebase Setup for Expenses Tracker

This project is now wired to use a `DefaultFirebaseOptions` config file in `lib/firebase_options.dart`.

## 1. Create a Firebase Project
1. Go to https://console.firebase.google.com
2. Create a new project.

## 2. Add Android
1. Add an Android app using package name `com.example.expenses_tracker`.
2. Download `google-services.json`.
3. Place it in `android/app/`.
4. If prompted, add the Google Services Gradle plugin to `android/build.gradle` and `android/app/build.gradle`.

## 3. Add iOS
1. Add an iOS app using the bundle ID from `ios/Runner.xcodeproj` (or `$(PRODUCT_BUNDLE_IDENTIFIER)`).
2. Download `GoogleService-Info.plist`.
3. Place it in `ios/Runner/`.

## 4. Add Web (optional)
1. Add a Web app in Firebase.
2. Copy the Firebase config values.
3. Replace the placeholder values in `lib/firebase_options.dart`.

## 5. Run
```bash
flutter clean
flutter pub get
flutter run
```

## 6. If you want automatic config generation
Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```
Then run:
```bash
flutterfire configure
```
`flutterfire configure` will generate `lib/firebase_options.dart` automatically.
