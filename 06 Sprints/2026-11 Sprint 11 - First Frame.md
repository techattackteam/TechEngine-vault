# 2026-11 · Sprint 11: First Frame

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Nov 14 - Friday Nov 27, 2026.
- **Epic:** E2 · First renderer, the first of about three sprints ([[Roadmap]]). Hubs:
  [[Renderer - Design]] and [[Content Pipeline - Design]].

## Sprint goal

E2's first frame. Sponza, imported with its textures, is drawn through a camera in the runtime's
window, on the new device, with base color only. The editor's scene view shows the same frame and
is the first part to drop.

Drafted by S10-D6's `/sprint-prep` on Nov 14 ([[2026-10 Sprint 10 - Close E1]] § *Sprint 11's
cut*) and fitted the same day ([[2026-11-14 Sprint 10 Retrospective]]). All 17 drafts survived
unchanged, and Miguel committed to all of them. § *What E2 still lacks* in that cut lists what
Sprint 12 and after must decide: the sun, material edits, the asset browser, sky lighting.

## Artifact gate

- Every R1 card is cut against [[Renderer - Design]] § *Decided*, under
  [[ADR-028 - Render device seam and frame packets]] and
  [[ADR-029 - Materials, surfaces and lobes]]. Each card writes its own mechanism section there.
- **First Design cards:** S11-D1, CI's GL floor, then S11-D5, the testing regime, on day 1.
  S11-T2 and S11-T3 raise the GL check, so they wait for both.
- **Briefs:** [[Renderer - Brief]] and [[Content Pipeline - Brief]] exist, so no `/brief` is owed.
- **Showcase:** none this sprint, because E2 does not end here. E2 has no outline yet; `/showcase
  E2` is owed before the sprint that ends it, and S11-D2 feeds it.
- [[Known Issues]]: D9, D10 and D11 neither block nor touch these cards. D11 rides along only if
  S11-T1 changes `ImageDecoder`.

## Stories & tasks

### Story A: Day 1 (Miguel)

- [x] **S11-D1** · CI's GL floor · P1 · 🟠 Moderate · 2-3h ·
  done: a spike branch shows whether zink over lavapipe gives CI a GL 4.6 core context with
  `ARB_bindless_texture`, on the Linux legs (TSan included) and on Windows' Mesa. ADR-028 gets a
  dated amendment to § *Consequences* that records the answer for each OS. Known so far, from
  S10-P2 ([[2026-11-09 14-12 Auto Run]]): every leg draws with Mesa's `llvmpipe`
  (`.github/workflows/ci.yml:158`, `:211-212`), which on Mesa 25.2.8 gives GL 4.5 core and no
  bindless, and zink would not start under Xvfb in the lane's sandbox. The spike probes first
  with a throwaway workflow that builds nothing, then dispatches `ci.yml` once on the branch,
  because a change to `ci.yml` never runs `ci.yml` (`.github/workflows/ci.yml:28-36`). Each
  spike push costs CI minutes, so batch them. The branch is never merged, so the card lands as
  vault commits. How CI runs the window tests is S11-D5's.
- [ ] **S11-D5** · The testing regime · P1 · 🟢 Deep · 4-6h ·
  done: every current test case is sorted by what it really is (unit, integration, a real-disk
  OS test, stress, or another type the audit finds), and the cases whose tags say otherwise are
  listed. How Unreal, Unity and Godot tier their tests is the baseline. ADR-008 gets a dated
  amendment to §6 and §9 that decides which tiers exist, how a case joins one, where each tier
  runs (every PR, a scheduled run, on demand, or only locally) and who reads a run that no PR
  shows. A weekly run that the weekly review reads is one proposal, not the answer. The
  amendment also decides what the diff coverage gate does with code that only a skipped tier
  covers. Its PR wires the decision: the tags, the CTest labels, the legs in `ci.yml` and any new
  workflow, with zink wherever S11-D1 found that it works. It must merge before S11-T2. Follows
  S11-D1. Added on Nov 14 at S11-D1's `/card-start`; its inputs are in § *S11-D5's inputs*.
