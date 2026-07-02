# Serenity Hub Backend

Laravel API backend for Serenity Hub.

This service is intended to replace the mobile app's current Supabase-backed flows with a first-party Laravel API for authentication, profiles, experts, consultations, bookings, bookmarks, resources, and support requests.

## Getting Started

```bash
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

The default local environment uses SQLite. Create `database/database.sqlite` if it does not already exist before running migrations.

## Planned API Domains

- Authentication and account recovery
- User profiles and profile images
- Mental health experts
- Consultation booking and payments
- Session schedules and reminders
- Self-care resources and search
- Bookmarks
- Support tickets
