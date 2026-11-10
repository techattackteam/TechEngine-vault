# ADR-029: Materials, surfaces and lobes

- **Status:** Accepted
- **Date:** 2026-11 (Accepted 2026-11-10)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** S10-D7 ([[2026-10 Sprint 10 - Close E1]] § *Story E*), R1's second renderer ADR.
- **Related:** [[Renderer - Brief]] · [[Renderer - Research Brief]] § *Q3 mapped* ·
  [[Renderer - Materials Paper Report]] · [[ADR-028 - Render device seam and frame packets]] ·
  living *how*: [[Renderer - Design]] § *Materials*

## Context

[[Renderer - Brief]] asks E2 for a standard material on every mesh slot, with textures and
values and no shader code, whose edits show in the scene view at once with no recompile.
Alongside E11, developers write surface shaders in code, and a shader must keep working when
the engine adds lighting features or the frame is replaced. A node-graph editor is *Later*.

ADR-028 §2 already fixed the delivery: texture handles live in a material buffer that each
draw finds through `gl_DrawID`, so one multi-draw covers many materials. Checked at engine
`ac594e4`: no material, texture, light or camera type exists. The only shader is M4's triangle,
as two string literals (`engine/client/src/render/FrameRenderer.cpp:48-61`), and
`MeshRenderer` holds a mesh only (`engine/core/include/TechEngine/core/mesh/MeshRenderer.hpp:13`).

### The baseline

*Memory* marks what was not read in a source.

- **Unreal:** a material is a node graph compiled to HLSL. The graph fills fixed outputs and
  the engine lights them. The shading model (Default Lit, Unlit, Clear Coat) is a setting, and
  a developer cannot add one without changing engine source. Material instances change values
  with no recompile; a static switch compiles a permutation *(memory)*. Substrate replaces the
  fixed models with slabs ([[Renderer - Materials Paper Report]] § *Where materials go*).
- **Unity:** a material is a shader reference, values and keywords. A keyword selects a
  precompiled shader variant. URP offers no surface shader in code, so hand-written shaders
  call the lighting themselves and a pipeline change can break them *(memory)*.
- **Godot 4:** one shader is generated per combination of features, so a toggle can compile.
  A `ShaderMaterial` writes `fragment()` and an optional `light()`
  ([[Renderer - Research Brief]] § *Godot 4*).
- **Filament:** one lit model with clear coat and sheen always present, and a `material()`
  function that only fills inputs ([[Renderer - Research Brief]] § *Filament*).

All four change a value without a recompile. Unreal, Unity and Godot pay a compile for a
feature toggle, and they have offline compilers and variant caches to carry that. TechEngine
has neither in E2, and a variant splits the multi-draw that ADR-028 §2 chose bindless to keep
whole. So Filament's shape is the one to beat, and the lobe seam in §2 is where TechEngine
offers more than Unreal does.

## Decision

### 1. A material is a surface and a block of values

A **surface** is shader code that fills a fixed set of inputs: base color, roughness, metallic,
normal, emissive, occlusion and opacity. It never computes lighting. A **material** is an asset
in `core` that names one surface and stores a value for each thing that surface reads. The
**standard material** is the engine's own surface, and it is the only one E2 builds.

Three things make a surface, and the engine cannot tell them apart: the engine, a developer in
code (alongside E11), and later a node graph, which is a generator of surfaces.

### 2. Surface, lobe, light loop

Lighting is three pieces. The surface fills the inputs. A **lobe** is a function that, given
the inputs and one light's direction, returns how much light the surface reflects. The **light
loop** belongs to the engine alone: it walks the sun, the clustered lights and the sky, applies
falloff and later shadows, calls each lobe and adds the results.

The engine's own lobes, diffuse and specular, are written in this form from E2. A lobe never
sees clusters or shadows, so E3 and E8 reach every lobe without changing it. The sky arrives
from every direction at once, so a lobe may also give an ambient function; a lobe without one
gets only an approximation from the sky.

The lobe seam stays **internal**. [[Renderer - Brief]] lists lighting written by developers as
*Won't*, so opening it to developers waits on a `/triage`. Nothing built here blocks it.

### 3. One lit model, with layers driven by values

The standard surface has one lit model. A layer such as clear coat is always present in the
program and switched by its values, where zero means off, so every edit is a buffer write. A
**shading model** value selects lit or unlit; unlit skips the light loop.

