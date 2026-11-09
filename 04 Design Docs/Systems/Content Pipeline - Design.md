# Content Pipeline: Design

> Living design doc. It turns a source file (glTF, FBX, OBJ) into runtime-form assets that the
> export packs unchanged. It is the hub for import work: plan and ground Story H from here.

**Module:** `core` (the model and mesh formats, the import block) · `apps/editor` (assimp, the
import, placement)
**Kind:** system
**Status:** the model is designed (2026-11-06, S10-D9) against engine `a67c4d4`; the mesh is S10-D10's; S10-P4's
report is in ([[Content Pipeline - Mesh Import Report]], Nov 9). assimp is in the editor's build with only its glTF, FBX and OBJ importers
(S10-T13, `cmake/deps.cmake`). The model file and the import block are built, with write and
read (S10-T14, `engine/core/include/TechEngine/core/model/Model.hpp` and
`engine/core/include/TechEngine/core/assets/ImportBlock.hpp`). The import, the placement and
the mesh beyond the triangle's `Mesh` are not.
**ADRs:** [[ADR-025 - Content packs (.tepack and the runtime load path)]] §6 ·
[[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §9 ·
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
| The model starts on today's mesh | Until TEMesh v2, a model's meshes are written in today's format (positions and indices), and its nodes carry no materials. | S10-D9, 2026-11-06 |

## The model file

A `.temodel` is a binary blob with its own `BlobKind`, like the mesh and the scene. It holds:

- **Its id, straight after the header**, as in the mesh and the scene, because the editor's
  asset index reads only the first 16 bytes (`ASSET_PREFIX_SIZE` in
  `apps/editor/src/assets/AssetIndex.cpp`).
- **The import block** (§ below), whose settings are the scale and up axis.
- **A node list in parent-first order**, so a node's parent is always earlier. Each node has a
  name, its parent's index (none for the root), a local translation, rotation and scale, an
  optional mesh reference, and, after TEMesh v2, one material reference per mesh slot.
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
  reference to it survives. How it matches on the two parts is S10-D10's.
- **Settings:** scale and up axis, where the up axis is Y or Z. Every block writes them, so
  the layout never branches; files other than the root asset carry the defaults, scale 1 and
  Y up.

The type is in `core` because the runtime must step over it when it reads a packed file. Only
the editor fills it in.

## Open questions

- **TEMesh v2.** One mesh with material slots, each slot one index range. Its vertex attributes,
  tangents and an optional second UV set for R7's baked mesh LOD are mapped in
  [[Content Pipeline - Mesh Import Report]] §4 and §7. Owner: S10-D10.
- **Materials per slot on the renderer.** The lean: the mesh file keeps a default material per
  slot, and `MeshRenderer` holds overrides matched by slot name, as Unreal does from memory.
  The material type itself is S10-D7's. Owner: S10-D10, with TEMesh v2.
- **Textures:** BC compression, mips, and which library. The libraries are mapped in
  [[Content Pipeline - Mesh Import Report]] §6; no speed was measured. Owner: S10-D10.
- **Re-import reloads at once.** It needs a dated amendment to ADR-024 §9, whose reload waits.
  Owner: S10-D10.
- **The merged mesh.** One material slot per source material, with no texture atlas. Atlas
  baking belongs to R7's mesh LOD, whose papers are queued on [[Research]]. assimp's
  flattening merge does not fix winding under a negative scale
  ([[Content Pipeline - Mesh Import Report]] §3). Owner: S10-D10.

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
