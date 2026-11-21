# Content Pipeline: Brief

**Map:** [[Capability Map]] § *Content pipeline*
**Goals:** E1 for export (M6, T2); E2 for import and the asset browser (T4, on E2's critical
path); the demo for packaging (T5). Skeletons and animation come with C1, for G3.
**Status:** agreed (2026-10-31)
**Feeds:** [[Content Pipeline - Design]] (S10-D9).

## Who uses it

- **Players:** nobody directly. They see the imported models through the renderer.
- **Developers:** before the demo, only Miguel ([[Renderer - Brief]] § *Decided*). He imports the
  reference models in the editor and ships them in the export's packs.

## Scenarios

1. Miguel imports Sponza (glTF) as a model. The scene gets one entity per mesh in the file's
   hierarchy, each with its mesh and its materials.
2. He imports Bistro (FBX). It arrives at the wrong size or rotated, so he sets its scale and up
   axis in the create dialog.
3. He imports a file as one merged mesh instead. It keeps a material slot for each source
   material, and it is placed as one entity.
4. He changes the source file and creates it again. The new copy lands beside the old one, and
   he places it. He deletes the old copy, and every scene that used it still opens, warning
   about the missing asset.
5. He exports, and the runtime shows the same scene from its packs.

## Requirements

| | Requirement | Why |
|---|---|---|
| **Must, showcase (E2)** | Sponza and Bistro are imported and drawn with their materials and textures ([[Renderer - Brief]] § *Requirements*). | Scenarios 1 and 2 |
| **Must, E2** | Supported source formats: glTF, FBX and OBJ. | Bistro's FBX; Miguel, 2026-10-31 |
| **Must, E2** | Textures in PNG, JPEG, TGA and DDS, beside the model file or embedded in it as PNG or JPEG (a `.glb`, an FBX). | What the three formats reference; embedded images, Miguel, 2026-11-10 |
| **Must, E2** | The sky image as a Radiance `.hdr`, imported on its own rather than through a model file. | [[Renderer - Brief]]'s sky image; `/triage`, 2026-11-10 |
| **Must, E2** | At import, the user chooses a merged mesh or a model. A merged mesh is one mesh with one material slot per source material. A model keeps the file's hierarchy, with an entity per mesh. The file can be imported again the other way. | Scenarios 1 and 3 |
| **Must, E2** | Cut-outs come through import. glTF's material extras (clear coat, sheen, transmission) come through when the renderer draws them, which is after E2 since 2026-11-09. | [[Renderer - Brief]] § *Decided* |
| **Must, E2** | Import settings for scale and up axis, chosen when a copy is created. | Scenario 2 |
| **Must, E2** | An asset browser: a folder tree beside the open folder, breadcrumbs, Ctrl, Shift and box selection, a right-click menu that creates a model or mesh from a source and places it, and drags to the scene view, the hierarchy and the inspector's asset fields. | Scenarios 1 and 3; Miguel, 2026-11-21 |
| **Must, E2** | Delete in the browser, after a warning that lists what uses the asset. Every scene that used it still opens. | Scenario 4; Miguel, 2026-11-21 |
| **Must, demo** | Export to content packs (M6), a packaged demo build (T5), and the editor's asset browser with import. | [[Capability Map]], unchanged |
| **Should, E2** | Compressed glTF (Draco or meshopt). | Cut first if E2 runs long |
| **Won't, for now** | Other formats as supported inputs. assimp may read them, but nothing promises them; more come if needed. EXR is one of them, because the sky needs only `.hdr`. Embedded images stored as raw pixels are refused. | Miguel, 2026-10-31; EXR and raw pixels, 2026-11-10 |
| **Won't, for now** | Thumbnails, rename and copy in the browser. Drag and drop from Windows Explorer. Dropping a texture on a material. Each is a future feature in [[Content Pipeline - Design]] § *Future features*. | Miguel, 2026-11-21 |
| **Won't** | Re-import. Creating from a source always writes a new copy. | Miguel, 2026-11-21: "It got clanky really quick" |
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
  `.import` files and Unreal's reimport. TechEngine sets scale and up axis per copy, at create.
- **Re-import that keeps references:** standard in all three. TechEngine leaves it out on
  purpose: a changed source becomes a new copy, placed again (2026-11-21).
- **Drag and drop from the desktop:** Unity and Godot do it. TechEngine leaves it out for now.
- **A content browser with thumbnails:** standard everywhere. E2's browser shows icons.

## Depends on and constrains

- **Leans on:** M6's packs and bake: import writes runtime-form files that the export packs
  unchanged ([[ADR-025 - Content packs (.tepack and the runtime load path)]] §6). The standard
  material and its slots come from R1's materials ADR (S10-D7), and the vertex layout from the
  frame and device seam ADR (S10-D4).
- **Constrains S10-D9:** the mesh and model split, references and material edits that survive
  re-import, and settings kept with the asset. Re-import keeping references is the requirement
  behind [[Resources - Design]] § *Open questions*' sidecar-or-registry question.
- **Constrains the [[Editor - Brief]]:** E2's part of the demo's asset browser is the core and
  delete (2026-11-21).

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
| Re-import | Removed: "We should change the options to 'create model' 'create mesh' and thats it it does not matter if there is already another model or mesh from that source it will create a new one." It replaces the Oct 31 Must. | 2026-11-21 |
| The asset browser in E2 | The core, plus delete: two panes, breadcrumbs, double-click to open, Ctrl, Shift and box selection, the right-click menu, and drags. Everything else is a future feature. | 2026-11-21, replacing the Oct 31 list-only Must |
| Deleting an asset | Permanent, after a warning; a missing asset loads as absent. | 2026-11-21 |
| Texture formats | PNG, JPEG, TGA and DDS. | 2026-10-31 |
| Import and load times | No number yet for either. | 2026-10-31 |
| Out until later | Skeletons and animation, morph targets, and cameras and lights stored in the file. | 2026-10-31 |
| Compressed glTF | Should. | 2026-10-31 |
| Import settings | A Must in E2 for scale and up axis, kept with the asset. | 2026-10-31 |
| Drag and drop from Explorer | Won't for now; a future feature. | 2026-10-31; 2026-11-21 |
| Links and prefabs | None: "there wont be any link/prefab features." | 2026-11-06 |
| A placed model | A copy: "Once the model is added to the scene the changes made wont reflect the others nor the model file." | 2026-11-06 |
| The sky's image | A Radiance `.hdr`, a Must in E2, for the sky only. EXR stays out (`/triage` at S10-D11). | 2026-11-10 |
| Embedded images | A Must: "yes we must support it". PNG and JPEG only; raw-pixel images are not needed. | 2026-11-10 |
