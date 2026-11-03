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
- **First Design card:** S10-D1, the lane's export design, on day 1. Story C, the console and
  Profiler panels, stays unsized until S10-D2 and S10-D3 cut it, and Story H's build stays unsized until
  S10-D9.
- **Brief check:** the content pipeline has no capability brief, so S10-D8 runs `/brief` before
  S10-D9 designs TEMesh, TEModel and the glTF loader ([[Principles]] P3).
- **Showcase:** none. E1 ends in an internal demo (S10-T7), which [[Principles]] P4 allows since
  Oct 31.
- **Coverage gap:** neither the renderer nor the content pipeline has a design note. S10-D4 starts
  `Renderer - Design`, and S10-D9 starts `Content Pipeline - Design`.
- [[Known Issues]]: D5 is carded as S10-B1 under the three-sprint rule.

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
- [ ] **S10-T2** · The inspector edits every selected entity · P1 · 🟢 Deep · 4-6h ·
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
- [ ] **S10-T8** · Edit an `AssetRef` in the inspector · P3 · 🟢 Deep · 4-6h · stretch ·
  done: the inspector edits an `AssetRef` field through a picker that offers the `AssetIndex` ids
  of the field's type, which `FieldVisitor::visitAsset` now passes. A set-field command adds the
  id as a dependency of the scene entry (`App::m_sceneHandle`) and fills the handle, so a
  `MeshRenderer` added in the editor gets its mesh. `/card-start` decides the policy for a load
  that fails inside a batch, and [[Editor - Design]] § *Open questions* records it. Tests: a set
  over a known mesh fills the handle; a set over an unknown id is refused. Follows S10-T2 and the
  lane's S10-T6, because all three change the inspector.

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

### Story C: Editor panels: console and Profiler (Miguel) · ~4 tasks · size after S10-D2 and S10-D3

The two Shoulds of [[Editor - Brief]] § *Requirements* that have no design yet, moved from the lane
to Miguel at planning. Both panels touch `EditorApp.cpp` and `PanelsManager.cpp`, so their build
cards follow S10-T4. Cvars stay out: where a cvar lives and which thread owns it probably needs
an ADR. The Profiler half drops first.

- [ ] **S10-D2** · Design the console panel · P2 · 🟠 Moderate · 2-3h ·
  done: [[Editor - Design]] decides, against [[Logger - Design]], how records reach main (the sink
  runs on any thread, so a bounded copy), what the panel keeps and drops, and its filters, then
  cuts the console's build cards into this story.
- [ ] **S10-D3** · Design the Profiler panel · P3 · 🟠 Moderate · 2-3h ·
  done: [[Editor - Design]] decides, against [[Profiler - Design]] and ADR-019's copied timing
  metrics, what the panel shows beside Tracy and where it reads the timings, then cuts the
  Profiler's build cards into this story. Follows S10-D2.

### Story D: E1's loose ends (Miguel)

- [x] **S10-T5** · Diff coverage leaves out ImGui drawing · P2 · 🟡 Light · 1-2h ·
  done: `ci.yml`'s diff coverage excludes `apps/editor/src/ui/`, and [[Editor - Design]] says
  `ui/` holds drawing only, so logic stays in `edit/`. The `te_sdk_smoke` comments in
  `sdk/CMakeLists.txt:9` and `ci.yml` name `TechEngineSDKSmoke`. CI config, so attended.
- [ ] **S10-T6** · Local and World modes in the transform inspector · P3 · 🤖 Claude · 2-3h ·
  done: a toggle shows world values, and a World edit is converted to local on the simulation
  thread through `setWorld` ([[Scene - Design]] § *Editor Local / World editing*). A test sets a
  world position on a child of a moved parent and reads back the expected local value. The PR
  ends with "needs Miguel's visual check" for the toggle. Moved to the lane at planning. **Not
  before Fri Nov 6**: S10-T2 is planned for Thu Nov 5 and changes the same inspector files, so if
  S10-T2 slips, Miguel moves this date with it.
- [ ] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h ·
  done: Miguel runs [[Editor - Brief]]'s five scenarios windowed, the runtime's log from the export
  folder names the edited entities, and the result is recorded. E1 is marked closed on the
  [[Roadmap]]. Follows S10-T2 and S10-T3.
- [ ] **S10-T9** · The base sweep's two leftovers · P3 · 🟡 Light · 1-2h ·
  done: the version anchors go (`baseVersion()`, `platformVersion()`, `coreVersion()`, `Base.hpp`,
  `Base.cpp` and `BaseTests.cpp`, whose glm case repeats `MathTests.cpp`). One log-capture guard in
  `te_test_support` replaces the seven copies (`LogTests.cpp`, `AssertTests.cpp`,
  `TaskGraphTests.cpp`, `ResourceCacheTests.cpp`, `RuntimeAppTests.cpp`, `SceneAssetTests.cpp`,
  and `HierarchyCommandsTests.cpp`, added by S10-T1),
  with the record fields it copies chosen at `/card-start`. About 65 lines, from the base sweep of
  Oct 29. Follows S10-B1 (`engine/base`) and S10-T3, which may add a runtime test.

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
- [ ] **S10-P3** · Paper report for the materials ADR · P2 · 🤖 Auto · report-only ·
  done: the validated materials and shading papers ([[Research]], Rendering) are mapped onto
  [[Renderer - Brief]]'s shading models and standard material, without choosing.
- [ ] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts R1's second ADR from [[Renderer - Brief]] and S10-P3's report; Miguel accepts
  it, and `Renderer - Design` indexes it. With S10-D4, R1 is unblocked for Sprint 11. Follows
  S10-P3 and S10-D4.

### Story F: Defects

- [ ] **S10-B1** · `removeLogSink(nullptr)` reports success (D5) · P3 · 🤖 Auto · 1-2h ·
  done: `removeLogSink` returns `LogError::NullSink` for a null sink before the loop, as
  `addLogSink` does, with one `LogErrorTests.cpp` case; D5 is deleted from [[Known Issues]].
  Merges before S10-D2's build cards if the console touches `Log.cpp`.
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
- 🤖 Auto cards: S10-P1, S10-P3 and S10-B1. S10-B1 stays in `engine/base`, and S10-T9 follows it.
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
- [ ] The hierarchy and inspector edit several entities at once, with tests for the set, the
  topmost rule and the per-entity records (S10-T1, S10-T2).
- [ ] E1's internal demo ran its five scenarios, and E1 is marked closed on the [[Roadmap]]
  (S10-T7).
- [ ] The frame and device seam ADR and the materials ADR are Accepted and indexed by
  `Renderer - Design` (S10-D4, S10-D7).
- [ ] The content pipeline's brief is agreed, and `Content Pipeline - Design` has cut Story H's
  build cards (S10-D8, S10-D9).
- [ ] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro.

## Capacity note

Sunday Nov 1 is a rest day. By the Rhythm table that leaves about 6-7 🟢, 2 🟠 and 2 🟡. Miguel
chose to size to his faster pace (a 🟢 card in about 1-2h, Sprint 09 retro). His cards are now
5 🟢 (S10-T8 a stretch), 6 🟠 and 4 🟡, plus about 4 build cards that S10-D2 and S10-D3 will cut,
and Story H's build. At two cards per session that is about ten sessions, against about nine.

- **This is over capacity on purpose.** It drops in this order: S10-T8, Story C's Profiler half,
  then Story H's build cards, which can open Sprint 11 instead. S10-T6 moved to the lane.
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
