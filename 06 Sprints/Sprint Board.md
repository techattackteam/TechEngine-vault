---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Day 1

- [ ] **S11-T1** · Story H meets a real asset · P1 · 🟠 Moderate · 2-3h: Sponza is re-imported with its images and ids kept, a real `.hdr` is imported, a merged `.temesh` is placed by hand, and the PR states BC7's encode time.


## Story B: R1's first frame

- [ ] **S11-T7** · Shared geometry buffers · P1 · 🟢 Deep · 4-6h: three immutable buffers with a free-list allocator and a second block when one fills. Follows S11-T6.
- [ ] **S11-T8** · The material buffer and bindless textures · P1 · 🟢 Deep · 4-6h: textures upload in their file's format, and each material writes its 96-byte record. Follows S11-T6.
- [ ] **S11-T9** · The first frame · P1 · 🟢 Deep · 4-6h: one forward pass draws Sponza with base color through the main camera in the runtime; Miguel's windowed check and a capture prove it. Follows S11-T4, S11-T7 and S11-T8.
- [ ] **S11-T16** · Render drops its GPU copies · P2 · 🟠 Moderate · 2-3h: render drops a copy once no packet or live copy names it and a device fence shows the GPU finished with it. Follows S11-T6.


## Story C: The scene view draws (drops first)

- [ ] **S11-T10** · The scene view is a render target · P2 · 🟠 Moderate · 2-3h: the editor draws the frame into a texture that the scene view and the game view show. Follows S11-T9.
- [ ] **S11-T11** · The scene view's fly camera · P2 · 🤖 Claude · 2-3h: the camera's state and update live in `edit/` with tests, fed from ImGui while the right mouse button is held. Follows S11-T10.


## Story D: Design and product

- [ ] **S11-D2** · Triage what a cinematic showcase needs · P2 · 🟡 Light · 1-2h: `/triage` of camera paths, fixed-rate capture and the rest, recorded in the [[Capability Map]]. Was S10-D5. Retagged from 🤖 Claude on Nov 17, because the lane runs no Design card.
- [ ] **S11-D3** · Design the asset browser · P2 · 🟠 Moderate · 2-3h: [[Content Pipeline - Design]] decides the list-only browser and cuts its build cards for Sprint 12. Drops after Story C.


## Story E: The lane's small cards

- [ ] **S11-T13** · A split mesh's children are named after their material · P3 · 🤖 Auto: with `_1`, `_2` on a repeat, and a two-primitive fixture test. After S11-T1.
- [ ] **S11-T15** · Queries replace the whole-scene walks · P3 · 🤖 Auto: every `getRoots`/`getChildren` walk is listed; the ones that need no hierarchy order become queries, the rest keep their reason. Off S11-T4's and S11-T12's files. Added Nov 16.


## Story F: Prepare Sprint 12

- [ ] **S11-P3** · Prep brief for Sprint 12 · P2 · 🤖 Auto · report-only: **not before Mon Nov 23**.
- [ ] **S11-D4** · Prepare Sprint 12 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 12's goal and draft cut into the Sprint 11 note. Runs **Tue Nov 24**, after S11-P3.


## 🔨 In Progress



## 👀 Review / Demo

- [ ] **S11-P2** · A README at the repo root · P3 · 🤖 Auto: #214, branch `S11-P2/readme`, opened Nov 18. Docs only, so no CI build runs.


## ✅ Done: Sprint 11

