---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Multi-select

- [ ] **S10-T8** · Edit an `AssetRef` in the inspector · P3 · 🟢 Deep · 4-6h · stretch: a picker over the `AssetIndex`, a set that adds the dependency and fills the handle, and the failed-load policy decided at `/card-start`. Follows S10-T2 and S10-T6.


## Story B: Export · 🤖 Claude



## Story C: Editor panels

- [ ] **S10-T12** · The console panel · P2 · 🟠 Moderate · 2-3h: a store of 5,000 records, level toggles with counts, text search, Clear, docked below the views. Follows S10-T11.


## Story D: E1's loose ends

- [ ] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h: the Editor brief's five scenarios run windowed, the exported runtime's log names the edited entities, and E1 is closed on the [[Roadmap]]. Follows S10-T2 and S10-T3.
- [ ] **S10-T9** · The base sweep's leftover · P3 · 🟡 Light · 1-2h: the version-anchor stubs go. The shared log-capture guard moved to S10-T10. Follows S10-T10.


## Story E: Alongside: R1's two ADRs

- [ ] **S10-D4** · The frame and device seam ADR · P1 · 🟢 Deep · 4-6h: `/adr` drafts it, Miguel accepts it, and a new `Renderer - Design` indexes it. Follows S10-P1.
- [ ] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h: `/adr` drafts R1's second ADR, Miguel accepts it, and `Renderer - Design` indexes it. Follows S10-P3 and S10-D4.


## Story F: Defects

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



## 👀 Review / Demo

- [ ] **S10-T6** · Local and World modes in the transform inspector · P3 · 🤖 Claude · 2-3h: #188 on `S10-T6/local-world-modes`, opened Nov 6 by the lane. Linux debug green (967 of 967). **Needs Miguel's visual check** of the toggle (World drags on a child of a moved, rotated parent) and a yes or no on the seven *Decisions I took* in the PR body.


## ✅ Done: Sprint 10

- [x] **S10-T11** · The console's sink · P2 · 🟠 Moderate · 2-3h: #187 `db72fe6`, **Nov 5**. `ConsoleLog` keeps each record as a `StoredLogRecord` in a queue of 1,024 that main drains each frame, and a Warn or worse from another thread wakes main once. Unblocks S10-T12; Story C stays open on it.
	- **Widened at review:** the scaffold's own `ConsoleRecord` repeated the test guard's `CapturedLog`, so both became `StoredLogRecord` in `base`. `ringSnapshot` now fills it, which fixed [[Known Issues]] D7 in the same PR, and its `capacity` argument went. [[Logger - Design]] § *Sinks* records both.
	- **Calls against [[Editor - Design]] § *The console*:** main is the thread that calls `start()`; `drain` returns the dropped count but adds no "N records dropped" line, which S10-T12's store now owes; the console stops before `stopImGui()`, because `Client::stop` holds its wake lock while GLFW may log an error.
	- **Retro: the first build queued `LogRecord`s and never marked the sink registered,** so messages dangled and a destroyed console stayed in the sink table. The card's tests crashed on both, and EditorAppTests' two-launch case caught the second.
	- **Retro: the branch was first cut from S10-T10's merged branch.** `/card-start`'s gate caught it and the branch was recut from `origin/master`; the empty #186 it had produced was closed.
- [x] **S10-T10** · Log sinks are objects, and removal waits · P2 · 🟠 Moderate · 2-3h: #183 `823067d`, **Nov 4**. A sink is a `LogSink` object, `removeLogSink` now waits for a sink that is still running, and a record logged inside a `write` goes to the ring and stderr. [[Known Issues]] D5 went with `NullSink`. Unblocks S10-T11 and S10-T9; Story C stays open on S10-T11 and S10-T12.
	- **"The seven copies" were nine:** S10-T9's list missed `EditorCommandsTests.cpp`'s identical copy and `AppTests.cpp`'s `AppWarningCapture`, which kept only Warn records. The shared guard replaced all nine. Its shape (a minimum level, full records under its own lock) was decided at `/card-start`, and S10-T11 has since widened its record into `StoredLogRecord`.
	- **Retro: TSan found a race the brief had waved through.** The threaded sink tests made the TSan leg report the ring's slot race, which `Log.cpp` had accepted as a best-effort crash trail. `/card-start` guessed the delivery lock would hide it, but `ringWrite` runs before that lock. The ring now has its own mutex (`e552bd1`), recorded in [[Logger - Design]] § *Sink registration and delivery*. Its snapshot still hands out messages a later log can overwrite: D7.
	- **Retro: the scaffold stubbed the shared guard,** so every migrated suite failed at once (36 cases) and hid which of the card's own tests were red.
	- **Unmeasured:** the cost of the delivery lock and of the new ring lock.
