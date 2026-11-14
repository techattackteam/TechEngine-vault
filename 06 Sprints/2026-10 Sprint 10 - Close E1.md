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
- [x] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h ·
  done: Miguel runs [[Editor - Brief]]'s five scenarios windowed, the runtime's log from the export
  folder names the edited entities, and the result is recorded. E1 is marked closed on the
  [[Roadmap]]. Follows S10-T2 and S10-T3. Closed Nov 14 with no PR, on Miguel's statement that he
  ran the five scenarios during development rather than as one recorded run.
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
- [x] **S10-D4** · The frame and device seam ADR · P1 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts it from [[Renderer - Brief]] and S10-P1's report; Miguel accepts it, and a
  new `Renderer - Design` indexes it. Meets Q4's ADR line. Follows S10-P1. Closed Nov 6 (vault
  `22f1514`): [[ADR-028 - Render device seam and frame packets]], Accepted, indexed by
  [[Renderer - Design]]. ADR-005 is amended for the GL 4.6 and bindless floor, and ADR-006 §5's
  Renderer row is partially superseded.
- [x] **S10-P3** · Paper report for the materials ADR · P2 · 🤖 Auto · report-only ·
  done: the validated materials and shading papers ([[Research]], Rendering) are mapped onto
  [[Renderer - Brief]]'s shading models and standard material, without choosing. Closed Nov 4 by
  the lane (vault `7bfdda8`): [[Renderer - Materials Paper Report]], from Filament's and glTF's
  documents, since no paper host was reachable.
- [x] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts R1's second ADR from [[Renderer - Brief]] and S10-P3's report; Miguel accepts
  it, and `Renderer - Design` indexes it. With S10-D4, R1 is unblocked for Sprint 11. Follows
  S10-P3 and S10-D4. Closed Nov 10 (vault `9a69f70`): [[ADR-029 - Materials, surfaces and lobes]],
  Accepted, indexed by [[Renderer - Design]]. Clear coat, sheen and transmission are postponed
  out of E2 in [[Renderer - Brief]]. R1's design is unblocked; CI's GL floor and the material
  file card are not.

### Story F: Defects

- [x] **S10-B1** · `removeLogSink(nullptr)` reports success (D5) · P3 · 🤖 Auto · 1-2h ·
  **folded into S10-T10** on Nov 3 by S10-D2, and taken off the lane: `removeLogSink` now takes a
  `LogSink&`, so a null sink cannot be passed, and S10-T10 deletes D5.
- [x] **S10-B2** · Roots keep their order · P2 · 🟠 Moderate · 2-3h · #197 `1b67345`, Nov 10 ·
  done: `Scene` keeps an order for root entities, so adding a component or destroying another
  root no longer moves a root, and a saved scene writes its roots in that order. Today
  `Scene::getRoots()` returns archetype storage order (`engine/core/src/scene/Scene.cpp:238` at
  `5c57bf8`), and removal swap-erases; found at S9-T16's `/card-start`. Tests: a root that gains a component keeps its position;
  destroying a root leaves the others in order; a save and a read keep the order. Whether the
  hierarchy may then reorder roots is decided at `/card-start`. Decided Nov 10: `Scene` takes a
  root position, and the panel's drop between roots stays refused ([[Backlog]]).
- [x] **S10-B3** · A reparent under a rotated, non-uniformly scaled parent is refused · P3 ·
  🟠 Moderate · 2-3h · #204 `6836c87`, Nov 14 ·
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
  Decided Nov 14: `setWorld` and a `PreserveWorld` detach take the same rule, and no closeness
  bound applies, only a degeneracy threshold ([[Scene - Design]] § *Transform propagation*).
- [x] **S10-B4** · A startup scene that no file holds leaves the editor stuck · P3 · 🟠 Moderate ·
  2-3h · #204 `6836c87`, Nov 14 ·
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
  Closed Nov 14 on the same PR as S10-B3, which completes Story F.

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
- [x] **S10-D9** · Design TEMesh, TEModel and the glTF loader · P1 · 🟢 Deep · 4-6h ·
  done: a new `Content Pipeline - Design` decides the runtime-form mesh and model files, how
  assimp's import writes them (ADR-025 §6), and sidecar or registry for a source's id
  ([[Resources - Design]] § *Open questions*, owner T4); then it cuts the build cards into this
  story. If the model format proves ADR-level, the card drafts the ADR instead and the build
  waits. Follows S10-D8 and S10-D4, because the seam ADR decides the vertex layout. Closed Nov 6
  (vault `d430705`), split: [[Content Pipeline - Design]] decides the model and cut its build
  cards below, and the mesh half moved to S10-D10. No ADR was needed.
