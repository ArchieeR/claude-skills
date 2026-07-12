# claude-skills

A toolkit of 16 battle-tested [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code, built and used daily while running a startup. The theme: **context engineering** — moving context between sessions, between AI CLIs (Claude Code ↔ Codex ↔ Grok ↔ Antigravity), and between you and the model.

## Install

```bash
git clone https://github.com/ArchieeR/claude-skills.git
cp -R claude-skills/skills/* ~/.claude/skills/
```

Or symlink individual skills so `git pull` keeps them fresh:

```bash
ln -s "$(pwd)/claude-skills/skills/handoff" ~/.claude/skills/handoff
```

Each skill is invoked with `/<name>` inside Claude Code, or triggers automatically when its description matches what you're doing.

## The skills

### Session interop — move context between sessions and agents

| Skill | What it does |
|-------|--------------|
| [`handoff`](skills/handoff) | Port a conversation between Claude Code and Codex CLI, either direction — pull a clean transcript, push it into another session so that agent continues with full prior logic. |
| [`grab`](skills/grab) | Digest another Claude Code session's recent activity (decisions, built-vs-uncommitted, open questions) via a cheap worker model reading its transcript — without blowing up your context. |
| [`peek`](skills/peek) | Quick glance at what another running CLI session is doing right now — last few turns only, the opposite of a full handoff. |
| [`codex-context`](skills/codex-context) | Import a Codex CLI conversation into Claude's context for review, continuation, or a second opinion. |
| [`ag-context`](skills/ag-context) | Same, for Antigravity (Gemini) sessions. |
| [`grok-sync`](skills/grok-sync) | Pull progress from a grok CLI session into Claude Code so it can continue work started in Grok. |
| [`session-search`](skills/session-search) | Find past Claude Code sessions across ALL projects by name or topic — searches the raw `~/.claude/projects/**/*.jsonl` transcripts with an agent so huge files never hit your main context. |
| [`claude-manage`](skills/claude-manage) | List and resume sessions across project subdirectories — fixes the "which directory did I start that session from?" problem. |

### Decisions & orchestration — get more out of the model

| Skill | What it does |
|-------|--------------|
| [`counsel`](skills/counsel) | Fire multiple LLM panels (Codex, Antigravity, optionally Grok/Perplexity) in parallel on a hard decision, then synthesise into an agree/disagree table + net recommendation. |
| [`ask`](skills/ask) | When context sprawls, distil it into a small set of structured decisions — separating "just decide this" from "needs your judgement" — surfaced as clickable questions. |
| [`recap`](skills/recap) | Table-format recap of the current session: what was done, status, decisions, open follow-ups. Works in any session type. |

### Dev workflow — ship with fewer surprises

| Skill | What it does |
|-------|--------------|
| [`env-sync`](skills/env-sync) | Compare and sync env vars between `.env.local` and Vercel (production/preview). Repo-agnostic, masks values, never deletes. |
| [`visual-qa`](skills/visual-qa) | Screenshot-driven feedback loop to verify UI actually looks right before committing. |
| [`mcp-config`](skills/mcp-config) | Add, configure, and troubleshoot MCP servers — remote and local, auth headers, scopes, and a diagnostics playbook for "it won't connect". |
| [`vercel-troubleshooting`](skills/vercel-troubleshooting) | Playbook for the common Vercel build failures in Next.js apps: module resolution, type safety, config pitfalls. |
| [`nextjs-ui`](skills/nextjs-ui) | Layout architecture, responsive patterns, and color-system conventions for Next.js + React 19 + Tailwind v4 + shadcn/ui. |

## Notes

- Skills that reference external CLIs (`codex`, `agy`, `grok`) assume you have those installed and authed; each skill degrades gracefully and tells you what's missing.
- Everything here is scrubbed of project-specific context — paths and examples are generic. Adapt the examples (e.g. repo tables in `env-sync`) to your own setup.

## License

MIT