E2 ships diffuse and specular only. Clear coat, sheen and transmission are **postponed**
(Miguel, 2026-11-09), which moves a Must in [[Renderer - Brief]]. A layer is added later as new
inputs that default to zero, new fields in the material's record, one lobe, and a version step
of the material file. Old materials and old surfaces keep working.

Whether the engine later compiles a variant for materials that leave a layer at zero is a
mechanism behind the same files, so it lives in [[Renderer - Design]], not here.

### 4. Alpha mode and sidedness are material state

A material carries an alpha mode (opaque, cut-out, blended) and a double-sided flag. Both are
pipeline state, so each combination is a **draw bucket** with its own multi-draw. Cut-outs skip
the positions-only depth pre-pass and discard in the forward pass (ADR-028 §5). The blended
mode is in the file from E2, and its pass arrives with the brief's glass, a *Should*.

### 5. Shaders are GLSL source, assembled by the engine

The engine builds each program from GLSL source: its shared declarations and light loop, the
lobes, and one surface. There is one program per surface and lobe set, and each program draws
with its own multi-draw per bucket. The driver compiles it on the render thread. The engine's
sources are engine assets, reached through the renderer's settings asset
([[Resources - Design]] § *Settings assets*). GL 4.6's SPIR-V loading goes unused.

### 6. Photometric units, and a fixed exposure until R2

Light values are photometric from the first light component: lux for the sun, lumens for local
lights, cd/m² for the sky. The camera carries a fixed exposure value until R2 adds
auto-exposure. No light or camera type exists yet, so nothing migrates. Check the formulas in
Lagarde and de Rousiers before a card relies on them ([[Renderer - Materials Paper Report]]).

### 7. What the standard material samples, and how it is edited

It samples four textures, each optional beside its factor: base color (whose alpha feeds the
cut-out), a packed occlusion, roughness and metallic map in glTF's channel order, a
tangent-space normal, and emissive. Wrap and filter live on the texture asset, so each texture
has one handle. This list is what S10-D11 formats.

A material's values are edited through an **asset edit path**: each edit is an undo step and
the file is written on Save (Miguel, 2026-11-09). That path is not designed; it is a
[[Backlog]] entry, because textures and settings assets will use it too.

## Consequences

- **Benefit:** a value edit and a layer toggle are both buffer writes, so the brief's "no
  recompile" holds for every edit of a standard material.
- **Benefit:** a developer's surface never touches lighting, so it survives E3, E8 and a
  replaced frame. A node graph needs no new contract.
- **Benefit:** the engine's lobes and a later developer lobe share one form.
- **Cost:** once layers exist, every lit pixel tests them. The cost is not measured.
- **Cost:** the lobe list is fixed per program. Free layering of any number of slabs, as in
  Substrate, would rewrite the light loop's input.
- **Cost:** GLSL source compiles at startup, once per surface, and a later Vulkan backend
  (ADR-028 §6) would need a translation step.
- **Cost:** a custom lobe's sky reflection will not match the built-in ones automatically.
- **Risk:** CI's software GL cannot run these shaders at all ([[Backlog]] § *client*).
- **Revisit when:** a wanted material cannot be expressed by the fixed lobes; the layer tests
  measure over budget on Sponza or Bistro; startup shader compiles exceed what the editor can
  hide; ADR-005's Vulkan trigger fires.

## Alternatives considered

| Option | For | Against |
|---|---|---|
| A shader per feature set (Unity, Godot, Unreal's static switches) | Each pixel pays only for what it uses. | A toggle compiles, and each variant splits the multi-draw. Swappable later behind the same files (§3). |
| Fixed shading models with no lobe seam (Unreal before Substrate) | Less contract to hold. | A new model touches the whole light loop, and developers can never add one. |
| The author writes the lighting (URP's HLSL passes) | Full freedom. | A new lighting feature breaks the shader, which the brief rules out. |
| Slabs from the start (Substrate) | Any layering. | A far larger system than E2 needs; Unreal ran fixed models for about ten years first *(memory)*. |
| SPIR-V compiled offline | Errors at build time; the format Vulkan wants. | A shader compiler in the build, and the less used driver path on GL *(memory)*. |
| An engine shading language (Godot) | Portable across backends. | A compiler to write and keep, for one backend. |
| Sampler state on the material | Matches glTF, where a sampler belongs to each use. | A handle per texture and sampler pair; Unity and Unreal keep it on the texture *(memory)*. |
