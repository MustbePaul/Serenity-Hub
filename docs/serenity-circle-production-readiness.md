# Serenity Circle Production Readiness

This document captures the production requirements for Serenity Circle realtime messaging and moderation. It intentionally uses placeholders only. Do not put real secrets in this repository or in Flutter builds.

## Baseline Message Flow

Serenity Circle keeps HTTP authoritative:

```text
HTTP command
  -> Laravel validation/authorization
  -> database state change
  -> privacy-safe HTTP response
  -> queued broadcast event
  -> private room channel: private-community.room.{roomSlug}
  -> Flutter CommunityRealtimeService
  -> CommunityProvider
  -> merge-by-ID state reconciliation
```

Initial history, pagination, reconnect reconciliation, and degraded operation continue through HTTP. WebSockets are an acceleration path for already-authorized room state, not the source of truth.

## Required Environment

Backend:

```text
BROADCAST_CONNECTION=reverb
REVERB_APP_ID=<reverb-app-id>
REVERB_APP_KEY=<public-reverb-app-key>
REVERB_APP_SECRET=<secret-reverb-signing-key>
REVERB_HOST=<public-api-host-or-reverb-host>
REVERB_PORT=443
REVERB_SCHEME=https
REVERB_ALLOWED_ORIGINS=https://<trusted-web-origin>
REVERB_SERVER_HOST=127.0.0.1
REVERB_SERVER_PORT=8080
QUEUE_CONNECTION=database|redis|sqs
CACHE_STORE=database|redis
```

Flutter receives only public connection values:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
  --dart-define=COMMUNITY_WS_URL=wss://api.example.com \
  --dart-define=COMMUNITY_WS_APP_KEY=<public-reverb-app-key>
```

Never ship `REVERB_APP_SECRET`, Laravel `APP_KEY`, database credentials, or private API keys in Flutter.

## TLS, Reverse Proxy, and Origins

Public production traffic must use `https://` for HTTP and `wss://` for WebSockets. Terminate TLS at the reverse proxy or platform edge, forward API traffic to Laravel, and forward WebSocket traffic to the Reverb process.

Reverse proxy requirements:

- Preserve `Host` and forwarded protocol headers.
- Support `Upgrade: websocket` and `Connection: Upgrade`.
- Use read/proxy timeouts long enough for persistent WebSocket connections.
- Keep Reverb on an internal port when possible.
- Expose only the TLS endpoint publicly; restrict direct Reverb process access with firewall or platform networking.
- Configure `REVERB_ALLOWED_ORIGINS` to trusted web origins for browser clients. Native Flutter clients do not rely on browser CORS, so validate mobile access through authenticated channel authorization rather than browser-only assumptions.

Do not use `ws://` for public production traffic. Local development may use `ws://127.0.0.1:8080` or emulator host aliases.

## Long-Running Processes

Serenity Circle requires processes beyond PHP web requests:

- Laravel HTTP service.
- Reverb server, for example `php artisan reverb:start --host=${REVERB_SERVER_HOST} --port=${REVERB_SERVER_PORT}`.
- Queue worker because broadcast events implement `ShouldBroadcast`, for example `php artisan queue:work --tries=3 --timeout=60`.
- Scheduler only if the deployment already runs scheduled Laravel tasks; no Circle-specific scheduler job is currently required.

Process manager requirements:

- Start services at boot.
- Restart failed Reverb and queue processes with bounded retry behavior.
- Capture stdout/stderr logs centrally.
- Support graceful deploy restarts: `php artisan queue:restart`, restart Reverb after code/config changes, and run `php artisan config:cache` only after environment values are correct.

## Broadcast Delivery

The events `CommunityMessageCreated`, `CommunityMessageRemoved`, and `CommunityReactionUpdated` use `ShouldBroadcast`, so queue workers are mandatory when `QUEUE_CONNECTION` is asynchronous. Database state is written before dispatch; HTTP responses remain authoritative and Flutter reconciliation/polling recovers missed realtime events.

Operationally monitor broadcast job failures. A temporary Reverb outage must not be treated as message persistence failure, but queue backlog or failed broadcast jobs should alert operators.

