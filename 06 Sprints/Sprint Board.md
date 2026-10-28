---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: M6's scene and its references



## Story B: The mesh path · 🤖 Claude



## Story C: E1's opening decisions



## Story D: E1's first panels · stretch

- [ ] **S9-T16** · The published view and the hierarchy panel · P2 · 🟢 Deep · 4-6h: create, delete, reparent and select as commands, drawn from the published view. Follows S9-T11, S9-T13 and S9-T15.
- [ ] **S9-T17** · The inspector · P2 · 🟢 Deep · 4-6h: the field visitor and field rows; edit fields, rename, add and remove components. Follows S9-T14 and S9-T16.
- [ ] **S9-T18** · Save, the unsaved marker and the prompt on close · P2 · 🟠 Moderate · 2-3h: save as a command, the title marker, Save, Discard or Cancel on close. Follows S9-T16.
- [ ] **S9-T19** · The dock, a placeholder scene view and the remembered layout · P2 · 🟠 Moderate · 2-3h: `editorSettings/layout.ini` through `FileAccess`, git-ignored. Follows S9-T11.


## Story E: Alongside: the renderer brief

- [ ] **S9-D4** · Write the renderer's capability brief · P2 · 🟠 Moderate · 2-3h: `/brief renderer`; one renderer ADR or several.
- [ ] **S9-P2** · Research brief for the renderer ADR · P3 · 🤖 Auto · 2-3h: Filament, Godot 4, URP and Unreal against the brief, mapped onto ADR-005's device seam without choosing. Report-only. Follows S9-D4.


## Story F: Auto lane and fired backlog



## Story G: Prepare Sprint 10

- [ ] **S9-P3** · Prep brief for Sprint 10 · P2 · 🤖 Auto · report-only: unbuilt *Decided* rows, blocking questions, fired triggers, candidate 🤖 Claude features; decides nothing. **Not before Mon Nov 2.**
- [ ] **S9-D5** · Prepare Sprint 10 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 10's goal and draft cut into the Sprint 09 note. Tue Nov 3 to Fri Nov 6, after S9-P3.


## 🔨 In Progress



## 👀 Review / Demo

- [ ] **S9-T10** · Let the case check see through symlinks below a mount root (D3) · P3 · 🤖 Auto · 2-3h: PR #169, branch `S9-T10/case-check-symlinks`, opened by the lane on Oct 28. `matchesOnDiskCase` walks the path one component at a time against each directory's listing, and a new `MountTableTests` case resolves a file through a directory symlink. Miguel's to review and merge. D3 is deleted at the close.


## ✅ Done: Sprint 09

- [x] **S9-T9** · Log the OS error where `FileAccess` returns `IoError` · P3 · 🤖 Auto · 1-2h: #168 `85ca195`, **Oct 28**. All 19 `IoError` returns in `FileAccess.cpp` log at warn first: the physical path and the `std::error_code` message for filesystem calls, and the path and the operation for stream failures; every other code stays silent ([[File Access - Design]] § *Resolution*). #168 has no review conversation and merged as the lane pushed it, so this entry comes from the card, the PR body and the diff. Story F stays open on S9-T10.
	- **A clause with no test behind it:** the failure paths cannot be reached in the suite, so nothing proves a line is written, and the PR used `[skip-coverage]` as the card allowed.
- [x] **S9-T15** · Every entity has a name · P2 · 🟠 Moderate · 2-3h: #167 `9a33c49`, **Oct 27**. Every new entity carries a `Name` called `Entity`, saved with the scene, and the runtime's scene log prints it beside the index ([[Editor - Design]] § *Entity names*). #167 has no body and no review conversation, so this entry comes from the card, the diff and the session. Unblocks S9-T16, whose last predecessor it was, and the rename in S9-T17; Story D stays open.
	- **"`App` registers it" was only half the clause:** registering does not create the component. `Name` joined the built-in set that `ArchetypeStorage::createEntity` gives every entity, so every registry that creates an entity must now register it, which touched six test files and the shared test helper.
	- **Decided in the card:** `Scene` refuses to add or remove `Name`, as it does `Transform`, because the brief's Must is that every entity has a name. S9-T17's inspector therefore leaves `Name` out of add and remove.
	- **Wider than the card:** `removeComponent(PendingEntity)` did not refuse `Transform`, so a pending spawn could lose its `Transform` before `propagateTransforms` read it. Fixed here, and `TransformTests` now checks all four guards at compile time.
	- **Retro:** Miguel: "this one should have been a really light one". The logic was three one-line changes; the rest was mechanical edits to registries and tests, so the card was 🟡 Light, not 🟠 Moderate.
