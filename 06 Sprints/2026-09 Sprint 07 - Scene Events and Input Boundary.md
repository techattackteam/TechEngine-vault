# 2026-09 · Sprint 07: Scene Events and Input Boundary

- **Quarter:** [[2026-Q3]] → Q4 boundary
- **Dates:** Saturday Sep 26 - Friday Oct 9, 2026.
- **Epic:** M5 · Scene & scheduling ([[Roadmap]]).

## Sprint goal

Make Scene-owned event streams visible at the Tick barrier to a scheduled reader,
with deterministic order and a defined retention lifetime. Translate GLFW controls
to engine identifiers and deliver ordered input notifications to selected systems
during the consuming Tick, including held, focus and overflow behavior.

Miguel's Sprint 06 showcase checked repeated Scene values and headless/windowed
parity. [[Events - Design]] and [[Task Graph - Execution Flow]] ground Scene
streams; [[Input - Design]] records the separate same-Tick input contract
accepted in S7-D2. Both event and input delivery are sprint implementation work.

## Artifact gate

- [[Events - Design]] decides per-Scene streams and Tick-barrier visibility. The
  Sep 26 amendments to ADR-014 and ADR-022 set next-Tick batch delivery without
  scheduled-reader cursors. S7-D1 set handler declaration order within each system
  and cut Story B against that contract. Names for the entry-scoped declaration API
  remain implementation choices.
- [[Input - Design]] records S7-D2's accepted GLFW-to-engine translation,
  ordered press/release and per-Tick held notifications, focus recovery, and
  same-Tick system delivery. ADR-014 §7, ADR-019 §2 and ADR-020 §1 have dated amendments;
  no new ADR or action-mapping layer is required. S7-T9-T12 implement it in
  this sprint.
- [[Known Issues]] D3 concerns symlinks in mount lookup. This sprint does not load
  resources through a symlinked asset directory, so it neither blocks nor touches
  the selected work. No unfixed Sprint 06 Bug card carries.

## Stories & tasks

### Story A: Finalize Tick-event delivery

- [x] **S7-D1** · Finalize Tick-event delivery and handler order · P1 · 🟢 Deep · 4-6h ·
  done: record ADR-014 and ADR-022's accepted next-Tick batch amendments in the
  event and task-graph notes; settle cross-type handler order and executor-facing
  registration. Then cut session-sized Story B cards. Include removal of M1's frame
  marks and cursors, replacement of `TaskGraph`'s diagnostic-only temporary system
  construction, and renaming the Clock diagnostic counter from frame to tick terms
  in the relevant implementation cards. Preserve publisher schedule order and FIFO.
  Completed locally Sep 26; the vault changes are not committed.

### Story B: Deliver Scene events at the Tick barrier · six Dev tasks

- [x] **S7-T3** · Construct and describe selected systems before graph build · P1 · 🟢 Deep · 4-6h ·
  done: construct one persistent instance per selected entry before graph build; let it
  declare component access, priority, slot and ordering through an entry-scoped surface;
  use registration name metadata instead of a temporary system for diagnostics. Migrate
  the runtime demo declarations and prove one construction, one startup pass, and safe
  failure on an invalid graph. API names remain provisional. Also finish the Clock's
  frame-to-Tick rename, including `advanceFrame()`, and drop the frame argument from
  `TickBarrierServices::flushEvents`. This was moved from S7-T8 on Sep 26 because T3's
  branch had already started it.
- [ ] **S7-T4** · Bind ordered event handlers to selected systems · P1 · 🟢 Deep · 3-5h ·
  done: collect typed event handlers on the same persistent instance in startup
  declaration order, resolve only registered event types before graph freeze, and carry
  handler metadata to the executor without creating event conflict edges. Prove
  duplicate-type handlers and invalid or late declarations behave deterministically.
  Make handlers the only read path: `Scene::read` stops being callable from `tick` and
  only the executor reads a batch for handlers. Move S7-T6's `SceneEventTests` readers
  from `tick` to handlers. Agreed Sep 27 at S7-T6's review; record it in
  [[Events - Design]] at close.
- [x] **S7-T5** · Replace event cursors with stable Tick batches · P1 · 🟢 Deep · 4-6h ·
  done: remove M1 frame marks and scheduled-reader cursors; expose Tick N's immutable
  visible batch during Tick N+1 and retire it only when asked after that phase. Prove
  quiet and consecutive Ticks, publisher order and FIFO, and a stable view when a
  handler publishes the same type and staging grows. Start with the invalidation case.