- [ ] **S11-T1** · Story H meets a real asset · P1 · 🟠 Moderate · 2-3h ·
  done: Sponza's images are in `projects/dev` with a licence file beside them, and
  *Re-import...* rewrites Sponza with every id kept and each mesh slot naming a material.
  *Import image...* runs on a real `.hdr`, and a merged `.temesh` is placed by hand. The PR
  states BC7's encode time for Sponza. Each defect found is fixed there or carded. This is the
  first windowed run of anything in #203.

### S11-D5's inputs

Moved here from the [[Backlog]]'s *Test tiers and parallel ctest* entry, which was cut on Nov 14.

- **Decided by Miguel:** the real-disk tests (`[files]`, `[fileaccess]`, `[mounttable]` and the
  rest that use `ScratchDirectory`) are an OS tier, not unit (S8-D3, Oct 2026). The repository
  will go private, so the plan must hold under a minute budget. The window's context request
  rises to 4.6 with S11-T2 (Nov 14), so every case that opens a window needs the GL floor.
- **Tags today:** `[window]` is not the set of cases that open a window. Three `EditorAppTests`
  cases open one under `[editor]` alone, because `bootstrap()` opens a window, and
  `engine/platform/tests/window/WindowErrorTests.cpp:12` is tagged `[window]` and opens nothing.
  `FrameRendererTests` loads GL itself (`engine/client/tests/render/FrameRendererTests.cpp:72`,
  `:117`), not through the render thread.
- **Coverage:** `cmake/coverage.cmake:94` runs the whole suite, so a tier that PRs skip leaves
  its code uncovered under the 85% gate.
- **From S11-D1's spike (Nov 14), recorded in ADR-028 § *Consequences*:** on Linux, zink over
  lavapipe runs the suite only if the window creates its context through EGL, which today's
  `Window.cpp` does not; whether it does so always on Linux or only on CI is open. Under TSan
  the 62 window cases all fail on races from Mesa and X, and Miguel chose not to suppress them
  (Nov 14). Those 62 failures are the exact set of cases that open a window. Three of them are
  tagged `[editor]` alone (the three named above), and two `[window]` cases open no window: the
  `WindowError` category case and *GLFW grows and frees its blocks through the allocator Window
  installs*. Windows' zink was left untried.
  TSan also reported a lock-order inversion in `Client::stop()`, which holds `wakeMutex` across
  `Window::terminate()` (`engine/client/src/Client.cpp:126-130`); its other side is an unnamed
  Mesa frame, so it may be a reused address. The spike's workflow and probe are on the
  `S11-D1/ci-gl-floor` branch.
- **Measured on Oct 11 with Windows binaries:** a test body takes about 0 ms. A process start
  costs 49 ms in `windows` Debug and 553 ms in `windows-profile`, where Tracy calibrates for
  200 ms before `main`. Each `[window]` case costs about 450 ms in its own process, because the
  first context loads the driver; the 13 cases take 1.6 s in one process and 3.5 s apart. The
  two `... does not depend on recursion depth` cases take 6 s each in Debug, because
  `setParent`'s cycle check makes a 4096-deep chain quadratic.
- **On CI:** `win ASan`'s test step was 173 s for 621 cases on run 38367963268 (Oct 13), against
  13-45 s on every other leg: about 89 s of process starts, 61 s of window and GL cases and 21 s
  for the two recursion-depth cases. It took between 4 min 7 s and 5 min 46 s on each of six
  `master` runs on Nov 5-6. No test preset sets `execution.jobs`, so `ctest` runs one case at a
  time on 4-core runners. Every `ScratchDirectory` name is unique today (checked by grep only).
- **Proposed at S8-D3, not decided:** tiers are Catch2 tags turned into CTest labels
  (`catch_discover_tests(... ADD_TAGS_AS_LABELS)`, which the pinned Catch2 supports); legs
  exclude by label, so a forgotten tag runs more rather than less; every case keeps its own
  process, so the `TE_ENSURE` entry in the [[Backlog]] needs no reset hook; test presets set
  `execution.jobs`; and `[stress]` leaves the sanitizer legs. Functional, visual and perf tiers
  get a shape and a trigger, not wiring.

