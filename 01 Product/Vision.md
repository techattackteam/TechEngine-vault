# 🌟 Vision

## One line

TechEngine is a client/server 3D game engine with a data-oriented core and a physically
grounded renderer. It is proven first on large, persistent, multiplayer worlds, widens to
general-purpose 3D later, and is meant to become an engine company.

## Who it is for

- **Now:** Miguel, building the [[Reference Game]], and the developers who follow the engine
  on YouTube.
- **Later:** other developers making their own games with it. They are the engine company's
  users.

So everything a game needs goes through the public SDK and the editor, and the reference game
is built that way too.

## What the company is

**An engine company**, offering the engine to other developers. That is far in the future, and
"selling" is a strong word for now. The near-term step is to **expose the engine on YouTube**,
so other developers can start their own games with it. (Decided 2026-10-23.)

## Why it exists

- To own a serious piece of technology end to end (rendering, ECS, tooling, networking) rather
  than assembling one from black boxes.
- To be the vehicle for deep graphics work: atmospherics, volumetrics, global illumination.
- To become an engine that other developers build their games with.

## How it gets there: the reference game

One game decides what the engine supports first: the [[Reference Game]], **TechAttack**, a
first-person multiplayer survival, building and automation game in the spirit of Minecraft,
Satisfactory and Rust. It ships in **stages**, each a playable slice and a YouTube video, and
ends as a **free public demo**. Client/server exists for this game: dedicated servers with
server authority.

## Three-year horizon

1. **Foundation**: a core you can trust. Done through M5; M6 closes in Sprint 09.
2. **The reference game's stages**, with the signature rendering in an outdoor world with a
   day and night cycle.
3. **The free public demo**, plus the documentation and videos that let another developer
   start a game with TechEngine.

## Non-goals (for now)

- Feature parity with Unreal or Unity. TechEngine chases a *deep, correct* subset, and the
  reference game decides which subset.
- A marketplace or plugin ecosystem.
- Platforms beyond Windows (primary) and Linux before the demo
  ([[ADR-005 - v2 tech stack & toolchain]]).
- Licensing, support or compatibility promises to outside developers before the demo.

See also: [[Reference Game]] · [[Principles]] · [[Roadmap]]
