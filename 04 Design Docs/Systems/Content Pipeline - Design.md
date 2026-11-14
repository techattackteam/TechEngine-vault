# Content Pipeline: Design

> Living design doc. It turns a source file (glTF, FBX, OBJ) into runtime-form assets that the
> export packs unchanged. It is the hub for import work: plan and ground Story H from here.

**Module:** `core` (the model and mesh formats, the import block) · `apps/editor` (assimp, the
import, placement)
**Kind:** system
**Status:** the model is designed (2026-11-06, S10-D9) against engine `a67c4d4`. TEMesh v2,
materials per slot, the merged mesh and re-import are designed (2026-11-09, S10-D10) against
`ac594e4`, from [[Content Pipeline - Mesh Import Report]]. Textures are designed (2026-11-10,
S10-D11) against `ccece28`. assimp is in
the editor's build with only its glTF, FBX and OBJ importers (S10-T13, `cmake/deps.cmake`). The
model file and the import block are built, with write and read (S10-T14,
`engine/core/include/TechEngine/core/model/Model.hpp` and
`engine/core/include/TechEngine/core/assets/ImportBlock.hpp`). The import is built (S10-T15,
`apps/editor/src/assets/ModelImporter.hpp`). The placement is built (S10-T16,
`apps/editor/src/edit/PlaceModelCommand.hpp`). TEMesh v2's file is built, with write and read
(S10-T17, `engine/core/include/TechEngine/core/mesh/Mesh.hpp`). Import writes the vertex streams
(S10-T19, `apps/editor/src/assets/MeshImporter.hpp`).

Six more cards are built, merged together in #203 (`25c93a4`, 2026-11-14). CI passed every leg,
but no menu entry has been tried in a window and no real asset has been imported through them:

- **S10-T20, the merged mesh:** `apps/editor/src/assets/ModelImporter.hpp`, `MeshImporter.hpp`
  and `apps/editor/src/edit/PlaceModelCommand.hpp`.
- **S10-T21, reload and re-import:** `ResourceCache::reload`
  (`engine/core/include/TechEngine/core/resources/ResourceCache.hpp`),
  `apps/editor/src/assets/ReimportMatcher.hpp`, which also reads the old outputs, and
  `apps/editor/src/edit/ReimportCommand.hpp`.
- **S10-T22, the texture file:** `engine/core/include/TechEngine/core/texture/Texture.hpp`.
- **S10-T23, the material file:** `engine/core/include/TechEngine/core/material/Material.hpp`,
  written up in [[Renderer - Design]] § *The material file*.
- **S10-T24, materials and textures at import:** `apps/editor/src/assets/MaterialImporter.hpp`,
  `TextureImporter.hpp` (encoding and the mip chain) and `ImageDecoder.hpp` (DDS decoding).
- **S10-T25, the sky image:** `apps/editor/src/assets/TextureImporter.hpp` (`importSky`,
  `reimportSky` and the `RGB9E5` packing), `ImageDecoder.hpp` and
  `apps/editor/src/edit/ImportSkyCommand.hpp`.

The calls these cards took that no artifact had made are recorded in the *as built* subsections
below. The implementation took them, and #203 merged them with no review conversation. Miguel
accepted them as merged on 2026-11-14, with no reversal.

