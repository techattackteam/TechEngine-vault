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
damaged") without callbacks: per-type buffered streams, staged writes, barrier flip,
reader cursors. Fixes F28 structurally.

## Decided

| Fact | Where |
|---|---|
| Buffered per-type streams; no subscriptions, no callbacks | ADR-014 §2 |
| Event = trivially-copyable struct + stable tag → `EventTypeId` over `StringId` | ADR-014 §2, §1 |
| Visibility flips at phase barriers, incl. every FixedUpdate sub-step | ADR-014 §3 |
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

**Stream anatomy.** One stream per event type, on the `Scene`: a contiguous ring of
events with **absolute `u64` sequence numbers**, three positions — retirement head ·
visible end · staging tail. ADR-014's "double-buffered" realized as one ring, not two
buffers.

**Staging (M1).** Executor is serial until M2 (task graph runs level-by-level, one
thread) → **one staging buffer per stream**; append order already *equals* ADR-014 §3's
merge key (schedule position, FIFO per publisher). M2's pool layers per-thread lanes +
a real merge under the **same key** — semantic unchanged, threading ADR owns the layout.

**Flip.** At each barrier (incl. every fixed sub-step): staged batch becomes visible;
record a mark `{endSeq, frameIndex, tick}`. Cheap — no copy, the ring is shared.

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

**Profiler.** `TE_PROFILER_SCOPE` on flip + retire, literal names (ADR-013 §6). Lands
with the cards — Story D's macros exist by then.

## Open (deliberately — each has an owner)

- **Script façade surface** (`onEvent<T>`-style, runner-drained; publishes routed
  through the façade) → **scripting ADR**.
- **Per-thread staging lanes + merge** → **M2 threading ADR** (semantic fixed above).
- **Editor watchdog UX** (what the editor shows, filtering) → **T1** (read path pinned
  above).
- **API spelling** (`publish<T>` / `read<T>` view type, header layout) → implementation +
  `CONVENTIONS.md`; not a decision, a naming pass.

## References

- [[ADR-014 — Events (buffered streams) & StringId]] — the decision + alternatives
- [[Game Loop — Frame Flow]] — barriers, ×N fixed ticks, where the flip sits
- [[v1 Code Audit]] F28 · `EventManager.hpp` at `v1-reference` — prior art
- Bevy `Events<T>`/`EventReader` — closest prior art for the pull model (retention rule
  here differs: tick-aware, not N-frames)
