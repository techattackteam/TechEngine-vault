---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Multi-select

- [ ] **S10-T2** · The inspector edits every selected entity · P1 · 🟢 Deep · 4-6h: shared components with a dash for mixed values, one command and one record per entity, a rotation axis edit per entity. Follows S10-T1.
- [ ] **S10-T8** · Edit an `AssetRef` in the inspector · P3 · 🟢 Deep · 4-6h · stretch: a picker over the `AssetIndex`, a set that adds the dependency and fills the handle, and the failed-load policy decided at `/card-start`. Follows S10-T2 and S10-T6.


## Story B: Export · 🤖 Claude



## Story C: Editor panels

- [ ] **S10-D2** · Design the console panel · P2 · 🟠 Moderate · 2-3h: how records reach main, what the panel keeps, its filters; cuts the console's build cards, which follow S10-T4.
- [ ] **S10-D3** · Design the Profiler panel · P3 · 🟠 Moderate · 2-3h: what it shows beside Tracy and where it reads the timings; cuts the Profiler's build cards. Follows S10-D2. First to drop.


## Story D: E1's loose ends

- [ ] **S10-T6** · Local and World modes in the transform inspector · P3 · 🤖 Claude · 2-3h: a toggle shows world values; a World edit goes through `setWorld` on the simulation thread; ends with Miguel's visual check. **Not before Fri Nov 6** (after S10-T2; move the date if S10-T2 slips).
- [ ] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h: the Editor brief's five scenarios run windowed, the exported runtime's log names the edited entities, and E1 is closed on the [[Roadmap]]. Follows S10-T2 and S10-T3.
- [ ] **S10-T9** · The base sweep's two leftovers · P3 · 🟡 Light · 1-2h: the version-anchor stubs go, and one shared log-capture guard in `te_test_support` replaces seven copies. Follows S10-B1 and S10-T3.


## Story E: Alongside: R1's two ADRs

- [ ] **S10-P1** · Paper report for the frame and device seam · P2 · 🤖 Auto · report-only: culling, draw submission and many-lights papers mapped onto the Renderer brief, without choosing.
- [ ] **S10-D4** · The frame and device seam ADR · P1 · 🟢 Deep · 4-6h: `/adr` drafts it, Miguel accepts it, and a new `Renderer - Design` indexes it. Follows S10-P1.
- [ ] **S10-P3** · Paper report for the materials ADR · P2 · 🤖 Auto · report-only: materials and shading papers mapped onto the Renderer brief, without choosing.
- [ ] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h: `/adr` drafts R1's second ADR, Miguel accepts it, and `Renderer - Design` indexes it. Follows S10-P3 and S10-D4.


## Story F: Defects

- [ ] **S10-B1** · `removeLogSink(nullptr)` reports success (D5) · P3 · 🤖 Auto · 1-2h: return `LogError::NullSink` for a null sink, one `LogErrorTests.cpp` case, and D5 deleted.
- [ ] **S10-B2** · Roots keep their order · P2 · 🟠 Moderate · 2-3h: `Scene` keeps a root order, so adding a component or destroying a root no longer moves another, and a save keeps the order.
- [ ] **S10-B3** · A reparent under a rotated, non-uniformly scaled parent is refused · P3 · 🟠 Moderate · 2-3h: amend ADR-021 so a reparent that would need shear keeps the world position with an approximate rotation and scale, as Unity does; a zero scale stays refused. Not at the same time as S10-B2, which also edits `Scene.cpp`.


## Story G: Product follow-up

- [ ] **S10-D5** · Triage what a cinematic showcase needs · P2 · 🟡 Light · 1-2h: `/triage` of camera paths, fixed-rate capture and the rest, recorded in the [[Capability Map]]. Before E2's showcase.


## Story H: Meshes and models before the renderer

- [ ] **S10-D9** · Design TEMesh, TEModel and the glTF loader · P1 · 🟢 Deep · 4-6h: a new `Content Pipeline - Design` decides the mesh and model files, assimp's import and source ids, then cuts the build cards (or drafts an ADR). Follows S10-D8 and S10-D4.


## Story I: Prepare Sprint 11

- [ ] **S10-P2** · Prep brief for Sprint 11 · P2 · 🤖 Auto · report-only: unbuilt *Decided* rows, blocking questions, fired triggers, candidate 🤖 Claude features; decides nothing. **Not before Mon Nov 9.**
- [ ] **S10-D6** · Prepare Sprint 11 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 11's goal and draft cut into the Sprint 10 note. Tue Nov 10 to Fri Nov 13, after S10-P2.


## 🔨 In Progress

- [ ] **S10-T5** · Diff coverage leaves out ImGui drawing · P2 · 🟡 Light · 1-2h: `ci.yml` excludes `apps/editor/src/ui/`, the note says `ui/` is drawing only, and the `te_sdk_smoke` comments are fixed.


## 👀 Review / Demo

