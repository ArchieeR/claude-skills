---
name: claude-manage
description: Find, list, and resume previous Claude Code sessions across project subdirectories. Use when the user wants to see recent sessions, locate a specific session to resume, or figure out which directory a past session belongs to (since sessions are stored per-cwd and /resume is unreliable across multiple terminals).
user_invocable: true
---

# Claude Session Manager

Helps find, list, and resume previous Claude Code sessions across a multi-directory project.

## The Problem

Sessions are stored per-project-directory. Starting Claude from `acme-repos/` vs `acme-repos/acme-dashboard/` creates sessions in different locations. This makes `/resume` unreliable when you have multiple terminals.

## Session Storage Locations

```
~/.claude/projects/-Users-you-code-acme-repos/
~/.claude/projects/-Users-you-code-acme-repos-acme-dashboard/
~/.claude/projects/-Users-you-code-acme-repos-acme-website/
```

Each contains:
- `{session-id}.jsonl` — full conversation transcript
- `sessions-index.json` — index with summaries, first prompt, message count, dates

## When User Runs `/claude-manage`

### 1. List Recent Sessions

Search across ALL project directories:

```bash
# Read session indexes from all project dirs
for dir in ~/.claude/projects/-Users-you-code-acme-repos*; do
  cat "$dir/sessions-index.json" 2>/dev/null
done
```

Also check `~/.claude/history.jsonl` for the most recent activity timestamps.

### 2. Display Format

For each recent session, show:
- **Session ID** (for `--resume`)
- **Summary** (from sessions-index.json)
- **First prompt** (truncated)
- **Last active** time
- **Message count**
- **Which directory** it belongs to (so user knows where to `cd`)

### 3. Resume Instructions

Tell the user:
```bash
cd "{correct-project-directory}"
claude --resume {session-id}
```

## Tips

- Sessions started from `acme-repos/` root can only be resumed from there
- Sessions started from `acme-repos/acme-dashboard/` need to be resumed from that subdirectory
- The `history.jsonl` file has the latest timestamps but sessions-index.json has summaries
- To extract user messages from a session: parse the `.jsonl` file for `type: "human"` entries
