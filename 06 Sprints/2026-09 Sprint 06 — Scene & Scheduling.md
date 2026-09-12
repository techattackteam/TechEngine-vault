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
also cover shared resources. A conflict requires serialization; semantic order still
needs an explicit rule. The task-graph ADR settles the exact API and edge direction.

## Artifact gate

| Area | Grounding | Gate |
|---|---|---|
| Scene/ECS port | [[Lessons from v1 (reference prototype)]]; ADR-007 §1–2 | No Scene/ECS design note exists. S6-D1 reviews v1 and creates the hub before port cards are cut. |
| Systems, graph and executor | [[Task Graph — Execution Flow]] | Draft exists but retains the superseded variable-phase pipeline. S6-D2 settles the task-graph ADR and reconciles it with ADR-019. |
| Fixed simulation and presentation | [[Simulation Thread — Design]]; ADR-019 | Already implemented. Integration consumes these seams; presentation cannot borrow live Scene data. |

Implementation stories remain roughly counted under the heavy gates, per
[[Planning Workflow — Artifact Gate]]. Their counts include verification and integration;
they are not promises that the unresolved design already fits a particular API.

## Stories & tasks

### Story A — Ground the ECS port

- [x] **S6-D1** · Review the v1 ECS and draft Scene — Design · P1 · 🟢 Deep · 4–6h —
  done: read the relevant storage, archetype, transition, query and entity code at
  `v1-reference`; record file-backed port/adapt/drop decisions and a Decided index against
  ADR-007. Cover local handles, stable/dense component identity, registration's existing
  serialization seam, storage lifetime and query invalidation. Identify which mechanics
  can be ported directly and which need change. Agree the reuse boundary with Miguel,
  then cut session-sized Story B cards. If a new load-bearing choice emerges, give it an
  explicit decision gate before cutting affected cards. Scheduling-bound changes wait on D2.

### Story B — Port Scene identity, storage, queries and hierarchy · 5 tasks · sized Sep 12

Retain v1's archetype/transition model and useful implementation. Adapt identity and
ownership to the accepted v2 boundaries. The source tree currently has no Scene/ECS
implementation. This story supplies the first consumer for its storage primitives.
Built-in hierarchy and transform are included per the accepted design; the D1 session
confirmed every entity carries both components.

- [ ] **S6-T1** · Entity handles and ComponentRegistry · P1 · 🟠 Moderate · 3–5h
  - Generational slot table: u32 index + u32 generation
  - Null sentinel at `UINT32_MAX`, exhaustion via `TE_CHECK` + null return
  - Slot reuse with advanced generation, retirement on wrap
  - ComponentRegistry: stable tag to StringId, dense u16 ID, collision rejection
  - Registration closes before first tick (startup-only freeze)
  - Tests: create/destroy/reuse handles, generation advancement, null checks, duplicate tag rejection, dense-ID exhaustion

- [ ] **S6-T2** · Archetype storage and transitions · P1 · 🟢 Deep · 4–6h (depends on T1)
  - Typed vector columns behind `IComponentStorage`, type-erased factory
  - Archetype with parallel entity/column rows, swap removal
  - Sorted-vector signatures with full equality check (not hash-only)
  - Cached add/remove transition edges with shared-column mappings
  - Enforce default-constructible + copyable + nothrow-movable at registration
  - Tests: add/remove components, swap removal repairs locations, signature collisions, row-count invariant across transitions

- [ ] **S6-T3** · Queries and iteration · P1 · 🟠 Moderate · 3–4h (depends on T2)
  - Query describes required component types and read/write access modes
  - Revision-based match caching: refresh on new archetypes, fresh spans each iteration
  - Const spans for reads, mutable spans for writes, read-only entity IDs
  - Structural mutation during iteration is prohibited
  - Tests: multi-archetype matching, stale revision refresh, grow existing archetype, clear invalidation, mutation-during-iteration rejection

- [ ] **S6-T4** · Built-in hierarchy · P1 · 🟢 Deep · 3–4h (depends on T1 + T2)
  - Hierarchy component on every entity: parent, first-child, sibling links
  - Parenting, unparenting, child reordering with insertion at position
  - Cycle rejection via ancestor walk (not just self-parent check)
  - Subtree destruction default, explicit detach/reparent for survivors
  - Deep trees must not use unbounded C++ recursion
  - Tests: traversal, cycle rejection, deep-tree destruction, reordering, entity slot reuse while linked