### Story B: R1's first frame (Miguel writes, Claude pairs)

Order: S11-T2 follows S11-D5, which follows S11-D1 (Story A); S11-T3 follows S11-T2; S11-T4 follows S11-T3 and S11-T5; S11-T6
follows S11-T3; S11-T7 and S11-T8 follow S11-T6; S11-T9 follows S11-T4, S11-T7 and S11-T8.

- [ ] **S11-T2** · GL 4.6 and bindless at startup · P1 · 🟡 Light · 1-2h ·
  done: glad2 is regenerated with `--api gl:core=4.6` and `ARB_bindless_texture`
  (`cmake/deps.cmake:244-246`), the window requests a 4.6 core context
  (`engine/platform/src/window/Window.cpp:58-59`, Miguel, Nov 14), and the startup check
  (`engine/client/src/render/RenderThread.cpp:93`) logs which requirement failed
  ([[Renderer - Design]] § *Build notes*).
- [ ] **S11-T3** · The device · P1 · 🟢 Deep · 4-6h ·
  done: a device in `client` with typed handles for buffers, textures, pipelines and render
  targets, pipelines bound whole and explicit render passes (ADR-028 §1). M4's triangle draws
  through it, `FrameRenderer` makes no GL call, and `Buffer` and `VertexArray` fold into it.
  Storage buffers are in; compute dispatch waits for the light clusters. The device's surface is
  settled at `/card-start`.
- [ ] **S11-T4** · Frame packets replace the snapshot · P1 · 🟢 Deep · 4-6h ·
  done: the extraction hook reads the `Scene` into a pooled packet after ticks and after applied
  edits, and render moves it instead of copying (ADR-028 §3; the copies are listed in
  [[Renderer - Design]] § *References*). The pool holds four packets. A packet carries each
  `MeshRenderer`'s world transform, mesh and slot materials, and the main active camera. Tests:
  simulation never waits with four packets; an edit in the Stopped editor produces a packet. How
  render matches an instance across two packets is this card's open question.
- [ ] **S11-T5** · The camera component · P1 · 🤖 Claude · 2-3h ·
  done: `Camera` in `core` with the fields in [[Renderer - Design]] § *Decided*, registered in
  both apps, shown by the inspector, and one `core` function that returns the main active camera.
  Tests: the first `main` camera in hierarchy order wins; a scene with none returns nothing, and
  the caller warns once. It stops at that function, so it stays off S11-T4's files.
- [ ] **S11-T6** · Ordered uploads and render's fence · P1 · 🟢 Deep · 4-6h ·
  done: mesh, texture and material uploads cross to render in order and are never dropped; render
  reports each upload done, and simulation defers a free until then (ADR-028 §4). A reload keeps
  its handle and sends a new upload, which replaces S10-T21's immediate destroy. Render drops a
  GPU copy by the rule in [[Renderer - Design]] § *Decided*.
- [ ] **S11-T7** · Shared geometry buffers · P1 · 🟢 Deep · 4-6h ·
  done: [[Renderer - Design]] § *Geometry buffers* as written: the three buffers with immutable
  storage, the free-list allocator, a second block when one fills, and defaults for a stream a
  mesh lacks. Tests, headless on the allocator: a freed range is reused, a mesh never moves, and
  a full block adds another.
- [ ] **S11-T8** · The material buffer and bindless textures · P1 · 🟢 Deep · 4-6h ·
  done: textures upload in their file's format with their mips and sampler, and each material
  writes its 96-byte record with bindless handles ([[Renderer - Design]] § *The material
  buffer*). Record 0 is written at startup. This card decides which way a texture is sampled
  (§ *Open questions*).
- [ ] **S11-T9** · The first frame · P1 · 🟢 Deep · 4-6h ·
  done: one forward pass draws the packet with CPU-written multi-draws, one per draw bucket, and
  shades base color times its factor, with cut-outs discarded. The runtime shows Sponza through
  the scene's main camera. Miguel's windowed check and a capture are the proof. The
  mirrored-instance question is this card's; anti-aliasing is not in it.

