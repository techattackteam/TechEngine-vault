# Renderer: Brief

**Map:** [[Capability Map]] § *Renderer*
**Goals:** E2 (R1), with T4 import and T3 viewport tools alongside; then E3, E4, E7 and E8.
Surface shaders in code come alongside E11, with scripting.
**Status:** agreed (2026-10-30)
**Feeds:** R1's two renderer ADRs, the frame and device seam (with lights and culling) and
materials and shading models, and the renderer's design note.

## Who uses it

- **Players:** see the world: materials, the sky and sun, local lights, and later shadows, fog,
  water and bounced light.
- **Developers:** before the demo, only Miguel. They import models, edit materials and place
  lights in the editor, and later write surface shaders in code. Viewers watch the videos;
  nobody else gets a build before T5 packaging.

## Scenarios

1. Miguel imports Sponza and Bistro as glTF in the editor, and the scene view draws them exactly
   as the runtime will.
2. He selects a material, changes its roughness and base color in the inspector, and the scene
   view shows the change at once.
3. He places hundreds of local lights across Bistro at night, beside the sun and the sky image,
   and it holds 60 fps at 1080p on the target PC. A stress scene fills the view with hundreds of
   thousands of copies of the reference models, and it holds 60 fps too.
4. He exports and starts the runtime: the same image, with correct brightness and smooth edges.
5. He switches the scene view to Unlit or Wireframe to inspect a model (a Should).
6. Alongside E11, he writes a surface shader in code for a scrolling conveyor belt, and a Script
   sets the belt's speed. The engine lights it like everything else, and it still works after E3
   added shadows and E8 bounced light.

## Requirements

| | Requirement | Why |
|---|---|---|
| **Must, E2** | Imported glTF reference models (Sponza, Bistro), seen through a camera in the runtime and in the editor's scene view, and the two look identical. | Scenarios 1 and 4 |
| **Must, E2** | Each mesh slot has a material on the engine's standard material: textures and values, no shader code. Edits in the inspector show in the scene view at once, with no recompile or reload. | Scenario 2; `/triage` |
| **Must, E2** | Shading models: lit, unlit, and glTF's common extras: clear coat, sheen and transmission. | Reference models look wrong without them |
| **Must, E2** | Lighting: a sun, a sky image that lights and reflects, and hundreds of local lights. No shadows. Shiny surfaces reflect only the sky. | Scenario 3 |
| **Must, E2** | A finished image: correct brightness for a bright sky and dark corners, and smooth edges. | Scenario 4; a comparison video |
| **Must, E2** | Cut-out surfaces (leaves, fences, curtains) draw correctly. | Sponza |
| **Must, E2** | Hundreds of thousands of objects on screen, many of them copies of one model. The video shows a stress scene of copies of the reference models. | Scenario 3 |
| **Must, alongside E11** | Developers write surface shaders in code, and the engine still lights them. A Script can set a material's values. A shader keeps working when the engine adds lighting features or the frame is replaced. | Scenario 6; `/triage` |
| **Should, E2** | Glass draws correctly. Debug view modes in the scene view (Unlit, Wireframe). | Cut first if E2 runs long |
| **Should, E2** | v1's test of a million cubes moving up and down on a grid runs at 60 fps; v1 reached 20 fps. It is also an end-to-end test of the ECS, the task graph and the renderer. | Miguel |
| **Later** | A node-graph material editor, after the demo. Developers add their own passes, or replace the whole frame through the engine's device seam. | `/triage` |
| **Won't, for now** | Shadows in E2 (they are E3's). Reflections of nearby objects in E2. | Keeps E2 to its goal |
| **Won't, for now** | Ray tracing · VR · HDR displays · low-end PCs and mobile, all until after the demo. Lighting written by developers. Replacing the device layer. | This brief; `/triage` |

## Numbers

| Budget | Value |
|---|---|
| Frame rate | Sponza and Bistro each hold 60 fps at 1080p on the target PC (a 6 to 8 GB GPU, a few years old). |
| Local lights | Hundreds on screen at once, inside that frame rate. |
| Objects | Hundreds of thousands on screen at once, inside that frame rate. A million moving cubes at 60 fps is the Should. |
| Material edits | Shown in the scene view at once, with no recompile or reload. |

## What developers will expect

Checked on 2026-10-30 against Epic's, Unity's and Godot's current docs, unless a line says
otherwise:

- **The editor draws with the game's renderer**, with editor-only view modes on top (Unreal's
  Lit, Unlit and Wireframe; Unity's draw modes). TechEngine meets it: identical, with view modes
  as a Should.
- **Material instances**: one shader, many materials with their own values, changed without a
  recompile (Unreal, Unity, Godot). E2 meets it.
