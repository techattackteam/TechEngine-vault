# 2026-11 · Sprint 12: Renderer Groundwork

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Nov 28 - Friday Dec 11, 2026.
- **Epic:** E2 · First renderer, the second of about four sprints ([[Roadmap]]). Hubs:
  [[Renderer - Design]] and [[Editor - Design]].

## Sprint goal

Renderer groundwork. The engine's shaders load from engine asset files and reload on command, the
light components exist, the scene view draws a visualizer for every camera and light and moves the
selection with a gizmo, and each view can switch to a debug view mode. Nothing is lit yet.

Drafted by S11-D4's `/sprint-prep` on Nov 24 ([[2026-11 Sprint 11 - First Frame]] § *Sprint 12's
cut*, which also records why the lit pass moved to Sprint 13) and fitted on Nov 27
([[2026-11-27 Sprint 11 Retrospective]]). All 17 drafts survived unchanged. Miguel added S12-D4
and S12-D5 from fired [[Backlog]] entries, and the fit added S12-P2.

## Artifact gate

- The visualizers, the light components, the view modes and shader reload are rows in
  [[Renderer - Design]] § *Decided*, and the gizmo is a row in [[Editor - Design]] § *Decided*,
  all dated Nov 24.
- **First Design cards:** S12-D1, then S12-D2, on the first work day (Tue Dec 1). Story B stays
  roughly sized until S12-D2.
- **Briefs:** [[Renderer - Brief]] and [[Editor - Brief]] exist, so no `/brief` is owed.
- **Showcase:** none, because E2 does not end here. `/showcase E2` is owed before the sprint that
  ends it; S11-D2 fed it on Nov 27 with rung T9, camera paths.
- [[Known Issues]]: D9, D11, D12 and D13 neither block nor touch these cards.
- **Fired [[Backlog]] entries not taken**, at Miguel's call (Nov 27): *Export refuses a reference
  that no file holds* and *Cancel an import*.

## Stories & tasks

### Story A: Day 1 (Miguel)

- [ ] **S12-D1** · Triage the renderer's debug tools · P1 · 🟡 Light · 1-2h ·
  done: `/triage` weighs the visualizers, the view modes with the light-count heat map, and whether
  a shipped game keeps the view modes. The [[Capability Map]] records the result with the date.
  Before S12-T7 and S12-T8.
- [ ] **S12-D2** · Engine assets and the renderer's settings asset · P1 · 🟢 Deep · 4-6h ·
  done: [[Project - Design]] and [[Resources - Design]] decide how the editor's `<exe dir>/engine`
  folder is filled from the repository, how an engine asset gets its id and enters the asset index
  so the bake packs what a settings asset reaches, whether the browser shows engine assets, and
  where the project names the renderer's settings asset (Resources - Design § *Open questions*).
  Unreal, Unity and Godot are the baseline. The card confirms or replaces the Oct 10 home (Project
  - Design § *Why no template tree*, `apps/editor/src/EditorApp.cpp:78`). On Nov 24 Miguel floated
  the project's own `engine/` folder or a `resources/` folder at its root; either one brings back
  v1's F27 unless the comparison answers it. The card narrows Project - Design's row *Shaders live
  in `assets/client/`* to developers' own shaders. A change to the bake amends ADR-025 §6. It cuts
  Story B.

### Story B: The engine's shaders are files (Miguel, rough until S12-D2)

- [ ] **S12-T1** · The forward shader leaves the code · P1 · 🟢 Deep · 4-6h ·
  done: the GLSL in `engine/client/src/render/FrameRenderer.cpp` moves into engine shader files that
  the renderer's settings asset names, render builds its programs from them, and no GLSL is left in
  `client`'s sources. How much of ADR-029 §5's assembly lands now is settled at `/card-start`. The
  unused `projects/dev/assets/client/shaders/GeometryShader.vert` and `.frag` are deleted. After
  S12-D2.
- [ ] **S12-T2** · Reload shaders · P2 · 🟠 Moderate · 2-3h ·
  done: the editor's *Reload shaders* command rebuilds every program from its files. A program that
  fails to compile keeps the old one and logs the error. After S12-T1.

### Story C: Lights as data

- [ ] **S12-T3** · The light components · P1 · 🤖 Claude · 2-3h ·
  done: the three light components in [[Renderer - Design]] § *Decided*, in `core`, with values in
  ADR-029 §6's units, registered in both apps and shown in the inspector. Their fields are the
  card's decisions, listed in the PR. Tests: each component round-trips through the scene file.
- [ ] **S12-T4** · Every light and camera in the packet · P1 · 🟠 Moderate · 2-3h ·
  done: extraction writes every light with its world transform, and every `Camera`, into the
  packet, by the row *How visualizers reach render*. The main camera is found as it is today.
  Render receives them and draws nothing new. Tests: a packet holds each light and camera of its
  scene. After S12-T3.