### Story C: The scene view draws (drops first)

Cut against [[Renderer - Design]] § *Decided*, rows *The scene view is a render target*, *Views*
and *How the scene view's camera is driven*.

- [ ] **S11-T10** · The scene view is a render target · P2 · 🟠 Moderate · 2-3h ·
  done: the editor draws the frame into a texture that the scene view shows, sized to the panel,
  and the game view does the same through the main active camera. A hidden view is not drawn.
  Follows S11-T9.
- [ ] **S11-T11** · The scene view's fly camera · P2 · 🤖 Claude · 2-3h ·
  done: the camera's state and its update from mouse and key deltas live in `edit/` with tests;
  `SceneViewPanel` feeds it from ImGui while the right mouse button is held, and it reaches
  render on ADR-019 §4's latest-value path. The PR ends with "needs Miguel's visual check".
  Follows S11-T10.

### Story D: Design and product

- [ ] **S11-D2** · Triage what a cinematic showcase needs · P2 · 🤖 Claude · 1-2h ·
  done: `/triage` weighs what the engine must provide to record a cinematic showcase, such as
  camera paths and capture at a fixed frame rate, and the [[Capability Map]] records the result
  with the date and "decided by the lane". The run report lists it under *Needs you*, because a
  vault card has no PR to review it in. Was S10-D5; 🤖 Claude by Miguel's exception to the gate
  (Nov 14), since a `/triage` is a product decision. Due before E2's showcase.
- [ ] **S11-D3** · Design the asset browser · P2 · 🟠 Moderate · 2-3h ·
  done: [[Content Pipeline - Design]] decides what the list-only browser shows and how it
  imports, re-imports and places, and whether deleting an asset is weighed now (its [[Backlog]]
  entry fires with this card). It cuts the build cards for Sprint 12. Drops after Story C.

### Story E: The lane's small cards · 🤖 Auto

- [ ] **S11-P1** · The inputs check in `/sprint-prep` · P2 · 🤖 Auto ·
  done: step 3 of `.claude/commands/sprint-prep.md` and [[Planning Workflow - Artifact Gate]] §
  *Where plans come from* gain one check: list everything the goal's showcase sentence consumes,
  and mark each built, carded, decided or undecided, before the goal is proposed. S10-D6's
  § *What E2 still lacks* is its first run.
- [ ] **S11-T12** · The runtime logs entities at Debug · P3 · 🤖 Auto ·
  done: `RuntimeApp::logSceneTree` writes its per-entity lines with `TE_LOGGER_DEBUG` and keeps
  one `INFO` summary line. After S11-T5, which also edits `RuntimeApp.cpp`.
- [ ] **S11-T13** · A split mesh's children are named after their material · P3 · 🤖 Auto ·
  done: a placed model's children of one split mesh take their material's name, with `_1`, `_2`
  on a repeat, and a test places a two-primitive fixture. After S11-T1.
- [ ] **S11-T14** · The base sweep's leftover · P3 · 🤖 Auto ·
  done: the version anchors go: `baseVersion()`, `platformVersion()` and `coreVersion()` with
  `Base.hpp`, `Platform.hpp`, `Core.hpp` and their `.cpp`, and `BaseTests.cpp`, whose glm case
  repeats `MathTests.cpp`. `ctest` proves it. Was S10-T9.
- [ ] **S11-P2** · A README at the repo root · P3 · 🤖 Auto ·
  done: what the engine is, how to clone the vault, and the three preset commands.

### Story F: Prepare Sprint 12 (standing)

- [ ] **S11-P3** · Prep brief for Sprint 12 · P2 · 🤖 Auto · report-only ·
  done: a run report lists the *Decided* rows with no code behind them, the open questions
  blocking them, the fired [[Backlog]] triggers and candidate 🤖 Claude features, and decides
  nothing. **Not before Mon Nov 23**: a fire before that leaves it in To Do.
