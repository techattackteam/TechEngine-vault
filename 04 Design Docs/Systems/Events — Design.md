# Events — Design

> Living design doc. **Status: active.** This is the hub for the *how*. The decision is
> [[ADR-014 — Events (buffered streams) & StringId]], accepted 2026-08-02.

**Module:** `core` (the streams live on `Scene`) · **Kind:** engine mechanism, not a System
**ADRs:** [[ADR-014 — Events (buffered streams) & StringId]] ·
[[ADR-007 — v2 networking & ECS replication foundation]] §4 §6 ·
[[ADR-006 — v2 core architecture & module layout]] §1 §4
**Id primitive:** [[StringId — Design]]

## Purpose

Discrete notifications that cross systems and reach scripts. "Collision entered", "entity
damaged", and so on.

The point is that none of it uses callbacks. Instead there are per-type buffered streams,
writes are staged, they become visible at a barrier, and readers hold cursors.

That fixes **F28** structurally, rather than by convention.

## Decided

| Fact | Where |
|---|---|
| Buffered per-type streams. No subscriptions and no callbacks. | ADR-014 §2 |
| An event is a trivially-copyable struct plus a stable tag, which becomes an `EventTypeId` over a `StringId`. | ADR-014 §2 §1 |
| Events become visible at phase barriers, including every FixedUpdate sub-step. | ADR-014 §3 |
| Merge order is the publisher's schedule position, then FIFO within a publisher. A replay is identical. | ADR-014 §3 |
| Retention: an event retires only after at least one frame boundary **and** at least one fixed tick. It is reader-independent, so it is lossy for an absent reader. | ADR-014 §3 |
| Event access is a third `SystemAccess` category, and it creates no conflict edges. | ADR-014 §4 |
| Streams are per-`Scene`. There is no `EventBus` service and no `EngineContext` field. | ADR-014 §5 |
| Type registration is process-global, invoked from the composition root. Never through file-scope statics. | ADR-014 §6 |
| No Pool primitive is needed. | ADR-014 §7 |
| Out of scope: OS and input events · editor notifications · the wire RPC channel · the script façade API. | ADR-014 §7 |

## Consumers, from v1's event taxonomy at `v1-reference`

| v1 events | What happens to them in v2 |
|---|---|
| Physics `OnCollision*` and `OnTrigger*` (`core/src/events/physics/`) | Streams, in the fixed domain. This is the first real consumer, at M5 or later. |
| Scene lifecycle: `EntityCreated`, `EntityDeleted`, `ComponentAdded`, `ComponentRemoved` | Maybe **not events at all**. Structural changes already flow through the barrier's command buffer (ADR-007 §6). Decide when a consumer appears. |
| Input events (`client/events/input/`) | **Not events.** They become command and intent components at `Input` (ADR-007 §6). |
| Resource created and deleted | Editor-side. The editor sits outside the loop, so these stay direct calls rather than streams. |
| UI widget events | Client-side, in the frame domain. Later. |
| The `editorWatchDog` catch-all callback | The editor observes streams after a frame. That needs a read API outside the schedule, which is open below. |

## Mechanism

Pinned 2026-08-02, before Story E.

### Stream anatomy

There is one stream per event type, living on the `Scene`.

A stream is a contiguous buffer of events carrying **absolute `u64` sequence numbers**. Three
positions cut it up: the retirement head, the visible end, and the staging tail.

ADR-014 calls this "double-buffered". It is realized as one buffer, not two.

> Where this note says "ring", read it as the linear compacted buffer described under
> *Stream storage*. Amended 2026-08-06.

### Staging, at M1

The executor is serial until P1, because the task graph runs level by level on one thread. So
there is **one staging buffer per stream**.

That is enough, because the append order already *equals* ADR-014 §3's merge key: schedule
position, then FIFO within a publisher.

