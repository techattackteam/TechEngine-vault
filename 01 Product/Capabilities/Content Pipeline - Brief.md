# Content Pipeline: Brief

**Map:** [[Capability Map]] § *Content pipeline*
**Goals:** E1 for export (M6, T2); E2 for import and the asset browser (T4, on E2's critical
path); the demo for packaging (T5). Skeletons and animation come with C1, for G3.
**Status:** agreed (2026-10-31)
**Feeds:** `Content Pipeline - Design` (S10-D9), or the ADR it drafts if the model format proves
ADR-level.

## Who uses it

- **Players:** nobody directly. They see the imported models through the renderer.
- **Developers:** before the demo, only Miguel ([[Renderer - Brief]] § *Decided*). He imports the
  reference models in the editor and ships them in the export's packs.

## Scenarios

1. Miguel imports Sponza (glTF) as a model. The scene gets one entity per mesh in the file's
   hierarchy, each with its mesh and its materials.
2. He imports Bistro (FBX). It arrives at the wrong size or rotated, so he sets its scale and up
   axis once, and the setting is kept for every later re-import.
3. He imports a file as one merged mesh instead. It keeps a material slot for each source
   material, and it is placed as one entity.
4. He edits an imported material in the inspector, changes the source file, and re-imports it.
   Every scene that used the asset still opens, and his material edit is kept.
5. He exports, and the runtime shows the same scene from its packs.

## Requirements

| | Requirement | Why |
|---|---|---|
| **Must, showcase (E2)** | Sponza and Bistro are imported and drawn with their materials and textures ([[Renderer - Brief]] § *Requirements*). | Scenarios 1 and 2 |
| **Must, E2** | Supported source formats: glTF, FBX and OBJ. | Bistro's FBX; Miguel, 2026-10-31 |
| **Must, E2** | Textures in PNG, JPEG, TGA and DDS. | What the three formats reference |
| **Must, E2** | At import, the user chooses a merged mesh or a model. A merged mesh is one mesh with one material slot per source material. A model keeps the file's hierarchy, with an entity per mesh. The file can be imported again the other way. | Scenarios 1 and 3 |
| **Must, E2** | glTF's material extras that the renderer draws (clear coat, sheen, transmission) and cut-outs come through import. | [[Renderer - Brief]], *Must, E2* |
| **Must, E2** | Re-import updates an asset in place: every scene that uses it keeps working, and a material the user edited is never overwritten. | Scenario 4 |
| **Must, E2** | Import settings for scale and up axis, kept with the asset and applied again on re-import. | Scenario 2 |
| **Must, E2** | A list-only asset browser: it lists the project's assets by folder, imports a file, and places a model in the scene. | Scenarios 1 and 3 |
| **Must, demo** | Export to content packs (M6), a packaged demo build (T5), and the editor's asset browser with import. | [[Capability Map]], unchanged |
| **Should, E2** | Compressed glTF (Draco or meshopt). | Cut first if E2 runs long |
| **Won't, for now** | Other formats as supported inputs. assimp may read them, but nothing promises them; more come if needed. | Miguel, 2026-10-31 |
| **Won't, for now** | Thumbnails, rename and delete in the browser. Drag and drop from Windows Explorer. Re-import on its own when a source file changes. | The browser is list-only in E2 |
| **Won't, for now** | Skeletons and animation (until C1). Morph targets. Cameras and lights stored in the source file. | Not needed by E2 |

## Numbers

| Budget | Value |
|---|---|
| Import time (Bistro, in the editor) | No number yet: measured first. |
| Runtime load time (a Bistro scene, launch to first frame) | No number yet: measured first. |

## What developers will expect

From memory, not checked against current docs:

- **FBX, OBJ and glTF import:** Unity and Unreal read all three; Godot prefers glTF. TechEngine
  meets it.
- **Import settings kept per asset and reapplied on re-import:** Unity's import settings, Godot's
  `.import` files and Unreal's reimport. TechEngine meets it for scale and up axis.
- **Re-import that keeps references:** standard in all three. TechEngine meets it.
- **Re-import on file change and drag and drop from the desktop:** Unity and Godot do both.
  TechEngine leaves them out for now.
- **A content browser with thumbnails:** standard everywhere. E2's browser is list-only.

## Depends on and constrains

- **Leans on:** M6's packs and bake: import writes runtime-form files that the export packs
  unchanged ([[ADR-025 - Content packs (.tepack and the runtime load path)]] §6). The standard
  material and its slots come from R1's materials ADR (S10-D7), and the vertex layout from the
  frame and device seam ADR (S10-D4).
- **Constrains S10-D9:** the mesh and model split, references and material edits that survive
  re-import, and settings kept with the asset. Re-import keeping references is the requirement
  behind [[Resources - Design]] § *Open questions*' sidecar-or-registry question.
- **Constrains the [[Editor - Brief]]:** E2's part of the demo's asset browser is list-only.

## Open questions

- **A GPU memory budget for Bistro's textures**, against the 6 to 8 GB target. It blocks nothing
  in S10-D9, but E2b's stress scene shares that memory.
- **When import and load times get their numbers.** "Measured first" needs a moment to set
  them, such as the first Bistro import.

## Decided

| Question | Answer | Date |
|---|---|---|
| Bistro and FBX | "I will be using assimp to import so we can support fbx." | 2026-10-31 |
| Supported formats | "gltf, fbx and obj I think for now is good enough. More in the future if needed." | 2026-10-31 |
| A placed model | "That is the distinction between the mesh and model. TEMesh packs every mesh inside the glft, fbx etc... into just a single mesh and material. The TEModel keeps the hierarchy and creates and entity per mesh and model." | 2026-10-31 |
| A merged mesh's materials | One material per slot: the merged mesh keeps a slot for each source material. | 2026-10-31 |
| Mesh or model | The user chooses at import, and can import again the other way. | 2026-10-31 |
| Re-import | A Must in E2: it updates the asset in place, and references survive. | 2026-10-31 |
| Material edits on re-import | The user's edits survive; re-import never overwrites an edited material. | 2026-10-31 |
| The asset browser in E2 | A list-only Must: it lists assets by folder, imports a file and places a model. Thumbnails, rename and delete come later. | 2026-10-31 |
| Texture formats | PNG, JPEG, TGA and DDS. | 2026-10-31 |
| Import and load times | No number yet for either. | 2026-10-31 |
| Out until later | Skeletons and animation, morph targets, and cameras and lights stored in the file. | 2026-10-31 |
| Compressed glTF | Should. | 2026-10-31 |
| Import settings | A Must in E2 for scale and up axis, kept with the asset. | 2026-10-31 |
| Drag and drop from Explorer | Won't for now. | 2026-10-31 |
| Re-import on file change | Won't; re-import is by hand. | 2026-10-31 |
