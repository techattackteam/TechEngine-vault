# 2026-09 · Sprint 06 — Scene & Scheduling

- **Quarter:** [[2026-Q3]]
- **Dates:** Saturday Sep 12 – Friday Sep 25, 2026.
- **Epic:** M5 · Scene & scheduling ([[Roadmap]]).

## Sprint goal

Port the reusable v1 ECS into a Scene and run systems through a dependency graph
built from their declared access and ordering constraints, reused across fixed ticks.
Demonstrate the same scene behavior headlessly.

Miguel set the direction on Sep 12: reuse v1's sound ECS code, and let each system
declare its component use so the graph derives dependencies. Read/write declarations
cover components in S6-T6–T9; ADR-020's Sep 19 amendment defers shared-resource access
until a concrete scheduled resource conflict needs it. A component conflict requires
serialization; semantic order still needs an explicit rule. The task-graph ADR settles
the exact API and edge direction.

## Artifact gate

At sprint opening on Sep 12, the Scene and task-graph design gates were open. S6-D1
created [[Scene — Design]] and S6-D2 accepted ADR-020 that day. The remaining gates
are implementation and verification in Stories B, D and E.

| Area | Grounding | Current gate |
|---|---|---|
| Scene/ECS port | [[Scene — Design]]; ADR-007 §1–2; [[ADR-021 — Immediate Scene transform propagation]] | Design cleared by S6-D1. T1–T5 merged; Story B complete. |
| Systems, graph and executor | [[Task Graph — Execution Flow]]; ADR-020 | Design cleared by S6-D2. Schedule, graph and serial executor merged through T8; S6-T9 fixed-tick wiring merged in PR #92. Repeated headless state proof remains open. |
| Fixed simulation and presentation | [[Simulation Thread — Design]]; ADR-019 | Already implemented. Integration consumes these seams; presentation cannot borrow live Scene data. |

Implementation stories were roughly counted under the heavy gates at planning,
per [[Planning Workflow — Artifact Gate]]. Their card estimates include verification
and integration.

## Stories & tasks

### Story A — Ground the ECS port

- [x] **S6-D1** · Review the v1 ECS and draft [[Scene — Design]] · P1 · 🟢 Deep · 4–6h —
  done: read the relevant storage, archetype, transition, query and entity code at
  `v1-reference`; record file-backed port/adapt/drop decisions and a Decided index against
  ADR-007. Cover local handles, stable/dense component identity, registration's existing
  serialization seam, storage lifetime and query invalidation. Identify which mechanics
  can be ported directly and which need change. Agree the reuse boundary with Miguel,
  then cut session-sized Story B cards. If a new load-bearing choice emerges, give it an
  explicit decision gate before cutting affected cards. Scheduling-bound changes wait on D2.

### Story B — Port Scene identity, storage, queries and hierarchy · 5 tasks · sized Sep 12

Retain v1's archetype/transition model and useful implementation. Adapt identity and
ownership to the accepted v2 boundaries. This story supplies Scene and its storage
primitives.
Built-in hierarchy and transform are included per the accepted design; the D1 session
confirmed every entity carries both components.

- [x] **S6-T1** · Entity handles and ComponentRegistry · P1 · 🟠 Moderate · 3–5h —
  **done 2026-09-14 · `9fb6aeaf` · PR #82.**
  - Generational slot table: u32 index + u32 generation
  - Null sentinel at `UINT32_MAX`; exhaustion is a fatal `TE_CHECK`
  - Slot reuse with advanced generation, retirement on wrap
  - ComponentRegistry: stable tag to StringId, dense u16 ID, collision rejection
  - Registration closes before first tick (startup-only freeze)
  - Tests: create/destroy/reuse handles, generation advancement, null checks, duplicate tag rejection, dense-ID exhaustion
  - Close note: slot exhaustion is fatal and cannot return null under ADR-011. The freeze
    mechanism landed here; composition-root ownership and the pre-first-tick call remain S6-T9.

- [x] **S6-T2** · Archetype storage and transitions · P1 · 🟢 Deep · 4–6h (depends on T1) —
  **done 2026-09-14 · `4bcc71d0` · PR #84.**
  - Typed vector columns behind `IComponentStorage`, type-erased factory
  - Archetype with parallel entity/column rows, swap removal
  - Sorted-vector signatures with full equality check (not hash-only)
  - Cached add/remove transition edges with shared-column mappings
  - Enforce default-constructible + copyable + nothrow-movable at registration
  - Tests: add/remove components, swap removal repairs locations, signature collisions, row-count invariant across transitions
  - Close note: review added transactional rollback for throwing default construction and
    shared-column copies before the source row is changed. Dedicated archetype tests also
    verify canonical reuse and entity/column alignment across mixed transitions.

