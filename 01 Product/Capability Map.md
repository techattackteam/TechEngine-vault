# 🧩 Capability Map

What each engine system must support, at product level: for whom, by which showcase, by the
TechAttack demo, and what is left out. It is derived from the [[Reference Game]] and feeds the
[[Roadmap]]. It never says *how*: that belongs to each system's ADR and design note. A deeper
brief for one system is written only when its goal comes next, from
[[Capability Brief Template]], into `01 Product/Capabilities/`, and linked from its section here. Decided 2026-10-23 with Miguel as
product owner, unless a row says otherwise.

## Targets every system shares

| Target | Value |
|---|---|
| Platform | Windows, for the client and the dedicated server ([[ADR-005 - v2 tech stack & toolchain]]) |
| Hardware | A mid-range gaming PC a few years old, with a 6 to 8 GB GPU |
| Performance | 60 fps at 1080p on that hardware |
| Look | Realistic and physically based |
| Camera | First person |
| Players | 16 to 32 per server in the demo |

## Editor

**For:** developers building a game. **Goals:** E1; import alongside E2, terrain tools alongside E6, play in the editor alongside E11. **Brief:** [[Editor - Brief]].

| | |
|---|---|
| **E1, internal demo** | No public video (2026-10-25; P4 is owed to `/product-review`). A hierarchy that shows each entity's name, an inspector that edits fields and renames entities, and a placeholder scene view; build a scene, save it, export it, and start the runtime by hand. Entity names were added on 2026-10-26 by `/triage`. |
| **Demo** | Edit scenes · play in the editor and return to the edited state · terrain tools (sculpt, paint, generation settings) · an asset browser with import · a visual game UI designer (§ *Game UI*). |
| **Later** | After R1: undo, more than one scene, and reopening the last one · a project launcher, with T5 packaging. |

## Renderer

**For:** players see the world; developers author materials and lights. **Goals:** E2, E3, E4, E7, E8; surface shaders alongside E11. **Brief:** [[Renderer - Brief]].

| | |
|---|---|
| **Showcase (E2)** | Imported glTF reference models (Sponza, Bistro) with physically based materials, seen through a camera, identical in the runtime and the editor's scene view. Each mesh slot has a material on the engine's standard material, with no shader code (2026-10-30, `/triage`), edited live in the inspector. Lit by a sun, a sky image and hundreds of local lights, with no shadows; correct brightness, smooth edges and cut-out surfaces; a stress scene of hundreds of thousands of copies of the reference models (2026-10-30, `/brief`). |
| **Showcase (E3)** | A physically based sky, a moving sun, day and night, and dynamic sun shadows. |
| **Showcase (E4)** | Volumetric fog and god rays. |
| **Showcase (E7)** | Static water with reflections, and trees and rocks drawn out to the view distance. |
| **Showcase (E8)** | Global illumination: bounced light that follows terrain edits and the day and night cycle. |
| **Demo** | A view of about 1 km over voxel terrain · hundreds of local lights at night · volumetric fog and god rays · global illumination (bounced light) · static water with reflections · each material picks a shading model from a set the engine provides: lit, unlit, and glTF's clear coat, sheen and transmission from E2, more later, such as subsurface and foliage (2026-10-30, `/triage` and `/brief`) · developers write surface shaders in code alongside E11, and a Script can set a material's values; the engine still lights them, and a shader keeps working when the engine adds lighting features or the frame is replaced (2026-10-30, `/brief`). |
| **Numbers** | 60 fps at 1080p on the target hardware, with all of the above on screen. In E2, Sponza and Bistro each hold it with hundreds of local lights, and so do hundreds of thousands of objects (2026-10-30, `/brief`). |
| **Later** | After the demo: a node-graph material editor (2026-10-30, `/brief`) · developers add their own passes to the engine's frame · developers replace the whole frame and still draw through the engine's device seam (2026-10-30, `/triage`). |
| **Not in the demo** | Lighting written by developers: a stylized look uses an unlit material and custom passes instead · replacing the device layer, because the engine's render thread owns the graphics context ([[ADR-018 - Main and simulation threads, render-owned GL]]) (2026-10-30, `/triage`) · ray tracing · VR · HDR displays · low-end PCs and mobile (2026-10-30, `/brief`). |
| **Open, for `/product-review`** | Whether the engine's first release gets a renderer beyond what TechAttack needs: powerful enough to stand out among indie engines (for example Godot 4, Flax, Bevy and Stride), without competing with Unreal or Unity (Miguel, 2026-10-30). That changes P1, so it is owed to the review of Nov 7-8, which also says what the engine's first release is. It may move the *Later* row up, and bring particles and mesh LOD back from the [[Roadmap]]'s *Deliberately absent*. [[Renderer - Brief]] § *Open questions* lists what else waits on it. |