- [x] **S10-P3** · Paper report for the materials ADR · P2 · 🤖 Auto · report-only: vault `7bfdda8`, **Nov 4**, by the lane. [[Renderer - Materials Paper Report]] maps the seven validated materials papers (Walter 2007, Burley 2012, Karis 2013, Lagarde 2014, Heitz 2014, Kulla and Conty 2017, Substrate 2023) onto the brief's standard material, its five shading models, cut-outs, the sky image and correct brightness, without choosing, and lists what S10-D7 must decide. Unblocks S10-D7 with S10-D4. Story E stays open on S10-D4 and S10-D7.
	- **Weaker than the card assumed, as S10-P1 was:** no paper could be opened, because every host and mirror is outside the network allowlist. Unlike S10-P1, two primary implementations were reachable on GitHub and read in full: Filament's PBR document and the glTF material specs, which cite six and five of the papers. Claims rest on those, so they report how an engine used each paper, not the paper itself. Substrate rests on search extracts only.
- [x] **S10-D3** · Design the Profiler panel · P3 · 🟠 Moderate · 2-3h: vault `cb2836a`, **Nov 3**. [[Editor - Design]] § *The Profiler panel*: it graphs recorded Play sessions, one file per run under `editorSettings/profiler/`, kept until deleted, and ADR-013 §3 now takes the native route. Story C's planning is done; the story stays open on S10-T10 to S10-T12.
	- **It cut no build cards, against the card's "cuts the Profiler's build cards":** in E1 the editor never ticks, so the simulation's metrics read zero, the title already shows FPS, and the copied metrics keep only the latest sample. The build waits for Play (E11) in the [[Backlog]].
	- **A live panel was dropped:** redrawing it while idle would need main to build frames on its own, against ADR-027 §1. Showing recorded runs after Stop avoids that.
	- **Miguel widened the scope as product owner:** runs are stored and selectable so a run from before a change can be compared with one after it. It went into [[Editor - Brief]] as "Should, with Play" without a `/triage`, since the brief already held the panel.
	- **Unmeasured:** the 4 MB size of a ten-minute run is an estimate.
- [x] **S10-D2** · Design the console panel · P2 · 🟠 Moderate · 2-3h: vault `372e249`, **Nov 3**. [[Editor - Design]] § *The console* and § *The console panel*: an editor-owned sink feeds a bounded queue that main drains each frame, a Warn or worse from another thread wakes main, and the panel keeps 5,000 records with level and text filters. Cut S10-T10 to S10-T12, which size Story C's console half; Story C stays open on them and S10-D3.
	- **The card's premise did not hold:** a sink could hold no state, and could still be running after `removeLogSink` returned (`Log.cpp:150-171`, `303-313` at `a6c832f`). The first proposal, a static buffer in the editor, was dropped in discussion as a workaround. The fix went into `base` instead, as S10-T10 ([[Logger - Design]] § *Sink registration and delivery*), and ADR-011 §3 and §7 were amended.
	- **"Its filters" had half a referent:** no module registers a channel, so every record is `default/default`. The console filters by level and text, and the channel filter waits.
	- **Scope moved:** S10-B1 was folded into S10-T10 and taken off the lane, and S10-T9's shared log-capture guard moved there too. So the console costs three 🟠 cards, not two.
	- **Unmeasured:** the cost of the new delivery lock. A Tracy capture with the task workers logging would show it.
- [x] **S10-T2** · The inspector edits every selected entity · P1 · 🟢 Deep · 4-6h: #182 `a6c832f`, **Nov 3**. The inspector lists the components every selected entity has with a dash for mixed values, and set field, add, remove, rename and a rotation axis edit are each one command with one record per entity. Miguel's windowed check saw three entities show dashes and one position edit move all three. Completes the hierarchy-and-inspector DoD row and unblocks S10-T6 and S10-T7; Story A stays open on the stretch S10-T8.
	- **Calls the design left open**, decided with Miguel at `/card-start` and now in [[Editor - Design]] § *Multi-select in the inspector, as built*: the active entity takes the panel's cached quaternion instead of being decomposed, so a single selection uses the same command and leaves one `RotationEditRecord` (half of the [[Backlog]]'s "four records" entry); and an Euler axis is mixed from 0.005° apart, compared modulo 360.
	- **The in-session review caught a regression:** the rotation command wrote through `setLocal`, which refuses a zero scale that a field edit allows, so such an entity could no longer rotate and the panel's Euler display stopped following it. It now writes through the field walk. Before that, Miguel's first test run had 10 failures: three commands changed the scene without a record or the revision, and `hasMixedNames` treated an empty name as "none yet". The PR has no review conversation, so this entry is the only record.
	- **Retro:** `Startup.tescene` shipped with the windowed test's scene for the second card running (#178, #182), although the review flagged it both times.
