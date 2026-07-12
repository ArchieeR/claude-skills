---
name: peek
description: Quickly glance at what another running CLI session (Grok, etc.) is doing in the current dir — just the last few turns, NOT the whole conversation. Use when the user says "peek at the other terminal", "what's grok doing right now", "look at that session quickly", "grab the context from the other terminal" — a light glance, the opposite of a full handoff. For the full ingest/continue use /grok-sync instead.
---

# peek — light glance at another terminal's session

The user runs multiple terminals (e.g. Claude here, Grok next door). This pulls just the
**tail** of the other session so you get oriented fast without reading the entire thread.

## Steps

1. **Default to the current working directory** (`pwd`) — the other CLI was launched there.
   The user may name another dir or a model.

2. **Peek** — last few turns only (default 6; pass a number for more):
   ```bash
   python3 ~/.claude/scripts/grok-handoff.py --peek "$(pwd)" 6
   ```
   Read the output. It's a glance, not the full conversation.

3. **Report the gist in 2–3 lines**: what the other session is currently doing and its last
   move. Don't summarise the whole history — just "here's where that terminal is right now."
   If the user then wants to actually take it over, escalate to `/grok-sync` (full ingest).

## Notes
- Peek ≠ sync. Peek is read-and-orient; `/grok-sync` is ingest-and-continue (+ledger marker).
- Bigger window: `--peek "$(pwd)" 20`, or `GROK_PEEK_TURNS=20`.
- The "drag context between sessions" UX is the dashboard's job; this is the data primitive.
