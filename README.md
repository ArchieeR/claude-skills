# claude-skills

A toolkit of 20 battle-tested [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code, Goose, and Berd — built and used daily while running startups. 

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

## The 20 Skills

### ⚡ Productivity & Focus — human-centered output shaping

| Skill | Description |
|-------|-------------|
| [`i-have-adhd`](skills/i-have-adhd) | Shape model output specifically for an ADHD brain — lead with immediate action, number multi-step work, suppress tangents, provide exact time estimates, and make wins visible. |

### 🛠️ Decisions & Orchestration — get maximum leverage from models

| Skill | Description |
|-------|-------------|
| [`team`](skills/team) | Multi-model implement → verify → fix → commit loop. Features Mode A (Full credit), Mode B (Shared), and Mode C (Delegated orchestration), with strict verification gates to prevent fabricated findings from burning cycles. |
| [`prd-interview`](skills/prd-interview) | Systematic product discovery interview for new features. Maps uncertainty spaces, locks defaults, and asks mutually exclusive forks via interactive prompts to yield a clean decision ledger. |
| [`counsel`](skills/counsel) | Run multi-LLM panels (Codex / Azure GPT, Gemini, Grok) in parallel on hard architectural decisions. Synthesises findings into an agree/disagree table + net recommendation. |
| [`ask`](skills/ask) | When context sprawls, distil open state into a small set of structured decisions — separating self-resolvable items from genuine forks surfaced via interactive choices. |
| [`recap`](skills/recap) | Dense table-format recap of the current session: what was done, status, decisions made, and open follow-ups. |

### 🔄 Session Interop — move context across sessions & model CLIs

| Skill | Description |
|-------|-------------|
| [`handoff`](skills/handoff) | Port a conversation between Claude Code and Codex CLI in either direction — pull a clean transcript, push it into another session so that agent continues with full prior logic. |
| [`grab`](skills/grab) | Digest another Claude Code session's recent activity (decisions, built-vs-uncommitted, open questions) via a background worker reading its transcript without bloating your main context. |
| [`peek`](skills/peek) | Quick glance at what another running CLI session is doing right now — last few turns only. |
| [`codex-context`](skills/codex-context) | Import a Codex CLI conversation into Claude's context for review, continuation, or a second opinion. |
| [`ag-context`](skills/ag-context) | Import Antigravity (Gemini) sessions into Claude's context. |
| [`grok-sync`](skills/grok-sync) | Pull progress from a Grok CLI session into Claude Code so it can continue work started in Grok. |
| [`session-search`](skills/session-search) | Find past sessions across ALL projects by name (`/rename`) or topic — searches raw `~/.claude/projects/**/*.jsonl` transcripts via sub-agents so huge files stay out of main context. |
| [`claude-manage`](skills/claude-manage) | List and resume sessions across project subdirectories — solves "which folder did I start that session in?". |

### 🛠️ Dev Workflow & System Performance

| Skill | Description |
|-------|-------------|
| [`memory`](skills/memory) | RAM & MCP-stacking audit runbook for macOS. Detects duplicate MCP servers across global and project config layers, analyzes process math, and fixes Spotlight `node_modules` indexing churn. |
| [`mcp-config`](skills/mcp-config) | Add, configure, and troubleshoot MCP servers — remote and local, auth headers, scopes, and diagnostic playbooks. |
| [`env-sync`](skills/env-sync) | Compare and sync env vars between `.env.local` and Vercel (production/preview). Repo-agnostic, masks values, never deletes. |
| [`visual-qa`](skills/visual-qa) | Screenshot-driven feedback loop to verify UI actually looks right before committing. |
| [`vercel-troubleshooting`](skills/vercel-troubleshooting) | Playbook for common Vercel build failures in Next.js apps: module resolution, type safety, config pitfalls. |
| [`nextjs-ui`](skills/nextjs-ui) | Layout architecture, responsive patterns, and color-system conventions for Next.js + React 19 + Tailwind v4 + shadcn/ui. |

---

## Usage Notes

- **Model Agnostic / Multi-CLI:** Skills referencing external CLIs (`codex`, `agy`, `grok`) degrade gracefully if those binaries aren't installed or authed.
- **Scrubbed & Generic:** All skills are scrubbed of personal paths, private tokens, and internal project names so they run out of the box anywhere.

## License

MIT
