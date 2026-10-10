---
type: retrospective
sprint: Sprint 07
date: 2026-10-11
---

# Retrospective: Sprint 07

## Outcome

All 28 cards closed: **15 Dev, 3 Design, 1 Bug and 9 Process**, plus S7-P8, which was dropped.
Process was 32% of the sprint, about a third, and three of those nine ran on the Auto lane. Six
cards arrived mid-sprint: Story F's four Auto cards, S7-P9 and S7-P10. S7-P9 was really a bug
(a workflow file that did not parse) that was carded as Process. M5 closed on Oct 9. The
delivery record is in [[2026-09 Sprint 07 - Scene Events and Input Boundary]] § *Sprint review*.

## What went well

- The event and input stories each opened with a Design card on day 1 (S7-D1, S7-D2). Both
  stories then shipped in full; Story B's five Deep cards merged on Sep 27.
- The lane's stop rule worked: S7-B1 stopped on Sep 30 instead of inventing a test policy, and
  the policy Miguel set on Oct 1 shipped the next day.

## What wasted time

- **Nine of the ten Story B and C Dev cards (S7-T3 to S7-T12) settled at least one decision at
  `/card-start` that no artifact had made.** The Done entries name each one. This is the
  baseline the decide-first trial is measured against.
- **The Oct 3-4 weekly review did not run, and neither did its weekday fallback.** The Sep 28
  sizing question ("the estimates assume Miguel writes everything") was deferred to it and
  was never answered. Sprint 08 now sizes on that assumption explicitly.
- **Fri Oct 9 carried five attended merges** (S7-T2, S7-P4, S7-P6, S7-D3, S7-P1). S7-D3 grew
  from a 4-6h policy card into a migration of every module on a day meant to be moderate.

## Process improvements

- Count the `/card-start` decisions per Dev card at the Sprint 08 retro, against the nine of
  ten above. That count decides whether the trial becomes the rule.
- When a mid-sprint ceremony is lost, its deferred questions go to the next boundary by name,
  so they are not lost with it.

## Decide-first trial: first half

The trial started on this boundary ([[Planning Workflow - Artifact Gate]] § *Trial from
Sprint 08*).

- **How long the board sat empty:** zero dev days. The last Sprint 07 card closed Fri Oct 9,
  and ADR-024 and ADR-025 were accepted on Oct 10, day 1 of Sprint 08.
- **What it cost:** week 1's weekend deep day (2-3 🟢) went to the two ADRs, the
  [[Resources - Design]] hub and a 63-commit reconciliation. Sprint 05 paid the same cost.
- **What deciding first did not decide:** planning still met four open questions. Three were
  already named in the hub (the second resource type, how a component field declares a
  reference, how the bake runs before T2). The fourth was new: how a dev scene gets written
  before T1 can save one. Three were settled in planning (the editor creates the dev scene at startup, S8-T13), and one
  became S8-D1.
- **Whether cards cut against accepted ADRs hold up better** than cards cut by a mid-sprint
  Design task cannot be known until Sprint 08 has run. That half belongs to the Sprint 08 retro.

## How AI helped

Claude wrote large parts of S7-T4, S7-T7, S7-T8, S7-T2 and the S7-D3 migration at Miguel's
request, which is why the Dev cards closed faster than their estimates. The rework it caused:
S7-T4's rewrite missed two graphs and broke the MSVC build; S7-T7's test rewrite broke the
CLion run configuration; S7-T11's review trusted an adaptation and missed two `WindowTests`
cases; S7-T12's scaffold stub returned the wrong kind; S7-D3's grep dropped six call sites; and
#95's mechanical dash replacement broke `ci-docs.yml`, which became S7-P9.

## 🤖 Auto lane

The routine ran all sprint (folders `autoruns/2026-09-27` to `autoruns/2026-10-09`), although
the Dashboard and the routine note still said it was paused; both are corrected.

- **Cards closed: 8** (S7-T1, S7-P2, S7-P3, S7-P7, S7-B1, S7-T13, S7-T14, S7-T15).
- **PRs: 12 opened, 12 merged**: seven card PRs (#96, #103, #106, #108, #113, #114, #115) and
  five sweeps (#107, #116, #118, #119, #120). S7-P7 was report-only.
- **Stopped runs: one.** Sep 30, S7-B1 was mis-scoped (14 tests asserted on Info records).
- **Papers: 20 screened** (Oct 6-9), from search results only, because the sandbox network
  blocks paper hosts. 23 wait in *MIGUEL REVIEW*.

| Module | Sweep | Source lines | Test lines | Net removed |
|---|---|---|---|---|
| `engine/base` | Sep 28, report only | 1489 | 1237 | 0 |
| `engine/base` | Oct 8, #119 | 1489 → 1463 | 1250 → 1236 | 40 |
| `engine/platform` | Sep 29, #107 | 1567 | 1661 | 15 |
| `engine/platform` | Oct 9, #120 | 1583 → 1569 | 1802 → 1783 | 33 |
| `engine/core` | Oct 1, report only, 8 Backlog entries | 5118 | 6251 | 0 |
| `engine/client` | Oct 5, report only, 1 entry | 813 | 507 | 0 |
| `engine/app` | Oct 6, #116 | 865 | 1170 → 1154 | 25 |
| `apps/` | Oct 7, #118 | 964 → 962 | 510 → 507 | 3 |

Between its two sweeps, `engine/platform` grew by 16 source lines and 141 test lines (the input
cards). Net removed is deletions minus insertions from each PR's diff.

## Sustainability

Miguel lost the Oct 3-4 weekend and compressed the final part of the sprint into the last
week; he reports ending it feeling good. A rib injury keeps him off karting for this weekend
and the next, and he chose to use those days for the engine. Sprint 08's P2 cache cards are
the stretch that absorbs them, so dropping them never costs the goal.

## Carry-over to next sprint

- No card carries; every Sprint 07 card closed.
- The routine's cron needs re-pointing for the Oct 25 clock change
  ([[Autonomous Lane - Routine Prompt]] § *Routine configuration*). That is Sprint 09.