- [x] **S7-T6** · Place registered event streams on Scene · P1 · 🟢 Deep · 3-5h ·
  done: register event types at the app composition root before stream construction,
  give each Scene its own streams, and expose the simulation-only publish/read seam.
  Prove two Scenes sharing type identity do not share event contents and late type
  registration is rejected without corrupting either Scene.
- [ ] **S7-T7** · Deliver handlers and advance batches at the Tick barrier · P1 · 🟢 Deep · 4-6h ·
  done: run each system's handlers in declaration order on the previous Tick's batches
  before its `tick`, including the terminal slot; retire that batch only after the
  system phase succeeds, then expose current-Tick publications at the barrier. Replace
  the no-op event service while leaving NetId assignment deferred. Prove failure
  retains the batch and discards pending structural commands.
- [ ] **S7-T8** · Prove the integrated event path · P1 · 🟢 Deep · 3-5h ·
  done: add a runtime or App-level publisher/reader witness and prove no same-Tick
  delivery, all selected handlers next Tick, zero-Tick preservation and multi-Tick
  catch-up in headless execution; record the windowed observation separately. Update
  touched design notes with shipped evidence.

T3 and T5 can start independently; T6 follows T5, T4 needs T3 and T6, T7 follows
T4, and T8 finishes the App-level proof. T5 is the highest-risk card because M1's
single buffer can invalidate a visible span during same-type publication. NetId
allocation waits for its first networking consumer.

These cards use App's existing selection of demo systems. ADR-022's public project
catalog and module-loading seam await a project-contributed system; that separate
consumer-triggered work is parked in [[Backlog]].

### Story C: Deliver engine input events

- [x] **S7-D2** · Review v1 input and settle the engine input contract · P1 · 🟢 Deep · 4-6h ·
  done: inspect v1's key/button/event path and the current GLFW callbacks,
  `InputEvent`, `InputBuffer` and `SimulationContext`; decide engine-owned codes,
  press/release/held and focus recovery semantics, and same-Tick event delivery.
  Amend ADR-014, ADR-019 and ADR-020 in place and create [[Input - Design]]. Cut
  implementation cards after Miguel accepts the contract. Completed locally Sep 26 after Miguel
  accepted the direct input-event path and S7-T9-T12 were cut below.

#### Dev cards: input implementation

- [ ] **S7-T9** · Translate GLFW controls to engine identifiers · P1 · 🟢 Deep · 4-6h ·
  done: define separate engine key and mouse-button identifiers; translate known
  GLFW values at the platform callback before publishing to `InputBuffer` and
  ignore unsupported values. Keep raw GLFW codes out of the simulation-facing
  event and held-state contract. Prove known and unknown controls, press/release
  order, ignored GLFW repeat, and the independent presentation input copy.
- [ ] **S7-T10** · Deliver input edges to selected systems · P1 · 🟢 Deep · 4-6h ·
  done: let each persistent selected system declare an input handler at startup.
  Deliver the consuming Tick's captured key, button, motion and focus events in
  sequence order at that system's scheduled slot before `tick`, under its declared
  component access. Prove press and release between two Ticks, two readers,
  declaration order, no delivery without a Tick, and multiple catch-up Ticks.
- [ ] **S7-T11** · Generate held input and handle focus resets · P1 · 🟢 Deep · 3-5h ·
  done: generate one held notification per held key or button after captured events
  in each Tick. Clear held controls and pointer baseline on focus transition;
  regain starts neutral. Prove press-plus-release in one Tick, quiet held Ticks,
  duplicate focus, and GLFW's post-loss synthetic releases without a stuck key.
- [ ] **S7-T12** · Prove overflow recovery and runtime delivery · P1 · 🟢 Deep · 4-6h ·
  done: give input handlers a visible recovery notice with the lost sequence range
  and recovered held/focus state, without inventing missing edges. Prove tiny-buffer
  overflow and resumed held delivery, then record a windowed runtime witness for
  press, held, release and focus loss. Record headless behavior separately and keep
  headless composition free of a GLFW source.

T9 precedes T10; T10 precedes T11; T12 follows T11. S7-T10 also needs the
persistent selected-system startup seam from S7-T3. Script delivery awaits its
first scripting consumer and is not part of these cards.

### Story D: Close other fired decisions and implementation seams

