# Scene — Design

**Module:** core
**Kind:** system
**Status:** draft — S6-D1, 2026-09-12; reuse boundary and most mechanics agreed, D2 barriers remain open
**ADRs:** [[ADR-007 — v2 networking & ECS replication foundation]] · [[ADR-016 — Serialization (binary primitives & describe-once seam)]] · [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]]
**Sprint:** [[2026-09 Sprint 06 — Scene & Scheduling]]

## Purpose

Scene owns live entities, their built-in parent/child hierarchy and component values. It provides lookup and queries for
fixed-tick simulation, using v1's archetype storage and cached transitions as the starting
point. It must run headlessly without a renderer, editor, resource system or system locator.

This note is S6-D1's deliverable. No Scene/ECS implementation exists in the inspected v2
tree. The sections marked proposed describe the intended port, not shipped behavior or
newly accepted decisions. Scheduling and barrier placement belong to S6-D2.

## Evidence and freshness

Inspected v1 at `v1-reference` (`00e63207d24518b4e79a0d95ad2dd983e901aa13`) and v2 at
`7d2546fc1eccf13d2c9806664cd8d3f3419d5068`. All v1 code citations below refer to that tag,
not files in the current checkout. Read them with `git show v1-reference:<path>`.

The Dashboard reconciliation stamp is still `01ed7a30`; local `origin/master` contains
later commits. This was a targeted source inspection, not a full reconciliation or a
fresh remote fetch. No build, tests or runtime experiments ran.

## Decided

| Contract | Decision source |
|---|---|
| Runtime entities are value handles containing a u32 index and u32 generation. | ADR-007 §1 |
| Disk uses per-scene authoring IDs and remapping; UUIDs are opt-in for cross-document identity. Wire identity is a separate NetId. | ADR-007 §1 |
| Stable component identity is an author-declared tag hashed to 64-bit StringId; a process-local u16 dense ID serves masks and access sets. | ADR-007 §1 and its Aug 22 amendment; ADR-016 §5 |
| One ComponentRegistry is owned by the app composition root; registration bridges stable and dense IDs and checks collisions. | ADR-007 §1 |
| Retain archetypes, cached transition edges and vector-backed SoA columns behind IComponentStorage; iterate typed spans. | ADR-007 §2 |
| One registration seam describes identity, disk serialization and replication eligibility. Replicated components are restricted to trivially-copyable data without process-local pointers or handles. | ADR-007 §2; ADR-016 §1–2 |
| Declared system writes feed per-column change ticks. Structural changes are deferred during system execution. | ADR-007 §2 and §6; exact fixed-tick barriers await S6-D2 |
| Simulation performs fixed ticks; presentation consumes copied snapshots and never accesses live Scene storage. | ADR-019 §1–3, superseding ADR-007's variable/presentation pipeline |
| Serialization uses the existing Writer/Reader and ADL visit seam. Scene document layout belongs to its consumer. | ADR-016 §2 and §6; [[Serialization — Design]] |

## Confirmed requirements — Sep 12

Miguel confirmed that entity hierarchy is an out-of-the-box engine feature. It belongs
in the Scene design and port scope; projects must not have to implement their own scene
graph. The agreed hierarchy and transform contracts are recorded below; unresolved details
remain listed under Open questions and gates.

Each game/project can define custom components and custom systems without modifying engine
source. This follows ADR-007 §1–2 and §6: engine and project types share registration,
queries, access declarations and scheduling. Engine defaults are ordinary schedule entries
that projects can extend or replace. D2 settles the scheduling API, not whether this is supported.

## v1 reuse boundary — agreed Sep 12

Miguel approved this port/adapt/drop boundary, including built-in hierarchy and project
extensibility. Approval settles reuse scope; the proposed mechanics and open questions
below still need resolution before affected implementation cards are cut.

“Port” means retain the useful mechanism and adapt house style and identity. It does not
mean copy a whole file unchanged. “Drop” means exclude it from this first Scene slice.

