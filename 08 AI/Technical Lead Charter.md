# 🧠 AI as Technical Lead — Charter

How AI (Claude Code) is used on TechEngine. The role is **technical lead**, not
autocomplete. Highest leverage is better architecture decisions, not faster
typing.

## Use AI for
- Architecture reviews and trade-off analysis
- Rendering / graphics design discussions
- ECS and systems design
- Feature decomposition (Epic → Story → Task)
- Code review of finished work
- Research summaries and technique evaluation

## Avoid
- Using AI mainly to generate boilerplate.
- Accepting designs without understanding the trade-offs.
- Skipping the ADR when AI proposes a load-bearing decision.

## Cadence
Anchored to the real weekly rhythm on the [[Dashboard]] — **not** a daily standup.

- **Sprint boundary (every 2nd weekend)** — retro + planning + architecture discussion.
- **The other weekend** — weekly review; refine tasks.
- **Deep days (Mon / Thu + one weekend day)** — implementation; call AI to design first and
  review after. Light/relaxed days are for docs, ADR drafting, and reading.

## Rules of engagement
- AI should **push back** on a rewrite unless evidence justifies it.
- Decisions that stick get an [[ADR Index|ADR]] — AI drafts, you accept.
- Ground every recommendation in the actual repo, not generic advice.

## As scrum master (planning & ceremonies)

On **process** — sprint planning, backlog grooming, retro, demo/planning — Claude is a
**co-driver, equal to Miguel**, not a proposer awaiting sign-off:

- **Co-create the plan**: build the Epic → Story → Task breakdown *together* — Claude
  drafts and challenges, Miguel decides scope. Tasks sized to one 2–6h session with a
  clear done-condition.
- **Run the ceremonies**: `/sprint-plan` (every 2nd weekend — absorbs that weekend's review,
  never both), `/weekly-review` (the other weekend);
  keep [[Sprint Board]], [[Roadmap]], and [[Dashboard]] in sync.
- **Guard capacity & sustainability**: size to the real weekly rhythm; call over-scope
  and burnout risk out loud.
- **Surface impediments** early; log blockers on the Dashboard.

Facilitation, not implementation — this hat never becomes "Claude writes the engine."

## The autonomous lane (2026-08-30)

There is now **one narrow exception** to "Claude does not implement", and it is deliberately
written here rather than buried, because it is the only place this charter bends.

In an **unattended weekday cloud routine**, Claude works cards that pass the artifact gate's
§ *The 🤖 Auto gate*: research, freshness checks, CI diagnosis, mechanical sweeps, test
scaffolding, and **small well-scoped bug fixes**. It builds and tests them on Linux, opens a
PR, and stops. Full model in [[Autonomous Lane — Design]].

What did **not** change, and what keeps the exception narrow:

- **Every decision is still Miguel's.** A card the gate routes to an ADR or a design note is
  disqualified by question 1, so the lane can never author a decision.
- **Nothing merges itself.** The lane opens a PR. Miguel reviews and merges.
- **Nothing on the critical path is Auto.** The lane is never a dependency.
- **The attended lane is unchanged.** In a session with Miguel present, Claude still advises
  and reviews, and still does not compile.

The honest read: this trades a slice of implementation ownership for the weekday hours that
were otherwise dead. If the review load ever stops feeling worth it, disabling one routine
reverses the whole thing.

See [[Working with Claude — Operating Guide]] for the day-to-day workflow. Machine-facing
rules live in the repo-root `CLAUDE.md`.
