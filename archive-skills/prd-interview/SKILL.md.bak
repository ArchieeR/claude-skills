---
name: prd-interview
description: Run a structured product-design discovery session for ONE feature/surface — map the design space, sort every dimension into locked / default / genuine-fork, then interview the user in themed AskUserQuestion rounds until the shape is decided, and close with a decision ledger ready to become a PRD/fat Linear ticket. Sibling of /ask — /ask distils accumulated open decisions across workstreams; /prd-interview systematically walks a NEW design's uncertainty space before anything is specced or built. Use when the user says "design session", "product design session", "PRD interview", "interview me about X", "let's design X together", or after mapping/research agents return and a feature direction needs locking.
trigger: /prd-interview, /prd, "design session", "product design session", "PRD interview", "interview me", "ask me questions about the design", "let's design this together"
user_invocable: true
---

# /prd-interview — Walk the design space, ask the forks, lock the shape

The user is the product founder; you hold the research (code maps, agent reports, Linear state, memory). This skill turns that asymmetry into a **structured interview**: you systematically enumerate what must be decided for the feature to be buildable, decide everything you can yourself, and bring only the genuine forks to the user — in themed rounds, via **AskUserQuestion**, never as an essay.

The output is not a conversation. It is a **decision ledger** that can be pasted into a PRD, a Linear project description, or a fat ticket.

## Difference from /ask

| | /ask | /prd-interview |
|---|---|---|
| Scope | Everything open across workstreams | ONE feature/surface being designed |
| Source | Accumulated unactioned decisions | A design space you enumerate deliberately |
| Order | Priority/blocking | Shape-defining first, details later |
| Ends with | Actions dispatched | Decision ledger → PRD/ticket material |

If the user is overwhelmed by open threads → /ask. If a new thing needs its shape decided → this.

## The process

### 1. Frame (one sentence, confirm by proceeding)
Name the feature, the target user, and the job-to-be-done in one line. If any of those three is itself unknown, that's Round 1's first question.

### 2. Build the uncertainty map (internal — do not dump it as text)
Enumerate the design dimensions. Standard sweep — prune what doesn't apply, add domain-specific ones:

- **Job & user** — who exactly, what moment, what does success look like for them
- **Scope cut** — what's v1 vs explicitly not-v1
- **Data model** — new primitives, ownership (org/brand/user), migration of old primitives
- **Core mechanic** — the one interaction that defines the feature (the thing users would describe to a friend)
- **Surfaces & entry points** — where it lives, what it replaces, how users reach it
- **Automation level** — what runs without the user (crons, re-flows, notifications) vs user-triggered
- **Generation/AI grounding** — what context feeds it, cost profile, quality gate
- **Monetisation/gating** — tier gates, trial pressure points, credit burn
- **Edge cases that change the architecture** (multi-brand, empty states, failure modes)
- **Sequencing & ship gate** — what's the smallest lovable slice, what must NOT ship early
- **Deprecations** — what old thing dies, and whether loudly or quietly

### 3. Sort every dimension into three buckets
- **LOCKED** — already decided (in memory, Linear, or earlier this session). List them in the ledger as settled; **never re-ask**. Re-asking settled calls burns trust in the whole interview.
- **DEFAULT** — you have a clear sensible answer; take it, note it in the ledger as "default taken — flag if wrong". Don't ask.
- **FORK** — genuinely open, changes the build, needs the founder. These become the interview.

The skill lives or dies on bucket discipline: a good session asks 6–12 forks total, not 30 dimensions.

### 4. Interview in themed rounds (AskUserQuestion, ≤4 per round)
Order rounds so early answers prune later questions:
1. **Shape round** — job, scope cut, core mechanic. (Answers here can invalidate half the map — always first.)
2. **Structure round** — data model, primitives, what old things migrate/die.
3. **Behaviour round** — surfaces, automation level, edge cases.
4. **Ship round** — sequencing, gates, monetisation hooks.

Rules per question (inherited from /ask, same bar):
- One decision per question; 2–4 mutually exclusive options; no "Other" (tool adds it).
- Recommended option FIRST, labelled "(Recommended)", with the reasoning in its description.
- Every option description states the **consequence/trade-off**, not just the label — choosable from descriptions alone.
- `header` chip = the dimension name (≤12 chars): "Core loop", "Data model", "V1 cut", "Kill pillars".
- Use previews when options are visual/structural (layout sketches, schema shapes, flow variants).
- multiSelect only for genuinely non-exclusive sets (e.g. "which platforms in the v1 group?").
- After each round, **one line** acknowledging the locks, then the next round. Answers that spawn new forks go into the next round, not an ever-growing queue — cap the whole interview at ~4 rounds; park the tail.

### 5. Context artifact — same contract as /ask
When the forks rest on a body of findings (agent maps, audits) or the options are visual/structural, publish/update a compact artifact FIRST and let the questions reference its section names. Artifact = depth; questions = the decision; every question still answerable from its options alone. Mark LOCKED items in the artifact so the user sees what's settled.

### 6. Close with the decision ledger
End the session with one compact block (and update the artifact if one exists):
- **Locked this session** — each fork + the chosen option (one line each)
- **Defaults taken** — what you decided solo (so the user can veto cheaply)
- **Parked** — explicitly deferred items, so no future session re-asks them
- **Next action** — what the ledger becomes: PRD artifact, Linear project description update, fat ticket set. Do NOT write to Linear without the user's go (one-writer rule); offer it.

## What NOT to do

- Don't re-ask anything LOCKED in memory/Linear/session — cite it as settled instead.
- Don't ask permission questions ("should I proceed?", "is this plan good?") — ask real forks.
- Don't front-load a recap essay. One framing sentence + artifact link, then the tool call.
- Don't let the interview sprawl past ~4 rounds — park the tail, ship the ledger.
- Don't ask about implementation detail the founder shouldn't care about (file names, function shapes) — that's yours.

## Shape of a good session

> "Design session on [feature]. Map: [artifact link]. X calls are already locked from earlier — starting with the 4 that define the shape."
> [Round 1: AskUserQuestion — shape forks]
> "Locked: … Three structure calls next."
> [Round 2 … Round N]
> [Decision ledger + offer to write it into Linear/PRD]
