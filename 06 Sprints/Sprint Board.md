---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Multi-select



## Story B: Export · 🤖 Claude



## Story C: Editor panels



## Story D: E1's loose ends

- [ ] **S10-T7** · E1's internal demo · P1 · 🟡 Light · 1-2h: the Editor brief's five scenarios run windowed, the exported runtime's log names the edited entities, and E1 is closed on the [[Roadmap]]. Follows S10-T2 and S10-T3.
- [ ] **S10-T9** · The base sweep's leftover · P3 · 🟡 Light · 1-2h: the version-anchor stubs go. The shared log-capture guard moved to S10-T10. Follows S10-T10.


## Story E: Alongside: R1's two ADRs



## Story F: Defects

- [ ] **S10-B2** · Roots keep their order · P2 · 🟠 Moderate · 2-3h: `Scene` keeps a root order, so adding a component or destroying a root no longer moves another, and a save keeps the order.
- [ ] **S10-B3** · A reparent under a rotated, non-uniformly scaled parent is refused · P3 · 🟠 Moderate · 2-3h: amend ADR-021 so a reparent that would need shear keeps the world position with an approximate rotation and scale, as Unity does; a zero scale stays refused. Not at the same time as S10-B2, which also edits `Scene.cpp`.
- [ ] **S10-B4** · A startup scene that no file holds leaves the editor stuck · P3 · 🟠 Moderate · 2-3h: when the manifest names a scene no asset source holds, the startup load recovers as it does with no scene named, adopting or creating `Startup.tescene`, so the editor can save again. A file that exists but does not load is still never overwritten.


## Story G: Product follow-up

- [ ] **S10-D5** · Triage what a cinematic showcase needs · P2 · 🟡 Light · 1-2h: `/triage` of camera paths, fixed-rate capture and the rest, recorded in the [[Capability Map]]. Before E2's showcase.


## Story H: Meshes and models before the renderer

- [ ] **S10-T16** · Place a model as copies · P1 · 🟠 Moderate · 2-3h: one edit command builds the model's entities under one root at the origin, with no link to the file. Until the asset browser, a *Place model* menu entry with a typed path sends it. Follows S10-T14.
- [ ] **S10-D11** · Design the texture file · P1 · 🟠 Moderate · 2-3h: a `/triage` of the sky's HDR image, then [[Content Pipeline - Design]] decides `.tetexture`, the BC format per material input, the mips, the encoder and the decoder, and cuts the texture card. No ADR. Follows S10-D7. Split from S10-D10.
- [ ] **S10-T17** · TEMesh v2's file · P1 · 🟢 Deep · 4-6h: `Mesh` at version 2 with the import block, stream flags, four streams and slots, its default materials listed as dependencies, and `Triangle.temesh` written again. Follows S10-T14.
- [ ] **S10-T18** · Materials per slot on `MeshRenderer` · P1 · 🟢 Deep · 4-6h: the four visitors walk a vector element by element, `MeshRenderer` holds one material per slot, and the list is rebuilt by slot name. Follows S10-T17 and S10-D7.
- [ ] **S10-T19** · Import writes TEMesh v2 · P1 · 🟢 Deep · 4-6h: normals, the file's tangents or MikkTSpace's, UV0, one slot per mesh; quantized and meshopt glTF refused. MikkTSpace and meshoptimizer join the editor's build. Follows S10-T15 and S10-T17.
- [ ] **S10-T20** · Import as one merged mesh · P1 · 🟢 Deep · 4-6h: the model walk baked and joined by material, mirrored parts flipped, placed as one entity. Follows S10-T19 and S10-T16.
- [ ] **S10-T21** · Re-import keeps ids and reloads · P1 · 🟢 Deep · 4-6h: outputs keep their ids by source key, materials stay untouched, and the cache reloads behind live handles while Stopped. May split at the reload. Follows S10-T18 and S10-T19.


## Story I: Prepare Sprint 11

- [ ] **S10-D6** · Prepare Sprint 11 · P1 · 🟠 Moderate · 2-3h: `/sprint-prep` writes Sprint 11's goal and draft cut into the Sprint 10 note. Tue Nov 10 to Fri Nov 13, after S10-P2.


## 🔨 In Progress

- [ ] **S10-D7** · The materials and shading models ADR · P2 · 🟢 Deep · 4-6h: `/adr` drafts R1's second ADR, Miguel accepts it, and `Renderer - Design` indexes it. Follows S10-P3 and S10-D4.


## 👀 Review / Demo



## ✅ Done: Sprint 10