**ADRs:** [[ADR-025 - Content packs (.tepack and the runtime load path)]] §6 ·
[[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §9 (amended 2026-11-09) ·
[[ADR-026 - Reference fields and scene-held acquires]] §2 §3 ·
[[ADR-027 - Editor threads, edit commands and play sessions]] §3 ·
[[ADR-028 - Render device seam and frame packets]] §5
**Product:** [[Content Pipeline - Brief]] · **Backlog:** [[Backlog]]

## Purpose

Import reads a source file once, in the editor, and writes the engine's own files: a model,
its meshes, its materials and its textures. Those files are already in runtime form, so
the export packs them as they are (ADR-025 §6) and the runtime never links assimp. A model
placed in a scene is a copy of the model's entities, with no link back to the model file.

## Decided

| What | Call | Ref |
|---|---|---|
| No links and no prefabs | A placed model is a copy. Changes in the scene reach neither the other copies nor the model file. | Miguel, 2026-11-06; [[Content Pipeline - Brief]] § *Decided* |
| TEModel is its own node table | Not a scene fragment. Placement builds the entities from the nodes. | Miguel, 2026-11-06; § *The model file* |
| An entity per mesh | A node with one mesh carries it. A node with several gets one child entity per mesh, because each source mesh has one material. This stays after TEMesh v2: a model never joins a node's meshes into slots. | Miguel, 2026-11-06; § *The model file* |
| A folder per import | Importing `Sponza.gltf` writes a `Sponza/` folder beside it: `Sponza.temodel`, then `Meshes/`, `Materials/` and `Textures/`. | Miguel, 2026-11-06 |
| Scale and up axis are baked at import | They are applied to the mesh vertices and the node transforms, so the settings never land on the placed root. A source root's own transform is kept. The settings live in the root asset's import block and are applied again on re-import. | Miguel, 2026-11-06; S10-T15 (#194), 2026-11-09 |
| The import block | Every imported file (model, mesh, material, texture) carries one: the source path, the source key and the settings. Its type is in `core`; only the editor writes it; it ships in the packs inside every packed file and the runtime skips it. A `.temodel` itself is never packed, because the export packs only what a scene reaches and a placed copy does not reference its model. | S10-D9, 2026-11-06; § *The import block* |
| The import block's layout | A byte count first, so a reader can step over the block. The source key is an index and a name. Every block writes its settings, and the up axis is Y or Z. | Miguel, 2026-11-06 (S10-T14); § *The import block* |
| Import is editor-only, on the job system | assimp links into `apps/editor` alone. An import runs as a job and never blocks the editor's frame. | S10-D9, 2026-11-06 |
| The import's own calls | Ids, refusals, file names, FBX pivots and closing the editor during an import. | S10-T15 (#194), 2026-11-09; § *The import* |
| Placement is one edit command | Main sends it; the simulation thread builds the entities. | ADR-027 §3 |
| Placement reads the model by path | The command finds the record in the asset index and reads the `.temodel` through `FileAccess` on the simulation thread. The cache has no model loader, because a placed copy keeps nothing from the file. | S10-T16 (#196), 2026-11-10 |
| One bad mesh refuses the whole model | A mesh that is not in the index, is not a mesh, is a server asset or fails to load leaves the scene with no new entity. A mesh that loaded before the refusal stays a dependency of the scene until the scene is released. | Miguel, 2026-11-10 (S10-T16) |
| The root is copied as stored | Placement adds no offset: the root keeps the transform the model stores for it. | Miguel, 2026-11-10 (S10-T16) |
| Placement waits for its meshes | It runs the cache's loading phase on the simulation thread, as an asset field set does. Loading over several frames waits for a measured stall ([[Backlog]] § *editor & tooling*). | S10-T16 (#196), 2026-11-10 |
| Materials are created once | A re-import never overwrites a material file that already exists. Built by `keepExistingIds` in `ModelImporter.cpp` (S10-T21, #203). | [[Content Pipeline - Brief]] § *Decided* |
| Before the asset browser | The editor imports one hardcoded source file at startup, `assets/client/Sponza.gltf`, skipped quietly when the file is missing or its folder exists. Placement goes through a *Place model* menu entry with a typed path, never at startup, because each launch would add a copy to a saved scene. Both go when the browser lands. | Miguel, 2026-11-06 |
| Before the asset browser, merge and re-import | The hardcoded import's mode (model or merged mesh) is a constant beside its path (`STARTUP_IMPORT_MODE`). Re-import goes through a *Re-import* menu entry with a typed path and a merged-mesh checkbox, like placement. | S10-D10, 2026-11-09; S10-T21 (#203) |
| UV0 is stored as assimp gives it | V grows the same way for every format, and a tangent's `w` follows the stored UV0. assimp flips glTF's V but keeps glTF's bitangent, so a glTF file's own `w` is negated. Texture rows are stored top row first with no flip, so the renderer must sample at `(u, 1 - v)`: see § *Texture rows and V*. | Miguel, 2026-11-11 (S10-T19); § *The import's streams*; S10-T24 (#203) |
| The import's stream calls | Flat normals when a file has none, no tangents without UV0, the `extensionsUsed` scanner, the scale refusal and the two importer classes. | Miguel, 2026-11-11 (S10-T19, #201); § *The import's streams* |
| TEMesh v2's own calls | Stream counts, unknown stream bits, empty slots and the loader's duplicates. | S10-T17 (#198), 2026-11-10; § *The mesh file* |
| TEMesh v2 is one mesh with slots | One vertex set, one index list, and one slot per source material: a name, a range of whole triangles and a default material. A model's mesh has one slot; a merged mesh has one per source material. | S10-D10, 2026-11-09; § *The mesh file* |
| The vertex streams | Positions, then a normal, a `vec4` tangent and UV0, each optional stream behind a presence flag. No second UV set: R7's baked LOD makes its own mesh, which carries its own. | S10-D10, 2026-11-09; § *The mesh file*; [[Content Pipeline - Mesh Import Report]] §7 |
| Tangents | The file's own tangents when it has them; otherwise MikkTSpace after the scale and up axis are baked, then re-indexed with meshoptimizer. assimp's `aiProcess_CalcTangentSpace` is not used, because it is not MikkTSpace. | S10-D10, 2026-11-09; [[Content Pipeline - Mesh Import Report]] §4 |
| A model node carries no materials | The mesh names its default material, so `MODEL_KIND` stays at version 1. | S10-D10, 2026-11-09 |
| Materials per slot | A `MeshRenderer` holds one material per mesh slot, no more and no fewer, each stored with its slot's name. Placement, and picking a mesh in the inspector, copy the mesh's defaults through the same rebuild that runs when a scene opens, over the entities they touch. After that the list is the entity's own. | Miguel, 2026-11-09; the rebuild 2026-11-10 (S10-T18); § *Materials per slot* |
| Slots match by name | When a mesh's slots change, a renderer's list is rebuilt in the mesh's order by slot name: a kept name keeps its material, a new slot takes the default, and a slot that is gone is dropped and logged. | Miguel, 2026-11-09; § *Materials per slot* |
| A slot list is walked, not bulk-copied | `Writer`, `Reader`, `ReferenceVisitor` and `FieldVisitor` visit a vector of references element by element. This refines [[Resources - Design]]'s Oct 24 row, whose point was that no live handle is bulk-copied. | Miguel, 2026-11-09 |
| The material type | S10-T23 (#203) defines `Material`, and `MeshRenderer.hpp` still only forward-declares it, so a slot holds an `AssetRef<Material>` without including the type. Both apps register the material loader, and the slot card's tests now load a real material. | Miguel, 2026-11-10 (S10-T18); S10-T23 (#203) |
| Slots under multi-select | The inspector shows slot rows only when every selected renderer has the same slot names in the same order. Otherwise it shows one read-only line saying that the materials differ. A row count that differs is flagged on the component's row, because each row's own mixed flag compares only the rows that both entities have. | Miguel, 2026-11-10 (S10-T18); § *Materials per slot* |
| The engine merges, not assimp | A merged mesh comes from the model walk: each node's world transform is baked into its meshes, triangles are flipped where the determinant is negative, and meshes are joined by material. `aiProcess_PreTransformVertices` is not used. | S10-D10, 2026-11-09; § *The merged mesh* |
| Refused at import | Quantized and meshopt-compressed glTF, as Draco already is, because assimp imports them as garbage positions. A scale that is not a finite number above zero, since S10-T19. The sky and re-import add their own refusals (§ *The sky image as built*, § *Re-import as built*). | S10-D10, 2026-11-09; [[Content Pipeline - Mesh Import Report]] §5; S10-T19 (#201), 2026-11-11 |
| Re-import keeps every id | Outputs are matched to their old files by source key. Old files with no match are left in place and logged. | S10-D10, 2026-11-09; § *Re-import* |
| Re-import reloads at once | Only while the editor is Stopped. Built as `ResourceCache::reload` and `ReloadImportedAssetsCommand` (S10-T21, #203). | ADR-024 §9 (amended 2026-11-09); § *Re-import* |
| The texture file | A `.tetexture` holds one 2D image in its GPU format, with every mip, its wrap and its filter. No ADR: a wrong format costs a version bump and a re-import. | S10-D11, 2026-11-10; § *The texture file* |
| A file per image, purpose and sampler | An image shared by many materials for one purpose is written once. Used for two purposes or with two samplers, it is written twice. | S10-D11, 2026-11-10; § *Texture import* |
| A format per purpose | Base color and emissive are BC7 sRGB, the packed ORM is BC7 linear, a normal map is BC5, and the sky is uncompressed `RGB9E5`. | S10-D11, 2026-11-10; § *Texture import* |
| One packed ORM | When occlusion and metallic-roughness are separate images, import packs them into one texture, so the material keeps ADR-029 §7's four. | S10-D11, 2026-11-10 |
| One path for every image | Every source is decoded and encoded again, a DDS included, and every mip is built at import. | S10-D11, 2026-11-10 |
| Embedded images | PNG and JPEG stored inside a `.glb` or an FBX are imported like files beside it. Raw-pixel ones are refused. | Miguel, 2026-11-10; [[Content Pipeline - Brief]] |
| The sky is imported on its own | A Radiance `.hdr`, through its own menu entry, not through a model. | `/triage`, 2026-11-10; § *The sky image* |
| New dependencies | MikkTSpace and meshoptimizer (2026-11-09); stb_image, bcdec and bc7enc_rdo, its `rgbcx` and scalar `bc7enc` with no ispc (2026-11-10). Each is pinned in `cmake/deps.cmake` and linked by the editor alone, as assimp is. No ADR. | Miguel, 2026-11-09 and 2026-11-10 |

## The model file

A `.temodel` is a binary blob with its own `BlobKind`, like the mesh and the scene. It holds:

- **Its id, straight after the header**, as in the mesh and the scene, because the editor's
  asset index reads only the first 16 bytes (`ASSET_PREFIX_SIZE` in
  `apps/editor/src/assets/AssetIndex.cpp`).
- **The import block** (§ below), whose settings are the scale and up axis.
- **A node list in parent-first order**, so a node's parent is always earlier. Each node has a
  name, its parent's index (none for the root), a local translation, rotation and scale, and
  an optional mesh reference. Materials come from the mesh (§ *Materials per slot*).
- **Exactly one root, always named after the file.** A source with several top-level nodes gets
  a new root. A lone top-level node is the root: it keeps its transform and loses its name,
  because assimp gives no way to tell a root it added (`ROOT`, `RootNode`) from a real one.

Placing a model walks the list once and creates an entity per node, with `Name`, `Transform`,
`Hierarchy` and, where the node has a mesh, `MeshRenderer`. The new root goes at the scene's
root, with the transform the model stores for it. Entity ids are fresh; the model file is not
referenced by the result.

The meshes are shared, not copied: every placed copy points at the same mesh ids. So a
re-import that changes a mesh's triangles shows in every copy, while a re-import that adds or
removes nodes changes only the model file and the copies placed after it.

The editor's asset index learns the model's kind (`apps/editor/src/assets/AssetIndex.cpp:33-36`).

## The import block

The block is how a re-import finds each file it wrote. It answers [[Resources - Design]]'s
former open question, sidecar or registry: neither, the data lives inside each file.

- **Byte count:** a `u32` count of the bytes that follow, so a reader that does not need the
  block steps over it without parsing it. A count that does not match the fields is refused.
- **Source path:** the source file, relative to the project.
- **Source key:** what the file was made from inside the source: a `u32` index into assimp's
  array and the name there. The root asset's key is empty, index 0 with no name. A re-import
  matches each output to its old file by this key, so the file keeps its id and every
  reference to it survives (§ *Re-import*).
- **Settings:** scale and up axis, where the up axis is Y or Z. Every block writes them, so
  the layout never branches; files other than the root asset carry the defaults, scale 1 and
  Y up.

The type is in `core` because the runtime must step over it when it reads a packed file. Only
the editor fills it in.

## The import

Built by S10-T15 (#194): `ModelImporter::importFile` in `apps/editor/src/assets/ModelImporter.cpp`
since S10-T19 (#201), run as a job by `ImportModelCommand` in `apps/editor/src/edit/`. These
calls came from the card, not the design above.

- **Ids are drawn on the worker** by `randomResourceId()`, because the job needs them before it
  writes a file and the asset index belongs to the simulation thread. The job then submits
  `RegisterImportedAssetsCommand`, which adds the records there and skips, with a log line, a
  record whose id is taken.
- **Refusals** are `ProjectError` codes: `SourceUnreadable`, `SourceHasNoMeshes` (a model with no
  triangle mesh places nothing visible), `ImportFolderExists`, and since S10-T19
  `SourceCompressed` and `InvalidImportScale`. A failed import leaves no folder behind. Of two
  imports of one source at once, only one creates the folder (`FileAccess::createDirectory`); the
  other gets `ImportFolderExists` and removes nothing. The codes added since by S10-T21, S10-T24 and S10-T25 (#203) are named where they are used:
  § *Re-import as built*, § *Texture inputs as built* and § *The sky image as built*.
- **Every triangle mesh is written**, even one that no node uses. Points and lines are skipped.
- **Mesh file names** keep ASCII letters, digits, space, `.`, `_` and `-`. A clash, compared
  without case because Windows treats `Part_A` and `part_a` as one file, gets `_1`, `_2`.
- **FBX pivots are off** (`AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS`). With them on, every FBX node
  arrives as a chain of pivot helper nodes.
- **The request carries the `Side`**, instead of deriving it from the path, which would hardcode
  the assets root a second time.
- **Each mesh carries its key and one slot** since S10-T17 (#198): the source path, assimp's
  mesh index and name, and the default settings, then one slot over all its indices, named after
  its material or `Slot <material index>`. The import writes through `Mesh::write`, so it could
  not keep writing meshes without a slot once the reader refused them.
- **Closing waits for running imports**, in `EditorApp::shutdown()`, so a large import holds the
  close until assimp returns. The destructor waits too, but too late for a job's log lines,
  which wake main through a virtual call ([[Known Issues]] D9).

### The import's streams

Built by S10-T19 (#201). Miguel took these calls at the card's start, on Nov 11:

- **Two importers.** `ModelImporter` walks the scene, names the files and writes them;
  `MeshImporter` turns one `aiMesh` into a baked `Mesh`, so a later mesh-only import reuses it.
  Such an import must pass the same assimp steps (`IMPORT_STEPS` in `ModelImporter.cpp`), or a mesh
  without normals comes back with none, and must set the slot itself, since its name comes from the
  scene's materials.
- **Normals.** A file's own are kept. A mesh with none gets flat normals from
  `aiProcess_GenNormals`, as glTF requires. They are turned by the up axis, never scaled, and
  normalized.
- **UV0 and `w`.** UV0 is stored as assimp gives it, and `cross(n, t.xyz) * w` points the way V
  grows in it. A file tangent's `w` is the sign of `dot(cross(n, t), b)` with assimp's bitangent,
  negated for a glTF source, because assimp flips glTF's V (`glTF2Importer.cpp:644`) but builds the
  bitangent from glTF's own `w` (`:597`). The test that a generated and a file tangent agree on one
  quad holds this.
- **No UV0, no tangents.** MikkTSpace needs UVs, and a normal map cannot be sampled without them,
  so the stream is left out and the upload fills its default.
- **MikkTSpace runs after the bake**, then `meshopt_generateVertexRemapMulti` welds the corners
  again, merging two only when all four streams match bit for bit.
- **The scale is refused** unless it is a finite number above zero, so the model's bake is always a
  rotation and a positive uniform scale: no winding or `w` flips there. The merged bake applies the
  determinant rule below (§ *The merged mesh as built*).
- **The extension check** is a small scanner, not a JSON parser, because the editor links none. It
  reads the `extensionsUsed` key, in a `.glb`'s JSON chunk too, and refuses `KHR_mesh_quantization`,
  `EXT_meshopt_compression` (what gltfpack writes) and `KHR_meshopt_compression`. It reads the whole
  file, so a large `.glb` is read twice ([[Backlog]] § *editor & tooling*).

## The mesh file

TEMesh v2 is `MESH_KIND` at version 2. The reader refuses version 1, so
`projects/dev/assets/client/Triangle.temesh` is written again in the same change. In order:

- **Its id, straight after the header**, as in the model, for the asset index's 16-byte read.
- **The import block.** A model's mesh keys on its index in assimp's mesh array and its name,
  with the default settings. A merged mesh is the root asset: an empty key and the real settings.
- **Stream flags:** a `u32` with one bit per optional stream: normal, tangent, UV0. Positions and
  indices are always present. An absent stream costs no bytes, and the upload fills defaults. A
  later stream (UV1, colours, skin weights) is a new bit, not a new version.
- **The streams**, each one value per vertex: positions `float3`, normals `float3`, tangents
  `float4` whose `w` is the bitangent's sign (±1, against UV0 as stored; § *The import's
  streams*), and UV0 `float2`. They stay
  unpacked until a measurement asks otherwise ([[Renderer - Design]] § *Geometry buffers*).
- **The indices**, `u32`, whole triangles.
- **The slots**, at least one: a name, a first index, an index count and a default material id.
  The ranges cover the indices in order, with no gap and no overlap, and each holds whole
  triangles. A slot with no source name is named `Slot <material index>`.

The loader lists each non-null default material as a dependency, so a slot that no renderer
entry covers still draws (§ *Materials per slot*). Since S10-T24 (#203) import writes each
slot's default as the id of the material it wrote for that source material. The id is null only
where the mesh's material index names no source material.

**Tangents and a baked transform.** For a baked matrix `M`, normals take the inverse transpose,
tangents take `M`, and `w` is multiplied by the sign of `det(M)`, because a mirror flips the
bitangent. A Z-up swap written as an axis swap has a negative determinant; written as a rotation
it has none. MikkTSpace returns one tangent per face corner, so the mesh is re-indexed after it.

### The mesh file as built

Built by S10-T17 (#198), in `engine/core/src/mesh/Mesh.cpp`. These calls came from the card:

- **Each optional stream keeps its `u32` count**, and read refuses one that is not the vertex
  count. It tests the flag, not the stream, so a set flag with no values is refused.
- **An unknown stream bit is refused** as `Malformed`, because a reader cannot know its size.
- **A slot with no indices is accepted.** The rule is only that the slots tile the indices in
  order, in whole triangles.
- **A default material is a `ResourceId`**, and it stays one now that the material type exists
  (S10-T23, #203). `MeshSlot` keeps the bare id, and the loader lists it as a dependency
  (`engine/core/src/mesh/Mesh.cpp:183`).
- **The loader lists a material once per slot** that names it, without removing duplicates. The
  cache counts references, so a duplicate costs one more count.
- **The committed version 1 meshes were rewritten in place**, with their ids kept, because
  `Startup.tescene` names all 103 Sponza meshes. Their keys come from the raw mesh names that
  `Sponza.temodel` stores. S10-T19 (#201) then imported Sponza again from scratch, with new ids
  and a new `Startup.tescene`.

## Materials per slot

`MeshRenderer` keeps its mesh and gains a list of slots, each a name and an
`AssetRef<Material>`. After a rebuild, the list has one entry per mesh slot, in the mesh's order.

- **Filled from the mesh.** Placement copies each mesh's default materials, so placement loads
  the meshes first. Picking another mesh in the inspector does the same.
- **Rebuilt by name** when the editor opens a scene, once its meshes are ready, and over the open
  scene after a re-import (S10-T21, #203). The rebuild is not an undo step.
- **A slot with no entry draws with the mesh's default.** That covers a scene nobody opened since
  a re-import and then exported, which still holds its old list.
- **Editing a slot** in the inspector is an ordinary `AssetRef` edit (ADR-026 §4).

As built (S10-T18, #199): `Writer`, `Reader`, `ReferenceVisitor` and `FieldVisitor` walk a vector
of a visited type element by element, and a bare vector of `Entity` or `AssetRef` still fails to
compile (`engine/core/include/TechEngine/core/serialization/Writer.hpp:95`, `Reader.hpp:109`,
`ReferenceVisitor.hpp:38`, `FieldVisitor.hpp:120`). The rebuild is `MeshRenderer::rebuildSlots`
(`engine/core/src/mesh/MeshRenderer.cpp`), and the editor acquires each new default in
`apps/editor/src/edit/MaterialSlotRebuild.cpp`.

From memory: Unity's renderer holds a full material array indexed by submesh, and Unreal's
component holds overrides by slot index, with the names on the mesh. This shape is Unity's full
list, matched by Unreal's slot names, so a reorder in the source never misplaces a material.

## The merged mesh

It reuses the model walk (S10-T15) instead of `aiProcess_PreTransformVertices`, whose flattening
path never fixes winding under a negative scale ([[Content Pipeline - Mesh Import Report]] §3).

- **Bake:** each mesh's vertices take its node's world matrix, with the tangent rule above.
  Where the determinant is negative, each triangle's winding is reversed.
- **Join by material**, one slot per source material, in material-index order. Instancing is
  lost: a mesh used by three nodes is copied three times.
- **Missing streams** take defaults: normals come from `aiProcess_GenSmoothNormals` before the
  walk, UV0 is zero, and a part with no UV0 gets the tangent `(1, 0, 0, 1)`.
- **`aiProcess_RemoveRedundantMaterials` stays off**, so editing one of two identical materials
  leaves the other alone.
- **Output:** `Sponza/Sponza.temesh` as the root asset, beside `Materials/`, with no `.temodel`.
  It is placed as one entity: `Name`, `Transform` and `MeshRenderer`.

### The merged mesh as built

Built by S10-T20 (#203). The implementation took these calls:

- **The walk is its own function.** `ModelImporter::readMergedParts` visits the nodes in the same
  order as `buildNodes`, so both modes see the meshes in one order. A mesh that no node uses is
  left out, because it has no world matrix. A model import still writes it.
- **The bake lives in `MeshImporter::read(source, world, out)`.** A negative determinant swaps
  each triangle's second and third corner. Normals take the cofactor matrix
  (`MeshImporter::normalMatrix`), which is also right for a matrix that flattens an axis, and
  tangents take the matrix itself, with `w` multiplied by the determinant's sign.
- **MikkTSpace runs once per part, before the join.** Two parts never share a vertex, so the
  merge needs no second welding pass.
- **A stream exists when any part has it** (`ModelImporter::joinParts`). A part without it takes
  the default: normal `(0, 1, 0)`, UV0 `(0, 0)`, tangent `(1, 0, 0, 1)`.
- **Parts are stable-sorted by material index** (`joinParts`), so the parts of one material
  keep their walk order. A material that no part uses gets no slot and no material file.
- **Two slots with one name get `_1`, `_2`** (`uniqueSlotName`), because a renderer's list is
  rebuilt by slot name and a clash would hand both slots one material.
- **Placing a mesh reuses placement.** `PlaceModelCommand::wrapMesh` turns a `.temesh` path into
  a model of one root node named after the file, with the default transform, so *Place model*
  takes either kind of path.

## The texture file

A `.tetexture` is `TEXTURE_KIND`, a binary blob like the mesh. In order:

- **Its id, straight after the header**, for the asset index's 16-byte read.
- **The import block**, with the default settings, because a texture has no settings of its own
  in E2.
- **The shape**, a `u8` that is always 2D in E2. A cube map later is a new value, not a new
  version.
- **The format:** `BC7_SRGB`, `BC7_UNORM`, `BC5_UNORM` or `RGB9E5`. Whether the data is sRGB is
  part of the format, so there is no colour space field. BC1 and BC6H can join later as values.
- **Width and height**, `u32` each, and **the mip count**, always the full chain down to 1×1.
- **The sampler:** wrap U and wrap V (repeat, clamp or mirror, as glTF has), and the filter
  (linear with trilinear mips, or nearest). It lives on the texture (ADR-029 §7), so a material
  holds one handle per input. Anisotropy is one renderer setting, not a texture field.
- **The mips, largest first**, each a `u32` byte count and its data. BC data comes in 4×4 blocks,
  so a level smaller than 4 pixels still takes one block.

The purpose (base color, normal and so on) is stored only in the source key, because the format
already says everything the renderer needs.

### The texture file as built

Built by S10-T22 (#203), in `engine/core/src/texture/Texture.cpp`. The implementation took these calls:

- **The mip count is written as a field**, after the size and before the sampler, and read
  refuses a count that is not `Texture::mipCount` for the size. So a file can never hold a
  partial chain.
- **Each mip's byte count must equal `Texture::mipByteSize`**, or read refuses the file as
  `Malformed`. A count larger than the bytes left is `Truncated`. Bytes after the last mip are
  `Malformed`.
- **Read refuses** an unknown shape, format, wrap or filter value, and a width or height of 0,
  each as `Malformed`.
- **`mipByteSize` returns `UINT64_MAX` when the size overflows 64 bits**, which no stored count
  can equal, so a huge size is refused without a special case.
- **A texture has no dependencies.** Its loader clears the list, and both apps register it
  (`apps/editor/src/EditorApp.cpp`, `apps/runtime/src/RuntimeApp.cpp`). The editor's asset index
  learns the kind in `apps/editor/src/assets/AssetIndex.cpp`.

## Texture rows and V

The renderer depends on this, so it is written down once, here.

- **Texture rows are stored top row first, with no vertical flip.** No decoder is asked to flip:
  stb_image keeps the file's order, `ImageDecoder::decodeDds` keeps the DDS order, and the mip
  builder and the encoders keep the row order they are given. A sky image is stored the same way.
- **UV0 is stored as assimp gives it** (§ *The import's streams*), and assimp flips glTF's V.
  So V is 0 at the bottom of the picture for every format, while row 0 of the texture is the top.
- **Import flips neither.** The R1 shader or upload must sample at `(u, 1 - v)`, or flip the rows
  as it uploads. A texture that draws upside down means this was missed.
- **The sky has the same rule.** Its first row is the top of the picture.

[[Renderer - Design]] § *Open questions* carries the matching entry, owned by R1.

## Texture import

Import writes a model's textures into `Textures/` while it walks the materials, because a
texture's format follows the input that samples it. Rows are stored top row first, so read
§ *Texture rows and V* before sampling one.

| Input | Format | Mips |
|---|---|---|
| Base color, alpha included | `BC7_SRGB` | Built in linear float, then encoded back to sRGB |
| Occlusion, roughness, metallic | `BC7_UNORM` | Linear |
| Normal | `BC5_UNORM`, its z rebuilt in the shader | Renormalized at every level |
| Emissive | `BC7_SRGB` | As base color |

- **Packing the ORM.** When the occlusion and metallic-roughness inputs name the same image, the
  texture is made from it. When they differ, import builds one image: red from occlusion, green
  and blue from metallic-roughness, after scaling the smaller image up to the larger one's size.
  A missing image's channels are 1, so the material's factor applies alone.
- **Decoding.** stb_image reads PNG, JPEG, TGA and HDR, from memory only. A DDS is read
  by import's own small reader, and its blocks are decoded with bcdec. Every image is then encoded
  again, so a DDS is compressed twice and loses a little quality.
- **Embedded images.** assimp keeps them in `aiScene::mTextures`, and `GetEmbeddedTexture` finds
  one from a material's texture path. One with `mHeight == 0` holds PNG or JPEG bytes and is
  decoded from memory. A raw-pixel one is refused with a log line, and the input stays empty.
- **Mips** are a 2×2 box filter of the level above.
- **Encoding.** bc7enc_rdo's `rgbcx` writes BC5 and its scalar `bc7enc` writes BC7, in plain C++.
  `RGB9E5` needs no encoder.
- **The source key's name** holds the image's path relative to the source, the purpose and the
  sampler, for example `Textures/wall.png#normal#repeat-linear`, so a key never depends on which
  material the walk reached first. An embedded image uses its own name when assimp has one,
  otherwise `*<index>`. A packed ORM names both images: `ao.png+mr.png#orm#repeat-linear`.
  Re-import matches it by name, as for meshes (§ *Re-import*).

**Known costs.** Cut-outs thin out in distant mips (Sponza's plants), because keeping the alpha
coverage needs the material's cutoff; that waits for a measured need. BC7 encoding at good
quality is slow, and no speed is measured ([[Content Pipeline - Mesh Import Report]] §6), so the
first Bistro import gives the brief's import time its number. S10-T24 (#203) encodes at
bc7enc's lowest search level, which trades quality for speed (§ *Encoding as built*).

### Materials and textures as built

Built by S10-T24 (#203). The implementation took these calls:

- **The material file** itself is [[Renderer - Design]] § *The material file* (S10-T23, in
  review). The asset index and the runtime learned the kind in `AssetIndex.cpp` and
  `RuntimeApp.cpp`, and the editor registers the loader in `EditorApp.cpp`.
- **Planning is separate from writing.** `MaterialImporter::plan` turns the scene's materials
  into a `MaterialPlan` of material and texture outputs. `ModelImporter::assignOutputs` then
  gives each a path and an id, a re-import swaps in the old ones (`keepExistingIds`), and
  `MaterialImporter::write` writes every texture and then every material.
- **Only a used material gets a file.** A material is planned when a written mesh, or a merged
  part, names it. A model import still writes every triangle mesh.
- **A texture that cannot be read is left out.** The import logs it, and the inputs that named
  it stay empty, so the material is still written. A `Textures/` folder that this call made and
  filled with nothing is removed again (`ModelImporter::writeMaterials`).
- **The root asset is written last**, after its materials and meshes, so a folder that holds a
  model or a merged mesh holds every file it names. A failed first import removes its folder.
- **A file name is the image's stem and the purpose**, such as `wall_normal`. A material with no
  name is `Material <index>` and an unnamed embedded image is `Texture <index>`, both made
  unique without regard to case. This is the fix v1's pointer-address names were owed (§ *Porting
  v1's import*): the key's name stays empty and its index is the material's index.
- **Material values come from `MaterialImporter::readValues`.** A value the source lacks keeps the
  file's default, except metallic, which is 0, because a source with no metallic factor is not
  glTF. Base color falls back to the diffuse color and its opacity. The emissive factor is
  multiplied by the emissive intensity. Cut-out and blended come from glTF's alpha mode only.
- **The records come back in a fixed order.** A model import lists the model, the meshes, the
  textures and the materials. A merged import lists the mesh first, then the textures and the
  materials.

### Texture inputs as built

Also S10-T24 (#203), in `MaterialImporter.cpp`, `ImageDecoder.cpp` and `TextureImporter.cpp`:

- **Base color falls back to the diffuse texture.** Occlusion is glTF's lightmap slot for a glTF
  source and assimp's ambient-occlusion slot for any other, because another format's lightmap is
  baked lighting.
- **The ORM is packed only from glTF's shared image.** Separate grey metalness and roughness
  images from another format are logged and not imported. When occlusion and metallic-roughness
  use two samplers, the packed texture takes the metallic-roughness one and the import logs it.
- **The sampler** takes its wraps from the source's mapping modes, with decal read as clamp. The
  filter is nearest only when glTF's magnify filter says nearest. The minify filter is ignored.
- **An image path** is resolved against the source's folder by `MaterialImporter::imagePath`,
  with `.` and `..` followed and glTF's `%XX` escapes decoded. An absolute path, or one that
  climbs above the project's mount, is refused, and the texture is left out.
- **A DDS file** is decoded by `ImageDecoder::decodeDds`: BC1, BC2, BC3, BC5 and BC7 from either
  header kind, and 32-bit RGBA or BGRA, the largest level of the first image only. A side above
  16384 pixels is `ImageUnreadable`.
  It converts no color, so an sRGB DDS format is read as stored, and a BC5 image has its blue
  rebuilt as a unit normal's z. Another format is `UnsupportedDdsFormat`, and a damaged file is
  `ImageUnreadable`.
- **An embedded image with raw pixels** is logged as `UnsupportedImageType`, and the texture is
  left out. A Radiance image used as a model texture is tone-mapped to 8 bits
  by stb_image, which is no use as a sky.
- **The mip builder** halves each side and averages 2×2 texels. An odd side loses its last row or
  column, and a normal map is normalized again at every level (a zero vector becomes `(0, 0, 1)`).

### Encoding as built

Also S10-T24 (#203), in `apps/editor/src/assets/TextureImporter.cpp`:

- **The top level is encoded from the source's own bytes.** Only the levels below it go through
  linear float and back, so the largest level never takes that round trip's rounding.
- **BC7 uses bc7enc's lowest search level** (`BC7_UBER_LEVEL`) with all 16 partitions, and the
  packed ORM uses linear weights. A level smaller than a block repeats its edge texels.
- **Both encoders fill global tables on first use**, so `TextureImporter::encode` guards them
  with `std::call_once`.
- **Packing scales both images bilinearly** to the larger width and the larger height, and a
  missing image's channels are 255 (`TextureImporter::packOcclusionRoughnessMetallic`).
- **The new libraries are pinned in `cmake/deps.cmake`.** stb is compiled with only its PNG, JPEG,
  TGA and HDR decoders and no file input. bcdec is header-only. Only `bc7enc.cpp` and `rgbcx.cpp`
  of bc7enc_rdo are built, as `TechEngineBc7Enc`, so no ispc is involved.

## The sky image

The sky has no model file, so an *Import image* menu entry with a typed path imports it, like
*Place model*, until the asset browser exists. It writes one `.tetexture` beside the source and
named after it: `Sky.hdr` gives `Sky.tetexture`, with no folder, because there is one output.
It is the root asset, so its key is empty and a re-import rewrites the same file.

Its format is `RGB9E5`, a core GL format that the renderer samples as it is. A 4096×2048 sky with
its mips takes about 43 MB, against about 11 MB in BC6H. BC6H joins as a format value if
memory asks for it, with no version bump.

How the image becomes the sky's lighting (filtered levels for rough reflections, and the diffuse
light) is the renderer's ([[Renderer - Design]] § *Open questions*).

### The sky image as built

Built by S10-T25 (#203), in `apps/editor/src/assets/TextureImporter.cpp`. The implementation took these calls:

- **Only a `.hdr` file is imported.** Any other extension is `UnsupportedImageType`. A source
  outside `assets/common`, `assets/client` or `assets/server` is `SourceNotInAssets`, because the
  record's side comes from that folder (`TextureImporter::sideOf`). An existing output is
  `ImportOutputExists`, and a file stb_image cannot read is `ImageUnreadable`. The output is
  written with `FileAccess::createFile`, so of two imports at once one gets `ImportOutputExists`
  and registers no record.
- **The sampler is repeat in U, clamp in V and linear** (`SKY_SAMPLER`), because a lat-long sky
  wraps around in longitude and ends at the poles.
- **The image is decoded as float and packed per channel.** Alpha is dropped. A negative or NaN
  channel becomes 0, and one above 65408 becomes 65408 (`TextureImporter::packRgb9E5`), the
  largest value `RGB9E5` holds.
- **The mips come from `TextureImporter::buildMipChain`** on the float image, so a sky whose side
  is odd loses a row or column at that level, as any texture does.
- **The key is empty.** The import block holds only the source path and the default settings.
- **Re-import rewrites the same file** under its id (`TextureImporter::reimportSky`). It returns
  the id as rewritten, with no new record. It refuses with `ReimportTargetMissing` when the output
  is missing or is not a texture.
- **The menu entry is *Import image...*** (`PanelsManager::drawImportImagePopup`), through
  `EditorApp::importSky` and `ImportSkyCommand`, until the asset browser lands. Its dialog and
  menu entry have not been tried in a window.

## Re-import

By hand only ([[Content Pipeline - Brief]]), and refused unless the editor is Stopped.

1. **Read the folder.** Every file under the import folder gives its kind, source key and id.
2. **Match each output** against files of its kind: by name first; among equal names, the index
   decides; an empty name matches by index alone. Matching by index first would hand every id to
   the wrong output when a tool reorders its arrays, with no error. assimp itself reorders: its
   glTF reader lists meshes in the order the nodes first name them, not in the file's order
   (found by S10-T15's two-mesh fixture).
3. **Write.** A matched output keeps its id; a new one gets a fresh id. A matched material is
   never rewritten. An old file with no match stays and is logged, since E2's browser cannot
   delete and a scene that names it must still open.
4. **Settings** come from the root asset's import block. Importing the other way switches the
   root asset between `.temodel` and `.temesh` in the same folder; the old root stays and is
   logged, and `Materials/` keeps its edits.
5. **Reload.** The job sends one reload command naming every rewritten id. The simulation thread
   runs it as a loading phase through `ResourceCache::reload`: each loaded payload is replaced
   behind its handle, new dependencies are acquired before the old ones are released, and render
   gets a new upload under its fence (ADR-028 §4). The slot rebuild then runs over the open
   scene.

`ResourceCache::reload` is built (S10-T21, #203;
`engine/core/include/TechEngine/core/resources/ResourceCache.hpp`).

### Re-import as built

Built by S10-T21 (#203). The implementation took these calls:

- **`ReimportMatcher::match` runs two passes** over all outputs. The first pairs a name and an
  index that both agree. The second gives an output the lowest remaining old index with its name.
  An empty name is matched only by the first pass, so it never takes a named file.
- **`ModelImporter::reimportFile` reads the root asset's settings** and ignores the request's.
  `listImportedFiles` in `ReimportMatcher.hpp` reads only each file's header, id and import block,
  and skips with a log line any file that is not an imported one.
- **The refusals are four `ProjectError` codes.** `ReimportTargetMissing` is a folder that does
  not exist, `ReimportRootMissing` is a folder with neither root asset, and `EditorNotStopped`
  stops the whole re-import. A stored scale that is not valid is still `InvalidImportScale`.
- **A second re-import of a source is refused while one runs**, as `ReimportInFlight`, because
  the two would give one new output two ids. `EditorApp::m_reimportsInFlight` lives on the
  simulation thread, and the job's last command takes the source out again:
  `ReloadImportedAssetsCommand` on success, `FinishReimportCommand` on failure. The key is the
  typed source path, so two spellings of one source are not caught (D10 in [[Known Issues]]).
- **The result splits in two.** `ModelImportResult::records` holds only files with a new id,
  and `rewritten` holds the ids that were written again. A matched material is in neither.
- **A new output avoids the names already in the folder** (`ExistingFolder::taken*Names`), so it
  never overwrites an old file that matched nothing. Such an old file is logged
  (`ModelImporter::finishReimport`).
- **`ReloadImportedAssetsCommand` indexes the new records first**, so the reload's loaders find
  the new materials and textures. It then reloads, and then rebuilds the slots if a scene is open.
- **The Stopped check cannot fail yet.** `EditSession::getPlayState` is always Stopped until
  Play and Stop set it (`TODO(E11)` in `EditSession.hpp`), and the command checks it twice: when
  it starts and again before the reload.
- **A `.hdr` path re-imports the sky** and ignores the mode. Any other path takes its side from
  `TextureImporter::sideOf`. The *Re-import...* dialog has a merged-mesh checkbox
  (`PanelsManager::drawReimportPopup`).

### The reload as built

Also S10-T21 (#203), in `engine/core/src/resources/ResourceCache.cpp`:

- **Only a Ready or Failed entry that is not loading is reloaded.** Any other id is skipped
  without an error, so the caller can pass every rewritten id.
- **A failed reload keeps the old payload** and the old dependencies, logs a warning, and
  returns the first error. A file whose type changed is refused as `BadMagic`.
- **A reloaded entry keeps only its loader's dependencies.** One added with `addDependency` is
  released, as the header says.
- **Load results travel in the completion.** A task no longer writes its entry, and the owner
  installs the payload when it drains (`publishCompletion`). That also changes a first load, and
  is what lets a failed reload leave the entry alone.
- **The old payload is destroyed at once**, because nothing on render holds one yet. Step 5's
  upload under render's fence is R1's to add.

## Open questions

- **Which way a texture is sampled.** Rows are stored top row first and UV0 keeps assimp's V, so
  the renderer samples at `(u, 1 - v)` (§ *Texture rows and V*). Owner: R1, listed in
  [[Renderer - Design]] § *Open questions*.
- **The material file** is decided: [[Renderer - Design]] § *The material file*, built by S10-T23
  and written by S10-T24's walk (both #203, § *Materials and textures as built*).
- **A mirrored instance in a model:** a placed node with a negative determinant needs its front
  face flipped. Owner: R1, in [[Renderer - Design]] § *Open questions*.

## Porting v1's import

v1's model import worked, and this design follows its shape: a folder per import, a
`.temodel`, and a child node per mesh. S10-T15 ported its assimp walk from
`v1-reference:runtime/editor/src/resources/loaders/AssimpLoader.cpp` and `ModelLoader.cpp`
(#194), with v1's Euler rotations, name-matched meshes, surviving points and lines, and
frame-bound import fixed on the way ([[v1 Code Audit]] F14). S10-T19 took nothing from v1's
streams: its `aiProcess_CalcTangentSpace` and `aiProcess_GenSmoothNormals` are what the design
rejects, and it wrote zero UVs where TEMesh v2 writes no stream. The last fix owed is done:

- **An unnamed material was named after its pointer address**, which changes on every run, so a
  re-import could never find it. S10-T24 (#203) fixed it: the file is `Material <index>` and
  the key is the index alone (§ *Materials and textures as built*). Leave v1's `MeshLoader.cpp`
  alone: it is the atlas merge below.

## References

- v1's merge baked every material into one atlas and never worked; the per-slot merge avoids it.
- `engine/core/include/TechEngine/core/mesh/MeshRenderer.hpp:13-40`: the renderer holds its mesh
  and one `MaterialSlot` per mesh slot.
- `apps/editor/src/ui/panels/InspectorPanel.cpp:239`: the inspector draws the slot list's walked
  fields as one row per slot.