- [x] **S6-T3** · Queries and iteration · P1 · 🟠 Moderate · 3–4h (depends on T2) —
  **done 2026-09-15 · `150f8f0d` · PR #85.**
  - Query describes required component types and read/write access modes
  - Revision-based match caching: refresh on new archetypes, fresh spans each iteration
  - Const spans for reads, mutable spans for writes, read-only entity IDs
  - Structural mutation during iteration is prohibited
  - Tests: multi-archetype matching, stale revision refresh, grow existing archetype, clear invalidation, mutation-during-iteration rejection
  - Close note: Entity-only traversal uses explicit `eachEntity`; component queries reject
    empty access packs. Storage is non-movable while retained queries point into it, and
    atomic iteration depth supports concurrent disjoint queries while the task graph owns
    conflict prevention.

- [x] **S6-T4** · Built-in hierarchy · P1 · 🟢 Deep · 3–4h (depends on T1 + T2) —
  **done 2026-09-17 · `5a687af1` · PR #86.**
  - Hierarchy component on every entity: parent, first-child, sibling links
  - Parenting, unparenting, child reordering with insertion at position
  - Cycle rejection via ancestor walk (not just self-parent check)
  - Subtree destruction default, explicit detach/reparent for survivors
  - Deep trees must not use unbounded C++ recursion
  - Tests: traversal, cycle rejection, deep-tree destruction, reordering, entity slot reuse while linked
  - Close note: creation starts in the required Hierarchy archetype. Registration in
    `ArchetypeStorage` is temporary until S6-T9 moves built-ins to the app composition root.

- [x] **S6-T5** · Transform component and propagation · P1 · 🟢 Deep · 3–4h (depends on T4) —
  **done 2026-09-18 · `47bfaefc` · PR #87.**
  - Transform component: local + world position (vec3), rotation (quat with euler conversion), scale (vec3)
  - Scene propagates parent-first immediately after accepted Transform writes and hierarchy changes ([[ADR-021 — Immediate Scene transform propagation]])
  - Zero scale rejected by the engine
  - Non-uniform parent scale: approximate world decomposition, correct rendered matrix
  - Preserve-local and preserve-world reparenting
  - Tests: propagation after local writes, propagation after hierarchy changes, zero-scale rejection, preserve-local/world results, non-uniform scale decomposition
  - Close note: review caught late rejection of small nonzero preserve-world scales and
    owner-binding loss on Transform assignment; both were fixed and covered before merge.

### Story C — Settle system dependencies and execution

- [x] **S6-D2** · Task-graph/System ADR and execution design · P1 · 🟢 Deep · 4–6h — **done 2026-09-12.**
  done: Miguel accepts the task-graph contract; update the existing execution note and
  ADR Index with its relationship to ADR-007 and ADR-019. The accepted scope originally
  covered component and resource read/write declarations; ADR-020's Sep 19 amendment
  narrows S6-T6–T9 to components and defers shared resources. Settle explicit order,
  deterministic conflict direction,
  cycle diagnostics, legal schedule mutations/rebuilds, debug access validation, node
  granularity, and structural/event barriers. Keep fixed simulation separate from snapshot
  presentation. Address the future fixed-only script terminal slot without implementing
  scripting. Include a worked graph example and cut Stories D/E into 2–6h cards. Use D1's
  registry and query findings; the serial executor must preserve the future worker seam.

### Story D — Schedule, graph and serial execution · 3 tasks · sized Sep 12

System declarations feed a graph built once at simulation start. Fixed ticks reuse it.
The schedule is immutable after build (ADR-020 §7). Structural commands queue into the
barrier. The serial executor walks levels one system at a time (ADR-020 §8).

- [x] **S6-T6** · Schedule and access declarations · P1 · 🟠 Moderate · 3–4h —
  **done 2026-09-19 · `9be7a8be` · PR #89.**
  - Schedule holds entries: system factory, priority (int, default 0), component-access bitmask
  - `DeclareAccess<Write<T...>, Read<T...>>` lowered to component dense-ID bitmasks at registration
  - `.priority(N)`, `.before<A>()`, `.after<A>()` on entries
  - `Slot::Terminal` flag for the script runner slot (ADR-020 §4)
  - Registration closes before first tick (same freeze as ComponentRegistry, S6-T1)
  - Tests: register entries, priority assignment, before/after edges, terminal slot flag, double-registration rejection, post-freeze rejection
  - Close note: the Sep 19 ADR-020 amendment narrowed this slice to component access
    and deferred shared resources. Review promoted registration invariants from dev-only
    `TE_ASSERT` to always-on `TE_CHECK` and ungated their rejection tests. T7 is unblocked.