- [ ] **S6-T5** · Transform component and propagation · P1 · 🟢 Deep · 3–4h (depends on T4)
  - Transform component: local + world position (vec3), rotation (quat with euler conversion), scale (vec3)
  - Parent-first propagation system computes world values from local
  - Zero scale rejected by the engine
  - Non-uniform parent scale: approximate world decomposition, correct rendered matrix
  - Preserve-local and preserve-world reparenting
  - Tests: propagation after local writes, propagation after hierarchy changes, zero-scale rejection, preserve-local/world results, non-uniform scale decomposition

### Story C — Settle system dependencies and execution

- [x] **S6-D2** · Task-graph/System ADR and execution design · P1 · 🟢 Deep · 4–6h — **done 2026-09-12.**
  done: Miguel accepts the task-graph contract; update the existing execution note and
  ADR Index with its relationship to ADR-007 and ADR-019. Settle system-owned component
  and resource read/write declarations, explicit order, deterministic conflict direction,
  cycle diagnostics, legal schedule mutations/rebuilds, debug access validation, node
  granularity, and structural/event barriers. Keep fixed simulation separate from snapshot
  presentation. Address the future fixed-only script terminal slot without implementing
  scripting. Include a worked graph example and cut Stories D/E into 2–6h cards. Use D1's
  registry and query findings; the serial executor must preserve the future worker seam.

### Story D — Schedule, graph and serial execution · 3 tasks · sized Sep 12

System declarations feed a graph built once at simulation start. Fixed ticks reuse it.
The schedule is immutable after build (ADR-020 §7). Structural commands queue into the
barrier. The serial executor walks levels one system at a time (ADR-020 §8).

- [ ] **S6-T6** · Schedule and access declarations · P1 · 🟠 Moderate · 3–4h
  - Schedule holds entries: system factory, priority (int, default 0), access bitmask
  - `DeclareAccess<Write<T...>, Read<T...>>` lowered to dense-ID bitmasks at registration
  - `.priority(N)`, `.before<A>()`, `.after<A>()` on entries
  - `Slot::Terminal` flag for the script runner slot (ADR-020 §4)
  - Registration closes before first tick (same freeze as ComponentRegistry, S6-T1)
  - Tests: register entries, priority assignment, before/after edges, terminal slot flag, double-registration rejection, post-freeze rejection

- [ ] **S6-T7** · Graph builder · P1 · 🟢 Deep · 4–6h (depends on T6)
  - Conflict detection: `A.writes ∩ B.touches ≠ ∅` produces an edge
  - Priority-based direction: lower priority runs first
  - Equal priority on a conflicting pair is a build error
  - Explicit `.before<>()`/`.after<>()` edges override priority between that pair
  - Terminal slot pinned after all regular levels
  - Topological sort into levels. Cycle detection with `TE_CHECK` naming every system
  - Log every conflict-derived edge at build time
  - Tests: conflict detection, priority ordering, explicit override, cycle rejection with named systems, terminal slot placement, disjoint readers on same level, equal-priority error

- [ ] **S6-T8** · Serial executor and barrier · P1 · 🟢 Deep · 4–6h (depends on T7 + T2)
  - Walk levels in order, run one system at a time
  - Command buffer: queue spawn/despawn/add/remove during tick
  - Barrier after tick: apply commands in deterministic order, validate hierarchy (S6-T4), assign NetIds, flush event streams
  - Structural changes invisible until barrier
  - Debug validation: actual access is a subset of declared (`TE_ASSERT`)
  - Coarse write-stamping: `changeTick` per system/archetype/component (ADR-007 §2)
  - Tests: systems run in level order, command buffer deferred until barrier, undeclared access fires assert, write-stamp advances on declared writes only

### Story E — Scene integration and headless proof · 1 task · sized Sep 12

Connect the scene and executor to the shipped simulation lifecycle and demonstrate a
small dependency chain. Hierarchy and transform are in Story B (S6-T4/T5). Input
action mapping remains M5 follow-through. Delivery may roll into Sprint 07.

