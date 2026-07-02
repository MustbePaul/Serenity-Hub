# Serenity Hub

Serenity Hub is a mental wellness platform split into a Flutter mobile app and a Laravel API backend.

## Repository Structure

```text
serenity_hub/
  mobile/      # Flutter app
  backend/     # Laravel API
```

## What It Does

The mobile app is designed to help users access mental health support through account management, therapist consultations, session scheduling, searchable self-care resources, saved bookmarks, profile management, settings, and help/support screens.

The backend is now scaffolded as a Laravel API service that will replace the current Supabase-backed flows over time.

## Local Development

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

### Backend

```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

The backend currently uses SQLite for local development.

## GitHub Description

Flutter mental wellness app with a Laravel backend for therapy booking, self-care resources, profiles, and user support.
