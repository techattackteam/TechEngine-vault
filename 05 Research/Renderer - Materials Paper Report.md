---
tags: [research]
status: report
---

# Renderer: Materials Paper Report

The paper report for R1's second ADR, the materials and shading models
([[Renderer - Brief]], [[2026-10 Sprint 10 - Close E1]] § *Story E*). Card S10-P3, written
unattended on Nov 4, 2026. **It maps; it does not choose or recommend.** Every decision below is
Miguel's, in S10-D7's ADR.

[[Renderer - Research Brief]] § *Q3 mapped* compared how five engines split the material model.
This note takes the seven validated materials and shading papers in [[Research]] § *Rendering* and
maps them onto the [[Renderer - Brief]]'s standard material and its shading models. The seam
papers are in [[Renderer - Seam Paper Report]].

**How to read the sources, and this report's limit.** None of the seven papers could be opened:
`blog.selfshadow.com`, `seblagarde.wordpress.com`, `jcgt.org`, `cs.cornell.edu`,
`advances.realtimerendering.com` and two university mirrors all fail at the session's proxy. Two
**primary implementations** of these papers were reachable on GitHub and were read in full, and
most claims rest on them: Filament's *Physically Based Rendering in Filament* **[P1]**, which
cites six of the seven papers by name, and the glTF 2.0 specification's Appendix B and its
`KHR_materials_*` extensions **[P2]** to **[P6]**, which cite five. They report what the papers say
and how an engine used it; they are not the papers. A claim tagged **[S1]** to **[S3]** rests on a
search extract, **(memory)** on what I knew before this run, and **(inference)** on my own reading
of two facts together. **Check a formula in the paper before the ADR relies on it.**

## The seven papers

