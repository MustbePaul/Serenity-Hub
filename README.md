# Serenity Hub

Serenity Hub is a mental wellness platform with a Flutter client and a Laravel API. The app supports account access, daily wellness content, searchable self-care resources, audio/video self-care sessions, playback progress tracking, mood-based recommendations, therapist discovery, appointment booking, saved resources, mood check-ins, profiles, settings, and support requests.

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
    ios/                   iOS runner
    lib/                   Flutter screens, shell, theme, API client, models
    linux/                 Linux desktop runner
    macos/                 macOS desktop runner
    test/                  Flutter widget tests
    web/                   Web runner and icons
    windows/               Windows desktop runner
```

## Backend

The backend is a Laravel 13 API running on PHP 8.3+. It exposes versioned routes under `/api/v1` and uses bearer tokens stored on users for local API authentication.

Implemented API areas include:

- Authentication: register, login, current user, logout
- Home content: quote, affirmation, recommended resource, upcoming appointment
- Resources: categories, paginated resource search/filter, resource detail
- Multimedia library: published audio/video media listing, media detail, resource-linked media
- Guided serenity sessions: searchable wellness sessions backed by media assets
- Playback progress: authenticated progress save/list endpoints
- Recommendations: mood-informed session and media recommendations
- Bookmarks: list, add, remove
- Therapists: approved therapist listing and availability
- Appointments: book an available therapist slot
- Wellness/support: mood check-ins and support tickets

The domain migrations include profiles, settings, therapist profiles, specialties, availability slots, appointments, session notes, resource categories, resources, resource media, media assets, wellness sessions, playback progress, bookmarks, quotes/affirmations, mood check-ins, notifications, support tickets, and audit logs.

Seed data creates an admin, a test user, sample resources, real playable audio/video demo media, wellness sessions, quotes/affirmations, specialties, approved therapists, and availability slots.

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

If you already seeded the database before the multimedia update, run:

```bash
php artisan db:seed
```

The seeder removes old `example.com/serenity` placeholder media rows and replaces them with real public MP3/MP4 URLs.

Useful backend commands:

```bash
composer run dev
composer test
npm run dev
npm run build
```

## Mobile

The mobile app is a Flutter project using Material UI, Provider, HTTP, shared preferences, local notifications, URL launching, image picking, just_audio, video_player, in-app purchase support, OTP utilities, and mobile scanner support.

Main app areas in `mobile/lib` include:

- `main.dart` for routing and the welcome screen
- `app_shell.dart` for bottom navigation
- `api_client.dart` for Laravel API requests and token storage
- Auth screens: login, signup, account recovery
- App screens: home, library, serenity sessions, audio player, video player, media detail, resources/search, consultation, bookmarks, profile, edit profile, schedule, settings, help/support
- Supporting files: theme, sample data, loading indicator, search provider, search result model

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
http://127.0.0.1:8000/api/v1
```

Override it at build/run time with:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## Test Accounts

After running `php artisan migrate --seed`, the backend includes local development accounts:

```text
admin@serenityhub.test / password
user@serenityhub.test / password
banda@serenityhub.test / password
phiri@serenityhub.test / password
```

## Demo Media

Seeded audio uses meditative MP3 tracks from AudionautiX by Jason Shaw under Creative Commons Attribution 4.0. Seeded videos use public demo MP4 files from MDN/W3C sources. These are development/demo assets so the player screens exercise real streaming, progress saving, and error handling; replace them with Serenity-owned or licensed production content before release.

## Notes

Serenity Hub supports wellness and access to professional care. It is not a replacement for emergency services, diagnosis, or medical treatment.