| Area                                                      | Treatment                                     | Source and reason                                                                                                                                                                                  |
| --------------------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Typed vector columns and type-erased storage factory      | Port                                          | `engine/core/include/TechEngine/core/components/ComponentStorage.hpp:7` and `ArchetypesManager.hpp:38`. Values already live in contiguous typed storage.                                           |
| Parallel entity/column rows and swap removal              | Port with invariant checks                    | `engine/core/src/components/Archetype.cpp:36`. Every column must remove the same row, and the entity moved from the tail needs its location repaired.                                              |
| Cached add/remove edges and shared-column mappings        | Port                                          | `engine/core/src/components/ArchetypesManager.cpp:168`. Resolve shared storage once per transition, then reuse it.                                                                                 |
| Entity locations and allocation                           | Adapt                                         | `engine/core/include/TechEngine/core/components/Entity.hpp:5`; `engine/core/src/components/ArchetypesManager.cpp:217`. Replace integer counters and the entity hash map with generational slots.   |
| Component registration                                    | Adapt                                         | `engine/core/include/TechEngine/core/components/Archetype.hpp:15`; `engine/core/src/components/ArchetypesManager.cpp:6`. Drop the resettable family counter and per-manager built-in registration. |
| Archetype lookup                                          | Adapt                                         | `engine/core/src/components/ArchetypesManager.cpp:159`. It compares only the hash, so colliding signatures can select the wrong storage. Compare canonical signatures as well.                     |
| Serial query traversal                                    | Port the span loop; adapt matching and access | `engine/core/include/TechEngine/core/components/Query.hpp:76`. Resolve columns once per archetype, then walk equal row indices.                                                                    |
| Retained query matches                                    | Adapt                                         | `engine/core/include/TechEngine/core/components/ArchetypesManager.hpp:126`. Matches are captured only at query creation; new archetypes are missed and clear destroys their targets.               |
| Query-owned threads and mutex callback                    | Drop                                          | `engine/core/include/TechEngine/core/components/Query.hpp:90`. Work execution belongs to the executor/JobSystem; this also removes division by a possibly zero hardware-concurrency result.        |
| Scene's SystemsRegistry dependency and runSystem wrappers | Drop                                          | `engine/core/include/TechEngine/core/scene/Scene.hpp:20` and `:61`. Scene stores data; the schedule runs systems.                                                                                  |
| Built-in hierarchy and creation defaults | Adapt | `engine/core/src/scene/Scene.cpp:22`. Preserve engine-provided hierarchy. Every entity carries Hierarchy and Transform; UUID remains opt-in under ADR-007. |
| Parent/child operations and transform hierarchy | Adapt | `engine/core/src/scene/Scene.cpp:168`. Keep these engine features, replacing raw IDs and defining cycle prevention, destruction and transform behavior. |
| Recursive duplication | Design with reference remapping | `engine/core/src/scene/Scene.cpp:36`. Copying values alone cannot correctly clone references in arbitrary project components. |
| Hardcoded component serialization dispatch                | Drop                                          | `engine/core/src/resources/scene/SceneResource.cpp`, serialize/deserialize. It writes runtime entity/type IDs and branches on each built-in type. Use the accepted registration seam instead.      |
| Immediate structural event dispatch                       | Adapt under D2                                | `engine/core/include/TechEngine/core/scene/Scene.hpp:35`. v1 dispatches even when the manager reports a failed add/remove. Publish only successful committed changes.                              |

## Ownership and lifetime — agreed Sep 12

Keep v1's single live Scene object, with one scene loaded at a time. A project can contain
multiple scene files; loading another replaces the contents of that same Scene. Concurrent
live Scenes are outside this design and need a concrete use case before reconsideration.

The composition root owns the registry and supplies it to the Scene. Registry metadata
and any code backing its storage/serialization callbacks must outlive the Scene's component
storage. Scene destruction destroys columns before that metadata can disappear.

Scene owns its entity slots, archetypes, columns and transition caches. Keep v1's
`vector<unique_ptr<Archetype>>` ownership shape: growing the owner vector does not move
the archetypes. Each archetype owns its type-erased columns. Edges borrow storage objects,
never pointers into a component vector's current allocation.

Retain empty archetypes during ordinary execution so cached edge targets remain valid.
Clear/destruction discards all edges and query matches before reclaiming archetypes.
Archetype reclamation and game-DLL unload/hot reload are outside this first slice.