- [x] **S9-T13** · The editor's simulation idles while Stopped · P2 · 🟠 Moderate · 2-3h: #166 `db2adac`, **Oct 27**. An App whose `simulationTicks()` is false waits for a command or stop with no deadline. In both loops, an applied batch runs a loading phase and then the new `publishEdits()` hook ([[Editor - Design]] § *Commands and the idle simulation*). #166 has no body and no review conversation, so this entry comes from the card, the diff and the session. Unblocks S9-T16 together with S9-T15; Story D stays open.
	- **Four calls no artifact made, settled at `/card-start`:** `simulationTicks()` is a virtual hook read once after the startup load. Edits publish through their own hook, because render drops a snapshot whose tick did not advance. A failed load inside a batch logs a warning and the app keeps running. The windowed stall proof was split: the editor case now proves that render keeps drawing while the simulation stays idle, and the tick-and-input half moved to `RuntimeAppTests`.
	- **Caught before merge** *(retro line)*: a first draft returned from `threadMain` for an idle app, which skips the shutdown hooks and stops the editor at once. `/card-review` then found that the batch skipped the loading phase and that every applied batch logged a warning. All three were fixed before the PR.
- [x] **S9-T8** · Prove the cache shuts down after the app's own shutdown · P3 · 🤖 Auto · 1-2h: #165 `b10f67b`, **Oct 27**. One `AppTests` case over the real simulation thread pins that `ResourceCache::shutdown()` runs after `simulationShutdown()` and sees its releases ([[Resources - Design]] § *Loads on the job system, as built*). #165 has no review conversation and merged as the lane pushed it, so this entry comes from the card, the PR body and the diff. Story F stays open on S9-T9 and S9-T10.
	- **Wider than the clause:** the case has a second section, an app that keeps its resource, as the control: the cache logs it once during `run()` and never before `simulationShutdown()` began, so the released section's empty log cannot pass by accident. It uses a test-only resource rather than the scene, because `AppTests` has no scene loader.
- [x] **S9-T14** · Every `visit` field carries a name · P2 · 🤖 Auto · 1-2h: #164 `a97890c`, **Oct 27**. `Writer`, `Reader` and `ReferenceVisitor` take `field(name, value)` and ignore the name, and every `visit` names its fields ([[Serialization - Design]] § *How `visit` binds*). #164 has no review conversation and merged as the lane pushed it, so this entry comes from the card, the PR body and the diff. Unblocks S9-T15 and, with S9-T16, S9-T17; Story D stays open.
	- **The clause kept the nameless `field(value)`:** `ComponentRegistry` and the tests call it at the root, outside any `visit`, and the card allowed editing only `visit` bodies. So a `visit` that forgets a name still compiles; S9-T17's field visitor can refuse it by having no nameless overload ([[Editor - Design]] § *Fields*).
