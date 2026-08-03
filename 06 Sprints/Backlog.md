# 🗃️ Backlog

**A parking lot for ideas — one bullet each, nothing more.** Not a design doc, not a
planning source. Groom at `/sprint-plan`.

- **One bullet + a `Trigger:`.** An entry that grows a decision, a rationale or a `How:` has
  outgrown this file — it belongs in an ADR or a design note ([[Planning Workflow — Artifact Gate]]).
- **Decided ⇒ deleted.** The moment a decision lands in an ADR or a design note, the entry
  goes — no tombstone, no trace. [[ADR Index]] is the record of what's settled.
- **Scheduled ⇒ deleted.** Pulling into a sprint is a **move**, not a copy — the entry is cut
  as the card is written. There is no `✅ Scheduled` state and no "done" state.
- **On the ladder ⇒ deleted.** [[Roadmap]] owns *sequencing*, which is what a `Trigger:` was
  doing. An entry that is only a thing plus a trigger is superseded the moment a rung carries
  it. What survives here is what no rung names.

Grouped by module ([[ADR-006 — v2 core architecture & module layout]] §1). Empty groups are
kept — they show where future work lands.

---

## base

- **Allocators** — a Pool primitive. **Trigger:** a first consumer. Events declined it
  ([[ADR-014 — Events (buffered streams) & StringId]] §7 — contiguous streams, no node
  churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting ADR).

## platform

- **File watching** — v1's `IFileWatcher`, for editor hot-reload; its callback-subscription
  shape needs re-reading against [[ADR-014 — Events (buffered streams) & StringId]].
  **Trigger:** hot-reload being wanted (M6+).

## core

- **Resources — hot-reload / eviction** — candidate ADR; depends on the UUID/cache model
  ported from v1 (F7, F13, F31). **Trigger:** the resource cache being real (M6).

## client

- *(none)*

## app

- **Frame pacing** — S2-T7's spin-to-deadline stand-in is not shippable; the Windows 15.6 ms
  timer evidence and the open questions live on [[Game Loop — Frame Flow]].
  **Trigger:** the first build that runs unattended.

## net

- **Debug assert on raw entity indices arriving over the wire** — catches a user component
  holding a slotmap index instead of a `NetId`. **Trigger:** the first replicated user component.

## server *(future module)*

- *(none — lands with N1)*

## scripting / `te_sdk` *(future module)*

- *(none)*

## editor & tooling *(exe)*

- **Frame capture / debug-visualization tools.** **Trigger:** a renderer to inspect (R2).

## etc — cross-cutting

- **Point each dep's allocator hook at the profiler** — Jolt (`JPH::Allocate`/`Free`/aligned
  + `JPH_OVERRIDE_NEW_DELETE`), miniaudio (`ma_allocation_callbacks`), GLFW 3.4
  (`glfwInitAllocator`) → [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §7.
  **Trigger:** the first init of each dep.
- **Retrofit `base` to the spelled-out-names rule** — `loc` / `fmtStr` predate it.
  **Trigger:** the next PR that touches those signatures for another reason.
- **Path-filter docs-only PRs** — a vault-free docs change still burns the full matrix; needs
  the dummy-job pattern, not `paths-ignore`. **Trigger:** the second docs-only PR.
- **Memory-management design note** — the engine-wide map (lifetime tiers, per-module memory,
  handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- **README at repo root** (public-facing). **Trigger:** T2 — the first build that runs outside
  the editor.
- **Recorded-demo workflow** — capture + store. **Trigger:** the first demo worth keeping.
- **Better way to add source/header files to CMake** — research the options (explicit lists,
  `CONFIGURE_DEPENDS` glob, generator script); current per-file editing is painful and v1's
  global glob was worse. **Trigger:** the next module that grows past a handful of files.
- **Command `/catch-up`** — session re-entry after a multi-day gap. **Trigger:** the first
  session that opens with "where was I".

## Ideas (unsorted)

- _drop raw ideas here; triage later_