The simulation owns mutable access after startup. Setup and teardown occur with execution
stopped; no main-thread inspector or renderer borrows Scene. Future workers may access only
the data allowed by D2's execution contract. A mutex inside Query cannot enforce that.

## Local entity handles — agreed Sep 12

Each occupied slot stores generation and location `{archetype, row}`. Every public entity
operation validates index bounds, occupancy and generation before reading that location.
Destroy removes the row, repairs the swapped entity's location and invalidates the slot.
Reusing a slot preserves its advanced generation. Component transitions preserve the handle.

Clear must invalidate existing handles without resetting generations to their initial
values. Retain the slot table and advance occupied generations while
freeing rows. Retire a slot when its generation would wrap, rather than reviving an ancient
handle. The null entity uses index `UINT32_MAX` as a reserved sentinel; valid indices are
0 to max-1. Slot exhaustion reports via `TE_CHECK` and returns a null entity.

Handles refer to entities in the single live Scene. Replacing its loaded contents must
invalidate old handles, including editor selections and queued commands targeting the old
contents. Keep generation history across clear/load; restarting slot generations could make
an old handle resolve to an unrelated entity. No multi-Scene identifier is required here.

## Built-in hierarchy — agreed Sep 12

Retain v1's parent, first-child and sibling-link model as the starting point, using
validated local Entity handles. Scene provides root/child traversal, parenting, unparenting
and subtree operations. Projects use this engine API rather than maintaining links themselves.
Every entity carries a Hierarchy component. Every entity also carries a Transform component;
transformless entities are not supported.

Child order is a contract, not an implementation detail. The editor reorders children
by drag-and-drop; scripts may reorder them at runtime. The sibling-link model must
support insertion at a specific position among siblings.

Hierarchy mutations preserve reciprocal links and child counts. Reject self-parenting,
parenting beneath a descendant and stale handles from previously loaded contents before changing
links. v1 checks self-parenting but does not walk ancestors to reject longer cycles.
Structural commands must validate against the hierarchy at commit time, including earlier
commands in the same barrier. D2 supplies ordering and visibility.

Retain subtree destruction as v1's default, with explicit detach/reparent
operations when children should survive. Traversal
must not hold component references across operations that move archetype rows. Deep trees
must not depend on unbounded C++ recursion for destruction or transform propagation.

Keep hierarchy topology distinct from Transform data. Reparenting exposes preserve-local
and preserve-world intent explicitly. Transform propagation and editor editing follow the
contracts below.

Subtree duplication needs an old-to-new entity map. Internal references point to the cloned
entities; external references need an explicit preserve/clear policy. Custom components must
participate through registered reference handling, not a switch over engine component names.
The same requirement informs future serialization remapping, without fixing a file format now.

## Transform propagation — agreed Sep 12

One Transform component stores both local and world values: position (vec3), rotation
(quaternion, with euler conversion for display and editing) and scale (vec3). Local values
are the source of truth; an engine-provided Transform system computes world values via
parent-first propagation. Scale is never zero; the engine rejects or clamps zero scale.
Non-uniform parent scale combined with child rotation produces shear that does not
decompose exactly into position/rotation/scale. The stored world values are the best
approximation; the rendered result uses the full accumulated matrix and is correct.
Custom systems declare local writes and world reads through the same access mechanism
as built-in systems.

Run propagation during fixed simulation ticks, parent-first, after local-transform writers
and before consumers that require current world transforms. A changed parent affects its
descendants even when their local values did not change. The renderer never updates live
Scene hierarchy; snapshot extraction copies completed values for presentation.

Access conflicts alone do not establish semantic order. D2 must express writer → propagation
→ consumer dependencies and propagation after committed hierarchy changes. If a consumer
such as physics subsequently changes local transforms, another propagation point may be
needed before downstream world readers or snapshot extraction. D2 settles those execution
points; one unconditional pass at the end is not assumed sufficient.

## Editor Local / World editing — agreed Sep 12

The transform inspector offers Local and World modes. Local displays values relative to
the parent; World displays computed scene-space values. For root entities they coincide.
The inspector reads copied simulation state, never live component references.

