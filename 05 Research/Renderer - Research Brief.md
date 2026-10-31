---
tags: [research]
status: report
---

# Renderer: Research Brief

The research report for R1's two renderer ADRs, the frame and device seam and the materials
([[Renderer - Brief]], [[2026-10 Sprint 09 - Close M6]] § *Story E*). Card S9-P2, written
unattended on Oct 31, 2026. **It compares; it does not choose or recommend.** Every decision
below is Miguel's, in the ADRs.

It compares how Filament, Godot 4, Flax, Unity's URP and Unreal split three things: the device
seam, the mesh format and the physically based material model. Each is then read against the
brief's targets and mapped onto [[ADR-005 - v2 tech stack & toolchain]]'s device seam, the guard
against v1's renderer god-object ([[v1 Code Audit]] F22).

**How to read the sources.** Every claim names its source in the *Sources* table at the end, by
tag (for example **[F1]**). A claim marked **(memory)** comes from what I knew before this run and
was not checked today. A claim marked **(inference)** is my own reading of two sourced facts
together. Filament, Godot and Flax were read in source, at the commits in the table. Epic's and
Unity's documentation sites could not be fetched from the sandbox (`dev.epicgames.com` does not
resolve), so the URP and Unreal claims rest on search-result extracts of their official pages,
or on memory. Engine code is cited at engine `fc0ed80`.

## The questions this report answers

| # | Question | Where it is open |
|---|---|---|
| Q1 | Where does each engine put its device seam, and how wide is it? | ADR-005 § *Graphics*: "a *small* seam, **not** a full RHI" |
| Q2 | What does a mesh look like on its way to the GPU? | `Mesh` holds positions and indices only (`engine/core/include/TechEngine/core/mesh/Mesh.hpp:19-23`) |
| Q3 | How is the physically based material split: a fixed model, shader code, or a graph? | [[Renderer - Brief]] § *Requirements* and § *Decided* |
| T1 | Hundreds of local lights at 60 fps, from clustered forward. | Brief, *Constrains the ADR* |
| T2 | Hundreds of thousands of objects, from multi-draw indirect instancing. | Brief, *Constrains the ADR* |
| T3 | Lit, unlit, clear coat, sheen and transmission; cut-outs; live edits with no recompile. | Brief, *Requirements* |
| T4 | Surface shaders in code that survive new lighting features and a replaced frame. | Brief, *Requirements* (alongside E11) |

## Filament

| Topic | Finding | Source |
|---|---|---|
| Backends | OpenGL 4.1+ and ES 3.0+, Vulkan 1.0, Metal and WebGPU, plus a no-op driver for tests. OpenGL is a first-class backend, not a fallback. | [F1], [F2] |
| Seam | One driver API, declared once in `DriverAPI.inc`: 150 entries. Create, update and destroy calls on buffers, textures, programs, render targets and descriptor sets; `beginRenderPass`, `bindPipeline`, `bindRenderPrimitive`, `bindDescriptorSet`, `draw`, `dispatchCompute`. | [F3] |
| Threading | The calls are recorded into a command stream and run on the driver thread. A call that returns a handle allocates it on the calling thread at once (`methodName##S()`), then enqueues the construction. 50 entries are *synchronous*, among them the capability queries and the fence calls. | [F3], [F4] |
| Mesh | A `VertexBuffer` declares up to several buffers and a fixed set of attributes (position, tangents, colour, two UVs, bone data, custom slots). Tangent frames are one quaternion per vertex, not a normal and a tangent. A renderable's `geometry` names a primitive per material slot. | [F5], [F6] |
| Instancing | `RenderableManager::Builder::instances` draws up to 32,767 instances of one renderable, culled by one shared box; with an `InstanceBuffer` of transforms the limit is 64 on most platforms. | [F6] |
| Material model | Five models: lit, subsurface, cloth, unlit and the legacy specular-glossiness. Lit stacks clear coat, sheen and a second specular lobe over specular and diffuse, and has transmission, IOR, absorption and thickness. | [F7] |
| Surface code | A material is a text definition compiled offline by `matc` into a package with shaders per backend. The author writes `void material(inout MaterialInputs material)`, which calls `prepareMaterial` and fills inputs; the engine does the lighting. A material instance is a set of parameter values over one material. | [F7] |
| Lights | Clustered forward rendering over "froxels", frustum voxels built from screen tiles and depth slices. Its Sponza figure shows dozens of dynamic lights with MSAA. | [F8] |
| glTF | `gltfio` maps `KHR_materials_clearcoat`, `sheen`, `transmission`, `volume`, `ior`, `specular` and `unlit` onto the lit model. | [F1] |

