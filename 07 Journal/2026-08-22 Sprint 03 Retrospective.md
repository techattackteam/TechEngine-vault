---
type: retrospective
sprint: Sprint 03
date: 2026-08-22
---

# Retrospective: Sprint 03 (M1 Enablers)

Sprint [[2026-08 Sprint 03 — M1 Enablers]], Aug 1 to Aug 20, closed 8 days early. This entry
covers the final week too: no separate weekly review runs this weekend.

## 🟢 What went well

- **19 cards closed: 13 Dev · 3 Design · 1 Bug · 2 Process.** The board's "17 of 17" excludes
  the two gate ADRs, which were already done when the rest was sized on Aug 2. One planned Bug
  card, zero mid-sprint arrivals, so the sprint paid for no unplanned work.
- Both M1 gates were Accepted on day 1, so every story was cut from an Accepted artifact and
  no story needed re-cutting afterwards.
- The sizing rule proved itself again. The pre-ADR reserve guessed about 7 🟢 for stories
  D, E and F, and they drew 3. *Don't size past an open decision* keeps producing lighter
  cards than the guess.
- Review depth paid three times: S3-T12's suite grew 17 to 26 cases in review, S3-T10's
  mid-call bug was caught in review (no end-of-call assertion could see it), and `te-review`'s
  dry run found a green format gate hiding a broken include rule.
- The Aug 20 drift check found four findings, two of them live poison, and all four were
  reconciled the same day.

## 🔴 What wasted time

- PR #25 merged a throwaway exercise and PR #26 redid the card. "It works" and "it is the
  card" are different reviews.
- S3-T3's three stacked risks were all non-risks, answerable by reading Tracy's build files.
  A dep's build-integration risk is assessed against its build, not its source.
- S3-T6's card recipe measured the frame pacer, not the profiler. Check what the loop is
  doing before trusting a number.
- S3-T13's build break survived my own check because the verifying grep reused the edit's own
  search pattern. A verification that shares the edit's pattern verifies nothing.
- S3-P1 burned about 14 CI minutes and 8 required checks on three markdown files. The skip-CI
  backlog trigger fired on the spot (pulled into Sprint 04 as S4-P4).
- Aug 14 to 19: six days, zero commits. Not rest, an empty board with a weekend-only refill
  point. Structural, and the 2-week box plus the weekday fallback are the fix.

## 🔧 Process improvements (do next sprint)

- Sprint 04 runs the two Aug 20 decisions for real: the 2-week box and the weekday ceremony
  fallback. Watch whether the tail stall repeats.
- The first `/card-start` of Sprint 04 is S3-P2's real acceptance test. Its done-clause had no
  referent in Sprint 03.
- A card written from a premise bakes that premise into its acceptance (S3-P1's off-limits
  clause encoded the wrong answer). Where the premise is unproven, write the done-condition as
  the question, not the expected answer.

## 🤖 How AI helped (and where it didn't)

- Two `/adr` sessions in one day produced both gates, Accepted, with design notes as hubs.
  `/card-close`'s dry run rebuilt S3-T12's entry and improved its own gather step.
  `te-review` found real findings on its first pass.
- Where it didn't: both `te-review` runs over-filed [[Known Issues]] rows before the
  latent-and-silent check. The guardrail (fresh defects route through the rubric) came from
  catching that.

## Carry-over to next sprint

- **RNG and the crash handler** stay on the M1 carry list: still no consumer, still
  artifact-less. Not pulled into Sprint 04.
- **Memory tracking is off the carry list.** It shipped at S3-T5. The Dashboard and
  [[Roadmap]] still said it carried; fixed at this boundary.
- No unfinished cards and no B cards to carry. The board closed empty.

## 🔋 Sustainability

- Weekday cadence held both halves (Tue light, Wed off), Aug 15-16 was a real full rest
  weekend, and the job plus engine plus karting balance held. Final week: rest, then Thu
  Aug 20 closed S3-P1 under the new fallback rule.
- Two overruns, the same shape Jul 25 flagged: Fri Aug 7 closed four PRs including a 🟢 card
  on a 🟠 day, and Mon Aug 3 and Aug 10 closed three cards each on evenings sized for one.
  Bank-the-slack is now untested for a third sprint.
- The kind mix is the health signal: 1 Bug and 2 Process across 19 cards means the capacity
  went to the goal.
