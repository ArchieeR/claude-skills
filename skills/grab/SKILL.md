---
name: grab
description: Grab a digest of another Claude Code session's recent activity via a Sonnet worker reading its .jsonl transcript locally — decisions, built-vs-uncommitted, open questions, pushed-vs-local. Use when the user says "/grab <session topic/name>", "grab context from the X session", "what did the X session do/decide", "get me up to speed on the other session". Lighter than /handoff (no push, digest not transcript), deeper than /peek (full recent-activity digest, not a glance).
---

# Grab — cross-session context digest

Pull a structured digest of ANOTHER Claude Code session's recent work by dispatching a **Sonnet worker** to read its `.jsonl` transcript. Battle-tested pattern (Jul 2026: onboarding, UPE, ad-canvas grabs — all landed accurate digests on first run when this method was followed).

## When to use which tool
- **/grab** — "what did session X do/decide?" → 5-section digest into current context.
- **/handoff** — move a *transcript* between Claude ⇄ Codex (push/pull, message-level).
- **/peek** — quick glance at another live terminal's last few turns.
- **/session-search** — you don't know WHICH session; search by topic across all projects first, then /grab it.

## Method (give this to the worker verbatim, filled in)

Dispatch ONE `general-purpose` agent, `model: sonnet`, background ok. The prompt MUST include all of these elements — each one exists because its absence broke a run:

1. **"READ-ONLY. Do the work YOURSELF with Bash (ls/grep/tail/python3). Do NOT delegate to another agent. Your FINAL MESSAGE must BE the digest, not a status update."** (A worker once spawned a sub-agent and returned nothing.)
2. **Where:** `~/.claude/projects/<cwd-slug>/*.jsonl` (cwd-slug = the project dir with `/`→`-`, e.g. `-Users-you-code-acme-repos`). If the target session ran in a different cwd, check sibling slugs under `~/.claude/projects/`.
3. **⚠️ Files are HUGE (tens of MB). NEVER read one whole.** Procedure:
   - `ls -lt` the .jsonl files; **EXCLUDE the requesting session's own id** (pass it explicitly).
   - Rank candidates by `grep -c` hits for 5–10 topic **markers** (component names, ticket ids, branch names, distinctive phrases — the caller supplies these; distinctive code identifiers beat English words).
   - On the best 1–2 files, extract ONLY the recent tail: `tail -c 2000000 <file>` piped through `python3`/`jq` to pull message-text fields, or grep with context. Focus on the last day of activity.
4. **The 5 sections** (adapt names to the topic, keep the shape):
   1. **Decisions made** — what was settled; locked vs still-draft.
   2. **What was built / proven** — with file paths; verified how?
   3. **Open items / questions** flagged for the human, blockers.
   4. **Gotchas & learnings** — things the next session must not re-derive.
   5. **Pushed vs local** — branch/worktree, committed vs uncommitted vs unpushed; is anything local-only/ungit'd? (This section has caught un-pushed work + ungit'd spec files repeatedly — never skip it.)
5. **"Quote sparingly. If you can't find a clear matching session, report what you DID find (session list + top marker counts per file) rather than guessing."**

## After the digest returns
- Save durable findings to memory / Linear per the usual rules (decisions → project notes; at-risk uncommitted work → flag to the user).
- If the worker returns a status update instead of the digest, `SendMessage` it: "Do the work yourself, final message must BE the digest" — this resumes it; don't respawn.

## Notes
- Scratchpads (`/private/tmp/claude-501/<slug>/<session-id>/scratchpad`) are per-session but ephemeral — wrong source for context; the jsonl transcript is canonical. Only peek at a scratchpad for named artifacts the transcript references.
- Sonnet is the right worker model (investigation lane); never use Fable subagents.
- Typical cost: ~60–130k worker tokens, 3–6 min.
