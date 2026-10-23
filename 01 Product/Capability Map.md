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

**For:** developers building a game. **Goals:** E1; import alongside E2, terrain tools alongside E6, play in the editor alongside E11.

| | |
|---|---|
| **Showcase (E1)** | A hierarchy, an inspector and a simple scene view (a placeholder until the first renderer); save the scene, export it, and run it in the runtime. |
| **Demo** | Edit scenes · play in the editor and return to the edited state · terrain tools (sculpt, paint, generation settings) · an asset browser with import · a visual game UI designer (§ *Game UI*). |

## Renderer

**For:** players see the world; developers author materials and lights. **Goals:** E2, E3, E4, E7, E8.

| | |
|---|---|
| **Showcase (E2)** | Imported models with physically based materials, seen through a camera, in the runtime and the editor's scene view. |
| **Showcase (E3)** | A physically based sky, a moving sun, day and night, and dynamic sun shadows. |
| **Showcase (E4)** | Volumetric fog and god rays. |
| **Showcase (E7)** | Static water with reflections, and trees and rocks drawn out to the view distance. |
| **Showcase (E8)** | Global illumination: bounced light that follows terrain edits and the day and night cycle. |
| **Demo** | A view of about 1 km over voxel terrain · dozens of local lights at night · volumetric fog and god rays · global illumination (bounced light) · static water with reflections. |
| **Numbers** | 60 fps at 1080p on the target hardware, with all of the above on screen. |

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
