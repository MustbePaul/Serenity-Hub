# Serenity Circle Incident Response

This runbook covers operational incidents for Serenity Circle realtime messaging, moderation, privacy, and deployment safety. It intentionally contains no real secrets.

## Reverb Down

Detection:

- WebSocket connection failures increase.
- Clients enter reconnecting/fallback state.
- Reverb process is not running or health checks fail.

Immediate action:

- Confirm HTTP API remains healthy.
- Confirm queue worker and database status.
- Use platform process manager to restart Reverb.

Containment:

- Keep HTTP functionality available.
- Do not disable Circle unless HTTP paths are also unsafe.

Recovery:

- Confirm clients reconnect.
- Confirm HTTP reconciliation removes duplicates and fills missed messages.

Escalation:

- Escalate to operations if Reverb repeatedly exits or resource usage is high.

Evidence preservation:

- Preserve process logs, restart timestamps, deployment identifiers, and error rates.

## Queue Worker Down

Detection:

- Queue depth grows.
- Broadcast events stop reaching clients.
- Failed jobs increase.
- Queue worker process is not running.

Immediate action:

- Confirm message persistence still works through HTTP.
- Restart queue worker with the platform process manager.
- Inspect failed jobs.

Containment:

- Keep HTTP authoritative paths available.
- Avoid repeated manual retries until failure cause is understood.

Recovery:

- Process or retry safe failed jobs.
- Confirm broadcasts resume.
- Confirm no duplicate or corrupted message state.

Escalation:

- Escalate to engineering if jobs fail consistently after restart.

Evidence preservation:

- Preserve failed job payload metadata, exception traces, queue depth history, and restart records. Do not expose tokens or secrets in incident notes.

## Failed Broadcast Auth

Detection:

- Increased `403`, `401`, `422`, or `429` responses on `/api/v1/community/broadcasting/auth`.
- Clients cannot subscribe to private room channels.

Immediate action:

- Check whether bearer-token auth is working.
- Check malformed `socket_id` or channel names.
- Check room active state.
- Check throttling rates.

Containment:

- Fail closed. Do not loosen auth validation during an incident.

Recovery:

- Restore correct client configuration or backend env values.
- Confirm valid authenticated requests return only Pusher auth material.

Escalation:

- Escalate to security if attack traffic or token abuse is suspected.

Evidence preservation:

- Preserve aggregate auth error counts, request IDs, and timestamps. Do not preserve bearer tokens in plaintext.

## Database Failure

Detection:

- API health or platform database checks fail.
- Message, reaction, report, or moderation endpoints return database errors.

Immediate action:

- Stop deploys.
- Confirm database service status with the platform.
- Put operators on alert for degraded Circle functionality.

Containment:

- Do not run destructive migrations or manual repairs without backup confirmation.
- Preserve current database state.

Recovery:

- Restore service through platform procedures.
- If restore is required, restore to a safe environment first when possible.
- Verify Circle tables and recent records.

Escalation:

- Escalate to operations, database owner, and security if data loss or unauthorized access is possible.

Evidence preservation:

- Preserve database error logs, migration history, backup timestamps, and operator actions.

## Elevated Report Volume

Detection:

- Report queue grows sharply.
- Multiple reports target the same identity, room, or content pattern.

Immediate action:

- Assign moderators.
- Prioritize high-risk reasons such as self-harm concern, threat/violence, harassment, privacy/personal information, and abuse patterns.

Containment:

- Hide/remove clearly harmful content.
- Apply posting restrictions when justified by policy.

Recovery:

- Resolve/dismiss reports with concise internal notes.
- Review whether rate limits or product controls need adjustment.

Escalation:

- Escalate safeguarding concerns through approved internal channels.

Evidence preservation:

- Preserve report IDs, message IDs, moderator actions, and audit entries.

## Suspected Privacy Leak

Detection:

- WebSocket frames, HTTP responses, logs, screenshots, or reports indicate exposure of account identifiers, contact details, tokens, moderator notes, reporter identity, or internal mappings.

Immediate action:

- Stop the leaking path if confirmed.
- Capture evidence privately.
- Notify security and product owner.

