---
name: cx
description: Import a Codex CLI conversation into Claude's context. Use when you want Claude to read, review, continue, or get a second opinion on what was done in a Codex (OpenAI) session. Triggers - "/cx", "read my codex session", "what did codex do", "load that codex chat".
---

# Codex Session Context Import

Codex CLI writes every session to plain JSONL on disk — no plugin or bridge is needed for Claude to read them. This skill lists recent Codex sessions and imports a chosen one into context so you can review, continue, or sense-check Codex's work.

> Note: there is NO live bridge between Codex and Claude. This reads the on-disk transcript, which is current as of the last thing Codex wrote. If a Codex session is still actively running, re-run the skill to pick up new lines.

## Where Codex stores sessions

- Live: `~/.codex/sessions/YYYY/MM/DD/rollout-<ts>-<id>.jsonl`
- Archived: `~/.codex/archived_sessions/rollout-<ts>-<id>.jsonl`
- Index: `~/.codex/session_index.jsonl` (one `{id, thread_name, updated_at}` per line)

Each rollout file is JSONL. Line types: `session_meta` (id, cwd, model), `turn_context`, `response_item` (full model items incl. reasoning), and `event_msg` (clean `user_message` / `agent_message` text — this is what we extract).

## How to Use This Skill

When the user invokes `/cx` (optionally with a hint like `/cx weekly brief`):

### Step 1: List recent sessions

```bash
python3 - <<'PY'
import json, os, glob, datetime
home = os.path.expanduser("~")
files = glob.glob(f"{home}/.codex/sessions/**/rollout-*.jsonl", recursive=True) \
      + glob.glob(f"{home}/.codex/archived_sessions/rollout-*.jsonl")
# newest first by mtime
files = sorted(files, key=os.path.getmtime, reverse=True)[:8]
# title lookup from session_index.jsonl
titles = {}
idx = f"{home}/.codex/session_index.jsonl"
if os.path.exists(idx):
    for l in open(idx):
        try:
            o = json.loads(l); titles[o.get("id")] = o.get("thread_name")
        except: pass
for f in files:
    sid, cwd, title = "?", "?", None
    try:
        meta = json.loads(open(f).readline())
        p = meta.get("payload", meta)
        sid = p.get("id", "?"); cwd = p.get("cwd", "?")
    except: pass
    title = titles.get(sid) or "(no title)"
    mt = datetime.datetime.fromtimestamp(os.path.getmtime(f)).strftime("%b %d %H:%M")
    print(f"{mt} | {title} | cwd={os.path.basename(cwd)} | {f}")
PY
```

### Step 2: Present options to the user

Use **AskUserQuestion** to present the sessions (timestamp + title + cwd). If the user gave a hint and exactly one session clearly matches, skip the question and go straight to Step 3 (mention which you picked).

### Step 3: Extract the conversation

Replace `FILE` with the chosen path:

```bash
python3 - <<'PY'
import json
FILE = "FILE"  # <-- chosen rollout path
out = []
meta = None
for l in open(FILE):
    try: o = json.loads(l)
    except: continue
    t = o.get("type"); p = o.get("payload", {})
    if t == "session_meta":
        meta = p
    elif t == "event_msg" and isinstance(p, dict):
        pt = p.get("type")
        if pt == "user_message":
            out.append(("USER", p.get("message", "")))
        elif pt == "agent_message":
            out.append(("CODEX", p.get("message", "")))
if meta:
    print(f"# Codex session: {meta.get('id')}")
    print(f"cwd: {meta.get('cwd')}  |  model: {meta.get('model','?')}\n")
for role, msg in out:
    if not msg: continue
    print(f"\n### {role}\n{msg.strip()}")
PY
```

This prints the clean human↔Codex dialogue (skipping reasoning/tool-noise). For deeper detail (tool calls, reasoning, file edits), read `response_item` lines from the same file directly with Read/grep.

### Step 4: Summarize

Give the user a tight summary:
- What the session was about
- Key decisions / what Codex built or changed (with file paths if present)
- Any open questions or unfinished work

### Step 5: Ready

Tell the user the context is loaded and ask what they want to do — review it, continue the work, or get a second opinion.

## Notes
- If the conversation is huge, extract first, then Read the printed output rather than piping the whole raw JSONL into context.
- To find a session by content rather than title, `grep -l "<keyword>" ~/.codex/**/rollout-*.jsonl`.