- [x] **S6-T7** · Graph builder · P1 · 🟢 Deep · 4–6h (depends on T6) —
  **done 2026-09-19 · `ea5d0c9c` · PR #90.**
  - Conflict detection: `A.writes ∩ B.touches ≠ ∅` produces an edge
  - Priority-based direction: lower priority runs first
  - Equal priority on a conflicting pair is a build error
  - Explicit `.before<>()`/`.after<>()` edges override priority between that pair
  - Terminal slot pinned after all regular levels
  - Topological sort into levels. Cycle detection with `TE_CHECK` naming every system
  - Log every conflict-derived edge at build time
  - Tests: conflict detection, priority ordering, explicit override, cycle rejection with named systems, terminal slot placement, disjoint readers on same level, equal-priority error
  - Close note: no scheduling decision changed. Review tightened exact directional-log
    assertions and added conflict coverage across the 64-bit access-mask boundary. T8 is unblocked.

- [x] **S6-T8** · Serial executor and barrier · P1 · 🟢 Deep · 4–6h (depends on T7 + T2) —
  **done 2026-09-19 · `4da771af` · PR #91.**
  - Walk levels in order, run one system at a time
  - Command buffer: queue spawn/despawn/add/remove during tick
  - Barrier after tick: apply commands in deterministic order, validate hierarchy (S6-T4), assign NetIds, flush event streams
  - Structural changes invisible until barrier
  - Debug validation: actual access is a subset of declared (`TE_ASSERT`)
  - Coarse write-stamping: `changeTick` per system/archetype/component (ADR-007 §2)
  - Tests: systems run in level order, command buffer deferred until barrier, undeclared access fires assert, write-stamp advances on declared writes only
  - Close note: persistent system instances and per-system command buffers live in the
    executor, leaving the cached graph immutable. Buffers merge in graph order at one
    post-Tick barrier; pending-entity tokens are local to the buffer that produced them.
    Queued type-erased component values own their payloads, and declared writable columns
    are stamped once per system before execution. Story D is complete and S6-T9 is unblocked.

### Story E — Scene integration and headless proof · 1 task · sized Sep 12

Connect the scene and executor to the shipped simulation lifecycle and demonstrate a
small dependency chain. Hierarchy and transform are in Story B (S6-T4/T5). Input
action mapping remains M5 follow-through. Delivery may roll into Sprint 07.

- [x] **S6-T9** · Wire executor into the simulation tick · P1 · 🟠 Moderate · 3–4h (depends on T8) —
  **done 2026-09-22 · `2a50f8cb` · PR #92.**
  - Register built-in components in the app composition root and remove their temporary
    registration from `ArchetypeStorage`
  - Freeze ComponentRegistry and Schedule after startup registration and before the first tick
  - Build the graph once at simulation start from registered systems
  - Each fixed tick: executor walks levels, then runs barrier
  - Register Movement, Gravity and Collision as test systems with real access; Transform setters propagate immediately under ADR-021
  - Prove the graph orders them under ADR-020's conflict and priority rules, without a separate propagation node ([[ADR-021 — Immediate Scene transform propagation]])
  - Run headlessly: same scene, same graph, no window, deterministic output
  - Tests: multi-tick run produces expected transform state, headless matches windowed, graph reuse across ticks (no rebuild)
  - Close note: App now finalizes the registry, graph and executor before fixed ticks;
    RuntimeApp registers the demo chain. Its test checks one entity after one tick,
    without expected component state, graph-reuse evidence or headless/windowed parity.
    Miguel kept this runtime as a demo and deferred Scene rendering. The remaining
    proof is in [[Backlog]], so Story E's headless-proof goal remains open. PR #92's
    final CI checks passed; `[skip-coverage]` bypassed changed-line coverage.

S6-P1 returned to [[Backlog]] on Sep 19 when the mid-sprint S6-B1 defect displaced the
lowest-priority Process card.

### Story G — Protect the Linux TSan signal

