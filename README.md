# Dân Trí Clone

A Flutter clone of the Dân Trí experience with news, video, notifications, and AI chat helpers for traffic laws and healthcare. The app uses Firebase for authentication/profile storage, RSS feeds for news, YouTube for videos, and Dialogflow-based bots for Q&A.

## Features
- News feed with article details, comments, and category browsing
- Video section (YouTube) with comments list and share support
- Dân Trí AI hub: 24h news digest, traffic-law bot, healthcare bot (Dialogflow)
- Firebase email/password + Google sign-in, profile view/edit, notifications screen
- Saved helpers: search bar, lunar date widget, gold/fuel quick cards, and utility shortcuts
- GoRouter navigation with shared layout and bottom navigation

## Tech Stack
- Flutter 3.7+, Dart
- State: Provider + ChangeNotifier view models
- Navigation: go_router
- Backend: Firebase Auth, Firestore, Firebase Core
- Media/feeds: RSS via `webfeed`/`xml`, YouTube player, cached images
- Dialogflow for chatbots

## Prerequisites
- Flutter SDK 3.7+ installed
- Android Studio/Xcode for platform builds
- Firebase project with mobile configs
- Dialogflow agents and credential JSONs for traffic-law and healthcare bots

## Project Setup
1) Install dependencies
```bash
flutter pub get
```

2) Firebase configuration  
Place your platform configs in the project:
- Android: `android/app/google-services.json`
- iOS/macOS: `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist`
If you re-run `flutterfire configure`, keep `lib/firebase_options.dart` in sync.

3) Dialogflow credentials  
Add service account JSONs to `assets/traffic-law-credentials.json` and `assets/health-care-credentials.json` (these paths are already listed in `pubspec.yaml`).

4) Assets  
Logos are under `assets/logo/` and referenced by launcher/splash configs.

## Running
```bash
flutter run
```
Use `-d chrome`/`-d macos`/`-d windows` etc. to target specific platforms.

## Testing
```bash
flutter test
```

## Key Paths
- App entry/theme: `lib/main.dart`
- Routing: `lib/router/router.dart`
- Screens: `lib/views/`
- View models: `lib/viewmodels/`
- Services (news, video, auth, chatbots): `lib/services/`

## Notes
- Env/secrets (Firebase, Dialogflow) are not committed; provide your own keys.
- Splash/launcher icons are configured via `flutter_native_splash` and `flutter_launcher_icons` using assets in `assets/logo/`.