- [x] **S11-T6** · Ordered uploads and render's fence · P1 · 🟢 Deep · 4-6h: #213 (`8f2a444`), **Nov 17**. The cache records uploads and releases for marked types in one ordered list, `ClientApp` exchanges them with render at each publish point, and a free or a reload's old payload waits for its upload's slot and token ([[Renderer - Design]] § *Uploads and the fence*). Unblocks S11-T7, S11-T8 and S11-T16; Story B goes on.
	- **Split at `/card-start` by Miguel's call:** dropping a GPU copy became S11-T16, and the forks (pull at publish, retry at each publish point, dependencies by slot with the id as a log label only, retire until done) were settled there.
	- **Written and then removed before the merge:** the first scaffold kept a separate list of uploaded types and reported a token alone, which made the cache search for it. Miguel's review folded the flag into the type record and made the report a slot and a token, and that review became the *adapt the owner, never bolt on* rule, which rides in this PR in `CONVENTIONS.md` and three review skills.
	- **`/card-review` found five defects, all fixed before the merge:** `drainFrees` tested `state == Pending` instead of the pin, which also failed two older slot-reuse tests; `exchangeUploads` never touched the cache; the channel copied records and never emptied the sender's list; and a cache entry that failed on its dependencies sent a release. One gap is logged: an added dependency never reaches render ([[Known Issues]] D13).
	- **The clause "an empty packet pool holds no upload back" has no headless test.** No clientapp test exe exists, so only the call order in `publishFrame` holds it ([[Backlog]] § *client*).
	- *Retro:* CI's Release leg failed the "marking a type for upload is rejected" test every run, and it was first read as flaky. `TE_ASSERT` is compiled out in Release, so a test that expects an assert to fire needs `TE_CHECK` in the code. The PR has no description or review conversation, so this entry comes from the session.

- [x] **S11-T14** · The base sweep's leftover · P3 · 🤖 Auto: #212 (`6e0c12f`), **Nov 17**. `baseVersion()`, `platformVersion()` and `coreVersion()` are gone with their files and `BaseTests.cpp`, which ends S10-T9.
	- **The `done:` clause was wrong about `Platform.hpp`.** The header also declares `executablePath()`, which both apps' `main.cpp`, `EditorApp.cpp` and its own tests include, so it stays with only `platformVersion()` removed. Renaming it after its `.cpp` is in the [[Backlog]] (*platform*).
	- **The merge left two loose ends**, both in the [[Backlog]]: `core` now links toml++ that none of its files use (*core*, trigger fired), and `CONVENTIONS.md` § *Headers* still gives `base/Base.hpp` as its example of a module's own header (*etc*).
	- *Retro:* the PR has no review conversation, so this entry comes from the card, the PR body, the diff and [[2026-11-17 14-10 Auto Run]]. A card that deletes a header should say what else the header declares; the lane's grounding caught it, the card's cut did not.
- [x] **S11-T12** · The runtime logs entities at Debug · P3 · 🤖 Auto: #211 (`63f2fb3`), **Nov 17**. `RuntimeApp::logSceneTree` writes its entity and mesh lines at Debug, under the one INFO summary. Frees `RuntimeApp.cpp` for S11-T15's sweep.
	- **The clause hid a test change.** Debug is compiled out on Release, so the two runtime log tests that read per-entity lines now gate those checks on `TE_LOG_ACTIVE_LEVEL`, as `TaskGraphTests.cpp` already did. The lane's first local Release run failed the mesh-id check, which is how it found the second test.
	- *Retro:* the PR has no review conversation, so this entry comes from the card, the PR body, the diff and [[2026-11-17 09-08 Auto Run]].
- [x] **S11-T4** · Frame packets replace the snapshot · P1 · 🟢 Deep · 4-6h: #210 (`4d0b8e0`), **Nov 16**. Simulation fills a pooled packet after ticks, after edits and after the startup load, and render matches instances by `Entity` and interpolates them on the CPU ([[Renderer - Design]] § *The frame packet*, § *Packet delivery*). Unblocks S11-T9 with S11-T7 and S11-T8; Story B goes on.
	- **`/card-start` found two holes the card did not name:** the history dropped every packet whose tick did not advance, so a Stopped editor showed only its first edit, and four packets run out if render takes one before the history lets one go. A per-publish sequence and a hand-over under the mailbox's lock close them.
	- **The card grew three times on Nov 16, by Miguel's call:** one main camera per scene (core functions, two editor commands, a warning on load), a read-only query on a `const Scene` with `Scene::isRegistered` ([[Scene - Design]] § *Queries and invalidation*), and the walks it leaves for S11-T15. The camera functions became static members of `Camera`, which opened the *Grouping functions no instance owns* row in `CONVENTIONS.md`.
	- **Two `/card-review` passes fixed everything before the merge**, so no [[Known Issues]] row: an unlocked `release` that failed both threaded pool tests, a `findMainCamera` that dropped the hierarchy-order tie-break, a `setMainCamera` that cleared the main camera before refusing, and two Tracy zones in one block that would break `windows-profile`.
	- *Retro:* 4-6h became 57 files across `core`, `client`, `app` and the editor, and the PR has no description or review conversation, so this entry comes from the session. `m_vsync` now starts `false` (`RenderThread.hpp`), which no card asked for and nothing records. CI's `linux-clang Release` failed once on GLFW error 65550 in an untouched window case and passed on re-run: the first `[gpu]` flake since parallel `ctest` ([[B3 - Build & Testing Notes]] § *Load*).
