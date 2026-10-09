# 🗃️ Backlog

A parking lot for ideas, observed problems and future work. **One bullet per item.**
It supplies candidates at `/sprint-plan`, not design decisions or implementation specs.

- **Each triaged entry is one bullet with `#prio/…`; `Trigger:` is optional.** Use a
  trigger only when a concrete event would make the work timely. An entry that grows
  a decision, a rationale or a `How:` has outgrown this file. Move that content to an
  ADR or a design note ([[Planning Workflow - Artifact Gate]]).
- **Prio means *want*; a trigger marks a reason to act now.** At sprint planning, turn
  every still-valid fired entry into a task after checking its evidence. Then review
  the rest by priority with Miguel, choose one to three to add to the sprint, remove
  rejected or obsolete entries, and keep useful unselected items with an updated priority.
  An item does not need a fired trigger to be chosen.
  This is not the board's `P1/P2/P3`. That scores value against one sprint's goal
  ([[Planning Workflow - Artifact Gate]] → *Priority + weight*). This scores whether a thing
  has value in the backlog.
- **Five levels, re-bucketed at `/sprint-plan`:** `#prio/xhigh` › `#prio/high` ›
  `#prio/medium` › `#prio/low` › `#prio/xlow`. Filter with `tag:#prio/high` in search, or use
  the tag pane. A bucket that nobody ever re-scores downward is a broken bucket, so that pass
  is part of grooming rather than optional.
- **Decided means deleted.** The moment a decision lands in an ADR or a design note, the entry
  goes. No tombstone, and no trace. [[ADR Index]] is the record of what is settled.
- **Scheduled means deleted.** Pulling an entry into a sprint is a **move**, not a copy. The
  entry is cut as the card is written. There is no `✅ Scheduled` state and no "done" state.
- **On the ladder means deleted.** [[Roadmap]] owns *sequencing*, which is what a `Trigger:`
  was doing. An entry that is only a thing plus a trigger is superseded the moment a rung
  carries it. What survives here is what no rung names.

Entries are grouped by module ([[ADR-006 - v2 core architecture & module layout]] §1). Empty
groups are kept, because they show where future work will land.

---

## base

