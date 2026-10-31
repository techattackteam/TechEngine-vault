# 🗺️ Roadmap

**The order, not the dates.** Sprints execute it ([[Sprint Board]]); the quarter notes and
sprint notes own the dates. `/sprint-prep` reads this page to pick the next goal. What each
system must support is in the [[Capability Map]], derived from the [[Reference Game]].

**Where we are:** the foundation chain (M0 to M5) is done, and M6, content, closes in
[[2026-10 Sprint 09 - Close M6]] (Oct 24 to Nov 6), which also makes E1's first decisions.
Then Phase 1 starts: engine goals E1 to E13, about a month each, each ending in a showcase video
([[Channel]]). Phase 2 is the game itself, TechAttack.

## Phase 1: the engine, one showcase a month

Each goal is sized to about two sprints and is done when its showcase is out. **Needs** is the
critical path; **Alongside** can run at the same time without blocking it, and is the natural
source of 🤖 Claude features. **Map** names the [[Capability Map]] section whose deeper brief
must exist before the goal's first ADR.

| Goal | The showcase shows | Needs | Alongside | Map |
|---|---|---|---|---|
| **M6 · Content** 🔨 now | (no video) The runtime loads scenes and meshes from packs, with references | Sprint 09's Story A and the mesh path (🤖 Claude) | The editor brief and ADR | |
| **E1 · Editor and export** | Build a scene of named entities in the editor (hierarchy, inspector, a simple scene view), export it, and run it in the runtime | T1 · T2 | The renderer brief and ADR | Editor |
| **E2 · First renderer** | Imported models with physically based materials, in the runtime and the editor's scene view | R1, after the **two renderer ADRs** | T4 import · T3 viewport tools | Renderer, content pipeline |
| **E3 · Sky and light** | A physically based sky, a moving sun, day and night, dynamic sun shadows | R2 · R3 | | Renderer |
| **E4 · Fog and god rays** | Volumetric fog and light shafts | R4 | The terrain brief and ADR | Renderer |
| **E5 · Voxel terrain** | Editable voxel terrain, dig and place, smooth or blocky, voxel size per world | W1, after the **terrain ADR** | P1 parallel executor | World and terrain |
| **E6 · Endless world** | A generated world with biomes and ores, streaming about 1 km around the viewer | W2 · the precision check ([[Reference Game]] § *Decided*) | T7 terrain tools | World and terrain |
| **E7 · Water and trees** | Static water with reflections; trees and rocks across the biomes | R6 · R7 · W5 | | Renderer, world and terrain |
| **E8 · Global illumination** | Bounced light that follows terrain edits and the day and night cycle | R5 | | Renderer |
| **E9 · Walk it** | A first-person character on the terrain, among rigid bodies | S1 · S2 | C2 audio | Physics, audio |
| **E10 · Together** | 2 to 8 clients on a Windows dedicated server, moving with prediction | N1, after the **transport ADR** · N2 · N3 · N4 | | Networking |
| **E11 · Scripted** | A game rule written as a user script and hot-reloaded | A1, after **accepting ADR-010** and the **scripting ADR** | T6 play in the editor · surface shaders in code ([[Renderer - Brief]], 2026-10-30) | Authoring |
| **E12 · Game UI** | A HUD, menus and an inventory, built in code and in the visual designer | A2, after **its own ADR** | | Game UI |
| **E13 · Saving** | The server autosaves and reloads the world, its edits, machines and inventories | W4 | | Persistence |

E10 is the goal most likely to need splitting: four networking rungs in one month is a lot. At
one goal a month, Phase 1 runs about thirteen months after M6.

## Phase 2: TechAttack

The game starts after E13, on a complete core, with one devlog per stage: **G1** gather, craft
and build · **G2** automate · **G3** survive · **Demo**, free to download. The stages and what
each one adds live in [[Reference Game]] § *Two phases*.

## Rung catalogue

The work items the goals are built from. The codes stay because cards, ADRs and design notes
cite them. Order **within** a lane is real.

