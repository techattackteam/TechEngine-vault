# Task Graph — Execution Flow

> Living design doc. **Status: implementing; fixed-tick App integration shipped**, updated
> 2026-09-22 against ADR-020 (Accepted).
>
> The ADR holds the decision, this doc holds the *how*. The scheduling decisions live in
> [[ADR-020 — System scheduling and task-graph execution]]. ADR-007 §6 defined the system
> interface and conflict DAG; ADR-020 settles the items §6 deferred. This note is the
> **execution view**: one end-to-end sequence, not a restatement of the rules.

**Module:** `core` · **Kind:** system · **Status:** implementing (attended repeated proof reported Sep 26)
**Runs inside:** [[Game Loop — Frame Flow]]. This doc covers one Tick and its barrier.
**ADRs:** [[ADR-006 — v2 core architecture & module layout]] §5 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §6 ·
[[ADR-020 — System scheduling and task-graph execution]] *(Accepted)* ·
[[ADR-021 — Immediate Scene transform propagation]] *(Accepted)* ·
[[ADR-022 — Project system composition and self-description]] *(Accepted)* ·
[[ADR-010 — User authoring model (Systems & Scripts)]] *(Proposed)*
**Roadmap:** [[Roadmap]]. ADR-018 owns the simulation thread; [[Concurrency — Design]]
shows the topology. **P1** turns parallel graph execution on; **P2** considers
work-stealing tuning.

## Purpose

How a registered system becomes running work.

Three layers get conflated whenever people talk about this, so name them separately first.

| Layer | What it is |
|---|---|
| **`Schedule`** | The **input data**. Entries registered at startup, each carrying a priority, an access declaration, and optional ordering overrides. Immutable after the graph is built (ADR-020 §7). |
| **Task graph** | The **derived structure**, built once at simulation start. Systems are nodes. Conflict edges and explicit order edges are the task edges. Sorted into levels. |
| **Executor** | The **runner**. Walks the levels once per tick. Serial first (ADR-020 §8); parallel at P1. |

In one line: the `Schedule` is what you registered, the task graph is what got compiled from
it, and the executor is what runs it.

## Design

### Stage 1: registration, once, at startup

Current shipped spelling:

```cpp
schedule.add<MovementSystem>();

void MovementSystem::init(ScheduleRegistration& registration) {
    registration.access(DeclareAccess<Write<Transform>, Read<Velocity>>{}).setPriority(10);
}
```

Register each system for the single Tick phase with component-access declarations, a priority
and any pairwise ordering. ADR-020 §1–4 owns the exact rules. Registration closes
before the first tick.

S6-T6 shipped this stage in PR #89 (`9be7a8be`). Each entry carries a
default-constructible system factory, component access masks, numeric priority, pairwise
type constraints and terminal-slot metadata. Duplicate registration, post-freeze
mutation, a second terminal entry and unregistered component access are fatal
`TE_CHECK`s in every configuration.

S7-T3 moved declaration into the system in PR #94 (`7e52fe3a`). `Schedule::add<T>()`
now constructs the persistent instance, caches its `name()`, and calls
`ISystem::init(ScheduleRegistration&)`. If `init` throws, the entry is removed. `init`
resolves access immediately, so component types must be registered before `add`. The
call-site `DeclareAccess` argument and chained setters still work and run after `init`;
removing them is a [[Backlog]] entry under core.

### Stage 2: build the graph, once, at simulation start

Lower the component declarations to dense-ID masks, derive conflict and explicit-order edges,
then sort the resulting DAG into levels. ADR-020 §3 owns edge direction and cycle
diagnostics. The cached levels are the task graph consumed by the executor.

S6-T6–T9 track components only. Shared-resource access is deferred until a concrete
scheduled resource conflict needs graph ordering or debug validation (ADR-020's
Sep 19 amendment).

S6-T7 shipped this stage in PR #90 (`ea5d0c9c`). `TaskGraph` stores immutable levels
of system-pointer, system-type and access nodes. Construction rejects equal-priority conflicts
and named cycles with `TE_CHECK`, and freezes the schedule only after a successful build.
Since S7-T3, diagnostics read each entry's cached name, so graph build constructs no
temporary system.

**Built once per simulation session.** The active set cannot change while that session
runs. A different selection requires stopping it and building a new graph before the
next session (ADR-020 §7; ADR-022).
Graph construction adds no allocation or string work inside a tick, which is F19's fix.

### Stage 3: per tick, the executor walks the prebuilt graph

Current shipped graph flow:

```mermaid
flowchart TD
  A["schedule.add&lt;Sys&gt;() → Sys::init declares access and order"] --> B["lower component access to dense-ID bitmasks"]
  B --> C["conflict edges (priority) + explicit .before/.after edges"]
  C --> D["topological levels = TASK GRAPH (cached)"]
  D --> E["Tick ×N (accumulator)"]
  E --> F["barrier"]
```

**Within the Tick phase**, the executor walks the levels in order. Systems on the same level
have disjoint writes, so they are safe to run in parallel. The serial executor (ADR-020 §8)
runs them one at a time. The parallel executor at P1 dispatches each level to workers.