- [x] **S9-T12** · Edit command admission · P2 · 🟠 Moderate · 2-3h: #163 `3165f73`, **Oct 26**. `App::submitCommand` admits a `Command` into a bounded `CommandQueue`, wakes the simulation thread, and the loop applies the batch at the top of each pass ([[Editor - Design]] § *Commands and the idle simulation*). #163 has no body and no review conversation, so this entry comes from the card, the diff and the session. Unblocks S9-T13; Story D stays open.
	- **The clause's premise was wrong:** "a ticking app applies the batch before each fixed tick" would never apply an edit in the Stopped editor, which does not tick. Miguel chose to apply commands whenever the thread wakes, never inside a tick, and S9-T12, S9-T13 and the note were rewritten before any logic. No artifact said what "reported as cancelled" means either; it is one warning with the count.
	- **Decided in the card:** the queue is open only while the simulation thread runs, so a submit before the run or after stop is rejected. Asked during the card whether the queue belongs in the editor, Miguel kept it in `app`, because ADR-018 §2 sends the server's console commands the same way.
	- **Review caught before merge:** a failed startup load left the queue open after the cancel, so a late submit would have been applied by the next run; the queue's own `std::errc` codes; a null command that would crash the simulation thread; `applyCommands` under the wait mutex, which blocked main's submit; and a "Cancelled 0 commands" warning after every run.
	- **Retro:** that warning looked like a race, because test names with a comma split into two filters when CLion reruns one test by name, so the test sometimes did not run at all. 59 test names on `master` have a comma ([[Backlog]] → cross-cutting). Claude's first reason for reopening the queue on each run, that an existing test would break, was also wrong.
- [x] **S9-T11** · ImGui draws in the editor's window · P2 · 🟢 Deep · 4-6h: #162 `6df5fa6`, **Oct 26**. `client` calls an `ImGuiHook` on the render thread, and the editor's `ImGuiBridge` carries main's frame across in three snapshots beside ImGui's texture queue ([[Editor - Design]] § *The ImGui hook*). Miguel reports that the demo window draws and the tests pass. #162 has no review conversation, so the findings below come from the session. Unblocks S9-T19, and S9-T16 with S9-T13 and S9-T15; Story D stays open.
	- **A clause without a referent:** "ImGui's docking branch, pinned" named one dependency, but `ImDrawDataSnapshot` and `ImTextureQueue` live in `imgui_club`, so it is a second pin.
	- **Against the note as written:** the note created the ImGui context after `startClient()`, but the hook's start initializes `imgui_impl_opengl3` inside that call, so the context now comes first (vault `7fc21ef`). Miguel renamed the "overlay seam" to `ImGuiHook`, and `draw()` lost a framebuffer size the backend never read.
	- **Decided in the card:** the shutdown order and `ClientApp::stopClient()`, because `~EditorApp` runs while the client still draws the bridge. It is now a *Decided* row.
	- **Review caught before merge:** a null hook crashed the runtime, `stopImGui()` asserted on every normal exit, `publish` rotated the slot render was drawing, and `beginFrame` and the extra wake were missing. Left open, not a defect: a focused text field keeps main busy, which the note gives to S9-T17's `/card-start`.
	- **Retro:** Claude committed a vault change without being asked (`7fc21ef`). The scaffold also left out the texture queue's `UpdateTexFunc`, which asserted on the first run, and its test hook waited on a non-`mutable` condition variable in a `const` function, which a `const_cast` now patches.
- [x] **S9-D3** · Write the editor's design note and cut the first T1 cards · P1 · 🟡 Light · 1-2h: vault `9c1caf9`, **Oct 26**. [[Editor - Design]] indexes ADR-027 and holds its mechanism, and Story D is cut as S9-T11 to S9-T19, all P2. Completes Story C and unblocks Story D.
	- **The clause's premise was wrong:** the first cards are plumbing, not panels. ImGui's channel, the command admission and the idle simulation come before any panel can exist.
	- **No artifact decided four things:** who issues ImGui's GL (Miguel chose a callback overlay with `imgui_impl_opengl3` over a draw list owned by `client`), field names for the inspector (`visit` had none), entity names (none existed, so `/triage` made them an E1 Must), and whether save is T1's or T2's (the Roadmap listed it in both; it is T1's).
	- **Wider than the clause:** the whole of T1 was cut, not its first cards. Miguel kept all nine in this sprint, about 3 🟢 slots over the remaining capacity, because M6's code closed on day 3.
	- **Retro:** while grounding, Claude claimed that no artifact decides persistent entity identity. ADR-007 §1 does: a scene row on disk and an opt-in UUID. Miguel's challenge caught it. The 🟡 1-2h card also ran as a long session with a triage fork.