- [x] **S10-P4** · Research report for mesh merging and import · P2 · 🤖 Auto · report-only ·
  done: a run report answers these questions without choosing. How does assimp merge a file
  into one mesh (`aiProcess_PreTransformVertices`, `aiProcess_OptimizeMeshes`), and what does
  each flag lose? How does a merge keep one material slot per source material, with no texture
  atlas? How are MikkTSpace tangents generated, and how is winding fixed under a negative scale?
  Which glTF material extensions (clear coat, sheen, transmission) survive assimp? Which BC
  compression libraries fit, and how fast are they? Should TEMesh v2 carry an optional second
  UV set, which R7's baked mesh LOD would need, so that baking never breaks the file format?
  Cut Nov 6 at S10-D9. Feeds S10-D10's vertex attributes and the merge build card. Closed Nov 9
  by the lane (vault `9a27c99`): [[Content Pipeline - Mesh Import Report]]. No speed was measured.
- [x] **S10-D10** · Design TEMesh v2 and re-import · P1 · 🟢 Deep · 4-6h ·
  done: [[Content Pipeline - Design]] decides TEMesh v2 (material slots as index ranges, its
  vertex attributes and tangents, whether it keeps an optional second UV set, and its import
  block), materials per slot on `MeshRenderer`, the merged mesh, and how a re-import keeps each
  file's id. It files ADR-024 §9's dated decision amendment, so a re-import reloads at once, then
  cuts those build cards into this story. Split from S10-D9 on Nov 6. Follows S10-P4; the slots
  point at S10-D7's material type. Narrowed on Nov 9: the texture file moved to S10-D11, because
  its formats follow what S10-D7's material samples. Closed Nov 9 (vault `5408328`): it cut
  S10-D11 and S10-T17 to S10-T21.
- [x] **S10-D11** · Design the texture file · P1 · 🟠 Moderate · 2-3h ·
  done: a `/triage` decides whether the sky's HDR image comes through import, since
  [[Content Pipeline - Brief]] lists only PNG, JPEG, TGA and DDS. Then
  [[Content Pipeline - Design]] decides the `.tetexture` file, the BC format for each input that
  S10-D7's material samples, the mips, the encoder and the image decoder, and how a re-import
  matches a texture; then it cuts the texture build card into this story. No ADR: a wrong format
  costs a version bump and a re-import. Follows S10-D7. Split from S10-D10 on Nov 9. The
  candidates are mapped in [[Content Pipeline - Mesh Import Report]] §6. Closed Nov 10 (vault
  `9915e78`): it cut S10-T22 to S10-T25, the material file's cards among them.

The model's cards below were cut on Nov 6 from [[Content Pipeline - Design]], the mesh's on
Nov 9 (S10-D10), and the texture and material cards on Nov 10 (S10-D11). They can open Sprint 11
(§ *Capacity note*). Order: S10-T13 and S10-T14 come first; S10-T15 follows both, and S10-T16
follows S10-T14. S10-T17 follows S10-T14; S10-T18 follows S10-T17 and S10-D7; S10-T19 follows
S10-T15 and S10-T17; S10-T20 follows S10-T19 and S10-T16; S10-T21 follows S10-T18 and S10-T19.
S10-T22 follows S10-T14; S10-T23 follows S10-T22; S10-T24 follows S10-T23 and S10-T19; S10-T25
follows S10-T22.

- [x] **S10-T13** · assimp in the editor build · P1 · 🟠 Moderate · 2-3h ·
  done: assimp is pinned in `cmake/deps.cmake` with only its glTF, FBX and OBJ importers, and it
  links into `apps/editor` alone; the runtime and `TechEngine::sdk` do not link it. The PR states
  the editor's clean build time before and after. Closed Nov 6: #192 `e59d77c`. Miguel waived
  the build times at the close, so the PR states neither.
