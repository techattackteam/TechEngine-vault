# ADR-015 — Threading (sim on main, render thread owns GL)

- **Status:** Accepted
- **Date:** 2026-08 (Accepted 2026-08-22)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Related:** [[ADR-005 — v2 tech stack & toolchain]] (dep policy) ·
  [[ADR-006 — v2 core architecture & module layout]] §1 §2 §4 §5 ·
  [[ADR-007 — v2 networking & ECS replication foundation]] §5 §6 ·
  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] (the gate; zones are per-thread) ·
  [[ADR-014 — Events (buffered streams) & StringId]] §3 · living *how*:
  [[Concurrency — Design]]
- **Task:** S4-D1 ([[2026-08 Sprint 04 — M2 Concurrency & Serialization]]). Gates M4's
  window bring-up and M5's executor. **P1 and P2 are [[Roadmap]] lane rungs, after M5:**
  P1 turns real workers on (workers > 1, levels running concurrently, TSan green), P2 tunes
  the pool (work-stealing, Jolt integration).
- **Amended 2026-08-24 — decision:** **the pool ships with four workers.** §3 said "one
  worker thread and a real queue", and raising the count was P1's job. S4-T5's first capture
  showed the single worker running a four-task batch end to end, exactly the shape §4
  predicted. Running the real width now retires this ADR's own negative ("one worker cannot
  produce real contention, so P1 is where hidden races surface") while the pool is still
  small enough to reason about, and it gives the `linux-tsan` leg something to find at M2
  rather than at P1. The interface, the level-to-batch mapping, barrier placement and the
  cross-thread rules are all unchanged: P1 still owns concurrent publishers and their lanes,
  P2 still owns stealing and Jolt. Taken at S4-T5 (2026-08-24).
  Record: [[Concurrency — Design]] § *Surface*.
- **Amended 2026-09-04 — citations:** § *Context*'s "tree today" paragraph is anchored at
  `5147c87f`, the engine tip when it was written. Its "no `std::thread` outside a pacer
  `yield`" was made false by this ADR's own decision two days later (#46 shipped four
  workers). No decision moved. Found by S5-P3.

## Context

OpenGL is why this decides now, not the job system. GLFW pins window creation and event
polling to the process's main thread, and a GL context is current on exactly one thread at a
time. Whichever thread owns the context, every other thread must reach it through data, and
retrofitting that seam across a written renderer is a rewrite ([[Roadmap]] § *M2*). So the
topology is decided before M4 builds the first window, and before M5 writes the executor
against a pool interface.

v1 is the counterexample: little real threading and three ad-hoc models around it
(F15: `Query.hpp:90-119`, `Parallel.hpp:29-50` @ `v1-reference`), with resource caches that
silently assumed single-threaded structural edits (F31). The v1 lesson list already names the
fix: one owned pool that queries, resource load and physics all schedule onto.

The tree at `5147c87f`, when this was written, is single-threaded by construction: no
`std::thread` exists outside a pacer `yield` (`engine/app/src/App.cpp:94` at that sha), the
loop walks fixed steps serially (`engine/app/include/TechEngine/app/FrameLoop.hpp:36` at that
sha), and the event streams stage into one
buffer per stream because "the executor is serial until M2"
([[Events — Design]] § *Staging, at M1*). The instrument this ADR was gated on exists
(ADR-013 Accepted; zones and the memory plot are live).

Inherited, not re-decided here: the job system lives in `core` and is injected as
`EngineContext`'s `JobSystem&` (ADR-006 §1 §4); barriers apply structural change
single-threaded in deterministic order (ADR-007 §6); the System interface stays deferred to
M5's task-graph ADR (ADR-006 §5).

## Decision

### 1. Topology: the sim runs on the main thread

