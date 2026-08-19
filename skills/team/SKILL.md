---
name: team
description: Run one unit of work through the multi-model implement→verify→fix→commit loop, in one of three staffing modes — Mode A (full credit: Claude leads work, external model reviews), Mode B (shared: external model leads work pulling in helpers, Opus reviews periodically), or Mode C (delegated: Opus orchestrates while external model does work). Sonnet never leads or orchestrates in any mode. Use when executing tickets from a plan or when the user says "run the team on TICK-123" / "run the loop on X". Pick the mode with `/team a|b|c <work>`; bare `/team <work>` uses default C.
---

# /team — one unit of work, many models, one committed diff

The orchestrator ORCHESTRATES — it writes briefs, verifies findings and decides. What it never does is review its own team's diff. How much of the actual work it hands out depends on the staffing mode.

## Three modes — pick one at the START of the run and say which

The loop below never changes. What changes is how much of the work Claude does itself. Mode A is Claude doing nearly everything; Mode C is Claude orchestrating while external models do the work.

> **Sonnet never leads and never orchestrates — in any mode.** It is a helper seat: dispatched for a bounded piece by whoever is leading, never handed the run. Orchestration is Fable or Opus; the work lead is Opus or an external frontier model depending on mode.

### Mode A — Full credit (quota healthy)

| Seat | Who |
|---|---|
| Orchestrate | **Opus** |
| Investigate | Claude — Sonnet as a helper, Opus where the task warrants |
| Implement / fix | **Claude (Opus)** |
| Review | **External model panel** (e.g. GPT-5.6 / Azure / Grok) |

Everything is Claude except review. That single outside reviewer is not a cost measure — it is the cross-review rule: Claude wrote the diff, so Claude does not review it. One genuinely different model family beats two Claude opinions.

### Mode B — Shared (middle tier)

| Seat | Who |
|---|---|
| Orchestrate | Opus |
| Investigate / implement | **External frontier model leads**, pulling in Sonnet helpers as needed |
| Review | External reviewer panel, with **Opus reviewing periodically** — judgment diffs, or findings nobody can settle |

The external model carries the work and decides what help it needs. Claude stays available — Sonnet as a second pair of hands, Opus dipping into review periodically rather than every round.

### Mode C — Delegated (conserve)

| Seat | Who |
|---|---|
| Orchestrate | **Opus at high effort** — thinking hard about the brief, not doing the work |
| Investigate / implement / fix | **External frontier models** (e.g. GPT-5.6 / Gemini) |
| Review | Cross-model review panel |
| Helpers | The odd Sonnet agent where it genuinely earns its place |

The bet: a strong orchestrator writing precise briefs beats a weaker one dispatching sloppily, and Opus at high effort costs far less than Opus implementing. Sonnet helpers are allowed — **but they are the orchestrator's explicit call, announced with a reason, never a subagent deciding for itself that it should just do the work.**

> If you are a dispatched subagent and you believe you should do heavy work yourself rather than shelling out, you may not. Say so and STOP.

### Choosing the mode

> **DEFAULT MODE: C** — default to conserving quota.

1. **The user said so.** `/team a TICK-123`, `/team b TICK-123` or `/team c TICK-123`. An explicit letter always wins.
2. **The work forces it.** Irreversible judgment code (schema, migration, auth, money) pulls the implement seat to Opus even in Mode C. Stay in the declared mode for everything else in the run.
3. **The default above.**

**Always state the mode in your first line of output**, e.g. `Mode C — Opus orchestrating, implement on GPT-5.6, review on Gemini/Azure.`

**And repeat it above EVERY status table, lane table or recap you show during the run.** The question "what are we burning right now" should never require asking.

**Switching mid-run:** finish the current round first — a half-reviewed diff is worse than either mode. Then announce the switch and carry on from the next step.

## The loop

```
0. SETUP     worktree off the repo's development branch
1. IMPLEMENT implementer ladder builds from the ticket spec — uncommitted

   ┌─ 2.  REVIEW  full panel attacks the diff IN PARALLEL
   │  2.5 VERIFY  orchestrator confirms EACH finding against source before any fix spec
   │              exists. Confirmed → into the spec. Refuted → into an explicit
   │              "NOT findings, do not fix" list.
   │  3.  FIX     findings-as-spec → fresh dispatch to the SAME implementer
   └─ 4.  LOOP    re-review the fix delta. Clean → exit. Not clean → round n+1.

5. COMMIT    main loop commits in the worktree (never pushes without user approval)
```

Exit conditions, in priority order:
1. **Clean round** — no finding survives VERIFY.
2. **Round 4 reached** — stop and hand back to the user with outstanding findings. Four rounds without convergence means the spec is wrong, not the code.
3. **Thrash detected** — the same finding reappears after a fix claimed to address it. Stop immediately and escalate.

## The VERIFY gate (step 2.5)

**An unverified finding costs more than a missed one.** A fix applied to working code is a brand new bug in a diff everyone now believes is reviewed. A missed finding merely survives to the next round.

Nothing goes from a reviewer's mouth into a fix spec without passing through here:

1. Open the actual source and confirm the claim. Not the diff — the file.
2. Length-check any cited line (`wc -l`). A line number past the file's end is a fabrication tell (common when reviewers read diff hunk offsets as file line numbers).
3. Sort into **confirmed** or **refuted**.
4. Pass the refuted list to the implementer explicitly as *"NOT findings, do not fix"*.

**Red-test-first, for findings claiming wrong runtime behaviour:**
1. Write the test against CURRENT code;
2. Run it and confirm it **FAILS**;
3. Only then apply the fix;
4. Re-run to verify green.

Later rounds re-review **only the fix delta**, not the whole diff — pipe `git diff HEAD~1` or the uncommitted delta.

## Reviewer rules
- **Pipe the diff INTO the prompt** (`git diff` embedded). NEVER ask a reviewer to explore the repo manually.
- **Length-check cited line numbers** — if a reviewer cites line 450 in a 200-line file, it's hallucinated/diff-offset noise.
- **A downed reviewer lane MUST appear in the round's verdict.** Never proceed silently on one voice.
- 2+ reviewers agreeing on a finding = strong signal, but it still passes through VERIFY before reaching a fix spec.

## Verification floor (every round, regardless of model)

`git diff --stat` + read the diff vs spec, then run repo checks (linter + typecheck script if available).

⚠️ **Always use the repo's own scripts (e.g. `npm run type-check`), not raw commands.** Repos often wrap tools with necessary flags or memory limits. Always verify linter/typecheck scripts run clean before opening a PR.
