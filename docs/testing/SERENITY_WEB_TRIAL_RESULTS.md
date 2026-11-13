# Serenity Hub trial test results

## Baseline and recovery

Before the React implementation, the repository already contained uncommitted moves from `backend/` to `services/api/` and `mobile/` to `apps/mobile/`, plus other changes. The original baseline Laravel suite passed 43 tests and 208 assertions. A recovery snapshot of the dirty tree was written to ignored `.recovery/before-react-status.txt`, `.recovery/before-react-tracked.patch`, and `.recovery/before-react-source.tar.gz` before React changes. No production database or deployment was touched.

The earlier Flutter restructuring checks passed: `flutter analyze`, 35 Flutter tests, debug and release demo Flutter Web builds, and an Android debug APK build. The Android emulator and iOS build were not run.

## Current React and Laravel results

| Check | Result | Scope |
| --- | --- | --- |
| `npm run typecheck` | PASS | React/TypeScript source |
| `npm run lint` | PASS | React source and smoke scripts |
| `npm test` | PASS, 10 tests | Routing, mode boundaries, API client, page actions and states |
| `npm run build` | PASS | Vite production bundle |
| `npm run smoke` | PASS, 21 checks | Real Chrome at 1440, 800 and 390 px; guest entry, navigation, care preview, no API calls or local storage, refresh, no horizontal overflow |
| `npm run smoke:staging` | PASS, 8 workflows | Chrome against an isolated local Laravel SQLite database: session login, persisted mood check-in, library, session action, test booking and cancellation, Circle post, logout and protected direct URL |
| `php artisan test` | PASS, 46 tests and 219 assertions | Laravel suite including three new browser session/CSRF tests |
| `php artisan route:list --path=api` and `--path=web` | PASS, 53 API and 5 browser auth routes | Laravel routing |
| `php artisan migrate:status` | PASS, 9 applied migrations | Existing local development database; no production DB |
| `flutter test` | PASS, 35 tests | Existing mobile app, unchanged by React work |
| `flutter analyze` | PASS, no issues | Existing mobile app |
| `flutter build apk --debug --dart-define=TRIAL_MODE=staging --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1` | PASS | Android debug APK compilation; emulator runtime not tested |
| `npm audit --omit=dev` | PASS, zero production dependency advisories | npm package audit only |

Chrome screenshots are in [screenshots/](screenshots/) for welcome, dashboard and care at desktop, tablet and mobile sizes. They were captured from the React demo. The local staging smoke used synthetic seeded records and an isolated `.recovery/staging-smoke.sqlite` database. It did not use production data.

## Not verified or unresolved

- External staging deployment, live WSS/Reverb connectivity and reconnect/resubscribe under network interruption: **NOT VERIFIED**. The HTTP fallback and authorized subscription implementation are present, but require a running Reverb service and staging infrastructure.
- Real licensed audio and video playback across browsers: **NOT VERIFIED**. Demo audio is explicitly unavailable; the demo video uses a CC0 sample.
- Android emulator and iOS runtime testing after this React change: **NOT VERIFIED**. React changes did not modify Flutter source.
- External therapist verification, real appointment availability, moderation staffing, crisis contacts, clinical/privacy review and retention approval: **NOT VERIFIED** and required before outside testers are invited.
- `npm audit` reports seven moderate development dependency advisories involving nested `minimatch` packages after upgrading Vitest. The production-only audit reports zero advisories. Review dependency updates before a release gate.
- Persistent guided-session and media progress, account preference editing, rescheduling and a moderation dashboard are not implemented in the React trial. The UI does not report those actions as saved.

Run React locally with `./infrastructure/development/web.ps1 -Mode demo` from the repository root, or `cd apps/web; npm ci; npm run dev` and open `http://127.0.0.1:3000`. Staging requires a separate Laravel API and `./infrastructure/development/web.ps1 -Mode staging -ApiProxyTarget http://127.0.0.1:8000`.