- [x] **S10-T15** · Import a source file as a model · P1 · 🟢 Deep · 4-6h: #194 `9c93b8f`, **Nov 9**. A job imports glTF, FBX or OBJ into a folder beside the source, and a second command adds the records to the asset index on the simulation thread. Unblocks S10-T19 together with S10-T17; Story H stays open on S10-T16 to S10-T21 and S10-D11.
	- **Two `done:` clauses had no referent:** no asset browser card exists, so the TODO is `TODO(E2)`. No source file ships in `projects/dev`, so the startup import of `assets/client/Sponza.gltf` is also skipped when the file is missing, and does nothing until one is dropped in. Nobody has run it on a real Sponza yet.
	- **The PR lists eleven calls that no artifact made**, among them: the root is always named after the file, a source root keeps its own transform, ids are drawn on the worker, and closing the editor waits for imports. The PR has no review conversation, so nothing records a reversal. The calls are now in [[Content Pipeline - Design]] § *The import*.
	- **Written and deleted before merge:** a test that destroyed the editor during an import without calling `shutdown()`. TSan on the Linux leg caught the job's log line waking main through a virtual call after the destructor had already rewritten the vptr. Only `shutdown()` can wait in time; the destructor still waits, but too late for the log lines.
	- **Found in assimp:** its glTF reader lists meshes in the order the nodes first name them, not in the file's order, so a mesh's index is a weak source key. [[Content Pipeline - Design]] § *Re-import* records it for S10-T21.
	- **Logged, not fixed:** a zero or negative import scale is not refused (D8). Not tested: an FBX source, and a write that fails halfway ([[Backlog]]).
- [x] **S10-D10** · Design TEMesh v2 and re-import · P1 · 🟢 Deep · 4-6h: vault `5408328`, **Nov 9**, **narrowed**. [[Content Pipeline - Design]] decides the mesh file, materials per slot, the merged mesh and re-import, and ADR-024 §9 has its dated amendment. It cut S10-D11 and S10-T17 to S10-T21. Unblocks S10-T17; Story H stays open on S10-T15 to S10-T21 and S10-D11.
	- **Textures moved to S10-D11** (Miguel): a texture's BC format follows what S10-D7's material samples, so deciding it here would have guessed at the material. Miguel also asked whether the texture file needed its own ADR; it does not, because a wrong format costs a version bump and a re-import.
	- **Miguel's calls against the note's lean:** a `MeshRenderer` holds exactly one material per mesh slot, copied from the mesh's defaults and matched by slot name after a re-import. The note had leaned toward Unreal-style overrides, and Claude proposed materials on the mesh only; Miguel rejected both.
	- **The slot list had no way to be stored:** `Writer` and `Reader` refuse a vector of `AssetRef` (Miguel, Oct 24), and `ReferenceVisitor` skips one silently. Miguel chose to visit each element, which refines the Oct 24 row in [[Resources - Design]]. Claude's first brief had wrongly called the whole failure silent.
	- **Retro:** the card started before S10-D7, although its slots point at S10-D7's type, so S10-T18, S10-D11 and the material card all wait on it. Grounding also found [[Renderer - Design]]'s attribute question still owned by S10-D9, and asking about an index width that ADR-028 §5 had already decided; the card's commit resolved it. A vault-only card has no PR conversation, so this entry is the only record.
- [x] **S10-P2** · Prep brief for Sprint 11 · P2 · 🤖 Auto · report-only: vault, **Nov 9**, by the lane. [[2026-11-09 14-12 Auto Run]] is S10-D6's reading list. Its main finding was measured, not read: CI's `llvmpipe` gives GL 4.5 with no bindless textures, so R1's GL 4.6 floor (ADR-028 §2) cannot start a render thread on CI (filed in the [[Backlog]], `#prio/high`). It also found that no card cuts R1's build cards. Unblocks S10-D6.
- [x] **S10-P4** · Research report for mesh merging and import · P2 · 🤖 Auto · report-only: vault `9a27c99`, **Nov 9**, by the lane. [[Content Pipeline - Mesh Import Report]] answers the card's six questions from assimp 6.0.5's source, MikkTSpace, the glTF spec and six BC libraries, and ends with eight questions for S10-D10. Unblocks S10-D10; Story H stays open on S10-D10, S10-T15 and S10-T16.
	- **Stronger than S10-P1 and S10-P3 on code, weaker on speed:** every source except the speed figures was cloned and read. Building the compressors to time them was refused by the sandbox, and the one independent benchmark's host fails at the proxy, so "how fast are they?" rests on search extracts and the authors' own claims.
	- **Found in assimp, not assumed by the card:** `aiProcess_PreTransformVertices`'s flattening path never fixes winding under a negative scale (only its keep-hierarchy path and `OptimizeGraph` do), and a quantized or meshopt-compressed glTF imports garbage positions instead of failing. Both are inputs to S10-D10's questions, not defects of ours.
	- A vault-only card has no PR conversation, so this entry is the only record.
