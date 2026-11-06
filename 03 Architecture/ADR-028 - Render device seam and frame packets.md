# ADR-028: Render device seam and frame packets

- **Status:** Accepted
- **Date:** 2026-11 (Accepted 2026-11-06)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** S10-D4 ([[2026-10 Sprint 10 - Close E1]] § *Story E*), R1's first renderer ADR.
- **Amends:** [[ADR-005 - v2 tech stack & toolchain]] § *Graphics*, "Target **4.5 core with
  DSA**" (§2 below), recorded in its header.
- **Partially supersedes:** [[ADR-006 - v2 core architecture & module layout]] §5's Renderer
  row, "**System** (final phase, client-side) | owns GPU device+graph" (§3 below), and §1's
  "GL 4.5 device seam" in the `client` row. [[ADR Index]] records both.
- **Related:** [[Renderer - Brief]] · [[Renderer - Research Brief]] ·
  [[Renderer - Seam Paper Report]] · living *how*: [[Renderer - Design]]

## Context

[[Renderer - Brief]] asks E2 to draw Sponza and Bistro at 60 fps at 1080p, identical in the
editor's scene view and the runtime, with inspector edits shown at once. E2b adds hundreds of
local lights and hundreds of thousands of objects, and the million moving cubes are a Should.
Miguel's starting points are clustered forward shading and multi-draw indirect, as in v1.
ADR-015 §2 left the frame's format to this ADR.

Checked at engine `a67c4d4`. `client` has no seam yet: `FrameRenderer` holds two `Buffer`s, a
`VertexArray` and raw program ids (`engine/client/src/render/FrameRenderer.hpp:12-17`), and the
render thread requires GL 4.5 (`engine/client/src/render/RenderThread.cpp:93`). Two facts
constrain the frame's path:

- **The snapshot is copied by value about four times per frame:** into the mailbox, out of it,
  into the history, and out of `prepareFrame` (`SnapshotMailbox.cpp:6`, `:14`,
  `SnapshotHistory.cpp:17-29`, `:42`). That is free at 80 bytes and fatal at 64 MB of transforms.
- **The editor never sends render a frame after an edit.** `publishSnapshot` runs once before
  ready and then only when a tick advances (`engine/app/src/SimulationThread.cpp:189-191`,
  `:226-229`); a stopped editor only runs `publishEdits` (`:211-214`). `publishSnapshot` also
  gets no `Scene` (`engine/app/include/TechEngine/app/App.hpp:113`).

### The baseline

*Memory* marks what was not read in source.

- **Unreal:** a full RHI over D3D12, Vulkan and Metal [[Renderer - Research Brief]]. The game
  thread mirrors each component into a render-thread scene proxy and sends changes as ordered
  commands; GPU Scene keeps instance data resident and uploads only what changed *(memory)*.
- **Unity:** a closed native device under SRP's render graph; the GPU Resident Drawer keeps
  instance data on the GPU, as Unreal does *(memory)*.
- **Godot 4:** a Vulkan-shaped `RenderingDeviceDriver`, under which GL did not fit, so GL is a
  second scene renderer. `RenderingServer` keeps a retained scene fed by queued commands *(memory)*.

All three keep a retained render-side scene fed by deltas. TechEngine's render thread consumes
complete snapshots and may skip them (ADR-018 §2), so deltas need a lossless delivery mode that
ADR-018 left out.

## Decision

### 1. A small device API, shaped for GL, owned by the render thread

`client` gets a device that only the render thread calls. It creates and destroys buffers,
textures, samplers, shader programs, vertex layouts and render targets, and hands out typed
handles; no GL id leaves it. Fixed-function state (depth, blend, raster, the program and the
vertex layout) is built once into a pipeline object and bound whole. Work happens inside
explicit render passes that name their targets and their load and store actions. Passes talk to
the device, never to GL. A render target is an ordinary texture, so the editor's scene view is
the same frame drawn into a target that ImGui shows (ADR-027 §1).

The device executes immediately. There is no recorded command stream of its own, because the
frame packet (§3) already crosses threads, and a second stream would duplicate it.

### 2. OpenGL 4.6, with bindless textures required

The floor rises from 4.5 to **4.6**, the last OpenGL version. It brings
`glMultiDrawElementsIndirectCount`, `gl_DrawID` and SPIR-V shader loading into core. The
renderer also requires **`ARB_bindless_texture`** and refuses to start without it, logging
which requirement failed, as the 4.5 check does today. There is no fallback path.

Textures reach shaders as 64-bit handles stored in a material buffer, which each draw finds
through `gl_DrawID`. So one multi-draw covers many materials, which is what makes few draws
possible ([[Renderer - Seam Paper Report]] § *GPU-Driven Rendering Pipelines*). Per-frame and
per-pass data stay on GL binding points. Bindless was v1's model too. ADR-005's trigger names
bindless as something GL "can't serve well"; with this extension GL serves it, so the trigger
has not fired.

### 3. The frame packet: read from the `Scene`, moved, never copied

The simulation thread reads the `Scene` into a **frame packet**: the scene's cameras, the
lights, and each drawn instance with its transform and its mesh and material handles. It does so after a
catch-up batch that advanced ticks and after every batch of applied edit commands, so a
stopped editor shows each edit. The hook that does it receives the `Scene`; the packet carries
no pointer into it.

