# Serenity Circle Staging Release Gate

This document is the staging acceptance record for Serenity Circle. It is intentionally evidence-based: do not mark a control `PASS` unless it was actually validated in the named environment.

Valid statuses:

- `PASS`
- `FAIL`
- `BLOCKED`
- `NOT TESTED`

Current gate date: 2026-09-12

Current release assessment: `NOT READY`

## Staging Environment Status

No real staging environment access, staging accounts, staging process manager, staging logs, staging database, or staging WebSocket endpoint were available during this repository pass.

Safe local review and automated verification can be completed from the repository. Real WebSocket smoke testing, outage testing, process supervision proof, load validation, backup restore proof, and socket-frame inspection remain blocked until operators provide an approved staging environment.

## Staging Configuration Requirements

Backend required settings:

| Setting | Required staging value | Status | Evidence |
| --- | --- | --- | --- |
| `APP_ENV` | `staging` or platform equivalent, not `local` | `BLOCKED` | Real staging env not available. |
| `APP_URL` | Public HTTPS API origin | `BLOCKED` | Real staging env not available. |
| `BROADCAST_CONNECTION` | `reverb` | `BLOCKED` | `backend/.env.example` defaults to local/log only. |
| `QUEUE_CONNECTION` | Durable async driver approved for staging, for example `database`, `redis`, or managed queue | `BLOCKED` | Repository supports `database`; real staging value not available. |
| `REVERB_APP_ID` | Backend-only app id | `BLOCKED` | Real staging env not available. |
| `REVERB_APP_KEY` | Public Reverb app key; may be shipped to Flutter | `BLOCKED` | Real staging env not available. |
| `REVERB_APP_SECRET` | Backend-only secret | `BLOCKED` | Code reads it only from backend config. |
| `REVERB_HOST` | Externally reachable realtime host | `BLOCKED` | Real staging env not available. |
| `REVERB_PORT` | `443` for externally exposed TLS traffic | `BLOCKED` | Production-readiness doc requires this. |
| `REVERB_SCHEME` | `https` for external Reverb traffic | `BLOCKED` | Production-readiness doc requires WSS/HTTPS. |
| `REVERB_ALLOWED_ORIGINS` | Comma-separated trusted web origins, not broad wildcard for browser clients | `BLOCKED` | `backend/.env.example` uses local wildcard only. |

Flutter required settings:

| Setting | Required staging value | Status | Evidence |
| --- | --- | --- | --- |
| API base URL | HTTPS `/api/v1` staging URL | `BLOCKED` | Must be supplied via build configuration. |
| realtime host | WSS staging WebSocket URL | `BLOCKED` | `CommunityRealtimeService` supports `COMMUNITY_WS_URL`. |
| realtime port | TLS endpoint, normally `443` through URL | `BLOCKED` | Real staging build not available. |
| realtime scheme | `wss://` externally | `BLOCKED` | Local default is `ws://10.0.2.2:8080`; release build must override. |
| public Reverb app key | Public key only | `BLOCKED` | `CommunityRealtimeService` supports `COMMUNITY_WS_APP_KEY`. |

Configuration findings:

- Secret values remain backend-only in current source structure.
- Flutter secret scan on 2026-09-12 found no `REVERB_APP_SECRET` usage.
- Flutter secret scan on 2026-09-12 found no database credential usage.
- Flutter config scan on 2026-09-12 found only public/runtime build defines: `API_BASE_URL`, `COMMUNITY_WS_URL`, and `COMMUNITY_WS_APP_KEY`.
- WSS cannot be confirmed without inspecting the actual staging build/runtime defines.
- Public configuration is separated from private configuration by Dart defines and Laravel env values.
- Do not insert real credentials into repository files.

Flutter forbidden values:

| Forbidden value | Status | Evidence |
| --- | --- | --- |
| `REVERB_APP_SECRET` | `PASS` | `rg` scan of `mobile` on 2026-09-12 found no match. |
| Database credentials | `PASS` | `rg` scan of `mobile` on 2026-09-12 found no database credential values or config keys beyond public API/realtime defines. |
| Private backend keys | `PASS` | `rg` scan of `mobile` on 2026-09-12 found only public `API_BASE_URL`, `COMMUNITY_WS_URL`, and `COMMUNITY_WS_APP_KEY` configuration. |

