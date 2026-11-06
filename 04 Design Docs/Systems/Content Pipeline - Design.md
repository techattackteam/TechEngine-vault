# Content Pipeline: Design

> Living design doc. It turns a source file (glTF, FBX, OBJ) into runtime-form assets that the
> export packs unchanged. It is the hub for import work: plan and ground Story H from here.

**Module:** `core` (the model and mesh formats, the import block) · `apps/editor` (assimp, the
import, placement)
**Kind:** system
**Status:** the model is designed (2026-11-06, S10-D9) against engine `a67c4d4`; the mesh waits
on S10-P4's report. Nothing is built beyond the triangle's `Mesh`
(`engine/core/include/TechEngine/core/mesh/Mesh.hpp:19-29`).
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
| The import block | Every imported file (model, mesh, material, texture) carries one: the source path, the source key and the settings. Its type is in `core`; only the editor writes it; it ships in the packs and the runtime skips it. | S10-D9, 2026-11-06; § *The import block* |
| Import is editor-only, on the job system | assimp links into `apps/editor` alone. An import runs as a job and never blocks the editor's frame. | S10-D9, 2026-11-06 |
| Placement is one edit command | Main sends it; the simulation thread builds the entities. | ADR-027 §3 |
| Materials are created once | A re-import never overwrites a material file that already exists. | [[Content Pipeline - Brief]] § *Decided* |
| Before the asset browser | The editor imports one hardcoded source file at startup, skipped when its folder exists. Placement goes through a *Place model* menu entry with a typed path, never at startup, because each launch would add a copy to a saved scene. Both go when the browser lands. | Miguel, 2026-11-06 |
| The model starts on today's mesh | Until TEMesh v2, a model's meshes are written in today's format (positions and indices), and its nodes carry no materials. | S10-D9, 2026-11-06 |

## The model file

A `.temodel` is a binary blob with its own `BlobKind`, like the mesh and the scene. It holds:

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

- **Source path:** the source file, relative to the project.
- **Source key:** what the file was made from inside the source, such as a mesh's index and
  name in assimp's scene. A re-import matches each output to its old file by this key, so the
  file keeps its id and every reference to it survives.
- **Settings:** scale and up axis in the root asset; empty in the others.

The type is in `core` because the runtime must step over it when it reads a packed file. Only
the editor fills it in.

## Open questions

- **TEMesh v2.** One mesh with material slots, each slot one index range. Its vertex attributes,
  tangents and an optional second UV set for R7's baked mesh LOD wait on S10-P4's report. Owner:
  S10-D9, after S10-P4.
- **Materials per slot on the renderer.** The lean: the mesh file keeps a default material per
  slot, and `MeshRenderer` holds overrides matched by slot name, as Unreal does from memory.
  The material type itself is S10-D7's. Owner: S10-D9 with TEMesh v2.
- **Textures:** BC compression, mips, and which library. Waits on S10-P4. Owner: S10-D9.
- **Re-import reloads at once.** It needs a dated amendment to ADR-024 §9, whose reload waits.
  Filed with the re-import card's design, not yet.
- **The merged mesh.** One material slot per source material, with no texture atlas. Atlas
  baking belongs to R7's mesh LOD, whose papers are queued on [[Research]].

## References

- v1's merge baked every material into one atlas and never worked; the per-slot merge avoids it.
- `engine/core/include/TechEngine/core/mesh/MeshRenderer.hpp:10-19`: the renderer holds a mesh only.
- `engine/core/include/TechEngine/core/serialization/FieldVisitor.hpp:120-122`: a vector field
  shows only its size in the inspector, so a slot list will need list rows.
