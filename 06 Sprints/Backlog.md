# 🗃️ Backlog

**A parking lot for ideas — one bullet each, nothing more.** Not a design doc, not a
planning source. Groom at `/sprint-plan`.

- **One bullet, a `#prio/…` and a `Trigger:`.** An entry that grows a decision, a rationale or
  a `How:` has outgrown this file — it belongs in an ADR or a design note
  ([[Planning Workflow — Artifact Gate]]).
- **Prio is *want*; `Trigger:` is *readiness*.** They are orthogonal and both must hold: a
  `#prio/xhigh` whose trigger has not fired is **not** pullable. Draining top-down means
  top-down *among the fired*. Not the board's `P1/P2/P3` — that scores value to one sprint's
  goal ([[Planning Workflow — Artifact Gate]] § *Priority + weight*); this scores value at all.
- **Five levels, re-bucketed at `/sprint-plan`:** `#prio/xhigh` › `#prio/high` ›
  `#prio/medium` › `#prio/low` › `#prio/xlow`. Filter with `tag:#prio/high` in search, or the
  tag pane. A bucket nobody re-scores downward is a broken bucket — that pass is part of
  grooming, not optional.
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

- #prio/xhigh · **Escape `<format>`'s weight** — `math/Format.hpp` is split from `Math.hpp`, and
  `FormatBuffer`/`FormatString` sit apart from their consumers, for one unmeasured reason:
  `<format>` is heavy in a header every TU sees ([[Math — Design]] § *Formatters in their own
  header*; [[ADR-011 — Diagnostics (Logger & Assert)]] § *Consequences*). Measure it, then ask
  whether the headers can drop `<format>` entirely or the split is simply the right shape.
  **Trigger:** fired — both headers exist and nothing gates the measurement.
- #prio/medium · **Allocators** — a Pool primitive. **Trigger:** a first consumer. Events
  declined it ([[ADR-014 — Events (buffered streams) & StringId]] §7 — contiguous streams, no
  node churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting
  ADR).

## platform

- #prio/medium · **File watching** — v1's `IFileWatcher`, for editor hot-reload; its
  callback-subscription shape needs re-reading against
  [[ADR-014 — Events (buffered streams) & StringId]]. **Trigger:** hot-reload being wanted (M6+).

## core

- #prio/medium · **Resources — hot-reload / eviction** — candidate ADR; depends on the
  UUID/cache model ported from v1 (F7, F13, F31). **Trigger:** the resource cache being real (M6).

## client

- *(none)*

## app

- #prio/high · **Frame pacing** — S2-T7's spin-to-deadline stand-in is not shippable; the
  Windows 15.6 ms timer evidence and the open questions live on [[Game Loop — Frame Flow]].
  **Trigger:** the first build that runs unattended.

## net

- #prio/low · **Debug assert on raw entity indices arriving over the wire** — catches a user
  component holding a slotmap index instead of a `NetId`. **Trigger:** the first replicated
  user component.

## server *(future module)*

- *(none — lands with N1)*

## scripting / `te_sdk` *(future module)*

- *(none)*

## editor & tooling *(exe)*

- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).

## etc — cross-cutting

- #prio/xhigh · **CI cache storage is at 7.89 GB / 10 GB across 199 entries** — every run writes
  a fresh timestamped `ccache-<leg>-<ts>` entry (`ci.yml:99`, `ci.yml:166`) instead of replacing
  one; investigate and cap it. **Trigger:** fired — observed Aug 6, LRU eviction already active.
- #prio/high · **Better way to add source/header files to CMake** — research the options
  (explicit lists, `CONFIGURE_DEPENDS` glob, generator script); current per-file editing is
  painful and v1's global glob was worse. **Trigger:** the next module that grows past a
  handful of files.
- #prio/high · **Memory-management design note** — the engine-wide map (lifetime tiers,
  per-module memory, handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- #prio/medium · **Point each dep's allocator hook at the profiler** — Jolt
  (`JPH::Allocate`/`Free`/aligned + `JPH_OVERRIDE_NEW_DELETE`), miniaudio
  (`ma_allocation_callbacks`), GLFW 3.4 (`glfwInitAllocator`) →
  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §7. **Trigger:** the first init of each dep.
- #prio/medium · **Path-filter docs-only PRs** — a vault-free docs change still burns the full
  matrix; needs the dummy-job pattern, not `paths-ignore`. **Trigger:** the second docs-only PR.
- #prio/medium · **Recorded-demo workflow** — capture + store. **Trigger:** the first demo
  worth keeping.
- #prio/low · **README at repo root** (public-facing). **Trigger:** T2 — the first build that
  runs outside the editor.
- #prio/xlow · **Retrofit `base` to the spelled-out-names rule** — `loc` / `fmtStr` predate it.
  **Trigger:** the next PR that touches those signatures for another reason.
- #prio/xlow · **Rename `TechEngine::detail` → `internal`** — 13 files, the `ci.yml`
  `\bdetail::log` guard and the CONVENTIONS *Open* row ratified Jul 30. **Trigger:** fired —
  mechanical, nothing gates it.
- #prio/xlow · **Command `/catch-up`** — session re-entry after a multi-day gap. **Trigger:**
  the first session that opens with "where was I".

## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and a `Trigger:`_
