# Clock — Design

> Living design doc. **Status: accepted** (2026-08-02) — drafted in the 2026-07-25 planning
> session (light artifact per [[Planning Workflow — Artifact Gate]]), shipped by S2-T6 and
> closed out by S2-T7/T8. Build to it.
> **ADR = the decision; this doc = the _how_.** No ADR is owed here — the Clock is local
> to `base`, reversible, and its shape was settled in [[Game Loop — Frame Flow]].

**Module:** `base` · **Kind:** utility (helper you *call*) · **Status:** accepted — implemented (S2-T6)
**ADRs:** [[ADR-006 — v2 core architecture & module layout]] §4 §6 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §5
**Consumers:** the app loop (writes) · [[Logger — Design]] / [[Profiler — Design]] (read the frame stamp)
**Sprint:** [[2026-08 Sprint 02 — Base Foundation]] — S2-T6

## Purpose

The engine's **time source** — and deliberately nothing more. The hard part of this
design is what the Clock *refuses* to own.

## Decided

| Fact | Where |
|---|---|
| Read-only time facade in `EngineContext` as `const Clock&` — loop writes, systems read | ADR-006 §4 |
| Lives in **`base`**, no `platform` seam — `steady_clock` is std and QPC-backed | this note → *Open questions* (a raw platform timer only if the Profiler measures a need) |
| Owns: monotonic `now()`, wall-clock stamp, `totalTime`, **diagnostic** frame counter | [[Game Loop — Frame Flow]] (2026-07-24) |
| Does **not** own `dt` / `fixedDt` / `tick` / `alpha` / `role` — those live on `FrameContext` | [[Game Loop — Frame Flow]] (2026-07-24), ADR-007 §5 |
| Monotonic for **durations**; wall-clock **only** for stamps | this note (local call; no ADR owes it) |
| The frame stamp is **pushed by `app`** into diagnostics — `base` holds no `Clock` reference | [[ADR-011 — Diagnostics (Logger & Assert)]] §9 |
| `timeScale` / pause / slow-mo is **loop policy**, not a Clock knob | [[Game Loop — Frame Flow]] |
| **No testability seam** — the loop takes its delta as a parameter, so nothing fakes the Clock | S2-T7 (2026-07-30), below |

## Design

### Why sim time is not here

A process can host **more than one sim** — the editor hosts a client *and* a server (v1's
F1 trigger), and tests run several headless sims. A process-wide Clock can hold exactly one
`tick`/`alpha`, and `role` is meaningless as a global. `FrameContext` is per-call, so each
sim carries its own. Full rationale: [[Game Loop — Frame Flow]] → *Where time lives*.

### The frame counter is correlation-only

[[Logger — Design]]'s `[f 1043]` stamp and the Profiler are **global macros** and cannot take a
`FrameContext` — they need an ambient number. So the Clock keeps one, and it is **approximate when two
sims share a process**. It is never the simulation's source of truth; anything that must be exact reads
`FrameContext.tick`.

**The Clock owns the counter; it does not hand itself to the Logger.** `app` reads `frame()` and
**pushes** the value into diagnostics once per frame — an ambient global `Clock*` read from a log macro
would be a second access path to an `EngineContext` service, which ADR-006 §4 exists to remove.
Decided in [[ADR-011 — Diagnostics (Logger & Assert)]] §9.

### Surface (shape, not a spec — impl decides the details)

| Call | Returns | For |
|---|---|---|
| `now()` | monotonic `TimePoint` | durations, the loop's `dt` |
| `totalTime()` | seconds since start | ambient elapsed |
| `wallClock()` | `system_clock` stamp | log timestamps only |
| `frame()` | diagnostic counter | Logger/Profiler correlation |

The loop is the only writer: it computes `dt` from `now()` and bumps `frame()` once per
frame. Everything else takes `const Clock&`.

### Testability seam — RESOLVED, there isn't one (S2-T7, 2026-07-30)

The open question was (a) inject the loop's delta vs (b) put a seam inside `Clock`. **(a), taken
one step further:** `FrameLoop::advance(frameDeltaTime)` is a pure function of its parameter and
holds **no `Clock` reference at all**. Sampling `now()`, bumping `advanceFrame()` and pushing the
diagnostic stamp all live in `app`'s driver (`engine/app/src/App.cpp`).

So the determinism/clamp tests (S2-T8) call `advance()` with a synthetic delta sequence: no fake
clock, no virtual, and `Clock` stays the concrete no-seam utility this note wanted.

## Open questions

- **Profiler-grade resolution.** Whether `steady_clock` is precise enough, or a raw
  platform timer is needed — **measure first** (CLAUDE.md perf rule), and there is no
  profiler yet to measure with. Revisit when the Profiler lands (Sprint 03+).

## References

- [[Game Loop — Frame Flow]] — where sim time lives, and why not here
- [[Logger — Design]] — the `[f N]` stamp consumer
- Code: `engine/base/include/TechEngine/base/Clock.hpp` · `engine/base/src/Clock.cpp` ·
  its only writer, `engine/app/src/App.cpp`
