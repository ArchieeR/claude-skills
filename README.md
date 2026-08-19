# 🛠️ claude-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills Count](https://img.shields.io/badge/Active%20Skills-14-blue.svg)](https://github.com/ArchieeR/claude-skills)
[![Compatibility](https://img.shields.io/badge/Compatible%20With-Claude%20Code%20%7C%20Goose%20%7C%20Berd-orange.svg)](https://github.com/ArchieeR/claude-skills)

A curated collection of 14 production-grade [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for **Claude Code**, **Goose**, and **Berd**.

Designed for **context engineering & multi-agent orchestration** — fanning out multi-model panels, porting context across AI CLIs, managing system health, and keeping human judgment at high leverage.

---

## 🚀 Quick Install

### Option A: Install All Skills

Clone the repository and copy the skills directly into your global `~/.claude/skills/` directory:

```bash
git clone https://github.com/ArchieeR/claude-skills.git
mkdir -p ~/.claude/skills
cp -R claude-skills/skills/* ~/.claude/skills/
```

### Option B: Symlink Individual Skills

Symlink specific skills so a simple `git pull` keeps them updated automatically:

```bash
git clone https://github.com/ArchieeR/claude-skills.git ~/claude-skills
mkdir -p ~/.claude/skills

# Example: Symlink handoff and ask
ln -s ~/claude-skills/skills/handoff ~/.claude/skills/handoff
ln -s ~/claude-skills/skills/ask ~/.claude/skills/ask
```

---

## 🧰 The 14 Active Skills

### 🧠 Focus & Output Formatting

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
| **[`i-have-adhd`](skills/i-have-adhd)** | `/i-have-adhd` | Shapes model output specifically for ADHD focus: leads with immediate action, numbers multi-step work, suppresses tangents, and provides exact time estimates. |

### ⚔️ Decisions & Multi-Model Orchestration

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
| **[`team`](skills/team)** | `/team [a\|b\|c] <task>` | Multi-model implement → verify → fix → commit loop (Modes A, B, C) with strict verification gates to prevent fabricated findings from burning fix cycles. |
| **[`prd-interview`](skills/prd-interview)** | `/prd-interview`, `/prd` | Systematic product discovery interview for new features. Maps uncertainty spaces, locks defaults, and interviews via interactive choices to generate a clean decision ledger. |
| **[`counsel`](skills/counsel)** | `/counsel <question>` | Fires parallel LLM panels (Codex / Azure GPT, Gemini, Grok) on hard decisions and synthesises findings into an agree/disagree table + net recommendation. |
| **[`ask`](skills/ask)** | `/ask` | Distils sprawling context and fat agent reports into structured, actionable choices via interactive questions — separating self-resolvable items from genuine forks. |
| **[`recap`](skills/recap)** | `/recap`, `/table` | Dense table-format recap of the current session: work done, status, decisions made, and open follow-ups. |

### 🔄 Session Interop & Context Portability

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
| **[`handoff`](skills/handoff)** | `/handoff` | Full bidirectional context bridge between Claude Code and Codex CLI — pull clean transcripts or push logic into new or resumed sessions. |
| **[`grab`](skills/grab)** | `/grab <session>` | Background worker digest of another session's recent work, decisions, and uncommitted state without bloating your active context window. |
| **[`session-search`](skills/session-search)** | `find the session...` | Deep-searches raw `.jsonl` session transcripts across all project subdirectories by session title (`/rename`) or topic via sub-agents. |

### 🛠️ Dev Workflow & Infrastructure

| Skill | Trigger / Command | Description |
| :--- | :--- | :--- |
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
