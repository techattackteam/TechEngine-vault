# ADR-014 — Events (buffered streams) & StringId

- **Status:** Accepted
- **Date:** 2026-08 (Accepted 2026-08-02)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Related:** [[ADR-006 — v2 core architecture & module layout]] §1 §4 §5 ·
  [[ADR-007 — v2 networking & ECS replication foundation]] §1 §2 §3 §4 §6 ·
  [[ADR-011 — Diagnostics (Logger & Assert)]] §2 (registration idiom) §10 (SDK gate) ·
  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §6 (no runtime names per-frame) ·
  living *how*: [[Events — Design]] · [[StringId — Design]]
- **Task:** S3-D2 ([[2026-08 Sprint 03 — M1 Enablers]]) — **gates Story E and closes M1's
  second gate.**
- **Supersedes (partial):** **ADR-006 §4's `EventBus& events` field only**
  (`:186`) — event streams are `Scene` state, not an `EngineContext` service; every other
  §4 clause (DI rule, immutability, "holds no systems", F13 ownership) remains in force.
  **ADR-007 §6's "or the `EventBus` service" phrase only** (`:216`) — read "via components
  or event streams"; the never-a-sibling-system-ref rule stands and is strengthened.
  Bodies are not edited; rows are in [[ADR Index]]'s partial-supersessions table.

## Context

ADR-006 deferred "event-system redesign (F28)" to its own ADR. F28 at the source
(`v1-reference`): unsubscribe erases by comparing `std::function`s
(`EventManager.hpp:52-56`) — not equality-comparable, so observers cannot be reliably
removed; every dispatch is a `make_shared<EventType>` and every subscribe allocates a
`shared_ptr<Observer>` (`:20`, `:40-47`); the manager is copyable (`:31-33`), is a
`System` (F16), and carries two mutexes. [[Lessons from v1 (reference prototype)]]'s
verdict: keep type-keying, redesign subscription identity + allocation.

Three open decisions converge here:

- [[Game Loop — Frame Flow]]'s *event dispatch point* — drain at barriers or continuously.
- The event-id type, which pins **`StringId`** ([[Roadmap]] M1) — ADR-007 §1 already
  committed component identity to a "64-bit hash of an author-declared stable tag"
  without naming the primitive.
- Whether the [[Backlog]] Pool allocator's trigger ("Events, M1") fires.

The constraint that shapes everything: ADR-007 §6 runs systems in parallel within a phase
under declared access, and ADR-007 §4 reconciles by rewind+replay — so event semantics
must be race-free and replay-deterministic **by construction**, not by mutex.

## Decision

### 1. `StringId` — the one hashed-string primitive, in `base`

`base/StringId.hpp`: a value type wrapping a `u64` **FNV-1a** hash, `constexpr`-computable
from a literal via a plain constructor/UDL — **no macro**; a macro earns its place only
for compile-out or `source_location` capture, and hashing needs neither. Case-sensitive,
bytes as written, no normalization. The hash is what disk and wire carry (ADR-007 §1), so algorithm and
width are frozen **here**: FNV-1a/64.

- **No process-global intern table.** Identity is the hash — nothing order-dependent (the
  F1 shape), no lock on first use.
- **Collision policy: persistent identity requires a registering seam.** Any StringId that
  reaches disk or wire enters via registration and gets ADR-007 §1's collision
  `TE_CHECK`. Ad-hoc runtime keys are legal but unchecked.
