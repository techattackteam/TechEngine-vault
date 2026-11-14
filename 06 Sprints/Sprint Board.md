---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Day 1

- [ ] **S11-D5** · The testing regime · P1 · 🟢 Deep · 4-6h: every test case sorted by its real type against how Unreal, Unity and Godot tier theirs; ADR-008's amendment decides the tiers and where each runs, and its PR wires them. Follows S11-D1; must merge before S11-T2.
- [ ] **S11-T1** · Story H meets a real asset · P1 · 🟠 Moderate · 2-3h: Sponza is re-imported with its images and ids kept, a real `.hdr` is imported, a merged `.temesh` is placed by hand, and the PR states BC7's encode time.


## Story B: R1's first frame

- [ ] **S11-T2** · GL 4.6 and bindless at startup · P1 · 🟡 Light · 1-2h: glad2 is regenerated for 4.6 and `ARB_bindless_texture`, and the window asks for a 4.6 context, and the startup check logs which requirement failed. Follows S11-D5.
- [ ] **S11-T3** · The device · P1 · 🟢 Deep · 4-6h: typed handles, pipelines bound whole and explicit render passes; M4's triangle draws through it. Follows S11-T2.
- [ ] **S11-T5** · The camera component · P1 · 🤖 Claude · 2-3h: `Camera` in `core`, registered in both apps, shown by the inspector, and one function that returns the main active camera.
- [ ] **S11-T4** · Frame packets replace the snapshot · P1 · 🟢 Deep · 4-6h: the extraction hook fills a pooled packet after ticks and edits, and render moves it. Follows S11-T3 and S11-T5.
- [ ] **S11-T6** · Ordered uploads and render's fence · P1 · 🟢 Deep · 4-6h: uploads cross to render in order, and simulation defers a free until render reports the upload done. Follows S11-T3.
- [ ] **S11-T7** · Shared geometry buffers · P1 · 🟢 Deep · 4-6h: three immutable buffers with a free-list allocator and a second block when one fills. Follows S11-T6.
- [ ] **S11-T8** · The material buffer and bindless textures · P1 · 🟢 Deep · 4-6h: textures upload in their file's format, and each material writes its 96-byte record. Follows S11-T6.
- [ ] **S11-T9** · The first frame · P1 · 🟢 Deep · 4-6h: one forward pass draws Sponza with base color through the main camera in the runtime; Miguel's windowed check and a capture prove it. Follows S11-T4, S11-T7 and S11-T8.


## Story C: The scene view draws (drops first)

- [ ] **S11-T10** · The scene view is a render target · P2 · 🟠 Moderate · 2-3h: the editor draws the frame into a texture that the scene view and the game view show. Follows S11-T9.
- [ ] **S11-T11** · The scene view's fly camera · P2 · 🤖 Claude · 2-3h: the camera's state and update live in `edit/` with tests, fed from ImGui while the right mouse button is held. Follows S11-T10.


## Story D: Design and product

- [ ] **S11-D2** · Triage what a cinematic showcase needs · P2 · 🤖 Claude · 1-2h: `/triage` of camera paths, fixed-rate capture and the rest, recorded in the [[Capability Map]] as decided by the lane. Was S10-D5.
- [ ] **S11-D3** · Design the asset browser · P2 · 🟠 Moderate · 2-3h: [[Content Pipeline - Design]] decides the list-only browser and cuts its build cards for Sprint 12. Drops after Story C.


## Story E: The lane's small cards

- [ ] **S11-P1** · The inputs check in `/sprint-prep` · P2 · 🤖 Auto: the command and the artifact gate list what the goal's showcase sentence consumes before a goal is proposed.
- [ ] **S11-T12** · The runtime logs entities at Debug · P3 · 🤖 Auto: per-entity lines at Debug and one `INFO` summary. After S11-T5.
- [ ] **S11-T13** · A split mesh's children are named after their material · P3 · 🤖 Auto: with `_1`, `_2` on a repeat, and a two-primitive fixture test. After S11-T1.
- [ ] **S11-T14** · The base sweep's leftover · P3 · 🤖 Auto: the version-anchor stubs go from `base`, `platform` and `core`. Was S10-T9.
- [ ] **S11-P2** · A README at the repo root · P3 · 🤖 Auto: what the engine is, how to clone the vault, and the three preset commands.


## Story F: Prepare Sprint 12

- [ ] **S11-P3** · Prep brief for Sprint 12 · P2 · 🤖 Auto · report-only: **not before Mon Nov 23**.
- [ ] **S11-D4** · Prepare Sprint 12 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 12's goal and draft cut into the Sprint 11 note. Runs **Tue Nov 24**, after S11-P3.


## 🔨 In Progress

- [ ] **S11-D1** · CI's GL floor · P1 · 🟠 Moderate · 2-3h: a spike shows whether zink over lavapipe gives CI GL 4.6 with bindless on each OS, and ADR-028's amendment records the answer. Unblocks S11-D5.


## 👀 Review / Demo



## ✅ Done: Sprint 11





%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%