## Godot 4

| Topic | Finding | Source |
|---|---|---|
| Backends | Vulkan, Direct3D 12 and Metal sit under `RenderingDeviceDriver`. OpenGL 3.3 and ES 3.0 do **not**: the Compatibility renderer is a separate `RasterizerSceneGLES3`, with its own mesh, material and light storage. | [G1], [G2], (memory for the GL versions) |
| Seam | Three layers. `RenderingServer` is the scene API. `RenderingDevice` adds validation, resource tracking and a command graph that reorders work and places barriers. `RenderingDeviceDriver` is the thin layer: 152 virtual calls, "very little validation", enums laid out like Vulkan's, no calls back up. | [G1], [G3] |
| Where GL meets the seam | Both the RD renderers and the GLES3 one implement `RendererSceneRender`, so GL joins Godot's design at the **scene renderer**, above the device. | [G2], [G4] |
| Mesh | A surface keeps three byte streams: `vertex_data` (position, normal, tangent, the ones skinning and blend shapes change), `attribute_data` (colour, UVs, custom) and `skin_data`. Indices are 16-bit or 32-bit by vertex count; LODs are extra index lists; the AABB and a format version travel with it. A compression flag packs attributes into 16 bits. | [G5] |
| Material model | `BaseMaterial3D` (exposed as `StandardMaterial3D` and `ORMMaterial3D`) toggles features: emission, normal map, rim, clear coat, anisotropy, AO, height, subsurface, backlight, refraction, detail, bent normals. **No sheen feature.** Transparency is off, alpha, alpha scissor, alpha hash or alpha with a depth pre-pass. | [G6] |
| How features become shaders | Each combination of features is a bit-packed `MaterialKey`, and a shared map generates one shader per key, so toggling a feature can compile a shader while changing a value cannot. | [G6], (inference) |
| Surface code | A `ShaderMaterial` runs Godot's shading language, with `vertex()`, `fragment()` and optional `light()` functions. | [G6], (memory for the function names) |
| Lights | Forward+ builds clusters on the GPU (`ClusterBuilderRD`) with a cap of elements per type. The Compatibility renderer caps lights per mesh and in total. | [G7], [G2] |
| Instancing | `MultiMesh` draws many copies of one mesh with per-instance transforms. | (memory) |

## Flax

| Topic | Finding | Source |
|---|---|---|
| Backends | DirectX 11 and 12, Vulkan, WebGPU and a null device. The `RendererType` enum still lists OpenGL, but no OpenGL device exists in the tree. | [X1], [X2] |
| Seam | `GPUDevice` creates resources (30 virtual calls) and `GPUContext` records work (61), in the style of an immediate D3D11 context: bind, draw, dispatch, copy. It is the engine's whole device seam, and every backend implements both. | [X3] |
| Indirect draws | `DrawInstancedIndirect` and `DrawIndexedInstancedIndirect`, one argument record per call. No multi-draw with a count buffer appears in the context. | [X3] |
| Mesh | Since 1.10 a mesh has an index buffer and up to three vertex buffers, laid out by a `GPUVertexLayout` built from `VertexElement`s: position, colour, normal, tangent, blend indices and weights, eight texture coordinates and four free attributes. The fixed `ModelVertex19` struct is deprecated in favour of a `MeshAccessor`. | [X4], [X5] |
| Material model | Shading models: unlit, lit, subsurface, foliage and custom-lit. **No clear coat or sheen** model appears in the material headers. | [X6] |
| Surface code | Materials are authored in a node graph that compiles to HLSL; a custom-code node takes raw HLSL. | (memory) |
| Frame | A G-buffer pass and a forward pass for transparent geometry, so the lit path is deferred. | [X7], (inference) |

## Unity URP