- [ ] **S12-T5** · Inspector field hints · P2 · 🟠 Moderate · 2-3h ·
  done: [[Serialization - Design]] decides how a field carries a range, a speed and a display name,
  the inspector reads them, and a drawer registry replaces `drawComponent`'s `if` chain. The
  lights' fields get their ranges. After S12-T3. *From the Backlog: a generic field has no range,
  speed or display name, and hints are an optional argument to `visit`'s `field` that the other
  archives ignore.*

### Story D: Seeing what the renderer does (Miguel)

- [ ] **S12-T6** · The shape pass · P1 · 🟢 Deep · 4-6h ·
  done: a pass in `client` draws lines that the CPU writes each frame into their own buffer, over
  the frame, in each view whose record asks for it. The scene view's record asks. Miguel's windowed
  check. After S12-T4.
- [ ] **S12-T7** · Camera and light visualizers · P1 · 🤖 Claude · 2-3h ·
  done: every camera's frustum, every point light's reach, every spot light's cone and the sun's
  direction, drawn through S12-T6's pass, with the selection brighter. How render learns the
  selection is the card's decision. The PR ends with "needs Miguel's visual check". **Not before
  S12-D1 and S12-T6 are in Done**: a fire before that leaves it in To Do.
- [ ] **S12-T8** · View modes · P2 · 🟠 Moderate · 2-3h ·
  done: each view's record names a view mode. Render draws at least lit (base color until the lit
  pass), unlit, wireframe and normals. The scene view picks one from its toolbar, and the runtime
  gets whatever switch S12-D1 decides. After S12-D1 and S12-T1.

### Story E: The gizmo (Miguel, T3)

- [ ] **S12-T9** · ImGuizmo moves the selection · P1 · 🟢 Deep · 4-6h ·
  done: ImGuizmo is pinned in `cmake/deps.cmake`, and the scene view draws it over the selected
  entity to move, rotate and scale it, in local or world space, by [[Editor - Design]] § *Decided*.
  A child's drag writes its local transform. How a drag becomes undo steps is settled at
  `/card-start`. Miguel's windowed check.
- [ ] **S12-T10** · A shortcut system · P2 · 🟠 Moderate · 2-3h ·
  done: the lean below becomes a row in [[Editor - Design]], each panel declares its shortcuts as
  data, and W, E and R switch the gizmo's modes through it, with Ctrl+S, Delete, F2 and F moved onto
  it. After S12-T9. *From the Backlog (lean, Nov 21): each panel declares its shortcuts as data
  (chord, scope, action) the way it declares style vars, and `Panel::draw` runs them through
  `ImGui::Shortcut`, with three scopes: focused, hovered or focused, and global.*

### Story F: Editor refinement

- [ ] **S12-T11** · The editor scales with the display · P3 · 🟠 Moderate · 2-3h ·
  done: the editor draws ImGui's vector font (`AddFontDefaultVector()`) and scales its style and
  font by the window's content scale, after `startClient()`, so a 150% display shows panels at
  their intended size. A real typeface waits for S12-D2's engine assets. *From the Backlog.*

### Story G: Two designs from the Backlog (added at the fit, Miguel's call)

- [ ] **S12-D4** · The null render device · P2 · 🟠 Moderate · 2-3h ·
  done: [[Renderer - Design]] decides the shape of a device that needs no GL context, with Godot's
  mock rendering server and Unreal's NullRHI as the baseline, and says whether ADR-028 needs an
  amendment. It lists which of the 47 `[gpu]` cases that open a window only because the client
  needs a context (39 app lifecycle cases, 8 render thread and client cases, [[B3 - Build & Testing
  Notes]] § *Test tiers*) leave `[gpu]`, and cuts the build cards for Sprint 13.
- [ ] **S12-D5** · How a create shows its progress · P3 · 🟠 Moderate · 2-3h ·
  done: [[Content Pipeline - Design]] decides how a model or mesh create reports what it reads and
  writes to main (the channel, the steps, one window for several creates), and cuts the build
  cards. The fired Backlog entry *Cancel an import* uses the same assimp `ProgressHandler`; the
  card says whether it joins the build.

### Story H: The lane's cards · 🤖 Auto

- [ ] **S12-P1** · Research clustered forward shading · P2 · 🤖 Auto · report-only ·
  done: a report in `05 Research/` from Olsson et al. 2012 ([[Paper]]) to current practice: the
  grid, depth slicing, light assignment in compute and the light-count heat map, read against v1's
  `engine/client/src/renderer/passes/LightCullingPass.cpp` at `v1-reference`. It decides nothing;
  it feeds E2b's light clusters.
- [ ] **S12-T12** · `logs/` is git-ignored · P3 · 🤖 Auto ·
  done: `.gitignore` lists `logs/`, and `logs/techengine.log` leaves the index. *From the Backlog:
  the logger writes it relative to the working directory (`engine/base/src/diagnostics/Log.cpp:28`),
  and #222 merged one line of it.*
