---
name: counsel
description: Fire 3 LLM panels in parallel (Codex, Antigravity, Grok) for sense-checks on architectural decisions, design reviews, hard problems. Synthesise their findings into agree/disagree table + net recommendation. Use when one model's opinion isn't enough — when the decision is structurally important and you want multiple voices to expose blind spots.
---

When the user runs `/counsel <question>`, you orchestrate a panel of external LLMs, then synthesise.

## Default panels

1. **Codex** (gpt-5.5, high reasoning per ~/.codex/config.toml) — via `Agent` tool, `subagent_type: "codex:codex-rescue"`. If invoking the CLI directly instead, ALWAYS use headless-safe flags: `codex exec --skip-git-repo-check -s read-only -c 'notify=[]' -c 'approval_policy="never"' "..."` — without the notify/approval overrides it hangs on approvals and launches the Computer-Use client app that never closes.
2. **Antigravity** (Gemini 3.5 Flash, Medium effort) — via Bash: `agy -p "<prompt>" 2>&1 | tail -120`
3. **Grok — OPT-IN ONLY, not a default panel.** Include only when explicitly asked (`--grok`). When used: via Bash, stdout/stderr separate + retry-on-auth-race (step 4 snippet); never `2>&1`.

> **Fail-fast rules (parallel + fail-fast council ≈ 36s total):**
> - Grok stderr showing `402` / `spending-limit` = out of credits → ONE attempt only, mark `⚠️ unavailable (402 — top up)`.
> - `codex --version` erroring `spawn ENOENT` on the vendored binary = broken npm install → `npm i -g @openai/codex@latest --force`, surface it, skip the panel this run.
> - macOS has no `timeout`/`gtimeout` by default — use the Bash tool's `timeout` param (ms) instead.
> - Any panel past 180s: abandon it, synthesise without it. Never serialize panels; never retry deterministic failures.

## Process

1. **Dispatch all panels in parallel** — single message, multiple tool calls, `run_in_background: true` where supported.
2. **Codex** — use the `Agent` tool with `subagent_type: "codex:codex-rescue"`. Ask it to lead with `[Model: <id>]`.
3. **Antigravity** — Bash with `agy -p`. **Health check:** if the output is empty, or contains `AuthorizationRequired` / auth errors, the Antigravity session has expired — do NOT silently drop it. Mark the panel `⚠️ unavailable (auth expired)` in the synthesis and tell the user verbatim:
   > Antigravity (`agy`) needs re-auth. Open the **Antigravity app** and sign in (re-auth, not just launch). Re-run `/counsel` after. (There's no `agy login` — auth comes from the app session; once reauthed, headless `agy -p` works from a non-interactive shell, no PTY needed.)
   Continue synthesising the other panels regardless.
4. **Grok** — Bash. The CLI uses your authed grok.com session (no `XAI_API_KEY` needed).
   **Known bug (grok 0.2.14):** longer prompts intermittently fail at startup with `no auth credentials found, will try unauthenticated` on stderr → **empty stdout** (a token-refresh/worker race, NOT real auth loss — short prompts are 5/5 reliable and `~/.grok/auth.json` is valid). **Mitigation: keep Grok's brief concise (~150 words / under ~500 chars)** — that alone makes it reliable; the retry below covers the rest. Use this exact pattern (separate streams + retry up to 3×):
   ```bash
   export PATH="$HOME/.local/bin:$HOME/.grok/bin:$PATH"
   PROMPT_FILE=$(mktemp); cat > "$PROMPT_FILE" <<'GROKEOF'
   <prompt here>
   GROKEOF
   for i in 1 2 3; do
     grok -p "$(cat "$PROMPT_FILE")" --output-format plain --always-approve --no-alt-screen >/tmp/grok.out 2>/tmp/grok.err
     if [ -s /tmp/grok.out ] && ! grep -qi "no auth credentials" /tmp/grok.err; then break; fi
     sleep 2
   done
   cat /tmp/grok.out
   ```
   Only treat Grok as `⚠️ unavailable` if all 3 attempts yield empty stdout — then note: run `grok` once interactively (or `grok login`) to refresh `~/.grok/auth.json`. The cosmetic `ERROR ... AuthorizationRequired` worker lines on stderr are harmless noise as long as stdout is non-empty.
5. **Synthesise** — agree/disagree table, then net recommendation with confidence.

## Flags

- `--quick` — Codex + Grok only (drop Antigravity)
- `--pplx` / `--research` — add/run Perplexity (requires your own Perplexity API access). `--research` = Perplexity-only deep dive.
- `--all` — add a 4th panel: Gemini CLI (`gemini -p`)
- `--raw` — append full panel outputs verbatim below the synthesis
- `--grok` — ADD the Grok panel (opt-in; excluded by default)
- `--no-agy` — drop the Antigravity panel

## Synthesis format

```
## Counsel: <question>

| Issue | Codex | Antigravity | Grok | Consensus |
|-------|-------|-------------|------|-----------|
| ...   | ...   | ...         | ...  | ...       |

**Net recommendation:** ...

**Confidence:** <high/med/low> — <why>
```

(If a panel is unavailable, keep its column and write `⚠️ unavailable` so the gap is visible rather than hidden. Add a Perplexity column only when `--pplx`/`--research` is used.)

## Notes

- Each panel runs independently; one failing shouldn't block the others — but surface the failure (esp. Antigravity auth), never hide it.
- Synthesise faithfully — don't let one loud panel dominate. Flag genuine disagreements.
- The frontmatter `description` drives auto-discovery; keep it tight.
- CLI paths: `pplx` + `agy` + `grok` live in `~/.local/bin` (grok via `~/.grok/bin`). Codex is the `codex:codex-rescue` subagent.