Local edits request local-transform changes. World edits request a world-space target;
simulation converts it to local values using the current parent world transform when the
command is applied. The editor must not perform authoritative conversion using its older
snapshot. Propagation then recomputes world values from the updated local data.

Command application must obtain an up-to-date parent transform, accounting for earlier
accepted edits or hierarchy commands. D2 settles how that freshness is established and
orders the subsequent propagation. Reject stale entity handles after destruction or load.

World-position conversion requires an invertible parent transform. Zero scale is prevented
by the engine, so inversion is always valid. Non-uniform parent scale may produce approximate
world decomposition in the inspector; the rendered result remains correct. UI delivery
remains separate from the Scene storage port, while these data and command requirements
guide its design.

## Project extension contract

A project registers its component types through the same typed registration entry point as
engine built-ins. Storage factories, stable tags, serialization eligibility and replication
traits are supplied there. Scene, archetype transitions and queries remain generic: adding
`MyGame.Health` must not require changing a central enum, serializer switch or Scene class.

A project registers stateful systems into the app-composed Schedule. Each declares component
and resource reads/writes and any semantic ordering. Those declarations include custom types
and feed the same graph, debug access validation and change tracking as engine systems.
A custom system can query and update both built-in and project components through public APIs.

Hierarchy operations are available to custom systems through the same deferred structural
command contract. Internal hierarchy links must not be freely writable in a way that bypasses
Scene invariants; D2 must account for hierarchy access and transform propagation dependencies.

Registration closes before the first tick (startup-only). There is no runtime registration
and no engine DLL hot-reload. Editor script reload tears down Scene and registry, then
re-registers all types from scratch. Archetype signatures use sorted vectors of dense IDs.
Whatever module supplies callbacks must remain loaded until its systems, component values
and cached metadata have been destroyed. No plugin loader is implied by this contract.

## Registration and serialization seam — deferred to resource system

Each registered component supplies its stable tag, stable ID, local dense ID, storage
factory, disk eligibility and replication eligibility. Serializable types bind adapters
to the existing archives/visit mechanism; no separate list of built-in serializers is added.
Reject conflicting tags/type bindings and dense-ID exhaustion before publishing a record.

Dense IDs may differ with registration order; stable IDs must not. Archetype signatures
contain sorted, unique dense IDs. Lookup checks full signature equality even when hashes
match. The u16 ID space is not a decision to allocate a full 65,536-bit mask per archetype;
mask representation (sorted vectors, pinned above) and registry freeze (startup-only,
pinned above) are decided.

The current archives expose `writeSpan`/`readSpan` for trivially-copyable columns and
`field` with ADL `visit` for described values. A non-trivial column needs element visits;
`Writer::field(vector<T>&)` currently selects the bulk path and is not a generic visited
container serializer. Registration must respect this distinction.

Local Entity fields cannot be copied to disk just because Entity is trivially copyable.
The future Scene document adapter must translate references to authoring IDs and remap on
load. Wire references similarly require network identity. This is a schema gate: the
accepted raw-byte path does not itself supply reference remapping or portable struct layout.
No Scene file format, loader or network encoder is included in the first storage port.

## Storage and transitions — proposed mechanics

Port v1's storage and transition mechanics as-is. One entity row and one value in every
column at the same index; typed construction, relocation and destruction; the cached
add/remove transition sequence. Components must be default-constructible, copyable and
nothrow-movable. Swap-removal moves the tail row into the vacated slot; nothrow-move
prevents partial failures that would break the equal-row-count invariant. Move-only
or throwing components are not supported in this first port.

## Queries and invalidation — proposed mechanics

Keep query matching separate from iteration. A query describes required component types
and access modes; iteration obtains fresh typed spans for each matching archetype. Reads
return const values/spans, writes return mutable values/spans. Entity IDs are read-only.
The same access description must support D2's debug check of actual versus declared access.

Cache matching archetypes with a Scene archetype revision counter. New archetypes bump the
revision; queries refresh their match cache before the next iteration when stale. Adding
rows to an existing archetype does not require rematching, but spans must be reacquired
fresh each iteration. Clear invalidates all cached matches.

