# React web handover

## Structure

- `apps/web/src/App.tsx`: React Router routes and protected application shell.
- `apps/web/src/components`: accessible navigation, notices, buttons and page primitives.
- `apps/web/src/pages`: welcome, auth, dashboard, library, sessions, care, appointments, Circle, profile, settings and help.
- `apps/web/src/lib`: typed Laravel contracts, demo content, session API and Reverb subscription adapter.
- `apps/web/src/auth`: browser session state; no bearer token in browser storage.
- `apps/web/src/styles.css`: Serenity sage/teal tokens and responsive layouts. Tailwind is available through Vite for utility classes.
- `apps/web/scripts`: Chrome smoke checks at three viewports and isolated local staging workflow checks.

Laravel owns all data and business rules. React demo performs no API calls. React staging sends same-origin requests through `/api` and `/web`, uses Laravel's HttpOnly session cookie and a CSRF token kept in memory. The web host must reverse-proxy those paths to the isolated Laravel service over HTTPS. Mobile bearer authentication remains unchanged.

Circle HTTP is authoritative. A private Reverb subscription triggers HTTP refetch; polling continues every 15 seconds and reconnection uses bounded retry. The browser sees anonymous community identities only. External Reverb connectivity and reconnection still require a live staging test.

## Known limits

The trial does not implement persistent guided-session progress, account preference toggles, media progress, appointment rescheduling or a full moderation dashboard. It labels unavailable controls and actions rather than claiming success. Staging seed profiles are synthetic test records and are never shown as verified professionals. The demo video uses the MDN CC0 sample; demo audio has no source and is marked unavailable. External testing requires verified care records, crisis contacts, moderation staffing, privacy review and the agreed retention policy.
