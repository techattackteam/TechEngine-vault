# 2026-10 · Sprint 09: Close M6

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Oct 24 - Friday Nov 6, 2026.
- **Epic:** M6 · content, closed; E1 · Editor and export, opened with its decisions
  ([[Roadmap]]). Hubs: [[Resources - Design]] and [[Editor - Design]].

## Sprint goal

The startup scene and the mesh it references load through the resource cache, in the runtime
from packs and in the editor from loose files. That closes M6. Beside it, E1 makes its first
decisions: the editor's capability brief and the editor ADR.

Drafted by S8-D4's `/sprint-prep` on Oct 23 ([[2026-10 Sprint 08 - Content Path]] § *Sprint
09's cut*) and fitted at the boundary on Oct 24 ([[2026-10-24 Sprint 08 Retrospective]]).

## Artifact gate

- Story A and Story B are cut against [[Resources - Design]] § *Reference fields*,
  [[ADR-026 - Reference fields and scene-held acquires]], and ADR-024 §8 as amended on Oct 24.
- **First Design card:** S9-D1, the editor brief, then S9-D2, the editor ADR. Story D stays
  unsized until S9-D3 cuts it. No showcase card: M6 has no video, and E1 does not end this sprint.
- **Coverage gap:** the editor has no design note, so S9-D3 writes one.
- [[Known Issues]]: D5 neither blocks nor touches these cards. D3 is carded as S9-T10 under the
  three-sprint rule.

## Stories & tasks

### Story A: M6's scene and its references (Miguel)

- [x] **S9-T1** · The scene loads as a cache entry · P1 · 🟢 Deep · 4-6h ·
  done: a loader under `SCENE_KIND` keeps the scene's bytes as its payload and names no
  dependencies. One `core` function requests a scene through a cache, streams the payload into
  the live `Scene`, frees the bytes and returns the scene's handle ([[Resources - Design]] §
  *Reference fields*, *One load for every app*). `RuntimeApp::simulationStartupLoad()` calls it,
  with its `PackSource` held as a member and set as the cache's source. The handle is released in
  `simulationShutdown()`, so the shutdown log names nothing. A new call, made only by the owner,
  adds a dependency to a Ready entry, with the same cycle check a completion gets. The function's
  name and header, and where the handle lives, are settled at `/card-start`. *From a fired
  Backlog entry.*
- [x] **S9-T2** · Reference fields and the reference walk · P1 · 🟢 Deep · 4-6h ·
  done: a component with `visit` can hold `Entity` and `AssetRef<T>` fields (ADR-026 §2). One
  reference visitor over `visit` sees only those two types. `SceneAsset::write` saves an `Entity`
  as its target's row and an `AssetRef<T>` as its id, and `SceneAsset::read` maps rows back to
  entities in a second pass after the last row. A round-trip test with a test component proves
  both, including a reference to a later row and empty fields.
- [x] **S9-T3** · The loaded scene acquires its references · P1 · 🟠 Moderate · 2-3h ·
  done: after streaming, S9-T1's function walks the live `Scene`, adds each distinct id once as a
  dependency of the scene entry, runs a loading phase, then fills each `AssetRef<T>` handle.
  Tests prove one acquire per distinct id, none left after the scene is released, and that a
  reference that fails to load fails the startup load. Follows S9-T1 and S9-T2.

S9-T1 and S9-T2 depend on nothing, so either can open the sprint. Story B waits on all three.

### Story B: The mesh path, from the editor to the runtime · 🤖 Claude

The sprint's 🤖 Claude feature, and the lane's first. Claude cuts nothing further and decides
the rest under [[Planning Workflow - Artifact Gate]] § *The 🤖 Claude gate*, listing each
decision in its PR. Headless and proven by `ctest`, per the Sprint 09 trial terms. Off Miguel's
files: S9-T4 touches neither app's startup, and S9-T7, which edits `RuntimeApp.cpp`, waits for
S9-T3 to merge.