## Process Supervision Requirements

Serenity Circle requires these long-running processes in staging:

| Process | Required? | Status | Evidence |
| --- | --- | --- | --- |
| Web/API process | Yes | `BLOCKED` | Platform process list not available. |
| Reverb process | Yes | `BLOCKED` | Must run `php artisan reverb:start` or platform equivalent under supervision. |
| Queue worker | Yes | `BLOCKED` | Broadcast events implement `ShouldBroadcast`; queued broadcasts need a worker. |
| Scheduler | Conditional | `NOT TESTED` | No Circle-specific scheduler job found; use if project/platform already runs scheduled jobs. |

Supervision checks:

| Check | Status | Evidence |
| --- | --- | --- |
| Reverb survives terminal/session exit | `BLOCKED` | Requires staging process manager access. |
| Queue worker survives terminal/session exit | `BLOCKED` | Requires staging process manager access. |
| Processes restart after failure | `BLOCKED` | Requires staging process manager access. |
| Processes start after reboot | `BLOCKED` | Requires staging process manager access. |
| Logs are available | `BLOCKED` | Requires staging log access. |
| Restart strategy is controlled | `BLOCKED` | Requires platform runbook/process config. |
| Failed processes can be detected | `BLOCKED` | Requires monitoring/process manager evidence. |

Use the deployment platform's native process architecture. Do not add another process manager unless the platform lacks a supported supervision mechanism.

## Queue Validation Plan

Because `CommunityMessageCreated`, `CommunityMessageRemoved`, and `CommunityReactionUpdated` implement `ShouldBroadcast`, staging must prove that queue behavior matches the HTTP-authoritative design.

Required test sequence:

1. Create message over HTTP.
2. Confirm database transaction succeeds.
3. Confirm broadcast queue job is created and processed.
4. Confirm broadcast is emitted.
5. Confirm receiving client gets event.

Failure behavior to validate:

| Condition | Expected behavior | Status |
| --- | --- | --- |
| Queue worker stopped | Message persists and HTTP response remains correct | `BLOCKED` |
| Queue worker stopped | Realtime delivery is delayed or missed, not corrupting authoritative state | `BLOCKED` |
| Queue worker restarted | Queued broadcasts recover or failures are visible | `BLOCKED` |
| Failed jobs inspected | Failed broadcast jobs are visible and actionable | `BLOCKED` |

## Staging Acceptance Checklist

| Check | Status | Evidence / next action |
| --- | --- | --- |
| API availability | `BLOCKED` | Hit `/api/health` and `/up` in staging. |
| Authentication | `BLOCKED` | Login/register and bearer-token protected route required in staging. |
| WebSocket connectivity | `BLOCKED` | Requires staging Reverb endpoint and client. |
| Private-channel authorization | `BLOCKED` | Test `/api/v1/community/broadcasting/auth` with valid and invalid requests. |
| Realtime message delivery | `BLOCKED` | Requires two-account smoke test. |
| Realtime reaction updates | `BLOCKED` | Requires two-account smoke test. |
| Realtime removal events | `BLOCKED` | Requires two-account smoke test. |
| Room isolation | `BLOCKED` | Requires two accounts in different rooms. |
| Reconnect recovery | `BLOCKED` | Requires client/network interruption test. |
| HTTP fallback | `BLOCKED` | Requires Reverb outage/reconnect test. |
| Queue processing | `BLOCKED` | Requires staging queue visibility. |
| Blocking behavior | `BLOCKED` | Requires two-account block test. |
| Moderation behavior | `BLOCKED` | Requires moderator account/API in staging. |
| Privacy of payloads | `BLOCKED` | Requires WebSocket frame inspection. |
| Process stability | `BLOCKED` | Requires process manager and logs. |
| Database stability | `BLOCKED` | Requires staging database observation. |
| Acceptable latency | `BLOCKED` | Requires smoke and load measurements. |
| Operational monitoring | `BLOCKED` | Requires platform monitoring evidence. |

## Two-Account WebSocket Smoke Test

Use only staging accounts and staging data.