- **Debug reverse-lookup (hash → string) is tooling-only** — never on a per-frame path
  (ADR-013 §6's rule, restated).
- `ComponentTypeId` (ADR-007 §1) is a typed wrapper over this scheme — implementing, not
  changing, ADR-007. `EventTypeId` (§2) is another.

### 2. Events are buffered per-type streams — no subscriptions, no callbacks

An event is a **trivially-copyable struct**; its payload is the struct's fields, and a
reader gets the concrete type back (per-type streams — no base class, no downcast). Its
author-declared stable tag is supplied at registration (§6) and hashes to `EventTypeId`
over StringId — no per-type macro. Publishers **write events by value** into the type's
stream; consumers **read via per-reader cursors** — each reader sees each retained event
exactly once.

F28 is not fixed; it stops being expressible. No unsubscribe exists because no
subscriptions exist; no per-event allocation exists because events are values in
contiguous buffers. Non-trivially-copyable payloads are rejected at registration — a
string payload carries a `StringId` or a handle (ADR-007 §2's POD discipline, same grain).

### 3. Dispatch point — visibility flips at phase barriers

- **No immediate dispatch.** A callback firing mid-phase executes under its *publisher's*
  declared access — unverifiable writes, exactly what ADR-007 §6 exists to prevent.
- **Publish stages; the barrier flips.** Events written during a phase become visible at
  that phase's end barrier — where structural changes already apply (ADR-007 §6). **Every
  `FixedUpdate` sub-step ends at that barrier** (the shape [[Game Loop — Frame Flow]]
  already draws): tick *k*'s events are visible to tick *k+1* and everything after.
- **Deterministic merge order:** publisher lanes merge at the barrier keyed by the
  publishing system's schedule position (the `Schedule` is data — add-order is stable),
  FIFO within a publisher. Replaying a tick re-produces the identical stream (ADR-007 §4).
- **Retention is bounded and reader-independent:** an event retires only after **both**
  one frame boundary **and** one fixed tick have passed since it became visible — so
  frame↔fixed cross-domain readers each get at least one look regardless of tick cadence
  (the classic fixed-timestep event footgun, closed by rule). A reader that did not run
  inside the window (disabled, role-gated — ADR-007 §4) misses silently; memory stays
  bounded by event rate × max(frame, tick period). Events never touch disk.

### 4. Event access is a **third access category** — declared, but outside the conflict rule

`SystemAccess` gains event read/write sets **beside** components and resources. ADR-007
§6's `conflict(A,B)` stays exactly as written — its domain is components and resources;
events are deliberately outside it, because staging + barrier flip make concurrent
publish/read race-free by construction. The declaration is not ceremony: the graph build
wires publisher lanes and reader cursors from it, and tooling gets "who publishes/reads
X" for free.

### 5. Residence — streams live on the `Scene`; there is no `EventBus` service

Same argument as sim time not living on the `Clock` ([[Game Loop — Frame Flow]]): a
process can run more than one sim (tests already run several headless sims — the v1
editor's client+server hosting is *not* a v2 scenario), the flip is per-sim tick
structure, and event buffers are frame-lifetime sim state — the wrong bucket for an
engine-lifetime `EngineContext` service either way.
Event *type* registration is process-global (mirrors ADR-007 §1: global registry,
per-`Scene` columns). Hence the two partial supersessions in the header.

### 6. Registration from the composition root — never file-scope statics

The tag is an argument at the registration call
(`registerEvent<CollisionEnter>("TechEngine.CollisionEnter")`-shaped), **invoked** from
the `app` composition root, engine types first, game DLL on load — ADR-007 §1's model,
for ADR-011 §2's reason (a static-lib TU whose only purpose is registration gets
linker-stripped). No file-scope statics, and no per-type macro — ADR-007 §1's
`TE_COMPONENT(…)` spelling is a sketch of this same seam, not a macro mandate.

### 7. No Pool primitive; non-goals

- Streams are contiguous, double-buffered, amortized — no fixed-size node churn. The
  [[Backlog]] Pool trigger dissolves; the Pool waits for its next candidate consumer.
- **Non-goals:** OS/input events (command/intent components at `Input` — ADR-007 §6);
  editor/tooling notifications (the editor is outside the loop — ADR-006 §1); the **wire**
  event/RPC channel (ADR-007 §3 — the registration seam reserves the on-wire fact, and a
  replicated event must survive until the encoder runs → netcode ADR); the script-facing
  API (scripting ADR, on the `te_sdk` façade — the first StringId header in `sdk/include/`
  triggers the smoke gate, ADR-011 §10's mechanic, expected not feared).

## Consequences

**Positive**

- **F28 dies structurally** — no subscription identity to get wrong, no per-event heap
  alloc, no mutexes; and the dispatch-point question closes with it.
- **Replay-deterministic and parallel-safe by construction** — the property ADR-007 §4/§6
  need, delivered by data layout rather than locking.
- **`StringId` lands with a wire-grade frozen contract**, and `ComponentTypeId` gets the
  primitive it was already described as.
- Bounded memory; nothing new to build in `base` allocators.
- Script ergonomics are recoverable at the façade (the runner drains cursors and calls
  `onEvent`-style hooks) without callbacks entering the engine model.

**Negative / open**

- **One-barrier latency, always.** Same-tick event chains are inexpressible; work that
  must settle same-tick belongs in the task graph as component data. Under ADR-010
  (*Proposed*) a script→system event is always next-tick (terminal slot + flip).
- **Pull is unfamiliar** next to "when X happens, call this" — a documentation and
  onboarding cost, concentrated on the script façade to hide.
- **Lossy for absent readers** — deliberate (bounded memory beats guaranteed delivery);
  a reader that must never miss belongs in every schedule role or reads component state.
- **If ADR-010 lands as written**, script event *publishes* must route through the façade
  so its "no unobserved script write path" assumption (§5a) generalizes to streams.
- Exact retirement bookkeeping across ×N ticks and fast frames is mechanism →
  [[Events — Design]], pinned before Story E is sized.

## Alternatives considered

- **v1 shape, repaired** — central pub/sub, handle-based unsubscribe, deferred queue; the
  [[Lessons from v1 (reference prototype)]] verdict leaned this way, and it is the
  familiar model. Rejected: callbacks execute outside any declared access set (parallel
  executor ⇒ race or global lock); deterministic ordering under parallel publishers needs
  the staging+merge machinery *anyway*; handles shrink but don't close the lifetime bug
  class (dangling captures); replay re-fires side effects. Repairing it converges on
  "queue + deterministic drain" — at which point callbacks are the only part left, and
  they are the part that breaks the model.
- **Events as ECS entities/components** — zero new machinery, access/replication free.
  Rejected: per-event structural churn through the command buffer, generational-slot
  pollution at volume, a cleanup system per type — and the same barrier latency anyway.
- **Immediate synchronous dispatch** — lowest latency. Rejected: reentrancy,
  order nondeterminism under parallelism, mid-phase writes outside declared access (§3).
- **`EventBus` as an `EngineContext` service** (ADR-006 §4's sketch) — rejected:
  multi-sim cross-talk (§5); the sketch predates the multi-sim argument.
- **Interned-pointer `StringId`** (pointer into a global table) — cheap compares.
  Rejected: registration-order dependence (a mild F1) plus a lock on first intern; a hash
  gives client/server identity by math.
- **`std::type_index` keys** (v1's) — already rejected by ADR-007 §1 (MSVC≠Clang, DLL
  boundary).
- **Per-source signals** (entt::sigh / Unity-style) — rejected: per-object subscription is
  per-object lifetime management; the F28 bug class multiplied by instance count.

## What would move this

- **A same-tick reaction that cannot be expressed** as graph-ordered component data — a
  real gameplay case in Story E or later, not a hypothetical → a scoped immediate channel
  (fixed-phase-only, serialized section) via amendment or successor.
- **Profiler evidence (ADR-013) that the barrier merge or stream memory is hot** at real
  event volumes → layout changes in [[Events — Design]]; the semantics here don't move.
- **A reader that legitimately cannot run every frame yet must not miss** → per-reader
  retention pinning; mechanism-level, note not ADR.
- **The registration `TE_CHECK` ever fires on FNV-1a/64** → rename the tag; if it fires
  twice, the hash upgrades — wire-breaking, so before the first baked asset, never after.
- **The netcode ADR finds bounded retention forecloses replicated events** → retention
  gains an encoder-pinned window; §3 otherwise stands.
- **ADR-010 changes shape** (scripts gain declared access) → script event access folds
  into the tier-1 path; nothing here assumes otherwise.

> Add to [[ADR Index]]. Once Accepted, treat as immutable — supersede with a new ADR.
