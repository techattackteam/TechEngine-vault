# 2026-10 · Sprint 10: Close E1

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Oct 31 - Friday Nov 13, 2026.
- **Epic:** E1 · Editor and export, closed with an internal demo; R1's two ADRs and the mesh and
  model formats alongside, so that E2 can build from Sprint 11 ([[Roadmap]]). Hubs:
  [[Editor - Design]] and [[Resources - Design]].

## Sprint goal

Close E1. The editor exports the project from its File menu into a folder that holds the runtime
beside its packs, the runtime started by hand from there logs the edited scene, and the
hierarchy and inspector edit several entities at once. Alongside, R1's two ADRs and the design of
TEMesh, TEModel and the glTF loader, so that E2 can build from Sprint 11.

Drafted by S9-D5's `/sprint-prep` on Oct 31 ([[2026-10 Sprint 09 - Close M6]] § *Sprint 10's
cut*), with S10-D5 added by that day's `/product-review`. Fitted the same day
([[2026-10-31 Sprint 09 Retrospective]]); at the fit Miguel added Story H, S10-P3, S10-D7,
S10-B2 and S10-T9, and moved the console and the Profiler (Story C) from the lane to himself.

## Artifact gate

- Every story is cut against a design note: [[Editor - Design]] § *Multi-select*,
  [[Resources - Design]] § *Decided: packs and the runtime layout* (the runtime copy, Oct 31),
  [[Logger - Design]] and [[Profiler - Design]] for the two panels.
- **First Design card:** S10-D1, the lane's export design, on day 1. S10-D2 cut Story C's
  console half on Nov 3, and S10-D3 moved its Profiler half's build to E11 the same day. Story
  H's build stays unsized until S10-D9.
- **Brief check:** the content pipeline has no capability brief, so S10-D8 runs `/brief` before
  S10-D9 designs TEMesh, TEModel and the glTF loader ([[Principles]] P3).
- **Showcase:** none. E1 ends in an internal demo (S10-T7), which [[Principles]] P4 allows since
  Oct 31.
- **Coverage gap:** neither the renderer nor the content pipeline has a design note. S10-D4 starts
  `Renderer - Design`, and S10-D9 starts `Content Pipeline - Design`.
- [[Known Issues]]: D5 was carded as S10-B1 under the three-sprint rule, and S10-T10 fixes it
  since Nov 3.

## Stories & tasks

### Story A: Multi-select (Miguel)

- [x] **S10-T1** · Multi-select in the hierarchy · P1 · 🟠 Moderate · 2-3h ·
  done: the hierarchy selects through `BeginMultiSelect` over its visible rows, with box
  selection off: Ctrl+click adds or removes one entity, Shift+click selects the visible range,
  and Ctrl+A selects every visible row. `EditSession` holds the selected entities and the active
  one, and `EditorSnapshot` carries both with the sequence number of the last select applied.
  `SelectEntityCommand` carries the whole set, the active entity and main's sequence number, and
  main draws its own set until the snapshot carries that number. Delete, the menu's Delete on a
  selected row, and a drag from a selected row act on the topmost selected entities in hierarchy
  order, each as one command; a move into any moved subtree is refused. A destroyed entity
  leaves the set. With several selected, the inspector shows only their count. Tests: a select
  replaces the set, and an older sequence number never overwrites a newer one; deleting a
  selected parent and its selected child is one command with no warning; a move of several keeps
  their order; a move into a moved subtree is refused. Windowed: Ctrl and Shift select, a
  right-click on a selected row keeps the selection, and dragging three rows moves all three.
