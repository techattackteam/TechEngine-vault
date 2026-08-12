# Clock — Design

> Living design doc. **Status: accepted** (2026-08-02). Drafted in the 2026-07-25 planning
> session as a light artifact ([[Planning Workflow — Artifact Gate]]), shipped by S2-T6, and
> closed out by S2-T7 and T8. Build to it.
>
> The ADR holds the decision, this doc holds the *how*. No ADR is owed here. The Clock is
> local to `base`, it is reversible, and its shape was settled in [[Game Loop — Frame Flow]].

**Module:** `base` · **Kind:** utility (a helper you *call*) · **Status:** accepted, implemented (S2-T6)
**ADRs:** [[ADR-006 — v2 core architecture & module layout]] §4 §6 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §5
**Consumers:** the app loop (writes) · [[Logger — Design]] and [[Profiler — Design]] (read the frame stamp)
**Sprint:** [[2026-08 Sprint 02 — Base Foundation]], S2-T6

## Purpose

The engine's **time source**, and deliberately nothing else.

The interesting part of this design is what the Clock refuses to own. It does not hold
simulation time, and it does not decide how fast the game runs. Both belong elsewhere, and
the two sections below explain why.

## Decided

| Fact | Where |
|---|---|
| A read-only time facade. `EngineContext` carries it as a `const Clock&`. The loop writes, systems read. | ADR-006 §4 |
| It lives in **`base`**, with no `platform` seam. `steady_clock` is standard, and it is QPC-backed on Windows. | This note. The profiler puts no pressure on it ([[ADR-013 — Profiler (Tracy-backed instrumentation)]] §5). |
| It owns a monotonic `now()`, a wall-clock stamp, `totalTime`, and a **diagnostic** frame counter. | [[Game Loop — Frame Flow]] (2026-07-24) |
| It does **not** own `dt`, `fixedDt`, `tick`, `alpha` or `role`. Those live on `FrameContext`. | [[Game Loop — Frame Flow]] (2026-07-24), ADR-007 §5 |
| Monotonic time is for **durations**. Wall-clock time is for **stamps only**. | This note. It is a local call, so no ADR owes it. |
| `app` **pushes** the frame stamp into diagnostics. `base` holds no `Clock` reference. | [[ADR-011 — Diagnostics (Logger & Assert)]] §9 |
| `timeScale`, pause and slow motion are **loop policy**, not Clock knobs. | [[Game Loop — Frame Flow]] |
| **There is no testability seam.** The loop takes its delta as a parameter, so nothing needs to fake the Clock. | S2-T7 (2026-07-30), below |

## Design

### Why simulation time is not here

One process can host more than one simulation. Tests run several headless sims side by side,
and that is the case which exists today.

**The v2 editor hosts a client only.** v1's editor hosted a client *and* a server in one
process, which is the mistake behind F1 and F2. That case does not come back, so it is not
what this section is protecting against. [[Game Loop — Frame Flow]] records the same call.

A process-wide Clock can hold exactly one `tick` and one `alpha`. With two sims running,
whose would they be? `role` is worse: it has no meaning at all as a global, because two sims
in one process do not have to share a role.

`FrameContext` is passed per call, so each sim carries its own. The full argument is in
[[Game Loop — Frame Flow]] under *Where time lives*.

### The frame counter is for correlation only

The Logger's `[f 1043]` stamp and the profiler's zones are **global macros**. A macro cannot
be handed a `FrameContext`, so it needs an ambient frame number from somewhere. The Clock
keeps one for exactly that.

That number is **approximate when two sims share a process**, for the reason above. It is
never the simulation's source of truth. Anything that has to be exact reads
`FrameContext.tick` instead.

**The Clock owns the counter, but it never hands itself to the Logger.** Once per frame,
`app` reads `frame()` and pushes the value into diagnostics.

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

The loop is the only writer. It computes `dt` from `now()` and bumps the frame counter once
per frame. Everything else takes a `const Clock&`.

### There is no testability seam

**Resolved at S2-T7 (2026-07-30), and the answer is that none is needed.**

The question was whether to inject the loop's delta, or to put a seam inside `Clock` so tests
could fake time. The answer is the first option, taken one step further.

`FrameLoop::advance(frameDeltaTime)` is a pure function of its parameter. It holds no `Clock`
reference at all. Sampling `now()`, bumping the frame counter and pushing the diagnostic
stamp all happen in `app`'s driver, in `engine/app/src/App.cpp`.

So the determinism and clamp tests (S2-T8) simply call `advance()` with a synthetic sequence
of deltas. No fake clock, no virtual function, and `Clock` stays the plain concrete utility
this note wanted.

## Open questions

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
  `engine/base/src/time/Clock.cpp` · its only writer, `engine/app/src/App.cpp`
