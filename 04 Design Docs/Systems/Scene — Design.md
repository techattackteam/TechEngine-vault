# Scene — Design

**Module:** core
**Kind:** system
**Status:** implementing — S6-T1–T8 merged by 2026-09-19; fixed-tick integration pending
**ADRs:** [[ADR-007 — v2 networking & ECS replication foundation]] · [[ADR-016 — Serialization (binary primitives & describe-once seam)]] · [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] · [[ADR-020 — System scheduling and task-graph execution]] · [[ADR-021 — Immediate Scene transform propagation]]
**Sprint:** [[2026-09 Sprint 06 — Scene & Scheduling]]

## Purpose

Scene owns live entities, their built-in parent/child hierarchy and component values. It provides lookup and queries for
fixed-tick simulation, using v1's archetype storage and cached transitions as the starting
point. It must run headlessly without a renderer, editor, resource system or system locator.

This note began as S6-D1's deliverable. S6-T1 shipped the entity-handle and component-
identity foundation; S6-T2 shipped typed columns, archetypes and cached transitions;
S6-T3 shipped query matching and iteration; S6-T4 added the built-in hierarchy;
S6-T5 added Transform and immediate propagation; S6-T6 added Schedule declarations.
S6-T7 added the immutable graph and S6-T8 added serial execution and the structural
barrier. Remaining proposed sections describe S6-T9 Scene integration work.

## Evidence and freshness

Inspected v1 at `v1-reference` (`00e63207d24518b4e79a0d95ad2dd983e901aa13`) and the
S6-T2 and S6-T3 merges at `4bcc71d0103abad323968394a69432679311059c` and
`150f8f0d50c4dd498cb0b6a3d0baeae83b9dd496`. All v1 code citations below refer to
that tag, not files in the current checkout. Read them with
`git show v1-reference:<path>`.

The Dashboard reconciliation stamp is still `01ed7a30`; `origin/master` contains later
commits. This note received targeted S6-T4/T5/T6/T7/T8 updates, not a full reconciliation.
PR #86 merged as `5a687af1`, PR #87 as `47bfaefc`, PR #89 as `9be7a8be`,
PR #90 as `ea5d0c9c` and PR #91 as `4da771af`.

## Decided

| Contract | Decision source |
|---|---|
| Runtime entities are value handles containing a u32 index and u32 generation. | ADR-007 §1 |
| Disk uses per-scene authoring IDs and remapping; UUIDs are opt-in for cross-document identity. Wire identity is a separate NetId. | ADR-007 §1 |
| Stable component identity is an author-declared tag hashed to 64-bit StringId; a process-local u16 dense ID serves masks and access sets. | ADR-007 §1 and its Aug 22 amendment; ADR-016 §5 |
| One ComponentRegistry is owned by the app composition root; registration bridges stable and dense IDs and checks collisions. | ADR-007 §1 |
| Retain archetypes, cached transition edges and vector-backed SoA columns behind IComponentStorage; iterate typed spans. | ADR-007 §2 |
| One registration seam describes identity, disk serialization and replication eligibility. Replicated components are restricted to trivially-copyable data without process-local pointers or handles. | ADR-007 §2; ADR-016 §1–2 |
| Declared system writes feed per-column change ticks. Structural changes are deferred during system execution and applied after Tick. | ADR-007 §2 and §6; ADR-020 §1 and §8 |
| S6-T6–T9 schedule conflicts from component access only. Shared-resource access waits for a concrete scheduled resource conflict. | ADR-020 §2, Sep 19 amendment |
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
that projects can extend or replace. ADR-020 settles the scheduling API.

## v1 reuse boundary — agreed Sep 12

Miguel approved this port/adapt/drop boundary, including built-in hierarchy and project
extensibility. Approval settled reuse scope; the later implementation cards were cut
in the Sprint 06 note. Open implementation gates remain below.

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
| Built-in hierarchy and creation defaults                  | Adapt                                         | `engine/core/src/scene/Scene.cpp:22`. Preserve engine-provided hierarchy. Every entity carries Hierarchy and Transform; UUID remains opt-in under ADR-007.                                         |
| Parent/child operations and transform hierarchy           | Adapt                                         | `engine/core/src/scene/Scene.cpp:168`. Keep these engine features, replacing raw IDs and defining cycle prevention, destruction and transform behavior.                                            |
| Recursive duplication                                     | Design with reference remapping               | `engine/core/src/scene/Scene.cpp:36`. Copying values alone cannot correctly clone references in arbitrary project components.                                                                      |
| Hardcoded component serialization dispatch                | Drop                                          | `engine/core/src/resources/scene/SceneResource.cpp`, serialize/deserialize. It writes runtime entity/type IDs and branches on each built-in type. Use the accepted registration seam instead.      |
| Immediate structural event dispatch                       | Adapt under ADR-020                           | `engine/core/include/TechEngine/core/scene/Scene.hpp:35`. v1 dispatches even when the manager reports a failed add/remove. Publish only successful committed changes.                              |

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