- [x] **S10-T2** · The inspector edits every selected entity · P1 · 🟢 Deep · 4-6h ·
  done: with several entities selected, the snapshot lists the components they all have, with
  the active entity's values, a mixed flag on each field row, and a mixed flag per Euler axis of
  `Transform`'s rotation. The inspector draws a mixed value as a dash with
  `ImGuiItemFlags_MixedValue`. Set field, add and remove each become one command over the
  selected entities, with one record per entity: an edit writes the same value to each, Add
  offers every type that one of them lacks and adds it only where it is missing, and Remove
  removes from all. A set-rotation-axis command decomposes each entity's own rotation on the
  simulation thread and replaces only the edited axis. The name field shows a dash when the names
  differ, and an edit renames every selected entity. Tests: a set field over three entities
  changes that field on each and leaves three records; an add over a mixed selection adds only
  where the type is missing; a rotation axis edit keeps each entity's other two axes; a field
  row is mixed only when a value differs. Windowed: two entities with different positions show a
  dash, and typing a value moves both. #174's comment in `EditSession::collectComponents` comes
  back. Follows S10-T1.
- [x] **S10-T8** · Edit an `AssetRef` in the inspector · P3 · 🟢 Deep · 4-6h · stretch ·
  done: the inspector edits an `AssetRef` field through a picker that offers the `AssetIndex` ids
  of the field's type, which `FieldVisitor::visitAsset` now passes. A set-field command adds the
  id as a dependency of the scene entry (`App::m_sceneHandle`) and fills the handle, so a
  `MeshRenderer` added in the editor gets its mesh. `/card-start` decides the policy for a load
  that fails inside a batch, and [[Editor - Design]] § *Open questions* records it. Tests: a set
  over a known mesh fills the handle; a set over an unknown id is refused. Follows S10-T2 and the
  lane's S10-T6, because all three change the inspector. Closed Nov 6: #190 `6764a8a`. The
  policy went into [[Editor - Design]] § *Decided*, which answered and removed the open question.

### Story B: Export, and run the export · 🤖 Claude

Cut against [[Resources - Design]] § *Decided: packs and the runtime layout* and § *Export
targets*. Story C also touches `EditorApp.cpp` and `PanelsManager.cpp`, so its build cards
start after S10-T4 merges.

- [x] **S10-D1** · Design the export command · P1 · 🤖 Claude · 1-2h ·
  done: [[Resources - Design]] decides what the runtime copy carries on Windows and Linux, whether
  a repeat export reuses its folder or numbers a new one (today it never writes into an existing
  folder), which folder File → Export writes to, and how the Run button finds the last export;
  S10-T3 and S10-T4 are rewritten to match. Vault only. Closed Nov 2 by the lane:
  [[Resources - Design]] § *The export command* and § *The Run button*.
- [x] **S10-T3** · File → Export · P1 · 🤖 Claude · 2-3h ·
  done: File → Export queues an export command that runs on the simulation thread and sends the
  client target through `Project::exportTo` into the editor's executable folder; with unsaved
  edits it warns that they are not exported. `exportTo` takes the runtime executable's path (the
  editor passes `<exe dir>/runtime[.exe]`), fails before touching any folder when that file is
  missing, and reuses `<folder>/<project name>/`: it replaces the runtime first, then writes the
  packs the target ships and removes the other pack names, and touches nothing else there.
  `findFreeExportFolder` and the numbering go. `add_dependencies(editor runtime)` is added. The
  startup load no longer exports, and `apps/runtime/src/main.cpp` passes the executable's own
  folder. Tests: a repeat export into the same folder succeeds and leaves one folder with an
  unrelated file kept (replacing the numbering case); a missing runtime fails the export and
  claims no folder; the copied runtime keeps its execute bit on Linux; a test exports
  `projects/dev` and opens the result as the runtime does. #174's include order in
  `PanelsManager.cpp` is fixed. The PR ends with "needs Miguel's windowed check": the runtime
  started from `bin/<config>/Dev/` logs the scene. Follows S10-D1. Closed Nov 2: #179
  `0dcbc1f`, merged with no decision reversed. The include order was not met, because
  clang-format reverts it; it stays in the [[Backlog]]. Miguel's windowed check passed.