| Paper | What it is | Maps onto |
|---|---|---|
| [[Paper#Microfacet Models for Refraction through Rough Surfaces]], Walter et al., EGSR 2007 | The GGX normal distribution, and a microfacet BTDF for light refracted through rough surfaces. | The specular lobe; transmission |
| [[Paper#Physically Based Shading at Disney]], Burley, SIGGRAPH 2012 course | The principled BRDF: a metallic blend, roughness squared, a diffuse with retro-reflection. | The standard material's parameters |
| [[Paper#Real Shading in Unreal Engine 4]], Karis, SIGGRAPH 2013 course | A real-time cut of Burley's model, and the split-sum approximation for image lighting. | The sky image that lights and reflects |
| [[Paper#Moving Frostbite to Physically Based Rendering 3.0]], Lagarde and de Rousiers, SIGGRAPH 2014 course | What a production engine changed to go physically based: light units, reflectance, occlusion, camera. | Correct brightness; R2's lights |
| [[Paper#Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs]], Heitz, JCGT 2014 | Why the height-correlated Smith masking-shadowing term is the right one for GGX. | The specular lobe |
| [[Paper#Revisiting Physically Based Shading at Imageworks]], Kulla and Conty, SIGGRAPH 2017 course | Energy compensation for multiple scattering, and the "Charlie" sheen. | Rough metals; sheen |
| [[Paper#Authoring Materials That Matters: Substrate in Unreal Engine 5]], Hillaire and de Rousiers, SIGGRAPH 2023 | Fixed shading models replaced by slabs that operators layer and mix. | How far the material can grow |

## The specular lobe: Walter 2007 and Heitz 2014

| Topic | Finding | Source |
|---|---|---|
| GGX | Walter et al. named the distribution GGX; it is the Trowbridge-Reitz distribution of 1975, found again. It fits measured data better than Beckmann because of its longer tails. | [P1], [P2] |
| Its cost | One line of GLSL. Filament rewrites `1 - NoH²` as a cross product so it survives half precision. | [P1] |
| Masking and shadowing | Heitz shows the Smith function is the correct `G` for a GGX surface, and that correlating masking and shadowing by height is more accurate than multiplying two separate terms. | [P1], [P2] |
| Its cost | The height-correlated visibility term takes two square roots. Filament gives an approximation without them, "mathematically wrong" but good enough for mobile; Hammon 2017 gives the same one as a lerp. | [P1] |
| As the specs use it | glTF's Appendix B recommends the Smith profile after Heitz, and both Filament and glTF use `α = roughness²`. | [P1], [P2] |
| Not physically based | The Kelemen visibility term Filament uses for clear coat is cheaper, and Heitz's paper shows it is not physically based. | [P1] |
| Refraction | Walter's BTDF is what `KHR_materials_volume` uses for refraction at a rough volume boundary, with a half vector bent by Snell's law. | [P5] |

## The parameters: Burley 2012

| Topic | Finding | Source |
|---|---|---|
| The metallic blend | A material is a linear mix of a dielectric BRDF and a metal BRDF, weighted by `metallic`. glTF's core material is exactly this, and credits Burley. | [P2] |
| Roughness | `α = roughness²` makes roughness perceptually linear. Without it, shiny metals fit between 0 and 0.05. | [P1], [P2] |
| Diffuse | Burley's diffuse adds retro-reflection at grazing angles. Filament keeps Lambert, because the extra cost was not worth it and Burley's diffuse "is not energy conserving as expressed". glTF's core material uses Lambert too. | [P1], [P2] |
| Too many parameters | Filament calls Burley's set "impractical for real-time", and cuts it to base color, metallic, roughness, reflectance, emissive and ambient occlusion. | [P1] |
| Blending | Because every parameter interpolates, two materials blend by mixing their values under a mask (Burley, and Neubelt 2013 for *The Order: 1886*). | [P1] |
| Sheen and clear coat | The 2012 model has both as extra lobes; Filament's and glTF's versions come from other papers. | (memory) |

## The sky image and the units: Karis 2013 and Lagarde 2014

| Topic | Finding | Source |
|---|---|---|
| Split sum | Image lighting is split into a pre-filtered environment, one mip per roughness, and a 2D table of the BRDF's integral indexed by roughness and `NoV`. Most engines use it. | [P1], [S2] |
| Its limit | It assumes an isotropic lobe, so reflections do not stretch at grazing angles. | [S2] |
| Light falloff | Karis windows the inverse-square falloff so a light reaches zero at its radius. A clustered scheme needs that radius to bound each light (inference). | [P1] |
| Reflectance | Lagarde remaps a dielectric's reflectance so that 0.5 gives 4% (an IOR of 1.5), up to 16% for gemstones. | [P1] |
| Units | Frostbite's whole lighting pipeline is in photometric units: lux for the sun, lumens for local lights, cd/m² for the sky. Filament copies the table. | [P1], [S3] |
| Occlusion | Specular occlusion is derived from the diffuse occlusion term by an empirical formula, with no physical basis but a pleasant result. | [P1] |
| A camera | The course has a physically based camera, so exposure follows aperture, shutter and ISO. Its content was not read. | [S3] |
| Material parameters | Karis's parameter set is base color, metallic, roughness and a cavity term, with specular fixed at 0.5 for most materials. | (memory) |

## Energy and sheen: Kulla and Conty 2017

| Topic | Finding | Source |
|---|---|---|
| The loss | A single-scattering microfacet BRDF loses energy as roughness grows, so rough metals look too dark; a white furnace test shows it. | [P1] |
| The fix | Kulla and Conty add a compensating lobe built from the BRDF's precomputed directional albedo. | [P1], [P2] |
| Its real-time form | Lagarde and Golubev (2018) simplify it to a scaled GGX lobe whose scale comes from the same table as the split sum. Filament calls the cost negligible: one line of GLSL. | [P1] |
| Diffuse and specular | The talk also couples diffuse and specular so energy is conserved and preserved, from a 16³ table. glTF's own `fresnel_mix` is cheap and breaks energy conservation. | [P2] |
| Sheen | The "Charlie" sheen (Estevez and Kulla, in the same course) is the distribution `KHR_materials_sheen` specifies, layered over the base by albedo scaling from a table. | [P1], [P4] |
| Sheen's cost | Its shadowing term is costly; Filament and glTF allow the cheaper Ashikhmin term, which breaks energy conservation under albedo scaling. | [P1], [P4] |

## Where materials go: Substrate 2023

| Topic | Finding | Source |
|---|---|---|
| Idea | A material is a tree of slabs. Operators combine them: a vertical layer puts one slab over another, and a horizontal mix blends two across a surface. Several slabs can share one tangent basis to save memory. | [S1] |
| Haze | Two specular lobes mixed perceptually, after Barla et al., give a hazy look. | [S1] |
| What it replaces | Unreal's fixed shading models (Default Lit, Clear Coat and the rest). New projects get it by default. | [S1], [[Renderer - Research Brief]] § *Unreal* |
| The cost | A pixel holds a variable number of closures, so the G-buffer is no longer fixed. | (memory) |

## The brief's requirements mapped

| Requirement | What the papers offer | Caveat |
|---|---|---|
| The standard material, values and textures only | Burley's metallic blend with Karis's or Filament's cut parameter set; glTF's core material is the same model, so import carries it unchanged ([P2]). | Whether reflectance is a parameter (Filament, Lagarde) or fixed at 4% (glTF, Karis). `KHR_materials_ior` and `KHR_materials_specular` exist to change it ([P3]). |
| Live edits, no recompile | Every parameter is a value that interpolates (Burley), so an edit is a buffer write (inference). | A feature that adds a lobe (clear coat, sheen) can change the shader, as Godot's toggles do ([[Renderer - Research Brief]] § *Godot 4*). |
| Lit | GGX (Walter), height-correlated Smith (Heitz), Schlick Fresnel, Lambert diffuse: the set both Filament and glTF use ([P1], [P2]). | The exact visibility term or its approximation; energy compensation or none. |
| Unlit | glTF's `KHR_materials_unlit` extension, which none of the seven papers covers. | None from the papers. |
| Clear coat | A second GGX lobe over the base, with fixed IOR 1.5 ([P1], [P3]); the base's F0 is recomputed against the coat in Filament. | Filament uses Kelemen visibility for the coat, which Heitz shows is not physical. |
| Sheen | Charlie sheen (Kulla and Conty) with albedo scaling ([P4]). | Needs its own albedo table; the cheap visibility breaks energy conservation. |
| Transmission | glTF's is thin-walled: a GGX BTDF mixes into the base, with no refraction ([P6]). True refraction needs `KHR_materials_volume`, Walter's BTDF and a baked thickness map ([P5]). | glTF warns that transmitting only the sky "will often fall short" of what the author meant ([P6]); the scene behind needs a copy of the frame. |
| Cut-outs | glTF's `MASK` writes depth for kept pixels and needs no sorting ([P2]). | Alpha-to-coverage is allowed and changes the edges ([P2]); it interacts with the "smooth edges" Must (inference). |
| Glass (Should) | Filament draws transparency with premultiplied alpha ([P1]); glTF's `BLEND` leaves sorting to the renderer ([P2]). | Order-dependent; no paper here solves it. |
| A sky image that lights and reflects | Split sum (Karis) for the reflection, an irradiance map or spherical harmonics for the diffuse ([P1]). | The sky must be pre-filtered at load or when it changes. |
| Correct brightness | Photometric units end to end (Lagarde), and a camera whose exposure follows them ([P1], [S3]). | E2 has no auto-exposure; that is R2 ([[Roadmap]]). Fixed exposure is the alternative (inference). |
| Surface shaders that survive (alongside E11) | Filament's `material()` fills the inputs and the engine lights them ([[Renderer - Research Brief]] § *Q3*). Substrate shows the slab path. | Which contract is an ADR call; Substrate is a far larger system than E2 needs (inference). |

## What S10-D7 still has to decide

The report closes none of these; it lists where the papers raise them.

- **The specular terms:** the full height-correlated Smith term or its approximation, and whether
  energy compensation (Kulla and Conty, in Lagarde and Golubev's form) is in from the start. It
  shares the split sum's table, so it is cheap if the table exists.
- **The diffuse term:** Lambert, as Filament and glTF use, or Burley's.
- **Reflectance:** a parameter (Lagarde's remap) or a fixed 4% with glTF's IOR extension.
- **Where the extras live:** one lit model with clear coat, sheen and transmission as layers that
  are always present (Filament), as variants that change the shader, or as Substrate-style slabs.
- **Which tables ship:** the split sum's BRDF table, the sheen's albedo table, and the energy
  compensation that reuses the first.
- **Transmission:** thin-walled only, as glTF's core extension is, or volume refraction too.
- **Units and exposure:** photometric units now, and a fixed or a physical camera until R2.
- **Whether the lighting code is shared** with the surface contract that E11's shaders will fill.

## Sources

| Tag | Source | Read how |
|---|---|---|
| P1 | Filament, `docs_src/src_markdeep/Filament.md.html`, at `5ce4cbf` | Read in full; its references name Walter07, Burley12, Karis13b, Lagarde14, Heitz14, Kulla17, Estevez17 |
| P2 | glTF 2.0 `specification/2.0/Specification.adoc` § *Materials* and Appendix B, at `9d23a5a` | Read |
| P3 | `KHR_materials_clearcoat` and `KHR_materials_ior`, at `9d23a5a` | Read |
| P4 | `KHR_materials_sheen`, at `9d23a5a` | Read |
| P5 | `KHR_materials_volume`, at `9d23a5a` | Read |
| P6 | `KHR_materials_transmission`, at `9d23a5a` | Read |
| S1 | Search extracts of the SIGGRAPH 2023 Substrate slides, and secondary notes on Unreal 5.7's Substrate operators | Search extract |
| S2 | Search extracts of Karis's 2013 slides and of write-ups of the split sum | Search extract |
| S3 | Search extracts of Lagarde and de Rousiers's 2014 slides and the Self Shadow course page | Search extract |
