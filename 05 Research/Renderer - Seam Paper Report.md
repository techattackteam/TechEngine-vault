---
tags: [research]
status: report
---

# Renderer: Seam Paper Report

The paper report for R1's first ADR, the frame and device seam with lights and culling
([[Renderer - Brief]], [[2026-10 Sprint 10 - Close E1]] § *Story E*). Card S10-P1, written
unattended on Nov 3, 2026. **It maps; it does not choose or recommend.** Every decision below is
Miguel's, in S10-D4's ADR.

[[Renderer - Research Brief]] compared how five engines split the seam. This note takes the four
validated culling, draw submission and many-lights papers in [[Research]] § *Rendering* and maps
them onto that brief's questions (Q1, T1, T2) and the [[Renderer - Brief]]'s numbers. The
materials papers are S10-P3's.

**How to read the sources, and this report's limit.** None of the four primary documents could
be opened from the sandbox: `highperformancegraphics.org`, `advances.realtimerendering.com`,
`gdcvault.com` and `cse.chalmers.se` are all outside the session's network allowlist. Every claim
therefore rests on a **search extract** of the paper or of a write-up about it (tagged, for
example **[S1]**, in *Sources*), on **(memory)**, what I knew before this run and did not check
today, or on **(inference)**, my own reading of two facts together. Memory is the larger share
here than in the research brief. **Check any number in the paper before the ADR relies on it.**

## The four papers