In a client composition the **main thread** pumps OS events and runs the whole loop
(`Input` to `PostUpdate`, plus producing `Present`'s output). A dedicated **render thread**
owns the GL context. **Pool workers** run task-graph levels when P1 turns them on. A
**dedicated server** is the same loop on the main thread, headless, with no render thread
(ADR-006 §2). The editor stays a host outside the loop (F14).

The known cost, accepted: a Windows window drag blocks the pump, so the sim stalls and
catches up under the existing clamp (`FrameLoop.hpp:12`, at most 15 ticks). The reversal is
bounded because input already flows as command data (ADR-007 §2), so moving the loop onto its
own thread later changes the loop's host, not the systems. See *What would move this
decision*.

### 2. GL context ownership: the render thread, exclusively

The render thread makes the context current once at startup and never releases it. After the
handoff the main thread issues no GL call, ever. Work reaches the render thread only as
**complete per-frame command lists**; it consumes the most recent complete list, so one frame
of present latency is allowed. The list format and pass structure belong to R1's renderer
ADR; M4 proves this seam with clear plus triangle running on the render thread.

### 3. JobSystem: hand-rolled in `core`, batch submit and join

> **Amended 2026-08-24:** the pool ships with **four** workers, not the one named below.
> Everything else in this section stands: the interface is still submit a batch and wait for
> it, and P2 still owns stealing and Jolt.

`JobSystem` is an engine-lifetime service in `core`, injected via `EngineContext`, name kept
from ADR-006 §4's sketch. The M2 interface is the executor's shape and nothing more:
**submit a batch of tasks, wait for that batch**. No futures, no continuations, no
priorities, no third-party scheduler. The minimal pool ships with **one worker thread and a
real queue**, so the submit and join handoff is exercised under the `linux-tsan` leg from
day one. P1 raises the worker count; P2 adds stealing and Jolt pool integration (F15).

### 4. Task-graph levels map to batches

> **Amended 2026-08-24:** with four workers, the "observable behavior stays serial" sentence
> below no longer holds. Determinism at M2 rests on the level mapping, on levels having
> disjoint writes, and on barriers running off the workers. It never rested on the worker
> count alone.

Within a phase the executor submits each level as one batch and waits before the next level
(levels have disjoint writes by construction, ADR-007 §6). Phase barriers, command-buffer
apply and `NetId` assignment run on the loop's thread, never on workers. With one worker the
observable behavior stays serial under the same ordering key, which is what keeps M2
deterministic by construction.

The known cost of fork-join is an **idle bubble at each level's tail**: workers wait on the
level's slowest task, and the sim thread blocks in `wait`. Idle workers sleep on a condition
variable; nothing spins and nothing deadlocks by construction, since tasks take no locks and
spawn no tasks at M2. Richer scheduling (task-level dependency edges crossing level
boundaries, caller-runs-tasks inside `wait`) changes the executor and the pool only, because
systems declare access rather than schedule themselves; that upgrade is P2's, behind a P1
measurement showing the bubble costs.

### 5. Cross-thread rules at M2

Event `publish` is **sim-thread-only until P1**. The per-thread staging lanes and their
merge, whose semantics [[Events — Design]] already fixes, are designed at P1 when concurrent
publishers exist; this ADR only reserves the rule. Diagnostics is already multi-thread
tolerant (atomics throughout `engine/base/src/diagnostics/Log.cpp`), and worker threads get
Tracy names at creation (mechanism in [[Concurrency — Design]]).

## Consequences

**Positive**

- M4 can build the window against a decided owner, and M5 writes the executor against a real
  pool interface instead of a placeholder.
- The first race-capable code lands with the TSan leg already watching it.
- The dedicated server composition needs no reshape: same loop, no render thread.
- The seams this topology requires (input as commands, render fed by command lists) are the
  same seams a sim-thread topology needs, so the reversal stays bounded.

**Negative / open**

- The drag-stall wart is real on Windows and accepted until it is measured to matter.
- One worker cannot produce real contention, so P1 is where hidden races surface; the pool's
  own handoff is the only concurrency actually tested at M2.
- One frame of present latency is baked into the seam; R1 owns the pacing detail.
- Which thread the editor's ImGui backend renders on is a T1 question, not answered here.

## Alternatives considered

- **Dedicated sim thread now** — rejected for now: a third thread and a main-to-sim input
  queue at M4, bought against a stall that is bounded and not yet measured to matter. Named
  as the reversal path below.
- **No render thread (main owns GL)** — rejected: `Present` couples the sim to vsync, and
  adding a render thread across a written renderer is the retrofit M2 exists to prevent.
- **Third-party tasking (TBB, Taskflow)** — rejected: ADR-005's dep bar, and v1's lesson is
  one owned pool everything schedules onto; determinism and the level mapping stay ours.
- **Settle the event lane layout now** — rejected: no concurrent publisher exists until P1,
  so the design would be built against nothing and P1 may overturn it.

## What would move this decision

- **Profiler evidence that pump stalls or OS jitter on the main thread harm a connected
  client** (catch-up bursts, missed sends) moves the loop to a dedicated sim thread; input
  is already command data, so the change is the loop's host, not the systems.
- **A per-level join showing up in P1's captures** as the bottleneck brings P2's
  work-stealing forward.
- **MSVC or libstdc++ trouble with the one-worker pool under a sanitizer leg** is a build
  fact to fix, not a topology change; it moves nothing here.

> Add to [[ADR Index]]. Once Accepted, change it only per [[ADR Index]] § *Amending an Accepted ADR*: a dated header entry for what fits one, a superseding ADR for what needs its own argument.
