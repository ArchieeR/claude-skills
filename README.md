# 🛠️ claude-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills Count](https://img.shields.io/badge/Active%20Skills-13-blue.svg)](https://github.com/ArchieeR/claude-skills)
[![Compatibility](https://img.shields.io/badge/Compatible%20With-Claude%20Code%20%7C%20Goose%20%7C%20Berd-orange.svg)](https://github.com/ArchieeR/claude-skills)

A curated collection of production-grade [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for **Claude Code**, **Goose**, and **Berd**.

Designed for **context engineering & multi-agent orchestration** — fanning out multi-model panels, offloading heavy coding to worker agents, managing decision UI, and keeping human judgment at high leverage.

---

## 🚀 Quick Install

### Option A: 1-Command Install via `npx` / `skillfish` (Recommended)

Run a single command without cloning:

```bash
npx skillfish add ArchieeR/claude-skills --all
```

To install a specific skill (e.g., `ask` or `team`):

```bash
npx skillfish add ArchieeR/claude-skills ask
```

---

### Option B: Clone & Symlink / Copy

Clone the repository and copy or symlink into your global `~/.claude/skills/` directory:

```bash
git clone https://github.com/ArchieeR/claude-skills.git ~/claude-skills
mkdir -p ~/.claude/skills

# Copy all active skills
cp -R ~/claude-skills/skills/* ~/.claude/skills/

# OR symlink individual skills so `git pull` keeps them fresh:
ln -s ~/claude-skills/skills/ask ~/.claude/skills/ask
```

---

## 🧰 Core Highlighted Skills

### 🧠 Decisions, Focus & Multi-Model Orchestration

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
| **[`ask`](skills/ask)** | `/ask` | Converts fat text and sprawling sub-agent reports into interactive `AskUserQuestion` decision chips so you can steer in seconds. |
| **[`counsel`](skills/counsel)** | `/counsel <question>` | Fires parallel consensus panels across **Grok CLI** (infra scouting) and **Codex CLI** (code review) to eliminate blind spots. |
| **[`team`](skills/team)** | `/team [a\|b\|c] <task>` | Multi-model implement → verify → fix → commit loop with 3 staffing modes to offload heavy investigation, writing, and fixing to Codex workers. |
| **[`recap`](skills/recap)** | `/recap`, `/table` | Dense table-format recap of the current session: work done, status, decisions made, and open follow-up items. |
| **[`i-have-adhd`](skills/i-have-adhd)** | `/i-have-adhd` | Shapes model output specifically for ADHD focus: leads with immediate action, numbers multi-step work, suppresses tangents, and gives exact time estimates. |

### 🛠️ Dev Workflow, Product & Session Search

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
| **[`prd-interview`](skills/prd-interview)** | `/prd-interview`, `/prd` | Systematic product discovery interview for new features. Maps uncertainty spaces, locks defaults, and interviews via interactive choices. |
| **[`grab`](skills/grab)** | `/grab <session>` | Background worker digest of another session's recent work, decisions, and uncommitted state without bloating your active context window. |
| **[`session-search`](skills/session-search)** | `find the session...` | Deep-searches raw `.jsonl` session transcripts across all project subdirectories by session title (`/rename`) or topic via sub-agents. |
| **[`mcp-config`](skills/mcp-config)** | `troubleshoot mcp...` | Add, configure, and troubleshoot MCP servers — remote and local servers, auth headers, scopes, and diagnostic playbooks. |
| **[`env-sync`](skills/env-sync)** | `/env-sync` | Compare and sync environment variables between `.env.local` and Vercel (production/preview). Repo-agnostic, masks values, and never deletes. |
| **[`visual-qa`](skills/visual-qa)** | `/visual-qa` | Screenshot-driven feedback loop (via Firefox / DevTools) to verify UI actually looks right before committing. |
| **[`vercel-troubleshooting`](skills/vercel-troubleshooting)** | `vercel build error...` | Playbook for common Vercel build failures in Next.js apps: module resolution, type safety, and configuration pitfalls. |
| **[`nextjs-ui`](skills/nextjs-ui)** | `nextjs layout...` | Layout architecture, responsive patterns, and color-system conventions for Next.js + React 19 + Tailwind v4 + shadcn/ui. |

---

## 🎯 Key Design Principles

1. **Model Agnostic & Multi-CLI**: Skills referencing external CLIs (`codex`, `agy`, `grok`) degrade gracefully if those binaries aren't installed or authed.
2. **Context Efficiency**: Heavy transcript reading and deep searches are offloaded to background sub-agents so your primary conversation context stays lightweight and sharp.
3. **Scrubbed & Portable**: All skills are scrubbed of machine-specific paths, private tokens, and internal project names so they run out of the box on any system.

---

## 📄 License

Distributed under the [MIT License](LICENSE).