| Paper | What it is | Maps onto |
|---|---|---|
| [[Paper#Clustered Deferred and Forward Shading]], Olsson, Billeter and Assarsson, HPG 2012 | Lights assigned to 3D clusters of view samples instead of 2D screen tiles. | T1, hundreds of lights |
| [[Paper#GPU-Driven Rendering Pipelines]], Haar and Aaltonen, SIGGRAPH 2015 | Instance and mesh-cluster culling on the GPU, two-phase occlusion against a depth hierarchy, multi-draw. | T2, hundreds of thousands of objects |
| [[Paper#Optimizing the Graphics Pipeline with Compute]], Wihlidal, GDC 2016 | Per-triangle culling in compute before the rasterizer, with a compacted index stream. | T2, later |
| [[Paper#A Deep Dive into Nanite Virtualized Geometry]], Karis, Stubbe and Wihlidal, SIGGRAPH 2021 | A cluster hierarchy for LOD, GPU culling and a software rasterizer for small triangles. | Beyond E2 (R7, W2) |

## Clustered Deferred and Forward Shading (2012)

| Topic | Finding | Source |
|---|---|---|
| Idea | View samples are grouped into clusters by 3D position, and optionally by normal, where tiled shading groups them by 2D screen position only. Each cluster gets the lights that reach it. | [S1] |
| Grid | Screen tiles times depth slices. The paper shows three ways to slice depth; the one usually taken is exponential in view space. Later engines start from grids such as 16 x 9 x 24 (DOOM 2016). | [S5], (memory for the exponential one) |
| Occupied clusters | The deferred variant finds the clusters that actually hold samples and assigns lights only to those. The forward variant needs a depth pre-pass to know them, or assigns to every cluster. | (memory) |
| Light assignment | Hierarchical, over a tree of lights; real-time up to about one million lights. | [S1] |
| Normal cones | A cluster can also cull lights that face away from all its samples. | [S1] |
| Worst case | Better than tiled shading on high-frequency geometry with large depth jumps, where a 2D tile spans a long depth range. | [S1] |
| Implementation | Assignment and compaction ran in CUDA beside OpenGL. One later slide deck says the paper culled on the CPU; I could not settle which. | (memory), [S8] |
| Follow-up | *Tiled and Clustered Forward Shading* (SIGGRAPH 2012 talk): clustered forward beats tiled forward by more than 2x, and beats tiled deferred with MSAA. | [S2] |

## GPU-Driven Rendering Pipelines (2015)

| Topic | Finding | Source |
|---|---|---|
| Clusters | Meshes are cut into clusters of 64 triangles. An instance becomes one sub-draw, and the surviving clusters' indices are appended to an index buffer on the GPU. | [S3] |
| Stages | Instance culling (frustum, occlusion), cluster chunk expansion, cluster culling (frustum, occlusion, triangle backface), index buffer compaction, then multi-draw. | [S3] |
| Two-phase occlusion | Draw what was visible last frame, build a depth hierarchy (Hi-Z) from it, test everything else against it, and draw what became visible. | (memory) |
| Materials | Virtual texturing lets one draw cover many materials, which is what makes few draws possible. | (memory) |
| Draw shape | One of the authors later wrote that multi-draw indirect is faster for high-polygon objects, and custom vertex-shader clustering for small low-polygon ones. Informal, not the talk. | [S4] |
| Platform | DirectX 11 and the consoles. Multi-draw indirect and compute are core in GL 4.3, so within 4.5. | (memory) |

## Optimizing the Graphics Pipeline with Compute (2016)

| Topic | Finding | Source |
|---|---|---|
| Idea | One compute thread per triangle culls before the rasterizer: orientation and zero area, small primitives that enclose no pixel centre, and the frustum. Survivors are compacted into a new index stream with an atomic counter. | [S6] |
| Clusters | Triangles are bucketed into clusters by spherical coordinates, and each cluster is reordered for the vertex cache. | [S6] |
| Batches | Meshes that share a shader and vertex and index strides form a batch, near one-to-one with a D3D12 pipeline state. | [S6] |
| Platform | AMD GCN centred; the culling runs on async compute while the rasterizer works. | [S7] |
| Draw output | The culled streams are drawn through indirect draws whose counts the GPU writes. The extracts did not confirm this. | (memory) |

## A Deep Dive into Nanite Virtualized Geometry (2021)

| Topic | Finding | Source |
|---|---|---|
| Clusters | Clusters of 128 triangles, grouped and simplified into a hierarchy (a DAG) that picks LOD per cluster group. | [S10] for 128, (memory) for the DAG |
| Culling | Two-pass occlusion against the previous frame's depth hierarchy, as in the 2015 talk, run on the GPU. | (memory); not confirmed by the extracts |
| Software raster | Small triangles are rasterized in compute and written with a 64-bit atomic max (depth above, cluster and triangle ids below) into a visibility buffer; larger ones go to the hardware rasterizer. | [S10], [S11], [S12] |
| Materials | Materials are shaded afterwards, from the visibility buffer, not while rasterizing. | (memory) |
| Limits in 2021 | Rigid, opaque meshes only: no skinning and no translucency. | (memory) |

## T1 and T2 mapped: what each paper asks of the frame

| Target | Paper | What it puts on the frame | Caveat |
|---|---|---|---|
| T1, hundreds of lights | Olsson et al. | A cluster grid and light-index lists in storage buffers, rebuilt each frame; a compute dispatch if they are built on the GPU. | The brief's starting point is the forward variant, which needs a depth pre-pass to use only occupied clusters (memory). Hundreds of lights is three orders below the paper's million, so a flat, non-hierarchical assignment may be enough (inference). |
| T2, hundreds of thousands of objects | Haar and Aaltonen | Instance data resident on the GPU, a culling pass that writes draw commands, and one multi-draw per batch. | A GPU-written draw count needs `glMultiDrawElementsIndirectCount`, core in 4.6 or `ARB_indirect_parameters` on 4.5; without it, culled commands are written with zero instances (memory). Two-phase occlusion also needs a depth pyramid built each frame. |
| T2, later | Wihlidal | Compute writes index buffers that the rasterizer then reads. | Pays off only where the frame is triangle-bound; whether Sponza and Bistro at 1080p are is unmeasured (inference). GL has no separate compute queue, so the async overlap the talk relies on is unavailable (memory). |
| The million cubes (Should) | None of the four | All four assume instance data stays on the GPU and only changes are uploaded (memory). | A million cubes all move every frame, so their cost is the snapshot crossing to the render thread and the buffer upload, as the research brief already says (inference). |
| Beyond E2 | Nanite | A visibility buffer, 64-bit image atomics and a deferred material pass. | 64-bit image atomics are not core in GL 4.5, only vendor extensions (memory), as [[Research]] already notes. Its material pass would change the surface contract of T4 (inference). |

## Q1 mapped: what the seam must expose for each paper

| Capability | Olsson | Haar and Aaltonen | Wihlidal | Nanite | In GL 4.5 core? |
|---|---|---|---|---|---|
| Storage buffers | Yes | Yes | Yes | Yes | Yes, since 4.3 (memory) |
| Compute dispatch | If built on the GPU | Yes | Yes | Yes | Yes, since 4.3 (memory) |
| Indirect multi-draw | No | Yes | Yes | Yes, for the hardware path | Yes, since 4.3 (memory) |
| GPU-written draw count | No | Yes | Yes | Yes | No: 4.6, or `ARB_indirect_parameters` (memory) |
| Atomic counters or atomics on buffers | If built on the GPU | Yes, for compaction | Yes | Yes | Yes (memory) |
| Depth pyramid (read depth, write mips) | No | Yes | Optional | Yes | Yes (memory) |
| 64-bit image atomics | No | No | No | Yes | No (memory) |
| A second, async compute queue | No | No | Assumed | No | No (memory) |

**Today's starting point** is unchanged since the research brief: `client` has `Buffer`,
`VertexArray` and raw program ids in `FrameRenderer`, and no seam type (research brief § *Q1
mapped: where each seam sits*). None of the capabilities in this table exists in the engine yet.

## What S10-D4 still has to decide

The report closes none of these; it lists where the papers raise them.

- **Compute on the seam from the start:** T1 needs it only if the clusters are built on the GPU;
  T2 needs it only if culling moves to the GPU.
- **Who writes the draw commands:** the CPU from the snapshot, or a GPU culling pass. If the
  GPU, whether the engine requires GL 4.6 or `ARB_indirect_parameters`, or writes
  zero-instance commands.
- **A depth pre-pass:** clustered forward and two-phase occlusion both read depth before the
  lit pass.
- **Where instance data lives,** and how changed transforms reach it (the cubes).
- **Whether meshes are cut into clusters at import** (64 or 128 triangles), which is a question
  for [[Content Pipeline - Brief]] and S10-D9's mesh format as much as for the seam.
- **Whether to leave room for a visibility buffer** (Nanite) or to rule it out until R7.

## Sources

| Tag | Source | Read how |
|---|---|---|
| S1 | Chalmers research record and the HPG 2012 proceedings entry (DOI `10.2312/EGGH/HPG12/087-096`) for Olsson, Billeter and Assarsson, *Clustered Deferred and Forward Shading* | Search extract (abstract) |
| S2 | Chalmers record for Olsson, Billeter and Assarsson, *Tiled and Clustered Forward Shading: Supporting Transparency and MSAA*, SIGGRAPH 2012 talk | Search extract (abstract) |
| S3 | Haar and Aaltonen, [course slides](https://advances.realtimerendering.com/s2015/aaltonenhaar_siggraph2015_combined_final_footer_220dpi.pdf), SIGGRAPH 2015, and a secondary copy of the deck | Search extract (outline and diagrams) |
| S4 | Beyond3D forum, *GPU-driven rendering (SIGGRAPH 2015 follow up)*, a post by one of the talk's contributors | Search extract |
| S5 | DaveH355, `clustered-shading` OpenGL tutorial on GitHub, and mmzala's blog post on clustered shading | Search extract |
| S6 | Wihlidal, *Optimizing the Graphics Pipeline with Compute*, GDC 2016 slides on SlideShare | Search extract |
| S7 | GameDev.net thread *Per-triangle culling (GDC Frostbite)* | Search extract |
| S8 | *Advancements in Tiled Rendering* slides on SlideShare | Search extract |
| S9 | 80.lv and Digital Production articles on the Nanite talk (155 pages) | Search extract |
| S10 | Medium, *Nanite: Epic's Practical Implementation of Virtualized Geometry* | Search extract (secondary) |
| S11 | gcores.com article on Nanite's software rasterizer, and the CIS 565 *Vulcanite* project on GitHub | Search extract (secondary) |
| S12 | Schütz et al., *CuRast*, TU Wien 2026 | Search extract |