S6-T8 shipped the serial path in PR #91 (`4da771af`). `SerialExecutor` owns one reusable
command buffer per graph node and the barrier's spawned-entity output. Since S7-T3 the
schedule owns the persistent system instances and the executor borrows them; `App`
destroys the executor before the schedule. It consumes the graph's immutable cached levels, runs nodes serially, then
merges their buffers in graph order. Keeping runtime state outside `TaskGraph` preserves
the same graph and per-node buffer boundary for the later parallel executor.

S6-T9 connected this path to the simulation thread in PR #92 (`2a50f8cb`). `App`
registers built-in components, accepts app-specific registration, freezes the registry,
builds the graph and executor once, then executes that instance on each fixed tick.
`RuntimeApp` configures a Movement/Gravity/Collision demo. Its current test observes
one spawned entity after one tick. Miguel reports expected component values and
headless/windowed parity in an attended Sep 26 showcase; those observations are not
encoded in the current App test.

ADR-022 accepts explicit project contribution and app selection. Each selected
persistent system gets one startup opportunity to declare access, scheduled event
handlers and ordering before graph construction. During Tick N+1, the executor
presents Tick N's visible batch once to each selected handler at its system's slot,
before `tick` and under the same declared access. After all systems, including the
terminal slot, finish successfully, it retires Tick N's batch. The barrier makes
Tick N+1's staged events visible. No per-reader cursor or frame counter governs
scheduled delivery (ADR-014 and ADR-022, Sep 26 amendments). The same instance
executes ticks. S7-T3 shipped startup declaration and pre-graph construction; handler
delivery and the no-op event barrier remain until S7-T4–T7.

S7-D1 resolves cross-type delivery at each node: run that system's handlers in their
startup declaration order, exhausting one handler's visible type batch before the
next handler, then call `tick`. Each type retains publisher schedule order and FIFO;
there is no merged order across types. The declaration surface is entry-scoped;
its class and method names remain implementation choices.

Current-Tick input uses a separate path. Simulation detaches the ordered ingress
batch before each Tick; selected systems receive its input notifications at their
scheduled slots before `tick`. It does not wait for the Scene event barrier or
retire through Scene streams. [[Input — Design]] owns its delivery and reset rules.

Systems perform value reads and writes only. Nothing structural happens here.
Transform setters refresh their affected subtrees within the calling system, so
world reads later in that system see current values. No separate transform
propagation entry is scheduled (ADR-021).

**At the barrier**, per-system command buffers are merged in graph order and applied
**single-threaded, in deterministic order**, then injected barrier services are called
for `NetId` assignment and event flushing. `App` currently supplies a no-op adapter.
Event integration is planned in [[2026-09 Sprint 07 — Scene Events and Input Boundary]];
`NetId` assignment waits for a networking consumer. Structural changes land here: spawn,
despawn, add and remove. Pending-entity tokens are local to the buffer that created them.
Hierarchy constraints are validated at commit time. That is what makes determinism hold
even once levels run in parallel.

**Debug validation.** `Scene` asserts that the **actual** access is a subset of the
**declared** access, so touching an undeclared component fires `TE_ASSERT`. Column
write-stamping (`changeTick` per system/archetype/component) marks every matching declared
writable column once before that system runs. The access assertion is debug-only; change
stamps remain part of runtime state in every configuration.

### Where scripts slot in (ADR-010, Proposed)

`ScriptSystem` is an ordinary entry pinned to the **terminal slot** of the Tick phase
(ADR-020 §4). `Slot::Terminal` means "after all regular levels, before the barrier."

```mermaid
flowchart LR
  L["Regular levels"] --> S["ScriptSystem: terminal slot"] --> B["Barrier"]
```

One terminal entry is allowed in Tick; a second is a build error. A terminal entry may
omit its access declaration (ADR-010 §5). Scripts run after every regular system. Their spawns
queue through the **same per-system command-buffer path**, so there is no separate structural
mutation path to keep consistent.

## Settled questions

Grouped by the ADR that settled them.

### Thread ownership

ADR-018 (Accepted Sep 7) supersedes simulation-on-main: the executor will run on the
dedicated simulation thread against `JobSystem`'s batch submit/wait. GL ownership and
level/barrier semantics remain. Current target: [[Simulation Thread — Design]].

### Settled by ADR-020 (Accepted Sep 12)

The terminal slot, whole-system node granularity and immutable schedule are now
decided in ADR-020 §4, §6 and §7. S6-T6–T8 implement schedule declarations, graph
construction and serial execution; S6-T9 connected them to fixed ticks.

### Deferred to implementation [P1 → P2]

- **A parallel executor, plus Jolt pool integration.** This fixes F15. P1 is a near-term
  follow-up to M5. The level structure feeds a pool **unchanged**, so this changes no
  interface. Work-stealing tuning is P2.

## References

- [[ADR-020 — System scheduling and task-graph execution]]: the scheduling decisions
- [[ADR-007 — v2 networking & ECS replication foundation]] §6: system interface and conflict DAG
- [[ADR-006 — v2 core architecture & module layout]] §5: the System and helper taxonomy
- [[Game Loop — Frame Flow]]: the frame this graph executes inside, including Tick running N times
- [[ADR-010 — User authoring model (Systems & Scripts)]]: the script terminal slot
- [[v1 Code Audit]]: F15 (three ad-hoc threading models) · F19 (per-frame allocation)
- Code: Schedule, graph and serial executor shipped in PRs #89–91 (`9be7a8be`, `ea5d0c9c`, `4da771af`); fixed-tick integration shipped in PR #92 (`2a50f8cb`)
