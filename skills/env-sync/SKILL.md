---
name: env-sync
description: Compare and sync environment variables between local .env.local and Vercel (production/preview). Repo-agnostic. Use when adding new env vars, rotating keys, onboarding a fresh laptop, or just checking "is my local in sync with prod?". Works in any Vercel-linked repo (single-repo or monorepo).
trigger: /env-sync, "diff env vars", "push env to vercel", "pull env from vercel", "sync env", "what env vars am I missing"
---

# env-sync — Environment Variable Sync Tool

Bidirectional `.env.local` ↔ Vercel env var management. **Neither side is canonical** — you decide per-var which is the source of truth.

## When to use

- Added a new env var locally and need it on Vercel for deploys
- Rotated a key and want to push the new value
- Cloned a repo on a new laptop and need missing local values
- Suspect drift ("did I update Vercel last time?") — run `diff` to check
- About to deploy and want to confirm prod has everything

## Setup (one-time per repo)

The repo must be Vercel-linked first:

```bash
cd <repo>
npx vercel link        # interactive — pick the project
```

After linking you'll have `.vercel/project.json`. Then env-sync works.

## Commands

All commands run via the script at `~/.claude/skills/env-sync/env-sync.sh`. The skill auto-detects:
- **Layout**: single-repo (`.env.local` next to `.vercel/`) or monorepo (`apps/web/.env.local` with `.vercel/` at repo root)
- **Project**: read from `.vercel/project.json`

Default environment is `production`. Pass `--env preview` to compare against preview env vars.

### `env-sync diff` (default)
Shows three groups:
- **🔼 Local only** — vars in `.env.local` missing from Vercel
- **🔽 Vercel only** — vars on Vercel missing from `.env.local`
- **⚠️ Value differs** — same name, different value (masked output)

```bash
~/.claude/skills/env-sync/env-sync.sh diff
~/.claude/skills/env-sync/env-sync.sh diff --env preview
```

### `env-sync push <VAR_NAME>`
Push one var from `.env.local` → Vercel. Replaces existing value if any. Warns before pushing test-shaped keys (`sk_test_*`, `pk_test_*`) to production.

```bash
~/.claude/skills/env-sync/env-sync.sh push LINEAR_WEBHOOK_SECRET
```

### `env-sync push-all-missing`
Push every var that exists locally but is missing from Vercel. Confirms before each batch. Does NOT touch vars that already exist on Vercel (won't override).

```bash
~/.claude/skills/env-sync/env-sync.sh push-all-missing
```

### `env-sync pull-missing`
Append every var that exists on Vercel but is missing from `.env.local`. Marks live keys (`sk_live_*`) with a comment so you know to swap them for test values before running dev. Does NOT touch existing local vars.

```bash
~/.claude/skills/env-sync/env-sync.sh pull-missing
```

### `env-sync pull`
Just pull Vercel env to `.env.vercel.<env>.local` for manual inspection. Does not modify `.env.local`.

```bash
~/.claude/skills/env-sync/env-sync.sh pull
```

## How to use this skill

When the user invokes `/env-sync` or says any of the trigger phrases:

1. **Determine the target repo.** If the CWD is a Vercel-linked repo, use that. Otherwise ask.

2. **Run the requested subcommand** by executing the script with `cd` to the repo:
```bash
cd "<repo path>" && ~/.claude/skills/env-sync/env-sync.sh <command> [args]
```

3. **Interpret the output for the user.** The script prints structured groups; summarise:
   - Highlight any value mismatches first (most likely cause of bugs)
   - Group missing vars (local-only vs vercel-only) with clear next-step suggestions
   - If pushing/pulling, confirm what changed

4. **For new env vars:** Remind the user to also add a placeholder to `.env.example` so other devs (or future-you on a fresh laptop) know it exists.

## Source-of-truth philosophy

- **`.env.local`** is what your dev server uses. Often has TEST values (`sk_test_*`), localhost URLs, debug log levels.
- **Vercel production** is what the deployed app uses. Has LIVE values, real URLs.
- **They are NOT mirrors.** A diff is normal and expected — what matters is that neither side has stale or accidentally-leaked-across-environments values.

## Repo coverage

Works with any Vercel-linked repo (auto-detect based on CWD or `.vercel/`):

| Layout | Detection | Notes |
|--------|-----------|-------|
| Monorepo (`apps/web`) | `apps/web/.vercel` | runs against the workspace app |
| Single repo | `.vercel/` at root | run `vercel link` once if missing |
| Firebase backend | no Vercel project | use `firebase functions:config:set` instead |

## Safety

- All `diff` output masks values to first 8 chars
- `push` to production warns on test-shaped keys
- `pull-missing` warns on live-shaped keys (with inline comment in `.env.local`)
- Never deletes vars (only adds/updates)
- Vercel CLI's own confirmations still apply