- [ ] **S10-T4** · The Run button · P2 · 🤖 Claude · 2-3h: #181, branch `S10-T4/run-button`, opened Nov 3 by the lane, green on Linux (927 of 927, diff coverage 86% locally). **Miguel decides:** the eight *Decisions I took* in the PR, mainly that the editor polls the child once per main-thread update, so an idle editor logs the exit at its next event, and that `Process` reports through `FileError`; and the windowed check (File → Export, then File → Run: the runtime logs the scene, Run is greyed out while it runs, and its exit code is logged). The Windows code was not compiled locally.


## ✅ Done: Sprint 10

- [x] **S10-T3** · File → Export · P1 · 🤖 Claude · 2-3h: #179 `0dcbc1f`, **Nov 2**, by the lane. File → Export sends the client target into `bin/<config>/Dev/` beside a copy of the runtime, a repeat export reuses that folder, and the runtime mounts `assets` beside itself. Unblocks S10-T4 and, with S10-T2, S10-T7; Story B stays open on S10-T4.
	- **No decision was reversed:** #179 merged unchanged with its six *Decisions I took*, now in [[Resources - Design]] § *The export command*. The PR has no review conversation, so this entry, built from the card, the PR and the diff, is the only record.
	- **One `done:` clause was not done:** #174's include order in `PanelsManager.cpp`. The card assumed clang-format would leave the fix alone, but the pinned 19.1.5 moves the header back. It is in the [[Backlog]] as a `.clang-format` question.
	- **Unverified:** no windowed check is recorded (File → Export, then `Dev/runtime` logs the scene), so the sprint's first DoD line stays open. CI was green on every leg, Windows included.
- [x] **S10-D1** · Design the export command · P1 · 🤖 Claude · 1-2h: vault `71288cd`, **Nov 2**, by the lane. [[Resources - Design]] § *The export command* and § *The Run button*: the copy is the runtime executable alone, a repeat export reuses `<project name>/` instead of numbering, File → Export writes to the editor's folder, and Run starts the runtime at that fixed path. S10-T3 and S10-T4 are rewritten to match. Unblocks S10-T3.
	- **One call changes a Decided row** ("it never writes into an existing folder"). The lane took it because Miguel's Oct 31 row handed exactly that question to this card; reverse it in review if the hand-off did not mean that.
	- **Added beside the card:** the export runs on the simulation thread as a command and exports the saved files with a warning for unsaved edits; process launch goes in `platform`. The folder picker went to the [[Backlog]]. No review conversation exists for a vault-only card, so this entry is the only record.

- [x] **S10-T1** · Multi-select in the hierarchy · P1 · 🟠 Moderate · 2-3h: #178 `9afda8d`, **Nov 1**. Ctrl, Shift and Ctrl+A select through ImGui's multi-select, the selection makes the round trip with main's sequence number, and delete and drag act on the topmost selected entities. Unblocks S10-T2; Story A stays open on S10-T2 and S10-T8.
	- **Calls the design left open**, now in [[Editor - Design]] § *Multi-select as built*: a move of several counts its position among the children not moved; an entity the `Scene` refuses is skipped instead of stopping the command; a select with a dead entity still stores its sequence, or main would never take a snapshot's set again; and the active entity comes from the last range request, because ImGui's `NavIdItem` lags one click.
	- **The in-session review caught two partial moves:** a move that failed partway changed the scene without the unsaved marker, and several entities could not be dropped at the root. Both were fixed before the merge. The PR has no review conversation, so this entry is the only record.
	- **Found beside the card:** ADR-021's shear rule refuses a reparent under a parent that is rotated and scaled differently per axis. Carded as S10-B3.
	- **Retro:** `projects/dev/assets/common/Startup.tescene` shipped in #178 holding the windowed test's scene, although the review flagged it. Only part of the windowed check was seen (three rows selected, a move under a parent); Ctrl, Shift and the right-click were not recorded.
- [x] **S10-D8** · Write the content pipeline's capability brief · P1 · 🟠 Moderate · 2-3h: vault `a5ed725`, **Oct 31**. [[Content Pipeline - Brief]] is agreed and linked from [[Capability Map]] § *Content pipeline*: E2 imports glTF, FBX and OBJ, as one merged mesh or as a model that keeps the file's hierarchy, chosen at import; a re-import keeps references and material edits; and the asset browser is list-only. Unblocks S10-D9 with S10-D4. Story H stays open on S10-D9.
	- **A map row reversed, by Miguel's call:** FBX was *Not in the demo*, but Bistro's original release is FBX, so FBX and OBJ became supported inputs through assimp. Other formats stay unpromised.
	- **Found beside the card:** [[Resources - Design]] § *Reference fields* says R1's renderer ADR owns the mesh format, while S10-D9 gives it to `Content Pipeline - Design`. S10-D9 settles which; it was reported, not fixed. The brief's re-import Must is the requirement behind that note's sidecar-or-registry question.
	- **Left for Miguel:** OBJ has no TechAttack need yet (P1), and re-import, import settings and the browser cannot be shown in a cinematic (P4).




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%