# Serenity Hub

Serenity Hub is a mental wellness platform with a Flutter client and a Laravel API. It supports account access, daily wellness content, searchable self-care resources, audio/video sessions, breathing exercises, progress tracking, mood-based recommendations, therapist discovery, appointment booking and management, saved resources, mood check-ins, support contacts, profile editing, settings, and support requests.

Serenity Hub supports wellness and access to professional care. It is not a replacement for emergency services, diagnosis, or medical treatment.

## Repository Structure

```text
serenity_hub/
  README.md
  backend/                 Laravel API service
    app/                   API controllers, middleware, Eloquent models
    bootstrap/             Laravel bootstrap files
    config/                Laravel configuration
    database/              Migrations, factories, seeders
    public/                API entry point and public assets
    resources/             Blade, CSS, and JS assets for Laravel/Vite
    routes/                API, web, and console routes
    storage/               Logs, cache, framework, and app storage
    tests/                 PHPUnit feature and unit tests
  mobile/                  Flutter app
    android/               Android runner
    assets/fonts/          Bundled Roboto font
    ios/                   iOS runner
    lib/                   Screens, shell, theme, API client, models, providers
    linux/                 Linux desktop runner
    macos/                 macOS desktop runner
    test/                  Flutter tests
    web/                   Web runner and PWA assets
    windows/               Windows desktop runner
```

## Backend Quick Start

The backend is a Laravel 13 API running on PHP 8.3+. It exposes health, USSD prototype, and versioned API routes. Local authentication uses bearer tokens stored on users.

```bash
cd backend
composer install
npm install
php -r "file_exists('.env') || copy('.env.example', '.env');"
php -r "file_exists('database/database.sqlite') || touch('database/database.sqlite');"
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

The default local database is SQLite at `backend/database/database.sqlite`.

Useful backend commands:

```bash
composer run dev
composer test
npm run dev
npm run build
```

Implemented API areas include authentication, home content, resources, support contacts, multimedia library, wellness sessions, media progress, recommendations, bookmarks, therapists, appointments, profile updates, mood check-ins, support tickets, and a provider-agnostic USSD callback prototype.

## Mobile Quick Start

The mobile app is a Flutter project using Material UI, Provider, HTTP, shared preferences, local notifications, URL launching, image picking, `just_audio`, `video_player`, `intl`, and timezone support.

```bash
cd mobile
flutter pub get
flutter run
```

For Flutter web:

```bash
flutter run -d chrome --no-web-resources-cdn
```

By default the Flutter API client points to:

```text
http://10.0.2.2:8000/api/v1
```

Override it at build or run time with:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

For an APK shared outside your local network, use a public HTTPS API URL. Do not use `127.0.0.1` in a reviewer build:

```bash
cd mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.your-domain.example/api/v1
```

## Guest Review Mode

The app includes a reviewer-friendly guest mode for people who cannot access a live backend. Select **Review as guest** from the welcome or sign-in screen to clear saved API tokens, skip live API calls, and use built-in sample resources, therapist profiles, recommendations, and guided text sessions.

Guest mode is intended for product and therapy-workflow review. Live account syncing, appointment creation, support tickets, and streamed audio/video still require connectivity.

## USSD Prototype

The welcome screen includes a local USSD menu preview. The backend also exposes `POST /api/ussd`, accepting common aggregator fields such as `sessionId`, `serviceCode`, `phoneNumber`, and `text`, and returns `CON`/`END` plain text.

This is only a technical prototype. A public shortcode requires MACRA/operator or approved aggregator provisioning, privacy review, verified care-directory content, and operational safeguarding before real users are invited to use it.

## Test Accounts

After running `php artisan migrate --seed`, the backend includes local development accounts:

```text
admin@serenityhub.test / password
user@serenityhub.test / password
banda@serenityhub.test / password
phiri@serenityhub.test / password
```

## Demo Data

Seed data creates an admin, a test user, sample resources, real playable audio/video demo media, wellness sessions, quotes/affirmations, demo support contacts, specialties, approved therapists, and availability slots.

Seeded audio uses meditative MP3 tracks from AudionautiX by Jason Shaw under Creative Commons Attribution 4.0. Seeded videos use public demo MP4 files from MDN/W3C sources. These are development/demo assets so the player screens exercise real streaming, progress saving, and error handling. Replace them with Serenity-owned or licensed production content before release.

Support contacts seeded with country code `ZZ` are placeholders only. Replace them with verified local emergency and crisis-support services before production release.

If you seeded the database before the multimedia or support-contact updates, rerun:

```bash
cd backend
php artisan db:seed
```

## Testing

Backend:

```bash
cd backend
composer test
```

Mobile:

```bash
cd mobile
flutter analyze
flutter test
```