- #prio/medium · **Get `<chrono>` out of `Log.hpp`**: `LogRecord`'s `system_clock::time_point`
  is the only reason it is there, and `<chrono>` costs ~1200 ms and 73k preprocessed lines per
  TU on MSVC (S4-T1's numbers, [[B3 - Build & Testing Notes]]). It is the engine's most widely
  included header. **Trigger:** a full-rebuild time that actually hurts, measured not guessed.
- #prio/medium · **Allocators**: a Pool primitive. **Trigger:** a first consumer. Events
  declined it ([[ADR-014 - Events (buffered streams) & StringId]] §7, contiguous streams, no
  node churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting
  ADR).
- #prio/medium · **Code sweep leftovers: base**: Found by the code sweep on Oct 8, 2026
  ([[2026-10-08 14-08 Auto Run]]). It folds in the two Sep 28 entries that #119 did not fix.
  - The version anchors: `baseVersion()` (`engine/base/include/TechEngine/base/Base.hpp:4`),
    `platformVersion()` (`engine/platform/src/Platform.cpp:7`) and `coreVersion()`
    (`engine/core/src/Core.cpp:8`) are the S1 link-order stubs, and nothing calls
    `coreVersion()`. Delete them, `Base.hpp`, `Base.cpp` and `BaseTests.cpp`, whose glm case
    repeats `MathTests.cpp`. About 35 lines. A test covers `baseVersion()`, so it is not dead.
  - The log-capture guards: `SinkGuard` (`engine/base/tests/diagnostics/LogTests.cpp:50-70`),
    `LogCaptureGuard` (`engine/base/tests/diagnostics/AssertTests.cpp:68-83`) and
    `GraphLogCaptureGuard` (`engine/core/tests/systems/TaskGraphTests.cpp:140-160`). Use one
    guard in `te_test_support`. About 30 lines. It needs a new header, and which record fields
    the shared guard copies is a choice.

## platform

- #prio/medium · **File watching**: v1's `IFileWatcher`, for editor hot-reload; its
  callback-subscription shape needs re-reading against
  [[ADR-014 - Events (buffered streams) & StringId]]. **Trigger:** hot-reload being wanted (M6+).

- #prio/low · **`executablePath()` aborts on a Windows path longer than `MAX_PATH`**:
  `resolveExecutablePath` calls `GetModuleFileNameW` into a fixed `wchar_t[MAX_PATH]` and
  `TE_CHECK`s that the result fit (`engine/platform/src/ExecutablePath.cpp:16-19`). 260
  characters is not the Windows limit, so a deep install path is legal and kills the process.
  The alternative is retrying into a growing buffer until the call stops truncating. Taken
  deliberately at S5-T1 with the trade named: a fatal is honest, and nothing ships to a deep
  path today. **Loud, not silent**, so it is here rather than in [[Known Issues]].
  **Trigger:** the first install or CI checkout under a long path, or long-path support being
  turned on.

- #prio/low · **`FileAccess::move` cannot cross a filesystem boundary**:
  `std::filesystem::rename` fails with `cross_device_link` when two mounts on one alias sit on
  different drives, and `move` surfaces that as the generic `IoError`
  (`engine/platform/src/files/FileAccess.cpp:262`). The alternative is falling back to
  copy-then-remove, which is not atomic and needs its own decision about a partial copy. Left
  undecided at S5-T3. No test covers it. **The comment this entry credited does not exist:**
  it was filed saying `move` carries "a comment saying so", and `cross_device`, `cross-device`
  and `filesystem boundary` return no hit anywhere under `engine/`, `apps/`, `sdk/` or
  `cmake/`. Either it was dropped in review under `CLAUDE.md` § *Code conventions*' default-to-no-comment
  rule or it was never written, so this entry is the only record of the decision.
  **Trigger:** the first project mounted from a different drive than the engine, which the
  editor's two-root bootstrap (S5-T5) makes reachable.

- #prio/medium · **`FileAccess::remove` resolves a must-exist path through `resolveForCreate`**:
  `remove` takes the highest-priority mount for the alias and never probes
  (`engine/platform/src/files/FileAccess.cpp:190`), so a file held only by a lower-priority
  mount in an overlay comes back `NotFound` while `read` and `list` both find it. That is the
  same shape S5-T3's review corrected for `copy`, `move` and `rename`, whose sources moved to
  `resolveExisting`; `remove`'s argument must already exist for exactly the same reason and did
  not move with them. [[Project - Design]] § *The five mutating calls* names only those three in
  its sources rule, so the note decides `remove` neither way. **Both readings are defensible**,
  which is why this is a decision and not a one-line change: a delete that reaches through an
  overlay into a lower and possibly read-only mount may be precisely what should not happen.
  `copy` has an overlay case (`engine/platform/tests/files/FileAccessTests.cpp:526`) and
  `remove` has none. **Silent**, because `NotFound` is a legitimate answer and the caller cannot
  tell it from the resolver having taken the wrong mount. **Trigger:** the first overlay mount
  set with a delete over it, which S5-T5's editor bootstrap makes reachable, or the next edit to
  that section.

- #prio/low · **`InputState` leftovers from S7-T9's review**: `isHeld` checks `focused`
  although `apply` already keeps both bitsets empty while unfocused
  (`engine/platform/src/input/InputState.cpp:36`, `:43`). The two copies of that rule could
  disagree silently if S7-T11 reads the bits directly for held notifications. The same file
  casts to an unqualified `size_t`, and no test covers the `Unknown` guards in `apply` and
  `isHeld`. **Trigger:** S7-T11, which edits this file.

- #prio/medium · **Restore a read-only FileAccess boundary**: `copy`, `move` and
  `rename` are `const` but write to disk. [[File Access - Design]] § *Open questions*
  records the options. **Trigger:** the SDK boundary or the next FileAccess API edit.

## core

- #prio/medium · **Resources: hot-reload / eviction**: candidate ADR; depends on the
  UUID/cache model ported from v1 (F7, F13, F31). **Trigger:** the resource cache being real (M6).

- #prio/low · **A test for `wait()` called from a pool worker**: the `TE_CHECK` added at
  S4-T4 is the only guard, and it has no case, because without it the test hangs rather than
  fails and costs a CI timeout to catch. **Trigger:** a test helper that can fail a case on a
  deadline.

- #prio/low · **Remove call-site access and ordering from `Schedule::add`**: S7-T3 moves
  declarations into `ISystem::init`, but `add<T>(DeclareAccess<…>)` and the returned
  registration's `setPriority`, `setSlot`, `before` and `after` still work. They run after
  `init`, so they silently merge with or override a system's own declaration. The schedule
  and graph tests use them heavily. S7-T4 added `onEvent<Event>` to the same handle, and a
  `ScheduleTests` case now pins a handle declaration after the `init` handlers. The
  constructor-injection entry below depends on removing this parameter. **Trigger:** a bug
  where a call-site declaration hides a system's own, or the next rewrite of those tests.

- #prio/medium · **Systems cannot receive services through their constructor**:
  `Schedule::add` requires `std::default_initializable<T>` and builds the instance with
  `std::make_unique<T>()` (`engine/core/include/TechEngine/core/systems/Schedule.hpp:55`,
  `:74`), and `ISystem::init` receives only the registration. ADR-006 §4 and ADR-022
  *Decision* both name constructor injection as the way services reach systems, so the only
  path left is `SimulationContext::engine` during `tick`, which hands every system the whole
  context. A system that needs a service at startup, such as a physics system creating its
  Jolt world with the `JobSystem`, has to defer that setup to its first Tick. Letting `add<T>`
  forward constructor arguments collides with the call-site `DeclareAccess` parameter, so this
  depends on the entry above. Found at the ownership review, Sep 27. **Trigger:** the first
  system that needs a service, S1's physics system at the latest.

- #prio/low · **Rename `EngineContext` to `EngineServices`**: the struct holds only
  process-lifetime services (`FileAccess`, `JobSystem`, `Clock`), but its name makes it look
  like the same kind of thing as the per-Tick `SimulationContext`. The new name would make the
  split between engine services and per-Tick values visible in the code. ADR-006 §4 and several
  later ADRs use the current name, so the rename needs a naming amendment in ADR-006's header,
  like its Jul 24 vocabulary amendment. Proposed by Miguel at the ownership review, Sep 27.
  **Trigger:** before an SDK surface exposes the name to project code, because a rename after
  that breaks projects.

- #prio/medium · **Declare the event types a system publishes**: ADR-014 §4 makes event
  access a declared `SystemAccess` category, and only the reader side was amended to
  handlers. `Scene::publish` accepts any registered type from any system, and no card owns
  the publish declaration. The shape is a publish declaration on S7-T4's entry-scoped
  surface, checked in `Scene::publish` the way `validateWrite` checks components. Found at
  S7-T6's review, Sep 27. **Trigger:** S7-T4 landing its declaration surface. **Fired Sep
  27:** #99 shipped `ScheduleRegistration::on<Event>`.

- #prio/low · **[[Clock - Design]] still argues from several simulations per process**: its
  *Why simulation time is not here* says tests run several headless sims side by side. ADR-014
  §5 made the same argument and was corrected on Sep 27, because the runtime and the editor
  each run one simulation. Clock's conclusion rests on ADR-019, not ADR-014, so its reasons
  need their own check rather than a copy of ADR-014's. Found at S7-T6, Sep 27. **Trigger:**
  the next edit to that section, or `/weekly-review`'s drift check.

- #prio/medium · **Should `SerialExecutor` borrow the graph instead of copying it?**: its
  constructor copies each `TaskGraphNode`'s access mask and system pointer into its own node,
  then drops the graph (`engine/core/src/systems/SerialExecutor.cpp:29`). Only per-node runtime
  state, such as the command buffer, has to live in the executor; the parallel executor needs
  that split, but not the copy. Borrowing a `const TaskGraph*`, as it already borrows systems
  from the schedule, would remove the duplicate `ScheduleAccess` and handler copies. Analyse
  the options, including the executor-before-graph lifetime in `App` and the tests, and
  implement the better one if borrowing wins. Found at S7-T4, Sep 27. **Trigger:** S7-T7's
  handler dispatch, or the parallel executor at P1. **Fired Sep 27:** #100 dispatches handlers
  from the executor's copied nodes.

- #prio/low · **Events published in a failed Tick stay staged**: a failed phase discards its
  structural commands but not its publications, so a retried Tick would make them visible
  alongside the retry's own. Today a failed phase ends the simulation, so nothing retries.
  S7-T7's failure test publishes nothing in the failing Tick, so no test pins either answer.
  Found at S7-T7, Sep 27. **Trigger:** the first path that re-executes a Tick after a failure.

- #prio/low · **Should `Scene::makeEventsVisible` and `retireEvents` stay public?**: since
  S7-T7 the executor, which is `Scene`'s friend, calls them at the barrier. Only tests call
  them from outside, and a `TE_CHECK` rejects them inside a system. Making them private removes
  that runtime gate along with its two `SceneEventTests` cases. Found at S7-T7, Sep 27.
  **Trigger:** a second caller outside the executor, or the next `Scene` API pass.

- #prio/low · **Component registration still takes its tag as an argument**: since S7-T8,
  `registerEvent<T>()` reads `T::tag`, while `registerComponent<T>(T::tag)` still passes a tag
  that every component already carries as `T::tag`, so the two registries differ. Aligning
  components would also let a component concept reject a type with no tag. Found at S7-T8,
  Sep 27. **Trigger:** the next change to `ComponentRegistry`'s registration call.

- #prio/low · **Intra-system chunking for heavy systems**: parallelize a system's entity
  iteration without changing whole-system graph semantics. **Trigger:** profiling after the
  parallel executor shows one system node dominates a tick.

- #prio/low · **Three public symbols in core have no caller and no test**: `toString(Role)`
  (`engine/core/include/TechEngine/core/SimulationContext.hpp:13-23`, the only reason the header
  includes `<string>`), `ComponentRegistry::tagOf`
  (`engine/core/include/TechEngine/core/scene/ComponentRegistry.hpp:56`, defined at
  `engine/core/src/scene/ComponentRegistry.cpp:42`) and `Writer::size()`
  (`engine/core/include/TechEngine/core/serialization/Writer.hpp:87`). `toString(Role)` lost its
  last callers when the log lines from #63 went away. Every serialization test reads the
  buffer's own `size()`. `EventRegistry::tagOf` is tested and stays. The simpler shape deletes all three, about
  25 lines. The sweep did not fix this, because the three are public API. Found by the code sweep on
  Oct 1, 2026. **Trigger:** the next edit to any of the three headers.

- #prio/low · **Two Scene paths re-implement `ComponentRegistry::denseId`**:
  `Scene::addComponentInternal` and `Scene::removeComponentInternal`
  (`engine/core/src/scene/Scene.cpp:593-603`) and `ArchetypeStorage::denseId<T>`
  (`engine/core/src/scene/ArchetypeStorage.hpp:154-158`) each write `find`, the same
  "Component type is not registered" `TE_CHECK`, and `->denseId`. That is exactly the body of
  `ComponentRegistry::denseId` (`engine/core/src/scene/ComponentRegistry.cpp:24-28`). The
  simpler shape calls `m_registry->denseId(type)`, which removes about 8 lines. This fix met the
  sweep's bar, but today's PR slot was already used. Found by the code sweep on Oct 1, 2026.

- #prio/low · **`ArchetypeStorage::componentRaw` is written twice**: the const and non-const
  overloads (`engine/core/src/scene/ArchetypeStorage.cpp:82-109`) have the same 12-line body.
  The simpler shape is the `std::as_const` plus `const_cast` forwarding that
  `EventStreamManager::getStream` already uses (`engine/core/src/events/EventStreamManager.cpp:45-47`).
  It removes about 10 lines. This fix met the sweep's bar, but today's PR slot was already used.
  Found by the code sweep on Oct 1, 2026.

- #prio/low · **`Scene::unparent` repeats `setParent`'s detach**: `setParent` validates the old
  parent and siblings and then unlinks the child (`engine/core/src/scene/Scene.cpp:301-316` and
  `:351-361`). `unparent` performs the same validation and the same unlink
  (`engine/core/src/scene/Scene.cpp:417-435`). The simpler shape is one private member that
  validates and unlinks a child, and both callers use it. It would remove about 20 lines. The
  `HierarchyTests` cases cover both paths. Found by the code sweep on Oct 1, 2026.
  **Trigger:** the next change to hierarchy linking.

- #prio/low · **The schedule's bitmask and entry guards are written several times**:
  `ScheduleAccess`'s constructor sets bits with two identical loops, and `reads` and `writes`
  each repeat the word and bit arithmetic (`engine/core/src/systems/ScheduleAccess.cpp:22-63`).
  `Schedule::addAccess` merges the two masks with two identical resize-and-OR blocks
  (`engine/core/src/systems/Schedule.cpp:50-67`). Five `Schedule` setters open with the same
  two `TE_CHECK` lines, and each one then calls `.at()` on an index it has just checked
  (`engine/core/src/systems/Schedule.cpp:44-94`). The simpler shape is one private static mask
  helper for set, test and merge, plus one private member that checks the index and returns
  the entry. Together they would remove about 25 lines. The *Remove call-site access* entry
  above may delete `addAccess`'s merge first. Found by the code sweep on Oct 1, 2026.
  **Trigger:** the next change to `ScheduleAccess` or the `Schedule` setters.

- #prio/low · **`SceneCommandBuffer` writes its pending-entity check four times**: the same
  bufferId and epoch `TE_CHECK` appears in `despawn`, `queueAdd`, `queueRemove` and
  `apply`'s `resolveTarget` (`engine/core/src/scene/SceneCommandBuffer.cpp:105`, `:114`,
  `:123`, `:134`). The `Entity` and `PendingEntity` overloads of the private `addComponent` and
  `removeComponent` templates also have identical bodies
  (`engine/core/include/TechEngine/core/scene/SceneCommandBuffer.hpp:108-130`). The simpler shape
  is one check on `Impl`, which lives in the `.cpp`, plus one template per operation over the
  target type. It would remove about 15 lines. Found by the code sweep on Oct 1, 2026.

