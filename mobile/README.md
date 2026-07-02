# Serenity Hub Mobile

Flutter mobile app for Serenity Hub, a mental wellness platform for therapy consultations, session scheduling, self-care resources, bookmarks, profiles, settings, and support.

This app now lives in the `mobile/` workspace directory. The Laravel API backend lives in `../backend/`.

## Getting Started

```bash
flutter pub get
flutter run
```

## Backend Migration Note

Some current screens still call Supabase directly or use mock data. Those flows should be migrated to HTTP calls against the Laravel API as the backend is implemented.
