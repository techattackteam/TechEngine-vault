# 2026-10 · Sprint 09: Close M6

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Oct 24 - Friday Nov 6, 2026.
- **Epic:** M6 · content, closed; E1 · Editor and export, opened with its decisions
  ([[Roadmap]]). Hubs: [[Resources - Design]], and the editor's note once S9-D3 writes it.

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
- [ ] **S9-T2** · Reference fields and the reference walk · P1 · 🟢 Deep · 4-6h ·
  done: a component with `visit` can hold `Entity` and `AssetRef<T>` fields (ADR-026 §2). One
  reference visitor over `visit` sees only those two types. `SceneAsset::write` saves an `Entity`
  as its target's row and an `AssetRef<T>` as its id, and `SceneAsset::read` maps rows back to
  entities in a second pass after the last row. A round-trip test with a test component proves
  both, including a reference to a later row and empty fields.
- [ ] **S9-T3** · The loaded scene acquires its references · P1 · 🟠 Moderate · 2-3h ·
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
- [ ] **S9-T5** · The editor writes a mesh and a component that references it · P1 · 🤖 Claude · 2-3h ·
  done: the editor writes the triangle as a mesh asset in code, the way it writes the startup
  scene, through one asset-creation call that `writeStartupScene` also uses, and the `TODO` on
  `writeStartupScene` (`apps/editor/src/EditorApp.cpp:79`) goes. A component with an
  `AssetRef<Mesh>` field, registered in the editor, sits on an entity of a newly created startup
  scene and is saved with it. It holds only the mesh reference, and its name must not decide how
  R1 splits the mesh from its material. Follows S9-T2 and S9-T4. *From a fired Backlog entry.*
- [ ] **S9-T6** · The editor reads its startup scene through the cache · P2 · 🤖 Claude · 2-3h ·
  done: when the project names a startup scene, `EditorApp::simulationStartupLoad()` registers the
  scene and mesh loaders and calls S9-T1's function with `LooseSource` as the cache's source, so a
  later launch opens on the saved scene instead of an empty one. The `TODO` at
  `apps/editor/src/EditorApp.cpp:45` goes. Follows S9-T1, S9-T3 and S9-T5.
- [ ] **S9-T7** · The bake packs what the startup scene reaches · P1 · 🤖 Claude · 2-3h ·
  done: `Project::exportTo` walks the startup scene's references and packs each reached asset into
  its side's pack when the target ships that side, instead of the scene alone. The runtime
  registers the mesh loader and S9-T5's component, and a `RuntimeAppTests` case over an export
  proves the runtime loads the mesh. What an id the index does not know does to the export is
  Claude's call. Follows S9-T2, S9-T3 and S9-T5. Miguel's windowed run then closes M6's
  Definition of Done.

### Story C: E1's opening decisions (Miguel)

Cut against [[Capability Map]] § *Editor*, [[2026-Q4]] objective 2 and [[Window - Design]] §
*Open questions*.

- [ ] **S9-D1** · Write the editor's capability brief · P1 · 🟠 Moderate · 2-3h ·
  done: `/brief editor` writes `01 Product/Capabilities/Editor - Brief.md`, linked from the map's
  § *Editor*. Miguel decides every line; Claude interviews. It says whether E1 includes a project
  launcher, reopening the last scene, and any Play state, because three [[Backlog]] entries
  trigger on the first editor UI card and the launcher is not on the map yet.
- [ ] **S9-P1** · Research brief for the editor ADR · P2 · 🤖 Auto · 2-3h ·
  done: a report compares how Unity, Unreal and Godot run editor UI beside the simulation and
  render threads, and how ImGui-based editors hand draw data to a render thread that owns GL. It
  names its sources, marks what is from memory, and maps each answer onto ADR-018's threads and
  [[Window - Design]] § *The frame command buffer* without choosing. Report-only, best done in week 1.
- [ ] **S9-D2** · Decide the editor's architecture · P1 · 🟢 Deep · 4-6h ·
  done: `/adr` drafts the editor ADR from the brief and S9-P1's report, with the Unity and Unreal
  baseline. It decides whether ImGui shares the window and which thread draws it (ADR-015 §
  *Consequences*), how panels read the `Scene` (published copies or main's fence, ADR-024 §6), how
  an edit reaches the simulation thread, and what the stopped state is ([[Resources - Design]] §
  *Open questions*). Miguel accepts it. Follows S9-D1 and S9-P1.
- [ ] **S9-D3** · Write the editor's design note and cut the first T1 cards · P1 · 🟡 Light · 1-2h ·
  done: a new `Editor - Design` note holds the ADR's mechanism and indexes it in its *Decided*
  rows, and the first T1 panel cards are cut against it into Story D, each with a `done:` clause
  and a size. Follows S9-D2.

### Story D: E1's first panels · ~4-6 tasks · size after S9-D2 · stretch

T1's dock, hierarchy and inspector ([[Roadmap]] § *Rung catalogue*). S9-D3 cuts them; any that
start this sprint are P2, so dropping them never costs the goal.

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

- [ ] **S9-T8** · Prove the cache shuts down after the app's own shutdown · P3 · 🤖 Auto · 1-2h ·
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
- 🤖 Auto cards: S9-P1, S9-P2, S9-T8, S9-T9 and S9-T10. None touches a file of Story A, Story C
  or Story B: S9-T9 and S9-T10 stay in `engine/platform`, and S9-T8 in `AppTests.cpp`.
- Standing prep: S9-P3 (not before Mon Nov 2) and S9-D5 (Tue Nov 3 to Fri Nov 6).
- PR load: seven PR-producing lane cards (four 🤖 Claude, three 🤖 Auto) over two weeks, about
  three or four a week against a limit of about five. S9-P1, S9-P2 and S9-P3 are report-only and
  free. Review costs about 3-3.5h, which fills both Tuesdays.
- The routine is enabled on `7 9,14 * * 1-5` with the Oct 23 prompt; its first fire is Mon Oct 26.
  Only 2 papers are left to screen, so morning fires with no card open will soon have no papers.

## Definition of Done

- [ ] A `RuntimeAppTests` case over an export proves that the runtime loads the startup scene
  through the cache with its mesh reference acquired, and that releasing the scene leaves nothing
  counted at shutdown (S9-T1, S9-T3, S9-T7).
- [ ] An `EditorAppTests` case proves that a later launch opens on the saved startup scene through
  the cache (S9-T6).
- [ ] Windowed: the editor opens `projects/dev` and exports it, and `runtime.exe` then loads the
  scene and its mesh, and its log names both. M6 is marked closed on the [[Roadmap]].
- [ ] The editor brief is written, the editor ADR is Accepted, and `Editor - Design` indexes it.
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

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