| Rung | Contents | Needs | Goal |
|---|---|---|---|
| 🔧 **T1** · Editor panels | Dock · hierarchy · inspector · console and cvars · Profiler panel · scene save · multi-select and editing several entities (a Should, 2026-10-31) | M6. ImGui only. | E1 |
| 🔧 **T2** · Export | The editor's export command over M6's bake. Save is T1's (2026-10-26). | T1 · M6 | E1 |
| 🔧 **T3** · Viewport tools | Picking (F21) and gizmos in the scene view | R1 | E2, alongside |
| 🔧 **T4** · Import and asset browser | glTF loaded through assimp, writing runtime-form files that M6's bake packs (ADR-025 §6) · an asset browser | T1 · M6 | E2, alongside |
| 🔧 **T5** · Packaging | Distributable build · launcher arguments · no dev dependencies | T2 · T4 | Demo |
| 🔧 **T6** · Play in the editor | Run the game inside the editor and return to the edited state | T1 · A1 | E11, alongside |
| 🔧 **T7** · Terrain tools | Sculpt and paint voxel terrain, and set up generation, in the editor | W1 · T3 | E6, alongside |
| 🎨 **R1** · Renderer v0 | Device seam (F22) · meshes, shaders and physically based materials · camera · frustum culling | M6 · **two renderer ADRs** (2026-10-30, S9-D4): the frame and device seam, with lights and culling, which also decides whether a per-frame allocator is owed; and materials and shading models | E2 |
| 🎨 **R2** · Render graph and lighting | Passes · lights and shadows · depth prepass · post (auto-exposure, bloom) · GPU zones per pass | R1 | E3 |
| 🎨 **R3** · Sky and sun | Physically based atmosphere · a moving sun · day and night | R2 | E3 |
| 🎨 **R4** · Volumetric fog | Volumetric fog · god rays | R3 | E4 |
| 🎨 **R5** · Global illumination | Bounced light on a world that changes | R2 · W1 | E8 |
| 🎨 **R6** · Water | Static water with reflections and a shoreline | R2 | E7 |
| 🎨 **R7** · Foliage rendering | Trees and rocks drawn in large numbers out to the view distance | R1 · W2 | E7 |
| 🌍 **W1** · Voxel terrain | Voxel data · smooth and blocky meshing · colliders · dig and place · voxel size per world | R1 · **terrain ADR** | E5 |
| 🌍 **W2** · Endless world | Procedural generation with biomes and ores · chunk streaming and terrain LOD around the viewer | W1 | E6 |
| 🌍 **W3** · Static terrain | Heightmap terrain that cannot be edited, with grid building | R1 | After the demo |
| 🌍 **W4** · Persistence | The server autosaves and loads the world, its edits, machines and players | W1 · N2 | E13 |
| 🌍 **W5** · Vegetation placement | Trees and rocks placed by the generator, per biome | W2 | E7 |
| 🎮 **S1** · Physics | Jolt, authoritative, in the fixed phase · rigid bodies | Nothing left | E9 |
| 🎮 **S2** · Character controller | First-person movement on voxel terrain | S1 · W1 | E9 |
| 🌐 **N1** · Transport | ENet, GNS or yojimbo · connect by address · reliable and unreliable channels | **Transport ADR** | E10 |
| 🌐 **N2** · Replication slice | Two processes, one replicated `Transform` | N1 | E10 |
| 🌐 **N3** · Snapshots and deltas | Real encoder · dirty sets · per-component byte counters | N2 | E10 |
| 🌐 **N4** · Prediction | Client prediction · rollback · server correction | N3 | E10 |
| 🌐 **N5** · Interest management | Relevance sets over the streamed world | N3 · W2 | G3 |
| ✍️ **A1** · Scripting SDK | C++ Systems and Scripts over the SDK · game-DLL load and hot reload · soft references and mid-run loads (ADR-024 §5) | M6 · [[ADR-010 - User authoring model (Systems & Scripts)]] accepted + **scripting ADR** | E11 |
| ✍️ **A2** · Game UI | 2D pass · font and text · layout · input routing · a code API and a visual designer in the editor | R1 · **its own ADR** | E12 |
| ⚡ **P1** · Parallel executor | `publish` opened to workers · levels running concurrently · TSan leg green | Nothing left | E5, alongside |
| ⚡ **P2** · Job-system tuning | Work stealing · Jolt pool integration (F15) | P1 and a measurement | G2 |
| 🎞️ **C1** · Animation and skinning | Skeleton and clip assets · a sampling System · GPU skinning | T4 · R1 | G3 |
| 🎞️ **C2** · Audio | miniaudio · 3D sound effects · music · a basic reverb | Nothing | E9, alongside |

## Guardrails