P1's workers layer per-thread lanes and a real merge on top, under the **same key**. The
semantics do not change. [[ADR-015 — Threading (sim on main, render thread owns GL)]] §5
made `publish` **sim-thread-only until P1** and left the lane layout to P1. (Updated
2026-08-22; this section previously said "until M2" and named the threading ADR as the
layout's owner.)

### Making events visible

At every barrier, including every fixed sub-step, the staged batch becomes visible and a mark
is recorded: `{endSeq, frameIndex, tick}`.

This is cheap. Nothing is copied, because the buffer is shared.

### Retiring

Once per frame, at frame start and before `Input`, the leading batches are dropped. A batch
goes when `currentFrame > mark.frame` **and** `currentTick > mark.tick`. That is ADR-014 §3's
rule.

Both halves of it matter. A fast frame that runs zero ticks leaves `tick` unadvanced, so
batches survive until a tick actually runs. A slow frame running many ticks retires at the
next frame boundary.

The retention window is therefore at most the longer of one frame and one tick period.

### Cursors

There is one cursor per reader system per stream, and a cursor is a `u64` sequence number.

It is owned by the reader's schedule entry, and wired at graph-build time from the declared
event access (ADR-014 §4).

A read clamps the cursor forward to the retirement head. So a lagging reader silently misses
events (ADR-014 §3). It never dangles.

### The registration record

A record holds the tag mapped to its `EventTypeId`, the dense stream index, `sizeof` and
`alignof`, a compile-time trivially-copyable check, and a reserved wire flag.

The tag arrives as a call argument from the composition root (ADR-014 §6).

### Tooling and editor reads

This covers v1's watchdog use case. It is an ordinary cursor, advanced at the host's
between-frames point.

Same stream API, and no second access path. The UX question lands at T1.

### Profiler zones

`TE_PROFILER_SCOPE` goes on `makeVisible` and `retire`, with literal names (ADR-013 §6). It
lands with the cards, since Story D's macros exist by then.

## Registry

Pinned 2026-08-06, with S3-T8.

It lives in `core/events/`, one folder per design note (`CONVENTIONS.md` → *Headers*).

`EventTypeId` is a struct over a **private** `StringId`, which is the [[StringId — Design]]
shape. `ComponentTypeId` will want the same shape. *That* is when a shared wrapper earns its
place, not now.

| Call | Shape |
|---|---|
| **Residence** | An app-owned `EventRegistry` object, **not a singleton**. §5's multi-sim argument applies here unchanged, and ADR-014 §6's "process-global" describes identity scope rather than storage. Tests build one per case, so no test-only reset hook exists. |
| **Type to id** | An `internal` inline variable per `T`, written by `registerEvent<T>` and read by `eventTypeId<T>()`. It holds the **id only**. The id is a pure function of the tag, so two registries agree on it. The dense index is registry state, resolved by lookup. It is not a self-registering static, so §6 still holds. |
| **Tag storage** | An owning `std::string`. A `string_view` would dangle the moment a game DLL unloads. |
| **Wire flag** | `EventWire{Local, Replicated}`, defaulting to `Local`. Nothing reads it at M1. A bare `bool` at the call site would read as nothing at all. |

**Four rejections, each an always-on `TE_CHECK`:** an empty tag, a tag that hashes to 0, a
duplicate id with a different tag (ADR-007 §1's collision), and a tag that is already
registered.

The last one is a bug either way. The composition root is a single ordered list, and two types
cannot share a tag.

**Only two of the four are reachable from a test.**

The collision and the zero-hash both need an FNV-1a/64 preimage to trigger. So they are field
guards, verified by reading the code rather than by Catch2.

That is *why* the empty tag earns a guard of its own (2026-08-06, with S3-T8). It is the
mistake a human actually makes. And an empty tag hashes to the offset basis, which is a valid
id, so it cannot ride on the zero check.

**A rejected registration leaves the registry unchanged and returns the invalid id.**
`TE_CHECK` is fatal by default. But a test handler can return `{false, false}`, and execution
then **continues** past the check. So the code after the check is real code that runs, not
theory.

## Stream storage

Pinned 2026-08-06, with S3-T9.

**Storage.** One **type-erased** `EventStream` over a byte buffer, sized from the registry
record. `EventStreamManager` holds a `std::vector<EventStream>`, indexed by the dense stream
index, and the driver owns the manager (see *Container and loop wiring*). `publish<T>`
memcpys, because registration already guaranteed the type is trivially copyable. `read<T>`
asserts that the stream's id is `eventTypeId<T>()`, so type safety here is a runtime check
rather than one the compiler makes.

**Overflow.** A capacity hint is given at registration, and growth is **geometric**. In steady
state nothing allocates, which is the property the card's `operator new` count asserts. A leak
then shows up as growth rather than as silent loss. This is bounded in practice, not by
construction.

**Reads.** Compaction is **eager, on every retire**. So the visible region is always
contiguous, and `read<T>` returns a single `std::span`.

**Spelling.** ADR-014 §3's *flip* is spelled **`makeVisible(frame, tick)`** in code, and its
mark is an `EventBatchMark`. "Flip" is GPU page-flip vocabulary, and it implies two buffers
swapping, which is exactly the mechanism this section replaced. Same refinement precedent as
`dt` becoming `deltaTime` (`CONVENTIONS.md` → *Names are spelled out*). The ADR is not edited.

### Compaction replaces the wrap, so the buffer is linear rather than a ring

Retire drops the retired batches, then memmoves what is left down to the front. Publishes only
ever append at the tail.

That has four consequences.

- **The head's *index* is always 0**, while its *sequence* still climbs with every retire. So
  no head index is stored, there is no compact-or-grow decision to make, and free space is
  always at the tail. That is one fewer state variable and one fewer branch than the lazy
  variant below.
- An index is `seq − retireHeadSeq`, with **no modulo anywhere**. The arithmetic gets simpler,
  not harder.
- Growth is the *only* overflow path, since a compaction that just ran frees nothing.
- The cost is one `O(retained)` move per frame per stream, paid unconditionally. It happens
  whether or not anything would have wrapped, and whether or not the buffer is near full.

**Lazy compaction was weighed and dropped** on 2026-08-06.

Compacting only when the tail hits capacity would make retire an O(1) index advance, and it
would still keep single-span reads. The cost is a buffer sized for the retained events *plus*
everything published between compactions, along with the extra state listed above.

It was chosen against deliberately. Simplicity now, with the profiler as the trigger to
revisit.

ADR-014 §7 asks for something contiguous, double-buffered and amortized, with no fixed-size
node churn. This satisfies that, so nothing here reaches the ADR.

## How one stream works

Two members carry everything.

| Member | Holds |
|---|---|
| `m_storage` | The events, as one flat byte array of `capacity × elementSize`. Index 0 is **always** the oldest retained event. |
| `m_marks` | One entry per batch made visible: `{endSequence, frameIndex, tick}`. These are not events. They are the bookkeeping that lets `retire` apply ADR-014 §3's rule, because that rule is about *when* a run of events became visible. |

Three `u64` positions cut the storage into three regions. They are **absolute sequence numbers,
never indices**. An index is `seq − m_retireHeadSequence`, so sequences keep counting up forever
while indices stay small.

| Region | From | To | Who sees it |
|---|---|---|---|
| **Visible** | `m_retireHeadSequence` | `m_visibleEndSequence` | Readers, through their cursors |
| **Staged** | `m_visibleEndSequence` | `m_stagingTailSequence` | Nobody yet |
| **Free** | `m_stagingTailSequence` | `m_capacity` | Nobody |

| Call | What moves |
|---|---|
| `publish<T>` | Writes one element at the end of the staged region and increments `m_stagingTailSequence`. It grows the buffer only if the tail hit capacity. **Readers observe no change.** |
| `makeVisible(f, t)` | Sets `m_visibleEndSequence = m_stagingTailSequence`, so the staged region joins the visible one, and pushes a mark `{that sequence, f, t}`. **No bytes move.** It is a no-op when nothing was staged, so a quiet sub-step records no mark. |
| `retire(f, t)` | Walks `m_marks` from the front while `f > mark.frameIndex && t > mark.tick`. It takes the last such `endSequence` as the new head, erases those marks, then memmoves what survives down to index 0. |

```mermaid
flowchart LR
    A["publish<br/>written at the tail"] --> B["staged<br/>invisible to readers"]
    B -->|"makeVisible(f, t)"| C["visible<br/>cursors can read it"]
    C -->|"retire(f, t)<br/>only after a frame AND a tick"| D["gone<br/>space reclaimed by compaction"]
```

A cursor is one `u64`. Reading hands back everything from the cursor up to
`m_visibleEndSequence`, then parks the cursor there. That is exactly-once delivery by
construction.

A cursor older than `m_retireHeadSequence` is clamped forward to it. That is how a lagging
reader misses silently instead of dangling.

## Container and loop wiring

Pinned 2026-08-08, with S3-T10.

`EventStreamManager` (`core/events/`) owns the `std::vector<EventStream>`, indexed by the
registry's dense stream index.

It is driver-owned at M1. **This is the object that moves onto `Scene` at M5** (ADR-014 §5),
and nothing else about its shape changes when it does.

| Call | Shape |
|---|---|
| **Construction** | `EventStreamManager{registry}` builds one stream per record, so **every `registerEvent` must precede it**. That is enforced rather than documented: the constructor takes a non-const `EventRegistry&` and **seals** it, and a later registration is a `TE_CHECK` naming the tag. The failure then lands on the registration that caused it, instead of on the first publish. |
| **Lookup** | `getStream(id)` returns a **pointer**, gated by `TE_VERIFY` on both "record found" and "index in range". On a miss, `publish` drops and `read` returns an empty span. An always-on check **plus** a defined path is the same shape as a rejected registration, and it is what makes the miss reachable from a test. |
| **Capacity** | One `initialCapacity` for every stream. The per-type hint that *Stream storage* assumes has no home yet, because `EventTypeRecord` carries no capacity field. Open below. |
| **Profiler** | Zones go on the **container's** `makeVisible` and `retire`, not on `EventStream`'s. That is one zone per barrier, rather than one per stream per sub-step (ADR-013 §6). |

**The loop stays ignorant of events.**

`FrameLoop::advance(deltaTime, onFixedStep)` calls the hook once per fixed sub-step, after
`tick++`. The driver's hook is what publishes and calls `makeVisible`.

Everything else is driver-side: the frame-tail `makeVisible`, the cursor read, and then
`retire` **last**.

That hook is what becomes `FixedUpdate`'s slot at M5.

Three ordering facts, each of which is a silent bug if reversed.

- `frameIndex` and `deltaTime` are set **before** the sub-step loop, so the hook stamps its
  marks with the current frame. `alpha` cannot be set there, because it is not known until the
  accumulator settles.
- `retire` at the frame **tail** is ADR-014 §3's "frame start" in a rotated loop. Putting it
  there is what stops it dropping a batch that the tail read never saw.
- A frame that runs zero ticks runs no hook at all. Nothing is published, and nothing retires
  either, because the tick did not advance.

## Open (deliberately, and each has an owner)

- **The script façade surface.** Something `onEvent<T>`-shaped, drained by the runner, with
  publishes routed through the façade. **Owner:** the scripting ADR.
- **Binding a cursor to a system is mandatory, not sugar.** Sharpened 2026-08-08, after
  S3-T10. `read<T>(cursor)` needs the *caller* to hold the cursor, and a system cannot: the
  cursor lives on its schedule entry. So the executor has to bind the stream and the cursor
  before the system body sees either. That is a view handed in, or the drain below. It is
  deferred deliberately until there is a `Schedule` to test it against. **Owner:** the
  task-graph ADR.
- **An engine-side `onEvent<T>` for C++ systems.** The executor would drain at the system's
  slot and call a handler, instead of the system body writing its own `read` loop. Same pull,
  same barrier, so this is sugar rather than a semantic change. The loop stays the primitive,
  because batch access and a tight span read are not recoverable from a per-event callback.
  The payoff is deriving the system's event access set from the registration instead of
  hand-declaring it. **Owner:** the task-graph ADR, since nothing can invoke it until
  `Schedule` and `SystemAccess` exist. Raised 2026-08-06 during S3-T9, because the raw call
  site read badly.
- **Per-thread staging lanes and their merge.** The semantics are fixed above. **Owner:**
  **P1**, re-scoped by [[ADR-015 — Threading (sim on main, render thread owns GL)]] §5:
  `publish` is sim-thread-only until then.
- **Rewind truncation for client reconciliation.** ADR-014 §3 asserts that a replayed tick
  reproduces an identical stream, but nothing says how the mispredicted run's events leave.
  `retire` only drops from the front, so a rewind needs a **tail** truncation: drop back to a
  sequence, erase those marks, and pull any cursor past it backwards. Reader cursors are rewind
  state too, because a system that already consumed tick N needs its cursor restored or the
  replay never re-delivers. Replayed side effects such as sound and VFX are a separate problem,
  which the ADR already names against the v1 shape. It is bounded in practice: ADR-007 §4
  replays unacked commands only, and its *Confirmed forks* section is snapshot plus
  interpolation, not rollback. **Owner:** the netcode transport ADR at M4. Raised 2026-08-06
  during S3-T9.
- **Editor watchdog UX**, meaning what the editor shows and how it filters. The read path is
  pinned above. **Owner:** T1.
- **API spelling**, covering `publish<T>` and `read<T>`'s view type, and the header layout.
  This is a naming pass rather than a decision. **Owner:** implementation plus
  `CONVENTIONS.md`.
- **Re-registration on DLL reload.** The registry rejects a second `registerEvent<T>`, so a
  reloaded game DLL cannot re-register its types. **The seal added at S3-T10 closes the door
  further:** once the streams are built, *no* registration is accepted, reload or not. Both are
  the same constraint made explicit rather than a new one, and no reload exists at M1.
  **Owner:** the module and script reload work, whenever it lands.
- **A per-type capacity hint.** Every stream is built with one shared `initialCapacity`,
  because `EventTypeRecord` has no capacity field. Growth is geometric, so a hot stream costs
  a few early reallocations rather than being wrong. **Owner:** the first event type with a
  known high rate. Add the field then, with a real number behind it.

## References

- [[ADR-014 — Events (buffered streams) & StringId]]: the decision and its alternatives
- [[Game Loop — Frame Flow]]: the barriers, the N fixed ticks, and where the barrier sits
- [[v1 Code Audit]] F28 · `EventManager.hpp` at `v1-reference`: the prior art
- Bevy's `Events<T>` and `EventReader`: the closest prior art for the pull model. The
  retention rule here differs: it is tick-aware rather than a count of N frames.