- [ ] **S11-D4** · Prepare Sprint 12 · P1 · 🟠 Moderate · 2-3h ·
  done: `/sprint-prep` wrote the next sprint's goal and draft cut into this sprint note. Its
  window is Tue Nov 24 to Fri Nov 27, but Thu and Fri are karting days, so it runs on **Tue Nov
  24**, after S11-P3's brief from Monday.

## 🤖 Lanes

- 🤖 Claude features: S11-T5 (the camera), S11-T11 (the fly camera, after S11-T10) and S11-D2
  (vault only). Both build cards are built to Miguel's design in [[Renderer - Design]] §
  *Decided*.
- 🤖 Auto cards: S11-P1, S11-T12, S11-T13, S11-T14 and S11-P2.
- Standing prep: S11-P3 (not before Mon Nov 23) and S11-D4 (Tue Nov 24).
- PR load: seven PR-producing lane cards over two weeks (two 🤖 Claude, five 🤖 Auto), under the
  limit of about five a week. S11-D2 and S11-P3 are free. Review costs about 2.5h.
- **The routine owes a prompt paste** ([[Autonomous Lane - Routine Prompt]] § *Routine
  configuration*): the sweep's outward look-for and step 5's narrowed 🤖 Claude paragraph. Paste
  it before Mon Nov 16, when the lane can first take S11-T5. Fri Nov 13 left no run report;
  check the routine's run list at the same time.

## Definition of Done

- [ ] The runtime shows Sponza, textured with base color, through the scene's main camera, on the
  device, with Miguel's windowed check and a capture (S11-T9).
- [ ] ADR-028's amendment records whether zink gives CI the GL floor (S11-D1), and CI runs each
  test tier where ADR-008's amendment says (S11-D5). S11-D1's half is done: vault `8446176`,
  Nov 14.
- [ ] Sponza was re-imported with its images through *Re-import...*, and its ids were kept
  (S11-T1).
- [ ] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro.
- [ ] Sprint 12's draft cut is in this note (S11-D4).

## Capacity note

Miguel's cards: 7 🟢, 5 🟠 (with S11-D4) and 1 🟡, about 10 slots. He chose to commit all of them.
S11-D5 was added on Nov 14 at S11-D1's `/card-start`, and it is the seventh 🟢.

- **The sprint's work days are Nov 14 to Nov 24.** Sat Nov 14 is a deep day after planning. Mon
  Nov 16 and Thu Nov 19 are evenings. Fri Nov 20 (a day off work), Sat Nov 21 and Sun Nov 22 are
  full days. Thu Nov 26 and Fri Nov 27 are karting days, and the Nov 28-29 weekend is a vacation.
- **That is about 10-12 🟢 slots if all three days of Nov 20-22 are worked**, and 8-9 if one of
  them is kept free, which the Rhythm table's guardrail asks for. The plan fits either way only
  because 🟠 cards take half a full day.
- **Drop order:** S11-T10 and S11-T11, then S11-D3. S11-T9 does not drop; if it slips, it opens
  Sprint 12.
- **Suggested order:** Nov 14, S11-D1 and S11-D5. Nov 16, S11-T2 and S11-T1. Nov 19, S11-T3.
  Nov 20, S11-T6 and S11-T4. Nov 21, S11-T7 and S11-T8. Nov 22, S11-T9. Nov 23, Story C and
  S11-D3, or slack. Nov 24, S11-D4.
- **S11-D5 costs the free day.** The R1 chain now fills all three days of Nov 20-22, so the
  Rhythm table's free day among them comes back only by dropping Story C and S11-D3.
- **S11-T4 needs the lane's S11-T5 merged first**, so that PR is reviewed by Thu Nov 19.
- **Lane review has one 🟡 evening, Tue Nov 17.** Tue Nov 24 belongs to S11-D4, so PRs opened
  after Nov 17 are reviewed inside the Nov 20-22 block.
- **Sprint 12's boundary falls on the vacation weekend.** If `/sprint-plan` cannot run on Nov
  28-29, it falls back to Mon Nov 30.

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
