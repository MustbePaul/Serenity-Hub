# Serenity Circle Moderation Operations

This document describes how Serenity Circle moderation should be operated with the current protected APIs. It does not replace a purpose-built moderator UI for public launch.

## Authorization Requirements

- Moderator routes are under `/api/v1/community/moderation`.
- Requests require normal bearer-token authentication.
- Requests also require the `community.moderator` middleware.
- Moderator access must be granted only to trained, authorized operators.
- Access must be revocable and periodically reviewed.

Moderators must not publicly reveal the Serenity Hub account behind a pseudonym.

## Report Statuses

Current report status transitions accepted by the API:

- `reviewing`
- `resolved`
- `dismissed`

Operational meaning must be defined by the organization. A suggested interpretation:

- `reviewing`: a moderator has taken responsibility for review.
- `resolved`: action was taken or the matter was otherwise completed.
- `dismissed`: the report did not require moderation action.

## Message Actions

Available message actions:

- Hide message.
- Restore message.
- Remove message.

Expected operational behavior:

- Hide/remove should stop ordinary users from seeing the message.
- Hide/remove emits a removal-style realtime event so connected clients remove it.
- Restore is available by API; clients may need HTTP reconciliation to observe restored content.
- Moderator notes are internal only and must not be exposed in ordinary client payloads.

## Report Resolution

When resolving or dismissing a report:

- Use neutral, factual moderator notes.
- Do not include unnecessary account details.
- Do not include medical judgments.
- Preserve relevant evidence according to the approved governance policy.

## Posting Restrictions

Available restriction actions:

- Apply temporary posting restriction.
- Apply indefinite posting restriction.
- Remove active posting restriction.

Restrictions should affect Serenity Circle posting only unless a separate policy decision authorizes broader account action. Other Serenity Hub features such as resources, support contacts, therapist discovery, and non-Circle functionality should remain accessible unless there is an independent safety or abuse reason.

User-facing denial text should remain neutral and should not reveal internal moderation reasoning.

## Audit Behavior

The API writes moderation audit records for:

- Report status updates.
- Message hide/restore/remove actions.
- Posting restriction application/removal.

Audit records include internal references and metadata. They must be access restricted and retained according to approved governance policy.

## Safety Classification Interpretation

Safety flags are not medical diagnoses.

Safety flags are triage signals that can help moderators prioritize review. They must not be presented as clinical conclusions, and they must not be used as the sole basis for punitive action without human review.

## Privacy Restrictions

Moderators must:

- Treat pseudonym-to-account mapping as sensitive internal information.
- Avoid copying report details, moderator notes, account identifiers, or identity mappings into public channels.
- Avoid exposing reporter identity to reported users.
- Avoid exposing moderator identity in ordinary community payloads.
- Use approved escalation channels for high-risk concerns.

## Escalation Principles

Escalate when:

- Content suggests imminent self-harm or harm to others.
- Personal contact information or private details are exposed.
- Abuse, spam, or harassment is coordinated.
- A moderator account may be compromised.
- A privacy leak or secret exposure is suspected.

Escalation should preserve evidence, minimize access to sensitive data, and follow the incident-response runbook.

## Moderator UI Launch Decision

Recommendation: `OPTION B - Limited pilot can operate temporarily using protected moderator APIs/internal tooling`.

Conditions:

- Pilot is small and controlled.
- Operators are comfortable with protected API tooling.
- Response-time expectations are explicit and achievable.
- A named moderator owner is assigned.
- Report queues and audit logs are monitored.
- A compatible moderator UI is required before broad public availability.

For public availability, prefer `OPTION A`: launch requires a moderator UI before public release. Public use increases report volume, operational urgency, and the cost of operator mistakes.