| Topic | Finding | Source |
|---|---|---|
| Seam | URP is C# on the Scriptable Render Pipeline. `ScriptableRenderContext` is the interface to Unity's low-level graphics code: commands and `CommandBuffer`s are queued and run at `Submit`. In Unity 6, URP passes are written against the render graph; an *unsafe* pass gets a wider `CommandBuffer` but cannot be optimised. | [U1], [U2] |
| Below the seam | The device layer under SRP is native and closed; a pipeline cannot reach it. | (memory) |
| Mesh | A mesh declares its vertex layout as `VertexAttributeDescriptor`s spread over **up to four streams**. Unity suggests three for skinned meshes: what deforms, what stays (colours, UVs), and the skinning data. Each attribute's size must be a multiple of four bytes. | [U3] |
| Material model | Lit chooses a metallic or a specular workflow. Clear coat lives in a separate *Complex Lit* shader and costs about twice a base material. URP's Lit has no sheen or transmission; HDRP has them. | [U4], (memory for sheen and transmission) |
| Surface code | Since URP, a surface shader in code is not offered; materials are Shader Graph or hand-written HLSL passes that must call URP's lighting functions themselves. | (memory; the brief checked this on Oct 30) |
| Lights | The Forward path lights 9 real-time lights per object. Forward+ removes the per-object cap but keeps a per-camera one: 256 visible lights on desktop in URP 15. | [U5] |
| Many objects | The SRP Batcher and the GPU Resident Drawer batch draws of many objects. | (memory) |

## Unreal

| Topic | Finding | Source |
|---|---|---|
| Seam | The RHI. `FRHICommandList` records draws, dispatches, copies, render passes, mesh shaders and ray tracing; the immediate list flushes to an RHI thread, and parallel lists are chained into it in order. Backends are D3D12, Vulkan and Metal; desktop OpenGL is gone. | [E1], (memory for the backends) |
| Above the seam | The Render Dependency Graph schedules passes and resources over the RHI; mesh draw commands are built and cached per primitive. | (memory) |
| Mesh | `FStaticMeshVertexBuffers` holds three buffers: positions, colours, and the rest (tangents and UVs), fed through a `FLocalVertexFactory`. Epic's own note asks for structure-of-arrays from the start. | [E2] |
| Material model | Substrate replaces the fixed shading models and blend modes, such as Default Lit and Clear Coat, with slabs. New projects get it by default; upgraded projects keep the old path unless they opt in. A legacy mode folds every material into one shading model per pixel in the G-buffer. | [E3] |
| Surface code | The material editor is a node graph compiled to HLSL, with a custom node for code. | (memory) |
| Lights and objects | The default path is deferred; the forward path uses a clustered light grid. Nanite and GPU-driven instancing carry high object counts. | (memory) |

## Q1 mapped: where each seam sits

ADR-005 asks for "a thin internal device/command seam, not a full RHI", so that "a future backend
can slot in without touching every pass", and names Vulkan as the promotion path.

| Engine | What sits on the seam | GL behind it? | Against ADR-005 |
|---|---|---|---|
| Filament | A handle-based command API, 150 entries, recorded and run on a driver thread [F3], [F4]. | Yes, first-class [F2]. | The closest shape: a small API with GL and Vulkan under it. It is also wider than "small": descriptor sets, pipelines and render passes are Vulkan-shaped (inference). |
| Godot | A thin driver (152 calls) under a validating device with a command graph [G1], [G3]. | **No**: GL is a second scene renderer [G2]. | Shows the cost of a Vulkan-shaped seam: GL did not fit under it, and every pass exists twice (inference). |
| Flax | An immediate-context device and context, 30 + 61 calls [X3]. | No GL device exists [X2]. | The smallest of the five, and the one most like today's `Buffer` and `VertexArray` wrappers in spirit (inference). |
| URP | A render graph over a closed native device [U1], [U2]. | Not visible to the pipeline. | Not comparable at the device level; the render graph is the comparable layer (inference). |
| Unreal | A full RHI with parallel recording [E1]. | No. | The "full RHI" ADR-005 rules out for now. |

**Today's starting point.** `client` owns three GL wrappers: `Buffer` and `VertexArray` hold a GL
id each (`engine/client/src/render/Buffer.hpp:9`, `VertexArray.hpp:11`), and `FrameRenderer`
holds raw shader and program ids beside them (`FrameRenderer.hpp:12-17`), with 21 `gl*` calls in
its `.cpp`. No seam type exists yet; the one producer is `RenderSnapshot`, which carries a clear
colour and a `drawTriangle` flag (`engine/client/include/TechEngine/client/render/RenderSnapshot.hpp:10-18`).

## Q1 mapped: what the seam must carry for T1 and T2

