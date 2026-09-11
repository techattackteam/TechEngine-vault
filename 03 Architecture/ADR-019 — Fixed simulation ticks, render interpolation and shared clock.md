# ADR-019 — Fixed simulation ticks, render interpolation and shared clock

- **Status:** Accepted (Miguel, 2026-09-10)
- **Date:** 2026-09-10
- **Deciders:** Miguel (Lead Engineer)
- **Task:** S5-T14 review, before S5-T15 integration
- **Design:** [[Simulation Thread — Design]] · [[Game Loop — Frame Flow]] · [[Clock — Design]]
- **Partial supersessions:** ADR-007 §5's variable tail and combined time context;
  §6's single simulation/presentation pipeline and Scene-taking presentation interface;
  ADR-006 §4's combined frame context and §5's live-ECS requirement for presentation Systems.
  ADR-011 §9's once-per-frame stamp cadence becomes once per primary simulation tick.
  ADR-018's thread ownership and latest-complete delivery remain. ADR-010 is still Proposed.

## Context

ADR-018 separated the threads, but the time model still couples simulation and presentation.
At `82ac7ed2` on `S5-T14/app-simulation-runner` (PR #80), plus the inspected working changes,
`engine/app/src/SimulationThread.cpp:97` constructs a private Clock and calls `update()`
after catch-up at line 113. `engine/app/include/TechEngine/app/SimulationThread.hpp:70`
still exports iteration delta and alpha. `engine/core/include/TechEngine/core/EngineContext.hpp:7` has no Clock.
`engine/client/src/render/RenderThread.cpp:85` acquires one value per draw;
`engine/client/include/TechEngine/client/render/FrameCommand.hpp:7` has no tick time.

Miguel reports 60–61 simulation `update()` calls per second on Windows, averaging 16.6 ms,
with gaps from about 14.7 to 31 ms. Removing the once-per-second title change in
`apps/editor/src/EditorApp.cpp:53` removed the spike; `timeBeginPeriod(1)` changed nothing.
These are callback gaps, not individual tick intervals or proof of lost ticks. The cause
of the apparent cross-thread delay is unknown; this ADR does not claim to fix that cause.

Freshness checked Sep 10 after fetching origin: 19 commits separate the Dashboard stamp
`01ed7a30` from `origin/master` at `a60b64bd`. The notes are suspect; this targeted checkout
inspection does not advance the reconciliation stamp. No build or timing experiment ran.

## Decision

### 1. Simulation executes fixed ticks only

Keep the accumulator, configurable 60 Hz default, catch-up and 0.25 s elapsed-time clamp.
A late wake executes the due ticks in order; never jump tick numbers to skip work. After
a catch-up batch that advances ticks, invoke a publication hook with no delta time or alpha.
It extracts completed state and does not run a variable-rate gameplay phase.

Ordinary wake jitter is recovered by catch-up. Sustained overload can lower TPS; a single
stall beyond the clamp also discards elapsed wall time and can lower a measured TPS window.
Consecutive tick identity survives that clamp. ADR-007 §5's server-master/prediction model
remains: silently omitting authoritative tick work would invalidate clients' command history.
This is not a guarantee of permanent wall-time lockstep or a network time-sync algorithm.

### 2. Presentation owns variable time and interpolation

Simulation runs input conversion and fixed work, with structural/event barriers preserved
per tick. The old `Update`, `PostUpdate` and `Present` tail becomes renderer-specific
preparation, drawing and presentation; it need not retain those phase names or a one-to-one
mapping. Vsync is optional and can be disabled; render owns its pacing either way.
Camera, visual animation, culling and presentation transforms operate on
snapshot data and render-owned state. Root motion, collision poses, gameplay animation
events and any other authoritative effect stay fixed-tick simulation work.

Presentation Systems remain replaceable defaults, but their input is a snapshot/presentation
context, never `Scene&` or a façade reaching live simulation data. There is no barrier that
makes simulation wait for render. Split combined frame context into fixed simulation state
and per-frame presentation state; alpha belongs to the latter, scoped to its simulation.

Revise Proposed ADR-010 §2–4: gameplay scripts have `onFixedUpdate`, `onStart`, `onDestroy`;
remove `onUpdate`. The terminal ScriptSystem slot exists only in `FixedUpdate`. Defer a
separate presentation-script API until needed; it must own separate instances, use copied
snapshot data and have no Scene access. Moving the same live script object is forbidden.

### 3. Share one time source and timestamp completed state

The composition root owns one Clock and exposes `const Clock&` through EngineContext to
main, simulation and render. Engine durations and input timestamps use its monotonic domain;
wall-clock stamps remain for logging and Tracy retains its independent measurement timer.
Tick, fixed step, role, accumulator and presentation alpha are per simulation/view, never
Clock fields. Tests can share the Clock while advancing independent simulations synthetically.

Each loop owns its timing state and publishes copied metrics; App exposes one combined
timing view without introducing a separate metrics service. Reuse rate-calculation helpers
for TPS and FPS. Elapsed time cannot establish completed work, and alpha depends on the
snapshots render acquired, so Clock does not advance the loops or calculate their progress.
Samples are coherent per producer, not simultaneous across threads. [[Clock — Design]]
holds the metrics surface and publication mechanism; alpha stays render-local unless needed
for diagnostics.

Each published render snapshot carries its completed tick number and the tick boundary's
time in that shared domain, plus self-contained presentation data. This is the scheduled
boundary represented by the state, not extraction completion time: catch-up ticks still
represent distinct fixed intervals. Clamp or timeline reset invalidates interpolation
history through a discontinuity marker; clock time is never reset to implement game policy.
This local time domain does not synchronize clocks across networked machines (ADR-007 §5).

Keep the bounded single-slot value mailbox. Render retains the last two distinct snapshots
it acquired; they need not be adjacent ticks. It computes alpha from their actual timestamps
and a delayed presentation time. Start with one fixed-step delay; clamp alpha to [0, 1].
Before two compatible snapshots exist, or after history runs out, hold available state.
Never extrapolate by accident, block for another snapshot, or borrow mutable Scene storage.
The detailed endpoint and discontinuity rules live in [[Game Loop — Frame Flow]].
The mailbox is one shared transfer slot; the two interpolation snapshots are render-private
history, not shared double buffering. Copies use short locks; simulation work and drawing
run outside them. Larger payloads may justify another storage mechanism without changing
the latest-complete delivery rule.

### 4. Deliver presentation input independently

Main publishes a second, bounded latest-state path for camera/mouse-look alongside ordered
simulation ingress. Render samples it each frame; neither consumer drains the other's input.
Use shared capture sequence/time and focus generations to distinguish fresh motion and resets.
Snapshot data identifies the input already reflected in its view, so render applies only
newer look input. Simulation alone forms gameplay commands, including absolute view angles;
visual look changes do not bypass authoritative command handling (ADR-007 §4).
Use ordered bounded queues for transitions, accepted commands and individual command
results; use latest-value publication for snapshots, presentation input, metrics and status.
Queue overflow and command-result capacity must be explicit; a latest-value slot must not
silently erase a result owed for an accepted command. [[Game Loop — Frame Flow]] maps the paths.

### 5. Main is event-driven; one simulation writes the diagnostic counter

Main blocks on `glfwWaitEvents` through platform and wakes only when an OS event arrives
or another thread posts `glfwPostEmptyEvent()`. It has no periodic timer or maintenance
deadline. `requestStop()` sets persistent stop state and wakes the main thread.
Completion/failure also wakes it. Headless apps use their cancellable control wait.
The wake path must outlive its callers through join.

On each wake, main processes delivered events and admitted commands in order, performs any
per-wake work (temporary title/metrics refresh, future editor UI updates), checks
stop/failure and blocks again. It does not replay missed iterations. Simulation and render
continue using their last delivered input; resumed delivery does not reconstruct physical
input timing during a stall. Wake events cannot forcibly interrupt a blocking callback or
native modal operation.

The app-designated primary simulation advances Clock's diagnostic frame counter once per
completed fixed tick and pushes it into diagnostics. Main and render never increment it;
additional test simulations keep their own tick counters. Reads of the shared diagnostic
counter must be race-free. It is approximate correlation, not FPS or a global simulation
tick. This replaces only ADR-011 §9's cadence; its app-owned push remains.
Render FPS still counts completed swaps.

### 6. Tracy frame streams have explicit owners

In a graphical process, the unnamed Tracy frame stream belongs only to render, with a mark
after each completed buffer swap. Its intervals include rendering and any pacing wait,
whether vsync is enabled or disabled. Simulation has a separate named tick stream and
zones for actual tick work; main uses its own work/wait zones, never the unnamed frame marker.
In a headless process, the primary simulation owns the unnamed stream instead, marking
completed ticks. Other simulations must not interleave marks into that stream.

Tracy frame intervals measure observed completion spacing, not the fixed simulated duration
or GPU completion time. Catch-up produces closely spaced tick marks; zones show tick cost.
Clock's diagnostic stamp is separate from Tracy frame numbering. This refines ADR-013's
instrumentation policy without changing its backend or independent timer.
[[Profiler — Design]] records macro needs and the current duplicate-marker evidence.

## Consequences

- **Benefit:** one time domain, fixed gameplay semantics and independent presentation cadence.
- **Cost:** a second private render value, explicit timestamp/reset semantics and input fan-out.
- **Risk:** one-step presentation delay trades latency for smoothing; skipped snapshots or
  long stalls can still cause visible holds. The remote-entity interpolation ring in
  ADR-007 §3 remains separate and is not replaced by these two local render snapshots.
- **Revisit when:** measured holds justify a larger local history or adaptive delay; a real
  presentation scripting consumer justifies its own restricted API; multiple simulations
  make the ambient diagnostic stamp misleading; or measured latency rejects the initial delay.

## Alternatives considered

- Publish simulation alpha: small payload, but stale between publications and couples
  visual cadence to simulation wakes. Incompatible with the already chosen render ownership.
- Transfer a guaranteed adjacent pair: better interpolation after missed publications, but
  requires per-tick extraction/history and larger transfers. Defer until visible holds justify it.
- Blocking snapshot delivery: preserves every publication but violates ADR-018 independence.
- Move gameplay scripts to render: preserves the API name but introduces unsafe shared state
  or a second lifecycle. A separate restricted presentation API is the viable future option.
- Use render frames for the diagnostic stamp: useful for graphics, but no writer exists on
  a dedicated server. Primary fixed ticks give one rule across compositions; exact IDs stay local.