### Test 1: Message Delivery

Account A and Account B enter World Room. B posts: `Realtime staging test message`.

Expected:

- B gets a normal HTTP response.
- B does not receive a duplicate message.
- A receives the message through realtime.
- No manual refresh is needed.

Result: `BLOCKED`

Approximate delivery delay: unavailable.

### Test 2: Reaction Delivery

A reacts to B's message.

Expected:

- Aggregate reaction count updates for B.
- A retains correct local `my_reactions`.
- Identity of reactor is not disclosed.

Result: `BLOCKED`

### Test 3: Delete

B removes their own message.

Expected:

- Message disappears from A.
- Message disappears from B.
- No moderation/private metadata is exposed.

Result: `BLOCKED`

## Room Isolation Test

Required staging test:

- A in World Room.
- B in Stress & Anxiety.
- B posts a message.
- A must not receive it.
- Reverse the test.
- Inspect each received event `room.slug`.

Code review evidence:

- Broadcast channel format is `private-community.room.{roomSlug}`.
- Flutter ignores events whose `roomSlug` does not match `selectedRoom.slug`.
- Stable message IDs prevent duplicate inserts.

Result: `BLOCKED` until observed in staging.

## Reconnect Test

Required staging test:

- A and B enter same room.
- Disconnect A's network.
- B posts multiple messages.
- Wait for reconnect/fallback state.
- Reconnect A.

Expected:

- Conversation remains visible.
- App does not crash.
- Polling/fallback activates during reconnect/fallback.
- HTTP reconciliation occurs after realtime recovery.
- Missed messages appear with no duplicates.
- Polling stops after realtime becomes healthy.

Code review evidence:

- `CommunityProvider` starts polling during reconnect/fallback.
- On connected status, provider stops polling and silently reloads messages.
- Message merging is by stable `id`.

Result: `BLOCKED` until observed in staging.

## Reverb Outage Test

Required staging/local infrastructure test:

- Stop Reverb.
- Confirm HTTP room history, sends, pagination, and reactions still work.
- Confirm provider enters reconnecting/fallback behavior without blocking full-screen realtime error.
- Restart Reverb.
- Confirm reconciliation and realtime recovery without duplicates.

Result: `BLOCKED`

## Queue Outage Test

Required staging/local infrastructure test:

- Stop queue worker.
- Post messages.
- Confirm persistence succeeds and HTTP response remains authoritative.
- Confirm realtime behavior reflects queue unavailability.
- Restart worker.
- Inspect queued jobs, delayed broadcasts, failed jobs, and duplicates.

Result: `BLOCKED`

## App Lifecycle Validation

Required client test:

- Open room, background app, wait, resume app.
- Repeat room navigation across World Room, Stress & Anxiety, and Relationships.

Expected:

- No stale duplicate subscriptions.
- Current room reconnects correctly.
- State reconciles if necessary.
- Only active room events affect visible state.
- Duplicate socket listeners do not accumulate.

Code review evidence:

- `leaveRoom` cancels realtime subscriptions and unsubscribes.
- `handleAppBackgrounded` stops polling and unsubscribes.
- `handleAppResumed` reloads and re-subscribes.

Result: `BLOCKED` until device lifecycle test is run.

## Blocking And Realtime

Expected behavior:

- When A blocks B's anonymous Circle identity, B's existing content disappears from A.
- New realtime events from B must not display for A.
- Backend HTTP filtering must also exclude blocked identities.

Code review evidence:

- Backend `visibleMessagesQuery` excludes blocked identities.
- Backend `canSeeMessage` prevents access to blocked messages.
- Flutter tracks blocked anonymous identity IDs and filters realtime-created messages.

Result: `BLOCKED` until two-account staging test is run.

## Moderation Realtime Test

Required staging test:

1. Create a test community message.
2. Hide/remove it using an authorized moderator account/API.
3. Confirm ordinary connected clients stop seeing it.
4. Confirm broadcast does not expose moderator identity, reporter identity, report reason, moderator notes, or internal user mapping.
5. Restore if supported and verify state behavior.

Code review evidence:

- Hide/remove dispatches `CommunityMessageRemoved`.
- Restore returns API state but does not currently emit a created/restored event; clients will observe restore through HTTP reconciliation, not realtime restoration.

