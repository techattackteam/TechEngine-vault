---
type: weekly-review
date: 2026-11-06
---

# Weekly Review: 2026-11-06

Sprint 10, day 7 of 14. Covers Oct 31 to Nov 6. Run on Friday, because the Nov 7-8 weekend is
Miguel's first karting race. [[Sprint Board]] holds every card's record.

## Completed this week

- Story A closed (S10-T1, S10-T2, S10-T8; #178, #182, #190). The hierarchy and inspector edit
  several entities at once, and an `AssetRef` field is set through a picker that loads first.
- Story B closed by the lane (S10-D1, S10-T3, S10-T4; #179, #181). File → Export writes the
  runtime beside its packs, and File → Run exports and then starts it. Miguel's windowed check
  passed, and one decision was reversed in review: Run exports first.
- Story C closed (S10-D2, S10-T10 to S10-T12, S10-D3; #183, #187, #189). Log sinks are objects
  whose removal waits, which fixed [[Known Issues]] D5 and D7. The console panel is built, and
  the Profiler panel moved to E11 by design.
- R1's first ADR is Accepted: [[ADR-028 - Render device seam and frame packets]] (S10-D4), on top
  of the lane's two paper reports (S10-P1, S10-P3).
- Story H started: the content pipeline's brief (S10-D8), [[Content Pipeline - Design]]'s model
  half (S10-D9, split into S10-D10), and assimp in the editor build (S10-T13, #192).
- S10-T5 and S10-T6 closed (#180, #188), and the lane swept `core`, the render thread tests and
  `AppTests` (#184, #185, #191). Every lane PR was merged, and none is open.
- Three of the six Definition of Done lines are met, and two more are half met.

## In progress

- Nothing is in progress. 14 cards are open: S10-T7, S10-T9, S10-D5, S10-D6, S10-D7, S10-D10,
  S10-B2 to S10-B4, S10-T14 to S10-T16, and the lane's S10-P2 and S10-P4.

## Blockers

- None block the sprint goal. E1 now waits only on its internal demo, S10-T7.
- S10-D10 waits on the lane's S10-P4 report, so the mesh's build cards cannot be cut before it.

## Artifact drift

Checked against fetched `origin/master` at `e59d77c`, the 15 engine commits since `4ba9f60`
(#178 to #192). Every design note these commits touch was edited after its commit. The claims
were read against the code for [[Logger - Design]] (delivery and ring locks), [[Resources -
Design]] (the Run button, `Process`, the scene read), [[Scene - Design]] (Local / World),
[[Content Pipeline - Design]] (assimp's importers and link) and the Decided rows of
[[Editor - Design]] and [[Logger - Design]]. `tools/check-vault-citations.py` found no break
that was not already there at `4ba9f60`. No build or test was run.

- **Fixed:** [[Resources - Design]] said the scene read has its own loop; since #184 it runs
  through the shared `visitReferences` walk.
- **Hub drift:** none. The Logger and Editor rows match ADR-011's and ADR-013's Nov 3
  amendments.
- **Backlog, fired this week:** the comma test names (#185 and #191 swept two test files and kept
  four comma names) and the test tiers (`win ASan`'s test step is now 4-6 minutes). Both are
  marked in place.
- **Backlog, corrected:** `registerComponent` moved to `ComponentRegistry.hpp:51`. The private
  plumbing entry counted three CI gates, but there are four, so its re-armed trigger now says
  "one gate more than those four".
- **Not corrected, because the entry has not fired:** the tree-walk entry's `SceneAsset.cpp`
  lines moved after #184 (`:33` is now `:42`, `:300` is now `:289`).

## Objective for next week

Close E1 with the internal demo (S10-T7), accept the materials ADR (S10-D7), and draft Sprint 11
in S10-D6. Suggested slots: S10-D7 on Mon Nov 9, S10-T7 on Tue Nov 10, S10-D10 on Thu Nov 12
(after S10-P4's report), and S10-D6 on Fri Nov 13, after S10-P2's brief from Mon Nov 9.

## Sustainability

- **The week broke the cadence on three days.** Sun Nov 1 was the planned rest day, and S10-T1
  merged that afternoon. Wednesday is the relaxed day, and S10-T10 merged at 14:50. Friday is one
  🟠 slot, and it closed five of Miguel's cards: S10-T12, S10-T8, S10-D4, S10-D9 and S10-T13.
- **The pace is now measured:** 13 of Miguel's cards in one week, against the nine sessions the
  sprint planned for two weeks. Sizing is not the problem. The days off are being spent.
- **The race weekend is the first weekend in a month with no engine work.** A race is not rest,
  so do not pull extra work into Monday to make up for it.
- **Nothing is cut now.** S10-T7, S10-D7, S10-D10 and S10-D6 come first in week 2. Whatever of
  S10-B2 to S10-B4, S10-T9, S10-D5 and Story H's three build cards is still open on Nov 13
  moves at the Nov 14-15 boundary, which the capacity note already allows (Miguel, Nov 6).