| Target | What the engines show | What it puts on the seam |
|---|---|---|
| T1, hundreds of lights | Filament's froxels [F8] and Godot's GPU clusters [G7] are clustered forward; URP's Forward+ caps lights per camera [U5]. | Storage buffers for the light and cluster lists, and a compute dispatch if the clusters are built on the GPU, as Godot's are (inference). Both are in GL 4.3+, so within 4.5. |
| T2, hundreds of thousands of objects | Filament instances one renderable up to 32,767 times under one box [F6]; Flax has single-record indirect draws [X3]; Unreal and URP lean on GPU-driven paths (memory). | `glMultiDrawElementsIndirect`, in core GL 4.3, and its count variant, core in 4.6 or `ARB_indirect_parameters` on 4.5 (memory). A per-instance transform buffer the render thread fills from the snapshot (inference). |
| The million cubes | None of the five documents this case. | A million transforms crossing from the simulation snapshot to the render thread each frame, about 48-64 MB a frame at 48-64 bytes each (inference). That is the snapshot seam's cost as much as the device's. |

## Q2 mapped: the mesh format

| Engine | Streams | What changes per vertex for skinning lives in |
|---|---|---|
| Filament | Several buffers, fixed attribute set, tangent frame as a quaternion [F5]. | The buffers the author assigns. |
| Godot | Three: vertex, attribute, skin; LODs as extra index lists [G5]. | `vertex_data`, kept apart from the rest. |
| Flax | Up to three, with a declared layout [X4], [X5]. | Declared per mesh. |
| URP | Up to four; three suggested for skinning [U3]. | Its own stream. |
| Unreal | Three: position, colour, tangents and UVs [E2]. | Positions apart from the rest. |

**The pattern across all five (inference):** positions are separated from the other attributes,
because a depth or shadow pass reads only positions, and skinning rewrites only them. Today's
`Mesh` is already that first stream and nothing else (`Mesh.hpp:21-22`), and `MESH_KIND` carries
a version of 1, so adding streams is a format version step in the blob header ([[Serialization - Design]]).
glTF itself stores each attribute as its own accessor, so any of these layouts can be filled from
it without repacking at import (memory).

## Q3 mapped: the material model against T3 and T4

| Engine | Clear coat | Sheen | Transmission | Cut-out | Value edit recompiles? |
|---|---|---|---|---|---|
| Filament | Yes | Yes | Yes | `maskThreshold` | No: instances [F7] |
| Godot | Yes | **No** | Refraction only | Alpha scissor or hash | No; a feature toggle can [G6] |
| Flax | **No** | **No** | Not seen | (memory: masked blend) | No (memory) |
| URP | Complex Lit only | No (memory) | No (memory) | Alpha clipping (memory) | No (memory) |
| Unreal | A Substrate slab | A Substrate slab | Yes (memory) | Masked (memory) | No: material instances (memory) |

**T3 (inference):** only Filament covers all three glTF extras the brief requires in one lit
model, and its `gltfio` maps them directly [F1], [F7]. Godot and URP split them across features or
shaders, and Flax has none of the three.

**T4, surface code that survives the frame changing.** The brief asks that a developer's shader
keeps working when the engine adds lighting or the frame is replaced.

| Contract | Engine | What the author can and cannot do |
|---|---|---|
| Fill the surface inputs; the engine lights them | Filament's `material()` [F7]; Godot's `fragment()` (memory) | Cannot change the lighting, so new lighting features reach old shaders. Godot's optional `light()` lets an author opt out of that (memory). |
| A fixed set of shading models | Flax [X6]; Unreal before Substrate (memory) | Adding a model touches every frame path that reads the model id (inference). |
| Write the lighting yourself | URP's HLSL passes (memory) | A pipeline change can break the shader, which is what the brief rules out (inference). |

## What R1's ADRs still have to decide

The report closes none of these; it only lists where the research found them.

- **Seam width:** a handle-based command API like Filament's, or an immediate context like Flax's.
- **Seam shape:** shaped for GL 4.5 today, or for Vulkan's descriptor sets and pipelines, given
  that Godot's Vulkan-shaped seam could not take GL [G2].
- **Seam position:** whether the scene renderer sits above it (Filament, Flax) or GL joins at the
  scene renderer (Godot).
- **Threading:** whether handles are allocated on the caller and built on the render thread, as
  Filament does [F4], given that only the render thread issues GL ([[ADR-018 - Main and simulation threads, render-owned GL]]).
- **Mesh streams:** how many, and whether tangents are a quaternion or two vectors.
- **Material:** one lit model with layered lobes (Filament), toggled features (Godot), or slabs
  (Unreal); and where cut-outs and the three glTF extras live in it.
- **Surface contract:** whether author code fills inputs only, or may also replace the lighting.
- **Instancing data:** how per-instance transforms reach the render thread for T2 and the cubes.