- [x] **S11-P1** · The inputs check in `/sprint-prep` · P2 · 🤖 Auto: #209 (`87a67c8`), **Nov 16**. Step 3 of `/sprint-prep` now lists what the goal's showcase sentence consumes before the goal is proposed; the vault half landed earlier in [[Planning Workflow - Artifact Gate]] § *Where plans come from*. Nothing surprised. Its first real run is S11-D4 on Nov 24.
	- *Retro:* the PR has no review conversation, so this entry comes from the card, the PR body and the diff alone. The card's half-in-the-vault, half-in-a-PR shape worked, but it means the vault described the check before the merge did.
- [x] **S11-T5** · The camera component · P1 · 🤖 Claude · 2-3h: #208 (`4e05985`), **Nov 16**. `Camera` and `findMainCamera` in `core`, registered in both apps, with the inspector drawing it through the generic rows ([[Renderer - Design]] § *Build notes*). Unblocks S11-T4, and S11-T12 can now take `RuntimeApp.cpp`.
	- **All seven *Decisions I took* stood**: Miguel merged it about 80 minutes after it opened, with none reversed. Zero reversals for the retro's count.
	- **It is the sixth hand-written walk over `getChildren`**, which fires the trigger on the *`Scene` has no tree-order walk* entry in the [[Backlog]] (*core*), and S11-T4 will call it once per packet.
	- *Retro:* the PR has no review conversation, so this entry comes from the card, the PR body and the diff alone; nothing records what was weighed in review. No value checks yet (a near plane above zero), so S11-T4's or S11-T9's projection is where a bad value first shows.
- [x] **S11-T3** · The device · P1 · 🟢 Deep · 4-6h: #207 (`d09c6f98`), **Nov 16**. `RenderDevice` in `client` owns every GL object behind generational handles, and `FrameRenderer` draws M4's triangle through it with no GL call of its own ([[Renderer - Design]] § *The device*). Unblocks S11-T6, and S11-T4 once S11-T5 lands; Story B goes on.
	- **The card left the surface to `/card-start`, which settled four forks with Miguel:** handles as an index and a generation, the vertex layout inside the pipeline, an empty target for the window, and error codes for bad descriptions but checks for misuse. The card's handle list also differed from ADR-028 §1's object list: programs got their own handle, the vertex layout folded into the pipeline, and samplers wait for S11-T8.
	- **The layout changed mid-card by Miguel's call:** one folder per object kind under `render/device/`, holding data only, while every GL call stays in `RenderDevice.cpp`.
	- **The first full run failed 42 cases.** The window pass read a null render target, which killed the render thread in every App, Client and RenderThread case. A `/card-review` in the session then found eleven defects, among them pipeline state that was never applied, a scissor that was never enabled and `Rgba16F` created with one channel. All were fixed before the merge, so no [[Known Issues]] row.
	- *Retro:* the scaffold turned `FrameRenderer`'s working compile and link code into a TODO, so Miguel had to rebuild it; this PR also carries the `/card-start` rule that moved code moves whole. The PR has no description or review conversation, so this entry comes from the session that paired on it. No CI leg runs the device on Windows, since Windows excludes `[gpu]`; Miguel ran the suite locally and checked the triangle in the editor and the exported runtime, resize included.
