---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Finalize Tick-event delivery



## Story B: Deliver Scene events at the Tick barrier

- [ ] **S7-T8** · Prove the integrated event path · P1 · 🟢 Deep · 3-5h: follows T7; App-level boundary proof.


## Story C: Deliver engine input events

- [ ] **S7-T9** · Translate GLFW controls to engine identifiers · P1 · 🟢 Deep · 4-6h: known/unknown codes, ordered edges and repeat handling.
- [ ] **S7-T10** · Deliver input edges to selected systems · P1 · 🟢 Deep · 4-6h: follows T9 and S7-T3; current-Tick delivery at each system slot.
- [ ] **S7-T11** · Generate held input and handle focus resets · P1 · 🟢 Deep · 3-5h: follows T10; held once per Tick and neutral regain.
- [ ] **S7-T12** · Prove overflow recovery and runtime delivery · P1 · 🟢 Deep · 4-6h: follows T11; lost-range notice plus headless/windowed witnesses.


## Story D: Close other fired decisions and implementation seams

- [ ] **S7-D3** · Decide the public error-handling policy · P2 · 🟢 Deep · 4-6h: settle the open conventions row and `[[nodiscard]]` policy in an ADR.
- [ ] **S7-T2** · Route GLFW allocations through profiler hooks · P3 · 🟠 Moderate · 3-4h: install and verify the GLFW allocator seam.


## Story E: Repair fired process and evidence gaps

- [ ] **S7-P1** · Reconcile build/profiler and App coverage policy · P2 · 🟢 Deep · 4-6h: carry S6-P1 and record the App coverage exclusion.
- [ ] **S7-P2** · Guard the merged branch-to-card link · P3 · 🤖 Auto · 4-6h: a `/card-close` gate step checking the merged branch prefix.
- [ ] **S7-P3** · Validate vault code citation paths and line bounds · P3 · 🤖 Auto · 4-6h: `tools/check-vault-citations.py` against the reconciliation SHA.
- [ ] **S7-P4** · Reconcile workflow-only CI policy · P3 · 🟠 Moderate · 2-3h: amend ADR-009 and fix the skipped-check comment.
- [ ] **S7-P6** · Keep fired backlog witnesses current · P3 · 🟡 Light · 2h: settle the widened sweep's workflow home.
- [ ] **S7-P7** · Measure ccache refresh after successive master revisions · P3 · 🤖 Auto · 2h: record comparable cache evidence; report-only.
- [ ] **S7-P8** · Define a small recorded-demo workflow · P3 · 🟡 Light · 2h: record capture storage and sprint-review links.


## Story F: Backlog code hygiene for the Auto lane

- [ ] **S7-B1** · Build with the log gate above Info · P3 · 🤖 Auto · 2h: `-DTE_LOG_ACTIVE_LEVEL=3` builds; fix `MathFormatTests.cpp:47`.
- [ ] **S7-T13** · Give `techengine_app()` a `LIBS_PRIVATE` · P3 · 🤖 Auto · 2h: mirror `techengine_module()`; toml++ goes private.
- [ ] **S7-T14** · Test `Log.hpp`'s `NDEBUG` fallback · P3 · 🤖 Auto · 2h: a TU that undefines the gate, in debug and release.
- [ ] **S7-T15** · Spell out `loc` and `fmtStr` in `base` · P3 · 🤖 Auto · 1-2h: parameter renames only; tests unedited.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done: Sprint 07

- [x] **S7-T7** · Deliver handlers and advance batches at the Tick barrier · P1 · 🟢 Deep · 4-6h: #100 `82bf3f72`, Sep 27. `SerialExecutor` now runs each node's handlers before `tick`, then retires the old batch and makes the new one visible after `assignNetIds`. Three calls that no artifact made were settled at `/card-start` and are now in [[Events - Design]] § *Scheduled Tick delivery*: the executor drives the event barrier itself, so `TickBarrierServices::flushEvents` is deleted and the service keeps only `assignNetIds`; a handler whose type has no visible events is not called; and a handler on a Scene without streams fires a `TE_VERIFY`, once per handler per Tick. **A clause had no referent:** "only the executor reads a batch" had nothing to read with, because nothing could read a batch by `EventTypeId`. The card added an untyped read from `EventStream` up to a private `Scene` accessor and deleted the public `Scene::read<T>`, so the compiler now enforces the clause; the "reading outside a system" test went with it. **Deleted before shipping:** a barrier draft that called `context.engine.events.makeVisible`; `EngineContext` has no such field, and the streams are Scene-owned (ADR-014 §5). **Review caught, fixed before merge:** `Scene::readEventBytes` ignored its `TE_VERIFY` result and dereferenced the empty stream container on a Scene without streams, and the first dispatch called handlers on an empty batch. The PR carries no review conversation, so this entry is the only record of that review. **Retro:** as on S7-T4, Miguel asked Claude to implement the review fixes and the barrier, so those lines are Claude-written and Miguel-reviewed. **Retro:** the first local test run failed almost wholesale because the tests had not been rebuilt, and Claude's full rewrite of `SceneEventTests.cpp` had left CLion's temporary run configuration with no target. Unblocks S7-T8; Story B stays open until S7-T8 ships.