- [x] **S10-P1** · Paper report for the frame and device seam · P2 · 🤖 Auto · report-only: vault, **Nov 3**, by the lane. [[Renderer - Seam Paper Report]] maps the four validated culling, draw-submission and many-lights papers (Olsson 2012, Haar and Aaltonen 2015, Wihlidal 2016, Nanite 2021) onto T1, T2 and Q1, and lists what each asks of the seam in GL 4.5, without choosing. Unblocks S10-D4.
	- **Weaker than the card assumed:** the sandbox could not open any of the four papers, because their hosts are outside the session's network allowlist, so the report rests on search extracts and memory, each claim tagged. Check a number in the paper before the ADR relies on it.
- [x] **S10-T4** · The Run button · P2 · 🤖 Claude · 2-3h: #181 `78c48ab`, **Nov 3**, by the lane. File → Run exports, then starts the exported runtime through `platform`'s new `Process`, and logs its exit code. Completes Story B; Story C's panel cards may now touch `EditorApp.cpp` and `PanelsManager.cpp`.
	- **Miguel reversed one decision in review:** Run exports first instead of being enabled when an exported runtime exists, so the lane's flag set by `ExportCommand` became a callback on `ExportCommand`, and the card's "enabled when that file exists, checked at startup" clause no longer holds. The other seven decisions merged as written, now in [[Resources - Design]] § *The Run button*.
	- The PR has no review conversation; the reversal lives only in its second commit and its edited body, so this entry is the only other record.
	- **Unverified:** no windowed check of Run is recorded. CI was green on every leg, Windows and the sanitizers included, which is the first time the Windows `Process` code compiled.
- [x] **S10-T5** · Diff coverage leaves out ImGui drawing · P2 · 🟡 Light · 1-2h: #180 `f4ece35`, **Nov 2**. diff-cover skips `apps/editor/src/ui/`, the smoke comments name `TechEngineSDKSmoke`, and [[Editor - Design]]'s row "`ui/` draws, `edit/` decides" is the rule's one home. S10-T2's inspector drawing no longer needs `[skip-coverage]`; Story D stays open on S10-T6, S10-T7 and S10-T9.
	- **One `done:` clause had no referent:** `ci.yml` has no exclude list. The exclusion went into `cmake/coverage_report.cmake`, beside the `tests/` filter that CI and a local run share.
	- **"`ui/` holds drawing only" was not true:** `ImGuiBridge` holds the three-slot swap between main and render, which the gate no longer scores. The row says "drawing and the plumbing around it" instead.
	- **Not yet proven:** this PR changed no `ui/` file, and diff-cover's path matching was not checked locally, so S10-T2 is the first PR to exercise the exclusion. The PR has no review conversation, so this entry is the only record.
- [x] **S10-T3** · File → Export · P1 · 🤖 Claude · 2-3h: #179 `0dcbc1f`, **Nov 2**, by the lane. File → Export queues an export command on the simulation thread, a repeat export reuses `bin/<config>/Dev/`, and the runtime copied there reads `assets` beside itself. Miguel's windowed check saw it log the scene. Unblocked S10-T4, and S10-T7 with S10-T2.
	- **One `done:` clause could not be met:** #174's include order in `PanelsManager.cpp`. The pinned clang-format 19.1.5 moves the paired header back into the private group, so the format gate fails. It is a `.clang-format` or `CONVENTIONS.md` call, kept in the [[Backlog]].
	- **All six *Decisions I took* were accepted, none reversed.** One lands against [[Editor - Design]]'s "Panels send through one sender" row: Export is a callback that `EditorApp` gives `PanelsManager`, because `EditorCommands` holds neither the project nor a mutable registry. The note now records the exception, and S10-T4's Run took the same route.
	- **Not checked by any test or CI leg:** the Windows file lock on a running `runtime.exe`, which the design relies on to fail an export before any pack changes. The PR has no review conversation, so this entry is the only record.
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