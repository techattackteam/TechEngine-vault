# ADR-024: Resources (64-bit ids, value handles, async loads)

- **Status:** Accepted
- **Date:** 2026-10 (Accepted 2026-10-10)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** the Sprint 08 decide-first trial ([[Planning Workflow - Artifact Gate]] § *Trial
  from Sprint 08*). Gates M6 together with [[ADR-025 - Content packs (.tepack and the runtime load path)]].
- **Amended 2026-10-18, decision:** §1's "the generic per-type cache as the public API" →
  one `ResourceCache` that holds every type behind a type tag, with typed members
  (`request<T>`, `resolve<T>`, `ResourceHandle<T>`), not a cache per type. F7's fix was a
  generic typed API instead of per-type copies, and that is kept. A dependency arrives as an
  untyped id, and dependency acquires and the cycle check cross types, so one store is what can
  route them. S8-T10 (#141); confirmed by Miguel at the Oct 18 weekly review.
- **Partially supersedes:** each rowed in [[ADR Index]] § *Partial supersessions*.
  - ADR-006 §4, the **`ResourceRegistry& resources` field** of the `EngineContext` sketch, and
    §5's "injected via `EngineContext`" for this one service (§4 below). The DI rule, context
    immutability and the `app` composition root remain.
  - ADR-020 §1, the **barrier-operations list**: it gains a resource step (§5 below), taking
    effect with A1. The rest of §1 remains.
- **Related:** [[ADR-006 - v2 core architecture & module layout]] §1 §4 §5 · [[ADR-007 - v2 networking & ECS replication foundation]] §1 §2 §3 · [[ADR-016 - Serialization (binary primitives & describe-once seam)]] §4 §5 ·
  [[ADR-018 - Main and simulation threads, render-owned GL]] §1 §2 §4 · [[ADR-020 - System scheduling and task-graph execution]] §1 §2 §7 · [[ADR-022 - Project system composition and self-description]] ·
  [[ADR-023 - Public error handling]] §2 · living *how*: [[Resources - Design]]

## Context

M6 is the last chain rung, and the [[Roadmap]] left it without a gate. It needs one: R1, T4,
A1 and every component that references content are written against the identity, handle and
load model chosen here. ADR-006 §1 already puts CPU resources in `core` and GPU upload in `client`.

v1 (mapped at the `v1-reference` tag) got identity right and the API wrong. Each resource
file began with a random 64-bit id (`engine/core/include/TechEngine/core/resources/IResource.hpp:31-41`),
and cross-references stored ids. The API failed on F7, F13, F30 and F31, each cited in §1's
table. Loading was synchronous on main: a project with
Sponza and one more large scene took up to **10 minutes** to open, by Miguel's measurement.

At engine `82d7a11c` no resource code exists (`engine/core/include/TechEngine/core/EngineContext.hpp:8-12`).
This ADR decides the model and ADR-025 the packs, apart because their reversal costs differ:
packs are regenerable, while handles end up in every component.

## Decision

### 1. Port v1's identity; replace its API

**Port** ids, references by id and the generic per-type cache as the public API. **Drop**
names as keys, the per-type copy-paste, the cascades into the ECS and the silent defaults.
§2-§9 are the adaptations. "Port" keeps the mechanism and adapts house style; "drop" excludes
it. Every adapt row is forced by an audit finding or an accepted ADR. Paths are at `v1-reference`.

> **Amended 2026-10-18:** the generic API is ported as typed members of one `ResourceCache`,
> not as a cache per type (S8-T10). The `IResourceCache<T>` row below is historical.

| v1 piece                                                      | Treatment                                          | Source and reason                                                                                                                                                                                          |
| ------------------------------------------------------------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Id written first in each resource file                        | Port, adapted                                      | `engine/core/include/TechEngine/core/resources/IResource.hpp:31-41`. Survives renames. Adapt: ADR-016 header, zero is null, no generation on default construction (`engine/core/src/core/UUID.cpp:24-27`). |
| Cross-references stored as ids                                | Port                                               | `engine/core/include/TechEngine/core/components/Components.hpp:203-204`; material texture slots in `.../resources/material/MaterialResource.hpp:21-26`.                                                    |
| Generic `IResourceCache<T>`                                   | Port as the public API                             | `engine/core/src/resources/IResourceCache.hpp:12-134`. F7: it existed but only as private storage.                                                                                                         |
| Six per-type register/get blocks                              | Drop                                               | `engine/core/src/resources/ResourceSystem.hpp:37-128`. F7.                                                                                                                                                 |
| `shared_ptr` from every getter                                | Adapt to value handles                             | `ResourceSystem.hpp:44-125`. F13.                                                                                                                                                                          |
| Name as a second unique key per type                          | Drop; names become debug labels                    | `IResourceCache.hpp:18-19`. Two keys meant two ways to collide.                                                                                                                                            |
| Lookup by file stem                                           | Drop                                               | `runtime/editor/src/resources/loaders/SceneLoader.cpp:51`. A rename broke it.                                                                                                                              |
| Per-call `shared_mutex` in the cache                          | Adapt to an owner thread and fences                | `IResourceCache.hpp:17`. F31: compound operations still raced.                                                                                                                                             |
| Synchronous loads on the main thread                          | Adapt to async loads on the `JobSystem`            | A project with Sponza took up to 10 minutes to open, by Miguel's measurement.                                                                                                                              |
| Unregister cascades into the ECS                              | Drop                                               | `engine/core/src/resources/ResourceSystem.cpp:577-649`. Resources reached into `Scene`.                                                                                                                    |
| Silent fallback to "Cube" and "DefaultMaterial"               | Drop; return an error                              | `ResourceSystem.cpp:260-278`. A broken reference rendered as a cube.                                                                                                                                       |
| Loader interface without a load method; loaders in the editor | Adapt: per-type load functions in `core`           | `engine/core/src/resources/IResourceLoader.hpp:6-18`, `runtime/editor/src/resources/loaders/`. F30.                                                                                                        |
| CPU and GPU caches keyed by the same id                       | Port the split                                     | `engine/client/src/renderer/resources/GpuResourceManager.cpp`. ADR-006 §1 keeps it (F23).                                                                                                                  |
| Created/deleted events as the CPU-to-GPU sync                 | Drop                                               | `GpuResourceManager.cpp:224-227` dereferences the CPU resource unchecked after an unregister.                                                                                                              |
| Eager whole-project load in extension order                   | Adapt: the editor knows every asset at open through the id index (headers only) and loads data on demand; the extension order is dropped | `runtime/editor/src/project/ProjectManager.cpp:313-346`. Order stood in for dependencies, and loading everything made open time and memory grow with the project. |
| `ResourcePathIndex`, id to path from file headers             | Port as the editor's locator                       | `runtime/editor/src/fileSystem/ResourcePathIndex.cpp:9-53`. Fix: it read a scene's name length as its id.                                                                                                  |
| Raw `.te*` dumps with no magic, no version, padded tails      | Adapt to ADR-016                                   | `engine/core/src/serialization/BufferStream.cpp:9-19` grows to a power of two and writes the capacity.                                                                                                     |
| `SceneResource` holding name and path, no id                  | Adapt: a scene with an id                          | `engine/core/src/resources/scene/SceneResource.cpp:18-20`.                                                                                                                                                 |
| Startup scene by name, never updated                          | Adapt: an id in `project.toml` and the boot record | `runtime/editor/src/project/ProjectManager.cpp:364-372`.                                                                                                                                                   |
| `exportProject` as a recursive copy                           | Drop; bake to packs                                | `ProjectManager.cpp:90-162`. It shipped source art to a runtime that loaded nothing.                                                                                                                       |
| Shader manifests and hot-reload                               | Defer to R1 and file watching                      | `runtime/editor/src/resources/loaders/ShadersLoader.cpp:82-84`. Each reload minted a new id.                                                                                                               |
| Import beside the source; the mesh atlas pipeline             | Defer to T4                                        | `runtime/editor/src/resources/loaders/MeshLoader.cpp:833-1017`.                                                                                                                                            |

### 2. Identity: a 64-bit id; the path only locates

- A resource is identified by a random 64-bit `ResourceId`, generated once at creation and
  stored in its own header. Zero is null; default construction never generates one, which was
  v1's leak (`engine/core/src/core/UUID.cpp:24-27`).
- Every reference on disk is a `ResourceId`, remapped to a handle on load as ADR-007 §1 remaps
  authoring ids. The virtual path only locates, in the editor; the runtime never looks up a
  resource by path. This is not ADR-007's id space: a scene's entities keep authoring ids.
- A duplicate id is an error, never a silent pick. T4 decides how a PNG or FBX carries its id.

### 3. Value handles, counted per entry

- Callers hold a generational handle, `{u32 index, u32 generation}` per type: the `Entity`
  pattern (`engine/core/include/TechEngine/core/scene/Entity.hpp:10-22`). It owns nothing, and
  a stale handle fails to resolve instead of dangling.
- The cache counts **per entry**, not per handle copy, so copying costs nothing (the F13 fix).
  A request acquires and `release` gives back. An entry holds acquires on its dependencies.
- Memory is freed only in a loading phase or at the Tick barrier (§5), never inside `release`.

### 4. Hard references load in loading phases, from data

- A **hard reference** loads with whatever holds it. All references are held in **data**: a
  component field, and later a prefab. A system that needs content of its own reaches it
  through a **settings asset** the project references. Code never contains a content asset id.
  A system names its settings asset at startup registration and reads it after the startup
  loading phase has published it, before its first Tick.
- Hard references load only in a **loading phase** on the simulation thread, while nothing
  ticks and main and render keep running: after readiness and before the first Tick, and around
  a scene change. A scene change acquires the new scene's references before it releases the
  old scene's, so shared content is never reloaded.
- A request fills a handle and returns a `std::error_code` (ADR-023 §2). An entry is pending,
  then ready or failed; nothing substitutes a default. A failed startup load ends a runtime's
  run; the editor reports it and stays open.
- Reading and decoding run as `JobSystem` tasks that write only their own entry and never wait
  inside a worker; [[Resources - Design]] § *Handles, counts and the load lifecycle* holds the rules.
- The **owner is the simulation thread**, in the runtime and the editor alike: only it creates,
  publishes and frees entries, and the editor's UI sends it load commands. `App` owns the cache
  and hands it to the simulation side, **not** to `EngineContext`.
- **In the editor, a stopped or paused simulation does not tick**, as in Unity and Unreal. The
  simulation thread stays alive and idle, and runs each load command as a loading phase. So the
  cache lives for the whole process, and pressing Play reloads nothing.
- Loaders are per-type functions registered under a `StringId` tag (ADR-016 §5). Registration
  closes in `configureSimulation()`. Loaders parse only the runtime form.

### 5. Soft references load at any time, asynchronously

A **soft reference** stores an id but is not loaded with its holder. A system asks for it
during a Tick through a request list the executor owns beside each system's structural buffer,
so P1's workers never touch the cache. A **resource step** at the barrier, after structural
commands and NetId assignment, issues the Tick's requests, publishes finished loads and drains
frees; its order relative to the event step is A1's to fix. Pool tasks load while the game keeps
ticking, and the system sees the entry ready on a later Tick. Readiness depends on timing, so
replicated or predicted state must not branch on it (ADR-007 §3, ADR-020 §7). The bake packs
what soft references point to. This is built with the scripting lane (A1); M6 builds hard
references only. Soft loads are requested by gameplay; budgeted streaming stays absent.

### 6. Reads from other threads are published or fenced

Entry storage never relocates. Systems may resolve ready entries during a Tick on any thread,
because the owner mutates only at the barrier or in a loading phase; they never acquire or
release from `tick`. Any other thread reads only copies the owner published, or data pinned
behind a fence that a free must wait for; a reload's replacement counts as a free of the old data. R1 adds render's fence and T1 adds main's; M6 has no other reader. This holds
ADR-018 §2.

### 7. A reference can be absent by role

Every id belongs to one side: `common`, `client` or `server` (ADR-025 §4). Requesting an id
whose side this role never opens gives a handle to an entry in the **absent-for-role** state:
not an error, never loaded, never resolved. So a dedicated server can load a scene that names a
client mesh. A replicated component carries the `ResourceId`, never a handle (ADR-007 §2).

### 8. A scene is an entry, not a cached resource

- A scene has a `ResourceId` and is stored like any resource, but loading streams it into the
  one live `Scene`, and no parsed copy is cached. There is one in-memory scene type (§10).
- Its format is ADR-016 binary, with the same bytes in the editor and in a pack. **Each
  component block carries its stable tag and byte length.** A block with an unregistered tag
  passes through a save unchanged. A registered block whose length does not match is skipped
  and reported, and its data is lost on the next save.
- Scenes are source content, so ADR-016 §4's trigger ("the first content that can no longer
  be regenerated") fires with the first scene T1 saves and keeps. Per-type versions, and an
  upgrade hook for any type that needs one, land then.

### 9. Hot-reload and eviction wait, under one rule

A reload will replace the data behind a live handle in a loading phase, without a generation
bump, so no consumer keeps a pointer into resource data across a loading phase. Eviction is
explicit release only; streaming is on the [[Roadmap]]'s *Deliberately absent* list.

### 10. Vocabulary

An **asset** is content on disk: loose under a project's `assets/`, or packed. A **resource**
is an asset loaded in memory, behind a handle. The scheduling sense of "resource" in ADR-006
§5, ADR-007 §6, ADR-014 §4 and ADR-020 §2 becomes "shared singleton" by `vocabulary`
amendments. ADR-006's and ADR-007's "no separate serialized-scene asset" is read as "no second
in-memory scene type": the scene document on disk is an asset.

## Consequences

- **Benefit:** F7, F13, F30 and F31 close by construction. A large load never freezes main or
  render, and gameplay can load content mid-run without a hitch once soft references land.
- **Benefit:** renames cost nothing, broken references fail loudly, and hot-reload and R1's GPU
  mirror both fit behind the handle. The TSan leg exercises loads from the first card.
- **Cost:** every caller handles a pending state, and a soft load arrives Ticks after its
  request. Every acquire needs a release; the cache logs outstanding counts at shutdown.
- **Cost:** a scene change briefly holds both scenes' unique content in memory.
- **Cost:** nothing loads mid-run until A1, and soft loads then share the pool with P1. Until
  T1, a changed component loses its data in saved scenes. Ids are opaque in diffs.
- **Revisit when:**
  - A soft load measurably delays a Tick once P1 runs: task priorities or a dedicated I/O thread.
  - A thread needs resource data that neither a published copy nor a fence can serve.
  - Content from several projects is mixed (mods, asset packages): widen the id to 128 bits.
  - A consumer's ownership cannot be expressed as acquire/release pairs.

## Alternatives considered

| Option | For it | Why not |
|---|---|---|
| Virtual path as identity | Readable; [[File Access - Design]] already treats a path as an identity. | A rename rewrites every referrer. Godot moved from path references to `uid://` ids in 4.0 for this reason. |
| `shared_ptr` or a counting handle | Automatic lifetime. | F13's churn on every copy; ADR-006 §4 bans shared ownership between systems. |
| Scene-scoped groups, or never free | No counts. | Shared resources reload on every scene change, or release calls become a sweep later. |
| Synchronous loads until measured | Simplest first slice. | v1's 10-minute open is the measurement; an async shape added later is a sweep of every caller. |
| A dedicated loader thread | Keeps the pool free for P1's executor. | Decoding stays serial. It remains the fallback if soft loads delay ticks. |
| No loads while ticking, ever | No barrier step, no request path. | Spawning unreferenced content or changing level seamlessly would be impossible; Unity and Unreal both load asynchronously mid-run. |
| Asset ids in code, or a preload list | No settings asset to author. | An id in code bypasses the bake's walk; a hand-kept list goes stale. Unity reaches its shaders through settings assets too. |
| On `EngineContext` (ADR-006 §4's sketch) | Every system can reach it. | Only the owner may use it; any holder of the context could otherwise race a load. |
| Any thread reads, cache under a lock (v1) | No fences. | Compound reads still race, as v1's did, and reads contend with render. |
| Text scenes in the editor | Diffable and mergeable. | Needs a text archive and a scene bake step, and reverses ADR-005's custom-binary choice for scenes. |

> Add to [[ADR Index]]. Once Accepted, change it only per [[ADR Index]] § *Amending an
> Accepted ADR*: a dated header entry for what fits one, a superseding ADR for what needs its
> own argument.