- [x] **S10-T4** · The Run button · P2 · 🤖 Claude · 2-3h ·
  done: a File → Run item below Export starts `<exe dir>/<project name>/runtime[.exe]` as a child
  process, with that folder as its working directory, and logs its exit code when it exits.
  Starting the process is a new function in `platform`, which this card names. Run is enabled
  when that file exists, checked at startup and after each successful export, and disabled while
  the runtime it started still runs. Closing the editor neither waits for the runtime nor stops
  it. Tests: the process function starts a stand-in program and reports its exit code. The PR
  ends with "needs Miguel's windowed check": Run starts the exported runtime. Follows S10-T3.
  Closed Nov 3 by the lane: #181 `78c48ab`. In review Miguel made Run export first, so the
  "enabled when that file exists" clause no longer holds; see [[Resources - Design]] § *The Run
  button*.

### Story C: Editor panels: console and Profiler (Miguel) · 3 console tasks; the Profiler is built with E11

The two Shoulds of [[Editor - Brief]] § *Requirements* that have no design yet, moved from the lane
to Miguel at planning. Both panels touch `EditorApp.cpp` and `PanelsManager.cpp`, so their build
cards follow S10-T4. Cvars stay out: where a cvar lives and which thread owns it probably needs
an ADR. The Profiler half drops first.

- [x] **S10-D2** · Design the console panel · P2 · 🟠 Moderate · 2-3h ·
  done: [[Editor - Design]] decides, against [[Logger - Design]], how records reach main (the sink
  runs on any thread, so a bounded copy), what the panel keeps and drops, and its filters, then
  cuts the console's build cards into this story. Cut on Nov 3: grounding found that a sink can
  hold no state and can still run after its removal, so the console starts with a fix in
  `base` (S10-T10) instead of a static buffer in the editor. ADR-011 §3 and §7 are amended.
  Closed Nov 3 (vault `372e249`).
