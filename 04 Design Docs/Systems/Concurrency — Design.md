# Concurrency — Design

> Living design doc. **Status: active.** The decisions live in
> [[ADR-018 — Main and simulation threads, render-owned GL]] and the remaining clauses of
> [[ADR-015 — Threading (sim on main, render thread owns GL)]]; this note is the working
> shape. Created with the ADR at S4-D1 (2026-08-22), mechanism pinned ahead of the
> implementation cards.

**Module:** `core` (JobSystem) · `app` owns the loop · **Kind:** system · **Status:** active
**ADRs:** [[ADR-015 — Threading (sim on main, render thread owns GL)]] ·
[[ADR-006 — v2 core architecture & module layout]] §1 §4 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §6
**Roadmap:** M2 builds the pool and runs it four wide · M4 exercises the render thread ·
**P1** opens `publish` to workers · **P2** tunes (stealing, Jolt pool, F15)

## Decided

| Fact | Where |
|---|---|
| One shared Clock supplies all loops; each loop owns its timing state and publishes copied measurements through App's timing view. | ADR-019 §3, Accepted Sep 10; [[Clock — Design]] |
| Simulation executes fixed ticks and publishes once after catch-up; render owns interpolation and variable presentation work, with optional vsync. | ADR-019 §1–3 |
| Ordered bounded queues carry input/commands/results; latest-value handoffs carry snapshots, presentation input and metrics. Two interpolation snapshots are private to render. | ADR-019 §3 §4; [[Game Loop — Frame Flow]] |
| Main is event-driven: blocks on events, performs per-wake work, no periodic timer. Tracy frame sets have one writer each. | ADR-019 §5 §6; [[Profiler — Design]] |
| Client target: main owns window/editor input, a dedicated simulation thread drives the loop, and rendering owns GL. | ADR-018 §1–3 |
| Dedicated-server target: main owns CLI/control input, simulation has its own thread, and there is no render thread. | ADR-018 §1; ADR-006 §2 |
| The GL context is current on the render thread once, forever; main issues no GL call after handoff. Work arrives as complete per-frame command lists, newest complete list wins. | ADR-015 §2 |
| `JobSystem` lives in `core`, engine-lifetime, injected via `EngineContext`. | ADR-006 §1 §4, ADR-015 §3 |
| Shipped M2 interface: batch submit/wait. The accepted extension adds dedicated-thread creation, registration and diagnostics; dedicated handles stay with subsystem owners. | ADR-018 §4; [[Simulation Thread — Design]] |
| The pool ships with four workers and a real queue, watched by `linux-tsan`. | ADR-015 §3 + its 2026-08-24 amendment |
| One task-graph level submits as one batch; join before the next level; barriers never run on workers. | ADR-015 §4, ADR-007 §6 |
| Event `publish` is sim-thread-only until P1; lane layout is designed at P1. | ADR-015 §5, [[Events — Design]] § *Open* |
| Dedicated thread handles use scoped registration, explicit readiness/failure and owner-controlled stop/join. | [[Simulation Thread — Design]] § Thread creation and lifetime; Sep 8 |
| Main thread stalls must not suspend simulation. | ADR-018 §1 |

## Design

The accepted target and diagram live in [[Simulation Thread — Design]], backed by
[[ADR-018 — Main and simulation threads, render-owned GL]] (Accepted Sep 7). The topology
below records the historical M4 baseline. ADR-019, Accepted Sep 10, now supplies the time
model in [[Game Loop — Frame Flow]]. T14's branch contains the runner, but integration of
the accepted time model and its validation remain pending; this note does not mark them shipped.

### Shipped topology at M4

```mermaid
flowchart LR
  subgraph main["main thread (client)"]
    PUMP["glfwPollEvents"] --> LOOP["FrameLoop: Input · FixedUpdate ×N · Update · PostUpdate"]
  end
  subgraph rt["render thread"]
    GL["GL context owner: consume newest complete command list"]
  end
  subgraph pool["JobSystem workers (4 at M2)"]
    W["level batches"]
  end
  LOOP -->|"per-frame command list"| GL
  LOOP -->|"submit level, wait"| W
```

The older dedicated-server baseline likewise places simulation on main plus the pool;
ADR-018 replaces that target with a CLI/control main thread and separate simulation thread.

### Surface (pinned 2026-08-22)

- `JobSystem` owns the workers; constructed at the composition root, before `EngineContext`.
- `submit(span<Task>) -> BatchId` and `wait(BatchId)`. A `Task` is a plain callable with no
  return value; results travel through the data the task was given.
- `workerCount()` exists for diagnostics and tests. At M2 it returns 4, which is the
  constructor's default (`JobSystem::DEFAULT_WORKER_COUNT`). A caller may still ask for a
  different width; the tests use a one-worker pool where a single worker is the point.
