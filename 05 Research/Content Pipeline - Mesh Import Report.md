---
tags: [research]
status: report
---

# Content Pipeline: Mesh Import Report

The research report for TEMesh v2 and the merged mesh ([[Content Pipeline - Design]] § *Open
questions*, [[2026-10 Sprint 10 - Close E1]] § *Story H*). Card S10-P4, written unattended on
Nov 9, 2026. **It maps; it does not choose or recommend.** Every decision below is Miguel's, in
S10-D10.

**How to read the sources.** Unlike S10-P1 and S10-P3, most of this card is about code, and the
code was reachable. These were cloned and read at the commits given:

| Tag | Source | Commit |
|---|---|---|
| **[A]** | assimp, at the `v6.0.5` tag that `cmake/deps.cmake` pins | `392a658` |
| **[M]** | MikkTSpace, `mikktspace.h` | `3e895b4` (2020) |
| **[G]** | The glTF 2.0 specification and its `extensions/2.0/Khronos/` folder | `9ec408b` (main) |
| **[L]** | The READMEs and licence files of bc7enc_rdo (`b943862`), ISPCTextureCompressor (`79ddbc9`), Compressonator (`095a143`), DirectXTex (`c0cb977`), betsy (`cc723dc`) and basis_universal (`073eb6a`) | as given |
| **[E]** | The engine at `origin/master` `ac594e4` | |

A claim tagged **[S]** rests on a search extract, **(memory)** on what I knew before this run,
and **(inference)** on my own reading of two facts together. **No speed was measured.** Building
the compressors to time them was refused by the sandbox's policy on running third-party code, and
`aras-p.info`, which holds the one independent benchmark, fails at the proxy.

## 1. How assimp merges a file into one mesh

Two flags merge, and they work at different levels.

| Flag | What it does | Source |
|---|---|---|
| `aiProcess_PreTransformVertices` | Bakes every node's absolute transform into its meshes' vertices, then **joins every mesh that shares a material index and a vertex format** into one `aiMesh`. The node tree is replaced by a root with one child per output mesh. | [A] `PretransformVertices.cpp:430-560`, `600-650` |
| `aiProcess_OptimizeMeshes` | Joins meshes **inside one node only**, when they share a material, a vertex format and primitive types. It skips any mesh used by more than one node, and every skinned mesh. No transform is applied, because the meshes share a node. | [A] `OptimizeMeshes.cpp:156-235` |
| `aiProcess_OptimizeGraph` | Collapses nodes that carry no animation, bone, light or camera, and so feeds `OptimizeMeshes` larger groups. The header says it "is not useful for editor environments". | [A] `postprocess.h:475-500` |

So `PreTransformVertices` is the flag that turns a whole file into "one mesh per material", and
`OptimizeMeshes` alone never crosses a node.

### What `PreTransformVertices` loses

- **The hierarchy and every node name.** Output nodes are named after the mesh, and a joined mesh
  takes the name of the last mesh merged into it. [A] `PretransformVertices.cpp:155-159`, `618`
- **Animations and bones.** Both are deleted. [A] `:448-458`, `:572-577`
- **Instancing.** A mesh used by three nodes is copied three times into world space. [A] `:240-250`
- **Nothing per vertex**, as long as formats match: normals, tangents, every UV set and every
  colour set are copied. Lights and cameras are kept and moved into world space. [A] `:500-530`, `:580-600`
- **The header's warning about zeroed normals is out of date.** The code never joins two formats:
  a material used by meshes with and without normals gives **two** output meshes, one per vertex
  format (`GetMeshVFormatUnique`, [A] `ProcessHelper.cpp:166-196`). (inference from the code)

## 2. A slot per source material, with no atlas

After `PreTransformVertices`, the scene holds about one `aiMesh` per material. Each can become one
TEMesh slot, an index range over shared vertex streams, by concatenating them. assimp has no
"one mesh with sub-ranges" output, so that concatenation is TechEngine's code. (inference)

Three details decide how clean the slots are:

- **Two slots can share one material.** That happens when one material's meshes have different
  vertex formats (§1). Either the merge fills the missing attributes with defaults and joins
  them, or it keeps two slots with the same material. (inference)
- **Duplicate materials split slots.** Two material entries with identical properties stay two
  slots unless `aiProcess_RemoveRedundantMaterials` runs first; the header names it as the
  companion of the merge flags. [A] `postprocess.h:294-312`
- **No atlas is involved.** Each slot keeps its own material and textures, so the UVs are
  untouched. v1's merge baked everything into one atlas and never worked
  ([[Content Pipeline - Design]] § *References*).

**An alternative that keeps assimp out of the merge:** import as a model (the tree S10-T15
already walks), then have the engine bake each node's world transform into its meshes and
concatenate by material. That uses the same walk for both import kinds, and it controls the
winding fix in §3, which `PreTransformVertices` gets wrong. (inference)

## 3. Winding under a negative scale

**glTF's rule** [G] `Specification.adoc:2198-2205`: the sign of the determinant of a node's
**global** transform sets the winding. Positive means counter-clockwise is front-facing; negative
means clockwise is, which is how a file mirrors geometry with a negative scale.