- #prio/low · **`ArchetypeStorage`'s typed mutations exist only for tests**: the
  `addComponent<T>` and `removeComponent<T>` templates
  (`engine/core/src/scene/ArchetypeStorage.hpp:55-90`) repeat the type-erased
  `addComponent` and `removeComponent` that `Scene` uses (`engine/core/src/scene/ArchetypeStorage.cpp:49-76`).
  `ComponentStorage::set` (`engine/core/include/TechEngine/core/scene/ComponentStorage.hpp:107`)
  exists only for the typed path and one `ArchetypeStorageTests` case. The simpler shape keeps
  the type-erased path and makes the typed one a two-line forward, or deletes it. That would
  remove about 30 lines, but the scene tests call it about 85 times, so the choice is yours.
  Found by the code sweep on Oct 1, 2026. **Trigger:** the next `ArchetypeStorage` API change.

- #prio/low · **Two core test fixtures build the same engine context by hand**:
  `ExecutorFixture` (`engine/core/tests/systems/SerialExecutorTests.cpp:234-251`) and
  `SceneEventFixture` (`engine/core/tests/scene/SceneEventTests.cpp:180-218`) declare the same
  seven members: `MountTable`, `FileAccess`, `JobSystem`, `Clock`, `EngineContext`,
  `InputFrame` and `SimulationContext`. They initialize them the same way. Their state guards
  (`SerialExecutorTests.cpp:45-59`, `SceneEventTests.cpp:63-77`) are the same class.
  `amountsOf` is written in both `EventStreamTests.cpp:26-32` and `SceneEventTests.cpp:79-86`.
  `registerMaskComponents` (`ScheduleTests.cpp:196-199`) is `registerGraphComponents`
  (`TaskGraphTests.cpp:162-165`) under another name. The simpler shape is one core test header
  beside `SceneTestRegistry.hpp`. It would remove about 40 lines. Found by the code sweep on
  Oct 1, 2026. **Trigger:** a third test file that needs a running `SimulationContext`.