- [x] **S10-T14** · The import block and the TEModel file · P1 · 🟢 Deep · 4-6h: #193 `ac594e4`, **Nov 6**. `core` has the import block and the `.temodel` node table with write and read, and the editor's asset index lists the model kind. Unblocks S10-T15 together with S10-T13, and S10-T16; Story H stays open on those two and the mesh's cards.
	- **The design note left the import block's layout open**, and listed the block before the model's id, where the asset index could not read the id. `/card-start` stopped on both. Miguel decided four calls: a byte count first, so a reader can step over the block; the source key as an index and a name; settings written in every block; and an up axis of Y or Z. All of it is now in [[Content Pipeline - Design]] § *The import block* and § *The model file*.
	- **Fixed before the PR:** the first read failed four of the scaffold's tests. The quaternion's w was never written, both reads changed the object before checking the bytes, and `Model::read` turned every error into `Malformed` and ignored the block's own. Claude rewrote both reads at Miguel's request.
	- **Grounding read v1's model import** at `v1-reference`. This design already follows its shape, and [[Content Pipeline - Design]] § *Porting v1's import* lists the seven fixes S10-T15 owes when it ports the assimp walk.
	- **Retro:** sized 🟢 Deep at 4-6h, it ran as a 🟠 Moderate (Miguel, at the close). The PR has no description or conversation, so this entry is the only record of the above.
- [x] **S10-T13** · assimp in the editor build · P1 · 🟠 Moderate · 2-3h: #192 `e59d77c`, **Nov 6**. assimp v6.0.5 is pinned in `cmake/deps.cmake` with only its glTF, FBX and OBJ importers and no exporters, and only the editor links it. Unblocks S10-T15 together with S10-T14; Story H stays open on S10-T14 to S10-T16 and the mesh's cards.
	- **The build-time clause was waived:** Miguel dropped the before and after clean build times at the close, so the PR states neither, and ADR-005's "revisit if build weight bites" still has no baseline.
	- **`/card-start` found assimp defaults that reach past its own targets:** a GLOBAL ccache launcher, a cached `CMAKE_DEBUG_POSTFIX` that renames every library declared after it, and a system zlib on Linux that nothing pins. Its own `-Werror` and its test suite were also on. All of them are off, and `deps.cmake` explains the first three.
	- **Written and deleted before merge:** a TODO warned that assimp's MSVC `/Zi` would defeat ccache as Jolt's did. A re-run of the win Debug leg on the same commit hit on all 591 calls, so the warning went.
	- **Retro:** the squash also rewrote the dev project's `Startup.tescene` from several entities to one, which the card did not ask for. **Unverified:** no check is recorded that the runtime's link line has no assimp.
- [x] **S10-D9** · Design TEMesh, TEModel and the glTF loader · P1 · 🟢 Deep · 4-6h: vault `d430705`, **Nov 6**, **split**. [[Content Pipeline - Design]] decides the model half: TEModel as its own node table, a folder per import, scale and up axis baked in, an import block inside every imported file (neither sidecar nor registry), and placed models as copies. It cut S10-P4 and S10-T13 to S10-T16. The mesh half moved to S10-D10, after S10-P4's report. No ADR was needed.
	- **Miguel's calls during grounding:** no prefabs or links, so a placed model is a copy, now two rows in [[Content Pipeline - Brief]] § *Decided*. A node's meshes stay separate child entities even after TEMesh v2, against Claude's proposal to join them into slots. Until the asset browser exists, one file is imported at startup, and placement goes through a menu entry, because placing at startup would add a copy on every launch.
	- **The brief contradicted itself:** its Oct 31 quote packs a merged mesh "into just a single mesh and material", while the next row keeps a slot per source material. Material slots won, because a single material means v1's texture atlas bake, which never worked. Atlas baking moved to R7's mesh LOD, and seven candidate papers are queued on [[Research]].
	- **Retro:** the `done:` clause assumed one session could decide both files, but the mesh waits on research. The card was split instead of left open. A vault-only card has no PR conversation, so this entry is the only record.
