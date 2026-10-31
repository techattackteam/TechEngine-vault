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
- #prio/medium · **Code sweep leftovers: base**: Found by the code sweep on Oct 29, 2026
  ([[2026-10-29 14-40 Auto Run]]), and carried from the Oct 8 sweep, which folded in two Sep 28 entries.
  - The version anchors: `baseVersion()` (`engine/base/include/TechEngine/base/Base.hpp:4`),
    `platformVersion()` (`engine/platform/src/Platform.cpp:7`) and `coreVersion()`
    (`engine/core/src/Core.cpp:8`) are the S1 link-order stubs, and nothing calls
    `coreVersion()`. Delete them, `Base.hpp`, `Base.cpp` and `BaseTests.cpp`, whose glm case
    repeats `MathTests.cpp`. About 35 lines. A test covers `baseVersion()`, so it is not dead.
  - The log-capture guards: `SinkGuard` (`engine/base/tests/diagnostics/LogTests.cpp:50`),
    `LogCaptureGuard` (`engine/base/tests/diagnostics/AssertTests.cpp:66`) and
    `GraphLogCaptureGuard` (`engine/core/tests/systems/TaskGraphTests.cpp:140`), and since
    S8-T10 `CacheLogCaptureGuard` (`engine/core/tests/resources/ResourceCacheTests.cpp:175`,
    added by the core sweep on Oct 20). S9-T1 added two more: `RuntimeLogCaptureGuard`
    (`apps/runtime/tests/RuntimeAppTests.cpp:454`) and `SceneLoadLogCaptureGuard`
    (`engine/core/tests/scene/SceneAssetTests.cpp:548`), each with its own id-matching helper. Use one
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

- #prio/low · **Code sweep leftovers: platform**: Found by the code sweep on Oct 30, 2026
  ([[2026-10-30 14-53 Auto Run]]), and carried from the Oct 9 sweep.
  - The four input event builders are copied in `engine/platform/tests/input/InputStateTests.cpp:17`
    and `engine/platform/tests/input/InputBufferTests.cpp:16`. Sharing them needs a new test
    header. About 16 lines.
  - `InputState::apply` repeats its press and release logic for keys and buttons
    (`engine/platform/src/input/InputState.cpp:8`). A helper would be a template over the bitset
    size in a public header. About 8 lines.
  - `FileAccess::list` splits the virtual path before `resolveExisting` splits it again
    (`engine/platform/src/files/FileAccess.cpp:189`). About 2 lines.