- [ ] **S6-B1** · Investigate intermittent llvmpipe synchronization teardown race · P1 · 🟠 Moderate · 2–4h —
  [PR #91 run 35463582634](https://github.com/techattackteam/TechEngine/actions/runs/35463582634/job/105952186879?pr=91)
  passed the pacing test's six assertions, then TSan reported two races during
  `RenderThread`'s `window.swapBuffers()` call: `pthread_mutex_destroy` against an
  llvmpipe worker lock and `pthread_cond_destroy` against another llvmpipe worker read.
  PR #91 changes only `engine/core`; it does not touch the client/render/window paths.
  Miguel reports this is the second occurrence.
  - Reproduce with repeated focused `linux-tsan` runs and record the failure frequency
  - Determine whether engine context/thread lifetime, Mesa/llvmpipe, or sanitizer instrumentation owns the race
  - Use `LP_NUM_THREADS=0` only as a diagnostic comparison; do not accept it as the root-cause fix
  - If engine-owned, fix it and add focused regression coverage; if dependency-owned,
    record upstream evidence and use only a narrow workaround that preserves engine-race detection
  - Finish with a green focused stress run and full Linux TSan suite, or split a concretely
    scoped resolution card if the investigation proves larger than this session

## Definition of Done

- [x] Scene reuse is grounded in inspected v1 code and an agreed design note. — S6-D1;
  first implementation merged 2026-09-14 as `9fb6aeaf`, PR #82.
- [x] The task-graph ADR is Accepted and its design hub reflects fixed-only simulation. — ADR-020 Accepted Sep 12.
- [ ] A small scene runs through the declared dependency graph on the simulation thread
  and produces the expected state headlessly over repeated ticks. PR #92 (`2a50f8cb`)
  wires the executor, but its runtime test covers only one tick and entity count.
- [ ] Tests prove handle invalidation, storage/query behavior, graph conflicts and semantic
  ordering, cycle rejection, graph reuse/rebuild boundaries and deferred structural changes.
  Handle invalidation and hierarchy cycle rejection landed through S6-T4, PR #86
  (`5a687af1`); graph conflicts, semantic ordering and graph-cycle rejection landed through
  S6-T7, PR #90 (`ea5d0c9c`). Deferred structural changes and repeated executor use landed
  through S6-T8, PR #91 (`4da771af`); PR #92 (`2a50f8cb`) added fixed-tick wiring,
  while repeated headless state and graph-reuse proof remains in [[Backlog]].
- [x] Required implementation PRs are merged with recorded validation, and touched design
  notes describe the shipped behavior. Presentation does not access the live Scene. —
  PR #92 (`2a50f8cb`) merged 2026-09-22 with green CI; its `[skip-coverage]` marker
  bypassed the changed-line coverage gate.

## Capacity note

Miguel reports good energy on Sep 12 and wants to continue the current pace. No specific
unavailable dates were supplied. Use the usual two-week rhythm: four weekday deep slots
plus two weekend deep days at 2–3 slots each = **8–10 Deep**, plus **2 Moderate** and
**2 Light** slots. The boundary ceremony shares the first weekend's time; it is not extra
capacity. Weekend work days remain swappable and at least one rest day is the default.

Story B is 5 Dev cards (S6-T1 through S6-T5, 16–23h). Story D is 3 Dev cards (S6-T6
through S6-T8, 11–16h). Story E is 1 Dev card (S6-T9, 3–4h). With 2 Design, 1 Bug and
1 Process that is **13 cut cards, ~15–21 substantive sessions**. The upper end will
roll into Sprint 07. Check the actual mix at the Sep 19–20 review. Cut S6-P1 first
if attended time tightens, then carry unfinished scope explicitly. S6-B1 arrived on
Sep 19 and took that cut: S6-P1 returned to the backlog rather than adding work on top.

Current card mix is 9 Dev (5 Deep + 4 Moderate) / 2 Design / 1 Bug / 1 Process.
One Process card is Auto.
The Auto pass selected only S6-P2: no decisions, file-verifiable, off the critical path,
and no workflow edits. It costs no code PR or CI minutes. No automation was changed.

No unfinished Sprint 05 card carries. Known Issue D3 has no identified consumer in this
slice; D4 must be rechecked if integration introduces a real Role-formatting caller.
No running defect was known at planning; S6-B1 was established from the repeated Sep 19
Linux TSan failure. Error-handling policy,
branch-link tooling and workflow-policy decisions remain parked, despite fired triggers;
they are not prerequisites inferred for this sprint. RNG/crash handling remain deferred
roadmap items, not untracked carry cards. Parallel execution stays P1; content stays M6.

## Sprint review (end)

Pending Sep 26–27 boundary review. Mid-sprint review: Sep 19–20.
