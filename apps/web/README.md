# Serenity Hub Web

Independent React + TypeScript + Vite application. Laravel remains the only backend and database owner. Flutter mobile remains in `../mobile`; its web runner is retained as a reference.

```powershell
cd apps/web
npm ci
$env:VITE_TRIAL_MODE='demo'
npm run dev
```

Open http://localhost:3000. Demo contains only synthetic content and does not connect to personal records. For staging, set `VITE_TRIAL_MODE=staging`, `VITE_API_PROXY_TARGET` to the isolated Laravel origin, and the public Reverb URL/key. Vite proxies `/api` and `/web` to Laravel so the browser uses a same-origin HttpOnly session cookie with CSRF tokens. In deployment, the web host must reverse-proxy these paths to Laravel over HTTPS; do not expose cross-origin cookie auth without a separate security review.

Checks: `npm run lint`, `npm run typecheck`, `npm test`, `npm run build`.