- [ ] **S7-D3** · Decide the public error-handling policy · P2 · 🟢 Deep · 4-6h ·
  done: settle `CONVENTIONS.md`'s open Error handling row in an ADR using
  `addLogSink` and `Reader` as current cases; state the `[[nodiscard]]` policy
  without rewriting working APIs speculatively.
- [x] **S7-T1** · Correct app-local includes · P3 · 🤖 Auto · 2-3h ·
  done: change the four quoted includes in `apps/` to angle brackets (`CONVENTIONS.md`
  § *Includes*), after checking that each path resolves through the app's include dirs,
  and include `<string>` directly in `apps/editor/src/EditorApp.hpp`. Preserve the
  `sdk-smoke` public-boundary intent. `platform` is already a public `engine/app`
  dependency on `7e52fe3a`; that half of the original card needs no change. Re-tagged
  Auto on Sep 27.
- [ ] **S7-T2** · Route GLFW allocations through profiler hooks · P3 · 🟠 Moderate · 3-4h ·
  done: install GLFW 3.4's allocator before initialization and check allocation/free
  pairing and disabled-profiler behavior. This is the fired GLFW portion of
  [[ADR-013 - Profiler (Tracy-backed instrumentation)]] §7; Jolt and miniaudio wait
  for their initialization consumers.

### Story E: Repair fired process and evidence gaps

- [ ] **S7-P1** · Reconcile build/profiler and App coverage policy · P2 · 🟢 Deep · 4-6h ·
  done: carry S6-P1's warning/tidy and Tracy-pin reconciliation into ADR-005/008/013,
  B3 and [[Profiler - Design]]; record the `App.cpp` coverage exclusion and decide
  whether its scope should narrow. Record unresolved decisions rather than inventing policy.
- [ ] **S7-P2** · Guard the merged branch-to-card link · P3 · 🤖 Auto · 4-6h ·
  done: add a gate step to `.claude/commands/card-close.md` that checks the merged
  commit's branch prefix against the card being closed, without rejecting a still-open
  card that landed in halves. Branches named `sweep/…` belong to the lane's code sweep,
  have no card, and pass. Re-tagged Auto on Sep 27, with the check's home pinned to
  `/card-close`.
- [ ] **S7-P3** · Validate vault code citation paths and line bounds · P3 · 🤖 Auto · 4-6h ·
  done: a Python 3 script at `tools/check-vault-citations.py` in the engine repo that
  resolves the vault's `file:line` citations against the Dashboard's reconciled engine
  SHA, including explicit at-SHA citations, and reports each broken path or out-of-range
  line. It checks mechanical validity only and says so; whether a line supports its claim
  stays a human read. Re-tagged Auto on Sep 27, with the check pinned as a script.
- [ ] **S7-P4** · Reconcile workflow-only CI policy · P3 · 🟠 Moderate · 2-3h ·
  done: amend ADR-009 for workflow-only PRs receiving no build, verify the stated
  master-run mitigation, and correct `ci.yml`'s skipped-check comment without
  changing the working gate.
- [x] **S7-P5** · Resolve old routine-prompt drift · P3 · 🟡 Light · 2h ·
  done: establish whether the old Claude routine still runs and reconcile its
  prompt-sync guidance with the vault, or record that the old routine is retired.
- [ ] **S7-P6** · Keep fired backlog witnesses current · P3 · 🟡 Light · 2h ·
  done: decide whether the widened witness check belongs in `$weekly-review`, then
  update that workflow or record why the existing sweep is sufficient.
- [ ] **S7-P7** · Measure ccache refresh after successive master revisions · P3 · 🤖 Auto · 2h ·
  done: record cache hits and snapshot growth from comparable recent runs, or name
  the missing evidence without claiming the policy improved hit rate. Report-only.
  Re-tagged Auto on Sep 27.
- [ ] **S7-P8** · Define a small recorded-demo workflow · P3 · 🟡 Light · 2h ·
  done: specify where a capture, Tracy trace and observed behavior are stored and
  linked from a sprint review, using the Sprint 06 showcase to identify what was
  observed and what was not captured.

### Story F: Backlog code hygiene for the Auto lane

Pulled from [[Backlog]] on Sep 27 as Auto work. None of their triggers had fired; they
use the lane's capacity, not Miguel's, and none touches a Story B or C file.

- [ ] **S7-B1** · Build with the log gate above Info · P3 · 🤖 Auto · 2h ·
  done: `cmake --preset linux-debug -DTE_LOG_ACTIVE_LEVEL=3` builds and its tests pass.
  Fix the unused `position` local at `engine/base/tests/math/MathFormatTests.cpp:47`
  without weakening the case, and fix any other site the same build exposes.