Packets come from a fixed pool and move by ownership: simulation fills a free one, publishing
replaces the slot's packet and frees the old one, and render returns each packet when its
history drops it. The pool is sized so simulation never waits. ADR-019 §3's latest-complete
delivery, its two private history entries and its interpolation are unchanged; §3 already
allows "another storage mechanism" for larger payloads.

A frame draws one packet into one or more **views**, each with a target and a camera. The
runtime has one, the window. The editor has its scene view and game view ([[Editor - Design]]).
The scene view takes its camera from main, on ADR-019 §4's latest-value path, so moving it
needs no packet and no tick. A hidden view is not drawn.

The renderer is therefore not a scheduled System, against ADR-006 §5: it is the extraction
hook on the simulation thread plus the frame on the render thread. Replacing either stays the
brief's *Later*.

### 4. Uploads cross in order, and render's fence guards their source

Mesh, texture and material data reach the GPU as **upload requests**, in an ordered channel
that never drops one, beside the packet, the same split ADR-027 §1 made for ImGui's textures.
Render keeps one GPU copy per resource handle, and packets name resources only by handle.

- **Render's fence (ADR-024 §6):** render reads a cache payload only while uploading it, and
  simulation defers the free of an entry until render reports that upload finished. Simulation
  never blocks on render; a free waits in a list. A reload, which keeps its handle, sends a
  new upload under the same fence.
- **The GPU copy's lifetime is render's own:** a release request drops it once no packet in
  render's history names the handle and the GPU has finished the frames that drew it.

### 5. The E2 frame, and the GPU vertex streams

- **Frame:** a depth pre-pass, light clusters built and filled by compute shaders as in v1,
  one forward lit pass with CPU-written multi-draws and cut-outs, the sky, then the final image.
  So the device dispatches compute and binds storage buffers from E2. Culling instances on the
  GPU comes only when a measurement asks for it.
- **Geometry:** static meshes share one set of buffers, one per stream plus one 32-bit index
  buffer, so one multi-draw spans every mesh. Positions are their own stream, because the depth
  pre-pass, and E3's shadow passes, read nothing else. A new vertex layout, such as skinning,
  gets its own set. A mesh never moves once placed, because frames the GPU is still drawing hold
  its offsets in their draw commands.
- **This ADR owns the streams and attributes; S10-D9 owns the mesh file** that fills them.
  No meshlets at import and no visibility buffer before R7.

### 6. The door to Vulkan or D3D12 stays open, unopened

There is one backend and no backend interface. §1's handles, pipeline objects, explicit passes
and grouped bindings are each a direct match for Vulkan's and D3D12's objects, and bindless
matches their descriptor indexing. Per-resource barriers and manual memory stay out of the API,
because a seam shaped by them is what kept GL out of Godot's. A pass that writes in compute
issues GL's coarse memory barrier through the device. ADR-005's promotion trigger is unchanged.

## Consequences

- **Benefit:** a pass never sees GL, so the god-object of v1's F22 has nowhere to grow, and a
  second backend later replaces the device, not the passes.
- **Benefit:** one frame path for editor and runtime, which is what the brief's "identical"
  scenario needs, and a stopped editor redraws on every edit.
- **Cost:** the target PC must support `ARB_bindless_texture`. From memory, NVIDIA and AMD do on
  Windows and Mesa's AMD driver does on Linux; Intel's Windows driver, Arc included, has
  historically not.
- **Cost:** RenderDoc cannot capture bindless GL frames, as Miguel found in v1, so GPU captures
  go through Nsight.
- **Cost:** a complete packet re-sends static instances every publish. For Sponza and Bistro
  that is small; for the E2b stress scene it is about 64 bytes per instance per publish.
- **Revisit when:** E2b's stress scene measures packet building or its upload over budget. The
  answer is a resident static-instance buffer fed through §4's ordered channel, not a new seam.
- **Revisit when:** a target GPU without `ARB_bindless_texture` becomes a requirement.
- **Revisit when:** ADR-005's promotion trigger fires; §6 is the starting point.

## Alternatives considered

| Option | For | Against |
|---|---|---|
| A recorded command stream, Filament style, Vulkan-shaped | Any thread records; closest to a future Vulkan backend. | A second cross-thread stream beside the packet; Vulkan's shape kept GL out of Godot's seam. |
| A retained render scene fed by deltas (Unreal, Unity, Godot) | Static scenes cost nothing per frame. | Deltas cannot be skipped, so it needs the lossless delivery mode ADR-018 §2 rejected. |
| Stay on GL 4.5, with `ARB_indirect_parameters` | Runs on drivers a few years older. | Every GPU that has bindless already ships 4.6 *(memory)*, so an extension check stays either way. |
| Binding points or texture arrays instead of bindless | Works everywhere, RenderDoc can capture it. | Splits multi-draws per texture set; arrays force one size and format per array. |
| Light clusters built on the CPU | No compute on the seam in E2, and easier to debug. | The render thread assigns hundreds of lights to thousands of clusters every frame; v1 already ran this in compute. |
| The scene view's camera through the simulation, into the packet | One source for every camera. | Each camera move rebuilds the packet, adds a hop of latency, and puts editor state in the simulation during Play. |
| Extraction as a System at the final phase (ADR-006 §5) | Scheduled like every other System. | A stopped editor never ticks, so edits would never reach the scene view. |
