---
type: retrospective
sprint: Sprint 09
date: 2026-10-31
---

# Retrospective: Sprint 09

## Outcome

All 30 cards closed: **21 Dev, 6 Design, 0 Bug and 3 Process**. Process was 10% of the sprint,
and all three were report-only lane cards. M6's code was complete on Oct 26 (day 3, S9-T7), and
Miguel's windowed run on Oct 31 closed M6. The whole Story D stretch shipped, plus three cards
added mid-sprint (S9-T20, S9-T21, S9-D6), so every T1 Must of E1 is built. The sprint closed on
day 8, a week early, so that it lines up with Miguel's day-job sprints. The delivery record is
[[2026-10 Sprint 09 - Close M6]] § *Sprint review*.

## What went well

- **Decide first unblocked the build fast.** The editor brief, ADR-027 and the design note were
  done by day 3 (S9-D1 to S9-D3), and the nine T1 cards they cut all shipped.
- **The first 🤖 Claude feature worked.** Story B shipped in four PRs (#155, #158, #160, #161)
  in three days, and Miguel reversed 1 of its 24 decisions: `MeshReference` became `MeshRenderer`
  (S9-T5). It stopped on no card.
- **Pairing changed the pace.** Miguel reports that a 🟢 4-6h card now takes him 1-2h. Story D's
  twelve cards closed between Oct 26 and Oct 31.
- **The prep held.** All 15 of S9-D5's drafts survived planning unchanged; `/product-review` added
  one.

## What wasted time

- **Scope grew at `/card-start` on almost every Story D card.** S9-T16, S9-T17, S9-T18, S9-T19,
  S9-T20, S9-D4 and S9-D6 each say "wider than the card, by Miguel's choice". S9-T16 and S9-T17
  each ran a whole day, and S9-D4 a whole evening, so the weights stopped measuring the work.
- **Six PRs used `[skip-coverage]`** (#171, #173 to #177), because ImGui drawing has no unit
  test. The gate taught nothing for a week; Sprint 10 carries the fix.
- **Claims from memory were wrong.** Claude's Unity and Unreal baselines were wrong twice in
  S9-D4, the persistent-id claim in S9-D3 missed ADR-007 §1, and one of S9-D6's four rules has no
  official source.
- **`projects/dev/Startup.tescene` rode along in three PRs in a row** (#174 to #176), because the
  editor rewrites it on every run.

## Process improvements

- **Re-weight a card at `/card-start` when its clause widens**, so the board shows the real size.
- **Drop `projects/dev/Startup.tescene` from a PR** unless the card changed the scene on purpose;
  `/card-review` checks `git status` for it.
- **Check current docs before any engine comparison**, not after Miguel asks.

## How AI helped

Claude wrote much of Story D's panel code at Miguel's request (S9-T16, S9-T17, S9-T20), which is
most of the pace gain. Rework came from two use-after-free bugs in tests Claude wrote, caught only
by ASan and TSan (S9-T17); an IDE re-wrap that CI's clang-format rejected (S9-T21); a scaffold that
left out ImGui's texture callback (S9-T11); and a vault commit Claude made without being asked
(`7fc21ef`, S9-T11).

## 🤖 Auto lane

Sixteen fires between Oct 24 and Oct 31: ten weekday cron fires and six run by hand on weekends
([[07 Journal]] → `autoruns/2026-10-24` to `2026-10-31`).

- **Cards closed:** S9-T4 to S9-T7 (🤖 Claude); S9-T8, S9-T9, S9-T10 and S9-T14 (🤖 Auto, PRs);
  S9-P1, S9-P2 and S9-P3 (report-only).
- **PRs:** ten (#155, #158, #160, #161, #164, #165, #168, #169, #170, #172), all merged.
- **Sweeps:** `base` (#170): source 1521 before and after, tests 1315 to 1313; at its Oct 8 sweep
  it was 1463 and 1236. `platform` (#172): source 1818 to 1812, tests 2062 to 2051; at its Oct 9
  sweep it was 1569 and 1783. `base` had no new finding; `platform` filed one leftovers entry.
- **Papers:** none screened, because [[Research]]'s *TO VALIDATE* column is empty.
- **Runs that produced no card:** Oct 29 09:08 and Oct 30 09:09 had no takeable card, so they ran
  only the freshness check. Those checks found three of the four drifts reconciled at this
  planning. No run stopped on an error.

## Sustainability

Oct 24-25 was the third weekend in a row with no rest day, and Sat Oct 31, the default off day,
became the longest day of the sprint: five cards closed, then the lane, the prep, the product
review and this planning. Miguel reports feeling fresh. Sun Nov 1 stays a rest day. Sprint 10 is
sized to 8-10 slots at his request, on his faster pace, so its first week is the measurement.

## Carry-over to next sprint

- No card carries over. Multi-select's two cards, cut on Oct 31, open Sprint 10.
