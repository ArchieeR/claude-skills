---
name: recap
description: Produce a concise table-format recap/overview of the current session — what was done, its status, decisions made, and open follow-ups. Works in ANY session type (coding, debugging, research, GTM, ops, planning). Use when the user types /recap, /table, or asks for "a table", "recap", "overview", "where are we", "catch me up", "summary of what we did".
---

# Recap

Produce a tight, scannable **table recap of the current session** so the user sees at a glance what happened, what state each thing is in, and what's left. Adapt to the session type — don't force irrelevant rows. This is a *glance*, not a report.

## Output format

Lead with a **one-line TL;DR** (≤1 sentence). Then up to three tables, omitting any that would be empty:

### 1. What happened  (always)
| # | Item | What happened | Status |
|---|------|---------------|--------|

- **Status** = emoji + word: ✅ done · 🟡 in progress · ⏳ waiting/running · 🔴 blocked/failed · 💡 noted/idea
- One row per meaningful unit of work, most-important first. Cells ≤ ~12 words.
- Anchor with concrete refs where useful: `file:line`, commit SHA, ticket ID, run ID, URL.

### 2. Decisions  (only if any were made)
| Decision | Choice | Why (≤8 words) |
|----------|--------|----------------|

### 3. Open / next  (only if anything remains)
| Item | Owner | Note |
|------|-------|------|

- **Owner** = who's on the hook: User / Claude / CI / external.

## Rules
- **Faithful, not flattering.** Include blocked, failed, skipped, and uncertain items — never hide them. If something's unverified, say so in the cell ("logic-proven, not run live").
- Pull from the **actual session**, not assumptions or memory.
- **Dense.** No prose around the tables beyond the TL;DR. No restating cells in sentences.
- Trivial/short session → a single small table is fine; don't pad.
- End with exactly one line: **"Want detail on any row, or should I action any of the open items?"**

## Notes
- This is a presentation skill — it does not change code or state, only summarises. If the user wants follow-ups actioned, that's a separate step they trigger.
- If invoked mid-task, recap covers work-so-far and marks the live task 🟡/⏳.
