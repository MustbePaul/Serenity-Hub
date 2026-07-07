# Serenity Hub Mobile

Flutter mobile app for Serenity Hub, a mental wellness platform for therapy consultations, session scheduling, self-care resources, bookmarks, profiles, settings, and support.

This app now lives in the `mobile/` workspace directory. The Laravel API backend lives in `../backend/`.

## Getting Started

```bash
flutter pub get
flutter run
```

For Chrome/Web, use the included VS Code launch profile or run:

```bash
flutter run -d chrome --no-web-resources-cdn
```

The web app registers a local Roboto font asset so it can start without fetching fonts from `fonts.gstatic.com`.

## Backend API

The app uses the Laravel API in `../backend/`. By default the Flutter client points to:

```text
http://127.0.0.1:8000/api/v1
```
