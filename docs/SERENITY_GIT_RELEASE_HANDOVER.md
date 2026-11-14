# Serenity Hub Git release handover

## Starting state and preservation

Repository: `https://github.com/MustbePaul/Serenity-Hub.git`, verified against GitHub's `MustbePaul/Serenity-Hub` repository. The default branch was `main` at `437b390` and no other remote branches existed. The working tree was on `main` with an unstaged, substantial restructure: tracked `backend/` and `mobile/` appeared deleted while their moved `services/api/` and `apps/mobile/` files, React `apps/web/`, infrastructure, CI, and documents were untracked. There was no merge, rebase, or cherry-pick in progress and no staged work. Git identified most moved files as renames after staging.

The pre-existing ignored `.recovery/before-react-*` snapshot remains local. A second Git checkpoint, `backup/serenity-pre-integration-20261113`, contains the complete reviewed combined change at `c214afc`. The branch is pushed and tracks `origin/backup/serenity-pre-integration-20261113`. Ignored local `.env` files, SQLite databases, dependencies, build output and Android CMake reports were excluded. A staged filename scan and sensitive-string scan found no private key, token or committed local database. The `local-serenity-secret` value in `services/api/.env.example` is a development-only placeholder, not a staging secret. No legitimate untracked files remained after the checkpoint commit.

## Branch layout and commits

| Branch | Remote tip at handover preparation | Purpose |
| --- | --- | --- |
| `main` | `437b390` | Existing stable baseline; **not updated** |
| `backup/serenity-pre-integration-20261113` | `c214afc` | Complete recovery checkpoint |
| `develop` | `75b0219` before this handover document | Combined integration, CI correction and handover |
| `feature/web` | `c214afc` | Ready-to-use branch; no separate web commit was fabricated |
| `feature/mobile` | `c214afc` | Ready-to-use branch; no separate mobile commit was fabricated |
| `feature/api` | `c214afc` | Ready-to-use branch; no separate API commit was fabricated |

All listed branches track their same-named `origin/*` branch. The combined restructure was kept as one integration commit because React browser authentication, Laravel session support, moved paths, and documentation depend on each other. The component branches were created from that shared base for subsequent isolated work; they are not presented as separate feature histories.

Commits created: `c214afc refactor(repo): preserve integrated Serenity Hub trial restructure` and `75b0219 chore(ci): align PHP and Flutter validation toolchains`. This handover document is committed separately on `develop`; use `git log -3 --oneline` for its final hash.

## Validation actually run

| Command or check | Result |
| --- | --- |
| `git diff --cached --check` before checkpoint and `git diff --check` after | PASS |
| Staged filename and sensitive-string checks | PASS with only documented development `.env.example` placeholder |
| `npm ci --no-audit --no-fund` in the active checkout | **BLOCKED** by Windows `EPERM` on a native module held by an existing Vite process |
| `npm ci --no-audit --no-fund` in detached `.recovery/validation` worktree at `c214afc` | PASS, 266 packages installed |
| `npm run typecheck`, `npm run lint`, `npm test`, `npm run build` in clean validation worktree | PASS; 10 web tests and production build |
| `npm run smoke` in clean validation worktree | PASS, 21 Chrome checks at desktop, tablet and mobile sizes |
| `npm audit --omit=dev --audit-level=high` | PASS, zero production dependency vulnerabilities reported |
| `composer install --no-interaction --prefer-dist --no-progress` and `composer validate --no-check-publish` | PASS on local PHP 8.5.2 |
| `php artisan test` | PASS, 46 tests and 219 assertions |
| `php artisan route:list --path=api` | PASS, 53 routes; an earlier attempt with unsupported `--compact` option failed and was rerun correctly |
| `php artisan migrate:status` | PASS, nine applied migrations on the existing local development DB; no migration was run against production |
| `flutter pub get`, `flutter analyze`, `flutter analyze --no-fatal-infos`, `flutter test` | PASS; 35 Flutter tests |
| `flutter build apk --debug --dart-define=TRIAL_MODE=staging --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1` | PASS; compilation only, emulator runtime **NOT VERIFIED** |

The prior web-trial report records eight browser workflows against an isolated local Laravel staging database. They were not rerun during this Git release pass. External staging, live WSS/Reverb, two-user isolation in a deployed environment, real therapist verification, media licensing/playback and moderation operations remain **NOT VERIFIED**.

## GitHub Actions and main gate

The first GitHub `component checks` run for `c214afc` failed: web passed, API could not install its locked Symfony 8 packages on CI PHP 8.3, and Flutter analysis treated new SDK-wide `material.dart` deprecation infos as fatal. Commit `75b0219` changed CI to PHP 8.5 and `flutter analyze --no-fatal-infos`; errors and warnings remain fatal. [GitHub Actions run 43567944258](https://github.com/MustbePaul/Serenity-Hub/actions/runs/43567944258) completed successfully for `75b0219`: web, API and Flutter jobs all passed. The handover-only commit should receive its own CI run after push; verify that run separately.

**MAIN NOT UPDATED.** The external staging, care, crisis-support, moderation, privacy and retention gates remain unresolved. GitHub returned `Branch not protected` for the main protection endpoint; that absence is not approval to merge. A draft `develop` to `main` pull request may be used to track the release candidate, but it must not be merged or deployed until the checks and governance gates are independently confirmed.

## Resume in a fresh Codex session

1. From the repository root, run `git status --branch`, `git fetch origin --prune`, `git branch -a -vv`, and `git log --oneline --decorate -5`. Confirm `develop` and its upstream before editing.
2. Run `gh run list --repo MustbePaul/Serenity-Hub --branch develop --limit 5` and inspect the newest run's web, API and Flutter jobs. Resolve any failure on a new branch from `develop`; preserve the pushed checkpoint.
3. Review the draft `develop` to `main` PR and its required checks. Keep `main` at `437b390` until all release gates are evidenced.
4. For component work, branch from current `develop` or advance the corresponding `feature/*` branch by normal merge. Do not assume the ready-to-use feature branches contain unique component commits.
5. Use `docs/testing/SERENITY_WEB_TRIAL_RESULTS.md` and `docs/SERENITY_WEB_TRIAL_DEPLOYMENT.md` for test and staging gates. No public deployment was performed in this release pass.
