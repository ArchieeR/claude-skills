---
name: handoff
description: Port context between Claude Code and Codex CLI sessions, in either direction. PULL a clean transcript out of any Claude or Codex session; PUSH it into a Codex session (new or resumed) so that agent continues with full prior logic. Use for "continue this codex chat in claude", "give claude the context from that codex session", "carry this session's logic into another codex session", "bridge claude and codex". Triggers - "/handoff", "pull context from", "hand this to codex/claude".
---

# Session Handoff (Claude ⇄ Codex)

Both Claude Code and Codex CLI write append-only JSONL transcripts to disk. There is no live socket between them, but context is fully portable at message granularity. This skill moves it either way.

- **PULL** — read any Claude *or* Codex session into a clean brief (this is how Claude "sees" a Codex chat, and vice-versa).
- **PUSH** — inject a brief into a Codex session, either a fresh one (`codex exec`) or an existing one (`codex exec resume <id>`), so Codex continues with the other session's logic.
- **Push into Claude** = there's nothing to run — Claude is the session you're in, so a PULL printed into context *is* the push.

Helper script: `~/.claude/skills/handoff/handoff.py` (auto-detects format).

Transcript locations:
- Claude: `~/.claude/projects/<cwd-slug>/<session-id>.jsonl`
- Codex live: `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` · archived: `~/.codex/archived_sessions/rollout-*.jsonl`

## How to use

When the user invokes `/handoff` (optionally with a hint or direction):

### Step 1 — list sessions from both tools
```bash
python3 ~/.claude/skills/handoff/handoff.py list -n 10
```
Output columns: `time | claude|codex | title | path`. Add `--claude` or `--codex` to filter.

### Step 2 — figure out source + destination
Use **AskUserQuestion** if ambiguous. Two things to pin: which **source** session to pull, and where it **goes**:
- → **into Claude (here)**: just PULL and read it. Done.
- → **into Codex (new session)**: PULL source to a file, then PUSH `--new`.
- → **into Codex (continue an existing chat)**: PULL source to a file, then PUSH `--resume <target-id>`.

If the user named a session by topic, find its path with the `list` output or:
`grep -l "<keyword>" ~/.codex/**/rollout-*.jsonl ~/.claude/projects/**/*.jsonl`

### Step 3 — PULL
```bash
python3 ~/.claude/skills/handoff/handoff.py pull "<source.jsonl>" > /tmp/handoff-brief.md      # clean dialogue
python3 ~/.claude/skills/handoff/handoff.py pull "<source.jsonl>" --full > /tmp/handoff-brief.md  # + tool calls/shell
```
If destination is Claude, Read `/tmp/handoff-brief.md` and summarise (what it was about, key decisions, file paths, open questions). Stop here.

### Step 4 — PUSH (only when destination is Codex)
This RUNS Codex and spends tokens — confirm with the user first.
```bash
# continue an existing Codex session with the pulled context:
python3 ~/.claude/skills/handoff/handoff.py push /tmp/handoff-brief.md --resume <target-id> "continue the brand work using this logic"

# or spin up a fresh Codex session seeded with it:
python3 ~/.claude/skills/handoff/handoff.py push /tmp/handoff-brief.md --new "pick this up"
```
Relay Codex's reply back to the user. To then pull Codex's continuation back into Claude, re-run Step 3 on the newest Codex rollout.

## Notes & limits
- **Not real-time.** Syncs at message boundaries — re-pull to get new lines from a still-running session.
- **Reasoning is stripped** on pull (Claude `thinking` blocks, Codex encrypted reasoning) — only user/assistant text, plus tool calls under `--full`.
- **Loop safety:** PUSH is a single one-shot call, not an auto-loop. Keep a human in the loop; never wire PULL→PUSH→PULL on a timer without a turn cap.
- The lighter `/cx` skill is just the Codex→Claude PULL on its own; `/handoff` is the full matrix.