- [x] **S10-T10** · Log sinks are objects, and removal waits · P2 · 🟠 Moderate · 2-3h ·
  done: as [[Logger - Design]] § *Sink registration and delivery* decides. `LogSink` has one
  `write(const LogRecord&) noexcept`; `addLogSink` and `removeLogSink` take a `LogSink&`, and
  `LogSinkFn` goes. `deliverRecord` writes the ring outside the lock, calls the sinks under one
  mutex that add and remove also take, and writes the stderr fallback after the lock. A
  `thread_local` flag sends a record raised inside a `write` to the ring and stderr, and makes
  add or remove inside a `write` return `LogError::InsideSink`. `NullSink` goes and
  `SinkAlreadyRegistered` is new. The spdlog sink becomes a `LogSink` local to `Log.cpp`. One
  log-capture guard in `te_test_support`, itself a `LogSink`, replaces the seven copies that
  S10-T9 listed, and the other test sinks move to the new API. Absorbs S10-B1, so D5 is deleted
  from [[Known Issues]]. Tests: after `removeLogSink` returns, while other threads keep logging,
  the removed sink gets nothing and can be destroyed (TSan and ASan legs); a record logged inside
  `write` reaches stderr instead of deadlocking; `removeLogSink` inside `write` returns
  `InsideSink`; a second add of the same sink returns `SinkAlreadyRegistered`; two sinks see the
  same records in the same order. The macros and every call site stay unchanged.
  Closed Nov 4 (#183, `823067d`): the guard replaced nine copies, not seven, and the ring got
  its own mutex after the TSan leg reported its slot race.
- [x] **S10-T11** · The console's sink · P2 · 🟠 Moderate · 2-3h ·
  done: as [[Editor - Design]] § *The console* decides. `ConsoleLog` in `apps/editor/src/edit/`
  copies each record into a queue of 1,024 that drops the oldest and counts them; main drains it
  at the start of each frame. `EditorApp` creates it in `init()` after copying the ring, removes
  it in `shutdown()`, and gives it a wake callback that a Warn or worse from another thread calls
  once until main drains. Tests: a record from another thread reaches the drain with its message
  intact after the log call returns; an overflow drops the oldest and the drain reports the
  count; a Warn from another thread wakes once until drained, while an Info, or a Warn from
  main, does not; the ring's records come first; nothing arrives after removal. Follows
  S10-T10. **Widened on Nov 5 at review:** `StoredLogRecord` in `base/diagnostics/`, a record
  that owns its message, is what the console keeps and what the test log-capture guard keeps,
  so the guard's `CapturedLog` goes and the console has no record type of its own. Tests: a
  stored record copies every field, and keeps its message after the logged buffer changes.
  **Also fixes [[Known Issues]] D7:** `ringSnapshot` appends `StoredLogRecord`s, copying each
  message under the ring's lock, and its capacity argument goes. Tests: a snapshot keeps its
  messages after later records reuse every slot; a snapshot taken while another thread logs
  reads every message whole (TSan leg). Closed Nov 5: #187 `db72fe6`.
- [x] **S10-T12** · The console panel · P2 · 🟠 Moderate · 2-3h ·
  done: as [[Editor - Design]] § *The console panel* decides. The store in `edit/` keeps 5,000
  records, drops the oldest, counts each level and filters by the level toggles and a
  case-insensitive search on the message; Clear empties it. `ConsolePanel` in `ui/panels/`
  draws the toolbar and the rows through the clipper, shows the selected row's
  `file:line:function()`, and follows new rows only at the bottom. The default layout docks it
  below the views. Tests: the bound drops the oldest; the counts follow adds, drops and Clear;
  a level toggle and a search each hide the rows they should; a drain that reports dropped
  records adds one "N records dropped" row (added at S10-T11's close, because `drain` only
  returns the count). Windowed: a Warn from the
  simulation shows without moving the mouse, and the toggles, search and Clear work. Follows
  S10-T11. Closed Nov 6: #189 `4a8af74`. At the windowed check the level toggles moved into a
  *Show* dropdown that also hides the time and tick; see [[Editor - Design]] § *The console panel*.
- [x] **S10-D3** · Design the Profiler panel · P3 · 🟠 Moderate · 2-3h ·
  done: [[Editor - Design]] decides, against [[Profiler - Design]] and ADR-019's copied timing
  metrics, what the panel shows beside Tracy and where it reads the timings, then cuts the
  Profiler's build cards into this story. Follows S10-D2. Decided Nov 3, with no build cards in
  this sprint: the panel graphs recorded Play sessions, so it is built with Play (E11), and its
  build waits in the [[Backlog]]. ADR-013 §3 is amended. Closed Nov 3 (vault `cb2836a`).

### Story D: E1's loose ends (Miguel)

- [x] **S10-T5** · Diff coverage leaves out ImGui drawing · P2 · 🟡 Light · 1-2h ·
  done: `ci.yml`'s diff coverage excludes `apps/editor/src/ui/`, and [[Editor - Design]] says
  `ui/` holds drawing only, so logic stays in `edit/`. The `te_sdk_smoke` comments in
  `sdk/CMakeLists.txt:9` and `ci.yml` name `TechEngineSDKSmoke`. CI config, so attended.
- [x] **S10-T6** · Local and World modes in the transform inspector · P3 · 🤖 Claude · 2-3h ·
  done: a toggle shows world values, and a World edit is converted to local on the simulation
  thread through `setWorld` ([[Scene - Design]] § *Editor Local / World editing*). A test sets a
  world position on a child of a moved parent and reads back the expected local value. The PR
  ends with "needs Miguel's visual check" for the toggle. Moved to the lane at planning. **Not
  before Fri Nov 6**: S10-T2 is planned for Thu Nov 5 and changes the same inspector files, so if
  S10-T2 slips, Miguel moves this date with it. Closed Nov 6 by the lane: #188 `1ac607d`, merged
  with no decision reversed.
- [ ] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h ·
  done: Miguel runs [[Editor - Brief]]'s five scenarios windowed, the runtime's log from the export
  folder names the edited entities, and the result is recorded. E1 is marked closed on the
  [[Roadmap]]. Follows S10-T2 and S10-T3.
- [ ] **S10-T9** · The base sweep's leftover · P3 · 🟡 Light · 1-2h ·
  done: the version anchors go (`baseVersion()`, `platformVersion()`, `coreVersion()`, `Base.hpp`,
  `Base.cpp` and `BaseTests.cpp`, whose glm case repeats `MathTests.cpp`). From the base sweep of
  Oct 29. Its second leftover, one log-capture guard in `te_test_support` for the seven copies
  (`LogTests.cpp`, `AssertTests.cpp`, `TaskGraphTests.cpp`, `ResourceCacheTests.cpp`,
  `RuntimeAppTests.cpp`, `SceneAssetTests.cpp` and `HierarchyCommandsTests.cpp`), moved to
  S10-T10 on Nov 3, where the guard becomes the first `LogSink`. Follows S10-T10
  (`engine/base`).

### Story E: Alongside: R1's two ADRs

- [x] **S10-P1** · Paper report for the frame and device seam · P2 · 🤖 Auto · report-only ·
  done: the validated culling, draw submission and many-lights papers ([[Research]], Rendering)
  are mapped onto [[Renderer - Brief]] and [[Renderer - Research Brief]]'s questions, without
  choosing. Closed Nov 3 by the lane:
  [[Renderer - Seam Paper Report]], from search extracts and memory, since no paper host was
  reachable.
- [ ] **S10-D4** · The frame and device seam ADR · P1 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts it from [[Renderer - Brief]] and S10-P1's report; Miguel accepts it, and a
  new `Renderer - Design` indexes it. Meets Q4's ADR line. Follows S10-P1.
- [x] **S10-P3** · Paper report for the materials ADR · P2 · 🤖 Auto · report-only ·
  done: the validated materials and shading papers ([[Research]], Rendering) are mapped onto
  [[Renderer - Brief]]'s shading models and standard material, without choosing. Closed Nov 4 by
  the lane (vault `7bfdda8`): [[Renderer - Materials Paper Report]], from Filament's and glTF's
  documents, since no paper host was reachable.
- [ ] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts R1's second ADR from [[Renderer - Brief]] and S10-P3's report; Miguel accepts
  it, and `Renderer - Design` indexes it. With S10-D4, R1 is unblocked for Sprint 11. Follows
  S10-P3 and S10-D4.

### Story F: Defects

- [x] **S10-B1** · `removeLogSink(nullptr)` reports success (D5) · P3 · 🤖 Auto · 1-2h ·
  **folded into S10-T10** on Nov 3 by S10-D2, and taken off the lane: `removeLogSink` now takes a
  `LogSink&`, so a null sink cannot be passed, and S10-T10 deletes D5.
- [ ] **S10-B2** · Roots keep their order · P2 · 🟠 Moderate · 2-3h ·
  done: `Scene` keeps an order for root entities, so adding a component or destroying another
  root no longer moves a root, and a saved scene writes its roots in that order. Today
  `Scene::getRoots()` returns archetype storage order (`engine/core/src/scene/Scene.cpp:238` at
  `5c57bf8`), and removal swap-erases; found at S9-T16's `/card-start`. Tests: a root that gains a component keeps its position;
  destroying a root leaves the others in order; a save and a read keep the order. Whether the
  hierarchy may then reorder roots is decided at `/card-start`.
- [ ] **S10-B3** · A reparent under a rotated, non-uniformly scaled parent is refused · P3 ·
  🟠 Moderate · 2-3h ·
  done: a `PreserveWorld` reparent whose new local transform would need shear is accepted with an
  approximate result, as Unity does: the child keeps its world position, and its local rotation
  and scale are the closest a local TRS can hold, so its world picks up the parent's shear. A zero
  scale axis stays refused, because no local scale can undo it. ADR-021 is amended first, because
  today it decides that such an edit fails (`engine/core/src/scene/Scene.cpp:424-430` at
  `4ba9f60`). Whether `setWorld` takes the same rule is decided at `/card-start`. Found at
  S10-T1 on Nov 1: dropping any entity under a parent that was rotated and scaled differently
  per axis moved nothing, and only the log said why. Tests: a child moved under a rotated parent
  with scale (1, 2, 1) is accepted and keeps its world position; a parent with a zero scale axis
  is still refused. How close the world rotation and scale must stay is decided with the
  amendment. It edits `Scene.cpp` like S10-B2, so the two do not run at the same time.
- [ ] **S10-B4** · A startup scene that no file holds leaves the editor stuck · P3 · 🟠 Moderate ·
  2-3h ·
  done: when the manifest names a startup scene that no asset source holds, the startup load logs
  the error and then recovers as it does when no scene is named: it adopts an indexed
  `Startup.tescene` or creates one, and points the manifest at it, so the editor opens on a scene
  it can save. A named scene whose file exists but does not load keeps today's behaviour (an
  empty scene, and saving refused), so a file the editor could not read is never overwritten.
  Today any failed load opens an empty scene with no scene file, so every save is refused and
  only a hand edit of `project.toml` recovers (`apps/editor/src/EditorApp.cpp:105-107` at
  `4a8af74`). Found at S10-T8 on Nov 6, after `Startup.tescene` was deleted. Tests: a manifest
  that names a missing scene ends with a loaded scene, a manifest that names the new one, and a
  save that writes; a named scene that does not parse still opens empty and refuses to save.
  "The editor keeps running with a startup scene it cannot find" changes with it. Saving into a
  new file (Save As) is not part of it: it is T8's "more than one scene" on the [[Capability Map]].

