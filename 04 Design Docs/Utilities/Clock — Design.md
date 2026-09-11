# Clock — Design

> Living design doc. **Status: accepted** (2026-08-02). Drafted in the 2026-07-25 planning
> session as a light artifact ([[Planning Workflow — Artifact Gate]]), shipped by S2-T6, and
> closed out by S2-T7 and T8. Build to it.
>
> The original utility remains accepted. Sep 10: the shared wiring and threaded diagnostic
> policy below were accepted Sep 10 in [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]].

**Module:** `base` · **Kind:** utility (a helper you *call*) · **Status:** accepted, implemented (S2-T6)
**ADRs:** [[ADR-006 — v2 core architecture & module layout]] §4 §6 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §5
**Consumers:** main, simulation and render (time reads); primary simulation (diagnostic writes).
[[Logger — Design]] reads the pushed stamp; [[Profiler — Design]] retains Tracy's own timer.
**Sprint:** [[2026-08 Sprint 02 — Base Foundation]], S2-T6

## Purpose

The engine's **time source**, and deliberately nothing else.

The interesting part of this design is what the Clock refuses to own. It does not hold
simulation time, and it does not decide how fast the game runs. Both belong elsewhere, and
the two sections below explain why.

## Decided

| Fact | Where |
|---|---|
| The composition root owns one time source; `EngineContext` carries `const Clock&` to all three lanes. | ADR-006 §4; ADR-019 §3; shipped in #81 |
| It lives in **`base`**, with no `platform` seam. `steady_clock` is standard, and it is QPC-backed on Windows. | This note. The profiler puts no pressure on it ([[ADR-013 — Profiler (Tracy-backed instrumentation)]] §5). |
| It owns a monotonic `now()`, a wall-clock stamp, `totalTime`, and a **diagnostic** frame counter. | [[Game Loop — Frame Flow]] (2026-07-24) |
| It does not own delta, fixed step, tick, alpha or role. Fixed state stays per simulation; alpha stays in that simulation's presentation view. | ADR-019 §2 §3, Accepted context split |
| Monotonic time is for **durations**. Wall-clock time is for **stamps only**. | This note. It is a local call, so no ADR owes it. |
| `app` **pushes** the frame stamp into diagnostics. `base` holds no `Clock` reference. | [[ADR-011 — Diagnostics (Logger & Assert)]] §9 |
| `timeScale`, pause and slow motion are **loop policy**, not Clock knobs. | [[Game Loop — Frame Flow]] |
| **There is no testability seam.** The loop takes its delta as a parameter, so nothing needs to fake the Clock. | S2-T7 (2026-07-30), below |
| Only the app-designated primary simulation advances the diagnostic counter, once per completed fixed tick; it pushes the result to diagnostics. | ADR-019 §5, Accepted; ADR-011 §9 push retained |
| Shared counter reads are race-free; time sampling has no mutable loop state. | ADR-019 §3 §5, Accepted |
| App exposes one copied timing view; each loop publishes its own measured progress, using shared rate helpers where useful. | ADR-019 §3, Accepted |

## Design

### Why simulation time is not here

One process can host more than one simulation. Tests run several headless sims side by side,
and that is the case which exists today.

**The v2 editor hosts a client only.** v1's editor hosted a client *and* a server in one
process, which is the mistake behind F1 and F2. That case does not come back, so it is not
what this section is protecting against.

A process-wide Clock can hold exactly one `tick` and one `alpha`. With two sims running,
whose would they be? `role` is worse: it has no meaning at all as a global, because two sims
in one process do not have to share a role.

The fixed and presentation contexts are passed per call, so each sim/view carries its own.
This split replaces the old combined `FrameContext` under Accepted ADR-019. The argument is in
[[Game Loop — Frame Flow]] under *Tick timestamps* and *Host waiting and diagnostics*.

### Central timing display without central advancement

A common readout is useful, but the data has different owners:

| Value | Who can calculate it correctly? |
|---|---|
| Monotonic time and elapsed time since engine start | Clock |
| Completed tick, backlog, TPS and tick-work duration | The simulation that executes the work |
| Frame delta, completed frames, FPS and interpolation alpha | The renderer holding the snapshots |
| Event age and host-work duration | Host captures and the consuming lane |

A Clock could store all of these, but it would need a record per simulation and renderer,
plus reports from those owners. It cannot infer completion from elapsed time. Two renderers
can also have different alpha at the same instant because they acquired different snapshots.
The extra state would be a timing registry, even if the class were still named Clock.

Accepted ADR-019 keeps calculation with each owner. App exposes the combined readout;
no separate registry is needed initially. The surface below records the agreed mechanism.

### Timing metrics surface

`App::timingMetrics()` returns a copied `TimingMetrics` value. App gathers simulation
measurements and the optional render sample supplied by the client composition, without
adding a dependency from app to client. Headless compositions report render data as absent,
not as a renderer running at zero FPS. Main never reads live accumulator or renderer state.

| Sample | Initial values |
|---|---|
| Simulation | Completed tick, TPS, tick-work duration, sample timestamp and simulation identity. |
| Render, when present | Completed frame, FPS, frame interval, rendering-work duration and sample timestamp. |

Each owner publishes a coherent sample under a short mutex. Readers copy each sample and
release its lock before formatting text or doing host work. Different producers need not
have sampled at the same instant; timestamps reveal stale samples. Publication must not
hold a lock through simulation, rendering or a wait for another lane's work.

