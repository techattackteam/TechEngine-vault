# 2026-09-11 Threaded Engine Validation

**Scope:** ADR-019 implementation delivered by `S5-T14/app-simulation-runner`, merged as
`7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)). Miguel requested
implementation, assessment of every remaining Sprint 05 card, and attended native validation.

## Implemented

- Simulation has fixed ticks only, clamp/catch-up, tick-boundary timestamps and timeline resets.
  The publication hook takes a fixed SimulationContext, with no variable delta or alpha.
- App owns one Clock, a cancellable main wait, coherent TimingMetrics and staged shutdown.
  Input is drained before every tick; only the primary simulation advances diagnostics.
- Editor uses event-driven waiting with no periodic timer. Stop/failure wakes its main thread.
  Runtime's bounded demo stops on tick 120, without per-frame gameplay updates.
- Render uses SnapshotMailbox and private SnapshotHistory, timestamp-based interpolation,
  independent cumulative presentation input, configurable vsync and its own Tracy frame set.
- Raw input preserves edges and held state, reports overflow, and resynchronizes focus/state.
  Reserved buffers avoid allocation on the normal per-tick drain path.

## Local evidence

| Check | Result |
|---|---|
| Windows Debug preset build | Passed. |
| Windows Debug CTest | 308/308 passed, including window/GL, input concurrency and editor integration. |
| Windows profile preset build | Passed; named Tracy macro and profile-only call sites compile. |
| Focused profile CTest | 6/6 passed: headless cancellation/stall, history, pacing and editor integration. |
| clang-format 19.1.5 | Changed/new C++ files formatted and checked. |
| Linux TSan | PR #81 CI passed at head `a58c6f52`; [run 34632662083](https://github.com/techattackteam/TechEngine/actions/runs/34632662083). |
| Native Windows move/resize | Miguel confirmed the triangle kept drawing while Tracy showed render and simulation progress across a long `Main.WaitEvents` interval. |
| Focused post-review test | Miguel confirmed the stall/delayed-input test passed before close. |

Local logs: `build/adr019-debug-build.log`, `build/adr019-debug-tests.log`,
`build/adr019-profile-build.log`, `build/adr019-profile-build-final.log`,
`build/adr019-profile-tests.log`. Build outputs are local artifacts, not committed evidence.
The checked test names and their implementations are retained in the repository.

## Remaining-card assessment

| Card | Implemented evidence | Still required |
|---|---|---|
| S5-T14 | App/SimulationThread tests prove initial publication, ownership, independent ticks, failure unwind, finite-job completion, shared Clock and cancellable headless waits. | Complete in `7d2546fc` (#81). |
| S5-T15 | Editor/runtime migrated; automated real-window tests exercise rendering, title update and stop. Combined editor test proves tick/render progress while main stalls. | Complete in `7d2546fc` (#81). Review's X11 self-wake finding was fixed before merge. |
| S5-T16 | Ordered bounded input, recovery metadata and independent presentation copy; tiny-capacity and concurrent-producer/consumer tests. | Complete in `7d2546fc` (#81). |
| S5-T9 | GLFW keyboard/mouse/focus callbacks wired; fixed-tick consumption and delayed input tested. Callbacks have no GL or simulation mutation. | Complete in `7d2546fc` (#81). |
| S5-T17 | Automated editor test proves simultaneous tick/render progress during a controlled main stall, then delayed input and shutdown; headless cancellation passes. Native Windows and Linux TSan evidence are recorded above. | Complete in `7d2546fc` (#81); completes Story D. |

T14/T15/T16/T9/T17 closed together on Sep 11. All previously completed Sprint 05 cards retain
their recorded status; this close does not re-certify their historical CI evidence.

## Boundaries and limitations

This is the current triangle/input stage. Scene, camera, animation and scripts do not exist
in the current implementation. Their ownership is fixed by ADR-019; no placeholder gameplay
systems were introduced. Editor/CLI commands, grammar and their result queues are explicitly
outside S5-T9, and remain future consumers of the accepted handoff contract.

The native evidence was reviewed from Miguel's attended Tracy screenshot and confirmation;
no `.tracy` capture file was added to the vault. The screenshot showed the main thread inside
`Main.WaitEvents` while the other recorded streams continued. PR CI also passed Linux UBSan
and Windows ASan. The earlier title-related 31 ms gap remains a separate timing observation;
review fixed the confirmed X11 self-wake loop caused by rewriting an unchanged title.
