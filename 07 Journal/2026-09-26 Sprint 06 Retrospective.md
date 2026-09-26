---
type: retrospective
sprint: Sprint 06
date: 2026-09-26
---

# Retrospective — Sprint 06

## Outcome

All 12 board cards closed: 9 Dev, 2 Design, 1 Bug and 0 Process. The permanent
delivery record is in [[2026-09 Sprint 06 — Scene & Scheduling]]. The final week's
engine history includes Schedule, graph, serial execution, App wiring and the Linux
TSan workaround in PRs #89–93.

Miguel reports that the showcase checked expected values and headless/windowed parity,
and that logs and Tracy showed systems running in the same order across ticks. This is
attended demonstration evidence. The existing runtime test still checks one tick and
one entity; it does not encode that full demonstration as an automated regression.

## What went well

- Reusing v1's storage model with targeted tests made the Scene and scheduling chain
  possible within one sprint. Reviews caught transition rollback, Transform binding and
  command-buffer ownership errors before merge.
- A standalone GLFW reproduction separated the Mesa TSan warning from TechEngine's
  render-thread scheduling. The narrow CI setting preserved a TSan signal for engine code.

## What wasted time

- The final weekend felt rushed because Miguel expected little weekday time. He ended
  the sprint feeling okay, but the pace should not become the default capacity estimate.
- PR #92's final CI passed with changed-line coverage bypassed. Its test evidence was
  narrower than the later attended showcase. PR #93's workflow edit still awaits its
  first hosted Linux TSan run.

## Process improvements

- Record what a showcase directly observed beside automated test evidence, so neither
  is made to stand for the other.
- Keep input's GLFW translation and action semantics behind a design decision before
  sizing implementation cards.

## Sustainability

Miguel rushed during the last weekend to compensate for a week with limited time, but
reports that he ended okay. Sprint 07 should account for an unavailable weekend and
use the Tuesday free from his day job without assuming every spare hour is capacity.

## Carry-over to next sprint

- Input action mapping remains M5 work. Its engine-owned input vocabulary and mapping
  contract are S7-D2 before implementation.
- Scene event streams and Tick barrier ownership remain unbuilt; the no-op adapter is
  still in App. S7-D1 gates their Sprint 07 implementation. The Sprint 06 showcase
  proof is recorded above; its full behavior is not yet an automated App regression.
- S6-P1's build/profiler reconciliation became S7-P1. [[Backlog]] retains the hosted
  TSan validation gap until a code PR runs the changed workflow.