- [x] **S7-T4** · Bind ordered event handlers to selected systems · P1 · 🟢 Deep · 3-5h: #99 `0218571e`, Sep 27. A system declares `on<Event>(handler)` in `init`, and `TaskGraph` now takes the `EventRegistry` and resolves each declaration onto its node. The last `done:` clause could not ship in this card: making handlers the only read path needs something to run them, and dispatch is S7-T7's first clause. Miguel moved it to S7-T7 at `/card-start`, so `Scene::read` stays callable from `tick` until then. Three calls that no artifact made were settled at `/card-start` and are now in [[Events - Design]] § *Handler declaration*: the handler shape (a lambda taking `(Scene&, std::span<const Event>)`, with no `SimulationContext`), a `TE_CHECK` at graph build for a type this registry never registered, and the registry as a `TaskGraph` constructor argument. Deleted before shipping: a first `addEventHandler` that skipped the append on a frozen schedule but fired nothing, so a late handler vanished silently; it now checks like its sibling setters. `SerialExecutor`'s node already carries the handlers, unused until S7-T7; whether it should borrow the graph rather than copy it is now a [[Backlog]] entry. **Retro:** Miguel asked Claude to implement this card's TODOs, so the handler wrapping and the resolution are Claude-written and Miguel-reviewed. **Retro:** Claude's rewrite for the new constructor argument matched only graphs named `graph`, missed `writeGraph` and `readGraph` in `SerialExecutorTests`, and broke Miguel's local MSVC build; the PR's second commit fixed it. Unblocks S7-T7; Story B stays open.
- [x] **S7-T6** · Place registered event streams on Scene · P1 · 🟢 Deep · 3-5h: #98 `745f067a`, Sep 27. The first `done:` clause collided with the code: `App` built `m_scene` in its constructor, events register later in `configureSimulation()`, and `EventStreamManager` seals the registry when it is built. No artifact decided when a Scene builds its streams, and "simulation-only" had no mechanical meaning either. Miguel settled both at `/card-start`: a separate `buildEventStreams` step in `finalizeSimulation()`, and publish/read gated to a running system of that Scene. Both calls, plus the no-streams behaviour, are now in [[Events - Design]] § *Scene residence*. The in-session `/card-review` added three tests for the no-streams paths, which S7-T7 will lean on; its two design gaps went to [[Backlog]] (publish declarations) and to S7-T4's `done:` (handlers become the only read path). **Retro:** the first test draft counted a fire from the registry's report-once `TE_ENSURE`, which `EventRegistryTests` already counts in the same exe, so it would pass under `ctest` and fail when run directly; caught before commit, and the [[Backlog]] trap entry still stands. **Retro:** grounding explained per-Scene residence with ADR-014 §5's "more than one sim" and invented two product cases for it; the ADR names only tests. The wording is now a [[Backlog]] entry. Unblocks S7-T4; Story B stays open.
- [x] **S7-T5** · Replace event cursors with stable Tick batches · P1 · 🟢 Deep · 4-6h: #97 `1f5dda4d`, Sep 27. The stream is now two buffers swapped at the barrier, which makes ADR-014's "double-buffered" literal. The design note had left the stable-view mechanism open; the rejected option (one buffer that keeps old allocations alive until `retire`) is in [[Events - Design]] § *Why two buffers replaced M1's compacted buffer*. Two calls no artifact made, both now in § *Making events visible*: `makeVisible` before `retire` is a `TE_VERIFY` reject that changes nothing, and the Tick stays readable through `visibleTick()`. Deleted before shipping, in review cleanup: the `ByteRange` indirection, `grow`'s misleading parameter, the unread `m_alignment` member, the unused `id()`, and `getStream`'s duplicated body (now the engine's first `const_cast`, through `std::as_const`). The win ASan leg ran the invalidation case. **Retro:** the session first opened S7-T4, whose order gate failed on S7-T6, because Story B's board cards carried no `follows` hints; they were added Sep 27. **Retro:** the squash also carries the `/card-start` change that makes it write full tests; Miguel kept it here deliberately. Unblocks S7-T6; Story B stays open.
- [x] **S7-T1** · Correct app-local includes · P3 · 🤖 Auto · 2-3h: #96 `7ef6140c`, Sep 27. The first card the autonomous lane took end to end: it opened the PR, Miguel reviewed and merged. The PR's linux-debug run passed 428/428 under Xvfb; Windows was not built. The lane's bare `ctest` fails 18 window cases without a display → [[Backlog]] § *autonomous lane's test line*.
- [ ] **S7-P5** · Resolve old routine-prompt drift · P3 · 🟡 Light · 2h: check the old routine's status and reconcile prompt guidance.
- [x] **S7-T3** · Construct and describe selected systems before graph build · P1 · 🟢 Deep · 4-6h: #94 `7e52fe3a`, Sep 26. `Schedule::add<T>()` constructs the instance and calls `ISystem::init(ScheduleRegistration&)`; the schedule owns instances and the executor borrows them. Deleted before shipping: a `SystemCatalog` (project contribution stays parked in [[Backlog]]) and a `SystemDeclaration` wrapper that only forwarded to `ScheduleRegistration`. Diagnostic names are cached from the persistent instance's `name()`, not a static per-type field. Absorbed S7-T8's frame→Tick rename, including the log stamp `[f N]`→`[t N]`. Call-site declarations still override `init` → [[Backlog]] § core. **Retro:** the card opened on static self-registration, which ADR-022 had rejected that morning; the ADR was reopened and re-accepted unchanged the same day. Unblocks S7-T4 and S7-T10.
- [x] **S7-D1** · Finalize Tick-event delivery and handler order · P1 · 🟢 Deep · 4-6h: settled declaration order and next-Tick batches; cut Story B cards. Vault changes remain local.
- [x] **S7-D2** · Review v1 input and settle the engine input contract · P1 · 🟢 Deep · 4-6h: accepted engine codes and same-Tick input notifications; amended ADR-014/019/020, created the Input hub and cut S7-T9-T12. Vault changes remain local.




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%