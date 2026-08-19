#!/usr/bin/env python3
"""
handoff.py — port context between Claude Code and Codex CLI sessions.

Both tools write append-only JSONL transcripts to disk. This reads either
format, emits a clean human-readable brief, and can push a brief into a
Codex session (new or resumed). Claude is the reader you're already in, so
"push into Claude" = just print the brief and let Claude read it.

Usage:
  handoff.py list [--claude|--codex] [-n N]      list recent sessions (both by default)
  handoff.py pull <file> [--full]                extract clean transcript (--full adds tool calls)
  handoff.py push <brief_file> [--resume ID|--new] [extra prompt...]
                                                 feed brief into Codex via `codex exec`
"""
import sys, os, json, glob, datetime, subprocess

HOME = os.path.expanduser("~")
CLAUDE_GLOB = f"{HOME}/.claude/projects/**/*.jsonl"
CODEX_GLOBS = [f"{HOME}/.codex/sessions/**/rollout-*.jsonl",
               f"{HOME}/.codex/archived_sessions/rollout-*.jsonl"]


def detect(path):
    """Return 'claude' or 'codex' by sniffing the first few lines."""
    try:
        with open(path) as fh:
            for _ in range(5):
                line = fh.readline()
                if not line:
                    break
                t = json.loads(line).get("type")
                if t in ("session_meta", "event_msg", "response_item", "turn_context"):
                    return "codex"
                if t in ("user", "assistant", "attachment", "ai-title", "mode"):
                    return "claude"
    except Exception:
        pass
    return "unknown"


def _claude_text(content):
    """Flatten a Claude message.content into plain text."""
    if isinstance(content, str):
        return content
    out = []
    for b in content or []:
        bt = b.get("type")
        if bt == "text":
            out.append(b.get("text", ""))
        elif bt == "thinking":
            pass  # skip private reasoning
        elif bt == "tool_use":
            out.append(f"[tool_use: {b.get('name')} {json.dumps(b.get('input',{}))[:200]}]")
        elif bt == "tool_result":
            r = b.get("content")
            r = r if isinstance(r, str) else json.dumps(r)[:200]
            out.append(f"[tool_result: {r[:200]}]")
    return "\n".join(x for x in out if x)


def list_sessions(which, n):
    rows = []
    if which in ("both", "claude"):
        for f in glob.glob(CLAUDE_GLOB, recursive=True):
            title = None
            try:
                for l in open(f):
                    o = json.loads(l)
                    if o.get("type") == "ai-title":
                        title = o.get("title") or o.get("payload") or title
                    elif o.get("type") == "user" and not title:
                        c = o.get("message", {}).get("content")
                        if isinstance(c, str):
                            title = c[:60]
            except Exception:
                pass
            rows.append((os.path.getmtime(f), "claude", title or "(untitled)", f))
    if which in ("both", "codex"):
        titles = {}
        idx = f"{HOME}/.codex/session_index.jsonl"
        if os.path.exists(idx):
            for l in open(idx):
                try:
                    o = json.loads(l); titles[o.get("id")] = o.get("thread_name")
                except Exception:
                    pass
        for g in CODEX_GLOBS:
            for f in glob.glob(g, recursive=True):
                sid = None
                try:
                    sid = json.loads(open(f).readline()).get("payload", {}).get("id")
                except Exception:
                    pass
                rows.append((os.path.getmtime(f), "codex",
                             titles.get(sid) or "(untitled)", f))
    rows.sort(reverse=True)
    for mt, src, title, f in rows[:n]:
        ts = datetime.datetime.fromtimestamp(mt).strftime("%b %d %H:%M")
        print(f"{ts} | {src:6} | {title[:55]:55} | {f}")


def pull(path, full):
    kind = detect(path)
    if kind == "claude":
        meta_done = False
        for l in open(path):
            try: o = json.loads(l)
            except Exception: continue
            t = o.get("type")
            if not meta_done and t in ("user", "assistant"):
                print(f"# CLAUDE SESSION  {os.path.basename(path).replace('.jsonl','')}\n"+"="*70)
                meta_done = True
            if t == "user":
                txt = _claude_text(o.get("message", {}).get("content"))
                if txt.strip() and not txt.startswith("[tool_result"):
                    print(f"\n## USER\n{txt.strip()}")
                elif full and txt.strip():
                    print(f"\n  {txt.strip()[:200]}")
            elif t == "assistant":
                txt = _claude_text(o.get("message", {}).get("content"))
                if not txt.strip():
                    continue
                if txt.startswith("[tool_use"):
                    if full: print(f"\n  >> {txt}")
                else:
                    print(f"\n## CLAUDE\n{txt.strip()}")
    elif kind == "codex":
        for l in open(path):
            try: o = json.loads(l)
            except Exception: continue
            t = o.get("type"); p = o.get("payload", {})
            if t == "session_meta":
                print(f"# CODEX SESSION  {p.get('id')}\ncwd: {p.get('cwd')}\n"+"="*70)
            elif t == "event_msg" and isinstance(p, dict):
                pt = p.get("type")
                if pt == "user_message":
                    print(f"\n## USER\n{p.get('message','').strip()}")
                elif pt == "agent_message":
                    print(f"\n## CODEX\n{p.get('message','').strip()}")
            elif full and t == "response_item" and isinstance(p, dict):
                it = p.get("type")
                if it == "function_call":
                    print(f"\n  >> TOOL: {p.get('name')} {str(p.get('arguments'))[:200]}")
                elif it == "local_shell_call":
                    print(f"\n  >> SHELL: {str(p.get('action',{}).get('command'))[:200]}")
    else:
        sys.exit(f"Could not detect format of {path}")


def push(brief_file, resume_id, new, extra):
    brief = open(brief_file).read()
    prompt = ("You are continuing work with full context from another agent "
              "session. Here is that session's transcript. Read it, then carry on.\n\n"
              f"<<<HANDOFF CONTEXT>>>\n{brief}\n<<<END CONTEXT>>>\n\n")
    if extra:
        prompt += "Now: " + " ".join(extra)
    cmd = ["codex", "exec"]
    if resume_id:
        cmd += ["resume", resume_id]
    cmd += [prompt]
    print(f"[handoff] running: codex exec {'resume '+resume_id if resume_id else '(new)'} "
          f"with {len(brief)} chars of context...", file=sys.stderr)
    subprocess.run(cmd)


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    cmd = a[0]
    if cmd == "list":
        which = "both"
        if "--claude" in a: which = "claude"
        if "--codex" in a: which = "codex"
        n = 10
        if "-n" in a: n = int(a[a.index("-n")+1])
        list_sessions(which, n)
    elif cmd == "pull":
        pull(a[1], "--full" in a)
    elif cmd == "push":
        brief = a[1]
        resume_id = a[a.index("--resume")+1] if "--resume" in a else None
        new = "--new" in a
        used = {brief, "--resume", resume_id, "--new", "push"}
        extra = [x for x in a[2:] if x not in used and x != resume_id]
        push(brief, resume_id, new, extra)
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
