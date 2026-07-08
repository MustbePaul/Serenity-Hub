# Serenity Hub Backend

Laravel API service for Serenity Hub.

The backend provides first-party API endpoints for authentication, profile-backed users, wellness content, multimedia self-care media, guided serenity sessions, playback progress, recommendations, therapist discovery, appointment booking, bookmarks, mood tracking, and support requests.

## Structure

```text
backend/
  app/
    Http/Controllers/Api/V1/   Versioned API controllers
    Http/Middleware/           Bearer token API middleware
    Models/                    Serenity Hub domain models
    Providers/                 Laravel service providers
  bootstrap/                   Application bootstrap
  config/                      Laravel configuration
  database/
    factories/                 Model factories
    migrations/                User, cache, queue, and domain tables
    seeders/                   Local development seed data
  public/                      Front controller and public files
  resources/                   Blade/CSS/JS assets for Laravel + Vite
  routes/                      api.php, web.php, console.php
  storage/                     Logs, framework cache, app storage
  tests/                       PHPUnit tests
```

## Requirements

- PHP 8.3+
- Composer
- Node.js and npm
- SQLite for the default local environment

## Setup

```bash
composer install
npm install
php -r "file_exists('.env') || copy('.env.example', '.env');"
php artisan key:generate
```

Create the SQLite database file if needed:

```bash
php -r "file_exists('database/database.sqlite') || touch('database/database.sqlite');"
```

Then run migrations and seed local data:

```bash
php artisan migrate --seed
```

## Run

Start only the API server:

```bash
php artisan serve
```

Start the Laravel development stack:

```bash
composer run dev
```

The dev script runs the API server, queue listener, Laravel Pail logs, and Vite together.

## API

Health check:

```text
GET /api/health
```

Public v1 endpoints:

```text
POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/resource-categories
GET  /api/v1/resources
GET  /api/v1/resources/{resource}
GET  /api/v1/media
GET  /api/v1/media/{media}
GET  /api/v1/wellness-sessions
GET  /api/v1/wellness-sessions/{session}
GET  /api/v1/therapists
GET  /api/v1/therapists/{therapist}/availability
```

Media listing supports `type`, `query`, `category`, and published status filtering. Wellness session listing supports `category`, `mood`, and `featured`.

Authenticated v1 endpoints require:

```text
Authorization: Bearer <token>
```

```text
GET    /api/v1/auth/me
POST   /api/v1/auth/logout
GET    /api/v1/home
GET    /api/v1/bookmarks
POST   /api/v1/resources/{resource}/bookmark
DELETE /api/v1/resources/{resource}/bookmark
POST   /api/v1/media/{media}/progress
GET    /api/v1/me/media-progress
GET    /api/v1/me/recommendations
POST   /api/v1/appointments
POST   /api/v1/mood-checkins
POST   /api/v1/support-tickets
```

## Domain Tables

The Serenity domain migration creates:

```text
user_profiles
user_settings
therapist_profiles
specialties
therapist_specialties
availability_slots
appointments
session_notes
resource_categories
resources
media_assets
resource_media
wellness_sessions
user_media_progress
bookmarks
quotes_affirmations
mood_checkins
notifications
support_tickets
audit_logs
```

## Seeded Data

`DatabaseSeeder` creates:

- Admin and user test accounts
- Resource categories and published resources
- Real playable audio/video demo media
- Wellness sessions linked to media and resources
- Quotes and affirmations
- Therapist specialties
- Approved therapists with availability slots

Local credentials:

```text
admin@serenityhub.test / password
user@serenityhub.test / password
banda@serenityhub.test / password
phiri@serenityhub.test / password
```

Seeded multimedia assets include AudionautiX meditative MP3 tracks and public MDN/W3C MP4 demo videos. If older placeholder media exists locally, rerun:

```bash
php artisan db:seed
```

The seeder removes old `https://example.com/serenity/...` media rows and writes real public demo URLs.

## Testing and Builds

```bash
composer test
npm run dev
npm run build
```