- **A node-graph material editor** is the main path in Unreal and Unity, and Godot has one too.
  TechEngine leaves it until after the demo and starts with shaders in code. Unity's current
  pipelines no longer offer a code version of surface shaders, so code first is a difference.
- **Mesh LOD and particles**: all three have them, and the [[Roadmap]] lists both under
  *Deliberately absent*. Owed to `/product-review` (*Open questions*). From memory.
- **Ray tracing** in Unreal and Unity's HDRP: out on purpose until after the demo. From memory.

## Depends on and constrains

- **Leans on:** OpenGL 4.5 behind a thin device seam ([[ADR-005 - v2 tech stack & toolchain]]);
  only the render thread issues GL ([[ADR-018 - Main and simulation threads, render-owned GL]]);
  glTF import through assimp ([[Capability Map]] § *Content pipeline*).
- **Leans on, open:** E2's showcase now needs imported reference models, so T4's import is on
  E2's critical path, not alongside it.
- **Constrains the ADR:** for hundreds of lights, Miguel's starting point is the technique v1
  used, clustered forward rendering ([[Paper#Clustered Deferred and Forward Shading]]). For
  hundreds of thousands of objects, it is v1's multi-draw indirect instanced rendering, which
  keeps draw calls to a minimum. The moving cubes also test how a million changing transforms
  reach the render thread each frame, not only how they are drawn. The
  surface contract must hold for every renderer, so the frame can be replaced later without
  breaking developers' shaders.
- **Constrains the [[Editor - Brief]]:** E2 replaces E1's placeholder scene view.

## Open questions

Owed to `/product-review` (Nov 7-8), because they change notes a brief does not own:

- **The renderer's bar.** Hundreds of lights, hundreds of thousands of objects, glTF's extras and
  Bistro go beyond what TechAttack needs (P1). They follow Miguel's goal of a first release that stands out among indie engines,
  which the map already owes to this review. Mesh LOD and particles wait on the same answer.
- **E2's scene.** Reference models only, while the [[Reference Game]] says every showcase runs
  in a scene shaped like TechAttack.
- **E2's size.** Lights, the finished image and see-through surfaces move from R2 into R1, and
  T4 moves onto the critical path. E2 is probably over a month, and the [[Roadmap]]'s guardrail
  is to split a goal, never stretch it.

## Decided

| Question | Answer | Date |
|---|---|---|
| What a mesh slot gets | A material on the engine's standard material, with no shader code. | 2026-10-30, `/triage` |
| How deep developers go | Shading models from the engine's set; custom passes and replacing the frame Later; lighting written by developers and replacing the device layer Won't. | 2026-10-30, `/triage` |
| What lights E2 | A sun, a sky image and local lights. | 2026-10-30 |
| Editor scene view and runtime | Identical. Miguel asked how Unreal and Unity do it: both draw the editor view with the game's renderer. | 2026-10-30 |
| E2's models | Reference models only. | 2026-10-30 |
| Editing materials in E2 | Yes, live: inspector edits show in the scene view at once. | 2026-10-30 |
| Local lights on screen | Hundreds, "using the same technique v1 used, forward rendering plus (clustered forward)". The technique goes to the ADR as Miguel's starting point. | 2026-10-30 |
| Shadows | None in E2; shadows stay in E3. | 2026-10-30 |
| Debug view modes | Should in E2. | 2026-10-30 |
| A finished image | Correct brightness and smooth edges are both a Must in E2. | 2026-10-30 |
| Scene size | Sponza and Bistro at 60 fps, 1080p, on the target PC. | 2026-10-30 |
| See-through surfaces | Cut-outs Must, glass Should. | 2026-10-30 |
| Surface shaders | In code, alongside E11, with scripting, and not inside E11's showcase; a Script can set a material's values. Changed the same day from "before Phase 2". E2 ships the standard material only; a node-graph editor comes after the demo. | 2026-10-30 |
| E2's shading models | Lit, unlit, plus glTF's common extras: clear coat, sheen and transmission. | 2026-10-30 |
| Out until after the demo | Ray tracing, VR, HDR displays, low-end and mobile. | 2026-10-30 |
| Reflections in E2 | The sky only. | 2026-10-30 |
| Developers before the demo | Only Miguel. | 2026-10-30 |
| Objects on screen | Hundreds of thousands. Instanced rendering with multi-draw indirect, as v1 did, is a must from the beginning; the technique goes to the ADR as Miguel's starting point. | 2026-10-30 |
| The million cubes | "In the v1 I did a million cubes going up and down on a grid that did 20 fps. It would be nice to try and have this test at 60 fps." Recorded as a Should. Miguel added: "this would be a good end to end test of the new task graph with the ECS implementation and renderer" ([[Backlog]] → cross-cutting). | 2026-10-30 |
| How E2's video shows the count | Copies of the reference models in a stress scene. | 2026-10-30 |