A small `RateCounter` helper accepts actual elapsed time and completed-work counts.
Each loop owns a separate instance: simulation counts ticks; render counts completed swaps.
Rendering-work duration excludes presentation/pacing waits; frame interval includes them.
Alpha stays render-local initially and can be published later if a diagnostic view needs it.
Main's deadline/wait behavior is specified in [[Game Loop — Frame Flow]]; it needs no TPS
counter or catch-up accumulator. Tracy host zones provide the initial host-work measurements.

### The frame counter is for correlation only

This is the Logger's ambient stamp. It is not Tracy's frame number: Tracy receives explicit
frame markers, with stream ownership defined in [[Profiler — Design]] and ADR-019 §6.

The Logger's `[f 1043]` stamp and the profiler's zones are **global macros**. A macro cannot
be handed a `FrameContext`, so it needs an ambient frame number from somewhere. The Clock
keeps one for exactly that.

That number is **approximate when two sims share a process**, for the reason above. It is
never the simulation's source of truth. Anything that has to be exact reads
the relevant simulation's tick instead.

**The Clock owns the counter, but it never hands itself to the Logger.** Under Accepted
ADR-019, the app-designated primary simulation advances it after each completed tick,
reads `frame()` and pushes the value into diagnostics. Other simulations never advance it.
Neither host wakes nor render swaps change this counter. It is not an FPS measure.

The alternative would be an ambient global `Clock*` that a log macro reads directly. That is
a second way to reach an `EngineContext` service, which is the exact pattern ADR-006 §4
exists to remove. Decided in [[ADR-011 — Diagnostics (Logger & Assert)]] §9.

### Surface

This is the shape, not a specification. The implementation decides the details.

| Call | Returns | For |
|---|---|---|
| `now()` | A monotonic `TimePoint` | Durations, and the loop's `dt` |
| `totalTime()` | Seconds since start | Ambient elapsed time |
| `wallClock()` | A `system_clock` stamp | Log timestamps only |
| `frame()` | The diagnostic counter | Logger and profiler correlation |

Host, simulation and render sample the same Clock through read-only references. Its start
time is initialized before threads start and never changes. Only the primary simulation
gets diagnostic-counter write access through app wiring; use an atomic counter or equivalent
synchronization for concurrent `frame()` reads. The existing plain integer is not sufficient.
Clock outlives all three loops; no global service pointer or per-loop Clock is introduced.

### There is no testability seam

**Resolved at S2-T7 (2026-07-30), and the answer is that none is needed.**

The question was whether to inject the loop's delta, or to put a seam inside `Clock` so tests
could fake time. The answer is the first option, taken one step further.

The synchronous advance seam takes elapsed time explicitly. T14 has moved the old
FrameLoop behavior into SimulationThread; under Accepted ADR-019 its fixed-step calculation
continues to accept synthetic deltas. Tests supply a per-simulation origin for tick-time
mapping and synthetic snapshot/render times for interpolation. No real sleeps are required.

So the determinism and clamp tests (S2-T8) simply call `advance()` with a synthetic sequence
of deltas. No fake clock, no virtual function, and `Clock` stays the plain concrete utility
this note wanted.

## Open questions

### Shared wiring implemented Sep 11

App now owns Clock and exposes it through EngineContext. Simulation, render rates and host
maintenance use that source. Clock's diagnostic counter is atomic, and TimingMetrics gathers
coherent per-lane values. RateCounter is shared calculation code with one instance per lane.
[[2026-09-11 Threaded Engine Validation]] records the validation and merge evidence.
The wiring shipped as `7d2546fc` (#81).

### Historical wiring gap, Sep 10

At `82ac7ed2` plus working changes, `engine/core/include/TechEngine/core/EngineContext.hpp:7`
still has only files/jobs. `engine/app/src/SimulationThread.cpp:97` creates a local Clock,
and `engine/client/src/render/RenderThread.cpp:79` uses a separate direct steady-clock path
for rate measurement. ADR-019 requires routing engine time reads through the shared service.
`engine/base/include/TechEngine/base/time/Clock.hpp:26` still has a plain diagnostic counter.
These changes are designed, not implemented or tested in this documentation session.

### Is `steady_clock` precise enough for profiling?

**Dissolved rather than answered**, on 2026-08-02 by
[[ADR-013 — Profiler (Tracy-backed instrumentation)]] §5.

The question assumed the profiler would read `Clock`. It does not. Tracy carries its own
timer and its own calibration, so it never asks us for a timestamp. `Clock` therefore needs
no `platform` seam and no raw timer, and it stays exactly as it is.

If `steady_clock` ever does prove too coarse, it will surface as a **frame pacing** problem
rather than a profiling one. That is already a [[Backlog]] item under `app`, with its
evidence recorded in [[Game Loop — Frame Flow]]. The profiler is now the instrument that
would measure it.

## References

- [[Game Loop — Frame Flow]]: where simulation time lives, and why it is not here
- [[Logger — Design]]: the consumer of the `[f N]` stamp
- Code: `engine/base/include/TechEngine/base/time/Clock.hpp` ·
  `engine/base/src/time/Clock.cpp` · current writer `engine/app/src/SimulationThread.cpp`