## client

- #prio/low · **Code sweep leftovers: client**: Found by the code sweep on Oct 5, 2026
  ([[2026-10-05 14-08 Auto Run]]). Each fix needs a new `te_test_support` header, which the
  sweep may not add.
  - `FrameRendererWindowScope` (`engine/client/tests/render/FrameRendererTests.cpp:13-17`),
    `RenderWindowTestScope` (`engine/client/tests/render/RenderThreadTests.cpp:14-18`) and
    `PlatformWindowTestScope` (`engine/platform/tests/window/WindowTests.cpp:17-21`) are the
    same guard that calls `Window::terminate()`. One shared guard would remove about 10 lines.
  - The three `ClientTests.cpp` cases (`:11-16`, `:31-36`, `:51-56`) build the same
    `JobSystem`, `Clock`, `MountTable`, `FileAccess`, `EngineContext` and `InputBuffer` by
    hand. The same set is in core's fixtures (the *Two core test fixtures* entry above), so
    one shared engine-services helper would serve both modules. Here it would remove about
    10 lines.

## app

- #prio/medium · **Expose project system contribution and pre-session selection**:
  complete [[ADR-022 - Project system composition and self-description]]'s public
  catalog boundary beyond App's built-in schedule selection. **Trigger:** the first
  project-supplied system or project-code loading card.