- [x] **S11-T2** · GL 4.6 and bindless at startup · P1 · 🟡 Light · 1-2h: #206 (`60707037`), **Nov 14**. The window asks for 4.6 core, glad2 loads 4.6 with `GL_ARB_bindless_texture`, and the render thread refuses to start through `meetsGlRequirements` (`engine/client/src/render/GlRequirements.cpp`). Unblocks S11-T3; Story B goes on.
	- **The startup check logs each requirement that failed, not both every time.** The card and ADR-028 §2 said "which requirement failed"; [[Renderer - Design]] § *Build notes* said it names both. The code follows the card, and the note now says so.
	- **The check takes what glad loaded as a `GlSupport` value**, so its failing paths are tested headless. No context in the `[gpu]` tier lacks the floor, so a window test could only ever reach the passing path.
	- **The generator command in `cmake/deps.cmake:246` still reads `gl:core=4.5`.** The card cited those lines, and the regenerated header records the real command; carded in the [[Backlog]] (*etc*).
	- *Retro:* the card spelled the extension `ARB_bindless_texture`, but glad2 needs `GL_ARB_bindless_texture`; `/card-start` caught it. The PR has no description and no review conversation, so this entry comes from the card and the diff alone. No CI leg ran the 4.6 path on Windows, since Windows excludes `[gpu]`.
- [x] **S11-D5** · The testing regime · P1 · 🟢 Deep · 4-6h: #205 (`f932dd21`), **Nov 14**. Godot's split: a case's tier tag names the environment it needs, legs exclude by label, and `[gpu]` runs on Linux only, over zink ([[ADR-008 - v2 build & testing baseline]]'s Nov 14 amendments; audit in [[B3 - Build & Testing Notes]] § *Test tiers*). Unblocks S11-T2; Story A still has S11-T1.
	- **No Windows leg runs `[gpu]`, by Miguel's call.** The Windows zink spike had never run: LunarG's `latest` loader URL returned Not Found. He chose Godot's Linux-only rule over another spike.
	- **`[gpu]` holds all 62 window cases until two [[Backlog]] entries shrink it to 7**: a null render device (*client*) and the window asking for its renderer's GL version (*platform*). Meanwhile TSan reaches no editor case, which [[Known Issues]] D9 now says.
	- **Parallel `ctest` came in mid-card**, from S8-D3's inputs: four jobs per preset and a per-process `ScratchDirectory`. `win ASan`'s test step went from about 203 s (#148) to 68 s on the first run.
	- *Retro:* the first run failed both plain Windows legs. Two cases shared a fixed file under parallel `ctest`: a stderr capture the audit had judged single-use, and `logs/techengine.log`, which every `App::run()` writes. Linux allows the shared file, so only Windows showed it; the shared log itself is [[Known Issues]] D12. *Retro:* the branch was first cut from S11-D1's spike branch; `/card-start`'s gate caught it.
- [x] **S11-D1** · CI's GL floor · P1 · 🟠 Moderate · 2-3h: vault `8446176`, **Nov 14**. No CI runner's default software GL meets ADR-028 §2, and only zink over lavapipe on Linux does, through an EGL context; recorded as a correction in [[ADR-028 - Render device seam and frame packets]] § *Consequences*. Unblocks S11-D5.
	- **Split at its `/card-start`:** how CI runs the window tests became the new S11-D5, which S11-T2 now follows, so this card kept only the spike and the amendment.
	- **The card's premise was stale.** `ubuntu-latest` is now ubuntu-26.04 with Mesa 26.0.8, not S10-P2's Ubuntu 24.04 and Mesa 25.2.8, and Windows' llvmpipe already gives 4.6; bindless is what every software path lacks. *Retro:* a measurement copied into a card goes stale when the runner image moves.
	- **Left open by Miguel's call, for S11-D5:** Windows' zink, which needs a Vulkan loader, and TSan's races from Mesa's threads, which he chose not to suppress. The spike's workflow and probe stay on the unmerged `S11-D1/ci-gl-floor` branch, after five runs and about 15 runner minutes.




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%