- [x] **S9-T4** · The mesh resource type · P1 · 🤖 Claude · 2-3h ·
  done: a `Mesh` payload with its own blob kind and type tag, its loader, and a row in
  `AssetIndex`'s table of asset kinds. A test registers the loader in a cache, writes a mesh and
  loads it back. The payload is a placeholder with the hard-coded triangle's shape, float3
  positions and `u32` indices (`engine/client/src/render/FrameRenderer.cpp:33-34`); R1's renderer
  ADR owns the real format and replaces it. The apps register the loader in S9-T6 and S9-T7.
  Depends on nothing.
- [x] **S9-T5** · The editor writes a mesh and a component that references it · P1 · 🤖 Claude · 2-3h ·
  done: the editor writes the triangle as a mesh asset in code, the way it writes the startup
  scene, through one asset-creation call that `writeStartupScene` also uses, and the `TODO` on
  `writeStartupScene` (`apps/editor/src/EditorApp.cpp:79`) goes. A component with an
  `AssetRef<Mesh>` field, registered in the editor, sits on an entity of a newly created startup
  scene and is saved with it. It holds only the mesh reference, and its name must not decide how
  R1 splits the mesh from its material. Follows S9-T2 and S9-T4. *From a fired Backlog entry.*
- [x] **S9-T6** · The editor reads its startup scene through the cache · P2 · 🤖 Claude · 2-3h ·
  done: when the project names a startup scene, `EditorApp::simulationStartupLoad()` registers the
  scene and mesh loaders and calls S9-T1's function with `LooseSource` as the cache's source, so a
  later launch opens on the saved scene instead of an empty one. The `TODO` at
  `apps/editor/src/EditorApp.cpp:56` goes. Follows S9-T1, S9-T3 and S9-T5.
- [x] **S9-T7** · The bake packs what the startup scene reaches · P1 · 🤖 Claude · 2-3h ·
  done: `Project::exportTo` walks the startup scene's references and packs each reached asset into
  its side's pack when the target ships that side, instead of the scene alone. The runtime
  registers the mesh loader and S9-T5's component, and a `RuntimeAppTests` case over an export
  proves the runtime loads the mesh. What an id the index does not know does to the export is
  Claude's call. Follows S9-T2, S9-T3 and S9-T5. Miguel's windowed run then closes M6's
  Definition of Done.

### Story C: E1's opening decisions (Miguel)

Cut against [[Capability Map]] § *Editor*, [[2026-Q4]] objective 2 and [[Window - Design]] §
*Open questions*.

- [x] **S9-D1** · Write the editor's capability brief · P1 · 🟠 Moderate · 2-3h ·
  done: `/brief editor` writes `01 Product/Capabilities/Editor - Brief.md`, linked from the map's
  § *Editor*. Miguel decides every line; Claude interviews. It says whether E1 includes a project
  launcher, reopening the last scene, and any Play state, because three [[Backlog]] entries
  trigger on the first editor UI card and the launcher is not on the map yet.
- [x] **S9-P1** · Research brief for the editor ADR · P2 · 🤖 Auto · 2-3h ·
  done: a report compares how Unity, Unreal and Godot run editor UI beside the simulation and
  render threads, and how ImGui-based editors hand draw data to a render thread that owns GL. It
  names its sources, marks what is from memory, and maps each answer onto ADR-018's threads and
  [[Window - Design]] § *The frame command buffer* without choosing. Report-only, best done in week 1.