- [x] **S9-T7** · The bake packs what the startup scene reaches · P1 · 🤖 Claude · 2-3h: #161 `c509ac3`, **Oct 26**. `exportTo` reads the startup scene's file with the editor's registry, collects its ids with `SceneAsset::collectReferences`, and packs each reached asset into its side's pack. The runtime registers `MeshRenderer` and the mesh loader ([[Resources - Design]] § *Export and the runtime layout*, *The bake as built*). #161 has no review conversation, so this entry comes from the card, the PR body, the diff and the session. Miguel merged its seven *Decisions I took* unchanged, so nothing was reversed. Completes Story B; the windowed run is left to close M6.
	- **Wider than the card:** the new runtime test found that `App::simulationShutdown()` released the scene without draining frees, so the shutdown log reported every reference of a loaded scene as a leak. The fix shipped as its own commit.
	- **A test fixture had to change:** the export's tests wrote placeholder scene bytes, and an export that parses the scene rejects those, so the `ExportScratch` fixture now writes real scenes. No assertion changed.
	- **Raised during the close, filed not built:** Miguel's wanted behaviour for deleting an asset in the editor went to the [[Backlog]] at `#prio/xhigh`. It would change the Decided row that a missing reference fails the scene load.
	- **Retro:** opening the PR failed twice with an HTTP 500 from GitHub before the third try worked.
- [x] **S9-T6** · The editor reads its startup scene through the cache · P2 · 🤖 Claude · 2-3h: #160 `bff0b6f`, **Oct 26**. A later launch now loads the named startup scene with `SceneAsset::load` over the editor's `LooseSource`, so it opens on the saved scene with its mesh acquired ([[Resources - Design]] § *Reference fields*, *The editor's load as built*). #160 has no review conversation, so this entry comes from the card, the PR body, the diff and the session. Miguel merged its three *Decisions I took* unchanged, so nothing was reversed. Unblocks nothing; Story B stays open on S9-T7.
	- **Questions in review, no code change:** Miguel checked that `LooseSource` serves only runtime-form files, with PNG and glTF left to T4's importers (ADR-025 §5 and §6), and asked what `setSource` does. The note now says both.
	- **Taken out of priority order:** S9-T7 is P1 and S9-T6 is P2, but the lane takes a 🤖 Claude story in the sprint note's order.
