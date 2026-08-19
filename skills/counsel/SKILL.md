---
name: counsel
description: Fire multiple LLM panels in parallel (e.g. OpenAI/Codex, Gemini/Antigravity, Grok, Perplexity) for sense-checks on architectural decisions, design reviews, hard problems. Synthesise their findings into agree/disagree table + net recommendation. Use when one model's opinion isn't enough — when the decision is structurally important and you want multiple voices to expose blind spots.
---

When the user runs `/counsel <question>`, you orchestrate a panel of external LLMs, then synthesise.

## Default panels

1. **Codex / Azure GPT** — via `Agent` subagent or CLI (`codex exec --skip-git-repo-check -s read-only "..."`).
2. **Antigravity (Gemini)** — via CLI (`agy -p "<prompt>" 2>&1 | tail -120`).
3. **Grok (xAI)** — via CLI (`grok -p "<prompt>"`).

> **Fail-fast rules (parallel + fail-fast council ≈ 30-40s total):**
> - If a panel CLI is missing or errors with auth/quota, mark `⚠️ unavailable (<reason>)` and proceed.
> - Any panel taking past 180s: abandon it, synthesise without it.
> - Never serialize panels; run them in parallel.

## Process

1. **Dispatch all panels in parallel** — single turn, multiple tool calls, `run_in_background: true` where supported.
2. **Collect outputs** from each panel as they complete.
3. **Synthesise** — create an agree/disagree table, then state a net recommendation with confidence level.

## Flags

- `--quick` — Codex + Grok only (drop Gemini)
- `--research` — add Perplexity or deep-research search panel
- `--raw` — append full panel outputs verbatim below the synthesis
- `--no-agy` — drop the Antigravity panel

## Synthesis format

```markdown
## Counsel: <question>

| Dimension / Issue | Codex / GPT | Antigravity (Gemini) | Grok | Consensus |
|-------------------|-------------|----------------------|------|-----------|
| ...               | ...         | ...                  | ...  | ...       |

**Net recommendation:** ...

**Confidence:** <high/med/low> — <why>
```

(If a panel is unavailable, keep its column and write `⚠️ unavailable` so the gap is visible. Never hide a missing voice.)

## Notes

- Each panel runs independently; one failing shouldn't block the others.
- Synthesise faithfully — don't let one loud panel dominate. Flag genuine disagreements.
- Make sure CLI commands are non-interactive / headless-safe.