- [x] **S9-D2** · Decide the editor's architecture · P1 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts the editor ADR from the brief and S9-P1's report, with the Unity and Unreal
  baseline. It decides whether ImGui shares the window and which thread draws it (ADR-015 §
  *Consequences*), how panels read the `Scene` (published copies or main's fence, ADR-024 §6), how
  an edit reaches the simulation thread, and what the stopped state is ([[Resources - Design]] §
  *Open questions*). Miguel accepts it. Follows S9-D1 and S9-P1.
- [x] **S9-D3** · Write the editor's design note and cut the first T1 cards · P1 · 🟡 Light · 1-2h ·
  done: a new `Editor - Design` note holds the ADR's mechanism and indexes it in its *Decided*
  rows, and the first T1 panel cards are cut against it into Story D, each with a `done:` clause
  and a size. Follows S9-D2.

### Story D: E1's first panels · 9 tasks · stretch

T1's dock, hierarchy, inspector and save ([[Roadmap]] § *Rung catalogue*), cut by S9-D3 on
Oct 26 against [[Editor - Design]]. Every card is P2, so dropping one never costs the goal. The
console, cvars and the Profiler panel are Shoulds in [[Editor - Brief]] and stay uncut. Export
as a command is T2's, not this story's.

- [x] **S9-T11** · ImGui draws in the editor's window · P2 · 🟢 Deep · 4-6h ·
  done: ImGui's docking branch, pinned in `cmake/deps.cmake`, links only into the editor, with
  its GLFW and OpenGL3 backends. `Client::start` takes an optional overlay that the render
  thread starts after GL loads, draws after the scene and before swap, and stops before it
  releases the context; the runtime passes none ([[Editor - Design]] § *The overlay seam*).
  `Window` and `Client` expose the native window to main. Main builds an ImGui frame on each
  wake and hands render its draw data newest-wins and its texture requests in order, never
  dropped. A `RenderThreadTests` case with a fake overlay proves the three calls run on the
  render thread in that order. Windowed: ImGui's demo window draws, and dragging it stays smooth.
  Depends on nothing.
- [x] **S9-T12** · Edit command admission · P2 · 🟠 Moderate · 2-3h ·
  done: `app` holds the bounded FIFO that [[Simulation Thread - Design]] § *Input and control
  handoffs* specifies: main submits without blocking, and a full or closed queue rejects visibly
  and never evicts. The queue is open only while the simulation thread runs. An accepted command
  wakes the simulation thread, which applies the whole batch to the live `Scene` at the top of
  each pass of its loop, before that pass's ticks and never inside one, so a command never waits
  for a tick. Commands accepted but not applied at shutdown are cancelled with one warning that
  gives their count. A command is a type with one virtual `apply` ([[Editor - Design]] §
  *Commands and the idle simulation*). Tests prove FIFO order on the live scene, a rejection at
  capacity 1, a rejection before the run and after stop, and the cancelled report; S9-T13's idle
  case proves the wake, because every App ticks until then. Nothing submits a command yet.
  Depends on nothing.
- [ ] **S9-T13** · The editor's simulation idles while Stopped · P2 · 🟠 Moderate · 2-3h ·
  done: an `App` can say that its simulation does not tick (ADR-027 §4). The editor says so, and
  the runtime keeps ticking unchanged. An idle simulation thread has no tick deadline: it sleeps
  until S9-T12's wake for an accepted command, or until stop, applies the batch as a loading
  phase, then runs a publication hook, so nothing ticks and nothing spins while Stopped. The editor detaches the `InputBuffer` while
  Stopped. `AppTests` cases prove that an idle app runs no tick across a wait, that a submitted
  command is applied and published within one wake, and that stop wakes it. Follows S9-T12.
- [x] **S9-T14** · Every `visit` field carries a name · P2 · 🤖 Auto · 1-2h ·
  done: `field` takes a name first, `archive.field("mesh", value.mesh)`, in `Writer`, `Reader`,
  `ReferenceVisitor`, every `visit` (`Transform`, `MeshRenderer`) and the test types. A name is
  a string literal, and `Transform`'s are `position.x`, `rotation.w` and so on. The three
  visitors ignore the name, so no byte changes: the existing round-trip and scene asset tests
  pass with only their `visit` bodies edited ([[Serialization - Design]] § *Decided*). Depends on
  nothing; S9-T15 and S9-T17 follow it.
- [ ] **S9-T15** · Every entity has a name · P2 · 🟠 Moderate · 2-3h ·
  done: a `Name` component in `core/scene/components/` holds one `std::string`. `App` registers
  it with `Transform`, and every new entity carries it, named `Entity` ([[Editor - Design]] §
  *Entity names*). It is saved and read with the scene, and a scene saved before it loads with
  the default name. `RuntimeApp::logSceneTree` prints each entity's name beside its index
  ([[Editor - Brief]], 2026-10-26). Tests: a round trip keeps names, including an empty name and
  two equal names; a scene without `Name` blocks loads with defaults. Existing tests that count
  an entity's components are adapted. Follows S9-T14.
- [ ] **S9-T16** · The published view and the hierarchy panel · P2 · 🟢 Deep · 4-6h ·
  done: after each applied batch that changed the scene, the simulation publishes the editor
  view (the hierarchy in tree order with names, the selection, the edit and saved revisions)
  newest-wins and wakes main ([[Editor - Design]] § *The published view*). A hierarchy panel
  draws from it and sends create, delete, reparent and select commands. It refuses a drop onto
  the dragged entity's own subtree, and a command the `Scene` rejects only logs a warning, so the
  [[Backlog]]'s `bool` mutator entry stays armed. Headless tests apply each command and check
  the published view. Windowed: the panel shows `projects/dev`'s startup scene. Follows S9-T11,
  S9-T13 and S9-T15.
- [ ] **S9-T17** · The inspector · P2 · 🟢 Deep · 4-6h ·
  done: `core/serialization` gains the field visitor, and each registered component a field walk
  in its registry record ([[Editor - Design]] § *Fields*). The published view adds the selected
  entity's components as field rows. The inspector edits each editable kind, renames the entity,
  and adds and removes components; every edit is a command that records the old value. How a
  `Transform` edit updates its world values is settled at `/card-start` (the note's *Open
  questions*). Tests: a set-field command changes exactly one field, publishes the new row, and
  records the old value. Follows S9-T14 and S9-T16.
- [ ] **S9-T18** · Save, the unsaved marker and the prompt on close · P2 · 🟠 Moderate · 2-3h ·
  done: a save command writes the live scene over the startup scene's indexed file on the
  simulation thread and publishes the saved revision ([[Editor - Design]] § *Save, the unsaved
  marker and close*). Ctrl+S and a menu item send it. The title shows an unsaved marker while the
  published revision differs from the saved one. Closing with unsaved edits asks Save, Discard or
  Cancel, and Cancel keeps the window open. `/card-start` decides what this first kept save does
  to [[Serialization - Design]]'s trigger for per-type versions. Tests: a save and a reload give
  the same scene; the saved revision follows a save; a failed write leaves the marker. Follows
  S9-T16.
- [ ] **S9-T19** · The dock, a placeholder scene view and the remembered layout · P2 · 🟠 Moderate · 2-3h ·
  done: a dockspace over the main window holds the panels and a placeholder scene view, with a
  default layout when none is saved. ImGui writes no file itself: the layout loads from and saves
  to `project://editorSettings/layout.ini` through `FileAccess` (ADR-027 §6), and
  `editorSettings/` is git-ignored. Windowed: rearrange the panels, relaunch, and they are where
  they were. Follows S9-T11; the hierarchy and inspector join the dock as S9-T16 and S9-T17 land.

S9-T11, S9-T12 and S9-T14 depend on nothing, so any of them can open the story. S9-T14 is the
lane's, and it must merge before S9-T15 and S9-T17 start.

### Story E: Alongside: the renderer brief

- [ ] **S9-D4** · Write the renderer's capability brief · P2 · 🟠 Moderate · 2-3h ·
  done: `/brief renderer` writes `01 Product/Capabilities/Renderer - Brief.md`, linked from the
  map's § *Renderer*. It also answers whether R1 is one renderer ADR or several (meshes,
  materials, the physically based pipeline), the question the Backlog's Roadmap revision left.
