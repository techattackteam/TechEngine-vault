---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: M6's scene and its references



## Story B: The mesh path · 🤖 Claude

- [ ] **S9-T6** · The editor reads its startup scene through the cache · P2 · 🤖 Claude · 2-3h: loaders registered, S9-T1's function with `LooseSource`, the `EditorApp.cpp:56` `TODO` goes. Follows S9-T1, S9-T3 and S9-T5.
- [ ] **S9-T7** · The bake packs what the startup scene reaches · P1 · 🤖 Claude · 2-3h: `exportTo` walks the scene's references; the runtime registers the mesh loader and component; a `RuntimeAppTests` case over an export loads the mesh. Follows S9-T2, S9-T3 and S9-T5.


## Story C: E1's opening decisions

- [ ] **S9-D1** · Write the editor's capability brief · P1 · 🟠 Moderate · 2-3h: `/brief editor`; decides the launcher, reopening the last scene and any Play state.
- [ ] **S9-P1** · Research brief for the editor ADR · P2 · 🤖 Auto · 2-3h: Unity, Unreal and Godot editor UI beside the sim and render threads, ImGui over a GL-owning render thread; mapped onto ADR-018 without choosing. Report-only, week 1.
- [ ] **S9-D2** · Decide the editor's architecture · P1 · 🟢 Deep · 4-6h: `/adr` from the brief and S9-P1; ImGui's window and thread, how panels read the `Scene`, how an edit reaches the sim, the stopped state. Follows S9-D1 and S9-P1.
- [ ] **S9-D3** · Write the editor's design note and cut the first T1 cards · P1 · 🟡 Light · 1-2h: `Editor - Design` indexes the ADR; T1 cards cut into Story D. Follows S9-D2.


## Story D: E1's first panels · stretch



## Story E: Alongside: the renderer brief

- [ ] **S9-D4** · Write the renderer's capability brief · P2 · 🟠 Moderate · 2-3h: `/brief renderer`; one renderer ADR or several.
- [ ] **S9-P2** · Research brief for the renderer ADR · P3 · 🤖 Auto · 2-3h: Filament, Godot 4, URP and Unreal against the brief, mapped onto ADR-005's device seam without choosing. Report-only. Follows S9-D4.


## Story F: Auto lane and fired backlog

- [ ] **S9-T8** · Prove the cache shuts down after the app's own shutdown · P3 · 🤖 Auto · 1-2h: one `AppTests` case over the real simulation thread; only `AppTests.cpp` changes. Follows S9-T1.
- [ ] **S9-T9** · Log the OS error where `FileAccess` returns `IoError` · P3 · 🤖 Auto · 1-2h: every `IoError` return in `FileAccess.cpp` logs the path and the OS message at warn; other codes stay silent; `[skip-coverage]` allowed if the paths are unreachable in tests.
- [ ] **S9-T10** · Let the case check see through symlinks below a mount root (D3) · P3 · 🤖 Auto · 2-3h: `matchesOnDiskCase` checks spelling per component with `directory_iterator`; a symlink case in `MountTableTests`, `SKIP` where it cannot be created.


## Story G: Prepare Sprint 10

- [ ] **S9-P3** · Prep brief for Sprint 10 · P2 · 🤖 Auto · report-only: unbuilt *Decided* rows, blocking questions, fired triggers, candidate 🤖 Claude features; decides nothing. **Not before Mon Nov 2.**
- [ ] **S9-D5** · Prepare Sprint 10 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 10's goal and draft cut into the Sprint 09 note. Tue Nov 3 to Fri Nov 6, after S9-P3.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done: Sprint 09

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