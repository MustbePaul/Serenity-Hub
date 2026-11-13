# Web trial test plan

## Independent React trial

From `apps/web`: `npm run lint`, `npm run typecheck`, `npm test`, `npm run build`. With the demo Vite server on port 3000 and Chrome available, run `npm run smoke` for desktop (1440px), tablet (800px), mobile (390px), deep link refresh, care preview, no backend calls, no localStorage and overflow checks. In an isolated local staging Laravel database, set `STAGING_SMOKE_EMAIL` and `STAGING_SMOKE_PASSWORD` to synthetic test credentials and run `npm run smoke:staging` for real login, mood, content, session, appointment, Circle and logout flows.

Before any external staging release, manually verify keyboard focus and screen-reader labels, media playback and cross-origin licensing, Reverb reconnect with a running service, two-user data isolation, moderation response, an HTTPS same-origin reverse proxy and Secure session cookies. These are separate gates from a green build.

Run API tests, route list, migrations on an isolated database, Flutter analysis/tests, Chrome debug, web release and Android build. In Chrome test welcome, guest, registration/login/logout, deep links and refresh, narrow/wide navigation, mood writes, library/search, media playback/progress, sessions, care listings and bookings against staging test slots, profile, Circle HTTP and Reverb reconnect, reporting/blocking, offline states and two-user data isolation. Verify demo never writes appointments and no ZZ contact is shown as verified support. Use browser developer tools to confirm tokens and private responses are absent from local storage. Test CORS from the actual staging origin.

Only invite testers after moderation coverage, verified content, privacy review, staging retention and incident ownership are agreed.