## World and terrain

**For:** players live in it; developers generate and shape it. **Goals:** E5, E6, E7.

| | |
|---|---|
| **Showcase (E5)** | Editable voxel terrain: **dig and place**, smooth or blocky per world, with the **voxel size set per world in the editor** (1 m by default, from 25 cm to 2 m). |
| **Showcase (E6)** | An unbounded, generated world with biomes and ores, streaming around the viewer about 1 km out, with terrain detail dropping off with distance. |
| **Showcase (E7)** | Static water (lakes and oceans), and **trees and rocks** placed across the biomes. |
| **Demo** | All of the above; players dig and place terrain, and gather ores, wood and stone. |
| **Later** | Static heightmap terrain with grid building, for general-purpose users (W3). |
| **Not in the demo** | Caves and overhangs · grass and bushes · generated structures · flowing water. |

## Physics

**For:** players move and things fall. **Goals:** E9.

| | |
|---|---|
| **Showcase (E9)** | A first-person character walking, jumping and falling on voxel terrain, among rigid bodies. |
| **Demo** | The character, plus rigid bodies: dropped items, crates and debris that tumble and stack. The server is authoritative. |
| **Not in the demo** | Structural collapse · vehicles. |

## Networking

**For:** players play together; developers write multiplayer games without extra work.
**Goals:** E10, then 16 to 32 players in G3.

| | |
|---|---|
| **Showcase (E10)** | 2 to 8 clients on a Windows dedicated server, moving with prediction. |
| **Demo** | 16 to 32 players · the demo ships the dedicated server program, which players run themselves · clients **connect by address** · server authority is the only anti-cheat. |
| **Not in the demo** | A server browser · LAN discovery · official servers · cheat detection beyond server authority. |

## Authoring and scripting

**For:** developers writing gameplay. **Goals:** E11.

| | |
|---|---|
| **Showcase (E11)** | A game rule written as a user script and hot-reloaded. |
| **Demo** | Gameplay in **C++ through the SDK, with hot reload**, in two tiers: data-oriented **Systems** for bulk work and per-entity **Scripts** for one-off behaviour. This is [[ADR-010 - User authoring model (Systems & Scripts)]]'s draft, still Proposed, so accepting it is owed before E11. |
| **Later** | A second, easier language (C# or Lua), **decided after the demo** from what the channel's viewers ask for. |

## Game UI

**For:** players see HUDs, menus and inventories; developers build them. **Goals:** E12.

| | |
|---|---|
| **Showcase (E12)** | A HUD, menus and an inventory, built in code and in the visual designer. |
| **Demo** | **Both** a code API through the SDK **and** a visual UI designer in the editor. Game UI is not ImGui ([[Roadmap]] § *Guardrails*). |

## Persistence

**For:** players keep their progress. **Goals:** E13.

| | |
|---|---|
| **Showcase (E13)** | The server autosaves and reloads everything. |
| **Demo** | **Everything survives a restart**: terrain edits, buildings, machines and player inventories, autosaved every few minutes and on shutdown. Saves live on the server only. |

## Audio

**For:** players hear the world. **Goals:** alongside E9.

| | |
|---|---|
| **Demo** | 3D sound effects positioned in the world · music · a really basic environment (simple reverb). |
| **Not in the demo** | Proximity voice chat · sound occlusion. |

## Content pipeline

**For:** developers bring art in and ship it out. **Goals:** E1 for export, alongside E2 for import.

| | |
|---|---|
| **Demo** | Import **glTF**, loaded through assimp · textures · export to content packs (M6) · a packaged demo build. |
| **Not in the demo** | FBX and other formats as supported inputs, even where assimp can read them. |

## Phase 2 systems, mapped later

Automation simulation (thousands of machines, G2), creature AI and animation (G3) and combat
(G3) get their sections when Phase 2 nears.

## Decided at the open-questions round

| Question | Answer | Date |
|---|---|---|
| Where GI and volumetric fog go | Each gets its own showcase month | 2026-10-23 |
| How the first big goal splits | Editor and export first (E1), then the first renderer (E2) | 2026-10-23 |
| How the UI and saving goal splits | Game UI one month (E12), saving another (E13) | 2026-10-23 |
| Voxel size | 1 m by default; the editor allows 25 cm to 2 m | 2026-10-23 |
| Terrain edits | Players dig and place | 2026-10-23 |
| Vegetation | Trees and rocks are in the demo; grass and bushes are not | 2026-10-23 |
