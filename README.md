# Serenity Hub

Serenity Hub is a wellness and care-access trial. It does not provide diagnosis, treatment or emergency response.

| Path | Purpose |
| --- | --- |
| `services/api` | Laravel API, database and Reverb integration |
| `apps/mobile` | Flutter mobile app for Android and iOS; web runner retained as reference |
| `apps/web` | Independent React + TypeScript browser trial |
| `infrastructure/development` | Local launch script |
| `infrastructure/staging` | Staging environment templates |
| `docs/architecture` | System and migration decisions |
| `docs/testing` | Trial test plan and results |

Start with the [development guide](docs/SERENITY_DEVELOPMENT_GUIDE.md). The [React web handover](docs/architecture/SERENITY_REACT_WEB_HANDOVER.md) explains the frontend and API boundary. The [deployment guide](docs/SERENITY_WEB_TRIAL_DEPLOYMENT.md) covers the isolated staging environment. Existing Serenity Circle operations and governance documents remain under `docs/`.