Result: `BLOCKED`

## Posting Restriction Test

Required staging test:

- Apply temporary Circle posting restriction.
- Attempt to post.
- Confirm neutral denial and no internal reason exposure.
- Verify support contacts, therapist discovery, resources, and other non-Circle functionality remain available.
- Remove restriction and verify posting works.

Code review evidence:

- Restriction check is scoped to posting/replies.
- Response says the user cannot post right now and optionally gives an expiry; it does not expose the moderator reason.

Result: `BLOCKED`

## Socket Frame Privacy Inspection

Inspect actual staging WebSocket traffic and search for:

`user_id`, `email`, `phone`, real name, profile photo, `Authorization`, access token, refresh token, `moderator_notes`, report details, reporter identity, IP information, device identifiers, and `REVERB_APP_SECRET`.

Allowed:

- Public pseudonymous identity information.
- Public message ID.
- Room identifier/slug.
- Public message body.
- Public timestamps.
- Public reaction aggregates.

Code review evidence:

- Broadcast payloads are built through `CommunityMessagePayload::forBroadcast`, which omits viewer-specific `my_reactions` and account identifiers.
- Reaction broadcasts send aggregate reaction counts only.
- Removal broadcasts send message id and room slug.

Result: `BLOCKED` until actual frames are inspected.

## Broadcast Auth Attack Tests

Required staging tests:

| Case | Expected | Status |
| --- | --- | --- |
| Missing token | Fail closed | `BLOCKED` |
| Invalid token | Fail closed | `BLOCKED` |
| Malformed `socket_id` | Fail closed | `BLOCKED` |
| Malformed channel | Fail closed | `BLOCKED` |
| Unknown room | Fail closed | `BLOCKED` |
| Inactive room | Fail closed | `BLOCKED` |
| Valid authenticated request | Return required Pusher auth material only | `BLOCKED` |
| Excessive repeated auth requests | Throttled | `BLOCKED` |

Code review evidence:

- Route is behind `api.token`.
- Route has `throttle:community-broadcast-auth`.
- `socket_id` must match `^\d+\.\d+$`.
- Channel must start with `private-community.room.` and contain a slug matching `^[a-z0-9]+(?:-[a-z0-9]+)*$`.
- Unknown/inactive rooms fail closed.

## Controlled Load Validation

Run only against approved staging/local infrastructure.

Initial scenarios:

| Scenario | Concurrency | Status |
| --- | --- | --- |
| A | 25 concurrent room connections | `BLOCKED` |
| B | 50 concurrent room connections | `BLOCKED` |
| C | 100 concurrent room connections | `BLOCKED` |

Measure:

- Connection success rate.
- WebSocket handshake failures.
- Auth failures.
- Message broadcast latency.
- Queue latency.
- Failed queue jobs.
- Reverb CPU and memory.
- Laravel CPU.
- Database load.
- Connection stability.
- Reconnect behavior.

Do not increase concurrency beyond what staging is designed to handle.

## Load Test Acceptance

No arbitrary enterprise-scale threshold is defined. Acceptance must be based on intended initial launch volume and measured staging behavior.

Flag any of:

- Connection instability.
- Memory growth.
- Queue backlog.
- High broadcast delay.
- DB query pressure.
- Excessive CPU.
- Repeated reconnect storms.
- Failed jobs.

Result: `BLOCKED`

## Database Observation

Required staging observation:

- Message query performance.
- Reply query performance.
- Report queue query performance.
- Reaction aggregation.
- Blocked-user queries.
- Restriction lookup.

Code review evidence:

- Existing indexes cover room/status/time, parent/status/time, room/status/id, identity/status, report status/time, reactions by identity/message, and block lookup by blocked identity.
- No index change is justified without staging query plans or slow-query evidence.

Result: `BLOCKED`

## Failed Job Monitoring

Required staging evidence:

- How failed jobs are listed.
- Where failures are logged.
- Restart/retry procedure.
- Escalation expectation.

Recommended Laravel commands, subject to project/platform conventions:

```bash
php artisan queue:failed
php artisan queue:retry <job-id>
php artisan queue:forget <job-id>
php artisan queue:restart
```