- Worker threads are named at creation (`TEWorker0`, `TEWorker1`, ...) so Tracy's per-thread
  zones read. Pascal, not `te-`, because `CONVENTIONS.md` § *Target naming scheme* keeps `te_`
  for build-only names and this one is shipped diagnostics. Re-pinned 2026-08-24 at S4-T4,
  was `te-worker-0`; ADR-015 §5 leaves the format to this note.
- Shutdown joins the workers; submitting after shutdown is a `TE_CHECK` with a defined path,
  the registry's check-then-defined-path shape.

Names beyond `JobSystem` (kept from ADR-006 §4) are this note's to refine; header placement
follows `CONVENTIONS.md`'s subject-area folder rule when Story B lands.

### Mechanism (decided in code at S4-T4)

These are not in the ADR. They were settled writing the pool, and each one changes how a
caller has to behave, so they belong here rather than in a comment. The functions named are
all in `engine/core/src/jobs/JobSystem.cpp`.

| Decision | Consequence for the caller |
|---|---|
| **`submit` moves the callables out of the span.** This is why the parameter is `span<Task>` and not `span<const Task>`: a `std::function` copy per task per frame is an allocation the executor would pay every level. | The caller's array holds empty `Task`s once `submit` returns. Rebuild the tasks each frame. Resubmitting the same array runs nothing the second time. |
| **An empty batch is not an error.** `submit` on an empty span returns an invalid `BatchId`, and `wait` on an invalid or already-finished id returns immediately. | A task-graph level with no tasks needs no special case, and `wait` is safe to call twice on the same batch. |
| **A task that throws does not kill the pool** (in `workerMain`). The worker catches, reports through `TE_CHECK` naming the batch and the worker, then decrements the batch as if the task had finished. Decided 2026-08-24 at S4-T4. | `wait` still returns instead of parking forever, and one bad job does not terminate the process. The cost is that a task which failed halfway leaves partial results behind, so the diagnostic is the only signal that a level's output is incomplete. |
| **`wait` from a pool worker is checked, not honoured.** ADR-015 §4 keeps barriers off workers; the code now enforces it instead of assuming it. | A nested `wait` returns immediately with a `TE_CHECK` rather than consuming a worker and hanging the pool. |
| **Shutdown drains the queue, it does not drop it** (in `workerMain`). Workers keep taking queued tasks while stopping and exit only once the queue is empty. | Every outstanding `wait` completes rather than parking forever. The cost is that a long-running queued task delays shutdown, and everything a queued task captured must outlive the pool. |

## Open questions

- **Per-worker event staging lanes and the merge.** Semantics fixed in
  [[Events — Design]]; layout designed at **P1** when concurrent publishers exist.
- **Richer render-data lifetime.** Owner: **R1**'s renderer ADR. ADR-019 already settles
  the small-value mailbox, private interpolation history and optional vsync.
- **Editor ImGui thread.** Owner: **T1**.
- **Jolt pool integration** onto the JobSystem. Owner: **P2** (F15).
- **Beyond fork-join**: task-level edges across level boundaries, caller-runs in `wait`.
  Owner: **P2**, only if P1's captures show the per-level join bubble actually costs.
- **Sub-worker spawning from systems.** Currently a system runs on one assigned worker and
  cannot spawn child jobs (`wait()` rejects calls from pool workers). Future expansion:
  let a system's worker spawn sub-workers for its own iteration and wait for their
  completion. Requires either a parallel-for helper or work-stealing inside `wait()`.
  Not in scope until profiling shows single-threaded system iteration is a bottleneck.
- **Render frame limiter and latency tuning.** ADR-019 fixes loop ownership and makes vsync
  optional; any later limiter remains renderer-owned. See [[Game Loop — Frame Flow]].
- **`JobSystem.hpp`'s weight in public `core`.** The pool's state is in the header, so
  `<mutex>`, `<condition_variable>`, `<deque>` and `<unordered_map>` now reach every consumer
  of `EngineContext`. A pimpl would cost an indirection and an allocation. Surfaced at S4-T4,
  unmeasured; S4-T1 is measuring header weight already and is the natural place to judge it.

## References

- [[ADR-015 — Threading (sim on main, render thread owns GL)]]: the decisions
- [[Task Graph — Execution Flow]]: the levels this pool runs
- [[Game Loop — Frame Flow]]: the loop the topology hosts
- [[v1 Code Audit]]: F15 · F31
- Code: `engine/core/include/TechEngine/core/jobs/JobSystem.hpp` ·
  `engine/core/src/jobs/JobSystem.cpp` · `engine/core/tests/jobs/JobSystemTests.cpp` ·
  wired into `EngineContext` and driven per frame from `engine/app/src/App.cpp` (S4-T4, S4-T5)