- [ ] **S9-P2** · Research brief for the renderer ADR · P3 · 🤖 Auto · 2-3h ·
  done: a report compares how Filament, Godot 4, Unity's URP and Unreal split the device seam,
  the mesh format and the physically based material model, against the brief's targets, and maps
  each onto ADR-005's device seam (F22) without choosing. Report-only. Follows S9-D4.

### Story F: Auto lane and fired backlog

- [x] **S9-T8** · Prove the cache shuts down after the app's own shutdown · P3 · 🤖 Auto · 1-2h ·
  done: an `AppTests` case drives the real simulation thread and proves that the app's releases
  in `simulationShutdown()` land before `ResourceCache::shutdown()` logs what is still counted.
  Only `engine/app/tests/AppTests.cpp` changes. Follows S9-T1. *From a fired Backlog entry.*
- [ ] **S9-T9** · Log the OS error where `FileAccess` returns `IoError` · P3 · 🤖 Auto · 1-2h ·
  done: every `return FileError::IoError` in `engine/platform/src/files/FileAccess.cpp` first logs
  the physical path and, where a `std::error_code` failed, its message, at warn level, as
  `CONVENTIONS.md` § *Error handling* requires of a mapping site. A stream failure with no
  `std::error_code` logs the path and the operation. `NotFound`, `NoMount` and the other codes
  stay silent, because mount probes miss on purpose. Existing tests pass unedited. If diff
  coverage falls under 85% because those paths cannot be reached in a test, the PR body says so
  and uses `[skip-coverage]`. *From a fired Backlog entry.*
