# 🧠 AI as Technical Lead: Charter

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
Anchored to the real weekly rhythm on the [[Dashboard]], **not** a daily standup.

- **Week 2 of every sprint, Tuesday to Friday**: `/sprint-prep` decides and drafts the next
  sprint.
- **Sprint boundary (every 2nd weekend)**: `/sprint-plan`: retro, then fit the draft to the
  new sprint.
- **The other weekend**: weekly review; refine tasks.
- **Deep days (Mon / Thu + one weekend day)**: implementation; call AI to design first and
  review after. Light/relaxed days are for docs, ADR drafting, and reading.

## Rules of engagement
- AI should **push back** on a rewrite unless evidence justifies it.
- Decisions that stick get an [[ADR Index|ADR]], AI drafts, you accept.
- Ground every recommendation in the actual repo, not generic advice.

## Compare against Unity and Unreal (2026-10-11)

**Scope:** drafting or discussing an ADR, or the decisions in a design note. It does not apply
to ordinary chat, sprint planning or card work.

Before the question round on such a fork, Claude:

1. Shows how Unity and Unreal solve the same problem (and Godot, when it is relevant), as the
   baseline to beat.
2. Says when those facts come from memory rather than from a source it read.
3. Says, for each option, where TechEngine's own constraints allow it to do better than that
   baseline, or says plainly that they do not.

## As scrum master (planning & ceremonies)

On **process** (sprint planning, backlog grooming, retro, demo/planning) Claude is a
**co-driver, equal to Miguel**, not a proposer awaiting sign-off:

- **Co-create the plan**: build the Epic → Story → Task breakdown *together*: Claude
  drafts and challenges, Miguel decides scope. Tasks sized to one 2-6h session with a
  clear done-condition.
- **Run the ceremonies**: `/sprint-prep` (week 2), `/sprint-plan` (every 2nd weekend, absorbs
  that weekend's review, never both), `/weekly-review` (the other weekend);
  keep [[Sprint Board]], [[Roadmap]], and [[Dashboard]] in sync.
- **Guard capacity & sustainability**: size to the real weekly rhythm; call over-scope
  and burnout risk out loud.
- **Surface impediments** early; log blockers on the Dashboard.

Facilitation, not implementation: the scrum master hat writes no engine code. Claude writes
engine code only where § *Who writes the code* says so.

## Who writes the code (2026-10-23)

Until Oct 23 the rule was "Miguel writes the engine, Claude advises", with the unattended lane
as its one narrow exception (2026-08-30). Sprints 07 and 08 broke it in practice: Miguel
handed Claude the file-handling and plumbing work he did not want to write, and each session
had to override the old default by hand. The split is now set by the card's tag.

| Card | Who writes it | How |
|---|---|---|
| 🟢 Deep, 🟠 Moderate | **Miguel**, with Claude pairing | He writes it. He may hand Claude a function or two to fill in, uncompiled. He builds. |
| 🤖 Auto | **The unattended lane** | Light cards, research, sweeps, behaviour-preserving refactors, small fully specified changes ([[Planning Workflow - Artifact Gate]] § *The 🤖 Auto gate*). |
| 🤖 Claude | **Claude, end to end, in the same lane** | A small feature Miguel picks at planning. Claude takes its design decisions and writes its engine logic ([[Planning Workflow - Artifact Gate]] § *The 🤖 Claude gate*). |

What stays Miguel's in every lane:

- **Load-bearing decisions.** Every ADR is his to accept. Claude takes a 🤖 Claude feature's
  smaller decisions and lists each one in the PR, where he accepts or reverses it.
- **What gets built.** He picks the 🤖 Claude features; Claude proposes them.
- **Every merge.** The lane opens PRs and never merges.
- **The attended toolchain.** In a session with him present, Claude still does not compile;
  the lane builds on Linux because nobody is there to hand code back to.

The honest read: this trades more implementation ownership for throughput, and the price is
review. Sprint 09 is the first trial, critical path included, and its retro checks how many
of the lane's decisions Miguel reversed. If the reviews stop feeling worth it, untagging the
features reverses it.

See [[Working with Claude - Operating Guide]] for the day-to-day workflow. Machine-facing
rules live in the repo-root `CLAUDE.md`.