S6-T4 keeps `ArchetypeStorage` under core's private source tree. Scene owns it through
a pointer so the public Scene header does not include a private storage header.

Retain empty archetypes during ordinary execution so cached edge targets remain valid.
Clear/destruction discards all edges and query matches before reclaiming archetypes.
Archetype reclamation and game-DLL unload/hot reload are outside this first slice.

The simulation owns mutable access after startup. Setup and teardown occur with execution
stopped; no main-thread inspector or renderer borrows Scene. Future workers may access only
the data allowed by ADR-020's access contract. A mutex inside Query cannot enforce that.

## Local entity handles — agreed Sep 12

S6-T1 shipped the value handle and generation-preserving slot allocator. S6-T2 added slot
locations and repairs them after component transitions and swap removal. `ArchetypeStorage`
owns this machinery until the later Story B work supplies the Scene-facing integration.

Each occupied slot stores generation and location `{archetype, row}`. Every public entity
operation validates index bounds, occupancy and generation before reading that location.
Destroy removes the row, repairs the swapped entity's location and invalidates the slot.
Reusing a slot preserves its advanced generation. Component transitions preserve the handle.

Clear must invalidate existing handles without resetting generations to their initial
values. Retain the slot table and advance occupied generations while
freeing rows. Retire a slot when its generation would wrap, rather than reviving an ancient
handle. The null entity uses index `UINT32_MAX` as a reserved sentinel; valid indices are
0 to max-1. Slot exhaustion is a fatal `TE_CHECK`; under ADR-011's Sep 1 amendment it does
not return to produce a null handle.

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
commands in the same barrier. ADR-020 §1 supplies ordering and visibility; S6-T8 shipped
the command buffer and barrier in PR #91 (`4da771af`).

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

S6-T4 created entities in the `{Hierarchy}` archetype. S6-T5 added Transform to the
starting archetype. The storage constructor registers both built-ins until S6-T9
moves registration to the app composition root.

## Transform propagation — shipped Sep 18

One Transform stores local and world position, quaternion rotation and scale. Local TRS
is authoritative. `setLocal` validates and stores it, then Scene refreshes that entity
and all descendants before returning. `setWorld` converts the requested world TRS
against the current parent chain and takes the same path. Reject an unrepresentable
local shear without changing values. Zero scale is rejected; small nonzero scales remain valid.

Scene binds each default-constructed Transform to its Scene and Entity at creation.
Assigning values to a bound Transform retains the destination binding and refreshes its
subtree. Storage swap removal move-constructs the replacement row to carry its binding.
Scene's internal parent-first subtree traversal updates the exact accumulated world matrix
without invoking the public world-edit setter. The world TRS cache is approximate
under shear; rendering uses the exact matrix. Traversal is iterative, so deep trees
do not depend on C++ recursion. `propagateTransforms()` remains available for a
full cache rebuild, but normal setters and hierarchy changes are immediately visible.

The binding is runtime owner data, so Transform cannot use ADR-007's raw replicated
column path. Replication must extract portable local values or revisit this choice.
During Tick, systems writing Transform may also cause writes to descendant Transforms
and internal hierarchy reads. S6-T9 must account for that in access validation.
Committed hierarchy changes refresh the moved subtree at the barrier, ready for the
next Tick. Snapshot extraction reads completed values, never live Scene on render.

## Editor Local / World editing — agreed Sep 12

The transform inspector offers Local and World modes. Local displays values relative to
the parent; World displays computed scene-space values. For root entities they coincide.
The inspector reads copied simulation state, never live component references.

Local edits request local-transform changes. World edits request a world-space target;
simulation converts it to local values using the current parent world transform when the
command is applied. The editor must not perform authoritative conversion using its older
snapshot. The accepted setter refreshes world values before returning.

Command application uses the current parent chain, including earlier accepted edits or
hierarchy commands. S6-T8 establishes graph-order structural application; S6-T9 must
connect editor commands to that order and reject stale entity handles after destruction
or load.

