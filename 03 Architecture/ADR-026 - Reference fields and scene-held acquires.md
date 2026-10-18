# ADR-026: Reference fields and scene-held acquires

- **Status:** Accepted
- **Date:** 2026-10 (Accepted 2026-10-19)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** S8-D1, the reference field shape that Sprint 09's mesh and reference cards build on.
- **Related:** [[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §2 §3 §4 §5 §7 §8 ·
  [[ADR-007 - v2 networking & ECS replication foundation]] §1 §2 ·
  [[ADR-016 - Serialization (binary primitives & describe-once seam)]] §2 · living *how*:
  [[Resources - Design]]

## Context

ADR-024 decided that a reference is a `ResourceId` on disk and a handle in memory (§2), that a
handle owns nothing and counts live per entry (§3), and that a scene loads everything it
hard-references (§4). It did not decide how a component **declares** such a field, who holds
the acquire behind it, or how the bake and a release find it. ADR-007 §1 left the same gap for
`Entity` fields: authoring ids on disk, remapped on load, with no field shape.

Checked at engine `39943f19`. No component can hold a reference yet, and that is enforced:
`Writer::field` stops with a `static_assert` on a type with no `write` overload and no `visit`
(`engine/core/include/TechEngine/core/serialization/Writer.hpp:77`), and neither `Entity` nor
`ResourceId` has one. The scene reader writes each block into the live entity while it is
still reading rows (`engine/core/src/scene/SceneAsset.cpp:105`, `:167-168`), so a reference to a
later row cannot be resolved inside that loop. `Scene` has no path to `ResourceCache`, which
`App` owns. The bake packs only the startup scene (`apps/editor/src/project/Project.cpp:175`).

**The baseline.** From [[2026-10-12 14-09 Auto Run]], S8-P4's brief; *memory* marks facts
it took from memory rather than from a source it read.

- **Unity:** a hard field is a pointer in memory and `{fileID, guid}` on disk *(memory)*.
  Nothing releases per field. `Resources.UnloadUnusedAssets()` scans for reachability, and a
  non-additive scene load runs it *(memory)*.
- **Unreal:** a `UPROPERTY` `TObjectPtr` is a pointer; reflection serializes it, the asset
  registry reads it for cooking, and the garbage collector walks it to keep it alive. Nothing
  calls release.
- **Godot:** `Ref<Resource>` counts per field, and the last reference dropping frees it.
- **All three** resolve entity references only after every object in the file exists.

## Decision

### 1. The loaded scene holds the acquires; a reference field owns nothing

Loading a scene acquires **each distinct id its components reference, once**, and the loaded
scene keeps those acquires. A reference field holds a non-owning handle, so copying a
component, queueing it in a command buffer or publishing it costs no count (ADR-024 §3).
Removing a component or destroying an entity releases nothing. The acquires go when the scene
changes or unloads, the new scene's first (ADR-024 §4).

### 2. Two field types

| Field | In memory | On disk | Resolved |
|---|---|---|---|
| `Entity` | The live handle (ADR-007 §1) | The target's authoring row, or a null row | After every row exists |
| `AssetRef<T>` | `{ResourceId, ResourceHandle<T>}`, trivially copyable | The id only; zero is an empty field | After the scene's loading phase |

An empty field is valid content and is skipped by every walk. A **replicated** component holds
a bare `ResourceId`, never an `AssetRef<T>`, so ADR-007 §2's bulk copy carries no handle and
ADR-024 §7 holds unchanged. N3 resolves that id on the receiving side.

### 3. One reference walk over `visit`

A further visitor over the same `visit` (ADR-016 §2) sees only reference fields and skips
everything else at compile time. Four jobs use it: the scene writer maps entities to rows, the
reader's second pass maps rows to entities and ids to handles, the scene load collects the ids
to acquire, and the bake collects what to pack. The scene header carries **no dependency
table**: the editor and the runtime both hold the registry, so the walk can find the ids.

### 4. Hard references stay inside what the scene holds

A live `AssetRef<T>` may name only an asset its scene already holds, because hard references
load only in a loading phase (ADR-024 §4). Pointing at anything else during a Tick is a soft
reference (ADR-024 §5, built with A1). The editor runs each edit as a loading phase: an
inspector change acquires the new asset at once, and the old one is released only when the
scene reloads (T1).

## Consequences

- **Benefit:** one count per asset per scene, with no per-copy bookkeeping. `Scene` stays
  independent of the cache, and save, load, bake and acquire share one description of each
  component, so a new reference field needs no new code in any of them.
- **Benefit:** release is deterministic at scene boundaries. Unity and Unreal reach the same
  point with a scan or a collector; counted entries make the scan unnecessary.
- **Cost:** an asset whose last user is removed mid-scene stays loaded until the scene changes,
  and an editor session holds every asset it swapped away from until a reload.
- **Cost:** the reader gains a second pass, and finding a scene's dependencies means decoding
  it. Both are linear in the scene's size.
- **Risk:** a project component whose `visit` skips a reference field is invisible to the
  walk: the asset never loads, and the bake leaves it out. The round-trip test per component
  type is what catches it.

## Alternatives considered

| Option | Why not |
|---|---|
| **A. Each field counts** (Godot's shape), released by a registry hook on remove, destroy and `clear` | Every copy site would have to acquire: `addComponent(value)`, queued commands, the reader's scratch copy, snapshots. One missed site is a leak or an early free, which is the bug class ADR-024 §3's non-owning handles exist to prevent. It also couples `Scene` to the cache. It frees sooner, and that is its one real advantage. |
| **Id-only fields**, resolved by an id lookup on each use | It needs no asset remap and is replication-safe by construction, but it amends ADR-024 §2, and R1's per-frame extraction pays a hash lookup for every resolve. The in-memory shape is easy to change later, since the disk holds only the id. |
| **A dependency table in the scene header** (Godot's `ext_resource`) | It makes a dependency query cheap without component code, but it is a format bump that duplicates what the payloads hold. Nothing needs that query yet. |
| **A reachability scan** (Unity, Unreal) | It contradicts ADR-024 §9: eviction is explicit release only. |

## What would move this

- **Measured memory** from assets held past their last user, in a long editor session or in a
  long-lived runtime scene. That points to option A, or a recount at a safe point.
- **A dependency query without component code**, for example the bake running before a game
  DLL loads. That adds the header table.
- **A resolve showing up in a profile** of R1's extraction, or a handle needing to cross the
  wire. That revisits the in-memory shape.
- **Prefabs or additive scenes** (two holders of one entity's references). §1 assumes one
  loaded scene owns each live component.
