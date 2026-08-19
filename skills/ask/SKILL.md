---
name: ask
description: When there's too much on the table, stop talking and start asking. Distil sprawling context — especially fat sub-agent reports — into a small set of structured decisions, separating "you can just decide this" (actionable) from "this needs your judgement" (uncertainty), and surface them via the AskUserQuestion tool. Use when the user says "ask me questions", "break this down", "what do you need from me", "I'm overwhelmed", after agents return big reports, or any time accumulated open decisions need the user's call.
trigger: /ask, "ask me questions", "ask me qs", "break this down", "what do you need from me", "ask me these again", "distil this", "what do you need decided"
user_invocable: true
---

# /ask — Break the sprawl into decisions

When the user invokes this, they're telling you: *there's too much context floating and I need to make decisions, not read another essay.* Your job is to compress the open state into a small, structured set of questions and surface them through the **AskUserQuestion** tool — never as a wall of text.

This skill exists because of a specific operating model (see below): the user sits above **one manager agent** (you) that fans work out to many sub-agents across many projects. You hold the context; the user makes the calls. This skill is the interface between the two — it turns everything you're holding into a tight set of decisions.

## The core move

1. **Survey the open state.** Scan the recent conversation, every sub-agent report still unactioned, and any project/vault/code context in play, for everything unresolved: pending decisions, forks, blockers, things you flagged but never got a call on, recommendations awaiting a yes/no.

2. **Sort each item into one of three buckets:**
   - **Actionable** — a concrete choice with clear options. The user can just pick. ("Ship the fix now / batch it later / skip it.")
   - **Uncertainty** — genuinely open, needs the user's judgement or info you don't have. ("Which of these is the real priority?", "What's the intended behaviour here?")
   - **Self-resolvable** — you can take a sensible default and let the user redirect. **DON'T ask these.** Resolve and move on. The skill surfaces what genuinely needs the user, not every micro-decision.

3. **Prioritise ruthlessly.** Order by: (a) what's blocking other work, (b) highest leverage / biggest blast radius, (c) cheapest to answer. Drop the long tail.

4. **Ask via AskUserQuestion, in batches of up to 4.** The tool caps at 4 per call. Pick the top 4. If more remain, say so and ask the next batch after these are answered.

## Primary use cases

### 1. Distilling fat sub-agent reports
You've fanned work out to sub-agents (audits, investigations, implementations) and they return long reports — each ending in its own "Questions for you". **Do not relay the reports.** Instead:
- Extract every genuine decision/question across all returned reports
- Drop the ones you can self-resolve (take the default, note it)
- De-dupe overlapping questions from different agents
- Surface the top 4 as one AskUserQuestion batch
- The user should never have to read the raw agent output to make the call — your question + options carry the needed context.

### 2. The multi-project manager pattern
The user runs ONE session (you) as a manager across many projects, rather than a session per project. You dispatch and track sub-agents per workstream, journal findings to your task board, and the user makes cross-cutting calls. When invoked here, **gather open decisions across ALL active workstreams** — not just the one most recently discussed — and present them as a prioritised batch so the user can steer the whole portfolio from one place. Group/label by project (use the `header` chip) so it's clear which workstream each decision belongs to.

### 3. General "I'm overwhelmed / just ask me"
Any time the discussion has accumulated more open threads than the user can hold. Compress and ask.

## Rules for the questions

- **One decision per question.** Don't bundle two forks into one.
- **2–4 mutually-exclusive options each.** No "Other" — the tool adds it automatically.
- **Recommended option FIRST, labelled "(Recommended)"** when you have a clear lean, reason in its description.
- **Every option's description states the consequence/trade-off**, not just what it is. The user should be able to choose from descriptions alone.
- **`header`** (≤12 chars) = a tight chip label. In the multi-project case, make it the project/workstream name so the user sees which area each Q belongs to.
- **Previews** (single-select only) when the choice is a concrete artifact worth comparing — UI mockups, copy variants, reward tables, layouts. Skip for plain preference questions.
- **multiSelect** only when choices genuinely aren't exclusive.

## Context artifacts — pair the questions with a page when depth helps

Option descriptions carry ~2 sentences. When a decision genuinely needs more context than that, don't cram it into the questions and don't dump it as chat text — **publish a compact Artifact first, then ask**, with the one-sentence framing linking to it. An artifact with the current-state summary, wireframe sketches per option, what's already locked, and a recommendation per call — followed by a 4-question /ask batch that mirrors its sections. The user skims the page for depth, answers from the chips.

**Reach for a context artifact when:**
- The options are **visual/structural** (layouts, UI shells, flows) — sketch them as simple wireframes.
- The decision set rests on a **body of findings** (audit results, comparison tables, scoreboards) the user hasn't read.
- There are **more than ~2 decisions sharing one backdrop** (same feature, same audit, same plan) — one artifact serving the whole batch beats per-question cramming.
- The material has **reuse value past the answer** (QA checklist, findings ledger, decision record).

**Keep the contract:**
- Artifact = depth; questions = the decision. Every question must still be answerable from its option descriptions alone.
- Label sections/options in the artifact with the SAME ids/names as the question headers so page and chips cross-reference cleanly.
- Mark what's **already locked** in the artifact so the user sees you're not re-asking settled calls.
- Skip the artifact for plain preference/sequencing questions — a page for "merge now or after QA?" is overhead, not help.

## What NOT to do

- Don't precede the tool call with a long recap. One sentence of framing is plenty — the questions carry the context.
- Don't ask what you should just decide. If you'd be fine taking a default and being redirected, take the default and note it.
- Don't ask more than 4 at once. Batch.
- Don't ask "is the plan ready?" / "should I proceed?" — those are permission-seeking, not decisions. Ask real forks.
- Don't relay raw agent reports as the question context. Distil first.

## After the answers

- Act on the locked decisions immediately (or dispatch the work to sub-agents).
- If items remain, fire the next batch of up to 4.
- For anything the user explicitly parked, note it as parked — don't re-ask it next time.

## Shape of a good output

> "A few open calls — here are the ones that actually need you."
> [AskUserQuestion with 2–4 prioritised, mutually-exclusive, recommended-first questions]

And when the decisions deserve depth (visual options, audit-backed, shared backdrop):

> "Breakdown with wireframes + recommendations: <artifact link>. The four calls:"
> [AskUserQuestion whose headers mirror the artifact's sections]