### Story G: Product follow-up

- [ ] **S10-D5** · Triage what a cinematic showcase needs · P2 · 🟡 Light · 1-2h ·
  done: `/triage` weighs what the engine must provide to record a cinematic showcase, such as
  camera paths and capture at a fixed frame rate, and the [[Capability Map]] records the result.
  Due before E2's showcase ([[Channel]] § *How a video fits the plan*).

### Story H: Meshes and models before the renderer (Miguel) · build sized after S10-D9

E2 needs imported glTF models ([[Roadmap]], E2), and the engine has only the triangle's `Mesh`
(S9-T4). Miguel's call at planning, Oct 31: build the loader and the mesh and model formats
before the renderer.

- [x] **S10-D8** · Write the content pipeline's capability brief · P1 · 🟠 Moderate · 2-3h ·
  done: `/brief content pipeline` is agreed with Miguel and linked from [[Capability Map]] §
  *Content pipeline*: what import must bring in for E2 (meshes, submeshes, materials, textures,
  the node tree), from which formats, and what the asset browser waits for. Closed Oct 31
  (vault `a5ed725`).
- [ ] **S10-D9** · Design TEMesh, TEModel and the glTF loader · P1 · 🟢 Deep · 4-6h ·
  done: a new `Content Pipeline - Design` decides the runtime-form mesh and model files, how
  assimp's import writes them (ADR-025 §6), and sidecar or registry for a source's id
  ([[Resources - Design]] § *Open questions*, owner T4); then it cuts the build cards into this
  story. If the model format proves ADR-level, the card drafts the ADR instead and the build
  waits. Follows S10-D8 and S10-D4, because the seam ADR decides the vertex layout.