World-position conversion requires an invertible parent transform. The engine rejects
zero local scale, and conversion also rejects a singular or non-finite parent matrix.
Non-uniform parent scale may produce approximate world decomposition in the inspector;
the rendered result remains correct. UI delivery remains separate from the Scene
storage port, while these data and command requirements guide its design.

## Project extension contract

A project registers its component types through the same typed registration entry point as
engine built-ins. Storage factories, stable tags, serialization eligibility and replication
traits are supplied there. Scene, archetype transitions and queries remain generic: adding
`MyGame.Health` must not require changing a central enum, serializer switch or Scene class.

A project registers stateful systems into the app-composed Schedule. Each declares component
reads/writes and any semantic ordering. Those declarations include custom component types
and feed the same graph, debug access validation and change tracking as engine systems.
Shared resources are outside S6-T6–T9 access masks; add them when a concrete scheduled
resource conflict needs graph ordering or debug validation.
A custom system can query and update both built-in and project components through public APIs.

The S6-T8 deferred command contract covers spawn, despawn, component add and component
remove. Custom-system hierarchy operations must join that structural path rather than
write internal links directly; their integration must preserve Scene invariants and
Transform propagation dependencies.

Registration closes before the first tick (startup-only). S6-T1 supplies the registry's
freeze mechanism; S6-T9 owns the composition-root call that closes registration before
execution. There is no runtime registration and no engine DLL hot-reload. Editor script
reload tears down Scene and registry, then re-registers all types from scratch. Archetype
signatures use sorted vectors of dense IDs.
Whatever module supplies callbacks must remain loaded until its systems, component values
and cached metadata have been destroyed. No plugin loader is implied by this contract.

## Registration and serialization seam — identity and storage factory shipped

S6-T1 shipped stable tag hashing, registration-order dense IDs, stable/dense lookup and
the startup freeze mechanism. S6-T2 added a type-erased storage factory to each registered
record. Duplicate tags, conflicting tags for one C++ type and dense-ID exhaustion fail
before publishing a record. Disk and replication traits remain resource-system work.

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

## Storage and transitions — shipped Sep 14

S6-T2 retained v1's vector-backed columns, parallel entity/value rows and cached add/remove
edges. `ArchetypeStorage` canonicalizes sorted, unique dense-ID signatures and compares the
full signature inside each hash bucket. Archetypes remain allocated during ordinary execution,
so cached archetype and column pointers survive owner-vector growth. Swap-removal moves the
tail entity and every column into the vacated row, then repairs the moved entity's slot.

The `ComponentValue` constraint requires default construction, copying and nothrow move
construction/assignment at compile time. Default construction and copying may still throw.
Review therefore changed transitions to build the destination row transactionally: a partial
append or shared-column copy removes the destination row before rethrowing, and the source
row is mutated only after destination preparation succeeds. Move-only or throwing-move
components remain unsupported in this first port.

## Queries and invalidation — shipped Sep 15

S6-T3 added `Query<Write<...>, Read<...>>`. Matching is separate from iteration: the
query caches archetype and column owners, then obtains fresh typed spans for each pass.
Callbacks receive Entity by value first, mutable references for writes and const references
for reads. Component queries require at least one access type and reject duplicates across
the read/write packs. Explicit `eachEntity` visits every live entity, including entities with
only built-in components, without inventing an empty component-access declaration.

`ArchetypeStorage` owns an archetype revision. New archetypes and clear bump it; retained
queries refresh matches when stale. Growing an existing archetype needs no rematch because
the spans are reacquired. Retained queries point to their storage owner, so storage is
non-copyable and non-movable and must outlive them.

Structural mutation is prohibited while any query or `eachEntity` callback is active.
Iteration depth is atomic so disjoint queries may run concurrently; the task graph remains
responsible for preventing conflicting component access. ADR-020 places queued structural
changes at the post-Tick barrier. S6-T8 shipped per-system command buffers whose owned
type-erased values survive until deterministic graph-order application. Immediate mutation
is only a setup, stopped-execution or internal barrier operation.

## Scheduling and presentation seams

Scene exposes data operations; it does not own worker threads or call sibling systems.
The S6-T8 serial executor invokes each system on one thread. A future parallel executor
may assign graph nodes to workers, but a system still does not spawn child jobs.
`JobSystem::wait()` rejects calls from pool workers, so nested parallelism is not available.

