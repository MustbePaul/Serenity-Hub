# Restructure report

Original: `backend/` Laravel API and `mobile/` Flutter application with web runner mixed into the Flutter project. No CI configuration was present. Existing API `/api/v1` and Flutter named routes were retained.

Final: `services/api/` Laravel; `apps/mobile/` Flutter source and runners; `apps/web/` independent React + TypeScript web frontend; `infrastructure/development/` local API, React and Flutter reference launchers; `infrastructure/staging/` environment templates; architecture and testing documents under `docs/`. Git can detect file renames after staging; existing unrelated working tree edits were left intact. A source archive and Git status snapshot were saved to ignored `.recovery/` before the React work.

Shared Dart package: none. Flutter remains independently buildable, and its web runner is retained only as a reference. React owns the new browser experience and a typed API client. Laravel retains all business logic, persistence, Reverb authorization and a new browser session flow. Mobile bearer auth remains compatible. CORS origins and authentication throttles are explicit in Laravel.

Known constraints: external staging hosting and Reverb reconnect testing remain gates. Seeded therapist and ZZ support records are synthetic placeholders, never verified providers. React demo labels and isolates synthetic content, with no backend calls. React staging uses real persisted Laravel workflows behind a same-origin proxy. The Flutter web reference still uses in-memory bearer auth and requires login after refresh; it is not the release web application.

The installed Flutter 3.47 tool rejected the repository's Android Gradle 8.7, AGP 8.6 and Kotlin 2.1 pins. The Android wrapper and plugins were raised to Gradle 8.14, AGP 8.11.1 and Kotlin 2.2.20; the debug APK build then passed.