- [ ] **S9-T10** · Let the case check see through symlinks below a mount root (D3) · P3 · 🤖 Auto · 2-3h ·
  done: `matchesOnDiskCase` (`engine/platform/src/files/MountTable.cpp:12`) checks the spelling
  one path component at a time with `directory_iterator`, instead of comparing `canonical()`
  results, so it never leaves the logical path ([[Known Issues]] D3's proposed fix, chosen by
  Miguel on Oct 24). Only that function changes. A new `MountTableTests` case creates a
  directory symlink below a mount root and resolves a correctly cased file through it, and a
  wrong-cased path through it is still `NotFound`; it calls `SKIP` where the symlink cannot be
  created (Windows without the privilege). Existing tests pass unedited. D3 is deleted when it
  merges.

### Story G: Prepare Sprint 10 (standing)

- [ ] **S9-P3** · Prep brief for Sprint 10 · P2 · 🤖 Auto · report-only ·
  done: a run report lists the *Decided* rows with no code behind them, the open questions
  blocking them, the fired [[Backlog]] triggers and candidate 🤖 Claude features, and decides
  nothing. **Not before Mon Nov 2**: a fire before that leaves it in To Do.
- [ ] **S9-D5** · Prepare Sprint 10 · P1 · 🟠 Moderate · 2-3h ·
  done: `/sprint-prep` wrote the next sprint's goal and draft cut into this sprint note. Runs in
  week 2, Tue Nov 3 to Fri Nov 6, after S9-P3's brief.

## 🤖 Lanes

- 🤖 Claude features: Story B (S9-T4 to S9-T7), the lane's first, headless under the trial terms
  ([[Planning Workflow - Artifact Gate]] § *The 🤖 Claude gate*). It sits on the goal's critical
  path, and its last three cards wait on Story A.
- 🤖 Auto cards: S9-P1, S9-P2, S9-T8, S9-T9, S9-T10 and S9-T14. None touches a file of Story A,
  Story C or Story B: S9-T9 and S9-T10 stay in `engine/platform`, and S9-T8 in `AppTests.cpp`.
  S9-T14 touches the three visitors and every `visit`, so it must merge before S9-T15 and S9-T17
  start; S9-T12 and S9-T13 also add cases to `AppTests.cpp`, so S9-T8 should merge first.
