# Serenity Hub Mobile

Flutter client for Serenity Hub, a mental wellness app for daily grounding, self-care resources, audio/video serenity sessions, media playback, progress tracking, therapist consultations, appointment scheduling, bookmarks, profiles, settings, and support.

## Structure

```text
mobile/
  android/                  Android runner
  assets/fonts/             Bundled Roboto font
  ios/                      iOS runner
  lib/
    api_client.dart         Laravel API client and token persistence
    app_shell.dart          Bottom navigation shell
    main.dart               App entry point, routes, welcome screen
    serenity_theme.dart     App theme
    sample_data.dart        Local sample content
    widgets/                Reusable UI widgets
    models/                 Dart models
    providers/              Provider state classes
    *.dart                  Feature screens
  linux/                    Linux desktop runner
  macos/                    macOS desktop runner
  test/                     Flutter tests
  web/                      Web runner and PWA assets
  windows/                  Windows desktop runner
```

## App Areas

- Welcome, sign in, sign up, and account recovery
- Home dashboard
- Library for articles, audio resources, and video resources
- Guided serenity sessions with category filters
- Audio playback through `just_audio`
- Video playback through `video_player`
- Continue-progress and mood-based recommendation cards
- Resource search and browsing
- Therapist consultation flow
- Schedule and reminders
- Saved bookmarks
- Profile and edit profile
- Settings
- Help and support

## Requirements

- Flutter SDK compatible with Dart `^3.7.2`
- Android Studio, Xcode, Chrome, or desktop tooling for your target platform
- Serenity Hub backend running locally for API-backed flows

## Setup

```bash
flutter pub get
```

## Run

Mobile or desktop target:

```bash
flutter run
```

Chrome/web target:

```bash
flutter run -d chrome --no-web-resources-cdn
```

The app bundles `assets/fonts/Roboto-Regular.ttf`, so the web target can start without fetching Roboto from `fonts.gstatic.com`.

Seeded media streams from public HTTPS URLs. For Android emulator testing, make sure your backend API URL uses `10.0.2.2`, but media files still load directly from the internet.

## Backend API

The Flutter API client uses:

```text
http://127.0.0.1:8000/api/v1
```

Override the API base URL with a Dart define:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

For Android emulators, you may need to point at the host machine instead:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## Main Dependencies

- `provider` for state management
- `http` for API calls
- `shared_preferences` for token storage
- `flutter_local_notifications` for local reminders
- `url_launcher` for opening external links
- `image_picker` for profile/media selection
- `just_audio` for audio session playback
- `video_player` for video session playback
- `in_app_purchase`, `otp`, and `mobile_scanner` for planned commerce, verification, and scanning flows
- `intl` and `flutter_localizations` for localization-ready UI

## Multimedia Flow

The Library tab combines Laravel `/media` results with existing `/resources` articles. The Sessions tab uses `/wellness-sessions`. Audio and video screens save playback progress to `/media/{media}/progress` about every 20 seconds and when leaving the screen. Home uses `/me/recommendations` and `/me/media-progress` when the user is signed in.

## Tests

```bash
flutter analyze
flutter test
```