Result: `BLOCKED`

## Health Check Validation

Available health endpoints:

- `/api/health` returns minimal service status.
- Laravel `/up` is available through the framework route.

Public health checks must not expose private topology or secrets.

Required operator checks:

- API responding.
- Database reachable through protected/internal diagnostic or platform health check.
- Reverb running.
- Queue worker running.
- Failed job state.

Result: `BLOCKED` for real staging; repository route review complete.

## Backup Validation

Relevant tables:

- `community_rooms`
- `community_identities`
- `community_messages`
- `community_reactions`
- `community_reports`
- `community_blocks`
- `community_posting_restrictions`
- `community_moderation_audits`

Required proof:

- Backup captures the tables above in staging.
- Restore procedure can restore to a safe non-production environment.
- Restore includes moderation evidence and pseudonymous identities according to approved governance policy.

Result: `BLOCKED`

## Account Deletion Design Review

Current migration behavior:

- `community_identities.user_id` uses `cascadeOnDelete`.
- `community_messages.community_identity_id` uses `cascadeOnDelete`.
- `community_reactions.community_identity_id` uses `cascadeOnDelete`.
- `community_reports` reporter/reported identity references use `cascadeOnDelete`.
- `community_blocks` identity references use `cascadeOnDelete`.
- `community_posting_restrictions.community_identity_id` uses `cascadeOnDelete`.
- `community_moderation_audits` references are nullable and use `nullOnDelete`.

Implication:

- Deleting a user can remove the active community identity and cascade to Circle messages, reactions, reports, blocks, and restrictions tied to that identity.
- Audit rows may remain but lose the linked identity/message/report references.

Production policy decision required:

- Delete.
- Pseudonymize.
- Retain as moderation evidence.
- Retain only legally/operationally necessary fields.

Do not implement destructive account-deletion changes until product/legal/operations define the required policy.

Status: `DECISION REQUIRED`

## Moderator UI Launch Recommendation

Recommendation: `OPTION B - Limited pilot can operate temporarily using protected moderator APIs/internal tooling`, with conditions.

Conditions:

- Pilot volume is small and invite-only.
- Operators are technically able to use protected internal API tooling safely.
- Response-time expectations are explicitly lower than public launch expectations.
- Report and high-risk safeguarding workflows are staffed and documented.
- Moderator API access is restricted, logged, and revocable.
- A compatible moderator UI is required before broad public availability.

Reasoning:

- Moderator APIs exist, but APIs alone are not operationally sufficient for public availability.
- A UI reduces operator error, improves queue visibility, and supports consistent response times.
- Safeguarding requirements may force `OPTION A` if expected volume or response expectations are high.

## Release Evidence Table