- [ ] **S7-T13** · Give `techengine_app()` a `LIBS_PRIVATE` · P3 · 🤖 Auto · 2h ·
  done: `cmake/techengine_app.cmake` splits `LIBS` and `LIBS_PRIVATE` the way
  `techengine_module()` does, and the editor's toml++ moves to `LIBS_PRIVATE`. The Linux
  build and tests pass unedited.
- [ ] **S7-T14** · Test `Log.hpp`'s `NDEBUG` fallback · P3 · 🤖 Auto · 2h ·
  done: a test TU that `#undef`s `TE_LOG_ACTIVE_LEVEL` before including `Log.hpp`, plus
  its CMake entry, proves the fallback's level in both `linux-debug` and `linux-release`.
- [ ] **S7-T15** · Spell out `loc` and `fmtStr` in `base` · P3 · 🤖 Auto · 1-2h ·
  done: rename the `loc` and `fmtStr` parameters in `base` to spelled-out names
  (`CONVENTIONS.md`). They are parameter names, so no caller changes; tests pass unedited.
## 🤖 Auto lane

- Auto cards: S7-T1, S7-P2, S7-P3, S7-P7 (re-tagged Sep 27) and S7-B1, S7-T13, S7-T14,
  S7-T15 (pulled from [[Backlog]] Sep 27). Seven open a PR; S7-P7 is report-only. With no
  Auto card open, the morning fire screens papers for [[Research]] and the afternoon fire
  sweeps one module for unnecessary code, on `sweep/` branches with no card.
- Attended slots freed: two 🟢 Deep (S7-P2, S7-P3), one 🟠 Moderate (S7-T1) and one
  🟡 Light (S7-P7).
- The lane runs only once Miguel pastes the current [[Autonomous Lane - Routine Prompt]]
  into the paused routine and resumes it.

## Definition of Done

- [ ] An event published by a scheduled system becomes visible after that Tick's
  barrier, reaches every selected registered handler during the next Tick, and retires
  after that system phase. Prove zero-tick, multi-tick, failed-phase and same-type
  handler-publication boundaries.
- [x] The input boundary has an accepted contract and an Input design hub grounded in
  current code and v1 prior art. Implementation follow-ups were cut after acceptance.
- [ ] GLFW controls reach simulation as engine identifiers. Selected systems receive
  captured transitions during the consuming Tick and held notifications once per Tick;
  focus loss and overflow recover without stuck controls or invented edges. Prove
  headless and windowed paths separately.
- [ ] Touched ADRs and design notes describe the shipped behavior; validation records
  distinguish tests, CI, attended demonstrations and unrun checks.

## Capacity note

Miguel reports that one weekend is unavailable and a Tuesday is free from his day
job; the exact dates are not yet confirmed. The normal rhythm would yield four
weekday evening Deep slots, one usable weekend day with 2-3 Deep slots, plus the
free Tuesday's additional daytime work. The boundary ceremony uses part of this
weekend. Moderate and Light slots are limited. The original 13 fixed cards use
six Deep, three Moderate and four Light sessions. Story B adds six Deep and
Story C adds four Deep: 23 cards total, with 16 Deep, three Moderate and four
Light sessions. S7-D1 and S7-D2 are already complete locally.

Miguel explicitly chose this oversized sprint, including the four input Dev
cards. Both implementation stories are committed; no card is pre-deferred.
Eight of the original 13 fixed cards are Process work. Run the event and input
goal first, then lower-priority Process work. If capacity forces rollover,
name each affected card at review. Keep a rest day despite the overfill.

**Scope change, Sep 27: the Auto lane returns.** Four cards moved to the lane and four
were pulled in for it (§ *🤖 Auto lane*). The attended lane drops to 14 Deep, two
Moderate and three Light sessions. The lane is not free: seven PRs at about 15 minutes of
review each is roughly 1h45 of Miguel's time, best spent on Light days. At one PR per
weekday, the ten weekdays left fit all seven only if the routine resumes early in week 1.

The Sprint 06 Scene-proof backlog entry is removed based on Miguel's reported
showcase, with the automated-test limit retained in the Sprint 06 review. No
additional discretionary backlog entry was selected after the fired items.

## Sprint review (end)

- Record shipped cards and the evidence that closes each part of the goal.

Retrospective: [[07 Journal]]