- #prio/medium · **No object owns one simulation session**: `App` builds the simulation once
  per lifetime. `finalizeSimulation` returns early after its first run
  (`engine/app/src/App.cpp:99`), `Schedule::freeze` has no inverse, the registries stay
  frozen, and `Scene` rejects a second stream build (`engine/core/src/scene/Scene.cpp:496`).
  ADR-022 *Decision* requires stopping a session, destroying its executor and graph, selecting
  again and rebuilding, but no object has that lifetime: `Scene` and `Schedule` live as long
  as `App`, while the graph and executor are `unique_ptr`s built once. The `Scene` without
  streams until `finalizeSimulation` and the `m_simulationFinalized` flag are symptoms of the
  same gap. What survives between editor sessions (Scene contents, event streams, system
  state) is load-bearing and likely needs an ADR. Found at the ownership review, Sep 27.
  **Trigger:** the project-contribution entry above, or the first editor Play and Stop.

- #prio/medium · **Both threads can reach `App::m_scene`**: `m_scene` is `protected`
  (`engine/app/include/TechEngine/app/App.hpp:42`), so a subclass's main-thread hooks can touch
  the Scene while the simulation thread owns it. `Scene`'s execution guards are `thread_local`
  (`engine/core/src/scene/Scene.cpp:28`), so on the main thread it believes no system is
  running and allows everything, including immediate structural mutation. **Silent**: only
  the TSan leg could catch the race, and only if a test exercised it.
  [[Scene - Design]] § *Ownership and lifetime* forbids main-thread borrowing, but nothing
  enforces it. Making `m_scene` private and passing `Scene` to the simulation-thread hooks
  would; `RuntimeAppTests` reads it through a probe that would need a replacement. Found at the
  ownership review, Sep 27. **Trigger:** the editor inspector on rung T1, or any main-thread
  hook that wants Scene data.

