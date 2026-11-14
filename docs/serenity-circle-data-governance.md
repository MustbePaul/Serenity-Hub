# Serenity Circle Data Governance

This document identifies governance decisions required before Serenity Circle is released to production. It does not invent legal requirements or retention periods.

## Current Account Deletion Behavior

Current database migrations make `community_identities.user_id` cascade when a `users` row is deleted. That identity then cascades to messages, reactions, reports, blocks, and posting restrictions that depend on it. Moderation audit references use nullable foreign keys, so audit rows may remain after linked users, identities, messages, or reports are deleted.

This behavior may be too destructive for production moderation evidence, safety review, account-request handling, or incident investigations. Do not change it until product, legal, operations, and engineering agree on the production policy.

## Governance Decisions

| Issue | Current repository behavior / concern | Status | Owner |
| --- | --- | --- | --- |
| Message retention | Published messages persist until removed, soft-deleted, or cascaded through account/identity deletion. No approved retention period exists. | `DECISION REQUIRED` | To be assigned |
| Removed message retention | Author removals and moderator removals update status; message bodies may remain in the database unless later deleted by cascade. No approved retention period exists. | `DECISION REQUIRED` | To be assigned |
| Report retention | Reports persist unless cascaded through linked message/identity deletion. No approved retention period exists. | `DECISION REQUIRED` | To be assigned |
| Moderation evidence retention | Moderation notes, safety flags, reports, and audit rows can be needed for operational review. Retention period and access rules are undefined. | `DECISION REQUIRED` | To be assigned |
| Audit-log retention | `community_moderation_audits` persists with nullable links. Retention and immutable-log expectations are undefined. | `DECISION REQUIRED` | To be assigned |
| Account deletion behavior | Current cascades can remove Circle identities and associated community records. Product/legal/ops must choose delete, pseudonymize, retain as evidence, or retain minimum necessary fields. | `DECISION REQUIRED` | To be assigned |
| Community identity deletion/anonymization | Active identity maps a real account to a pseudonym internally. Whether deletion should remove, disable, rotate, or anonymize identities is undefined. | `DECISION REQUIRED` | To be assigned |
| Backup retention | Backups should include Circle tables, but backup retention duration and deletion propagation requirements are undefined. | `DECISION REQUIRED` | To be assigned |
| Moderator access | APIs require moderator authorization, but role assignment, review cadence, least-privilege boundaries, and revocation process are undefined. | `DECISION REQUIRED` | To be assigned |
| Authorized disclosure/escalation process | No approved policy defines when internal identity mapping may be escalated or disclosed to authorized parties. | `DECISION REQUIRED` | To be assigned |
| Data-subject/account requests | Request handling for Circle content, pseudonymous identities, moderation records, and backups is undefined. | `DECISION REQUIRED` | To be assigned |
| Incident response | Incident response runbook exists separately, but ownership, drills, and approval path must be assigned. | `DECISION REQUIRED` | To be assigned |

## Policy Options For Account Deletion

The organization must choose the intended behavior before production:

| Option | Description | Tradeoff |
| --- | --- | --- |
| Delete | Delete Circle identity and dependent content when the account is deleted. | Simple, but may destroy moderation evidence and community context. |
| Pseudonymize | Remove account mapping while preserving public pseudonymous content. | Preserves conversations, but needs careful removal of re-identification links. |
| Retain as moderation evidence | Keep selected records for safety, audit, or dispute handling. | Requires strict access controls and approved retention limits. |
| Retain minimum necessary fields | Keep only fields needed for legal/operational requirements. | Requires field-level policy and tested implementation. |

## Backup And Restore Expectations

Backups should capture the following tables in staging and production:

- `community_rooms`
- `community_identities`
- `community_messages`
- `community_reactions`
- `community_reports`
- `community_blocks`
- `community_posting_restrictions`
- `community_moderation_audits`

Restore steps, conceptually:

1. Restore to a safe non-production environment first.
2. Confirm schema version matches the application release.
3. Verify community rooms, identities, messages, reports, restrictions, and audit logs are present.
4. Confirm no production data is exposed to unauthorized operators.
5. Document restore time, data freshness, missing records, and any manual repair steps.

Do not use real production data for ad hoc testing.

## Required Production Decisions

Before public production launch, assign owners and record approved decisions for:

- Retention duration for ordinary messages.
- Retention duration for removed/hidden messages.
- Retention duration for reports and moderation evidence.
- Retention duration for moderation audits.
- Account deletion and anonymization behavior.
- Backup retention and deletion propagation expectations.
- Moderator access and review process.
- Escalation process for high-risk safeguarding concerns.
- Data-request handling for pseudonymous community content.