Containment:

- Disable affected endpoint/event if necessary.
- Revoke exposed credentials if any token or secret leaked.

Recovery:

- Patch and test payloads.
- Inspect logs and frames to confirm sensitive fields are absent.

Escalation:

- Escalate to legal/privacy owner if user data exposure is plausible.

Evidence preservation:

- Preserve minimal necessary samples, timestamps, affected fields, and affected users. Store evidence in restricted locations only.

## Leaked Secret

Detection:

- Secret found in source, logs, client build, ticket, chat, screenshot, or public repository.

Immediate action:

- Treat as compromised.
- Remove exposure from the visible channel where possible.
- Rotate the affected secret using platform procedures.

Containment:

- Invalidate old secret.
- Review access logs for suspicious use.

Recovery:

- Deploy updated backend configuration.
- Confirm Flutter builds do not contain backend-only secrets.

Escalation:

- Escalate to security and operations.

Evidence preservation:

- Preserve where and when the secret appeared, who had access, and rotation timestamps. Do not paste the secret into incident notes.

Secret rotation readiness:

- Rotate `REVERB_APP_SECRET` in backend environment only.
- Restart/reload Laravel config and Reverb after rotation.
- Rotate Laravel application secrets and API credentials through the deployment platform or secret manager.
- Never place private keys, database credentials, or Reverb secrets in Flutter.

## Abusive Or Spam Surge

Detection:

- Post/reaction/report rate limits trigger heavily.
- Repeated messages or reports occur across rooms.
- Moderators observe coordinated abuse.

Immediate action:

- Review rate-limit and report signals.
- Apply posting restrictions to abusive identities where policy permits.

Containment:

- Keep affected rooms usable.
- Avoid broad shutdown unless moderation cannot keep users safe.

Recovery:

- Clear reports.
- Review rate-limit thresholds and abuse patterns.

Escalation:

- Escalate to trust/safety lead if abuse is coordinated or high volume.

Evidence preservation:

- Preserve message IDs, anonymous identity codes, action timestamps, and audit rows.

## Moderator Account Compromise

Detection:

- Unexpected moderation actions.
- Audit records show unusual activity.
- Moderator reports lost credentials or suspicious login.

Immediate action:

- Revoke moderator access.
- Invalidate sessions/tokens for the account.
- Freeze or review recent moderation actions.

Containment:

- Restrict moderation endpoints to known-good operators.
- Review whether any private report details or identity mappings were accessed.

Recovery:

- Restore incorrectly hidden/removed content if appropriate.
- Rotate affected credentials.

Escalation:

- Escalate to security, operations, and product owner.

Evidence preservation:

- Preserve audit logs, access logs, affected reports/messages, and account activity.

## High-Risk Safeguarding Concern

Detection:

- Reports or content indicate possible imminent harm to self or others.

Immediate action:

- Prioritize review.
- Follow the organization's approved safeguarding escalation process.
- Provide or preserve access to appropriate support resources according to policy.

Containment:

- Hide content only when needed for user/community safety or privacy.
- Do not publicly identify the user behind a pseudonym.

Recovery:

- Document actions taken in moderation audit/notes as allowed by policy.

Escalation:

- Escalate to trained safeguarding owner or designated emergency process.

Evidence preservation:

- Preserve relevant message/report IDs, timestamps, and moderator decisions with restricted access.

## Deployment Rollback

Detection:

- Release causes elevated errors, broken auth, broken realtime, privacy risk, failed migrations, or unusable Circle flows.

Immediate action:

- Stop further rollout.
- Identify affected version and migration state.
- Decide whether code rollback, config rollback, or process restart is safest.

Containment:

- Avoid destructive database rollback unless migration safety is proven and approved.
- Keep HTTP fallback available when possible.

Recovery:

- Roll back code/config through platform procedure.
- Restart queue workers and Reverb as needed.
- Run smoke tests after rollback.

Escalation:

- Escalate to engineering and operations release owner.

Evidence preservation:

- Preserve deployment IDs, logs, failed jobs, metrics, migration status, and operator actions.