## Sources

| Tag | Source | Read how |
|---|---|---|
| F1 | Filament [`README.md`](https://github.com/google/filament/blob/fd9ec7ff9510df148011c5326bcb50d4bfb811ca/README.md), *Rendering* and *glTF 2.0*, at `fd9ec7f` | Source read |
| F2 | Filament `filament/backend/include/backend/DriverEnums.h`, `enum class Backend`, at `fd9ec7f` | Source read |
| F3 | Filament `filament/backend/include/private/backend/DriverAPI.inc`, at `fd9ec7f` | Source read |
| F4 | Filament `filament/backend/include/private/backend/CommandStream.h:221-237`, at `fd9ec7f` | Source read |
| F5 | Filament `filament/include/filament/VertexBuffer.h`, at `fd9ec7f` | Source read |
| F6 | Filament `filament/include/filament/RenderableManager.h`, `geometry` and `instances`, at `fd9ec7f` | Source read |
| F7 | Filament `docs_src/src_markdeep/Materials.md.html`, at `fd9ec7f` | Source read |
| F8 | Filament `docs_src/src_markdeep/Filament.md.html`, § *Clustered Forward Rendering*, at `fd9ec7f` | Source read |
| G1 | Godot `servers/rendering/rendering_device_driver.h`, at `95c0fa5` | Source read |
| G2 | Godot `drivers/gles3/rasterizer_scene_gles3.h` and `drivers/gles3/storage/`, at `95c0fa5` | Source read |
| G3 | Godot `servers/rendering/rendering_device.h`, `RenderingDeviceGraph`, at `95c0fa5` | Source read |
| G4 | Godot `servers/rendering/renderer_rd/forward_clustered/render_forward_clustered.h`, at `95c0fa5` | Source read |
| G5 | Godot `servers/rendering/rendering_server_enums.h` (`ArrayType`, array flags) and `rendering_server_types.h` (`SurfaceData`), at `95c0fa5` | Source read |
| G6 | Godot `scene/resources/material.h`, at `95c0fa5` | Source read |
| G7 | Godot `servers/rendering/renderer_rd/cluster_builder_rd.h`, at `95c0fa5` | Source read |
| X1 | Flax `Source/Engine/Graphics/Enums.h`, `RendererType`, at `021e79d` | Source read |
| X2 | Flax `Source/Engine/GraphicsDevice/` (DirectX, Null, Vulkan, WebGPU), at `021e79d` | Tree listing |
| X3 | Flax `Source/Engine/Graphics/GPUDevice.h` and `GPUContext.h`, at `021e79d` | Source read |
| X4 | Flax `Source/Engine/Graphics/Models/Types.h`, `MeshBufferType`, at `021e79d` | Source read |
| X5 | Flax `Source/Engine/Graphics/Shaders/VertexElement.h`, at `021e79d` | Source read |
| X6 | Flax `Source/Engine/Graphics/Materials/MaterialInfo.h`, `MaterialShadingModel`, at `021e79d` | Source read |
| X7 | Flax `Source/Engine/Renderer/GBufferPass.h` and `ForwardPass.h`, at `021e79d` | Source read |
| U1 | Unity Manual, [Scriptable Render Context](https://docs.unity.cn/6000.0/Documentation/Manual/srp-using-scriptable-render-context.html) (6000.0) | Search extract |
| U2 | Unity Manual, [Render graph unsafe pass](https://docs.unity3d.com/Manual/urp/render-graph-unsafe-pass.html) (6000.3) | Search extract |
| U3 | Unity Scripting API, [`VertexAttributeDescriptor`](https://docs.unity3d.com/ScriptReference/Rendering.VertexAttributeDescriptor.html) | Search extract |
| U4 | Unity Manual, [Complex Lit shader](https://docs.unity3d.com/Manual/urp/shader-complex-lit.html) (6000.5); URP 11 package docs for the cost | Search extract |
| U5 | URP 15 and 16, [Forward+ rendering path](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/rendering/forward-plus-rendering-path.html) | Search extract |
| E1 | Epic API, [`FRHICommandList`](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/RHI/FRHICommandList) and `FRHICommandListImmediate` | Search extract |
| E2 | Epic API, [`FStaticMeshVertexBuffers`](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/FStaticMeshVertexBuffers) | Search extract |
| E3 | Epic, [Overview of Substrate materials](https://dev.epicgames.com/documentation/en-us/unreal-engine/overview-of-substrate-materials-in-unreal-engine) | Search extract |
