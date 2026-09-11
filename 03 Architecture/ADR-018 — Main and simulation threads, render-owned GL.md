# ADR-018 — Main and simulation threads, render-owned GL

- **Status:** Accepted
- **Date:** 2026-09 (Accepted 2026-09-07)
- **Deciders:** Miguel (Lead Engineer)
- **Task:** S5-D3 ([[2026-08 Sprint 05 — M3 Project & M4 Window]])
- **Design:** [[Simulation Thread — Design]]
- **Partial supersessions:** ADR-015 §1's client and dedicated-server simulation
  placement and §3's batch-only JobSystem interface; ADR-017 § *Decision* 3's restriction
  to one loop driver and four lifecycle hooks.
  [[ADR Index]] records the superseded clauses. Other clauses remain in force.
- **Discussion:** [Assess job system thread ownership](thread://01a07da8-c4d0-7ac1-be39-813f3324175d?hostId=local), read during S5-D3.

## Context

At engine `681ddf6b` (#77), `engine/app/src/App.cpp:32` advances simulation before calling
`update()`. `apps/editor/src/EditorApp.cpp:41` polls window events inside that same driver.
During the S5-T8 demo, rendering continued during resize while TPS fell. Miguel confirmed
the rendering and Tracy checks and wants simulation independent of main thread interaction too.
This changes a requirement deliberately accepted by ADR-015 §1; it is not a T8 defect.

The main thread also exists on a dedicated server: Miguel requires a CLI for server commands.
Waiting for console input must not stop ticks. Command-based editor changes are a benefit:
they establish a clear owner of simulation state instead of allowing direct UI mutation.

The existing render handoff copies a complete value under a short mutex
(`engine/client/src/render/FrameCommandBuffer.cpp:4`). The worker pool already exposes batch
submit/wait, with waits rejected on pool workers (`engine/core/src/jobs/JobSystem.cpp:63`).
The task-graph executor itself remains M5 work. This decision changes its eventual owner,
not its dependencies or execution semantics.

## Decision

### 1. Separate main thread interaction from simulation

Interactive clients and dedicated servers have a main thread and a dedicated
simulation thread. The client main thread owns window events and editor interaction. The
server main thread accepts CLI/control input without acquiring a graphical dependency. A
main thread with no input can wait for control or shutdown; it does not need to busy-poll.

The simulation thread owns simulation time, mutable simulation state and loop progression.
It coordinates the existing worker pool and, later, the task-graph executor. Structural
changes still apply at the established phase barriers. Tests may drive the same simulation
loop synchronously; that test seam is not a second simulation implementation.

Main thread operations cannot require a tick to run on the main thread. A blocked main event
pump must not suspend simulation. CPU overload and slow simulation jobs can still lower TPS;
the decision provides independence from main thread work, not a hard real-time guarantee.

### 2. Cross ownership boundaries through data

Input, editor edits and CLI commands cross into simulation through explicit handoffs.
The simulation applies them at defined boundaries. Accepted key/button transitions and
control commands must not disappear silently; overload and stale-input policy are explicit.
Main thread code reads published results or snapshots rather than live mutable simulation state.

The render thread keeps exclusive GL ownership and consumes complete render snapshots.
Miguel chose **allow skipping; keep simulation independent** on Sep 7. A slow renderer
consumes the newest completed snapshot at its next safe exchange, skipping intermediate
snapshots. If no new snapshot is complete, it redraws its current one rather than waiting
for simulation. Simulation does not wait for a render frame or presentation to finish.
Bounded transfer synchronization is permitted.

Double buffering is the proposed storage mechanism in [[Simulation Thread — Design]].
Two buffers do not imply delivery of every frame. The producer must never overwrite data
still owned by the consumer; resource lifetime is part of snapshot ownership.

### 3. One lifecycle owner, distinct main and simulation loops

`app` remains the presentation-agnostic composition and lifecycle owner. Executables retain
their `App` subclasses and supply app-specific behavior. `platform` owns OS interaction;
`client` owns GL and rendering. A server links no client rendering code (ADR-006 §1–2).

The lifecycle separates main thread work from simulation callbacks rather than moving today's
mixed `update()` wholesale. This explicitly relaxes ADR-017's single-driver/four-hook
restriction. There is one simulation driver; a main event/control loop is separately owned
and coordinated by the same lifecycle. Exact hooks belong in the design note.

Startup reports success or failure across threads. Shutdown stops new submissions, settles
outstanding simulation work, joins its owner, and releases render resources on their owner
before destroying the window. No join may depend on a main thread action that the joining thread
has stopped servicing. CLI waits and handoff waits must be interruptible during shutdown.

### 4. Thread creation and subsystem ownership

`JobSystem` in `core` provides batch execution, dedicated-thread creation, role registration
and thread diagnostics through distinct APIs. A separate `ThreadCoordinator` is not needed.
The OS-created main thread is registered, never created or joined by `JobSystem`. Simulation
and rendering use named dedicated threads; their permanent loops never occupy pool workers.
No graphics or main-thread-specific type enters `core` through this seam.

Owning handles remain with their subsystems: simulation with its app-owned runner, rendering
with `Client`, pool workers with `JobSystem`. The composition root orders stop/join through
those owners and keeps `JobSystem` alive until dedicated handles and registrations are
released. `JobSystem` shuts down its own pool; it does not infer application teardown order.
This expands ADR-015 §3's batch-only interface without changing batch execution semantics.

## Consequences

- **Benefit:** window interaction and server CLI waits on the main thread no longer suspend simulation.
- **Benefit:** editor and administrative changes become explicit commands, giving simulation
  a clear mutation boundary and a basis for later validation and history.
- **Cost:** one extra simulation thread, input/result buffering, independent pacing and
  more lifecycle states. Four pool workers remain; this is not another worker pool.
- **Cost:** `JobSystem` now serves both finite jobs and dedicated-thread infrastructure;
  separate APIs and explicit owning handles must keep their lifetime contracts clear.
- **Risk:** input can be stale while OS delivery is delayed. Continuing ticks cannot create
  missing events. Tick assignment, focus handling and overload behavior require agreement.
- **Risk:** a snapshot can outlive the tick that produced it. Render data cannot borrow
  mutable world storage without an explicit lifetime protocol.
- **Revisit when:** measured scheduling or handoff overhead defeats the latency benefit on
  supported machines, or a concrete consumer requires every produced frame to be consumed.
  That requirement would need a separate delivery mode and a deliberate backpressure policy.
- **Revisit when:** a real consumer needs thread management without the pool, or their
  lifetimes diverge enough to justify extracting a coordinator.

## Alternatives considered

| Option | Trade-off and disposition |
|---|---|
| Keep simulation and main event loop on one thread | Simplest lifecycle and no input handoff, but retains the resize/CLI coupling Miguel now rejects. |
| Keep server simulation on main; use asynchronous CLI input | Viable and may use fewer threads without a CLI. Deferred in favor of one main/simulation ownership model across executables; revisit if its overhead is material. |
| Run the permanent simulation loop as a pool job | Reuses a worker but occupies it indefinitely and conflicts with the current prohibition on worker-side batch waits. Rejected. |
| Separate `ThreadCoordinator` | Separates thread infrastructure from scheduling, but adds a service and lifetime dependency without a current consumer that needs the separation. Deferred. |
| Share mutable world state behind a broad mutex | Reduces message plumbing but makes editor/CLI access stall simulation and hides ownership. Rejected. |
| Consume every render snapshot using blocking double buffering | Preserves all frames but lets renderer stalls block simulation. Rejected for the live simulation path by Miguel. |

Accepted by Miguel on Sep 7. The design note retains unresolved lifecycle and input details
for S5-D3; implementation cards are cut once those details are settled. Acceptance establishes
the ownership decision, not completion of its implementation or of S5-D3.
