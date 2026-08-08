# Events — Design

> Living design doc. **Status: active** — hub for the *how*; the decision is
> [[ADR-014 — Events (buffered streams) & StringId]] (**Accepted 2026-08-02**).

**Module:** `core` (streams on `Scene`) · **Kind:** engine mechanism (not a System)
**ADRs:** [[ADR-014 — Events (buffered streams) & StringId]] ·
[[ADR-007 — v2 networking & ECS replication foundation]] §4 §6 ·
[[ADR-006 — v2 core architecture & module layout]] §1 §4
**Id primitive:** [[StringId — Design]]

## Purpose

Cross-system + script-facing discrete notifications ("collision entered", "entity
damaged") without callbacks: per-type buffered streams, staged writes, visibility at the
barrier, reader cursors. Fixes F28 structurally.

## Decided

| Fact | Where |
|---|---|
| Buffered per-type streams; no subscriptions, no callbacks | ADR-014 §2 |
| Event = trivially-copyable struct + stable tag → `EventTypeId` over `StringId` | ADR-014 §2, §1 |
| Events become visible at phase barriers, incl. every FixedUpdate sub-step | ADR-014 §3 |
| Merge order: publisher's schedule position, FIFO within publisher — replay-identical | ADR-014 §3 |
| Retention: retires only after ≥1 frame boundary **and** ≥1 fixed tick; reader-independent; lossy for absent readers | ADR-014 §3 |
| Event access = third `SystemAccess` category; no conflict edges | ADR-014 §4 |
| Streams are per-`Scene`; no `EventBus` service, no `EngineContext` field | ADR-014 §5 |
| Type registration process-global, invoked from composition root (never file-scope statics) | ADR-014 §6 |
| No Pool primitive needed | ADR-014 §7 |
| Out of scope: OS/input events · editor notifications · wire RPC channel · script façade API | ADR-014 §7 |

## Consumers (from v1's event taxonomy, `v1-reference`)

| v1 events | v2 fate |
|---|---|
| Physics `OnCollision*/OnTrigger*` (`core/src/events/physics/`) | streams, fixed domain — first real consumer (M5+) |
| Scene lifecycle (`EntityCreated/Deleted`, `ComponentAdded/Removed`) | maybe **not events** — structural changes already flow through the barrier command buffer (ADR-007 §6); decide when a consumer appears |
| Input events (`client/events/input/`) | **not events** — command/intent components at `Input` (ADR-007 §6) |
| Resource created/deleted | editor-side; editor is outside the loop → direct, not streams |
| UI widget events | client, frame domain — later |
| `editorWatchDog` catch-all callback | editor observes streams after-frame; needs a read API outside the schedule — open below |

## Design — mechanism (pinned 2026-08-02, pre-Story-E)

**Stream anatomy.** One stream per event type, on the `Scene`: a contiguous buffer of
events with **absolute `u64` sequence numbers**, three positions — retirement head ·
visible end · staging tail. ADR-014's "double-buffered" realized as one buffer, not two.
*(Read "ring" here as the linear compacted buffer below — amended 2026-08-06.)*

**Staging (M1).** Executor is serial until M2 (task graph runs level-by-level, one
thread) → **one staging buffer per stream**; append order already *equals* ADR-014 §3's
merge key (schedule position, FIFO per publisher). M2's pool layers per-thread lanes +
a real merge under the **same key** — semantic unchanged, threading ADR owns the layout.

**Make visible.** At each barrier (incl. every fixed sub-step): staged batch becomes
visible; record a mark `{endSeq, frameIndex, tick}`. Cheap — no copy, the buffer is shared.

**Retire.** Once per frame, at frame start (before `Input`): drop leading batches where
`currentFrame > mark.frame` **and** `currentTick > mark.tick` — the ADR-014 §3 rule.
Fast 0-tick frames leave `tick` unadvanced → batches survive until a tick runs; slow ×N
frames retire at the next frame boundary. Window ≤ max(frame, tick period) of events.

**Cursors.** Per (reader system, stream): a `u64` sequence, owned by the reader's
schedule entry — wired at graph build from declared event access (ADR-014 §4). Read
clamps the cursor to the retirement head: a lagging reader silently misses (ADR-014 §3),
never dangles.

**Registration record.** `{tag → EventTypeId, dense stream index, sizeof/alignof,
trivially-copyable check (compile-time), reserved wire flag}` — tag as call argument
from the composition root (ADR-014 §6).

**Tooling/editor reads** (v1 watchdog use case): an ordinary cursor advanced at the
host's between-frames point — same stream API, no second access path. UX at T1.

**Profiler.** `TE_PROFILER_SCOPE` on `makeVisible` + `retire`, literal names (ADR-013 §6).
Lands with the cards — Story D's macros exist by then.

## Registry (pinned 2026-08-06, with S3-T8)

`core/events/` — folder per design note (`CONVENTIONS.md` → *Headers*). `EventTypeId` is a
struct over a **private** `StringId`, the [[StringId — Design]] shape; `ComponentTypeId`
will want the same one, and *that* is when a shared wrapper earns its place, not now.

| Call | Shape |
|---|---|
| **Residence** | app-owned `EventRegistry` object — **not a singleton**. §5's multi-sim argument applies unchanged; ADR-014 §6's "process-global" is identity scope, not storage. Tests build one per case, so no test-only reset hook exists |
| **Type → id** | `detail` inline variable per `T`, written by `registerEvent<T>`, read by `eventTypeId<T>()`. Holds the **id only** — the id is a pure function of the tag, so two registries agree; the dense index is registry state, resolved by lookup. Not a self-registering static, so §6 holds |
| **Tag storage** | owning `std::string`. A `string_view` dangles the moment a game DLL unloads |
| **Wire flag** | `EventWire{Local, Replicated}`, defaulted `Local`. Nothing reads it at M1 — a bare `bool` at the call site reads as nothing |

**Rejections are always-on `TE_CHECK`** — empty tag · tag hashing to 0 · duplicate id,
different tag (the ADR-007 §1 collision) · a tag already registered. The last is a bug
either way: the composition root is one ordered list, and two types cannot share a tag.

**Only two of the four are reachable from a test.** The collision and the zero-hash both
need an FNV-1a/64 preimage, so they are field guards verified by reading, not by Catch2 —
which is *why* the empty tag earns its own guard (2026-08-06, with S3-T8). It is the
mistake a human actually makes, and an empty tag hashes to the offset basis, a valid id,
so it cannot ride the zero check.

**A rejected registration leaves the registry unchanged and returns the invalid id.**
`TE_CHECK` is fatal by default, but a test handler returns `{false, false}` and execution
**continues** past it — so the post-check path is real code, not theory.

## Stream storage (pinned 2026-08-06, with S3-T9)

| Call | Shape |
|---|---|
| **Storage** | one **type-erased** `EventStream` over a byte buffer sized from the registry record; `EventStreamManager` holds the `std::vector<EventStream>` indexed by the dense stream index — what that index is for — and the driver owns the manager (§ *Container + loop wiring*). `publish<T>` memcpys (registration already guaranteed trivially-copyable); `read<T>` asserts the stream's id is `eventTypeId<T>()`, so type safety is a runtime check, not the compiler's |
| **Overflow** | capacity hint at registration, **geometric growth**. Steady state allocates nothing — the property the card's `operator new` count asserts — and a leak shows up as growth instead of silent loss. Bounded in practice, not by construction |
| **Reads** | **eager compaction — every retire**, so the visible region is always contiguous and `read<T>` returns one `std::span` |
| **Spelling** | ADR-014 §3's *flip* is **`makeVisible(frame, tick)`** in code, and its mark is `EventBatchMark` — "flip" is GPU page-flip vocabulary and implies two buffers swapping, which is the mechanism this section just replaced. Same refinement precedent as `dt` → `deltaTime` (`CONVENTIONS.md` → *Names are spelled out*); the ADR is not edited |

**Compaction replaces the wrap — the buffer is linear, not a ring.** Retire drops the
retired batches and memmoves what is left to the front; publishes only ever append at the
tail. Four consequences:

- **the head's *index* is always 0** — its *sequence* still climbs with every retire — so no
  head index is stored, there is no compact-or-grow decision, and free space is always the
  tail: one fewer state variable and one fewer branch than the lazy variant weighed below
- index is `seq − retireHeadSeq`, with **no modulo anywhere** — the arithmetic gets simpler,
  not harder
- growth is the *only* overflow path, since a compaction that just ran frees nothing
- cost is one `O(retained)` move per frame per stream, paid unconditionally — whether or not
  anything would have wrapped, and whether or not the buffer is anywhere near full

**Lazy compaction was weighed and dropped** (2026-08-06): compacting only when the tail hits
capacity makes retire an O(1) index advance and keeps single-span reads, at the cost of a
buffer sized for retained *plus* publishes-between-compactions, and the extra state above.
Chosen against deliberately — simplicity now, with the profiler as the trigger to revisit.

ADR-014 §7 asks for "contiguous, double-buffered, amortized — no fixed-size node churn",
which this satisfies, so nothing here reaches the ADR.

## How one stream works

Two members carry everything:

| Member | Holds |
|---|---|
| `m_storage` | the events — one flat byte array, `capacity × elementSize`. Index 0 is **always** the oldest retained event |
| `m_marks` | one entry per batch made visible: `{endSequence, frameIndex, tick}`. Not events — the bookkeeping that lets `retire` apply ADR-014 §3's rule, because the rule is about *when* a run of events became visible |

Three `u64` positions cut the storage into three regions. They are **absolute sequence
numbers, never indices** — an index is `seq − m_retireHeadSequence`, so sequences keep
counting up forever while indices stay small.

| Region | From | To | Who sees it |
|---|---|---|---|
| **Visible** | `m_retireHeadSequence` | `m_visibleEndSequence` | readers, through their cursors |
| **Staged** | `m_visibleEndSequence` | `m_stagingTailSequence` | nobody yet |
| **Free** | `m_stagingTailSequence` | `m_capacity` | — |

| Call | What moves |
|---|---|
| `publish<T>` | writes one element at the staged region's end; `m_stagingTailSequence++`. Grows only if the tail hit capacity. **Readers observe no change** |
| `makeVisible(f, t)` | `m_visibleEndSequence = m_stagingTailSequence` — the staged region joins the visible one — and pushes a mark `{that sequence, f, t}`. **No bytes move.** A no-op when nothing was staged, so a quiet sub-step records no mark |
| `retire(f, t)` | walks `m_marks` from the front while `f > mark.frameIndex && t > mark.tick`, takes the last such `endSequence` as the new head, erases those marks, then memmoves what survives down to index 0 |

```mermaid
flowchart LR
    A["publish<br/>written at the tail"] --> B["staged<br/>invisible to readers"]
    B -->|"makeVisible(f, t)"| C["visible<br/>cursors can read it"]
    C -->|"retire(f, t)<br/>only after a frame AND a tick"| D["gone<br/>space reclaimed by compaction"]
```

A cursor is one `u64`. Reading hands back everything from the cursor to
`m_visibleEndSequence` and parks the cursor there — exactly-once by construction. A cursor
older than `m_retireHeadSequence` is clamped forward to it, which is how a lagging reader
misses silently instead of dangling.

## Container + loop wiring (pinned 2026-08-08, with S3-T10)

`EventStreamManager` (`core/events/`) owns the `std::vector<EventStream>`, indexed by the
registry's dense stream index. Driver-owned at M1 — **this is the object that moves onto
`Scene` at M5** (ADR-014 §5); nothing else about the shape changes when it does.

| Call | Shape |
|---|---|
| **Construction** | `EventStreamManager{registry}` builds one stream per record, so **every `registerEvent` must precede it**. Enforced rather than documented: the ctor takes a non-const `EventRegistry&` and **seals** it, and a later registration is a `TE_CHECK` naming the tag — the failure lands on the registration that caused it instead of on the first publish |
| **Lookup** | `getStream(id)` returns a **pointer**, gated by `TE_VERIFY` on both "record found" and "index in range"; `publish` drops, `read` returns an empty span. Always-on check **plus** a defined path — the same shape as a rejected registration, and what makes the miss reachable from a test |
| **Capacity** | one `initialCapacity` for every stream. The per-type hint § *Stream storage* assumes has no home yet — `EventTypeRecord` carries no capacity field. Open below |
| **Profiler** | zones on the **container's** `makeVisible`/`retire`, not on `EventStream`'s — one zone per barrier instead of one per stream per sub-step (ADR-013 §6) |

**The loop stays events-ignorant.** `FrameLoop::advance(deltaTime, onFixedStep)` calls the
hook once per fixed sub-step, after `tick++`; the driver's hook publishes and calls
`makeVisible`. Everything else is driver-side — frame-tail `makeVisible`, the cursor read,
then `retire` **last**. That hook is what becomes `FixedUpdate`'s slot at M5.

Three ordering facts, each of which is a silent bug if reversed:

- `frameIndex` and `deltaTime` are set **before** the sub-step loop, so the hook stamps marks
  with the current frame. `alpha` cannot be — it is not known until the accumulator settles.
- `retire` at the frame **tail** is ADR-014 §3's "frame start" in a rotated loop, and it is
  what stops it dropping a batch the tail read never saw.
- A 0-tick frame runs no hook at all: nothing is published, and nothing retires either,
  because the tick did not advance.

## Open (deliberately — each has an owner)

- **Script façade surface** (`onEvent<T>`-style, runner-drained; publishes routed
  through the façade) → **scripting ADR**.
- **Binding a cursor to a system — mandatory, not sugar** (sharpened 2026-08-08, after S3-T10).
  `read<T>(cursor)` needs the *caller* to hold the cursor, and a system cannot: the cursor lives
  on its schedule entry. So the executor has to bind stream + cursor before the system body
  sees it — a view handed in, or the drain below. Deferred deliberately until there is a
  `Schedule` to test it against. **Owner:** the task-graph ADR.
- **Engine-side `onEvent<T>` for C++ systems** — the executor drains at the system's slot and
  calls a handler, instead of the system body writing the `read` loop. Same pull, same
  barrier; sugar, not a semantic change. The loop stays the primitive (batch access and a
  tight span read are not recoverable from a per-event callback), and the payoff is deriving
  the system's event access set from the registration rather than hand-declaring it.
  **Owner:** the task-graph ADR — nothing can invoke it until `Schedule`/`SystemAccess` exist.
  Raised 2026-08-06 during S3-T9, from the raw call site reading badly.
- **Per-thread staging lanes + merge** → **M2 threading ADR** (semantic fixed above).
- **Rewind truncation for client reconciliation** — ADR-014 §3 asserts a replayed tick
  reproduces an identical stream, but nothing says how the mispredicted run's events leave.
  `retire` only drops from the front, so a rewind needs a **tail** truncation: drop back to a
  sequence, erase those marks, and pull any cursor past it backwards. Reader cursors are
  rewind state too — a system that already consumed tick N needs its cursor restored or the
  replay never re-delivers. Replayed side effects (sound, VFX) are a separate problem the
  ADR already names against the v1 shape. Bounded in practice: ADR-007 §4 replays unacked
  commands only, and §Confirmed forks is snapshot+interpolation, not rollback.
  **Owner:** the netcode transport ADR (M4). Raised 2026-08-06 during S3-T9.
- **Editor watchdog UX** (what the editor shows, filtering) → **T1** (read path pinned
  above).
- **API spelling** (`publish<T>` / `read<T>` view type, header layout) → implementation +
  `CONVENTIONS.md`; not a decision, a naming pass.
- **Re-registration on DLL reload** — the registry rejects a second `registerEvent<T>`, so a
  reloaded game DLL cannot re-register its types; **the seal (S3-T10) closes the door
  further** — after the streams are built, *no* registration is accepted, reload or not.
  Both are the same constraint made explicit, not a new one, and no reload exists at M1.
  **Owner:** the module/script reload work, whenever it lands.
- **Per-type capacity hint** — every stream is built with one shared `initialCapacity`
  because `EventTypeRecord` has no capacity field. Growth is geometric, so a hot stream
  costs a few early reallocations rather than being wrong. **Owner:** the first event type
  with a known high rate — add the field then, with a real number behind it.

## References

- [[ADR-014 — Events (buffered streams) & StringId]] — the decision + alternatives
- [[Game Loop — Frame Flow]] — barriers, ×N fixed ticks, where the barrier sits
- [[v1 Code Audit]] F28 · `EventManager.hpp` at `v1-reference` — prior art
- Bevy `Events<T>`/`EventReader` — closest prior art for the pull model (retention rule
  here differs: tick-aware, not N-frames)
