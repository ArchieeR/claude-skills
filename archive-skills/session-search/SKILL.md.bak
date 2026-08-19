---
name: session-search
description: Find past Claude Code sessions across ALL projects — by exact session NAME (set via /rename) or by topic — and pull their context. Searches the raw transcripts (~/.claude/projects/**/*.jsonl) and launches an agent to read/rank them so huge files never hit the main context. Triggers: "load my <name> session", "find the session where we...", "what did we decide about X", "search my past sessions / chat history".
---

# Deep Session Search

This skill searches the **raw local session transcripts** across every project directory and uses a **sub-agent** to read and rank them — so multi-MB JSONL files never overflow the main context. The agent absorbs the bulk; you get back the conclusion.

## When to use
- You need a session that's old, lives in a different project dir, or was never summarised
- You want the *decisions / design / conclusion* from a past session, not the raw transcript

## How session storage works
Transcripts live at `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl`:
- The **directory** name is the project's working dir with `/` and `.` replaced by `-` (e.g. `-Users-acme-Documents-projects-my-app`).
- The **filename** (minus `.jsonl`) is the session ID.
- Each **line** is one message as JSON; the human-readable text is under `.message.content`.
- **Session names** (set via `/rename`) are recorded in the transcript as a literal `Session renamed to: <name>` line.

## Steps

### 0. Resolve by name first (when the arg is/contains a session name)
If the user passes a short slug (`auth-v2`, `billing`, `refactor`) or says "my X session", try an **exact name lookup** before any topic search:
```bash
cd ~/.claude/projects && NAME="auth-v2"; \
grep -rlE "renamed to: ${NAME}( |<|$)" --include="*.jsonl" . 2>/dev/null \
  | while read -r f; do printf "%s\t%s\n" \
      "$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null)" "$f"; done | sort -r
```
- **One hit** → that's the session; skip to Step 4 (deep-load) directly.
- **Multiple hits** → newest wins, or list them and ask.
- **No hit** → fall back to topic search (Step 1).

### 1. Fast candidate scan
Grep every project for query terms + synonyms, list matching files newest-first with hit counts.

```bash
cd ~/.claude/projects && QUERY="term1|synonym|ProductName|some/path\\.ts"; \
grep -rliE "$QUERY" --include="*.jsonl" . 2>/dev/null \
  | while read -r f; do printf "%s\t%s\t%s\n" \
      "$(grep -icE "$QUERY" "$f")" \
      "$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null || stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)" \
      "$f"; done \
  | sort -rn | head -20
```

### 2. Launch an agent to read + rank
Dispatch a **general-purpose** agent with the candidate file list:

> Read-only investigation. These are Claude Code session transcripts (JSONL — human text is under `.message.content`). They may discuss **"<TOPIC>"**:
> <candidate file paths, newest first>
>
> For each file, extract: title/subject, date range, project, and substantive content on **"<TOPIC>"** — decisions, designs, conclusions, file paths. Summarise without echoing raw JSONL lines. Rank files by relevance.
>
> Return: a ranked list with `session-id · project · date · 2–3 line summary + key decisions`.

### 3. Present ranked results
Show the ranked list to the user.

### 4. Deep-load on request
Pull full relevant context from the chosen session.

## Notes
- JSONL session files can be multi-MB — **NEVER read a whole one into the main thread.**
- Match on **file paths and code symbols**, not just prose.