## Health Checks

Existing public health endpoints are minimal (`/api/health` and Laravel `/up`) and should remain free of secrets and topology. Production monitoring should check:

- API health through the public minimal endpoint.
- Database connectivity through protected/internal diagnostics or platform checks.
- Cache backend availability.
- Queue worker liveness and failed job count.
- Reverb process liveness and successful staging WebSocket subscription.

Detailed diagnostics should be internal or protected, not public.

## Observability

Recommended operational signals:

- WebSocket connection/auth failures.
- Broadcast auth `403` and `429` rates.
- Reconnect/fallback frequency from client telemetry if a privacy-preserving monitoring channel exists.
- Broadcast job failures and queue latency.
- Reverb process restarts.
- Community message, reaction, and report error rates.
- Moderator queue size by status.
- Rate-limit events for posts, reactions, reports, and broadcast auth.

Do not log bearer tokens, Reverb auth signatures, private account fields, moderator notes, report details, device identifiers, IP addresses, or pseudonym-to-account mappings for analytics. Moderation audit records may contain controlled internal references and must remain access restricted.

## Staging WebSocket Smoke Test

Use staging accounts and staging data only.

1. Account A enters World Room.
2. Account B enters World Room.
3. B posts a message.
4. A sees the message without manual refresh.
5. A reacts.
6. B sees the updated reaction count.
7. B removes their own message.
8. A sees it disappear.
9. Disconnect A's network.
10. B posts multiple messages.
11. Reconnect A.
12. A reconciles correctly with no duplicate messages.
13. Switch A to another room.
14. Confirm World Room events do not appear there.
15. Block B from A.
16. Confirm B's content remains absent from A.
17. Inspect socket frames where practical and confirm absence of `user_id`, email, phone, real name, tokens, and moderator details.

## Controlled Load Test Plan

Run only against local or staging infrastructure approved for load testing.

Suggested scenarios:

- 25, 50, and 100 concurrent room subscriptions.
- Sustained message broadcasts for 10 minutes.
- Sustained reaction broadcasts for 10 minutes.
- Reconnect burst after temporarily stopping Reverb.

Record environment, concurrency, duration, message/reaction latency, failed requests, failed jobs, Reverb memory, PHP worker CPU/memory, queue depth, and database pressure. Do not fabricate results if staging infrastructure is unavailable.

## Moderation

Moderator APIs are complete and protected by existing admin/moderator authorization. No compatible admin web frontend exists in the Laravel project, so moderator web UI remains a separate implementation task. If implemented later, use safety-focused wording such as "Safety flags", "Possible self-harm concern", "Possible privacy concern", and "Requires review". Do not label people clinically or terminate access to broader wellness services automatically from a content moderation decision.

## Migrations, Backup, and Retention

The realtime/moderation migration adds indexes and creates posting restriction and moderation audit tables. It does not recreate community tables or require destructive data resets. Validate rollback/forward in a local or staging database before production deploy.

Back up:

- Community rooms.
- Pseudonymous identities.
- Messages and reactions.
- Reports.
- Posting restrictions.
- Moderation audit logs.

Retention policy is a governance requirement. Define moderation evidence retention, account deletion handling, pseudonymous identity deletion/anonymization, report retention, and audit retention before production. Do not silently delete evidence, and do not assume indefinite retention without policy approval.

## Deployment Checklist

Before production release:

- `composer audit` has no unresolved serious advisories.
- `composer test` passes.
- `flutter analyze` passes.
- `flutter test` passes.
- Production env uses `BROADCAST_CONNECTION=reverb`.
- Reverb secret is present only on the backend.
- Flutter uses `https://` API and `wss://` WebSocket URLs.
- `REVERB_ALLOWED_ORIGINS` is restricted for web deployments.
- Reverb and queue workers are supervised.
- Migrations have been tested forward and backward in a safe environment.
- Staging smoke test has passed.
- Controlled load test has run or has explicit sign-off to defer.
- Backup and retention decisions are documented.
- Moderator operational workflow is staffed; web UI is tracked separately if required.

Current release gate: not ready until staging smoke testing, controlled load validation, and retention/governance decisions are completed.