**Future expansion:** allow a system's worker to spawn sub-workers for its own iteration
and wait for them. This requires either a parallel-for helper called from outside the pool
or work-stealing inside `wait()`. Not in scope until profiling shows single-threaded
iteration is a bottleneck.

ADR-020 defines the component-access scope, structural command ordering, event visibility
and column write-stamping points. S6-T6–T8 ship Schedule, graph and serial execution.
`SerialExecutor` owns persistent system instances and one reusable command buffer per
graph node, while `TaskGraph` remains immutable. Scene validates actual accesses against
the active declaration, and the executor stamps every matching declared writable column
once before a system runs. Injected barrier services assign `NetId`s and flush event streams
without moving networking or event ownership into Scene. S6-T9 connects this path to fixed
ticks. The port does not restore v1's `parallelEach` or ADR-007's superseded variable-rate tail.

Completed simulation state is extracted into owned presentation values through the
existing publication lifecycle. Extraction may read Scene on its owner thread; the
published value must contain no borrowed columns, archetypes or component references.
See [[Game Loop — Frame Flow]] and ADR-019 for delivery and interpolation.

## Open implementation gates

- S6-T9 must register built-ins at the composition root and prove the integrated
  schedule headlessly.

S6-T8 shipped deferred structural commands, event flushing through barrier services and
declared-write stamps under ADR-020's Tick barrier. [[Events — Design]] still records the
unresolved retention anchor after the loop split.

Story B closed with five cards (S6-T1 through S6-T5): entity handles and registry,
archetype storage and transitions, queries, built-in hierarchy and transform propagation.
Each includes focused tests. The sprint note holds their acceptance criteria.

## Verification required when implemented

- Destroy/reuse and clear reject old handles; transitions preserve live handles. Exercise
  generation exhaustion through a controlled test seam and reject handles from prior loads.
- Register types in different orders and compare stable identities. Check duplicate/conflict
  handling, dense-ID exhaustion and registry stability across replacement of Scene contents.
- Exercise canonical signatures and hash collisions. Create entities with their required
  built-in components, add/remove optional components repeatedly and remove first, middle
  and last rows; verify every location/value.
  S6-T2 covers these cases plus transition reuse, mixed migrations and rollback after
  throwing default construction or shared-column copy in PR #84 (`4bcc71d0`).
- S6-T4 covers parent/child traversal, ordered reparenting, cycle rejection, detach/reparent
  survival, iterative deep-tree destruction, slot reuse and Scene clear in PR #86
  (`5a687af1`). Still verify archetype moves while linked during integration.
- S6-T5 covers immediate parent-first propagation after local/world writes and hierarchy
  changes, current-parent world edits, preserve-local/world reparenting, small nonzero scale
  boundaries and non-uniform scale in PR #87 (`47bfaefc`). System execution and snapshot
  extraction still need S6-T9 proof.
- Prove editor world edits convert using the current parent state despite an older displayed
  snapshot. Cover root equivalence, ordered parent/child edits and stale handles. Verify
  that zero scale is rejected and that non-uniform parent scale produces correct rendered
  results with approximate inspector decomposition.
- Use a project-owned component and system through only public engine APIs, without engine
  source edits. Exercise mixed built-in/custom queries, declared conflicts and custom hierarchy
  commands. Reference remapping for subtree duplication is deferred to the resource system.
- Count construction/destruction with a non-trivial component. S6-T2 covers balanced
  lifetimes and compile-time rejection of types that are not default-constructible,
  copyable or nothrow-movable.
- S6-T3 covers multi-archetype read/write access, new matching archetypes, existing-column
  growth, clear invalidation, structural-mutation rejection, callback unwinding and concurrent
  disjoint queries in PR #85 (`150f8f0d`). It also covers explicit `eachEntity`; empty
  component queries are rejected.
- Serialization round-trip testing is deferred to the resource system.
- S6-T8 proves deferred mutation visibility, declared-access checks, graph-order buffer
  application and column change ticks in executor tests. S6-T9 must prove the same path in
  a repeated headless fixed-tick scenario. Snapshot publication must own its values.

## References

- [[Serialization — Design]] and current `engine/core/include/TechEngine/core/serialization/`
  (`Writer.hpp`, `Reader.hpp`, `Visit.hpp`) supply the existing archive seam.
- [[Task Graph — Execution Flow]] is the accepted execution view for ADR-020; T6–T8
  shipped it through PRs #89–91.
- [[Simulation Thread — Design]] and [[Game Loop — Frame Flow]] describe the integration
  boundary; ADR-019 controls where older wording conflicts.
