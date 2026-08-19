---
name: grok-sync
description: Pull progress from a grok CLI session into the current Claude Code conversation, so Claude can continue work you did in Grok. Use when the user says "grok sync", "grab grok's progress", "what did grok do", "continue from grok", or is bouncing a task between the grok CLI and Claude Code (synced sessions). The reverse direction (Claude → Grok) is the `grokvault` shell function, not this skill.
---

# grok-sync — pull Grok's session into Claude

You and the user run a task across two tools: the **grok CLI** (subscription) and
**Claude Code**. This skill ingests the latest Grok session for a project so you can
pick up exactly where Grok left off. It does NOT drive Grok — it reads Grok's saved
transcript (`~/.grok/sessions/<encoded-cwd>/<id>/chat_history.jsonl`).

## Steps

1. **Pick the project dir.** Default to the **current working directory** (run `pwd`) —
   Grok was almost always launched in the same repo you're now in Claude. If the user
   names another repo (or `$ARGUMENTS` contains a path), use that instead.

1b. **Read the handoff ledger** so you see the model-switch timeline. The ledger path is
   `~/.claude/grok-handoffs/<enc>.md` where `<enc>` is the cwd with every non-alphanumeric
   char replaced by `-`:
   ```bash
   enc=$(pwd | sed 's/[^a-zA-Z0-9]/-/g'); cat ~/.claude/grok-handoffs/"$enc".md 2>/dev/null
   ```
   The `⏩ Claude → Grok` lines are prior handoffs out; this sync is the return trip.

2. **List Grok sessions** for that dir so the user can confirm which one:
   ```bash
   python3 ~/.claude/scripts/grok-handoff.py --grok-list "<dir>"
   ```
   If there's only one recent session, skip straight to step 3. If several look
   plausible, show the list and ask which session id (or just take the most recent).

3. **Extract the latest (or chosen) Grok session into context.** Most recent:
   ```bash
   python3 ~/.claude/scripts/grok-handoff.py --grok "<dir>"
   ```
   This prints a clean markdown transcript (system prompt + tool noise stripped,
   `<user_query>` unwrapped). Read its full output — that IS the context to ingest.
   For a specific older session, use `--grok-file` with its chat_history path:
   `python3 ~/.claude/scripts/grok-handoff.py --grok-file "<...>/chat_history.jsonl"`

4. **Orient and report back.** After reading, give the user a tight recap:
   - What Grok was working on and where it got to
   - Concrete changes Grok claims it made (files, decisions) — flag these as *claimed*,
     not verified
   - Any open threads / next steps Grok identified
   Then **verify before trusting**: Grok's transcript is its own account. Check the
   actual repo state (git status/diff, the files it named) before building on it.

5. **Log the return switch** to the ledger so the timeline stays complete and the next
   relay sees it. Look for a `## Handoff back to Claude` section in Grok's transcript and
   use its gist as the note:
   ```bash
   enc=$(pwd | sed 's/[^a-zA-Z0-9]/-/g'); mkdir -p ~/.claude/grok-handoffs
   printf -- '- ⏪ %s  **Grok → Claude**  · %s\n' "$(date '+%Y-%m-%d %H:%M')" "<one-line gist of what Grok did>" >> ~/.claude/grok-handoffs/"$enc".md
   ```

6. **Continue the work** in Claude from that point, per the user's direction.

## Notes
- Size is capped (~120k chars, tail kept). Override: `GROK_HANDOFF_MAXCHARS=200000 python3 ...`.
- This is a snapshot, not a live link. If the user keeps working in Grok afterward,
  re-run grok-sync to pull the newer state.
- Direction memory aid: **`grokvault`** (shell) pushes Claude → Grok; **`/grok-sync`**
  pulls Grok → Claude.