- [ ] **S12-P2** · The prep check runs after the prep · P2 · 🤖 Auto ·
  done: `.claude/commands/sprint-prep.md` loses gate 3 and step 1's start from the brief, and its
  grooming step says a sprint takes at least one [[Backlog]] entry, ideally two or three.
  `.claude/commands/sprint-plan.md` step 1 reads the prep check's report, and step 6 plants
  `Check Sprint <n+1>'s cut` to wait for the prep card. The vault half landed on Nov 27
  ([[Planning Workflow - Artifact Gate]] § *Decide first, then plan*, [[Dashboard]] § *Rhythm*,
  [[Autonomous Lane - Routine Prompt]] step 4). Must merge before S12-D3.

### Story I: Prepare Sprint 13 (standing)

- [ ] **S12-D3** · Prepare Sprint 13 · P1 · 🟠 Moderate · 2-3h ·
  done: `/sprint-prep` wrote Sprint 13's goal and draft cut into this sprint note, and the cut holds
  a Design card for T9, camera paths, which settles how playback starts and whether keys are child
  entities ([[Capability Map]] § *Cinematics*). It runs in week 2, Tuesday to Thursday, so a weekday
  fire follows it: planned for **Tue Dec 8**, a holiday.
- [ ] **S12-P3** · Check Sprint 13's cut · P2 · 🤖 Auto · report-only ·
  done: a run report reads Sprint 13's cut in this note against the design notes, the code, the
  [[Backlog]] and [[Known Issues]], and lists what the cut missed: *Decided* rows the goal consumes
  with no card, open questions that block a card, fired Backlog entries the cut neither took nor
  declined, Known Issues that touch a card, `done:` clauses with no referent, and candidate
  🤖 Claude features. It decides nothing. **Not before S12-D3 is in Done**: a fire before that
  leaves it in To Do.

**Order:** S12-D1 before S12-T7 and S12-T8. S12-D2 → S12-T1 → S12-T2, and S12-T1 before S12-T8.
S12-T3 → S12-T4 → S12-T6 → S12-T7, and S12-T3 before S12-T5. S12-T9 → S12-T10. S12-P2 → S12-D3
→ S12-P3.

## 🤖 Lanes

- 🤖 Claude features: S12-T3 (the light components) and S12-T7 (the visualizers, after S12-D1 and
  S12-T6). Both are built to Miguel's rows in [[Renderer - Design]] § *Decided*.
- 🤖 Auto cards: S12-P1 (report-only), S12-T12 and S12-P2.
- Standing prep: S12-D3 (Tue Dec 8), then S12-P3 (after S12-D3).
- PR load: four PR-producing lane cards over two weeks (two 🤖 Claude, two 🤖 Auto), under the
  limit of about five a week. Sweeps fill the free fires. Review costs about 2h.
- **Lane status:** enabled. It owes a paste: the bolt-on look-fors from Nov 17 and Nov 23, and
  step 4's card-wait line from Nov 27 ([[Autonomous Lane - Routine Prompt]] § *Routine
  configuration*). Until the paste, S12-T7 and S12-P3 rely on their own text to wait.

## Definition of Done

- [ ] The runtime and the editor draw with programs built from engine shader files, and no GLSL is
  left in `client`'s sources (S12-T1).
- [ ] The scene view draws every camera's and light's visualizer and moves the selection with the
  gizmo, with Miguel's windowed check (S12-T7, S12-T9).
- [ ] Each view switches to at least unlit, wireframe and normals (S12-T8).
- [ ] Every 🤖 Claude PR's *Decisions I took* list is accepted or reversed, and the reversals are
  counted for the retro.
- [ ] Sprint 13's draft cut is in this note (S12-D3), and S12-P3's check has run on it.

## Capacity note

Miguel's cards: 4 🟢, 9 🟠 and 1 🟡, about 9 slots, against about 10.

- **The first four days are lost.** Sat Nov 28 and Sun Nov 29 are away, and Mon Nov 30 is a
  karting day. The first work day is **Tue Dec 1**, a holiday.
- **Two holiday Tuesdays are full days** (Dec 1 and Dec 8), and so is one of Dec 5-6, which also
  holds the weekly review. The evenings are Thu Dec 3, Mon Dec 7 and Thu Dec 10, and the Fridays
  Dec 4 and Dec 11 take a 🟠 each. Working from home four days a week still holds (Nov 27), so
  these slots are a floor.
- **Drop order:** S12-T11, then S12-T10, then S12-D5, then S12-T8.
- **Story B is rough until S12-D2.** If S12-D2 finds more work, it takes the slack first.
- **The lane's S12-T3 should merge by Thu Dec 3**, because S12-T4 follows it. The Monday Nov 30
  fire takes it, so review it on Tue Dec 1.
- **Suggested order:** Dec 1, S12-D1, S12-D2 and the review of S12-T3. Dec 3, S12-T1. Dec 4,
  S12-T4. Dec 5 or 6, S12-T6 and S12-T9. Dec 7, S12-T2 or S12-T5. Dec 8, S12-D3 and S12-D4. Dec 10
  and 11, S12-T8, S12-T10 and whatever is left.

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