- Standing prep: S9-P3 (not before Mon Nov 2) and S9-D5 (Tue Nov 3 to Fri Nov 6).
- PR load: eight PR-producing lane cards (four 🤖 Claude, four 🤖 Auto) over two weeks, about
  four a week against a limit of about five. S9-P1, S9-P2 and S9-P3 are report-only and
  free. Review costs about 3-3.5h, which fills both Tuesdays.
- The routine is enabled at 09:07 and 14:07 Lisbon on weekdays with the Oct 23 prompt; its first
  weekday fire is Mon Oct 26 ([[Autonomous Lane - Routine Prompt]]).
  Only 2 papers are left to screen, so morning fires with no card open will soon have no papers.

## Definition of Done

- [x] A `RuntimeAppTests` case over an export proves that the runtime loads the startup scene
  through the cache with its mesh reference acquired, and that releasing the scene leaves nothing
  counted at shutdown (S9-T1, S9-T3, S9-T7). Oct 26, #161 `c509ac3`: *the startup load acquires the mesh the
  startup scene references from the client pack*.
- [x] An `EditorAppTests` case proves that a later launch opens on the saved startup scene through
  the cache (S9-T6). Oct 26, #160 `bff0b6f`: *a later launch opens on the saved startup scene
  through the cache*.
- [ ] Windowed: the editor opens `projects/dev` and exports it, and `runtime.exe` then loads the
  scene and its mesh, and its log names both. M6 is marked closed on the [[Roadmap]].
- [x] The editor brief is written, the editor ADR is Accepted, and `Editor - Design` indexes it.
  Oct 26, vault `9c1caf9`: [[Editor - Brief]] (S9-D1), ADR-027 (S9-D2) and [[Editor - Design]]
  (S9-D3).
- [ ] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro. Touched design notes describe what shipped.

## Capacity note

Miguel chose to work both days of the boundary weekend (Oct 24-25); the Oct 31-Nov 1 weekend
keeps one rest day. That gives about **10 🟢, 2 🟠 and 2 🟡**. The committed cards use 3 🟢, 4 🟠
and 1 🟡: about six 🟢 slots once two 🟠 cards take 🟢 slots. Story D is the stretch for the rest.

- **Sized on Miguel writing his own 🟢 and 🟠 cards**, the split since Oct 23. In Sprint 08,
  Claude wrote much of the file-handling code, which is why those cards closed early; these may
  close slower.
- **Both 🟡 Tuesdays go to reviewing the lane** (about 3-3.5h), so S9-D3 rides a weekend day or a
  Friday.
- **Critical path:** S9-T5 to S9-T7 wait on S9-T1, S9-T2 and S9-T3. Suggested order: S9-T1 and
  S9-T2 this weekend with S9-D1, S9-T3 on Mon Oct 26, S9-D2 on Thu Oct 29 after S9-P1's report,
  S9-D4 on Fri Oct 30, S9-D3 and Story D on the next weekend's deep day, S9-D5 on Thu Nov 5, and
  the windowed run once S9-T7 merges.
- Week 2 of Sprint 08 was hard after a car crash, and this is the third weekend in a row with no
  rest day. If energy dips, Story D and then S9-D4 drop first.
- **Story D is over the remaining capacity, by Miguel's choice (Oct 26).** S9-D3 cut 9 cards:
  3 🟢, 5 🟠 and one 🤖 Auto, about 8 🟢 slots. About 5 🟢 slots are free after S9-D3, S9-D4,
  S9-D5, the weekly review and the windowed run. Miguel kept the whole cut in this sprint because
  M6's code closed on day 3; every card is P2, so the tail drops into Sprint 10 at no cost to the
  goal.

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
