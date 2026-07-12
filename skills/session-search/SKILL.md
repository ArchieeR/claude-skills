---
name: session-search
description: Find past Claude Code sessions across ALL projects — by exact session NAME (set via /rename) or by topic — and pull their context. Searches the raw transcripts (~/.claude/projects/**/*.jsonl) and launches an agent to read/rank them so huge files never hit the main context. Use when /load-session comes up empty (its vault index only holds the few most-recently-summarised sessions). Triggers: "load my <name> session", "find the session where we...", "what did we decide about X", "search my past sessions / chat history".
---

# Deep Session Search

`/load-session` only searches the thin vault index (≈3 most-recently-summarised sessions), so it misses almost everything. This skill searches the **raw local session transcripts** across every project directory and uses a **sub-agent** to read and rank them — so multi-MB JSONL files never overflow the main context. The agent absorbs the bulk; you get back the conclusion.

## When to use
- `/load-session` returned nothing relevant (its index is tiny)
- You need a session that's old, lives in a different project dir, or was never summarised
- You want the *decisions / design / conclusion* from a past session, not the raw transcript

## How session storage works
Transcripts live at `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl`:
- The **directory** name is the project's working dir with `/` and `.` replaced by `-` (e.g. `-Users-you-code-acme-repos`). It tells you which project the session belongs to.
- The **filename** (minus `.jsonl`) is the session ID.
- Each **line** is one message (user / assistant / tool result) as JSON; the human-readable text is under `.message.content`.
- **Session names** (set via `/rename`) are recorded in the transcript as a literal `Session renamed to: <name>` line — so a name maps to a file with one exact grep. A session can be renamed more than once; the **last** marker wins.

## Steps

### 0. Resolve by name first (when the arg is/contains a session name)
If the user passes a short slug (`googleio`, `billing`, `martin`) or says "my X session", try an **exact name lookup** before any topic search — it's a precise, instant hit:
```bash
cd ~/.claude/projects && NAME="googleio"; \
grep -rlE "renamed to: ${NAME}( |<|$)" --include="*.jsonl" . 2>/dev/null \
  | while read -r f; do printf "%s\t%s\n" \
      "$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null)" "$f"; done | sort -r
```
- **One hit** → that's the session; skip to Step 4 (deep-load) directly.
- **Multiple hits** (name reused across sessions) → newest wins, or list them and ask.
- **No hit** → fall back to topic search (Step 1).

Heuristic: a **single token** → try name-resolution first, then topic. A **phrase** → topic search. An explicit `name:<slug>` arg forces this path. To list all named sessions: `grep -rhoE "renamed to: .*" --include="*.jsonl" . | sort -u`.

### 1. Fast candidate scan (inline, cheap)
Grep every project for the query terms + obvious synonyms/product-names, list matching files newest-first with hit counts. Build a broad alternation regex — include synonyms, product names, and any file paths/symbols likely referenced.

```bash
cd ~/.claude/projects && QUERY="term1|synonym|ProductName|some/path\\.ts"; \
grep -rliE "$QUERY" --include="*.jsonl" . 2>/dev/null \
  | while read -r f; do printf "%s\t%s\t%s\n" \
      "$(grep -icE "$QUERY" "$f")" \
      "$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null || stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)" \
      "$f"; done \
  | sort -rn | head -20
```
- Column 1 = hit count, column 2 = last-modified date, column 3 = `<project-dir>/<session-id>.jsonl`.
- If **zero hits**, broaden the regex once (more synonyms, looser stems) and retry. Still zero → the session probably isn't a Claude Code session: suggest **Antigravity** (`/ag-context`) or that the user paste it. Don't keep grepping blindly.

### 2. Launch an agent to read + rank (the whole point — keep raw transcripts OUT of the main context)
Dispatch a **general-purpose** (or **Explore**) agent with the candidate file list. Run it in the background if the candidate set is large. Use a prompt like:

> Read-only investigation. These are Claude Code session transcripts (JSONL — one message per line; human text is under `.message.content`). They may discuss **"<TOPIC>"**:
> <candidate file paths, newest first>
>
> For each file, extract: a title/subject, date range, which project (from the dir name), and the **substantive content on "<TOPIC>"** — decisions, designs, conclusions, file paths, open questions. Pull only the `.message.content` text of matching messages and summarise — **do NOT echo raw JSONL lines, and never read an entire file into your reply** (they can be multi-MB). Rank the files by relevance to "<TOPIC>".
>
> Return: a ranked list — for each, `session-id · project · date · 2–3 line "what's in it" + the key excerpts/decisions`. Flag the single best match and give a tight synthesis of its relevant content.

### 3. Present ranked results
Show the user the ranked list (session ID, project, date, one-liner). If there's one clear winner, fold its key points straight into the current session. If it's ambiguous, ask which to load deeper.

### 4. Deep-load on request
For the chosen session, dispatch the agent again (or read targeted line ranges) to pull the full relevant context — decisions, designs, file paths — into a concise summary the current session can build on.

## Notes
- JSONL session files can be multi-MB — **NEVER `Read` a whole one into the main thread.** That's exactly what the agent is for.
- Match on **file paths and code symbols**, not just prose — sessions reference things like `foo.ts:123`.
- This is macOS (darwin): `stat -f '%Sm'`. The snippet falls back to `stat -c` for Linux.
- Routing: Antigravity sessions aren't on disk here → `/ag-context`. Vault-summarised sessions → `/load-session`. Everything else (the bulk) → this skill.