## net

- #prio/medium · **Assign NetIds at the Tick barrier**: connect server-authoritative NetId
  allocation to newly spawned replicated entities. **Trigger:** the first networking or N2
  replication card; move this requirement into that card when scheduled.

- #prio/low · **Debug assert on raw entity indices arriving over the wire**: catches a user
  component holding a slotmap index instead of a `NetId`. **Trigger:** the first replicated
  user component.

## server *(future module)*

- *(none, lands with N1)*

## scripting / `te_sdk` *(future module)*

- *(none)*

## editor & tooling *(exe)*

- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).
- #prio/medium · **Project launcher UI**: list, open and create projects inside the
  editor executable. [[Project - Design]] records the placement and open storage choice.
  **Trigger:** the first editor UI card.
- #prio/medium · **Code sweep leftovers: apps**: Found by the code sweep on Oct 7, 2026
  ([[2026-10-07 14-08 Auto Run]]). This covers both `apps/runtime` and `apps/editor`.
  - `RuntimeApp.cpp:26-98` and `EditorApp.cpp:28-85` host the client the same way: starting
    it, `publishSnapshot`, `mainThreadUpdate` (only the title prefix differs),
    `wakeMainThread`, `renderTiming`, `shutdown` and `shouldClose`. The simpler shape is one
    client-hosting `App` subclass that takes the window title. It would remove about 45 lines.
  - `RuntimeApp::runtimeRole()` (`RuntimeApp.cpp:100`) and `EditorApp::editorRole()`
    (`EditorApp.cpp:87`) are public statics that only return `Role::Client` for the
    constructor. Passing `Role::Client` directly would remove about 8 lines.
  - `CollisionSystem.cpp:19` names an unused `context` and `GravitySystem.cpp:26` an unused
    `entity`, which are 2 of the build's 10 warnings. Leaving them unnamed, as
    `EntitySpawnSystem::tick` and `MovementSystem`'s lambda do, removes no lines.

## etc: cross-cutting

- #prio/medium · **Jolt's precompiled header probably makes all 138 Jolt TUs uncacheable**: every
  `ccache stats` step on the last three `master` runs reports 139 uncacheable calls out of 386 on
  Linux and 381 on Windows. The build logs show 138 Jolt `.cpp` objects plus Jolt's
  `cmake_pch` object, which is exactly 139. ccache does not reuse a PCH-using compile without
  extra `sloppiness` settings, and `ci.yml` sets none. The match is circumstantial: `ccache -s`
  gives no reasons, and `ccache -sv` would. If it holds, [[B3 - Build & Testing Notes]]
  § *ccache keys* is wrong that Jolt's compiles are cached: 140 of the 183 compilations were
  meant to be deps. On a 100%-hit Linux run (#106), the Jolt stretch of the build still took
  about 47 seconds. Found by S7-P7 on Sep 30, 2026. **Trigger:** the next CI-time card, or the
  next change to `deps.cmake`'s Jolt block.
- #prio/medium · **`ci.yml`'s `prune caches` job has never deleted anything**: S7-P10 (#110,
  `16b934d6`) merged without a `ci.yml` run, because workflow-only merges are excluded by the
  push filter. Every cache was deleted by hand the same day, so the first run on any ref only
  seeds one entry per family and has nothing to prune. The witness is the first `prune caches`
  log that reports a nonzero stale count and a successful `delete` line, after which
  `gh cache list` shows one entry per family on that ref. Until then the 10 GB bound is
  unproven. Found at S7-P10's close on Oct 1, 2026. **Trigger:** the second `ci.yml` run on
  `master` after #110, or the second push to any open PR.
- #prio/medium · **A workflow file that does not parse can still merge**: #95 broke
  `ci-docs.yml`'s YAML (fixed by S7-P9, #104). A run that fails to parse reports under the
  file's path, which is not a required context, and #95 also touched code, so `ci.yml`
  reported the nine required contexts and the merge went through. Nothing checks that a
  workflow file parses before it lands. Found at S7-P9's close on Sep 28, 2026.