| Control | Status | Evidence | Blocker? | Owner / next action |
| --- | --- | --- | --- | --- |
| Composer security | `PASS` | `composer audit`: No security vulnerability advisories found. | No | Engineering: keep audit in release checklist. |
| Backend tests | `PASS` | `composer test`: passed, 43 tests, 208 assertions. | No | Engineering: keep suite green. |
| Flutter analysis | `PASS` | `flutter analyze`: No issues found. | No | Engineering: keep analyzer clean. |
| Flutter tests | `PASS` | `flutter test`: passed, 35 tests. | No | Engineering: keep suite green. |
| Migration safety | `PASS` | 2026-09-12 local testing DB: `php artisan migrate:fresh --env=testing` passed all migrations; `php artisan migrate:rollback --env=testing --step=1` rolled back `2026_09_12_000001_add_community_realtime_moderation_tables`; `php artisan migrate --env=testing` re-applied it successfully. | No | Engineering/Ops: repeat against approved staging deploy workflow before production release. |
| Broadcast auth | `BLOCKED` | Code review positive; staging attack tests pending. | Yes | Engineering/Ops: run attack test set. |
| Channel isolation | `BLOCKED` | Code review positive; room isolation smoke pending. | Yes | QA: two-account staging test. |
| Realtime delivery | `BLOCKED` | Requires staging WebSocket smoke. | Yes | QA/Ops. |
| Reconnect | `BLOCKED` | Requires network interruption test. | Yes | QA. |
| HTTP fallback | `BLOCKED` | Requires Reverb outage test. | Yes | QA/Ops. |
| Queue supervision | `BLOCKED` | Requires process manager evidence. | Yes | Ops. |
| Reverb supervision | `BLOCKED` | Requires process manager evidence. | Yes | Ops. |
| WSS/TLS | `BLOCKED` | Requires deployed staging endpoint/build config. | Yes | Ops. |
| Allowed origins | `BLOCKED` | Requires staging env review. | Yes | Ops. |
| Blocking | `BLOCKED` | Code review positive; two-account test pending. | Yes | QA. |
| Moderation | `BLOCKED` | APIs exist; staging moderation test pending. | Yes | Trust/safety + QA. |
| Posting restrictions | `BLOCKED` | Code review positive; staging test pending. | Yes | Trust/safety + QA. |
| Privacy payload review | `BLOCKED` | Code review positive; frame inspection pending. | Yes | Security. |
| Load validation | `BLOCKED` | No staging load test run. | Yes | Engineering/Ops. |
| Health monitoring | `BLOCKED` | Minimal routes exist; monitoring not proven. | Yes | Ops. |
| Backup | `BLOCKED` | Tables identified; backup/restore not proven. | Yes | Ops. |
| Retention policy | `BLOCKED` | Governance document requires decisions. | Yes | Product/legal/ops. |
| Account deletion policy | `BLOCKED` | Current cascade behavior requires review. | Yes | Product/legal/engineering. |
| Moderator operations | `NOT TESTED` | Operations document created separately. | Yes | Trust/safety. |
| Incident response | `NOT TESTED` | Runbook created separately. | Yes | Ops/security. |

## Final Security Scan

Scan command:

```bash
rg -n "REVERB_APP_SECRET|Authorization|user_id|email|phone|profile_photo|moderator_notes|reporter|token|Log::|logger\(|dump\(|dd\(" backend mobile docs README.md
```

Classification:

| Result class | Findings | Classification |
| --- | --- | --- |
| Reverb secret references | Backend `.env.example`, backend config/docs, incident-response rotation text. No Flutter `REVERB_APP_SECRET` usage found. | `EXPECTED CONFIG` |
| Authorization/token references | Normal bearer-token auth middleware, API client header injection, login/register token handling, README/docs/tests. | `SAFE INTERNAL` |
| Account/profile fields | Normal auth/profile, therapist, support, appointment, and non-Circle app functionality. | `SAFE INTERNAL` |
| Circle internal identity fields | `community_identities.user_id` and moderation audit `actor_user_id` are backend internals. Broadcast/client payload builders continue to use pseudonymous identity payloads. | `SAFE INTERNAL` |
| Moderator fields | `moderator_notes`, reporter/reported identities appear in protected moderation API payloads and docs, not ordinary room broadcasts. | `SAFE INTERNAL` |
| Debug logging/dumps | No `Log::`, `logger(`, `dump(`, or `dd(` debug call risk was identified in backend app/routes or mobile lib. Plain `.add(` method calls were false positives from the broad regex. | `SAFE INTERNAL` |
| Flutter private config | Search of Flutter app folders found only `COMMUNITY_WS_APP_KEY`; no `REVERB_APP_SECRET`, database credential, password, or private secret usage. | `SAFE INTERNAL` |

No `PRIVACY RISK` or `SECRET EXPOSURE` finding was identified in this repository scan. Actual staging WebSocket frames still require inspection before production.

## Final Automated Verification

| Command | Result |
| --- | --- |
| `composer audit` | `PASS`: No security vulnerability advisories found. |
| `composer test` | `PASS`: 43 tests, 208 assertions. |
| `flutter analyze` | `PASS`: No issues found. |
| `flutter test` | `PASS`: 35 tests, all passed. |

## Final Release Decision

`NOT READY`

Reason:

- Core realtime behavior has not been validated in a realistic staging environment.
- Load validation has not been run.
- WSS/TLS, Reverb supervision, queue supervision, failed-job monitoring, backup restore, retention policy, and account-deletion policy remain unproven or undecided.
- Automated tests are necessary but not sufficient for production readiness.
