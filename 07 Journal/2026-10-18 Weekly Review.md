---
type: weekly-review
date: 2026-10-18
---

# Weekly Review: 2026-10-18

Sprint 08, day 9 of 14. Covers Oct 11 to Oct 18; [[Sprint Board]] holds every card's record.

## Completed this week

- Stories A to C closed on Oct 11 (S8-T1 to S8-T5, S8-T14; #126 to #129): the per-kind blob
  header, the ranged read, scene assets, `.tepack` files and the boot record.
- Story D closed on Oct 12 (S8-T6, S8-T7; #131, #132). The editor indexes its assets by id and
  exports the client target. The export was rescoped mid-card to one export target per `Role`.
- Story E closed on Oct 15 (S8-T8, S8-T13, S8-T9; #134, #138, #139). **The sprint goal is
  met:** Miguel's windowed run loaded the exported startup scene in `runtime.exe`.
- Story G, the P2 stretch, closed today (S8-T10, S8-T11; #141, #142). The resource cache core
  and its loads on the `JobSystem` are built, but no product code requests a resource yet.
- The Auto lane closed nine cards: S8-P1 to S8-P6, S8-T12 and S8-T15 to S8-T17. Every code PR
  it opened was merged.

## In progress

- Story F is the sprint's last attended work. S8-D1 decides how a component field declares a
  reference, and it starts from S8-P4's brief in [[2026-10-12 14-09 Auto Run]]. S8-D2 then cuts
  Sprint 09's cards before the Oct 24-25 boundary.
- S8-P7 and S8-P8 are open in the Auto lane.

## Blockers

- None block the sprint.
- **S8-P8 has a date.** The routine's cron must be re-pointed before the Oct 25 clock change,
  and only Miguel can paste the prompt and change the cron, so its report needs a reply this week.

## Artifact drift

Checked against fetched `origin/master` at `39943f19`, the 17 engine commits since `82d7a11c`.
The as-built sections of [[Resources - Design]] were read against `ResourceCache.hpp`,
`SimulationThread.cpp`, `App.hpp`, `App.cpp`, `RuntimeApp.cpp` and the runtime's `main.cpp`.
[[Project - Design]], [[File Access - Design]], [[Serialization - Design]] and
[[Scene - Design]] were spot-checked on the claims this week's cards added. The citation
checker found no drift in v2 code. No build or test was run.

- **Fixed:** [[Simulation Thread - Design]] said `simulationShutdown()` runs after the load
  batches settle; since S8-T11 the cache shuts down right *after* it. The startup-load row
  also read as if the load already ran on the `JobSystem`; it now says no override uses the
  cache yet.
- **Fixed:** the sprint note still showed S8-P2, S8-P3, S8-P4 and S8-P6 as open, although the
  board had closed them.
- **Amended:** ADR-024 §1 said to port `IResourceCache<T>` as the public API, while S8-T10 built
  one type-erased `ResourceCache` with typed members. Miguel kept the single cache, so §1 got a
  dated `decision` amendment and an inline marker.
- **Known and owned:** ADR-025 §7 says the runtime mounts `<exe dir>/assets`, while `main`
  passes `<exe dir>/Dev`. [[Resources - Design]] § *Open questions* gives it to T2.
- **Backlog:** seven triggers fired and are marked in place. Three citations were corrected:
  `ComponentRegistry::tagOf` moved to `:68`, and `Scene::setParent` and `unparent` moved after
  #127 added the last-child link.

## Objective for next week

S8-D1 settles the reference field shape, and S8-D2 cuts Sprint 09's cards against it before the
Oct 24-25 boundary.

## Sustainability

- The weekdays kept their shape: Tuesday was 🟡 (S8-T8), Wednesday was rest, and Friday had no
  attended card. Both weekends were worked because of the rib injury, so there has been no rest
  day for two weeks. Keep Friday light and protect one day of the Oct 24-25 weekend.
- **The pace came partly from Claude writing engine logic.** The board records that Claude wrote
  most of S8-T3, the pack reader and writer, much of S8-T5, the rewritten `exportTo`, the body of
  S8-T9's load and `ResourceCache`'s implementation. Each was at Miguel's request, but CLAUDE.md
  says Miguel writes the engine for mastery and ownership. The retro should decide whether that
  split is the new normal or something to pull back.
- No PR this sprint has a body or a review conversation, so the board entries are the only
  record of the calls made during each card.