- **R1 goes behind ADR-005's device seam (F22)**, or R2 is a rewrite instead of a wrapper. That
  rule is the whole reason splitting the renderer is safe.
- **A2 is not ImGui.** ImGui is an editor dependency ([[ADR-006 - v2 core architecture & module layout]]
  §1). Game UI is shipped, skinnable and script-driven, needs its own ADR (retained or
  immediate, layout, styling, input routing), and drags in a font rasterizer, which moves `stb`
  from editor-only to shared.
- **A goal is about a month: split it, never stretch it.** The first half gets the showcase.
- **Alongside work never blocks its goal.** If an alongside rung turns out to be needed, it
  moves to *Needs* and the order is reviewed, not silently stretched.

## Why this order

- **The product decides (2026-10-23).** The [[Capability Map]] sets what each system supports,
  and the [[Channel]] sets the rhythm: one showcase a month.
- **Editor first, then the renderer.** E1 is the work already understood; E2 is the first
  renderer, and every later showcase builds on it.
- **Look before world.** Sky, light and fog (E3, E4) work on any scene, so they come before the
  voxel world exists.
- **Global illumination after the world.** Bounced light has to follow terrain that players
  dig and place, so its approach is chosen against the real voxel world (E8), not a static one.
- **Walking, then networking, then gameplay systems.** Scripting, UI and saving are written
  server-authoritative from the start ([[ADR-007 - v2 networking & ECS replication foundation]]),
  and the game starts on a complete core.
- **The chain went first because later code is written against it.** Threading and GL context
  ownership, the serialization seam, paths, profiler zones and the System interface were cheap
  to decide early and a sweep across twenty written systems later.
- **Concurrency is turned on at P1, alongside the voxel terrain.** Chunk meshing is the first
  real parallel load, so races surface there, across a handful of systems rather than thirty.

## Done: the foundation chain

| Rung | What shipped | Closed |
|---|---|---|
| **M0** · Base | Logger · Assert · Clock · headless fixed-timestep loop ([[ADR-011 - Diagnostics (Logger & Assert)]]) | Jul 30, [[2026-08 Sprint 02 - Base Foundation]] |
| **M1** · Enablers | Math · file access · Events and `StringId` · Profiler hooks and memory tracking ([[ADR-013 - Profiler (Tracy-backed instrumentation)]], [[ADR-014 - Events (buffered streams) & StringId]]). The deterministic RNG and the crash handler were deferred and are not built. | Aug 20, [[2026-08 Sprint 03 - M1 Enablers]] |
| **M2** · Concurrency and serialization | Thread topology and GL ownership · a four-worker pool · binary serialization and the trait seam ([[ADR-015 - Threading (sim on main, render thread owns GL)]], [[ADR-016 - Serialization (binary primitives & describe-once seam)]]) | Aug 30, [[2026-08 Sprint 04 - M2 Concurrency & Serialization]] |
| **M3** · Project | `project.toml` with toml++, holding only the name · mount resolution · `FileAccess`'s mutating half · the `projects/dev/` testbed ([[Project - Design]] § *The manifest*) | Sep 12, [[2026-08 Sprint 05 - M3 Project & M4 Window]] |
| **M4** · Window | GLFW window · GL 4.5 context on its owning thread · raw input · clear and triangle | Sep 12, [[2026-08 Sprint 05 - M3 Project & M4 Window]] |
| **M5** · Scene and scheduling | Slot maps · `Scene` and ECS · `Schedule` and executor · command buffer · transform hierarchy · event and input delivery ([[ADR-020 - System scheduling and task-graph execution]]) | Oct 9, [[2026-09 Sprint 06 - Scene & Scheduling]] and [[2026-09 Sprint 07 - Scene Events and Input Boundary]] |

## Deliberately absent

Recorded so they read as decisions, not oversights: particles · mesh LOD (terrain LOD is W2) ·
localization · platforms beyond Windows and Linux. Terrain, streaming, saving and AI left this
list on 2026-10-23, when TechAttack became the reference game.

## Quarters

- **2026 Q3 (Jul-Sep)**: *Foundation and Direction* → [[2026-Q3]]
- **2026 Q4 (Oct-Dec)**: *Close the Chain, Open the Lanes* → [[2026-Q4]]
- **2027 Q1 and beyond**: a theme is written at the planning session that opens the quarter,
  never earlier. A quarter gets a direction, not a feature list.