- [x] **S10-T14** · The import block and the TEModel file · P1 · 🟢 Deep · 4-6h ·
  done: `core` gains the import block and the `.temodel` node table, with write and read, and the
  editor's asset index lists the model kind (`apps/editor/src/assets/AssetIndex.cpp:33-36`).
  Today's `.temesh` gets no import block yet; that comes with TEMesh v2. Tests: a model with a
  root and nested nodes writes and reads back equal; a node list with a parent after its child, or
  with two roots, is refused with an error code; the import block round-trips; the asset index
  lists a `.temodel`. Closed Nov 6: #193 `ac594e4`. It ran as a 🟠 Moderate.
- [x] **S10-T15** · Import a source file as a model · P1 · 🟢 Deep · 4-6h ·
  done: an editor command imports a glTF, FBX or OBJ file as a job, into a folder beside it: a
  `.temodel`, and one `.temesh` per source mesh in today's format, with scale and up axis baked
  in. Until the asset browser exists, the editor imports one hardcoded source file at startup
  and skips it quietly when its folder already exists; a `TODO` names the browser's card. Tests: a small glTF fixture imports with its node and mesh counts; a scale of
  0.01 and a Z-up axis give the expected vertex positions and an identity root; importing into
  an existing folder is refused, because re-import does not exist yet
  (`apps/editor/src/EditorApp.cpp:434-456` refuses to overwrite). Follows S10-T13 and S10-T14.
  Closed Nov 9: #194 `9c93b8f`. The TODO is `TODO(E2)`, because no browser card exists yet.
- [x] **S10-T16** · Place a model as copies · P1 · 🟠 Moderate · 2-3h ·
  done: placing a `.temodel` builds its entities in the open scene through one edit command
  (ADR-027 §3): `Name`, `Transform`, `Hierarchy` and `MeshRenderer`, under one root at the origin,
  with no reference to the model file. Until the asset browser exists, a small *Place model* menu
  entry takes a typed path and sends the same command; placing at startup is out, because every
  launch would add another copy to a saved scene. Tests: a three-node model adds three entities with their parents and
  local transforms; placing it twice gives two independent trees; editing one copy changes
  neither the other nor the file. Follows S10-T14. Closed Nov 10: #196 `9233481`.
- [x] **S10-T17** · TEMesh v2's file · P1 · 🟢 Deep · 4-6h ·
  done: `Mesh` is TEMesh v2 at `MESH_KIND` version 2 ([[Content Pipeline - Design]] § *The mesh
  file*): the id, the import block, the stream flags, the four streams, `u32` indices and the slots,
  with write and read. Its loader lists each non-null default material as a dependency.
  `projects/dev/assets/client/Triangle.temesh` is written again, and the asset index still lists a
  mesh. Tests: a mesh with two slots and every stream writes and reads back equal; a mesh with
  positions only reads back with empty optional streams; a slot range past the indices, a gap or
  an overlap between slots, a range that is not whole triangles, and no slots at all are each
  refused with `ReadError::Malformed`; a version 1 file is refused with `ReadError::BadVersion`;
  the loader's dependencies hold the non-null defaults and no null one. Follows S10-T14.
  Closed Nov 10: #198 `d781e99`. It also rewrote the 103 Sponza meshes and gave the import a key
  and one slot per mesh.
- [x] **S10-T18** · Materials per slot on `MeshRenderer` · P1 · 🟢 Deep · 4-6h ·
  done: `Writer`, `Reader`, `ReferenceVisitor` and `FieldVisitor` visit a vector of a visitable
  type element by element, and the bulk path still refuses a vector of `Entity` or `AssetRef`.
  `MeshRenderer` gains its slot list ([[Content Pipeline - Design]] § *Materials per slot*), the
  inspector shows one row per slot, and the list is rebuilt by slot name when the editor opens a
  scene and after a re-import. Tests: a scene with a two-slot renderer saves and loads its
  materials, and both the scene's acquire set and the bake's walk name them; after the mesh's
  slots are reordered, a rebuild keeps each material on its named slot; a new slot takes its
  default; a removed slot is dropped. Follows S10-T17 and S10-D7's material type.
  Closed Nov 10: #199 `099823e`. The rebuild after a re-import is S10-T21's, and the material
  type stays a forward declaration until S10-T23.