- [ ] **S6-T9** · Wire executor into the simulation tick · P1 · 🟠 Moderate · 3–4h (depends on T5 + T8)
  - Build the graph once at simulation start from registered systems
  - Each fixed tick: executor walks levels, then runs barrier
  - Register Movement, Gravity, Propagation and Collision as test systems with real access
  - Prove the graph orders them correctly (ADR-020 §5 worked example)
  - Run headlessly: same scene, same graph, no window, deterministic output
  - Tests: multi-tick run produces expected transform state, headless matches windowed, graph reuse across ticks (no rebuild)

### Story F — Repair bounded documentation drift

- [ ] **S6-P1** · Align the documented build/profiler policy with shipped decisions · P3 · 🟡 Light · 2h —
  done: confirm the shipped warning/tidy policy and Tracy pin, apply dated amendments to
  ADR-005/008/013 where needed, and align B3 and Profiler — Design. Preserve enforced
  formatting and the matching Tracy client/desktop requirement. Record any unresolved
  discrepancy rather than making a new policy choice. Sources are the S5-T12 decision
  and the existing backlog entries, moved here at planning.
- [ ] **S6-P2** · Report remaining Sprint 05 artifact and backlog drift · P3 · 🤖 Auto —
  done: produce one bounded report comparing Project, File Access, Simulation Thread,
  Game Loop and their indexed decisions with the inspected engine revision; re-resolve
  fired backlog witnesses too. Classify stale history versus live claims and identify
  resolved entries. Report only; do not amend decisions or advance the Dashboard stamp.
  Verify by reading files. No code PR, build, workflow edit or dependency on this report.

## Definition of Done

- [ ] Scene reuse is grounded in inspected v1 code and an agreed design note.
- [x] The task-graph ADR is Accepted and its design hub reflects fixed-only simulation. — ADR-020 Accepted Sep 12.
- [ ] A small scene runs through the declared dependency graph on the simulation thread
  and produces the expected state headlessly over repeated ticks.
- [ ] Tests prove handle invalidation, storage/query behavior, graph conflicts and semantic
  ordering, cycle rejection, graph reuse/rebuild boundaries and deferred structural changes.
  Exact cases are cut with the accepted designs; none has run at planning.
- [ ] Required implementation PRs are merged with recorded validation, and touched design
  notes describe the shipped behavior. Presentation does not access the live Scene.

## Capacity note

Miguel reports good energy on Sep 12 and wants to continue the current pace. No specific
unavailable dates were supplied. Use the usual two-week rhythm: four weekday deep slots
plus two weekend deep days at 2–3 slots each = **8–10 Deep**, plus **2 Moderate** and
**2 Light** slots. The boundary ceremony shares the first weekend's time; it is not extra
capacity. Weekend work days remain swappable and at least one rest day is the default.

Story B is 5 Dev cards (S6-T1 through S6-T5, 16–23h). Story D is 3 Dev cards (S6-T6
through S6-T8, 11–16h). Story E is 1 Dev card (S6-T9, 3–4h). With 2 Design and
2 Process that is **13 cut cards, ~15–21 substantive sessions**. The upper end will
roll into Sprint 07. Check the actual mix at the Sep 19–20 review. Cut S6-P1 first
if attended time tightens, then carry unfinished scope explicitly.

Current card mix is 9 Dev (5 Deep + 4 Moderate) / 2 Design / 0 Bug / 2 Process.
One Process card is Auto.
The Auto pass selected only S6-P2: no decisions, file-verifiable, off the critical path,
and no workflow edits. It costs no code PR or CI minutes. No automation was changed.

No unfinished Sprint 05 card carries. Known Issue D3 has no identified consumer in this
slice; D4 must be rechecked if integration introduces a real Role-formatting caller.
No new running defect was established in this planning pass. Error-handling policy,
branch-link tooling and workflow-policy decisions remain parked, despite fired triggers;
they are not prerequisites inferred for this sprint. RNG/crash handling remain deferred
roadmap items, not untracked carry cards. Parallel execution stays P1; content stays M6.

## Sprint review (end)

Pending Sep 26–27 boundary review. Mid-sprint review: Sep 19–20.
