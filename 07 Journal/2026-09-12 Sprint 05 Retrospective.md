---
type: retrospective
sprint: Sprint 05
date: 2026-09-12
---

# Retrospective — Sprint 05

## Outcome

The editor project testbed and render-thread triangle shipped. The added simulation
independence work also closed. All **25 cards** closed: **17 Dev, 3 Design, 1 Bug,
4 Process**. Process was 16% of closed cards. These counts classify the existing IDs;
they do not imply all defect-fixing time had a Bug card.

The permanent card summary is in [[2026-08 Sprint 05 — M3 Project & M4 Window]].
The final week's git history includes glad2, Xvfb, Window, drawing, dedicated threads,
worker adoption and #81's simulation/input integration. Freshly fetched `origin/master`
is `7d2546fc`; [[2026-09-11 Threaded Engine Validation]] holds the recorded test/CI
evidence and Miguel's native Windows demo. No build, test or demo was rerun today.

## What went well

- The resize demo exposed a real requirement: simulation must survive a blocked host.
  ADR-018/019 and the integration proof turned it into a shipped boundary.
- The v2 testbed now provides a real place to exercise project loading and rendering.
  Controlled stalls and the attended Tracy demo proved different parts of the contract.
- Review caught the X11 title self-wake loop before #81 merged. The applied-title cache
  made the event-driven main loop behave as intended.

## What wasted time

- Bootstrap and fatal-check contracts were treated as settled before they were. Their
  implementation exposed missing decisions and changed cards underneath the work.
- Catch2 and Jolt disagreed on exception configuration, hiding useful failure reports.
  Build policy also changed during that repair and its accepted documentation still lags.
- Sizing predicted an unavoidable M4 cut, yet M4 and the added thread split shipped.
  Card weights and actual session cost need calibration; merged-card count is not hours.

## Process improvements

- Read v1 before sizing the ECS port. Reuse sound mechanics and name the concrete
  adaptations, instead of pricing every piece as new implementation.
- Stop detailed card cutting at an open design gate. In Sprint 06, the Scene reuse review
  and task-graph ADR own the follow-on breakdown.
- Record the shipped state in hubs at close. Stale headers currently contradict newer
  completion evidence, even within the same note.

## Sustainability

Miguel reports: “it good I believe we can continue with this pace”. Keep the current
rhythm and rest-day default. Actual hours, individual rest days and job/karting conflicts
were not reported, so the card count cannot prove that every day respected the cadence.
No specific unavailable dates were supplied for Sep 12–25.

## Artifact check and limits

This was a targeted check, not complete vault reconciliation. The Dashboard stamp stays
at `01ed7a30`. Fresh history confirms #81 merged; source inspection confirms App's optional
hooks, fixed SimulationContext and the editor's snapshot publication/event wait.

- The task-graph draft still shows the old variable-phase pipeline. ADR-019 explicitly
  supersedes it. S6-D2 must reconcile that hub before implementation.
- Project — Design still calls S5-T5 open. Simulation Thread — Design has a correct
  implemented header but ends with an old claim that separation remains future work.
- The old four-pure-hook warning is no longer current: App now has optional work hooks.
  Project/ADR-017 historical wording and the separate entry-point divergence need a
  careful reconciliation rather than deleting both issues together.
- Known Issue D4 points to removed FrameContext and overstates allocation: short strings
  may use small-string storage. SimulationContext still returns an owning string, but its
  actual consumers and measured cost need checking before promotion or closure.
- Warning-policy and Tracy-pin reconciliation move to S6-P1. Remaining File Access,
  bootstrap and backlog witness checks are S6-P2's bounded report, not confirmed fixes.

Full reconciliation is offered through these bounded follow-ups. No new engine bug was
established by this spot-check; live CI and scheduler state were not inspected.

## Carry-over

No unfinished board cards remain and no Bug card was dropped. Runtime fixed-layout
packaging remains deferred to M6. RNG and crash handling stay on the roadmap pending a
consumer. Sprint 06 opens M5 with Scene reuse and the task-graph contract.
