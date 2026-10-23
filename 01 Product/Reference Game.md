# 🎮 Reference Game

The one game that decides what TechEngine supports first. The capability briefs and the
[[Roadmap]] are derived from it. Decided 2026-10-23, Miguel as product owner. Why a reference
game at all: [[Vision]] § *How it gets there*.

## The target

**TechAttack**: a first-person multiplayer survival, building and automation game, with
Minecraft's editable world, Satisfactory's factories, and Rust's servers and danger. This is
the full game. It sets the direction and writes the capability briefs; the phases below decide
what gets built, and when.

| Aspect | Target |
|---|---|
| **World** | Unbounded, procedurally generated, streamed around each player. Editable voxel terrain, with each world rendered smooth (marching cubes or similar) or blocky. Positions stay 32-bit floats for now (§ *Decided*). |
| **Camera** | First person only. |
| **Players** | 16 to 32 per dedicated server, with server authority. The dedicated server runs on Windows for now. |
| **Core loop** | Gather and craft · build on a grid · automate with machines and conveyors · survive creatures and other players (PvP). |
| **Persistence** | The server saves the world, its edits and its players. |
| **Look** | Outdoors, with a day and night cycle, an atmospheric sky and fog: the Vision's signature rendering. |
| **Release** | A free public demo, for example on itch.io. |

## Two terrain systems

The engine will offer two, and they are engine features, not game code:

1. **Editable voxel terrain**, smooth or blocky. It comes first, because it is the reference
   game's world.
2. **Static terrain**, a heightmap that cannot be dug or added to, with grid building on top. It
   comes later, for general-purpose users.

## Two phases

**Phase 1: the engine, one showcase a month.** The core systems TechAttack needs are built as
general engine features, each goal sized to about a month and ending in a showcase video
([[Channel]]). Each showcase runs in a tech-demo scene shaped like TechAttack: first person,
outdoors, a voxel world. The goals are on the [[Roadmap]].

**Phase 2: TechAttack, one devlog per stage.** The game starts after Phase 1's last goal, on a
complete core (decided 2026-10-23). It is multiplayer from its first day, because networking
ships in Phase 1.

| Stage | You can show | What it adds |
|---|---|---|
| **G1 · Gather, craft and build** | Dig and gather, an inventory, crafting and grid building; edits replicated and saved | Gameplay through the SDK, terrain edits over the network |
| **G2 · Automate** | Machines and conveyors that move and process items on their own | Many simulated entities, the job system under load |
| **G3 · Survive** | Health, creatures, PvP, 16 to 32 players | AI, combat, lag compensation, interest management |
| **Demo** | G3, polished and packaged, free to download | Packaging, polish |

**The risk this order carries:** engine systems built before their game can come out general
but miss what the game needs. Three things guard against it: the target above writes the
capability briefs, every showcase scene is shaped like TechAttack, and the briefs are checked
again when Phase 2 starts.

## Built the way users will build

The game is a project made through the public SDK and the editor, the way a developer who found
TechEngine on YouTube would make theirs. Game rules (recipes, machines, creatures) live in the
game project, never in the engine. A gap the game runs into is an engine gap, fixed in the
engine for everyone.

## Decided

| Question | Answer | Date |
|---|---|---|
| Name | **TechAttack** | 2026-10-23 |
| Camera | First person only | 2026-10-23 |
| Dedicated server platform | Windows, for now | 2026-10-23 |
| When the game is built | Phase 2, after Phase 1's engine goals | 2026-10-23 |
| World-space precision | 32-bit floats for now. A float's step grows with distance: about 1 mm at 8 km and 2 mm at 16 km. Decide (origin rebasing or double precision, an ADR because it touches `Transform` and physics) at the first goal that lets players travel that far, likely the endless-world goal, or at the first visible jitter. | 2026-10-23 |