### Story I: Prepare Sprint 11 (standing)

- [ ] **S10-P2** · Prep brief for Sprint 11 · P2 · 🤖 Auto · report-only ·
  done: a run report lists the *Decided* rows with no code behind them, the open questions
  blocking them, the fired [[Backlog]] triggers and candidate 🤖 Claude features, and decides
  nothing. **Not before Mon Nov 9**: a fire before that leaves it in To Do.
- [ ] **S10-D6** · Prepare Sprint 11 · P1 · 🟠 Moderate · 2-3h ·
  done: `/sprint-prep` wrote the next sprint's goal and draft cut into this sprint note. Runs in
  week 2, Tue Nov 10 to Fri Nov 13, after S10-P2's brief.

## 🤖 Lanes

- 🤖 Claude features: Story B (S10-D1, S10-T3, S10-T4) and S10-T6, not before Fri Nov 6, after
  S10-T2. Story C moved to Miguel at planning.
- 🤖 Auto cards: S10-P1 and S10-P3. S10-B1 was folded into Miguel's S10-T10 on Nov 3, so the
  lane has no `engine/base` card this sprint.
  S10-T5 stays attended, because it edits `.github/workflows/ci.yml`, which the routine's token
  cannot push.
- Standing prep: S10-P2 (not before Mon Nov 9) and S10-D6 (Tue Nov 10 to Fri Nov 13).
- PR load: four PR-producing lane cards over two weeks (three 🤖 Claude, one 🤖 Auto), well under
  the limit. S10-P1, S10-P2, S10-P3 and S10-D1 are free. Review costs about 2h, inside one 🟡
  Tuesday.