**What assimp does with it** [A]:

| Path | Winding under a negative determinant |
|---|---|
| `PreTransformVertices`, default (the flattening merge) | **Not fixed.** `CollectData` transforms positions and normals but copies the faces as they are (`:140-260`). A mirrored part of a merged mesh comes out inside-out. |
| `PreTransformVertices` with `AI_CONFIG_PP_PTV_KEEP_HIERARCHY` | Fixed: `ApplyTransform` flips the faces when `Determinant() < 0` (`:300-305`). |
| `OptimizeGraph` | Fixed the same way (`OptimizeGraph.cpp:189-193`). |
| No flattening (a model, transforms kept on nodes) | Nothing to fix at import. The renderer must flip its front face for an entity whose world matrix has a negative determinant. (inference) |

**Two TechEngine-specific notes** (inference):

- **The baked up axis.** A Z-up to Y-up conversion written as a rotation has determinant +1 and
  flips nothing. Written as a swap of the Y and Z axes, it has determinant −1 and flips every
  triangle. S10-T15 bakes it, so the sign is worth one test.
- **Tangents flip with it.** For a mirror `M`, `cross(Mn, Mt) = det(M)·M(n×t)`, so the
  bitangent sign `w` must be multiplied by the sign of the determinant when a transform is baked.
  `PreTransformVertices` transforms tangents and bitangents with the inverse transpose, like
  normals (`:200-205`, `:316-327`). That is exact for a rotation with uniform scale and slightly
  wrong for a tangent under non-uniform scale, where the tangent should take `M` itself.

## 4. MikkTSpace tangents

**What it is** [M]: two standalone C files with callbacks for positions, normals and UVs per
face corner. It welds internally and returns a tangent and a sign per corner, **unindexed**, and
its header says not to average the results through an existing index list. It is the tangent
space that baking tools (Substance, Blender, xNormal) write normal maps against. (memory, for the
tool list)

**What glTF asks** [G] `:1664`, `:1707`, `:1823-1827`: `TANGENT` is a `vec4` whose `w` is ±1; the
bitangent is `cross(normal, tangent.xyz) * w`. When a file has a normal map and no tangents, the
client **should generate MikkTSpace** from positions, normals and the normal map's UV set.

**What assimp gives** [A]:

- **`aiProcess_CalcTangentSpace` is not MikkTSpace.** It is a per-face tangent projected onto
  each normal and smoothed by angle (`CalcTangentsProcess.cpp:100-230`). No MikkTSpace code exists
  in the tree. A normal map baked in MikkTSpace will show seams and shading errors on it.
  (inference, from the algorithm's difference)
- **assimp stores a tangent and a bitangent, with no `w`.** The glTF importer rebuilds the
  bitangent from glTF's `w` (`glTF2Importer.cpp:585-600`). A TEMesh with a `vec4` tangent would
  recover `w` as the sign of `dot(cross(n, t), b)`. (inference)

**How it would run in an import:** call MikkTSpace on triangles after the scale and up axis are
baked, then re-index, because each corner may now carry a different tangent. MikkTSpace has no
re-indexer of its own. (inference; meshoptimizer's vertex remap is the usual tool, from memory)

## 5. glTF material extensions through assimp

[A] `glTF2Importer.cpp:240-400`, `glTF2Asset.inl:2160-2210`, against [G]'s extension folder:

| Extension | Through assimp 6.0.5 | Note |
|---|---|---|
| `KHR_materials_clearcoat` | **Yes** | Factor, roughness and three textures (clear coat, roughness, normal). Dropped when the factor is 0, which is glTF's default and means off. |
| `KHR_materials_sheen` | **Yes** | Colour, roughness and two textures. Dropped when the colour factor is 0, glTF's "off". |
| `KHR_materials_transmission` | **Yes** | Factor and texture. |
| `KHR_materials_volume` | Yes | Thickness, its texture, attenuation distance and colour. |
| `KHR_materials_ior`, `_specular`, `_emissive_strength`, `_anisotropy`, `_unlit` | Yes | `_unlit` sets the shading mode to `aiShadingMode_Unlit`. |
| `KHR_texture_transform` | Yes | Read per texture. |
| `KHR_materials_iridescence`, `_dispersion`, `_diffuse_transmission`, `_variants` | **No** | Not read; their properties are lost without a warning. |
| `KHR_draco_mesh_compression` | **Refused** | `ASSIMP_BUILD_DRACO` is off by default and our `deps.cmake` does not set it, so a file that *requires* it throws "Draco mesh compression not supported". |
| `KHR_mesh_quantization`, `KHR_meshopt_compression` | **No, and not refused** | Only Draco, BasisU and WebP are checked as required. `Accessor::ExtractData` copies raw bytes with `memcpy` and never converts a normalized integer (`glTF2Asset.inl:1021-1070`), so a quantized file imports with garbage positions instead of failing. (inference from the code; gltfpack writes both by default, from memory) |

The three the [[Capability Map]] names for E2, clear coat, sheen and transmission, all survive.

## 6. BC compression libraries

Speeds are not in any of the READMEs, and none was measured (see the top).

| Library | Formats | Licence | Fit notes | Source |
|---|---|---|---|---|
| **bc7enc_rdo** (`rgbcx.h`, `bc7enc.cpp`, `bc7e.ispc`) | BC1-5 (rgbcx), BC7 (bc7enc, or bc7e via ispc) | MIT or public domain; `bc7e.ispc` Apache 2.0 | Plain C++ except `bc7e`, which needs the ispc compiler. `bc7e` also has a plain C++ port inside basis_universal (`encoder/basisu_bc7e_scalar.cpp`). Optional RDO for smaller packed files. No BC6H. | [L] |
| **ISPCTextureCompressor** | BC1, BC3-5, BC6H, BC7, ASTC, ETC1 | MIT | **Discontinued by Intel**, says its README. Needs the ispc compiler. | [L] |
| **Compressonator** | All BC formats, ASTC, ETC | MIT | A whole SDK and tool suite rather than one encoder. | [L] |
| **DirectXTex** | All BC formats; BC6H and BC7 on the GPU through DirectCompute | MIT | Builds with Visual Studio or MinGW; on Linux only through WSL with GCC 11. | [L] |
| **betsy** | BC1, BC3-5, BC6H, ETC1/2, EAC on the GPU in OpenGL | MIT | **No BC7.** Last commit 2022. | [L] |
| **basis_universal** | Supercompressed formats that transcode to BC1-7 | Apache 2.0 | A different model: ships one intermediate file and transcodes at load, instead of BC data that is uploaded as is. | [L] |

**Relative speeds, from search extracts only** [S]: bc7e's README claims about 2-3× the speed of
ispc_texcomp at the same average quality, and up to about 8× against its slow profile; both are
the author's own figures. Aras Pranckevičius's 2020 comparison found high-quality BC7 encoders
(above 45 dB) running at 10-20 Mpix/s, and favoured bc7e over ISPC on quality, speed or both. A
newer analytical encoder, bc7f (2026), is said to be faster still. **Check these against a run on
Miguel's machine before the design leans on a number.**

## 7. An optional second UV set in TEMesh v2

**What the engine does with a format change today** [E]: `Reader.cpp:25-28` refuses any blob whose
version differs from the kind's (`ReadError::BadVersion`), and `Mesh.hpp:15` has
`MESH_KIND{…, 1}`. So adding an attribute later is a version bump, and every `.temesh` already
written fails to load until it is imported again. The blob header's 16-bit `flags` field is read
and kept (`Reader.cpp:30-38`), but nothing uses it yet.

| Option | Cost now | Cost at R7 |
|---|---|---|
| **A presence flag per stream** (UV1, colours, tangents) | One flags field in the mesh; an empty stream costs no bytes. | R7 writes UV1 into new files, and old files still load. |
| **No UV1, bump the version at R7** | Nothing. | Every imported mesh must be re-imported, which the re-import S10-D10 designs makes possible. |

**What a second set would be for** (inference): R7's baked LOD needs a non-overlapping atlas UV to
bake colour and normals into ([[Research]]: Iso-charts, Box Cutter, Seamless, queued Nov 6). That
UV belongs to the **simplified** LOD mesh, which the bake creates. The source mesh would not need
it. Lightmaps are the other usual user of a second UV, and the [[Capability Map]]'s global
illumination follows terrain edits and the day and night cycle, so it is not lightmapped.
assimp itself reads up to eight UV sets per mesh, glTF's `TEXCOORD_1` included
([A] `glTF2Importer.cpp:627-645`).

## Questions S10-D10 must decide

1. Does the merged mesh come from `aiProcess_PreTransformVertices`, or from the engine baking
   S10-T15's model walk (§2)? If from assimp, who fixes mirrored winding (§3)?
2. When one material's meshes differ in vertex format, are the missing attributes filled with
   defaults, or does the material get two slots (§2)?
3. Does `aiProcess_RemoveRedundantMaterials` run, so duplicate materials share a slot (§2)?
4. Are tangents MikkTSpace, generated at import and stored as `vec4`, or generated by assimp
   (§4)? Are a file's own glTF tangents kept when present?
5. Does the renderer flip the front face for a placed node with a negative determinant (§3)?
6. Which unsupported glTF cases are refused with an error: Draco already is; quantized and
   meshopt-compressed files are not (§5)?
7. Which BC library, for which formats (colour, normal maps as BC5, HDR as BC6H), and does it
   need the ispc compiler in the editor's build (§6)?
8. Does TEMesh v2 carry per-stream presence flags, a second UV set, both or neither (§7)?

## Unverified

- No speed was measured, and §6's relative speeds rest on search extracts and the authors' claims.
- The assimp findings are read from source, not run: no file was imported to confirm the inside-out
  merge in §3 or the garbage positions in §5. A two-node glTF with one node scaled −1 on X would
  prove §3 in S10-T15's tests.
- glTF's spec and extension list were read at `main`, not at a release.