- [x] **S9-D2** · Decide the editor's architecture · P1 · 🟢 Deep · 4-6h: vault `ba93e26`, **Oct 25**. [[ADR-027 - Editor threads, edit commands and play sessions]] is Accepted: main builds the ImGui frame and render draws it, panels read a published view, every edit is a command, and Play ticks a copy that Stop discards. Unblocks S9-D3; Story C stays open.
	- **The clause's premise was wrong:** it framed "how panels read the `Scene`" as published copies or main's fence under ADR-024 §6, but §6 governs cache entries. ADR-018 §2 already rules out main reading the live `Scene`, so only the copy was open.
	- **Wider than the clause:** Miguel had Play and Stop decided now rather than at E11, to avoid a rewrite. He chose to play a parked original's copy (Unreal's shape) over Claude's save-and-restore pick, and named the layout folder `editorSettings/`.
	- **Written, then dropped while drafting:** a hand-written platform backend over `Window` (ImGui's GLFW backend already manages viewports), an editor-only lib (ADR-006 §1 already gives ImGui to the editor executable), and a scene field on every command (unneeded once the original is parked).
	- **No code behind Q3 and Q4:** the edit command admission and the idle simulation state are designed but unbuilt, so T1 builds both and Story D's size must include them.
	- **Retro:** planned for Thu Oct 29, run on Sunday as the day's third card on the third weekend without a rest day. The ADR is 146 lines, over the usual 120, because it holds six decisions.
- [x] **S9-P1** · Research brief for the editor ADR · P2 · 🤖 Auto · 2-3h: vault `3f5a227`, **Oct 25**. [[Editor - Research Brief]] compares Unity, Unreal and Godot, and ImGui over a render thread, and maps each finding onto ADR-018, [[Window - Design]] § *The frame command buffer*, [[Editor - Brief]] and S9-D2's four questions without choosing. Run by hand on a Sunday so that the report is in before S9-D2. Unblocks S9-D2; Story C stays open.
	- **Against the clause's premise:** none of the three engines puts its editor UI and the edited world on different threads in edit mode, so none answers S9-D2's "how panels read the `Scene`" directly. Godot's editor even forces rendering onto its main thread.
	- **Wider than the clause:** since ImGui 1.92, a render thread needs texture requests staged beside the draw data, and those must not be skipped the way the newest-wins slot skips snapshots. `imgui_impl_glfw` also calls GLFW directly, against [[Window - Design]]'s "GLFW stays inside `platform`" row.
	- **Retro:** Unity's, Epic's and Godot's documentation sites were unreachable from the sandbox, so the Unity and Unreal rows rest on search extracts of their official pages, and the brief marks each claim from memory.
- [x] **S9-D1** · Write the editor's capability brief · P1 · 🟠 Moderate · 2-3h: vault `c1502b1`, **Oct 25**. [[Editor - Brief]], the first capability brief, is agreed and linked from [[Capability Map]] § *Editor*. E1 has one project and one scene, runs stopped only, keeps Play alongside E11, and brings the launcher back with T5. Unblocks S9-D2 with S9-P1's report; Story C stays open.
	- **The clause's premise was wrong:** only the launcher's [[Backlog]] entry triggered on the first editor UI card. Reopen-last triggers when the editor can open another scene, and the session-ownership entry on the first Play and Stop, so the brief decided multiple scenes and Play instead. Both triggers now follow the brief.
	- **Against the product as written:** E1 ends in an internal demo, not a public video, because showcases are meant to be cinematic. That contradicts P4, [[Channel]] and the [[Roadmap]]'s E1 row, and the brief lists it as owed to the `/product-review` of Nov 7-8, with a `/triage` for what a cinematic needs and the new rung after R1 for undo and multiple scenes.
	- **New for S9-D2:** remembering the panel layout is a Must, kept in a git-ignored file inside the project, so the ADR now decides where per-user state lives for the layout.
- [x] **S9-T3** · The loaded scene acquires its references · P1 · 🟠 Moderate · 2-3h: #159 `5cc9ed8c`, **Oct 25**. #159 has no body and no review conversation, so this entry comes from the card, the diff and the session. After streaming, `SceneAsset::load` adds each distinct referenced id as a dependency of the scene entry, runs a loading phase and fills every `AssetRef<T>` handle ([[Resources - Design]] § *Reference fields*, *The scene's acquires as built*). Miguel wrote the two visitors and the cache change against Claude's scaffold; at his request, Claude wrote `acquireReferences` and the tree walk in `visitReferences`. Completes Story A and unblocks the lane's S9-T6 and S9-T7.
	- **No artifact said how the load learns each dependency's slot**, which it needs to fill a handle, or what a failed reference phase leaves in the `Scene`. `/card-start` stopped on both. Miguel chose an out-param on `addDependency` that returns the slot, and a `load` that clears the `Scene` on any failure, as `read` already did.
	- **Written, then deleted:** the first `visitReferences` walked only the roots, so a child's reference was never acquired. The first collector also wrote a placeholder slot `{0, 0}` into every live handle while it collected. Both were caught while pairing, before the PR.
	- **A reference absent for the role does not fail the load.** Its handle names the `AbsentForRole` entry, and a test now pins that.
- [x] **S9-T5** · The editor writes a mesh and a component that references it · P1 · 🤖 Claude · 2-3h: #158 `abcda239`, **Oct 25**. The editor writes the triangle as `assets/client/Triangle.temesh` when it creates the startup scene, and saves a `MeshRenderer` with its `AssetRef<Mesh>` on the scene's root. Both assets go through one `EditorApp::createAsset` call ([[Resources - Design]] § *Reference fields*, *The mesh component as built*). #158 has no review conversation, so this entry comes from the card, the PR body, the diff and the session. Unblocks S9-T6 and S9-T7 with S9-T3; Story B stays open.
	- **Reversed (1 of 7 decisions):** the lane named the component `MeshReference` so that it would not decide R1's mesh and material split. Miguel renamed it `MeshRenderer`, as in v1. It holds only the mesh until a material type exists, and that split is not final. The other six decisions merged unchanged.
	- **Against the note as written:** it said the editor regenerates the mesh on every run. The editor writes the mesh once, with the startup scene, and reuses the indexed file after that. A blob version bump therefore needs its own migration, which is R1's.
	- **Retro:** the rename's first push held only the `git mv`, because `git add` aborted on the old path. It was folded into that commit and force-pushed. Check `git show --stat` before pushing.
- [x] **S9-T2** · Reference fields and the reference walk · P1 · 🟢 Deep · 4-6h: #157 `1a92dfc2`, **Oct 24**. #157 has no body and no review conversation, so this entry comes from the card, the diff and the session. `AssetRef<T>`, one `ReferenceVisitor`, and a scene save and read that map entities through rows ([[Resources - Design]] § *Reference fields*, *The reference walk as built*). Miguel wrote the logic against Claude's scaffold. Unblocks S9-T3 and S9-T5; Story A stays open on S9-T3.
	- **No artifact said how a type-erased `writePayload` learns rows.** `/card-start` stopped on it, and Miguel chose to copy each component and rewrite the copy, so `Writer` and `Reader` stay free of context. He also took three defaults: a target with no row saves as empty with a warning, a row past the last entity is `Malformed`, and a vector of `Entity` or `AssetRef` does not compile.
	- **Written, then deleted:** the first copy block wrote the live component instead of the copy, and the first second pass walked the scratch copies instead of the scene. Both were caught while pairing.
	- **Retro:** in a fresh `Scene` the loaded entity for row r is `Entity{r, 0}`, so a read that skipped the second pass would still pass. The round-trip tests read into recycled slots to rule that out.
- [x] **S9-T4** · The mesh resource type · P1 · 🤖 Claude · 2-3h: #155 `ca141d2`, **Oct 24**. The lane's first 🤖 Claude card. `Mesh` in `core/mesh/` with its blob kind, type tag and loader, and the second row of `AssetIndex`'s table of asset kinds ([[Resources - Design]] § *Reference fields*, *The mesh*). #155 has no review conversation, so this entry comes from the card, the PR body and the diff. Miguel merged its seven *Decisions I took* unchanged, so nothing was reversed. Unblocks S9-T5 with S9-T2.
	- **Retro:** the fire that built it ran on a Saturday, outside the weekday cron, so the card started two days before the sprint note's Mon Oct 26.
- [x] **S9-T1** · The scene loads as a cache entry · P1 · 🟢 Deep · 4-6h: #154 `5786fd47`, **Oct 24**. #154 has no body and no review conversation, so this entry comes from the card, the diff and the session. The runtime's startup load now goes through the cache, as `SceneAsset::load` ([[Resources - Design]] § *Reference fields*). Miguel wrote the logic against Claude's scaffold. Unblocks S9-T3 (with S9-T2) and S9-T8; Story A stays open.
	- **"Frees the bytes" had no mechanism.** `resolve` returns a const payload, so a second owner call was needed beside the one the card named: `takePayload` moves the bytes out and leaves an empty payload. `/card-start` also settled the name (a `SceneAsset` member), the handle's home (`App::m_sceneHandle`, released by the base `simulationShutdown()`), and that a failed `addDependency` leaves its holder Ready.
	- **Review changed the design:** a second load of A, with A released but not yet drained, revived the entry with no bytes and failed as `Truncated`. `load` now drains frees first. A scene that is still held is refused with a warning and the new `ReadError::AlreadyLoaded` (Miguel's call), and `out` is written only on success.
	- **Written, then deleted:** `SceneAsset::write` briefly took `SceneBytes`; it went back to a byte vector, because `SceneBytes` exists only as the cache's type key.
	- **Retro:** the first CI attempt's two slowest legs were cancelled by hand because their live log page was blank, but their logs show them working: linux-clang Debug had passed 700 of 700, and win ASan was at 628 with none failed. The re-run cost those minutes again, win ASan at twice the rate. A blank log under the 20-minute job timeout is not a hang.




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%