- #prio/medium · **Restore a read-only FileAccess boundary**: `copy`, `move` and
  `rename` are `const` but write to disk. [[File Access - Design]] § *Open questions*
  records the options. **Trigger:** the SDK boundary or the next FileAccess API edit.
  **Fired Oct 11:** S8-T1 (#126) added `FileAccess::readRange`. The three calls are still
  `const`, and the note's *Open questions* still records the options. **Re-armed Oct 24:** not
  picked for Sprint 09, which edits no `FileAccess` signature; the trigger is now the SDK
  boundary (A1) or the next signature change.

## core

- #prio/medium · **Classify the failures behind Scene's and `Transform`'s `bool` mutators**:
  `setParent`, `unparent`, `reorderChild`, `destroyEntity`, `fromLocalToWorld`,
  `fromWorldToLocal`, `setLocal`, `setWorld`, and since S9-T17 `addComponentRaw` and
  `removeComponentRaw`, are the known exception to
  [[ADR-023 - Public error handling]]. One `false` covers a dead entity, a cycle, a position out
  of range, a singular transform and corrupt sibling links. Each reason needs its lane (assert or
  `std::error_code`) before a `SceneError` can exist. **Trigger:** the first caller that has to
  tell two of those reasons apart, likely the editor's hierarchy panel.

- #prio/medium · **Root entities have no order**: `Scene::getRoots()` returns roots in archetype
  storage order (`engine/core/src/scene/Scene.cpp:238` at `5c57bf8`), and removal swap-erases.
  So destroying a root moves another root into its place, and a root that changes archetype
  (adding a component, from S9-T17) moves to another position. Roots have no sibling list, so
  the hierarchy panel cannot keep a drop between two roots, and S9-T16 offers no root reorder. A
  saved scene writes its roots in the same order. Found at S9-T16's `/card-start` on Oct 29,
  2026. **Trigger:** roots visibly jumping in the hierarchy, or the first feature that needs a
  root order, such as reordering roots by drag.

- #prio/medium · **Resources: hot-reload**: decided in shape by [[ADR-024 - Resources (64-bit ids, value handles, async loads)]] §9: a reload swaps
  data behind a live handle in a loading phase, with no generation bump, and fenced readers
  treat it as a free. Eviction stays explicit release only. **Trigger:** file watching
  ([[Backlog]] → `platform`) and an editor workflow that needs it.

- #prio/medium · **A scene load does not notice a reference that was already Failed**: the
  load's loading phase reports only the errors it drains, so a dependency that failed before
  this load and is still held elsewhere produces no error, and its handle is filled with a
  Failed entry. It cannot happen at startup, where the cache starts empty. Found while pairing
  on S9-T3, Oct 25. **Trigger:** T1's scene reload, or any second scene load in one process.

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
  S7-T6's review, Sep 27. **Trigger:** P1's parallel executor, where an undeclared publisher
  becomes a race. Its first trigger (S7-T4's surface, #99) fired on Sep 27, and Sprint 08's
  planning re-triggered it on Oct 11 because no M6 card needs it.

- #prio/medium · **Should `SerialExecutor` borrow the graph instead of copying it?**: its
  constructor copies each `TaskGraphNode`'s access mask and system pointer into its own node,
  then drops the graph (`engine/core/src/systems/SerialExecutor.cpp:29`). Only per-node runtime
  state, such as the command buffer, has to live in the executor; the parallel executor needs
  that split, but not the copy. Borrowing a `const TaskGraph*`, as it already borrows systems
  from the schedule, would remove the duplicate `ScheduleAccess` and handler copies. Analyse
  the options, including the executor-before-graph lifetime in `App` and the tests, and
  implement the better one if borrowing wins. Found at S7-T4, Sep 27. **Trigger:** the parallel
  executor at P1. S7-T7's dispatch (#100) fired the first trigger on Sep 27; Sprint 08's
  planning re-triggered it on Oct 11 because no M6 card needs it.

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
  **Fired Oct 11:** S8-T3 (#127) changed `registerComponent`'s body to fill the serialization
  adapters, and it still takes the tag as an argument
  (`engine/core/include/TechEngine/core/scene/ComponentRegistry.hpp:45`). **Re-armed Oct 24:**
  not picked for Sprint 09; the trigger is now the next change to `registerComponent`'s
  signature.

- #prio/low · **Intra-system chunking for heavy systems**: parallelize a system's entity
  iteration without changing whole-system graph semantics. **Trigger:** profiling after the
  parallel executor shows one system node dominates a tick.

- #prio/medium · **Code sweep leftovers: core**: Found by the code sweep on Oct 20, 2026
  ([[2026-10-20 15-09 Auto Run]]). #149 fixed nine findings; these need a decision, a new
  header, or cost about as much as they save. It folds in the two Oct 1 entries #149 did not fix.
  - `Scene::unparent` (`engine/core/src/scene/Scene.cpp:417-455`) repeats `setParent`'s
    old-link validation and unlink (`:301-317`, `:356-368`). One private member would serve
    both, about 20 lines, but `setParent` validates the destination between the two halves,
    so the split is a choice. S8-T3 grew both copies with the last-child link.
  - `ArchetypeStorage`'s typed `addComponent<T>` and `removeComponent<T>`
    (`engine/core/src/scene/ArchetypeStorage.hpp:56-90`) exist only for tests and repeat the
    type-erased path; `ComponentStorage<T>::set` (`ComponentStorage.hpp:101`) goes with them.
    About 30 lines, but the scene tests call them about 85 times.
  - `ArchetypeStorage::component<T>`'s const and non-const bodies are identical
    (`engine/core/src/scene/ArchetypeStorage.hpp:96-114`). The `std::as_const` forward that
    #149 gave `componentRaw` removes about 8 lines.
  - `ArchetypeStorage::addEdge` and `removeEdge` (`engine/core/src/scene/ArchetypeStorage.cpp:203-225`)
    differ only in the transition map and the signature edit. About 8 lines.
  - `Scene::fromWorldToLocal` (`Scene.cpp:183-187`) and `setParent(…, ReparentMode)`
    (`:403-409`) repeat the determinant check and the inverse-and-decompose. About 5 lines.
  - `ArchetypeStorage::eachEntity` (`ArchetypeStorage.hpp:129-141`) hand-writes what
    `Query`'s `IterationGuard` (`Query.hpp:66`) does. Sharing it puts a new `internal::` symbol
    in a public header. About 6 lines.
  - `EntitySlots::destroy` (`engine/core/src/scene/EntitySlots.cpp:26`) repeats `contains()`'s
    condition, and `clear()` (`:63`) repeats its retire-or-bump step. About 6 lines.
  - Three identical global-state guards: `SceneEventStateGuard` (`engine/core/tests/scene/SceneEventTests.cpp:63`),
    `InputDeliveryStateGuard` (`engine/core/tests/systems/InputDeliveryTests.cpp:50`) and
    `ExecutorStateGuard` (`engine/core/tests/systems/SerialExecutorTests.cpp:43`). One template
    guard needs a new test header, about 30 lines. Moving the state and guard into
    `InputDeliveryFixture` saves about 38 more across its 19 cases.
  - `HierarchyTests` and `TransformTests` repeat the registry, built-in registration and
    `Scene` setup about 33 times. A `SceneFixture` beside `registerBuiltInSceneComponents` in
    `tests/scene/SceneTestRegistry.hpp` saves about 60 lines.
  - The pack tests copy one scratch fixture (`engine/core/tests/resources/PackTests.cpp:68`,
    `engine/core/tests/assets/PackSourceTests.cpp:58`), `viewOf` and `bytesOf`, and `patch<T>`
    (`PackTests.cpp:123`, `BootRecordTests.cpp:105`). One test header, about 30 lines.

- #prio/low · **[[Scene - Design]] still names two built-in components**: § *Built-in
  hierarchy* says every entity carries `Hierarchy` and `Transform`, and that Scene tests register
  "both built-ins" (`Scene - Design.md:148`, `:176-178`). S9-T15 (#167, `9a33c49`) made `Name` a
  third member of the set `ArchetypeStorage::createEntity` gives every entity, and `Scene`
  refuses to add or remove it. Only [[Editor - Design]] § *Entity names* records that. Found by
  the vault freshness check, Oct 29 ([[2026-10-29 09-08 Auto Run]]). **Trigger:** the Oct 31
  weekly review's drift check, or the next card that edits [[Scene - Design]].

## client

- #prio/low · **No test can make the render thread fail**: `Client` has no way to fail on
  purpose, so `ClientApp`'s failure handling has no test. That covers the stop it requests from
  the render thread, the stop in `mainThreadUpdate()` when `failed()` is set, and the throw in
  `shutdown()` (`apps/clientapp/src/ClientApp.cpp:16-18`, `:52-54`, `:67-69`, S8-T19, #151).
  They were untested before the move too. **Trigger:** the next change to how `Client` reports
  a render failure, or to `ClientApp`'s handling of it.
- #prio/high · **Paper reports before R1's two ADRs**: the rendering papers validated on
  2026-10-30 ([[Paper]], [[Research]]'s Rendering column) are read by no card, and S9-P2 compares
  engines, not papers. Two report-only research briefs, each mapping its papers onto
  [[Renderer - Brief]] without choosing: culling, draw submission (multi-draw indirect and
  instancing, as v1 did) and hundreds of lights before the frame and device seam ADR, and materials before the materials ADR. **Trigger:** Sprint 10's
  `/sprint-prep` (S9-D5), which places the two ADRs.

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

- #prio/low · **The runtime logs every loaded entity at `INFO`**: after the startup load,
  `RuntimeApp::logSceneTree` writes one `INFO` line per entity (S8-T9, #139). That is useful
  while nothing draws entities, but a real scene would flood the log. Drop the lines to
  `TE_LOGGER_DEBUG` or keep only the summary line. **Trigger:** the first scene with more than a
  handful of entities, or the first card that draws them.

- #prio/low · **[[Game Loop - Frame Flow]]'s diagram predates the editor's loop**: its
  simulation lane always ticks and has no command step, and its two other lanes have no ImGui
  work. Since S9-T12 and S9-T13 (#163, #166), each simulation pass applies the command batch
  first and an app that does not tick waits in `waitForCommands()`
  (`engine/app/src/SimulationThread.cpp:201-230`). Since #162, main builds the editor's ImGui frame
  and render draws it after the scene. [[Simulation Thread - Design]] and [[Editor - Design]]
  are current; only the overview diagram and its prose drifted. Found by the vault freshness
  check, Oct 29 ([[2026-10-29 09-08 Auto Run]]). **Trigger:** the Oct 31 weekly review's drift
  check, or the next card that changes a loop phase.

- #prio/low · **[[Simulation Thread - Design]]'s hook table still lists `publishEdits()`**: since
  S9-T16 (#171) the hook is `publishEdits(const Scene&)`, and `SimulationThread` passes the live
  scene (`engine/app/include/TechEngine/app/App.hpp:115`, `engine/app/src/SimulationThread.cpp:213`).
  The row also misses that `EditorApp` calls it once at the end of its startup load
  (`apps/editor/src/EditorApp.cpp:95`). [[Editor - Design]] has the new signature in its *Decided*
  row; only its § *Commands and the idle simulation* bullet still writes `publishEdits()`. Found by
  the vault freshness check, Oct 30 ([[2026-10-30 09-09 Auto Run]]). **Trigger:** the Oct 31 weekly
  review's drift check, or the next edit to either note.

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

- #prio/xhigh · **Deleting an asset in the editor**: Miguel's wanted behaviour, Oct 26, 2026.
  Before the delete, a warning lists the scenes that use the asset. After it, each reference
  points at its type's default asset. Loading a scene with an asset that is not there warns
  instead of failing. Not decided and not designed. It changes the Decided row "a reference
  that fails to be added or loaded fails the scene load" ([[Resources - Design]]), and it needs
  a default asset per resource type, which does not exist yet. Today a deleted file goes
  unnoticed until the next export (`NotFound`) or launch (the editor opens on an empty scene).
  **Trigger:** the asset browser ([[Editor - Brief]], *Must, demo*).
- #prio/medium · **Local and World modes in the transform inspector**: [[Scene - Design]] §
  *Editor Local / World editing* (agreed Sep 12) asks for both, with a World edit converted to
  local values on the simulation thread through `setWorld`. S9-T17 shows local values only,
  because [[Editor - Design]] never carried that agreement over. Found Oct 30, 2026.
  **Trigger:** E2's transform gizmo (T3, [[Editor - Brief]]), or the next card on the inspector.
- #prio/low · **One rotation edit is four records, and the Euler cache is untested**: the
  inspector sends a rotation as four set-field commands, so an undo would need four steps, and
  `InspectorPanel::syncEuler` holds a small state machine that no test reaches while it is
  private to the panel. A set-rotation command and a class in `edit/` would fix both. Found at
  S9-T17. **Trigger:** the rung after R1 that brings undo ([[Editor - Brief]]).
- #prio/low · **Inspector field hints and a drawer registry**: a generic field has no range,
  speed or display name, and `drawComponent` picks a drawer with an `if` chain on the type. Hints
  would be an optional argument to `visit`'s `field`, which the other archives ignore, so they
  are a [[Serialization - Design]] decision first. Found at S9-T17. **Trigger:** the first
  component with a field that needs a range, or the third custom drawer, likely in R1.
- #prio/high · **Edit an `AssetRef` in the inspector**: split from S9-T17 at its `/card-start`
  on Oct 30, 2026, where the field stayed read-only and shows only the id. It needs a picker
  that offers the `AssetIndex`'s ids of the field's type, and `FieldVisitor::visitAsset` passes
  only the id today, so the visitor must also learn the type. It needs a set-field command
  that adds the id as a dependency of the scene entry (`App::m_sceneHandle`) and fills the
  handle, and a policy for a load that fails inside the batch, which today only warns
  ([[Editor - Design]] § *Open questions*). Until then a `MeshRenderer` added in the editor
  keeps an empty mesh. **Trigger:** S9-T17 merges.
- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).
- #prio/medium · **Project launcher UI**: list, open and create projects inside the
  editor executable. [[Project - Design]] records the placement and open storage choice.
  **Trigger:** T5 packaging ([[Editor - Brief]], 2026-10-25).
- #prio/low · **Reopen the scene the editor had open last.** Per-user state, not
  `project.toml`: the `[export.<target>]` keys change only when a shipped program's first
  scene is chosen ([[Project - Design]] § *The manifest*). Found at S8-T6 on Oct 12, 2026. Its
  storage is [[Project - Design]] § *Open questions*' per-user settings question. **Trigger:**
  the rung after R1 that lets the editor open another scene ([[Editor - Brief]], 2026-10-25).
- #prio/low · **ImGui multi-viewport**: panels dragged out into their own OS windows. Not a
  Must, but wanted later. ADR-027 §1 keeps it off in E1 and leaves the threaded window glue to
  build. Found at S9-D2 on Oct 25, 2026.
- #prio/medium · **The editor scales with the display, in a scalable font**: the editor draws
  ImGui's 13px ProggyClean bitmap font at a scale of 1, so on a Windows display at 150% every
  panel is two thirds of its intended size, and the bitmap font is what makes it look like a
  debug tool. ImGui 1.93 embeds a scalable version of that font (`AddFontDefaultVector()`, no
  file to load), and its GLFW backend reports the window's content scale, which
  `style.ScaleAllSizes()` and `style.FontScaleDpi` take. The scale needs the open window, so it
  runs after `startClient()`, not where S9-T20 applies the theme. A real typeface (Roboto ships
  in imgui's `misc/fonts`) would change the look more, but where its file lives, compiled in or
  read through `FileAccess`, is a decision first. Split from S9-T20 at its `/card-start` on
  Oct 31, 2026. **Trigger:** the first recording of the editor for a showcase.
- #prio/low · **Two review nits that #174 shipped**: restore the deleted comment
  "contains(), not valid(): a selection whose entity died would otherwise offer every type to
  add." in `EditSession::collectComponents`; and put `<ui/PanelsManager.hpp>` first in
  `PanelsManager.cpp`, which clang-format does not catch because the paired header sits under
  `ui/`. Found by S9-T18's `/card-review` on Oct 31, 2026. **Trigger:** the next card that
  touches either file, or the editor's code sweep. **Fired by S9-T19 (#175)**, which touched
  `PanelsManager.cpp` and fixed only the third nit, the comment in
  `EditorApp::handleCloseRequest`.

## etc: cross-cutting

- #prio/medium · **The million cubes as an end-to-end benchmark**: Miguel's ask, Oct 30, 2026.
  [[Renderer - Brief]]'s Should of a million cubes moving on a grid at 60 fps (v1 reached 20)
  exercises one whole frame: a System over the ECS, the task graph's executor, transform
  propagation, the snapshot to the render thread, and instanced drawing. Kept as a repeatable
  scene with its frame time recorded, it is a candidate first case for the perf tier in *Test
  tiers and parallel ctest* below. One System that moves every cube is one node on one level,
  so P1's parallel executor alone does not speed it up. **Trigger:** R1's first card that
  draws instanced meshes.
- #prio/low · **Log lines that mention an entity print its name**: Miguel's ask, Oct 26, 2026.
  Once entities have names (S9-T15), a warning or error about an entity should print its name
  beside `index:generation`, not the index alone. S9-T15 covers only the runtime's scene log,
  which [[Editor - Brief]] makes a Must. Today one other line mentions an entity, without naming
  it: `engine/core/src/scene/SceneAssetRowWriter.cpp:14`. **Trigger:** S9-T15 merges, then the
  next card that adds or edits a log line about an entity. **Fired by S9-T16 (#171)**: its
  hierarchy commands warn about entities through the new `std::formatter<Entity>`, which prints
  `index:generation` only (`apps/editor/src/edit/HierarchyCommands.cpp`).

- #prio/medium · **Diff coverage for ImGui drawing code**: #171 (S9-T16) scored 31% against the
  85% gate, because about 360 of its changed lines are ImGui drawing in `apps/editor/src/ui/`
  that no unit test reaches, so it used `[skip-coverage]`. Each panel card will do the same, and
  the gate's own comment says a weekly bypass teaches nothing. Two ways out: exclude
  `apps/editor/src/ui/` from diff coverage, which is fair only while `ui/` holds drawing alone
  (S9-T16 moved its logic to `edit/`), or run ImGui headless in the tests. Found Oct 29, 2026.
  **Trigger:** the next panel card's PR, S9-T17 or S9-T19. **Fired by S9-T17 (#173)**, and
  S9-T18 (#174) and S9-T19 (#175) used `[skip-coverage]` a third and a fourth time.

- #prio/low · **Two comments still name the old SDK smoke target**: `sdk/CMakeLists.txt:9` and
  `.github/workflows/ci.yml:79` say `te_sdk_smoke`, while the target is `TechEngineSDKSmoke`
  (ctest `sdk-smoke`). The Markdown copies were fixed in #153. Found at S8-P11's close, Oct 23.
  **Trigger:** the next card that edits either file.
- #prio/medium · **A workflow file that does not parse can still merge**: #95 broke
  `ci-docs.yml`'s YAML (fixed by S7-P9, #104). A run that fails to parse reports under the
  file's path, which is not a required context, and #95 also touched code, so `ci.yml`
  reported the nine required contexts and the merge went through. Nothing checks that a
  workflow file parses before it lands. Found at S7-P9's close on Sep 28, 2026.
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
  Oct 1, 2026. **Trigger:** the next drift check with engine commits to check (the Oct 11
  boundary had none).
  **Fired Oct 18:** the weekly review's drift check ran it against `39943f19` with
  `--exclude` for `07 Journal`, `05 Research`, `09 References` and [[v1 Code Audit]]. It reported
  67 of 237 citations, and every one was a v1 path or a card's historical `done:` clause, so
  those four excludes are not enough to make it a gate yet. **Re-armed Oct 24:** not picked for
  Sprint 09; the trigger is now an exclude for historical card text, or the next full
  reconciliation.
- #prio/medium · **A `TE_ENSURE` case passes under `ctest` and fails when the test exe is run
  directly**: report-once is per call site through a function-local static (ADR-011 §5), and
  `catch_discover_tests` hides that by giving every Catch2 case its own process. Two
  `EventRegistryTests` cases hit the duplicate-tag site, and S5-T2 dropped the fire count from
  the second rather than leave the trap armed. That is a patch, not a fix: the next suite that
  asserts a fire twice through one site inherits the same split behaviour, and it will look
  like a flake. Options are a test-only reset hook on the report-once static, or a rule that a
  fire count is asserted at exactly one case per site. **Trigger:** the next card that adds a
  `TE_ENSURE` case, or the first developer confused by a green `ctest` and a red exe.
- #prio/medium · **Test tiers and parallel ctest**: S8-D3 started as this decision and was
  rescoped on Oct 19 to the PR wall-time fix, because builds, not tests, set that time. Still
  open: which tiers exist, how a case is tagged into one, where each runs, and whether any tier
  shares a process. Already answered by Miguel at S8-D3's `/card-start`: the real-disk tests
  (`[files]`, `[fileaccess]`, `[mounttable]` and the rest that use `ScratchDirectory`) are the
  OS tier, not unit; and the repository is public now but will go private, so the plan must
  hold under a minute budget. Proposed and not decided: tiers are Catch2 tags turned into CTest
  labels (`catch_discover_tests(... ADD_TAGS_AS_LABELS)`, which the pinned Catch2 supports),
  legs exclude by label so a forgotten tag runs more rather than less, every case keeps its own
  process (so the `TE_ENSURE` entry above needs no reset hook), test presets set
  `execution.jobs`, and `[stress]` leaves the sanitizer legs. Functional, visual and perf get a
  shape and a trigger, not wiring. Evidence, measured Oct 11, 2026, with existing Windows
  binaries:
  - A test body takes about 0 ms. A process start costs 49 ms in `windows` Debug and 553 ms in
    `windows-profile`, where Tracy sleeps 200 ms to calibrate its timer before `main`.
  - Each `[window]` case costs about 450 ms in its own process, because the first OpenGL context
    loads the driver. The 13 cases take 1.6 s in one process and 3.5 s in separate processes.
  - The two `... does not depend on recursion depth` cases (`HierarchyTests`, `TransformTests`)
    take 6 s each in Debug. They build a 4096-deep chain top-down, and `setParent`'s cycle check
    makes that quadratic.
  - On CI (run 38367963268, Oct 13, 2026), `win ASan`'s test step is 173 s for 621 cases,
    against 13-45 s on every other leg: about 89 s of process startup, 61 s of window and GL
    cases and 21 s for the two recursion-depth cases. Its cap is `timeout-minutes: 5`.
  - No test preset sets `execution.jobs`, so `ctest` runs one case at a time on 4-core runners.
    Every `ScratchDirectory` name is unique today (checked by grep only), which parallel runs
    need.
  - Three `EditorAppTests` cases are tagged only `[editor]` (project mounts, asset index, the
    `assets/client` overlay), but `bootstrap()` opens a window, so a split by tag would leave
    them in the unit tier.

  **Trigger:** the repository goes private, or `win ASan`'s test step passes 4 minutes.

- #prio/low · **`delete_branch_on_merge` is off**: [[ADR-009 - Branching strategy & merge rules]]
  §1 says topic branches are deleted after merge, and the repo setting does not enforce it, so
  merged branches accumulate by hand. **Trigger:** the next settings pass, or the first time a
  stale branch is mistaken for live work.
- #prio/medium · **Assert the private-plumbing gates still match something**: `ci.yml`'s
  `check()` greps literals, so a rename empties the pattern and the gate passes on an empty
  search instead of failing (S4-T2). **Trigger:** a third gate, or the next rename that
  crosses one of the existing patterns.
  **Fired Oct 18:** S8-T10 (#141) added a third `check` to `ci.yml`, for
  `internal::g_(componentTypeSlot|resourceTypeTag)` under `engine/core/include/`. **Re-armed
  Oct 24:** not picked for Sprint 09; the trigger is now a fourth gate, or the next rename that
  crosses a pattern.
- #prio/low · **Reconcile ADR-017's `main()` clause**: each executable defines `main()`
  and calls `runApp<AppType>()`; ADR-017 § *Decision* 3 instead places `main()` in a shared
  header. [[Project - Design]] § *Entry point and presentation boundary* records the
  divergence. **Trigger:** the next ADR-017 decision amendment.

- #prio/low · **clang-tidy is never cached on the `linux-clang` legs**: with 99.76% ccache hits,
  `linux-clang Debug` and `Release` still build for 91-142 s (#148, Oct 19), because clang-tidy
  runs on every first-party TU and ccache does not cache it. Off the critical path since S8-D3:
  a PR's slowest leg is `win ASan`'s test step (203 s). The other causes of slow CI were fixed
  by S8-T21 (#143) and S8-D3 (#147) ([[B3 - Build & Testing Notes]] § *Four legs start every
  PR cold*). Found while measuring the test step for S8-D3's evidence, Oct 13, 2026.
  **Trigger:** a linux-clang leg becomes the PR's slowest leg.
- #prio/high · **Memory-management design note**: the engine-wide map (lifetime tiers,
  per-module memory, handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- #prio/medium · **Point later dependency allocator hooks at the profiler**: Jolt
  (`JPH::Allocate`/`Free`/aligned + `JPH_OVERRIDE_NEW_DELETE`) and miniaudio
  (`ma_allocation_callbacks`) remain under [[ADR-013 - Profiler (Tracy-backed instrumentation)]]
  §7. GLFW's hook shipped in S7-T2 (#121); each new hook needs its own pool constant
  ([[Profiler - Design]] § *Memory pools*). **Trigger:** the first init of Jolt or miniaudio.
- #prio/low · **README at repo root** (public-facing). **Trigger:** T2, the first build that
  runs outside the editor.
- #prio/xlow · **Command `/catch-up`**: session re-entry after a multi-day gap. **Trigger:**
  the first session that opens with "where was I".
- #prio/low · **A comma in a test name stops the IDE from rerunning that test**: Catch2 reads a
  comma in a test filter as "or", so CLion's rerun of one test splits its name into two filters
  that match nothing, and the test silently does not run. 59 `TEST_CASE` names on `master` had a
  comma on Oct 26. Rename them, and decide whether `CONVENTIONS.md` § *Unit tests* bans the
  comma. Found in S9-T12, where it made a deterministic failure look like a race. **Trigger:**
  the next test that seems to pass and fail with no code change, or the next sweep of a test file.
## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