- #prio/medium · **The lane's PR bodies carry an AI attribution footer**: #103's body ended
  with "Generated by Claude Code" and a session link, although
  [[Autonomous Lane - Routine Prompt]] bans AI attribution in a PR body. The squashed commit
  message was clean. The footer is probably added by the cloud harness and not by the prompt,
  so another prompt line may not stop it. Found at S7-P2's close on Sep 28, 2026.
  **Fired Sep 29:** the lane's next PR, #106 (S7-P3), ends in the same footer and session
  link. The sweep PR #107 the same day does not.
  **Workaround found Oct 2:** #113 carried it too. On #114 the footer was appended when the PR
  was created, and one body update through the GitHub MCP tool with the same text removed it.
  A routine-prompt line could make that update a standard step.
- #prio/low · **No CI leg builds with the log gate above Info**: S7-B1 (#113, `2b9c921f`)
  made `-DTE_LOG_ACTIVE_LEVEL=3` build cleanly and pass, but only on a local Linux debug run.
  The CI matrix builds every leg at its default level, so a new test that asserts on an Info
  record, or a parameter only an Info log reads, breaks that build unseen. MSVC has never
  built at level 3. The fix is a leg or a step in `.github/workflows/ci.yml`, which costs CI
  minutes and is outside the Auto lane. Policy in [[Logger - Design]] § *Tests under the
  level gate*. Found at S7-B1's close on Oct 2, 2026. **Trigger:** the next CI-matrix card,
  or the first time a level-3 build breaks again.
  **Near miss Oct 6:** #117 added `InputLogSystem::onRecovered`, whose parameter only an Info
  log reads. It got `[[maybe_unused]]` by hand before the commit; nothing would have caught it.
- #prio/low · **Undriven demo code counts against diff coverage**: the runtime test binary
  compiles `apps/runtime`'s demo systems, so `cmake/coverage_report.cmake` measures their
  changed lines, but no test publishes input into `RuntimeApp`. `InputLogSystem`'s lines are
  never run. #111, which added it, and #117 both shipped with `[skip-coverage]`; #117's body
  names those lines as the reason. A headless `RuntimeAppTests` input case would cover them;
  Miguel kept S7-T12 without one on Oct 6. Related: S7-P1's `App.cpp` coverage exclusion.
  Found at S7-T12's close on Oct 6, 2026. **Trigger:** the next card that changes an undriven
  demo system.
- #prio/low · **`static` helpers that now belong to a class**: the Sep 29 rule
  (`CONVENTIONS.md` § *Internal linkage*, history in [[B4 - Code Conventions]]) makes a helper
  that serves a class's member functions a private member. About 22 older `static` helpers
  across 11 source files predate it, and some serve no class and correctly stay `static`.
  Convert one when its file is next touched, not in a rename pass. Found by the
  `engine/platform` code sweep on Sep 29, 2026. **Trigger:** the next edit to a file that
  has one.
- #prio/low · **Nothing runs the vault citation checker**: S7-P3 (#106) shipped
  `tools/check-vault-citations.py`, but neither `/weekly-review`'s drift check nor CI calls
  it. Its first run reported 158 of 290 citations, most of them expected (a stale stamp,
  [[v1 Code Audit]] with no `v1-reference` anchor, shas lost in the August rewrite). Until
  that noise is cut down with `--exclude` or anchors, its output is not a usable gate.
  Decide whether the drift check runs it, and with which excludes. Found at S7-P3's close on
  Oct 1, 2026. **Trigger:** the next `/weekly-review`.
- #prio/medium · **The autonomous lane's test line fails without a display**: step 6 of
  [[Autonomous Lane - Routine Prompt]] runs a bare `ctest --preset linux-debug`. The cloud
  sandbox has no `DISPLAY`, so 18 of 428 cases (every Window, Client, renderer and
  editor case that opens a window) fail on GLFW error 65550. Under
  `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a ctest --preset linux-debug`, which matches `ci.yml`,
  all 428 pass. Xvfb is already installed in the image. The note's measured "200/200" row is
  stale for the same reason. Found by the Sep 27 fire on S7-T1. **Trigger:** the next time
  the routine prompt is pasted into the routine.

- #prio/medium · **A `TE_ENSURE` case passes under `ctest` and fails when the test exe is run
  directly**: report-once is per call site through a function-local static (ADR-011 §5), and
  `catch_discover_tests` hides that by giving every Catch2 case its own process. Two
  `EventRegistryTests` cases hit the duplicate-tag site, and S5-T2 dropped the fire count from
  the second rather than leave the trap armed. That is a patch, not a fix: the next suite that
  asserts a fire twice through one site inherits the same split behaviour, and it will look
  like a flake. Options are a test-only reset hook on the report-once static, or a rule that a
  fire count is asserted at exactly one case per site. **Trigger:** the next card that adds a
  `TE_ENSURE` case, or the first developer confused by a green `ctest` and a red exe.