- [x] **S10-T19** · Import writes TEMesh v2 · P1 · 🟢 Deep · 4-6h ·
  done: S10-T15's import writes v2 meshes with one slot each, normals (generated when missing),
  the file's tangents or MikkTSpace's re-indexed through meshoptimizer, and UV0. MikkTSpace and
  meshoptimizer are pinned in `cmake/deps.cmake` and linked by the editor alone. A glTF whose
  `extensionsUsed` lists `KHR_mesh_quantization` or a meshopt compression extension is refused
  with an error code before assimp reads it. Tests: a glTF fixture with tangents keeps them; one
  without gets unit tangents with `w` of ±1; after a Z-up bake, `cross(n, t.xyz) * w` still matches
  the baked bitangent; a quantized fixture is refused. Follows S10-T15 and S10-T17.
  Closed Nov 11: #201 `c99bf04`. It also fixed D8, split the import into `ModelImporter` and
  `MeshImporter`, and imported Sponza again with the streams.
- [x] **S10-T20** · Import as one merged mesh · P1 · 🟢 Deep · 4-6h ·
  done: import in merged mode writes the root `.temesh` from the model walk
  ([[Content Pipeline - Design]] § *The merged mesh*): world transforms baked, triangles flipped
  under a negative determinant, tangents' `w` multiplied by its sign, one slot per source material
  and missing streams filled with defaults. Placing a merged mesh adds one entity with `Name`,
  `Transform` and `MeshRenderer` through one edit command. Tests: a two-node glTF with one node
  scaled −1 on X gives the mirrored half's triangles in reversed order; two materials give two
  slots in material-index order; a part without UV0 joins with zero UVs; placing it adds one
  entity whose slot list matches the mesh. Follows S10-T19 and S10-T16.
  Closed Nov 14: #203 `25c93a4`, with S10-T21 to S10-T25. A `.temesh` goes through *Place model...*.
- [x] **S10-T21** · Re-import keeps ids and reloads · P1 · 🟢 Deep · 4-6h ·
  done: a *Re-import* menu entry with a typed path re-imports a source file into its folder while
  the editor is Stopped, and is refused otherwise ([[Content Pipeline - Design]] § *Re-import*).
  Outputs match old files by source key, name first, and keep their ids; matched materials are
  untouched; unmatched old files stay and are logged; importing the other way switches the root
  asset. `ResourceCache` gains a reload that replaces payloads behind live handles in a loading
  phase (ADR-024 §9, amended Nov 9), and the open scene's slot lists are rebuilt after it. S10-T15's
  refusal to import into an existing folder becomes this path. Tests: re-importing an unchanged
  fixture keeps every id; a fixture whose meshes are reordered keeps each id on its named mesh; a
  new mesh gets a fresh id and a removed one's file stays; a handle held across a reload resolves
  to the new payload with the same generation; a reload that adds a dependency acquires it, and
  one that drops a dependency releases it. Follows S10-T18 and S10-T19. It may split at the cache's
  reload. Closed Nov 14: #203 `25c93a4`, unsplit. The Stopped refusal cannot fire until E11 sets
  the play state (D10 is its in-flight guard).
- [x] **S10-T22** · The texture file · P1 · 🟠 Moderate · 2-3h ·
  done: `core` gains `Texture` at `TEXTURE_KIND` version 1 ([[Content Pipeline - Design]] §
  *The texture file*): the id, the import block, the shape, the format, the size, the mip count,
  the sampler and the mips, with write and read. Its loader is registered in the editor and the
  runtime (`apps/editor/src/EditorApp.cpp:102-103`, `apps/runtime/src/RuntimeApp.cpp:42-43`), and
  the asset index lists the texture kind (`apps/editor/src/assets/AssetIndex.cpp:35-37`). Tests: a
  `BC7_SRGB` texture and an `RGB9E5` texture, each with a full mip chain, write and read back
  equal; a mip count that is not the full chain for the size, a mip whose byte count does not
  match its format and size, a shape other than 2D and an unknown format are each refused with
  `ReadError::Malformed`; the asset index lists a `.tetexture`. Follows S10-T14. Cut Nov 10 at
  S10-D11. Closed Nov 14: #203 `25c93a4`.