Structural mutation during iteration is prohibited. D2 chooses how systems enqueue it and
where it becomes visible. Serial execution does not relax this rule. Immediate mutation is
only a setup/stopped-execution operation or an internal barrier operation.

## Scheduling and presentation seams

Scene exposes data operations; it does not own worker threads or call sibling systems.
Each system runs on a single worker assigned by the task graph. A system iterates its
matched archetypes on that thread and does not spawn child jobs. `JobSystem::wait()` rejects
calls from pool workers, so nested parallelism is not available.

**Future expansion:** allow a system's worker to spawn sub-workers for its own iteration
and wait for them. This requires either a parallel-for helper called from outside the pool
or work-stealing inside `wait()`. Not in scope until profiling shows single-threaded
iteration is a bottleneck.

D2 defines the system access scope, structural command ordering, event visibility and
column write-stamping points. S6-D1 must not restore v1's `parallelEach` or ADR-007's
superseded variable-rate tail while that work is pending.

Completed simulation state is extracted into owned presentation values through the
existing publication lifecycle. Extraction may read Scene on its owner thread; the
published value must contain no borrowed columns, archetypes or component references.
See [[Game Loop — Frame Flow]] and ADR-019 for delivery and interpolation.

## Open questions and gates

| Decision                                     | Recommendation / next step                                                                                                                                                                          | Blocks                                                                                                 |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Structural/event barriers and change ticks   | Deferred to S6-D2. Includes transform propagation dependencies, current-parent conversion for world edits and the accepted fixed-only boundary.                                                     | Scheduling-bound cards and Scene integration.                                                          |

Story B is sized at five cards (S6-T1 through S6-T5): entity handles and registry,
archetype storage and transitions, queries, built-in hierarchy and transform propagation.
Each includes focused tests. Cards are cut on the sprint note.

## Verification required when implemented

- Destroy/reuse and clear reject old handles; transitions preserve live handles. Exercise
  generation exhaustion through a controlled test seam and reject handles from prior loads.
- Register types in different orders and compare stable identities. Check duplicate/conflict
  handling, dense-ID exhaustion and registry stability across replacement of Scene contents.
- Exercise canonical signatures and hash collisions. Create empty entities, add/remove
  components repeatedly and remove first, middle and last rows; verify every location/value.
- Prove parent/child traversal, reparenting, cycle rejection, subtree destruction and deep-tree
  handling. Exercise entity slot reuse and archetype moves while entities remain linked.
  Verify preserve-local and preserve-world reparenting results and child reordering.
- Prove parent-first propagation after local writes and committed hierarchy changes, including
  changes to a parent whose descendants' local values are unchanged. World readers and
  snapshot extraction must observe the required propagation point.
- Prove editor world edits convert using the current parent state despite an older displayed
  snapshot. Cover root equivalence, ordered parent/child edits and stale handles. Verify
  that zero scale is rejected and that non-uniform parent scale produces correct rendered
  results with approximate inspector decomposition.
- Use a project-owned component and system through only public engine APIs, without engine
  source edits. Exercise mixed built-in/custom queries, declared conflicts and custom hierarchy
  commands. Reference remapping for subtree duplication is deferred to the resource system.
- Count construction/destruction with a non-trivial component. Verify that registration
  rejects types that are not default-constructible, copyable or nothrow-movable.
- Query multiple archetypes with read/write access; create a new matching archetype, grow
  existing columns and clear the Scene. Prove fresh matches and prohibit structural mutation
  during iteration. Check the documented empty-query and Entity-only behavior once selected.
- Serialization round-trip testing is deferred to the resource system.
- With D2, prove deferred mutation visibility, declared-access checks and column change ticks
  in a repeated headless fixed-tick scenario. Snapshot publication must own its values.

## References

- [[Serialization — Design]] and current `engine/core/include/TechEngine/core/serialization/`
  (`Writer.hpp`, `Reader.hpp`, `Visit.hpp`) supply the existing archive seam.
- [[Task Graph — Execution Flow]] is D2's working document; its superseded phase pipeline
  must be reconciled before it can specify Scene execution.
- [[Simulation Thread — Design]] and [[Game Loop — Frame Flow]] describe the integration
  boundary; ADR-019 controls where older wording conflicts.