- #prio/low · **Four CI legs can never restore a ccache, and it is scoping, not the key**:
  a cache written on `refs/pull/N/merge` is readable only by that PR; only caches on
  `refs/heads/master` are shared across branches. `sanitizers` and `coverage` are
  `pull_request`-only by design (`ci.yml`, ADR-008 §9 Option A), so master never writes their
  entries. Measured on #59: master holds ccache entries for exactly `linux-debug`,
  `linux-release`, `windows-debug`, `windows-release`, and the ASan, UBSan, TSan and coverage
  legs all logged "No cache found". **The likely answer is to leave it.** Adding the four to
  the master push costs roughly 15 billed minutes per merge, Windows ASan at 2×, to save one
  or two minutes per leg on the next PR. At one PR per merge that is a net loss against the
  2k budget. What this needs is the reasoning written into
  [[B3 - Build & Testing Notes]] § *ccache keys*, not a fix. **Trigger:** more than one open
  PR per master merge becomes normal, or a sanitizer leg's cold build gets slow enough to
  notice.

- #prio/medium · **Make sanitizer workflow edits testable in hosted CI**: PR #93
  changed the Linux TSan test step but received only docs-only stand-in checks.
  A manual `workflow_dispatch` on `master` cannot validate it because `sanitizers`
  runs only for `pull_request`. The local WSL TSan suite passed, but the hosted leg
  remains unverified. Find a targeted validation path that preserves the normal
  PR-only sanitizer cost. **Trigger:** before the next sanitizer workflow edit;
  inspect the next code PR's Linux TSan result for #93's first hosted evidence.
- #prio/low · **`delete_branch_on_merge` is off**: [[ADR-009 - Branching strategy & merge rules]]
  §1 says topic branches are deleted after merge, and the repo setting does not enforce it, so
  merged branches accumulate by hand. **Trigger:** the next settings pass, or the first time a
  stale branch is mistaken for live work.
- #prio/medium · **Assert the private-plumbing gates still match something**: `ci.yml`'s
  `check()` greps literals, so a rename empties the pattern and the gate passes on an empty
  search instead of failing (S4-T2). **Trigger:** a third gate, or the next rename that
  crosses one of the existing patterns.
- #prio/low · **`.gitattributes` for committed test assets**: a repo-committed text asset gets
  CRLF on a Windows checkout, so the day a case asserts on such a file's *contents* the two CI
  legs disagree. Scratch-directory assets are written by the test and are unaffected.
  **The witness this was written against is gone:** #65 deleted `engine/app/assets/demo.txt`,
  and the tree now carries no committed data asset of any kind, so the entry is entirely
  prospective and further from firing than when it was filed.
  **Trigger:** the first test that reads a committed asset rather than a scratch one.
- #prio/low · **Reconcile ADR-017's `main()` clause**: each executable defines `main()`
  and calls `runApp<AppType>()`; ADR-017 § *Decision* 3 instead places `main()` in a shared
  header. [[Project - Design]] § *Entry point and presentation boundary* records the
  divergence. **Trigger:** the next ADR-017 decision amendment.

- #prio/high · **Memory-management design note**: the engine-wide map (lifetime tiers,
  per-module memory, handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- #prio/medium · **Point later dependency allocator hooks at the profiler**: Jolt
  (`JPH::Allocate`/`Free`/aligned + `JPH_OVERRIDE_NEW_DELETE`) and miniaudio
  (`ma_allocation_callbacks`) remain under [[ADR-013 - Profiler (Tracy-backed instrumentation)]]
  §7. GLFW's fired hook is S7-T2. **Trigger:** the first init of Jolt or miniaudio.
- #prio/low · **README at repo root** (public-facing). **Trigger:** T2, the first build that
  runs outside the editor.
- #prio/xlow · **Command `/catch-up`**: session re-entry after a multi-day gap. **Trigger:**
  the first session that opens with "where was I".
- #prio/low · **The vault does not record #112's CI install change, and the CI cost figure predates it**:
  #112 (`8c32ea7b`, Oct 1) replaced the three `apt-get update` plus `apt-get install` steps in
  `ci.yml` with the third-party `awalsh128/cache-apt-pkgs-action@v1`, and it swapped `xorg-dev`
  for an explicit list of X11 packages. [[B3 - Build & Testing Notes]] has no line on either
  change, and no note says whether a third-party action should be pinned by tag or by sha. The
  16.1 billed minutes per code PR (measured on #52 and recorded in B3) also predates #110 and #112,
  and [[Autonomous Lane - Design]] § *Cost model* still prices the lane with it. Found by the
  freshness check in [[2026-10-06 09-09 Auto Run]]. **Trigger:** the next `/weekly-review`, or
  the next change to the lane's PR cap.

## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