- The routine runs at 09:07 and 14:07 Lisbon on weekdays ([[Autonomous Lane - Routine Prompt]]).
  With only seven lane cards, its fires will often find nothing to take; the afternoon fallback
  sweeps a module then.

## Definition of Done

- [x] File → Export writes a folder with the runtime beside its packs, and the runtime started
  from it logs the edited scene (S10-T3, Miguel's windowed check). Nov 2, `0dcbc1f`, #179.
- [x] The hierarchy and inspector edit several entities at once, with tests for the set, the
  topmost rule and the per-entity records (S10-T1, S10-T2). Nov 1, `9afda8d`, #178; Nov 3, `a6c832f`,
  #182.
- [ ] E1's internal demo ran its five scenarios, and E1 is marked closed on the [[Roadmap]]
  (S10-T7).
- [ ] The frame and device seam ADR and the materials ADR are Accepted and indexed by
  `Renderer - Design` (S10-D4, S10-D7).
- [ ] The content pipeline's brief is agreed, and `Content Pipeline - Design` has cut Story H's
  build cards (S10-D8, S10-D9).
- [x] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro. Nov 6: #179, #181 and #188, one reversal in all (S10-T4's Run exports
  first, #181 `78c48ab`).

## Capacity note

Sunday Nov 1 is a rest day. By the Rhythm table that leaves about 6-7 🟢, 2 🟠 and 2 🟡. Miguel
chose to size to his faster pace (a 🟢 card in about 1-2h, Sprint 09 retro). His cards are now
5 🟢 (S10-T8 a stretch), 6 🟠 and 4 🟡, plus about 4 build cards that S10-D2 and S10-D3 will cut,
and Story H's build. At two cards per session that is about ten sessions, against about nine.

- **This is over capacity on purpose.** It drops in this order: S10-T8, Story C's Profiler half,
  then Story H's build cards, which can open Sprint 11 instead. S10-T6 moved to the lane.
- **S10-D2 cut three 🟠 console cards** (S10-T10 to S10-T12) on Nov 3, one more than an editor-only
  console would have needed, because the sink fix in `base` comes first. S10-T9 shrank by the
  guard it gave S10-T10.
- **S10-D3 cut no build cards** on Nov 3: the Profiler panel waits for Play (E11), so the first
  thing to drop has dropped by design.
- **Design-heavy:** two ADRs, a brief and a format design. Sprint 09's Design cards each took
  about one session; S10-D9 may become an ADR of its own.
- **One 🟡 Tuesday goes to lane review**, so the other takes S10-T5, S10-T9 or S10-D5.
- **Critical path:** S10-D1 then S10-T3 (lane) and S10-T1 then S10-T2 end in S10-T7; S10-P1 then
  S10-D4 opens S10-D7 and S10-D9. Suggested order: S10-T1 Mon Nov 2, S10-D8 Tue Nov 3, S10-T2
  Thu Nov 5, S10-D4 and S10-D7 on the Nov 7-8 weekend, S10-D9 in week 2.
- **The first week measures the new pace.** The Nov 7-8 weekly review resets the size if it was
  wrong.

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
