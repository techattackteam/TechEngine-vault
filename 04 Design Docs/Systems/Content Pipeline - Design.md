# Content Pipeline: Design

> Living design doc. It turns a source file (glTF, FBX, OBJ) into runtime-form assets that the
> export packs unchanged. It is the hub for import work: plan and ground Story H from here.

**Module:** `core` (the model and mesh formats, the import block) · `apps/editor` (assimp, the
import, placement)
**Kind:** system
**Status:** the model is designed (2026-11-06, S10-D9) against engine `a67c4d4`. TEMesh v2,
materials per slot, the merged mesh and re-import are designed (2026-11-09, S10-D10) against
`ac594e4`, from [[Content Pipeline - Mesh Import Report]]. Textures are S10-D11's. assimp is in
the editor's build with only its glTF, FBX and OBJ importers (S10-T13, `cmake/deps.cmake`). The
model file and the import block are built, with write and read (S10-T14,
`engine/core/include/TechEngine/core/model/Model.hpp` and
`engine/core/include/TechEngine/core/assets/ImportBlock.hpp`). The import, the placement, TEMesh
v2 and re-import are not.
**ADRs:** [[ADR-025 - Content packs (.tepack and the runtime load path)]] §6 ·
[[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §9 (amended 2026-11-09) ·
[[ADR-026 - Reference fields and scene-held acquires]] §2 §3 ·
[[ADR-027 - Editor threads, edit commands and play sessions]] §3 ·
[[ADR-028 - Render device seam and frame packets]] §5
**Product:** [[Content Pipeline - Brief]] · **Backlog:** [[Backlog]]

## Purpose

Import reads a source file once, in the editor, and writes the engine's own files: a model,
its meshes, and later its materials and textures. Those files are already in runtime form, so
the export packs them as they are (ADR-025 §6) and the runtime never links assimp. A model
placed in a scene is a copy of the model's entities, with no link back to the model file.

## Decided

| What | Call | Ref |
|---|---|---|
| No links and no prefabs | A placed model is a copy. Changes in the scene reach neither the other copies nor the model file. | Miguel, 2026-11-06; [[Content Pipeline - Brief]] § *Decided* |
| TEModel is its own node table | Not a scene fragment. Placement builds the entities from the nodes. | Miguel, 2026-11-06; § *The model file* |
| An entity per mesh | A node with one mesh carries it. A node with several gets one child entity per mesh, because each source mesh has one material. This stays after TEMesh v2: a model never joins a node's meshes into slots. | Miguel, 2026-11-06; § *The model file* |
| A folder per import | Importing `Sponza.gltf` writes a `Sponza/` folder beside it: `Sponza.temodel`, then `Meshes/`, `Materials/` and `Textures/`. | Miguel, 2026-11-06 |
| Scale and up axis are baked at import | They are applied to the mesh vertices and the node transforms, so the placed root starts at identity. The settings live in the root asset's import block and are applied again on re-import. | Miguel, 2026-11-06 |
| The import block | Every imported file (model, mesh, material, texture) carries one: the source path, the source key and the settings. Its type is in `core`; only the editor writes it; it ships in the packs inside every packed file and the runtime skips it. A `.temodel` itself is never packed, because the export packs only what a scene reaches and a placed copy does not reference its model. | S10-D9, 2026-11-06; § *The import block* |
| The import block's layout | A byte count first, so a reader can step over the block. The source key is an index and a name. Every block writes its settings, and the up axis is Y or Z. | Miguel, 2026-11-06 (S10-T14); § *The import block* |
| Import is editor-only, on the job system | assimp links into `apps/editor` alone. An import runs as a job and never blocks the editor's frame. | S10-D9, 2026-11-06 |
| Placement is one edit command | Main sends it; the simulation thread builds the entities. | ADR-027 §3 |
| Materials are created once | A re-import never overwrites a material file that already exists. | [[Content Pipeline - Brief]] § *Decided* |
| Before the asset browser | The editor imports one hardcoded source file at startup, skipped when its folder exists. Placement goes through a *Place model* menu entry with a typed path, never at startup, because each launch would add a copy to a saved scene. Both go when the browser lands. | Miguel, 2026-11-06 |
| Before the asset browser, merge and re-import | The hardcoded import's mode (model or merged mesh) is a constant beside its path. Re-import goes through a *Re-import* menu entry with a typed path, like placement. | S10-D10, 2026-11-09 |
| The model starts on today's mesh | Until TEMesh v2, a model's meshes are written in today's format (positions and indices), and its nodes carry no materials. | S10-D9, 2026-11-06 |
| TEMesh v2 is one mesh with slots | One vertex set, one index list, and one slot per source material: a name, a range of whole triangles and a default material. A model's mesh has one slot; a merged mesh has one per source material. | S10-D10, 2026-11-09; § *The mesh file* |
| The vertex streams | Positions, then a normal, a `vec4` tangent and UV0, each optional stream behind a presence flag. No second UV set: R7's baked LOD makes its own mesh, which carries its own. | S10-D10, 2026-11-09; § *The mesh file*; [[Content Pipeline - Mesh Import Report]] §7 |
| Tangents | The file's own tangents when it has them; otherwise MikkTSpace after the scale and up axis are baked, then re-indexed with meshoptimizer. assimp's `aiProcess_CalcTangentSpace` is not used, because it is not MikkTSpace. | S10-D10, 2026-11-09; [[Content Pipeline - Mesh Import Report]] §4 |
| A model node carries no materials | The mesh names its default material, so `MODEL_KIND` stays at version 1. | S10-D10, 2026-11-09 |
| Materials per slot | A `MeshRenderer` holds one material per mesh slot, no more and no fewer, each stored with its slot's name. Placement, and picking a mesh in the inspector, copy the mesh's defaults. After that the list is the entity's own. | Miguel, 2026-11-09; § *Materials per slot* |
| Slots match by name | When a mesh's slots change, a renderer's list is rebuilt in the mesh's order by slot name: a kept name keeps its material, a new slot takes the default, and a slot that is gone is dropped and logged. | Miguel, 2026-11-09; § *Materials per slot* |
| A slot list is walked, not bulk-copied | `Writer`, `Reader`, `ReferenceVisitor` and `FieldVisitor` visit a vector of references element by element. This refines [[Resources - Design]]'s Oct 24 row, whose point was that no live handle is bulk-copied. | Miguel, 2026-11-09 |
| The engine merges, not assimp | A merged mesh comes from the model walk: each node's world transform is baked into its meshes, triangles are flipped where the determinant is negative, and meshes are joined by material. `aiProcess_PreTransformVertices` is not used. | S10-D10, 2026-11-09; § *The merged mesh* |
| Refused at import | Quantized and meshopt-compressed glTF, as Draco already is, because assimp imports them as garbage positions. | S10-D10, 2026-11-09; [[Content Pipeline - Mesh Import Report]] §5 |
| Re-import keeps every id | Outputs are matched to their old files by source key. Old files with no match are left in place and logged. | S10-D10, 2026-11-09; § *Re-import* |
| Re-import reloads at once | Only while the editor is Stopped. | ADR-024 §9 (amended 2026-11-09); § *Re-import* |
| Textures are their own card | The texture file, its BC formats, mips and library are S10-D11's, after S10-D7 names what a material samples. | Miguel, 2026-11-09 |
| New dependencies | MikkTSpace and meshoptimizer, pinned in `cmake/deps.cmake` and linked by the editor alone, as assimp is. No ADR. | Miguel, 2026-11-09 |

## The model file

A `.temodel` is a binary blob with its own `BlobKind`, like the mesh and the scene. It holds:

- **Its id, straight after the header**, as in the mesh and the scene, because the editor's
  asset index reads only the first 16 bytes (`ASSET_PREFIX_SIZE` in
  `apps/editor/src/assets/AssetIndex.cpp`).
- **The import block** (§ below), whose settings are the scale and up axis.
- **A node list in parent-first order**, so a node's parent is always earlier. Each node has a
  name, its parent's index (none for the root), a local translation, rotation and scale, and
  an optional mesh reference. Materials come from the mesh (§ *Materials per slot*).
- **Exactly one root.** A source with several top-level nodes gets a root named after the file.

Placing a model walks the list once and creates an entity per node, with `Name`, `Transform`,
`Hierarchy` and, where the node has a mesh, `MeshRenderer`. The new root goes at the scene's
root, at the origin. Entity ids are fresh; the model file is not referenced by the result.

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
  `float4` whose `w` is the bitangent's sign (±1, as glTF's), and UV0 `float2`. They stay
  unpacked until a measurement asks otherwise ([[Renderer - Design]] § *Geometry buffers*).
- **The indices**, `u32`, whole triangles.
- **The slots**, at least one: a name, a first index, an index count and a default material id.
  The ranges cover the indices in order, with no gap and no overlap, and each holds whole
  triangles. A slot with no source name is named `Slot <material index>`.

The loader lists each non-null default material as a dependency, so a slot that no renderer
entry covers still draws (§ *Materials per slot*). Until the material file exists (after S10-D7),
import writes null defaults.

**Tangents and a baked transform.** For a baked matrix `M`, normals take the inverse transpose,
tangents take `M`, and `w` is multiplied by the sign of `det(M)`, because a mirror flips the
bitangent. A Z-up swap written as an axis swap has a negative determinant; written as a rotation
it has none. MikkTSpace returns one tangent per face corner, so the mesh is re-indexed after it.

## Materials per slot

`MeshRenderer` keeps its mesh and gains a list of slots, each a name and an
`AssetRef<Material>`. After a rebuild, the list has one entry per mesh slot, in the mesh's order.

- **Filled from the mesh.** Placement copies each mesh's default materials, so placement loads
  the meshes first. Picking another mesh in the inspector does the same.
- **Rebuilt by name** when the editor opens a scene, once its meshes are ready, and over the open
  scene after a re-import. The rebuild is not an undo step.
- **A slot with no entry draws with the mesh's default.** That covers a scene nobody opened since
  a re-import and then exported, which still holds its old list.
- **Editing a slot** in the inspector is an ordinary `AssetRef` edit (ADR-026 §4).

The material type is S10-D7's. Today `Writer` and `Reader` refuse a vector of references
(`engine/core/include/TechEngine/core/serialization/Writer.hpp:95-97`, `Reader.hpp:108`), and
`ReferenceVisitor::field` skips a vector without a word (`ReferenceVisitor.hpp:25-29`), so the slot
card adds a walked vector path to all four visitors.

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

## Re-import

By hand only ([[Content Pipeline - Brief]]), and refused unless the editor is Stopped.

1. **Read the folder.** Every file under the import folder gives its kind, source key and id.
2. **Match each output** against files of its kind: by name first; among equal names, the index
   decides; an empty name matches by index alone. Matching by index first would hand every id to
   the wrong output when a tool reorders its arrays, with no error.
3. **Write.** A matched output keeps its id; a new one gets a fresh id. A matched material is
   never rewritten. An old file with no match stays and is logged, since E2's browser cannot
   delete and a scene that names it must still open.
4. **Settings** come from the root asset's import block. Importing the other way switches the
   root asset between `.temodel` and `.temesh` in the same folder; the old root stays and is
   logged, and `Materials/` keeps its edits.
5. **Reload.** The job sends one reload command naming the rewritten ids that are loaded. The
   simulation thread runs it as a loading phase: each payload is replaced behind its handle, new
   dependencies are acquired before the old ones are released, and render gets a new upload under
   its fence (ADR-028 §4). The slot rebuild then runs over the open scene.

`ResourceCache` has no reload today
(`engine/core/include/TechEngine/core/resources/ResourceCache.hpp`), so the re-import card adds one.

## Open questions

- **Textures:** the texture file, its BC formats per material input, mips and the library. They
  follow what a material samples. Owner: S10-D11, after S10-D7, starting with a `/triage` of the
  sky's HDR image, which no format in [[Content Pipeline - Brief]] covers.
- **The material file** that import writes into `Materials/`. Owner: S10-D7's type, then a build
  card cut after it.
- **A mirrored instance in a model:** a placed node with a negative determinant needs its front
  face flipped. Owner: R1, in [[Renderer - Design]] § *Open questions*.

## Porting v1's import

v1's model import worked, and this design already follows its shape: a folder per import, a
`.temodel`, and a child node per mesh. S10-T15 ports its assimp walk from
`v1-reference:runtime/editor/src/resources/loaders/AssimpLoader.cpp` and `ModelLoader.cpp`.
The code depends on v1's `ResourceSystem`, `FileSystem` and `Buffer`, so it is ported, not
copied. v1's model file is a recursive tree, so T14 takes nothing from it. Fix these on the
way:

- **Rotation goes through Euler angles** (`processScene`, then `convertNode`), which loses
  precision and breaks near gimbal lock. Keep the quaternion from `Decompose`.
- **No scale or up axis** is applied. This design bakes both at import.
- **Meshes are matched by name across the project** (`isMeshRegistered`), so two models' meshes
  named "Cube" share one file. Here every output gets its own id and a source key.
- **An unnamed material is named after its pointer address**, which changes on every run, so a
  re-import could never find it.
- **Points and lines survive `aiProcess_Triangulate`**, and `Mesh::read` refuses an index count
  that is not whole triangles. Add `aiProcess_SortByPType` and skip any mesh that isn't made of
  triangles.
- **The import runs on the editor's frame** ([[v1 Code Audit]] F14). Here it is a job.
- **Normals and UVs are written**, but today's mesh holds positions and indices only, until
  TEMesh v2. Leave `MeshLoader.cpp` alone: it is the atlas merge below.

## References

- v1's merge baked every material into one atlas and never worked; the per-slot merge avoids it.
- `engine/core/include/TechEngine/core/mesh/MeshRenderer.hpp:10-19`: the renderer holds a mesh only.
- `engine/core/include/TechEngine/core/serialization/FieldVisitor.hpp:120-122`: a vector field
  shows only its size in the inspector, so a slot list will need list rows.