- [x] **S10-D4** · The frame and device seam ADR · P1 · 🟢 Deep · 4-6h: vault `22f1514`, **Nov 6**. [[ADR-028 - Render device seam and frame packets]] is Accepted and [[Renderer - Design]] indexes it: a small GL-shaped device on the render thread, frame packets moved instead of copied, ordered uploads behind render's fence, and a forward E2 frame. Unblocks S10-D7 and S10-D9; Story E stays open on S10-D7.
	- **Miguel moved three calls in review:** GL 4.6 instead of keeping 4.5, `ARB_bindless_texture` required as in v1, and light clusters built in compute as in v1 instead of on the CPU. He confirmed from v1 that RenderDoc cannot capture bindless GL, so captures go through Nsight.
	- **Grounding found two gaps no artifact had named:** the editor never sent render a frame after an edit, because `publishSnapshot` runs only on ticks and gets no `Scene`; and the snapshot was copied by value about four times a frame. ADR-028 §3 answers both. The scene view's camera, from main on ADR-019 §4's path, was added in review because the editor's two views made "the camera" plural.
	- **Written and corrected before acceptance:** §4 had merged render's fence with the GPU copy's lifetime, and §5 said packets hold mesh offsets, when the GPU's in-flight draw commands do. v1's copy-on-remove mesh buffers are recorded in [[Renderer - Design]] § *Geometry buffers* as the thing not to repeat.
	- **ADRs touched:** ADR-005 amended for the 4.6 and bindless floor; ADR-006 §5's Renderer row partially superseded ([[ADR Index]]). **Retro:** the ADR runs about 166 lines against the usual 120, for six decisions. S10-D9 was started first and the order gate sent it back. A vault-only card has no PR conversation, so this entry is the only record.
- [x] **S10-T8** · Edit an `AssetRef` in the inspector · P3 · 🟢 Deep · 4-6h · stretch: #190 `6764a8a`, **Nov 6**. The inspector sets an `AssetRef` through a picker over the index's assets of the field's type, and `SetAssetFieldCommand` adds the id as a dependency of the scene entry and fills the handle. Completes Story A.
	- **"Which `visitAsset` now passes" meant more than the type:** writing the field needs its id and handle by reference too, so asset fields are no longer a read-only kind. [[Editor - Design]] § *Fields* now says so.
	- **Decided at `/card-start`, in [[Editor - Design]] § *Decided*:** the command runs its own loading phase and writes only a Ready entry, so a failed load changes nothing. A created startup scene is now loaded back, because the first launch's scene had no cache entry to add a dependency to.
	- **Calls the note did not make:** the picker reads a copy of the index in the snapshot, a server asset is refused and left out of the picker (a `/card-review` finding), and `core` gained `ResourceCache::getState(ResourceSlotId)`. There is no way to clear a reference: an empty id is not in the index, and no artifact decides it.
	- **Found beside the card:** a manifest that names a missing scene leaves the editor unable to save, carded as S10-B4. The dev project never had a mesh, because its scene predates S9-T5; it now ships `Triangle.temesh`.
	- **Retro: the first push failed CI twice.** The Run test raced its own fake runtime on UBSan and now waits for a release file, and diff coverage was 79% until the refusal branches got tests. Miguel asked Claude to write the logic of this 🟢 card. The PR has no review conversation, so this entry is the only record. **Unverified:** no recorded windowed pick of the triangle, or runtime log of it.
- [x] **S10-T12** · The console panel · P2 · 🟠 Moderate · 2-3h: #189 `4a8af74`, **Nov 6**. The editor's console docks below the views and keeps 5,000 records in `ConsoleHistory`, with a level and text filter, Clear, and the selected row's source. Completes Story C, since the Profiler's build waits for E11.
	- **Changed at Miguel's windowed check, against [[Editor - Design]] § *The console panel*:** the level toggles left the toolbar for one *Show* dropdown with their counts, which also hides the time and tick columns. Debug rows are blue, and the rows sit on a darker background. The note now records the new toolbar.
	- **Calls the note did not make:** the "N records dropped" row is Info, Clear keeps the filters, and the selection is a copy of the record, so a drop cannot leave it dangling.
	- **A new row must show in the frame that adds it:** `SetScrollHereY` lands a frame late and the idle editor may not build that frame, so the panel sets the scroll and the content size before `BeginChild`.
	- **Retro: the first `addDroppedRow` pointed a `LogRecord`'s message at a temporary string,** and `add` skipped every batch with no drops. `/card-review` traced both from three failing tests before the PR. The PR has no review conversation, so this entry is the only record.
	- **Unverified:** no record that a Warn from the simulation shows without moving the mouse, the windowed clause the scroll call above exists for.
- [x] **S10-T6** · Local and World modes in the transform inspector · P3 · 🤖 Claude · 2-3h: #188 `1ac607d`, **Nov 6**, by the lane. A Mode row on `Transform` shows world values, and a World edit becomes a `SetWorldAxisCommand` that calls `setWorld` on the simulation thread against the current parent chain. Unblocks S10-T8; Story D stays open on S10-T7 and S10-T9.
	- **All seven *Decisions I took* merged as written, none reversed.** The PR has no review conversation, so nothing records what was weighed and rejected.
	- **The shear limit stays S10-B3's:** a World edit under a rotated, non-uniformly scaled parent is refused for that entity and logged, as ADR-021 decides today.
	- **New in the edit records:** `LocalTransformRecord`, because one `setWorld` can change position, rotation and scale at once. **World mode's Euler cache matches within 1e-4**, because a world rotation never comes back bit for bit.
	- **Unverified:** no visual check of the toggle is recorded.
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