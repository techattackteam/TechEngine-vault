# Renderer: Design

> Living design doc. The decisions that are hard to reverse are in
> [[ADR-028 - Render device seam and frame packets]] (Accepted 2026-11-06) and
> [[ADR-029 - Materials, surfaces and lobes]] (Accepted 2026-11-10). This note holds the *how*,
> and it is R1's hub: plan and ground renderer work from here.

**Module:** `client` (the device, the passes, the render thread) · `apps/clientapp` and `app`
(the extraction hook) · `core` (mesh and material types)
**Kind:** system
**Status:** designed on 2026-11-06 (S10-D4) against engine `a67c4d4`; materials designed on
2026-11-10 (S10-D7) against `ac594e4`. The device is built (S11-T3, #207), and so are the frame
packets (S11-T4, #210), the ordered uploads (S11-T6, #213), the geometry buffers (S11-T7,
#217), the material buffer with bindless textures (S11-T8, #219), the forward pass that draws
the first frame (S11-T9, #220, `engine/client/src/render/FrameRenderer.cpp`) and the editor's
views (S11-T10, #221).
**ADRs:** [[ADR-028 - Render device seam and frame packets]] ·
[[ADR-029 - Materials, surfaces and lobes]] ·
[[ADR-015 - Threading (sim on main, render thread owns GL)]] §2 ·
[[ADR-018 - Main and simulation threads, render-owned GL]] §2 ·
[[ADR-019 - Fixed simulation ticks, render interpolation and shared clock]] §3 ·
[[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §6 ·
[[ADR-027 - Editor threads, edit commands and play sessions]] §1
**Product:** [[Renderer - Brief]] · **Research:** [[Renderer - Research Brief]],
[[Renderer - Seam Paper Report]], [[Renderer - Materials Paper Report]] ·
**Backlog:** [[Backlog]]

## Purpose

The renderer draws the `Scene` through a camera, the same way in the editor's scene view and
in the runtime. The `Scene` belongs to the simulation thread and GL to the render thread, so
the renderer is two halves: a hook that reads the `Scene` into a frame packet, and a frame on
the render thread that draws packets through a small device.

## Decided

| What | Call | Ref |
|---|---|---|
| A small device, shaped for GL | Typed handles, pipeline objects bound whole, explicit render passes. Passes never call GL. It executes immediately; there is no recorded command stream. | ADR-028 §1 |
| The scene view is a render target | The editor draws the same frame into a texture that ImGui shows. | ADR-028 §1; ADR-027 §1 |
| OpenGL 4.6 | The floor rises from 4.5. | ADR-028 §2 |
| Bindless textures are required | `ARB_bindless_texture`, with no fallback. Texture handles live in a material buffer that each drawn instance indexes through its draw record (row *How a draw finds its data*). | ADR-028 §2, amended 2026-11-20 |
| The frame packet | Read from the `Scene` after ticks and after applied edits; pooled and moved by ownership, never copied. ADR-019 §3's delivery and interpolation stand. | ADR-028 §3 |
| The extraction hook | `App::publishFrame(scene, simulation)` runs after a tick batch, after each applied batch of edits, and once after the startup load. `ClientApp` fills the packet through `FrameExtraction::extractFramePacket` in `client`. | Miguel, 2026-11-16 (S11-T4); § *The frame packet* |
| A packet at the same tick | Each packet carries a rising sequence. On the current timeline and tick, a newer sequence replaces the current packet and keeps the previous one; an older or equal one is dropped. | Miguel, 2026-11-16 (S11-T4); § *Packet delivery* |
| Matching instances across two packets | By `Entity`, generation included. An instance that appears draws at its current world, and one that vanishes is not drawn. From E2 render interpolates instance worlds and the camera on the CPU every frame. | Miguel, 2026-11-16 (S11-T4); § *Packet delivery* |
| The packet pool | Four packets, moved by `unique_ptr` and never destroyed. The render thread owns the pool. An empty pool is misuse and fires a check. | Miguel, 2026-11-16 (S11-T4); § *Packet delivery* |
| Handing a packet to the history | The mailbox runs the history's acquire while it holds its own lock, so render never holds a third packet. | Miguel, 2026-11-16 (S11-T4); § *Packet delivery* |
| Views | A frame draws one packet into one or more views, each with a target and a camera. The runtime has the window; the editor has its scene view and game view. A hidden view is not drawn. Light clusters depend on the camera, so each view builds its own. | ADR-028 §3 |
| The scene view's camera | It comes from main on ADR-019 §4's latest-value path, not from the packet, so it moves with no packet and no tick. The game view uses the scene's main active camera from the packet. | ADR-028 §3; [[Editor - Design]] § *The layout* |
| The camera component | `Camera` in `core`, registered in both apps like `MeshRenderer`. Perspective only in E2: a vertical field of view, near and far planes, ADR-029 §6's fixed exposure and a `main` flag. Its view comes from the entity's world transform. Orthographic is added when something needs it. | Miguel, 2026-11-14 (S10-D6) |
| The main active camera | A scene has at most one `Camera` with `main` set, and the game view and the runtime draw through it. With none, the view clears to a colour and the app warns once. | Miguel, 2026-11-14 (S10-D6); one at a time, Miguel, 2026-11-16 |
| How one main camera is kept | A `core` function sets a camera as main and clears `main` on every other `Camera`. Every caller goes through it: the editor's commands now, scripts from E11, so the runtime holds the rule too. A `Camera` added to a scene that already has a main camera is added with `main` off; the first camera in a scene is still main by default. Ticking `main` on several selected cameras at once is refused with a warning. Each camera it clears is part of the same edit, so one undo restores them all. | Miguel, 2026-11-16 |
| A scene with two main cameras | An old file, a hand edit or a merge can still bring two. Loading warns once, and the first in hierarchy order wins. The file stays as it is until the user fixes it and saves. | Miguel, 2026-11-16 |
| How the scene view's camera is driven | The scene view panel reads ImGui's mouse and keys on main. A right drag rotates the camera in place, a middle drag pans it, the wheel zooms, and F flies it to the selected entity from any panel. Pan and zoom follow the distance to the selection; Shift speeds every movement up and Ctrl slows it down. There is no WASD. The `InputBuffer` stays detached while Stopped. Orbit stays T3's. | Miguel, 2026-11-14 (S10-D6); the controls, Miguel, 2026-11-20 and 21 (S11-T11); [[Editor - Design]] § *Decided* |
| How main declares the views | A latest-value slot on `Client`. Each ImGui frame, main writes one record per view: its id, its size, whether it is visible, and its camera, either the packet's main camera or a pose main sends. Render reads the slot each frame and creates, resizes or skips each view's target. A client with no record draws one view, the window, through the main camera, so the runtime writes nothing. | Miguel, 2026-11-20 (S11-T10); ADR-028 §3 |
| How ImGui names a view's texture | Main passes a fixed token per view to `ImGui::Image`. On the render thread, the ImGui hook swaps each token for the view's current GL texture name in the draw-data snapshot, just before it draws. GL names never leave render, and a draw replayed after a resize still finds the live texture. | Miguel, 2026-11-20 (S11-T10) |
| The scene view's own pose | Main sends the fly camera's pose through the view slot, so the scene view draws in a scene with no camera. The camera starts at the old fixed pose. | Miguel, 2026-11-20 (S11-T10); built by S11-T11 |
| The device's surface | One handle type per kind, each an index and a generation. The vertex layout lives inside the pipeline. An empty target is the window. A bad description returns an error code; misuse fires a check. | Miguel, 2026-11-15 (S11-T3); § *The device* |
| The renderer is not a scheduled System | It is the extraction hook plus the render-thread frame. | ADR-028 §3, against ADR-006 §5 |
| Uploads cross in order | Mesh, texture and material uploads are never dropped. One GPU copy per resource handle. | ADR-028 §4 |
| Render's fence | Simulation defers a free until render reports the upload done. A reload keeps its handle and sends a new upload. | ADR-028 §4; ADR-024 §6 |
| The GPU copy's lifetime | Render drops a copy on a release request, once no packet in its history names the handle and the GPU has finished the frames that drew it. | ADR-028 §4 |
| How uploads leave the cache | The cache records an upload when an entry of a marked type turns Ready and a release when one is freed, in one ordered list. `ClientApp` sends that list at each publish point, before the packet. | Miguel, 2026-11-17 (S11-T6); § *Uploads and the fence* |
| Render finds resources by handle only | An upload's dependencies travel as the slots its loader named. The upload also carries the entry's `ResourceId`, as a label for render's log lines only; render never looks anything up by an id. | Miguel, 2026-11-17 (S11-T6); § *Uploads: order, reads and shutdown* |
| A replaced payload waits for its upload | A reload's old payload is destroyed only once render reports that payload's upload done. | ADR-024 §6; Miguel, 2026-11-17 (S11-T6) |
| Deferred frees retry at each publish point | Render's finished uploads, each a slot and a token, unpin their payloads, and the cache drains frees, before the outbox is sent. | Miguel, 2026-11-17 (S11-T6); § *Uploads and the fence* |
| Dropping a copy is its own card | S11-T6 builds the queue, the pins and the done reports, and leaves each type's handler empty for S11-T7 and S11-T8. Render keeps every copy until shutdown, and S11-T16 adds the drop. | Miguel, 2026-11-17 |
| E2's frame | Depth pre-pass, light clusters built and filled in compute as in v1, one forward lit pass with CPU-written multi-draws, sky, final image. | ADR-028 §5 |
| Compute from E2 | The device dispatches compute and binds storage buffers. A pass that writes in compute issues GL's coarse memory barrier through the device; per-resource barriers stay out. | ADR-028 §5 §6 |
| Shared geometry buffers | Static meshes share one set: a position buffer, an attribute buffer and a 32-bit index buffer. A new vertex layout gets its own set. A mesh never moves once placed. | ADR-028 §5; § *Geometry buffers* |
| Geometry blocks and their fit | A block holds 1M vertices and 4M indices. A mesh that cannot fit an empty block gets a block sized exactly to it. Free ranges are taken best-fit, the lowest offset on a tie, and a freed range merges with each free range it touches. | Miguel, 2026-11-19 (S11-T7); § *Geometry buffers: placing a mesh* |
| Who owns the mesh | This note owns the GPU streams and attributes; `Content Pipeline - Design` (S10-D9) owns the file. | ADR-028 §5 |
| The vertex attributes | A normal (`float3`), a tangent (`float4`, `w` the bitangent's sign) and UV0 (`float2`), unpacked until measured. A stream a mesh lacks is filled with defaults at upload. Indices are 32-bit only. | S10-D10, 2026-11-09; ADR-028 §5; [[Content Pipeline - Design]] § *The mesh file* |
| A slot with no material entry | It draws with the mesh's default material. | S10-D10, 2026-11-09; [[Content Pipeline - Design]] § *Materials per slot* |
| One backend | No backend interface; Vulkan or D3D12 later replaces the device, not the passes. | ADR-028 §6 |
| A material is a surface and values | A surface is shader code that only fills inputs. A material is an asset in `core` that names one surface and stores its values. The standard material is the engine's own surface, and the only one in E2. | ADR-029 §1 |
| Surface, lobe, light loop | The engine owns the light loop and calls lobes. Its diffuse and specular are lobes from E2. Developers cannot add a lobe until a `/triage` opens the seam. | ADR-029 §2 |
| One lit model | Layers are always in the program and switched by values. A shading model value selects lit or unlit. | ADR-029 §3 |
| Postponed out of E2 | Clear coat, sheen and transmission. | Miguel, 2026-11-09; ADR-029 §3 |
| Draw buckets | Alpha mode (opaque, cut-out, blended) and double-sided are material state, and each combination has its own multi-draw. Cut-outs skip the depth pre-pass. | ADR-029 §4 |
| Shaders are GLSL source | The engine assembles one program per surface and lobe set from its own sources and the surface. No offline compiler, no SPIR-V. | ADR-029 §5 |
| Units | Photometric light values, and a fixed exposure on the camera until R2. | ADR-029 §6 |
| What the standard material samples | Base color, a packed occlusion, roughness and metallic map, a normal and emissive. Wrap and filter live on the texture asset. | ADR-029 §7 |
| Editing a material | Each edit is an undo step, and the file is written on Save. The asset edit path itself is not designed. | Miguel, 2026-11-09; [[Backlog]] § *editor & tooling* |
| The material file | A `.tematerial` is `MATERIAL_KIND` version 1: the id, the import block, the surface, the shading model, the alpha state, then each factor beside its texture, in glTF's terms. | S10-T23 (#203), 2026-11-13; § *The material file* |
| The material buffer | One 96-byte `std430` record per material: the factors, the cutoff, the shading model and four bindless handles. Alpha mode and sidedness pick the bucket, so they stay out of the record. | S10-T23 (#203), 2026-11-13; § *The material buffer* |
| A slot with a null material | It draws the engine's default material, record 0: opaque, lit, single-sided, white, roughness 1, metallic 0 and no textures. A material whose load failed draws it too. | S10-T23 (#203), 2026-11-13; § *The material buffer* |
| The material buffer's size | It starts at 1024 records and doubles when full. A freed record is handed out again first, and a material reload keeps its record. | Miguel, 2026-11-20 (S11-T8, #219); § *The material buffer as built* |
| A texture that arrives after its material | The outbox is not sorted. Render rewrites the record of every material that names the texture when it arrives, which also covers a texture reload. | Miguel, 2026-11-20 (S11-T8, #219); § *The material buffer as built* |
| Which way V runs | Texture rows stay top first, and the geometry upload stores `1 - v` and negates the tangent's `w`, so the shader samples UV0 as it is. | Miguel, 2026-11-20 (S11-T8, #219); [[Content Pipeline - Design]] § *Texture rows and V* |
| How a draw finds its data | Each drawn instance has an 8-byte record: the index of its world and its material record. A command's `baseInstance` points at its first record, so the shader reads `gl_BaseInstance + gl_InstanceID`. Worlds upload once per instance, and no buffer is rebound between multi-draws. v1 did the same (`engine/client/src/renderer/Renderer.cpp:278` at `v1-reference`). | Miguel, 2026-11-20 (S11-T9); ADR-028 §2, amended 2026-11-20 |
| What one draw command holds | One mesh slot in one geometry block and one bucket, with one material, and its instances. The material stays in the key because a bindless handle must be the same for every instance of a command, or GL leaves the sample undefined. v1 grouped by mesh only and relied on NVIDIA tolerating it. | Miguel, 2026-11-20 (S11-T9); § *Materials* |
| A mirrored instance | A world with a negative determinant draws in its bucket's twin, a pipeline whose front face is clockwise. A double-sided bucket has no twin, because it culls nothing. E2 therefore has nine pipelines: each of the three alpha modes as single-sided, mirrored and double-sided. | Miguel, 2026-11-20 (S11-T9) |
| Where linear becomes sRGB | The forward pass's fragment shader encodes its output, until E2's final image pass takes the encode over. The window's framebuffer stays linear, so `platform` does not change. Until then, blending happens on encoded values. | Miguel, 2026-11-20 (S11-T9) |
| How blended materials draw | Last, after opaque and cut-outs, with the depth test on, depth writes off and no sorting. Batches run bucket first across every geometry block, so no block's opaque draws follow another block's blended ones. Overlapping blended surfaces blend in the wrong order until a sort lands ([[Backlog]] § *client*). | Miguel, 2026-11-20 (S11-T9) |
| The camera's axes and depth | As in v1: a camera looks down its local −Z, its view is the inverse of its world matrix, and its projection is `glm::perspective`, with GL's −1 to 1 depth range and `Less`. Reversed-Z waits for a float depth target. | Miguel, 2026-11-20 (S11-T9); v1's `Camera::updateViewMatrix` at `v1-reference` |

## Design

```mermaid
flowchart LR
    subgraph Sim["Simulation thread"]
        X["Extraction hook<br/>reads the Scene"]
        U["Upload requests"]
    end
    subgraph Render["Render thread"]
        H["Packet history<br/>two entries"]
        F["Frame: passes"]
        D["Device"]
        G["GPU copies<br/>by handle"]
    end
    X -->|"packet, latest wins"| H
    H -->|"released packets"| X
    U -->|"ordered, never dropped"| G
    G -->|"upload done, copy dropped"| U
    H --> F --> D
    G --> D
```

### The device

Built by S11-T3 (#207) in `engine/client/src/render/device/`. Only the render thread calls it.
Its surface was settled at the card's `/card-start` (Miguel, 2026-11-15).

| Part | As built |
|---|---|
| Handles | One type per kind: buffer, texture, program, pipeline and render target. Each is an index and a generation, kept in a table per kind (`render/device/RenderSlots.hpp`). Destroying a slot raises its generation, so an old handle stops resolving; a slot at the generation limit is retired. |
| Data | One folder per kind holds its description, its enums and the record the device keeps. Every GL call is in `RenderDevice.cpp`. |
| Buffers | Immutable storage. A Static buffer takes all its data at creation; only a Dynamic one accepts `updateBuffer`. |
| Textures | `Rgba8`, `Rgba16F` and `Depth32F` for targets. The asset formats `Bc7Srgb`, `Bc7Unorm`, `Bc5Unorm` and `Rgb9E5` take their pixels level by level through `updateTexture` and cannot be a target's colour. Wrap and filter come from the description, and a texture with mips is sampled trilinear, or nearest-mipmap-nearest when its filter is `Nearest`. `makeTextureResident` makes one bindless handle, and only once. `readTexture` reads level 0 of a target format, and `Rgba16F` comes back as 32-bit floats. |
| Pipelines | The program, the vertex layout with its strides, topology, cull, front face, depth and blend. `bindPipeline` applies all of it every time, and forgets the bound index buffer, because that lives in the pipeline's vertex array. |
| Render targets | One colour texture and an optional depth texture, which the target does not own. |
| Passes | An empty target is the window. The extent sets the viewport and the scissor, so a clear covers the extent only, and the scissor test is off again when the pass ends. Each pass starts with nothing bound and ends with the window's framebuffer bound, because ImGui's backend draws into whatever is bound (S11-T10). |
| Failures | A description the device cannot build returns a `ClientError` and creates nothing. Misuse, such as a stale handle, a draw outside a pass or a pass larger than its target, fires one `TE_CHECK` and returns before any GL call. |
| Multi-draws | `drawIndexedIndirect` reads its `IndexedIndirectCommand` records from a buffer, at a byte offset, and binds that buffer to `GL_DRAW_INDIRECT_BUFFER` itself, because with none bound GL reads the offset as a client pointer. `bindUniformBuffer` binds a range, as `bindStorageBuffer` does (S11-T9, #220). |

- **Not built yet:** compute dispatch (the light clusters). Store actions are accepted and
  ignored, so `DontCare` does not invalidate anything yet.
- **A target needs a colour texture.** A depth-only target, which E3's shadow maps need, is
  refused today as `InvalidRenderDescription`.
- **The window's depth clear** runs whether or not the window has a depth buffer; without one,
  GL ignores it.

### The frame packet

Built by S11-T4 (#210, `4d0b8e0`, Nov 16). A packet is everything render needs from the `Scene` for one frame, with
handles and values only, never a pointer into the `Scene`
(`engine/client/include/TechEngine/client/render/FramePacket.hpp`).

| Field | Holds |
|---|---|
| Timing | The tick, its time, the fixed step and the timeline, as the snapshot carried them. |
| Sequence | A number that rises on every publish, so render can order packets that share a tick. |
| Input | The held input at the publish. |
| Instances | One per `MeshRenderer`: its `Entity`, its world matrix, its mesh handle, and a range of slots in the packet's material list. |
| Materials | One handle per slot, in slot order. A null handle is a slot with no material. |
| Camera | Whether the scene has a main active camera, and if so its settings and world matrix. |

- **Why it moves instead of being copied.** The snapshot was copied about four times per frame.
  A packet holds 64 bytes of matrix per instance, which is about 64 MB in E2b's stress scene.
- **Why it is published after edits and after the startup load.** A Stopped editor never ticks,
  so a packet sent only after ticks would never show an edit or the loaded scene.
- **Its vectors keep their capacity.** Extraction clears them without shrinking, and packets are
  never destroyed, so a warm frame allocates nothing.

### Packet delivery

Where each packet lives, and which thread moves it:

```mermaid
flowchart TB
    subgraph Sim["Simulation thread"]
        P["Publish point<br/>after ticks, after edits,<br/>after the startup load"]
        F["Filling<br/>extractFramePacket<br/>reads the Scene"]
    end
    subgraph Shared["Shared, each behind its own lock"]
        Pool[("Pool<br/>four packets")]
        Slot["Mailbox slot<br/>latest wins"]
    end
    subgraph Render["Render thread"]
        H["History<br/>previous and current"]
        V["FrameView<br/>interpolated worlds"]
        R["FrameRenderer<br/>draws"]
    end
    P --> F
    Pool -->|"acquire"| F
    F -->|"publish, moved"| Slot
    Slot -->|"unread packet replaced"| Pool
    Slot -->|"deliverTo, under the slot's lock"| H
    H -->|"dropped or rejected"| Pool
    H -->|"prepareFrame"| V
    V --> R
```

- **Four packets are enough:** one being filled, one in the slot and two in the history.
- **Render must never hold a third.** If render took the packet out of the slot and only then gave
  it to the history, it would hold three for a moment. Simulation could then publish into the
  empty slot and acquire from an empty pool. So the mailbox runs the history's acquire under its
  own lock, and simulation's publish waits on that lock for a few pointer moves at most.
- **The history's rules.** A new timeline replaces both entries. On the current timeline, a newer
  tick moves the current packet to previous, and a newer sequence at the same tick replaces the
  current packet in place. Anything older is dropped. Every packet it lets go returns to the pool.

### Packet delivery: the call order

```mermaid
sequenceDiagram
    participant S as Simulation thread
    participant Pool as Pool
    participant M as Mailbox slot
    participant R as Render thread
    S->>Pool: acquire()
    Pool-->>S: a free packet
    S->>S: fill timing, sequence and input, then extract the Scene
    S->>M: publish(packet)
    M-->>Pool: release the unread packet, if there was one
    loop every render frame
        R->>M: deliverTo(history)
        Note over M,R: the slot's lock is held while the history acquires
        M->>R: the packet moves into the history
        R-->>Pool: release the oldest or a rejected packet
        R->>R: prepareFrame matches by Entity and interpolates
        R->>R: draw the FrameView
    end
```

- **The frame view is render's own.** `prepareFrame` fills a reused `FrameView` with one world
  per instance of the current packet, in the same order, and points it at that packet. The next
  acquire can free the packet, so the view is good for one frame only.

### Uploads and the fence

Designed at S11-T6's `/card-start` (Miguel, 2026-11-17). How render drops a copy is S11-T16's
(§ *Open questions*).

```mermaid
flowchart LR
    subgraph Sim["Simulation thread"]
        C["ResourceCache<br/>outbox, pins, retired payloads"]
        P["Publish point<br/>ClientApp"]
    end
    subgraph Shared["Shared, each behind its own lock"]
        Q["Upload queue<br/>never drops"]
        D["Done reports"]
    end
    subgraph Render["Render thread"]
        H["Handler per type"]
        T["Copies by handle"]
    end
    C -->|"take the outbox"| P
    P -->|"uploads and releases, in order"| Q
    Q --> H --> T
    H -->|"slot and token"| D
    D -->|"finished uploads"| P
    P -->|"unpin, then drain frees"| C
```

| Part | How it works |
|---|---|
| Marked types | The client apps mark `Mesh`, `Texture` and `Material` for upload beside their loaders, before registration closes. A server marks none, so its cache records nothing and no free ever waits. |
| An upload | Recorded when an entry of a marked type turns Ready, on a first load or a reload. It carries the handle, the type tag, a pointer to the payload, the slots of the dependencies its loader named (in the loader's order), a rising token, and the entry's `ResourceId` as a log label. A failed or absent entry sends none. |
| A release | Recorded when a Ready entry of a marked type is freed, in the same list as the uploads, so a handle's release never passes its upload. An entry that never turned Ready sends none, even one that holds a payload because its dependencies failed. |
| The pin | An upload pins the payload it points at until render reports that upload's slot and token. The cache finds the entry by the slot, so it never searches for a token. `drainFrees` defers an entry whose payload is pinned, as it already defers one that is still loading. |
| A reload | The new payload goes in at once and sends its own upload. A pinned old payload moves to a retired list under its token and is destroyed when that token comes back; an unpinned one is destroyed at once, as before. ADR-024 §6 counts the replacement as a free. |
| The publish point | `ClientApp` hands render's finished uploads to the cache, drains frees, then sends the outbox, all before it acquires a packet. A publish point follows a loading phase or a tick batch, so this keeps ADR-024 §3's rule on when memory is freed. |
| Render | After `deliverTo`, it takes every queued record in order. An upload runs its type's handler, then reports its slot and token; a release is recorded. The handlers are S11-T7's (meshes) and S11-T8's (textures and materials), and until S11-T16 every copy lives until shutdown. |

### Uploads: order, reads and shutdown

- **Done means the CPU finished reading the payload**, not that the GPU finished with the copy.
  GL's buffer and texture upload calls copy client memory before they return, so a handler
  reports as soon as it returns. A mapped or asynchronous upload would have to report later.
- **Render drains the queue after `deliverTo`, never before.** Simulation queues an upload before
  it publishes the packet that names the handle, so any packet render holds has its uploads
  queued already. Draining first leaves a gap in which a packet arrives naming a handle that
  render has not seen.
- **No upload waits on a packet.** The publish point sends the outbox before it acquires a
  packet, so an empty pool (`apps/clientapp/src/ClientApp.cpp:56`) never holds an upload back.
- **An id is a label, never a key.** A payload names its dependencies by `ResourceId`
  (`MeshSlot::defaultMaterial`, and a `Material`'s `AssetRef<Texture>` fields, whose handles
  nothing fills in a cached payload). Render keys its copies by handle and finds a dependency
  only through the upload's slots, matched by position in the loader's order. It keeps the
  upload's id beside each copy so that a release, which arrives after the payload may be gone,
  can still name the asset in a log line.
- **Shutdown.** The simulation shuts the cache down while render still runs
  (`engine/app/src/SimulationThread.cpp:249`, `:256`); render stops later, in `App::shutdown`.
  Pinned payloads stay valid only because `ClientApp::m_client` is destroyed before
  `App::m_resources`. Records still queued when render stops are discarded.
- **A render thread that failed never reports**, so its pinned entries are never freed. The app
  is stopping by then, so nothing is lost.

### Geometry buffers

| Buffer | Holds |
|---|---|
| Positions | Every static mesh's positions, 12 bytes each. |
| Attributes | Every static mesh's other attributes, interleaved: normal, tangent and UV0, 36 bytes. |
| Indices | Every static mesh's indices, 32-bit. |

One vertex array binds the two vertex buffers to two bindings.

- **Why positions are apart.** The depth pre-pass reads only positions, and from E3 so does
  every shadow pass. Interleaved, each vertex fetch would pull the whole vertex into the cache
  to use 12 bytes of it. All five engines in [[Renderer - Research Brief]] § *Q2 mapped* split
  them for the same reason. The gain is not measured on Sponza or Bistro.
- **One vertex index, two buffers.** A mesh's vertices sit at the same index range in both
  vertex buffers, so one `baseVertex` serves both streams.
- **Fixed size, immutable storage.** The set is created once with `glNamedBufferStorage`,
  sized at startup, and never resized. When it fills, a second block is added, and each block
  draws with its own multi-draw.
- **A free-list allocator, and meshes never move.** A freed range goes back to the list when
  render drops the mesh's GPU copy (ADR-028 §4), so no frame the GPU is still drawing reads it.
- **What v1 did, and why not again.** v1 grew its buffers by reallocating and copying them
  (`engine/client/src/renderer/mesh/VertexBuffer.cpp:100-108` at `v1-reference`). Removing a
  mesh copied the buffer's tail down over it and shifted every later mesh's offsets
  (`engine/client/src/renderer/resources/GpuResourceManager.cpp:99-112`). That costs a copy of
  the buffer per removal, and it moves offsets that frames still in flight use, which ADR-028
  §3's packets cannot allow.
- **Not in this set:** geometry the CPU rewrites each frame (debug lines, UI) gets its own
  streaming buffer, so it never fragments the static set.

### Geometry buffers as built

Built by S11-T7 (#217, `5ed5875`) in `engine/client/src/render/GeometryBuffers.cpp`. The block size, the
oversize rule and the fit are Miguel's (2026-11-19).

```mermaid
flowchart TB
    RT["RenderThread::threadMain"] --> GC["GpuCopies<br/>one copy per slot"]
    GC --> GB["GeometryBuffers"]
    GC --> CP["A mesh's GpuCopy<br/>holds its GeometryRange"]
    GB --> B0["Block 0, created at startup"]
    GB --> B1["Block 1, added when no block fits"]
    B0 --> P["Position buffer<br/>12 bytes per vertex"]
    B0 --> A["Attribute buffer<br/>36 bytes per vertex"]
    B0 --> I["Index buffer<br/>4 bytes per index"]
    B0 --> FL["Two free lists<br/>vertices and indices"]
    CP -.->|"block, baseVertex, firstIndex"| B0
```

| Part | As built |
|---|---|
| Ownership | `GpuCopies` owns `GeometryBuffers`. `RenderThread::threadMain` initializes it after the GL check, and shuts it down before the device. |
| A block | Three `Dynamic` buffers, which are immutable storage with `GL_DYNAMIC_STORAGE_BIT`, because a `Static` buffer refuses `updateBuffer`. Beside them, two free lists: one counted in vertices and one in indices. |
| Its size | `GEOMETRY_BLOCK_CAPACITY` is 1M vertices and 4M indices, so 12, 36 and 16 MB. Block 0's buffers are created by `initialize`; a later block's are created when its first mesh lands. |
| A range | `GeometryRange` holds the block, `baseVertex`, `firstIndex` and the two counts. The mesh's `GpuCopy` keeps it, because the payload is gone once the upload reports done. |
| The attribute record | `GeometryAttributes` puts the normal at byte 0, the tangent at 12 and UV0 at 28. A stream the mesh lacks takes import's defaults: normal (0, 1, 0), tangent (1, 0, 0, 1), UV0 (0, 0). |
| An empty mesh | A mesh with no positions or no indices gets an empty range, with no error and no GL call. Import never writes one, but `Mesh::read` accepts both, and it is a valid file with nothing to draw. |

- **Not built yet:** nothing frees a range until S11-T16 drops a mesh's copy. Until then a
  reload replaces the copy in `GpuCopies::apply`, and the old range is never returned
  ([[Known Issues]] D14). The payload is gone once the upload reports done, so `uploadMesh`
  copies each slot's index range and default material into the copy's `meshSlots` (S11-T9).
- **The allocator is tested headless** (`engine/client/tests/render/GeometryBuffersTests.cpp`).
  No test reads the GL writes back; S11-T9's frame (#220) drew Sponza from them.

### Geometry buffers: one block's layout

An example block with two meshes and one freed hole between them:

```mermaid
flowchart LR
    subgraph V["Position and attribute buffers, counted in vertices"]
        direction LR
        VA["Mesh A<br/>0 to 99"] --- VH["Free<br/>100 to 149"] --- VB["Mesh B<br/>150 to 399"] --- VT["Free<br/>400 to the end"]
    end
    subgraph X["Index buffer, counted in indices"]
        direction LR
        XA["Mesh A<br/>0 to 299"] --- XH["Free<br/>300 to 449"] --- XB["Mesh B<br/>450 to 1199"] --- XT["Free<br/>1200 to the end"]
    end
```

- **One vertex number, two buffers.** Vertex 150 is mesh B's first vertex in both vertex
  buffers, so B draws with `baseVertex` 150 and `firstIndex` 450.
- **Indices are not rewritten.** A mesh's indices stay relative to its own first vertex, and
  `baseVertex` adds the offset at draw time.
- **Each free list is sorted by offset.** The list above holds `{100, 50}` and `{400, rest}`
  for vertices. A freed range merges with the free range before it, the one after it, both or
  neither, and only where the two touch exactly.
- **Misuse fires a check and changes nothing:** a freed range that overlaps a free one (a
  double free), a block that does not exist, or a take from a range too small. Freeing an
  empty range does nothing.

### Geometry buffers: placing a mesh

```mermaid
flowchart TD
    U["GpuCopies::uploadMesh"] --> E{"Any positions<br/>and any indices?"}
    E -->|"no"| Z["Empty range, no GL call"]
    E -->|"yes"| S["Search the blocks in order"]
    S --> F{"A best fit for the vertices<br/>and the indices, in one block?"}
    F -->|"yes"| T["Take from both free lists"]
    F -->|"no block has both"| O{"Would it fit an<br/>empty default block?"}
    O -->|"yes"| N["Add a default block"]
    O -->|"no"| X["Add a block sized<br/>exactly to the mesh"]
    N --> T
    X --> T
    T --> C{"Does the block<br/>have its buffers?"}
    C -->|"no"| CB["Create them; on failure,<br/>free the range and fail"]
    C -->|"yes"| W["Write positions, interleaved<br/>attributes and indices"]
    CB --> W
```

- **Best-fit.** The smallest free range that holds the count, with the lowest offset on a tie.
  Both lists are searched before anything is taken, so a block where only the vertices fit
  changes nothing.
- **One block per mesh.** A mesh's vertices and indices sit in the same block, because each
  block draws with its own multi-draw.
- **An oversize block is exact.** A mesh too big for an empty default block gets a block of
  exactly its vertices and indices. Taking the larger of the default and the mesh in each
  dimension would fill one dimension and strand the other's space, up to 16 MB of indices.
- **Why best-fit and not first-fit.** Sponza's meshes differ in size by 100x or more, and
  best-fit keeps large holes whole for a large re-import. It costs a full scan instead of
  first-fit's early exit, which is nothing at tens of holes per block. Johnstone and Wilson
  (ISMM 1998) found address-ordered first-fit and best-fit about equally low in fragmentation.
  From memory and unchecked, Unreal's GPU Scene uses a first-fit span allocator that merges.
  The merge matters more than the fit, and neither is measured here.

### Materials

How a program is put together, from ADR-029 §1, §2 and §5:

```mermaid
flowchart LR
    S["Surface<br/>fills the inputs"] --> P["One program"]
    L["Lobes<br/>diffuse, specular"] --> P
    E["Engine source<br/>declarations, light loop"] --> P
    P --> B["One multi-draw<br/>per draw bucket"]
    M["Material buffer<br/>one record per material"] -->|"draw record"| B
```

- **A draw command** is one mesh slot with one material, and its instances. Commands are
  grouped by program, then by bucket.
- **The material buffer** holds one record per material, with the same layout for every
  material of one surface: the values, then a bindless handle per texture. An edit rewrites one
  record through ADR-028 §4's ordered channel. The standard surface's record is in § *The
  material buffer*.
- **An empty texture input** uses its factor alone.
- **Adding a layer later** (clear coat, sheen): new inputs that default to zero, new record
  fields, one lobe, and a version step of the material file.
- **A variant per layer set** stays possible behind the same files. If the layer tests measure
  too slow, the engine can compile a program for materials that leave a layer at zero. Unity,
  Unreal and Godot work this way from the start.

### The material file

Built by S10-T23 (#203) in `engine/core/src/material/Material.cpp`. A `.tematerial` is `MATERIAL_KIND`
at version 1, a binary blob like the texture. In order:

- **Its id, straight after the header**, for the asset index's 16-byte read.
- **The import block**, with the default settings.
- **The surface**, a `u8` that is always `Standard` in E2. A developer's surface is a new value.
- **The shading model** (`u8`: lit or unlit), **the alpha mode** (`u8`: opaque, cut-out or
  blended), **the cutoff** (`f32`, 0.5 by default) and **the double-sided flag** (`u8`).
- **Base color:** a `float4` factor, then its texture id.
- **Occlusion, roughness and metallic:** three `f32` factors (occlusion strength, roughness,
  metallic), then the packed texture's id, with occlusion in red, roughness in green and metallic
  in blue.
- **Normal:** an `f32` scale, then its texture id.
- **Emissive:** a `float3` factor, then its texture id.

A texture id of 0 is an empty input. The factors and their defaults are glTF's, so S10-T24 copies
a source material field by field: white base color, roughness and metallic 1, occlusion strength
and normal scale 1, emissive 0.

- **Read refuses** an unknown surface, shading model or alpha mode, a double-sided byte other
  than 0 or 1, and bytes after the emissive texture, each as `Malformed`. The factors are not
  range-checked.
- **The loader lists each non-null texture** in input order, once per input that names it, as the
  mesh's loader does with its default materials.
- **A layer later** (clear coat, sheen) appends its factors and textures and steps the version.

### The material buffer

The standard surface's record, one per material, in a `std430` storage buffer that each drawn
instance indexes through its draw record. It holds only what the shader reads:

| Offset | Field | Type |
|---|---|---|
| 0 | Base color factor | `vec4` |
| 16 | Emissive factor | `vec3` |
| 28 | Alpha cutoff | `float` |
| 32 | Occlusion strength, roughness, metallic, normal scale | 4 × `float` |
| 48 | Base color, packed ORM, normal and emissive handles | 4 × `uvec2` |
| 80 | Shading model, 0 lit or 1 unlit | `uint` |
| 84 | Padding to the record's 16-byte alignment | 3 × `uint` |

- **Handles are `uvec2`**, turned into a `sampler2D` in the shader, so the shader needs no 64-bit
  integer extension. A zero handle is an empty input, and the shader uses the factor alone.
- **Not in the record:** the alpha mode and the double-sided flag pick the draw bucket (ADR-029
  §4), and the surface picks the program.
- **The shading model is a value**, so an unlit material shares its bucket's multi-draw and the
  branch is uniform across each draw.
- **Record 0 is the engine's default material**, written by render at startup and never freed.
  A slot whose material is null or failed to load draws with it. It is visible and neutral, so a
  mesh imported before S10-T24 still shows; a missing material does not hide a mesh, and nothing
  flags it as an error.

### The material buffer as built

Built by S11-T8 (#219) in `engine/client/src/render/MaterialBuffer.cpp`, owned by `GpuCopies`.
The record is `GpuMaterial` in `render/device/material/Material.hpp`, where its base color
factor is named `albedo`.

- **A copy of every record stays on the CPU.** `allocate` grows only that copy. The next
  `write` that finds the GPU buffer smaller replaces it with a `Dynamic` buffer holding every
  record, so a frame binds the buffer it gets after its uploads, never one kept from before.
- **Misuse fires a check and changes nothing:** freeing record 0, a record never handed out, or
  a record already free.
- **A material finds its textures through its dependency slots**, in input order, skipping the
  inputs that name no texture. An input whose texture has not arrived stays zero until it does.
- **A texture upload creates the texture, fills every level, makes it resident**, then rewrites
  each material copy that names its slot. It scans every copy to find them; a map from texture
  slot to material copies replaces the scan if a profile shows it.
- **A material whose write failed draws record 0**, and the texture rewrite skips it, so record
  0 is never overwritten.

### The forward pass as built

Built by S11-T9 (#220) in `engine/client/src/render/FrameRenderer.cpp` and `DrawList.cpp`. Its
calls are the *Decided* rows from *How a draw finds its data* to *The camera's axes and depth*.

```mermaid
flowchart LR
    V["FrameView<br/>packet and worlds"] --> C["collectDraws<br/>one DrawItem per mesh slot"]
    G["GpuCopies<br/>mesh slots, material records"] --> C
    C --> L["DrawList::build<br/>sort, group, batch"]
    L --> S["Per-frame buffers<br/>uniforms, worlds, draw instances, commands"]
    S --> D["Per batch: pipeline, block buffers,<br/>drawIndexedIndirect"]
```

- **A slot's material.** Inside the instance's material range it is the packet's. A null one, one
  not uploaded yet, or one whose write failed draws record 0, opaque and single-sided. A slot past
  the range takes the mesh slot's default.
- **Commands.** `DrawList` sorts its items by bucket, block, index range and material. Equal
  neighbours share a command, and each command's `baseInstance` is its first `DrawInstance` (a
  world index and a material record). Batches run bucket first, so no block's opaque draws follow
  another block's blended ones.
- **Three programs from one source.** Forward, cut-out (`TE_ALPHA_CUTOUT`, which discards under
  the cutoff) and blended (`TE_ALPHA_BLENDED`). Only the blended one writes the material's alpha;
  the others write 1, as glTF's opaque and mask modes require. The nine pipelines pick from them.
- **Per-frame buffers** are `Dynamic`, and grow to the larger of the data and twice their size. A
  frame with no batch only clears, and a failed write skips that frame's draws with one error.
- **The material buffer is bound with `getBufferSize()`**, the GPU buffer's size, because
  `getCapacity()` counts CPU records, which can outgrow it.
- **Tests.** `DrawListTests` run headless. `FrameRendererTests` draw a cube seen from inside, so
  they pass whichever axis the camera looks along.

### The editor's views as built

Built by S11-T10 (#221), by the *Decided* rows from *How main declares the views* to *The scene
view's own pose*.

```mermaid
flowchart LR
    P["View panels on main<br/>size, visibility, camera"] -->|"ViewRequest per view, every ImGui frame"| S["ViewSlot<br/>latest value"]
    S --> R["RenderThread::drawViews"]
    R --> T["ViewTargets<br/>one target per sized view"]
    R --> F["FrameRenderer<br/>prepare once, draw per view"]
    T -->|"token and GL name"| B["ImGui hook<br/>swaps tokens in the draw data"]
```

- **One prepare, one draw per view.** `FrameRenderer::prepare` collects, builds and writes the
  worlds, instances and commands once per frame; `draw(ViewDraw)` writes only the view's
  uniforms. A null camera only clears.
- **The window.** A client that never declared views draws the window through the main camera,
  so the runtime is unchanged. With views, the window is only cleared, and ImGui covers it.
- **Targets** are `Rgba8` with `Depth32F`, keyed by the view's token. A changed size replaces
  them, a size of 0 has none, and a hidden view keeps its target. A view that fails is left out,
  the others are still built, and the next frame retries it.
- **Tokens** carry `VIEW_TEXTURE_TOKEN_BIT` (`RenderView.hpp`), so the editor's
  `ViewTextureSwap` can tell a token from a texture name even before its target exists; such a
  token draws texture 0. It restores the tokens after drawing, because the bridge draws the same
  snapshot again when main publishes nothing new.
- **The image's V runs 1 to 0** (`ViewPanel::onDraw`), because a GL target's first row is its
  bottom. The panels push zero window padding through `Panel::addStyleVar`, as v1 did.

### The scene view's fly camera as built

Built by S11-T11 (#222, `a4c65ce`, Nov 21), by the row *How the scene view's camera is driven*.
`FlyCamera` (`apps/editor/src/edit/FlyCamera.hpp`) takes a plain input record and never touches
ImGui. `SceneViewPanel::updateCamera` fills that record on main, and `describeCamera` sends the
pose through the view slot. The numbers are the lane's calls; the controls are Miguel's.

- **Drags.** A right or middle press on the view starts a drag that lasts until the button is
  released, even off the panel. While either lasts, `EditorApp` locks the cursor with
  `GLFW_CURSOR_DISABLED`, which hides it, keeps reporting motion past the screen's edge, and puts
  it back where the drag began. `ImGui::TeleportMousePos` was tried first and cannot work: ImGui
  drops every mouse position event in the frame after a teleport, so the drag read no motion.
- **Distance.** Zoom and pan scale with the distance to the selected entity, clamped to 1 to
  2000 m, or 5 m with no selection. A wheel step zooms a fifth of it, measured from where a zoom
  still under way ends, so quick steps toward the selection shrink instead of passing it. A pan
  keeps a point at that distance under the cursor. Shift multiplies rotation, pan and zoom by 3,
  and Ctrl by 0.25.
- **Easing.** Rotation, pan and zoom each ease exponentially toward their target, at 30/s, 20/s
  and 15/s, so the result does not depend on the frame rate; one update is clamped to 0.1 s.
  `FlyCamera::isMoving` stays true until each arrives, and main asks for frames until then
  ([[Editor - Design]] § *Decided*).
- **Focus.** F works from any panel unless a text field takes input. The camera turns to face
  the target from where it is and eases there over 0.4 s, the short way round in yaw, dropping any
  pan or zoom under way. It stops at 2.5 times the entity's largest world-scale axis, and never
  closer than 1.5 m ([[Backlog]] § *editor & tooling* has the bounds gap). Rotating, panning or
  zooming cancels it.
- **Tests.** `FlyCameraTests` cover the camera headless. `SceneViewPanelTests` drive the real
  panel through an ImGui context with no backend, fed events the way the GLFW backend feeds them,
  which is what would have caught the teleport.

### Build notes

Mechanism sections land as the build cards are cut. Known build work:

- **The GL floor is enforced at startup** (S11-T2, #206). glad2 loads 4.6 core with
  `GL_ARB_bindless_texture` (`external/glad/include/glad/gl.h` records the command), and the
  window requests a 4.6 core context (`engine/platform/src/window/Window.cpp:59-60`). The render
  thread starts only if `meetsGlRequirements` passes
  (`engine/client/src/render/RenderThread.cpp:94-99`). It takes what glad loaded as a
  `GlSupport` value and logs one error per missing requirement, so it is tested headless
  (`engine/client/tests/render/GlRequirementsTests.cpp`).
- **CI's software GL cannot meet the floor**, and only zink over lavapipe on Linux does,
  through an EGL context (ADR-028 § *Consequences*, S11-D1). On Linux the window uses EGL
  always, not only on CI, and the cases that draw or load GL are a `[gpu]` tier that CI runs on
  Linux only ([[ADR-008 - v2 build & testing baseline]]'s Nov 14 amendment, S11-D5).
- **The camera component** (S11-T5, #208, `4e05985`, merged Nov 16). `Camera` lives in
  `engine/core/include/TechEngine/core/camera/Camera.hpp`. The field of view is in degrees, the
  exposure is EV100 (the frame is scaled by `1 / (1.2 * 2^EV100)`, default 0), `main` defaults
  to true, and near and far default to 0.1 and 1000. `findMainCamera` takes the caller's
  warn-once flag and clears it when it finds a camera, so each view keeps its own flag. These
  were the lane's calls, listed in #208; Miguel merged it with none reversed.
- **One main camera per scene** (S11-T4, #210). `Camera::findMainCamera`, `setMainCamera` and
  `countMainCameras` are static members of `Camera`
  (`engine/core/src/camera/Camera.cpp`). The lookup counts main cameras with a const query
  and walks the tree through `getChildren` only when two or more tie, so a normal scene never
  walks. The inspector's `main` tick and the add-component command go through them
  (`apps/editor/src/edit/InspectorCommands.cpp`), and `SceneAsset::read` warns on two.
- **GPU captures** go through Nsight, since RenderDoc cannot capture bindless GL (Miguel, v1).
- **The light clusters follow v1's two dispatches:** one builds each cluster's bounds, one
  assigns lights. v1 ran both every frame and read the light count from the live `Scene`
  (`engine/client/src/renderer/passes/LightCullingPass.cpp:19-49` at `v1-reference`). Here the
  lights come from the packet, and the bounds depend only on the projection and the viewport,
  so they are rebuilt only when one of those changes.

## Open questions

- **How render drops a copy safely,** for a release and for a reload's old copy. Three checks
  are owed: no packet in the history names the handle, no live copy names it as a dependency (a
  texture under its material, a default material under its mesh, since `freeEntry` releases a
  holder and its dependencies in the same drain), and the GPU finished the frames that drew it.
  The lean for the last check is a `glFenceSync` per frame, polled with a zero timeout, rather
  than a fixed frame count. Owner: S11-T16.
- **Whether instance interpolation moves to the GPU.** From E2 the CPU interpolates every
  instance each frame (§ *Decided*). The GPU could do it from both packets' buffers instead.
  Owner: E2b, measured against the stress scene.
- **How a world matrix is interpolated.** S11-T4 shipped a column-wise lerp of the matrix
  (`engine/client/src/render/PacketHistory.cpp`), which is exact for a translation but shrinks
  a mesh partway through a rotation. A slerp needs the packet to carry position, rotation and
  scale beside the matrix. The camera's field of view and planes follow the current packet, as
  shipped. Owner: the first card that shows something rotating, or E2b.
- **Orbit around the selection** for the scene view's camera. The fly camera and its focus are
  decided (§ *Decided*). Owner: T3's viewport tools.
- **The anti-aliasing method** for the brief's smooth edges. MSAA suits forward shading.
  Owner: none since S11-T9 left it out (Nov 20); the next R1 cut assigns it.
- **The lit model's terms.** [[Renderer - Materials Paper Report]] § *What S10-D7 still has to
  decide* lists them, and ADR-029 leaves them here because they change no file. The leans, none
  of them decided: Lambert diffuse, the height-correlated Smith visibility term, energy
  compensation from the start because it shares the split sum's table, and a fixed 4%
  reflectance as glTF has. Owner: R1's lit pass card.
- **How the sky image becomes lighting:** the filtered levels for rough reflections and the
  diffuse light, built at load or at import. The file is one 2D `RGB9E5` image with ordinary mips
  ([[Content Pipeline - Design]] § *The sky image*). Owner: R1's sky card.
- **How a developer's surface declares its values,** and how a Script sets one on a single
  entity. Owner: the surface shader card, alongside E11.
- **Whether developers may write lobes.** The seam is internal. Owner: a `/triage`.
- **Where the project names the renderer's settings asset** ([[Resources - Design]] §
  *Open questions*, owner R1).
- **Whether lights go only to occupied clusters,** found from the depth pre-pass, or to every
  cluster as v1 did. With hundreds of lights, every cluster may be enough. Owner: E2b.
- **An ordered pass list or a render graph.** E2 needs only the list; ADR-013 §8's GPU zones
  attach to each pass either way.

## References

- The packet path that replaced M4's snapshot (S11-T4, #210): `engine/client/src/render/`,
  `PacketMailbox.cpp`, `PacketHistory.cpp` and `FramePacketPool.cpp`.
- At `6836c87`, the copies ADR-028 removed were `SnapshotMailbox.cpp:6`, `:14` and
  `SnapshotHistory.cpp:17-29`, `:42`.
- The publish points: `engine/app/src/SimulationThread.cpp:189-191`, `:211-214`, `:226-229`.
