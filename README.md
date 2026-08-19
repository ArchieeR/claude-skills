# claude-skills

A toolkit of 14 battle-tested [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code, Goose, and Berd — built and used daily while running startups.

The core theme: **context engineering & agent orchestration** — routing context between sessions, fanning out multi-model agent panels (Claude ↔ Codex ↔ Grok ↔ Gemini), and keeping human judgment at high leverage.

---

## Quick Install

```bash
git clone https://github.com/ArchieeR/claude-skills.git
cp -R claude-skills/skills/* ~/.claude/skills/
```

Or symlink individual skills so `git pull` keeps them updated:

```bash
ln -s "$(pwd)/claude-skills/skills/handoff" ~/.claude/skills/handoff
```

Each skill can be invoked with `/<name>` or triggered automatically when its description matches what you're doing.

---

## The 14 Active Skills

### ⚡ Focus & Productivity — human-centered output shaping

| Skill | Description |
|-------|-------------|
| [`i-have-adhd`](skills/i-have-adhd) | Shape model output specifically for an ADHD brain — lead with immediate action, number multi-step work, suppress tangents, provide exact time estimates, and make wins visible. |

### 🛠️ Decisions & Orchestration — get maximum leverage from models

| Skill | Description |
|-------|-------------|
| [`team`](skills/team) | Multi-model implement → verify → fix → commit loop. Features Mode A (Full credit), Mode B (Shared), and Mode C (Delegated orchestration), with strict verification gates. |
| [`prd-interview`](skills/prd-interview) | Systematic product discovery interview for new features. Maps uncertainty spaces, locks defaults, and asks mutually exclusive forks via interactive prompts to yield a clean decision ledger. |
| [`counsel`](skills/counsel) | Run multi-LLM panels (Codex / Azure GPT, Gemini, Grok) in parallel on hard architectural decisions. Synthesises findings into an agree/disagree table + net recommendation. |
| [`ask`](skills/ask) | When context sprawls, distil open state into a small set of structured decisions — separating self-resolvable items from genuine forks. |
| [`recap`](skills/recap) | Dense table-format recap of the current session: what was done, status, decisions made, and open follow-ups. |

### 🔄 Session Interop — move context across sessions & model CLIs

| Skill | Description |
|-------|-------------|
| [`handoff`](skills/handoff) | Full bidirectional context bridge between Claude Code and Codex CLI — pull clean transcripts or push logic into new/resumed sessions. |
| [`grab`](skills/grab) | Digest another Claude Code session's recent activity (decisions, built-vs-uncommitted, open questions) via a background worker reading its transcript. |
| [`session-search`](skills/session-search) | Find past sessions across ALL projects by name (`/rename`) or topic — searches raw `~/.claude/projects/**/*.jsonl` transcripts via sub-agents. |

### 🛠️ Dev Workflow & Infrastructure

| Skill | Description |
|-------|-------------|
| [`mcp-config`](skills/mcp-config) | Add, configure, and troubleshoot MCP servers — remote and local, auth headers, scopes, and diagnostic playbooks. |
| [`env-sync`](skills/env-sync) | Compare and sync env vars between `.env.local` and Vercel (production/preview). Repo-agnostic, masks values, never deletes. |
| [`visual-qa`](skills/visual-qa) | Screenshot-driven feedback loop (via Firefox / DevTools) to verify UI actually looks right before committing. |
| [`vercel-troubleshooting`](skills/vercel-troubleshooting) | Playbook for common Vercel build failures in Next.js apps: module resolution, type safety, config pitfalls. |
| [`nextjs-ui`](skills/nextjs-ui) | Layout architecture, responsive patterns, and color-system conventions for Next.js + React 19 + Tailwind v4 + shadcn/ui. |

---

## Usage Notes

- **Model Agnostic / Multi-CLI:** Skills referencing external CLIs (`codex`, `agy`, `grok`) degrade gracefully if those binaries aren't installed or authed.
- **Scrubbed & Generic:** All skills are scrubbed of personal paths, private tokens, and internal project names so they run out of the box anywhere.

## License

MIT
