# 🗃️ Backlog

**A parking lot for ideas — one bullet each, nothing more.** Not a design doc, not a
planning source. Groom at `/sprint-plan`.

- **One bullet + a `Trigger:`.** An entry that grows a decision, a rationale or a `How:` has
  outgrown this file — it belongs in an ADR or a design note ([[Planning Workflow — Artifact Gate]]).
- **Decided ⇒ deleted.** The moment a decision lands in an ADR or a design note, the entry
  goes — no tombstone, no trace. [[ADR Index]] is the record of what's settled.
- **Scheduled ⇒ deleted.** Pulling into a sprint is a **move**, not a copy — the entry is cut
  as the card is written. There is no `✅ Scheduled` state and no "done" state.

Grouped by module ([[ADR-006 — v2 core architecture & module layout]] §1). Empty groups are
kept — they show where future work lands.

---

- 🎯 **C2 — first v2 vertical slice.** First end-to-end slice on the ADR-008 scaffold; the
  renderer ADR is born here. **Trigger:** Sprint 03 planning (end Aug).

## base

- **FrameAllocator** — `EngineContext` carries it (ADR-006 §4) and ADR-007 §2's no-per-tick-heap
  promise rides on it. **Trigger:** replication, or the job-system era — whichever lands first.
- **Memory tracking** — tag allocations by subsystem, track high-water / budgets / leaks; emits
  into [[Profiler — Design]]. **Trigger:** with the Profiler.
- **Math** — engine helpers over glm (ADR-005). **Trigger:** as C2 needs it.
- **Allocators** — a Pool primitive for its first consumers (events/particles). **Trigger:** those consumers.
- **Containers** — SlotMap/HandleMap and a ring buffer, in `base`. **Trigger:** their first consumers.

## platform

- **glad2 GL loader** — fetched in `cmake/deps.cmake`, deliberately built into nothing.
  **Trigger:** the first GL 4.5 context (the C2 slice).

## core

- **Job-system / task-graph** — needs its own ADR; execution view →
  [[Task Graph — Execution Flow]]. **Trigger:** the ECS + app-loop slice being real.
- **Resources — hot-reload / eviction** — candidate ADR; depends on the UUID/cache model ported from v1 (F7, F13, F31). **Trigger:** the resource cache being real.
- **Serialization** — custom binary format for assets + scenes; needs its own ADR, on the
  critical path. **Trigger:** the first asset or scene that must survive a restart.
- **Physics (Jolt)** — *(none — rides in with C2)*

## client

- **Renderer / render graph** — needs the v2 renderer ADR, written when building it.
  **Trigger:** C2, with v1 passes as reference.
- Post-C2 rendering ideas: atmospheric scattering · volumetric fog · volumetric shadows /
  god rays · auto-exposure + bloom.
- **Audio (miniaudio)** — *(none — lands when a slice needs sound)*

## app

- **Loop phases + frame pacing** — the five phases, the barrier, and a real pacer; open
  questions live on [[Game Loop — Frame Flow]]. **Trigger:** the C2 loop / first sim slice.

## net

- **Netcode transport** — needs its own ADR (ENet · GameNetworkingSockets · yojimbo).
  **Trigger:** the `server` module becoming real.
- **Per-component-type byte counters in the encoder** — replication cost as a number, not a
  feeling. **Trigger:** the first real replication slice.
- **Debug assert on raw entity indices arriving over the wire** — catches a user component
  holding a slotmap index instead of a `NetId`. **Trigger:** the first replicated user component.

## server *(future module)*

- *(none — lands with the netcode transport)*

## scripting / `te_sdk` *(future module)*

- **Native C++ script DLL SDK & hot-reload** — needs its own ADR (façade shape, ownership,
  hot-reload, ABI stability). **Trigger:** when scripting becomes real, post-C2.

## editor & tooling *(exe)*

- **Frame capture / debug-visualization tools.** **Trigger:** a renderer to inspect.

## etc — cross-cutting

- **Retrofit `base` to the spelled-out-names rule** — `loc` / `fmtStr` predate it.
  **Trigger:** the next PR that touches those signatures for another reason.
- **Path-filter docs-only PRs** — a vault-free docs change still burns the full matrix; needs
  the dummy-job pattern, not `paths-ignore`. **Trigger:** the second docs-only PR.
- **Memory-management design note** — the engine-wide map (lifetime tiers, per-module memory,
  handles-not-pointers). **Trigger:** after ECS + resources + renderer are real.
- **README at repo root** (public-facing). **Trigger:** the first slice worth showing.
- **Recorded-demo workflow** — capture + store. **Trigger:** the first demo worth keeping.
- **Command `/catch-up`** — session re-entry after a multi-day gap. **Trigger:** the first
  session that opens with "where was I".
- **Skill `te-review`** — engine review rubric over the ADR structural invariants.
  **Trigger:** wanted now — `CONVENTIONS.md` landed Jul 30.

## Ideas (unsorted)

- _drop raw ideas here; triage later_