- [x] **S10-T23** · The material file · P1 · 🟢 Deep · 4-6h ·
  done: `core` gains `Material` and its `.tematerial` file
  ([[ADR-029 - Materials, surfaces and lobes]]): the id, the import block, the surface, the
  shading model, the alpha mode and its cutoff, the double-sided flag, and each factor beside its
  `AssetRef<Texture>`, one per input of ADR-029 §7, with write and read. Its loader, in the editor
  and the runtime, lists each non-null texture as a dependency, and the asset index lists the
  material kind. The card settles the file's layout and the material buffer's, and what a slot
  with a null material draws, and records them in [[Renderer - Design]] (§ *Open questions* names
  this card). Tests: a material with all four textures writes and reads back equal; one with no
  textures reads back with null references and its factors; an unknown alpha mode or shading
  model is refused with `ReadError::Malformed`; the loader's dependencies hold the non-null
  textures and no null one; the asset index lists a `.tematerial`. Follows S10-T22. Cut Nov 10 at
  S10-D11. Closed Nov 14: #203 `25c93a4`. The layouts and the null slot are in [[Renderer - Design]].
- [x] **S10-T24** · Import writes materials and textures · P1 · 🟢 Deep · 4-6h ·
  done: S10-T15's import writes one `.tematerial` per source material into `Materials/`, and their
  textures into `Textures/` ([[Content Pipeline - Design]] § *Texture import*), and each v2 mesh
  slot names its material as the default. An unnamed material gets a stable name from its index,
  not its pointer address (§ *Porting v1's import*). stb_image, bcdec and bc7enc_rdo are pinned in
  `cmake/deps.cmake` and linked by the editor alone. Tests: two materials that share a base color
  image write that texture once; separate occlusion and metallic-roughness images give one ORM
  texture, red from occlusion and green and blue from the other; a material with no occlusion
  gives a red of 1; a `.glb` fixture's embedded PNG is imported; a BC1 DDS fixture is decoded and
  written as BC7; each texture has its input's format and a full mip chain; the mip builder keeps a
  normal map's texels unit length at every level; each texture's source key names its path,
  purpose and sampler. Follows S10-T23 and S10-T19. It may split at the textures. Cut Nov 10 at
  S10-D11. Closed Nov 14: #203 `25c93a4`, unsplit. Not run on Sponza, whose images are not in the
  repo.
- [x] **S10-T25** · Import the sky image · P1 · 🟠 Moderate · 2-3h ·
  done: an *Import image* menu entry with a typed path imports a `.hdr` file as a job into
  `<name>.tetexture` beside it, as `RGB9E5` with a full mip chain and an empty source key
  ([[Content Pipeline - Design]] § *The sky image*). Importing when that file already exists is
  refused, as a model's folder is, until S10-T21's re-import; a path that is not a `.hdr` is
  refused with an error code. Tests: a small `.hdr` fixture gives an `RGB9E5` texture of its size
  with a full mip chain, whose top level matches the source within `RGB9E5`'s precision; an
  existing output is refused; a `.png` path is refused. Follows S10-T22; whichever of S10-T24 and
  this card lands first pins stb_image. Cut Nov 10 at S10-D11. Closed Nov 14: #203 `25c93a4`.
  Re-import landed with it, so an existing output is re-imported through *Re-import...*.

### Story I: Prepare Sprint 11 (standing)

- [x] **S10-P2** · Prep brief for Sprint 11 · P2 · 🤖 Auto · report-only ·
  done: a run report lists the *Decided* rows with no code behind them, the open questions
  blocking them, the fired [[Backlog]] triggers and candidate 🤖 Claude features, and decides
  nothing. **Not before Mon Nov 9**: a fire before that leaves it in To Do. Closed Nov 9 by the
  lane: [[2026-11-09 14-12 Auto Run]].
- [x] **S10-D6** · Prepare Sprint 11 · P1 · 🟠 Moderate · 2-3h ·
  done: `/sprint-prep` wrote the next sprint's goal and draft cut into this sprint note. Runs in
  week 2, Tue Nov 10 to Fri Nov 13, after S10-P2's brief. Closed Nov 14, a day late: the cut is
  below.

#### Sprint 11's cut

Drafts for `/sprint-plan`, which gives them `S11-` IDs and fits them to capacity. Cut by S10-D6
on Nov 14, one day after its window, with Miguel's picks.

- **Proposed goal:** E2's first frame. Sponza, imported with its textures, is drawn through a
  camera in the runtime's window, on the new device, with base color only. The editor's scene
  view shows the same frame and is the first part to drop. This is the first of about three
  sprints for E2; the sun, the sky, the lit pass and the finished image follow.
- **First Design card:** card 1, CI's GL floor. Cards 3 and 4 raise the GL check, so they wait
  for it. No showcase card: E2 does not end this sprint.
- **Decided in this prep:** the camera component, the main active camera and the scene view's
  fly camera ([[Renderer - Design]] § *Decided*, [[Editor - Design]] § *Decided*). They answered
  two open questions in [[Editor - Design]].
- **Carry-over, not drafts:** both open 🟡 cards move to the lane (Miguel, Nov 14). S10-T7
  closed on Nov 14 instead, so E1 is done.
  - **S10-T9 goes as 🤖 Auto.** It passes all four questions of the gate: it removes the version
    anchors in `engine/base`, `engine/platform` and `engine/core` (`Base.hpp`, `Platform.hpp`,
    `Core.hpp` and their `.cpp`, `BaseTests.cpp`), which no R1 card touches, and `ctest`
    proves it.
  - **S10-D5 goes as 🤖 Claude, by Miguel's exception to the gate.** A `/triage` is a product
    decision, which § *The 🤖 Claude gate* keeps for Miguel. He chose to hand this one over. The
    lane records its call in the [[Capability Map]] with the date and "decided by the lane", and
    lists it under *Needs you* in its run report, because a vault card has no PR to review it in.
    Miguel reverses it there if he disagrees. It is due before E2's showcase, so it is off this
    sprint's critical path.
- **Fired [[Backlog]] entries:** card 1 (CI's software GL), card 2 (Story H has not met a real
  asset), card 15 (the runtime logs every entity), card 16 (a split mesh's child names) and
  card 17 (the README). *Test tiers and parallel ctest* rides with card 1 if its label path wins.
- **[[Known Issues]]:** D9, D10 and D11 neither block nor touch these cards. D11 rides along
  only if card 2 changes `ImageDecoder`.
- **Lane:** enabled, but the routine still owes the Nov 9 prompt paste
  ([[Autonomous Lane - Routine Prompt]] § *Routine configuration*). Paste it before a 🤖 Claude
  card runs.
- **Rough count:** Miguel 6 🟢, 3 🟠 and 1 🟡; 🤖 Claude 2 candidates plus S10-D5; 🤖 Auto 5
  with S10-T9. That is at the Rhythm table's limit of 6-7 🟢 before any carry-over, so
  `/sprint-plan` should expect to drop cards 11 and 12, then card 13.

##### What E2 still lacks, for Sprint 12 and after

The inputs check that this prep ran against E2's showcase sentence ([[Roadmap]], E2). None of
these has a card yet, and each needs a decision before it can have one:

- **The sun.** No light component exists in code, and [[Renderer - Design]] has no *Decided* row
  for one.
- **Material edits in the inspector** (a Must in [[Renderer - Brief]]): the asset edit path is
  not designed ([[Backlog]] § *editor & tooling*, `#prio/high`).
- **The asset browser** (a Must in [[Content Pipeline - Brief]]): no design. Card 13 takes it if
  a slot is left.
- **Sky lighting, anti-aliasing and the lit model's terms:** open in [[Renderer - Design]] §
  *Open questions*.
- **Bistro:** never imported, and FBX has no fixture.
- **The showcase:** no outline exists, and S10-D5 is still open.

##### Day 1

1. **D · CI's GL floor** · P1 · 🟠 Moderate · 2-3h · done: a spike branch shows whether zink
   over lavapipe gives CI a GL 4.6 context with `ARB_bindless_texture`, on the Linux legs and on
   Windows' Mesa. ADR-028 gets a dated amendment that says how CI runs the window and render
   tests: through zink, or under a ctest label that CI skips and Miguel runs locally. The seven
   test files that open a window through the render thread are listed in it. It edits `ci.yml`,
   so it is attended, and each spike push costs CI minutes. If the label path wins, the fired
   *test tiers* entry is done in the same PR. *From a fired Backlog entry.*
2. **T · Story H meets a real asset** · P1 · 🟠 Moderate · 2-3h · done: Sponza's images are in
   `projects/dev` with a licence file beside them, and *Re-import...* rewrites Sponza with every
   id kept and each mesh slot naming a material. *Import image...* runs on a real `.hdr`, and a
   merged `.temesh` is placed by hand. The PR states BC7's encode time for Sponza. Each defect
   found is fixed there or carded. *From a fired Backlog entry.*

##### Story: R1's first frame (Miguel)

Cut against [[Renderer - Design]] § *Decided*. Each card writes its own mechanism section into
that note. Order: 3 follows 1; 4 follows 3; 5 follows 4 and 6; 7 follows 4; 8 and 9 follow 7;
10 follows 5, 8 and 9.

3. **T · GL 4.6 and bindless at startup** · P1 · 🟡 Light · 1-2h · done: glad2 is regenerated
   with `--api gl:core=4.6` and `ARB_bindless_texture` (`cmake/deps.cmake:244-246`), and the
   startup check (`engine/client/src/render/RenderThread.cpp:93`) logs which requirement failed
   (§ *Build notes*).
4. **T · The device** · P1 · 🟢 Deep · 4-6h · done: a device in `client` with typed handles
   for buffers, textures, pipelines and render targets, pipelines bound whole and explicit
   render passes (ADR-028 §1). M4's triangle draws through it, `FrameRenderer` makes no GL call,
   and `Buffer` and `VertexArray` fold into it. Storage buffers are in; compute dispatch waits
   for the light clusters. The device's surface is settled at `/card-start`.
5. **T · Frame packets replace the snapshot** · P1 · 🟢 Deep · 4-6h · done: the extraction hook
   reads the `Scene` into a pooled packet after ticks and after applied edits, and render moves
   it instead of copying (ADR-028 §3; the copies are listed in § *References*). The pool holds
   four packets. A packet carries each `MeshRenderer`'s world transform, mesh and slot materials,
   and the main active camera. Tests: simulation never waits with four packets; an edit in the
   Stopped editor produces a packet. How render matches an instance across two packets is this
   card's open question.
6. **T · The camera component** · P1 · 🤖 Claude candidate · 2-3h · done: `Camera` in `core`
   with the fields in § *Decided*, registered in both apps, shown by the inspector, and one
   `core` function that returns the main active camera. Tests: the first `main` camera in
   hierarchy order wins; a scene with none returns nothing, and the caller warns once. It stops
   at that function, so it stays off card 5's files.
7. **T · Ordered uploads and render's fence** · P1 · 🟢 Deep · 4-6h · done: mesh, texture and
   material uploads cross to render in order and are never dropped; render reports each upload
   done, and simulation defers a free until then (ADR-028 §4). A reload keeps its handle and
   sends a new upload, which replaces S10-T21's immediate destroy. Render drops a GPU copy by
   the rule in § *Decided*.
8. **T · Shared geometry buffers** · P1 · 🟢 Deep · 4-6h · done: § *Geometry buffers* as
   written: the three buffers with immutable storage, the free-list allocator, a second block
   when one fills, and defaults for a stream a mesh lacks. Tests, headless on the allocator: a
   freed range is reused, a mesh never moves, and a full block adds another.
9. **T · The material buffer and bindless textures** · P1 · 🟢 Deep · 4-6h · done: textures
   upload in their file's format with their mips and sampler, and each material writes its
   96-byte record with bindless handles (§ *The material buffer*). Record 0 is written at
   startup. This card decides which way a texture is sampled (§ *Open questions*).
10. **T · The first frame** · P1 · 🟢 Deep · 4-6h · done: one forward pass draws the packet with
    CPU-written multi-draws, one per draw bucket, and shades base color times its factor, with
    cut-outs discarded. The runtime shows Sponza through the scene's main camera. Miguel's
    windowed check and a capture are the proof. The mirrored-instance question is this card's;
    anti-aliasing is not in it.

##### Story: the scene view draws (drops first)

Cut against [[Renderer - Design]] § *Decided*, rows *The scene view is a render target*, *Views*
and *How the scene view's camera is driven*.

11. **T · The scene view is a render target** · P2 · 🟠 Moderate · 2-3h · done: the editor draws
    the frame into a texture that the scene view shows, sized to the panel, and the game view
    does the same through the main active camera. A hidden view is not drawn. Follows 10.
12. **T · The scene view's fly camera** · P2 · 🤖 Claude candidate · 2-3h · done: the camera's
    state and its update from mouse and key deltas live in `edit/` with tests; `SceneViewPanel`
    feeds it from ImGui while the right mouse button is held, and it reaches render on ADR-019
    §4's latest-value path. The PR ends with "needs Miguel's visual check". Follows 11.

##### Design, Process and the lane

13. **D · Design the asset browser** · P2 · 🟠 Moderate · 2-3h · done:
    [[Content Pipeline - Design]] decides what the list-only browser shows and how it imports,
    re-imports and places, and whether deleting an asset is weighed now (its [[Backlog]] entry
    fires with this card). It cuts the build cards for Sprint 12. Drops after cards 11 and 12.
14. **P · The inputs check in `/sprint-prep`** · P2 · 🤖 Auto · done: step 3 of
    `.claude/commands/sprint-prep.md` and [[Planning Workflow - Artifact Gate]] § *Where plans
    come from* gain one check: list everything the goal's showcase sentence consumes, and mark
    each built, carded, decided or undecided, before the goal is proposed. The table above is
    its first run. Driver: Sprint 10 found the resources missing only after planning.
15. **T · The runtime logs entities at Debug** · P3 · 🤖 Auto · done: `RuntimeApp::logSceneTree`
    writes its per-entity lines with `TE_LOGGER_DEBUG` and keeps one `INFO` summary line. After
    card 6, which also edits `RuntimeApp.cpp`. *From a fired Backlog entry.*
16. **T · A split mesh's children are named after their material** · P3 · 🤖 Auto · done: a
    placed model's children of one split mesh take their material's name, with `_1`, `_2` on a
    repeat, and a test places a two-primitive fixture. After card 2. *From a fired Backlog entry.*
17. **P · A README at the repo root** · P3 · 🤖 Auto · done: what the engine is, how to clone
    the vault, and the three preset commands. *From a fired Backlog entry.*

## 🤖 Lanes

- 🤖 Claude features: Story B (S10-D1, S10-T3, S10-T4) and S10-T6, not before Fri Nov 6, after
  S10-T2. Story C moved to Miguel at planning.
- 🤖 Auto cards: S10-P1, S10-P3 and S10-P4 (cut Nov 6 at S10-D9). S10-B1 was folded into Miguel's S10-T10 on Nov 3, so the
  lane has no `engine/base` card this sprint.
  S10-T5 stays attended, because it edits `.github/workflows/ci.yml`, which the routine's token
  cannot push.
- Standing prep: S10-P2 (not before Mon Nov 9) and S10-D6 (Tue Nov 10 to Fri Nov 13).
- PR load: four PR-producing lane cards over two weeks (three 🤖 Claude, one 🤖 Auto), well under
  the limit. S10-P1, S10-P2, S10-P3, S10-P4 and S10-D1 are free. Review costs about 2h, inside one 🟡
  Tuesday.
- The routine runs at 09:07 and 14:07 Lisbon on weekdays ([[Autonomous Lane - Routine Prompt]]).
  With only eight lane cards, its fires will often find nothing to take; the afternoon fallback
  sweeps a module then.

## Definition of Done

- [x] File → Export writes a folder with the runtime beside its packs, and the runtime started
  from it logs the edited scene (S10-T3, Miguel's windowed check). Nov 2, `0dcbc1f`, #179.
- [x] The hierarchy and inspector edit several entities at once, with tests for the set, the
  topmost rule and the per-entity records (S10-T1, S10-T2). Nov 1, `9afda8d`, #178; Nov 3, `a6c832f`,
  #182.
- [x] E1's internal demo ran its five scenarios, and E1 is marked closed on the [[Roadmap]]
  (S10-T7). Nov 14, no PR: Miguel's statement that he ran them during development.
- [x] The frame and device seam ADR and the materials ADR are Accepted and indexed by
  `Renderer - Design` (S10-D4, S10-D7). ADR-028 on Nov 6, vault `22f1514` (S10-D4); ADR-029 on
  Nov 10, vault `9a69f70` (S10-D7).
- [x] The content pipeline's brief is agreed, and `Content Pipeline - Design` has cut Story H's
  build cards (S10-D8, S10-D9). The brief on Oct 31 (vault `a5ed725`), the model's cards on Nov 6
  (vault `d430705`), the mesh's cards on Nov 9 (S10-D10, vault `5408328`), and the texture and
  material cards on Nov 10 (S10-D11, vault `9915e78`).
- [x] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro. Nov 6: #179, #181 and #188, one reversal in all (S10-T4's Run exports
  first, #181 `78c48ab`). Nov 14: #203's eight decisions, built by Claude and Fable on Miguel's
  Story H cards, accepted as merged at the close with no reversal. Nov 14: #204's six decisions on
  Miguel's Story F cards, merged with none reversed in review.

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
