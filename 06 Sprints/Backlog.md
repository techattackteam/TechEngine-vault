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
- #prio/low · **The crash path needs a ring read that does not allocate**: since S10-T11,
  `ringSnapshot` appends `StoredLogRecord`s, so it allocates a string per record, and a crash
  handler cannot rely on the heap. [[Logger - Design]] still says the crash path flushes the
  ring. Found at S10-T11's close, Nov 5. **Trigger:** the platform crash handler is built.

- #prio/low · **Code sweep leftovers: base**: Found by the code sweep on Nov 11, 2026
  ([[2026-11-11 14-10 Auto Run]]); the first two bullets came from the `core` sweep on Nov 4
  ([[2026-11-04 14-12 Auto Run]]) and the `apps` sweep on Nov 10.
  - The boost hash-combine formula (`0x9e3779b9 + (seed << 6) + (seed >> 2)`) is written twice:
    `engine/core/include/TechEngine/core/scene/Entity.hpp:31` and
    `engine/core/src/scene/ArchetypeStorage.cpp:165`. A `hashCombine` in `base` would serve both.
    It is a new public symbol, and saves about 2 lines.
  - Added by the `apps` sweep on Nov 10 ([[2026-11-10 14-12 Auto Run]]). The console names a log level and formats a
    record's time by hand (`apps/editor/src/ui/panels/ConsolePanel.cpp:26`, `:171`), as `base`
    does privately (`engine/base/src/diagnostics/Log.cpp:119`, `:398`). The `localTime` copy is the
    editor's entry "The console repeats `Log.cpp`'s `localTime`". About 25 lines.
  - `logChannelModule` (`engine/base/include/TechEngine/base/diagnostics/Log.hpp:117`) and
    `assertKindName` (`engine/base/include/TechEngine/base/diagnostics/Assert.hpp:41`) are public,
    but nothing outside their own `.cpp` calls them. Each could be `static` there. Removing a
    used public symbol is your call. About 4 lines.
  - Test-only: `FillerSink` (`engine/base/tests/diagnostics/LogErrorTests.cpp:20`) is the
    no-op sink that `CountingSink` (`engine/base/tests/diagnostics/LogTests.cpp:38`) already is,
    in the same test executable. Sharing it needs a new test header. About 5 lines.

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

- #prio/low · **Code sweep leftovers: platform**: Found by the code sweep on Nov 12, 2026
  ([[2026-11-12 14-09 Auto Run]]), and carried from the Oct 9 and Oct 30 sweeps.
  - The four input event builders are copied in `engine/platform/tests/input/InputStateTests.cpp:17`
    and `engine/platform/tests/input/InputBufferTests.cpp:16`. Sharing them needs a new test
    header. About 16 lines.
  - `InputState::apply` repeats its press and release logic for keys and buttons
    (`engine/platform/src/input/InputState.cpp:8`). A helper would be a template over the bitset
    size in a public header. About 8 lines.
  - `FileAccess::list` splits the virtual path before `resolveExisting` splits it again
    (`engine/platform/src/files/FileAccess.cpp:189`). About 2 lines.
  - Added by the `apps` sweep on Nov 10 ([[2026-11-10 14-12 Auto Run]]). The editor converts between text and
    `FileAccess`'s bytes by hand (`apps/editor/src/project/Project.cpp:69`, `:125`;
    `apps/editor/src/EditorApp.cpp:271`, `:285`), and treats `AlreadyExists` after
    `createDirectory` and `NotFound` after `remove` as success (`Project.cpp:225`, `:237`, `:254`,
    `:311`; `EditorApp.cpp:280`). Text and idempotent calls in `FileAccess` would serve them.
    These are new public symbols. About 10 lines.
  - `InputState::capturedAt` is written by `apply` (`engine/platform/src/input/InputState.cpp:6`)
    and read nowhere, tests included. `InputEvent::capturedAt` is the one that is read. Deleting
    the field drops the age of the presentation copy, which a renderer may want. About 2 lines.

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
  (`engine/core/include/TechEngine/core/scene/ComponentRegistry.hpp:51` at `e59d77c`). **Re-armed Oct 24:**
  not picked for Sprint 09; the trigger is now the next change to `registerComponent`'s
  signature.

- #prio/low · **Intra-system chunking for heavy systems**: parallelize a system's entity
  iteration without changing whole-system graph semantics. **Trigger:** profiling after the
  parallel executor shows one system node dominates a tick.

- #prio/medium · **Code sweep leftovers: core**: Found by the code sweep on Nov 4, 2026
  ([[2026-11-04 14-12 Auto Run]]), and carried from Oct 20 ([[2026-10-20 15-09 Auto Run]]).
  The `engine/app` sweep on Nov 6 added the built-in registration line ([[2026-11-06 14-07 Auto Run]]).
  #149 and #184 fixed what needed no decision; these need a decision, a new header or a new
  public symbol, or cost about as much as they save. The Oct 20 line numbers were not re-checked on Nov 4.
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
  - Registering the three built-in components (`Hierarchy`, `Transform`, `Name`) is written by
    hand outside `core`: `engine/app/src/App.cpp:124-132` (only when missing),
    `engine/app/tests/SimulationThreadTests.cpp:96`, `apps/editor/tests/edit/EditTestScene.hpp:95`,
    `apps/editor/tests/project/ProjectTests.cpp:92`, `apps/editor/tests/EditorAppTests.cpp:279`,
    and `apps/runtime/tests/RuntimeAppTests.cpp:395` and `:841`. `core`'s own tests already share
    `registerBuiltInSceneComponents` (`engine/core/tests/scene/SceneTestRegistry.hpp:31`). A
    public `core` function would serve all of them; it is a new public symbol, and saves about 15 lines.
  - The pack tests copy one scratch fixture (`engine/core/tests/resources/PackTests.cpp:68`,
    `engine/core/tests/assets/PackSourceTests.cpp:58`), `viewOf` and `bytesOf`, and `patch<T>`
    (`PackTests.cpp:123`, `BootRecordTests.cpp:105`). One test header, about 30 lines.
  - **Possible hang:** `ResourceCache::runLoadingPhase` loops while any pending entry is still
    `loading` (`engine/core/src/resources/ResourceCache.cpp:284-292`). If `JobSystem::submit`
    refuses a batch after shutdown (`engine/core/src/jobs/JobSystem.cpp:66`), `submitLoads` has
    already marked its entries `loading` (`ResourceCache.cpp:178`) and keeps no batch, so the loop
    never ends. Looping until `m_pendingLoads` is empty removes about 8 lines, but leaves those
    entries Pending, which is a decision. Found by reading, not by a test.
  - `SceneCommandBuffer::Payload` (`engine/core/include/TechEngine/core/scene/SceneCommandBuffer.hpp:37`)
    hand-rolls the aligned, type-erased value that `IComponentStorage` already provides, as
    `Scene::addComponentRaw` uses it. About 70 lines, at the cost of a vector per command.
  - `ReferenceVisitor`'s two pure virtuals (`engine/core/include/TechEngine/core/serialization/ReferenceVisitor.hpp:20`)
    force an empty override in each of the four `SceneAsset*` visitors. Empty default bodies
    remove about 16 lines and change a public interface.
  - The built-in exclusion `!same_as<…Hierarchy>` and friends is spelled out in `Scene.hpp:85`,
    `:98`, `:104`, `:114`, `Query.hpp:57`, `Schedule.hpp:57` and `ScheduleRegistration.hpp:48`. A
    `UserComponent` concept is a new public symbol; it saves about 4 lines and keeps the
    spellings in sync.
  - `SerialExecutor` rebuilds every input notification for each node, in three loops
    (`engine/core/src/systems/SerialExecutor.cpp:129-147`). One per-Tick list and one loop, about 8 lines.
  - `Scene::validateRead` and `validateWrite` differ only in `reads`/`writes` and the message
    (`engine/core/src/scene/Scene.cpp:584-598`). Merging them needs a flag argument at five call
    sites, about 6 lines.
  - `Writer::write(std::string_view)` (`Writer.cpp:59`) repeats `writeSpan<char>`, and
    `Reader::read(std::string&)` (`Reader.cpp:91`) repeats `readSpan`. About 14 lines; the
    `TE_ENSURE` text changes.
  - `PackWriter::add` scans for duplicates and `write` copies and sorts (`PackWriter.cpp:17`, `:32`).
    Inserting at `lower_bound` removes both, about 9 lines.
  - `ResourceCache::freeEntry` repeats the null and `acquires` check its only caller just made
    (`ResourceCache.cpp:319`). About 4 lines.
  - `Schedule::getEntryByType` returns its map by value (`Schedule.hpp:66`), and
    `checkedEntry` bounds-checks twice (`Schedule.cpp:78-79`). `JobSystem`'s worker lambda names a
    `stopToken` it never uses (`JobSystem.cpp:31`), which warns on every build. About 2 lines.
  - Test setup: the in-memory `AssetSource` and cache harness is copied in `MeshTests.cpp:66`,
    `SceneAssetTests.cpp:358` and `ResourceCacheTests.cpp:217` (a new test header, about 40 lines).
    `BootRecordTests.cpp:111`'s `requireSameRecord` is repeated by hand in `PackTests.cpp:312`
    (a defaulted `operator==` on the boot record types, about 28 lines).
  - Test setup inside one file: `ArchetypeTests`, `ArchetypeStorageTests` and `QueryTests` repeat
    the registry and `ArchetypeStorage` setup in about 27 cases (a fixture per file, 60-80 lines;
    the local components differ per case). `DedicatedThreadTests` repeats its gated entry lambda six
    times (about 12 lines) and `EventStreamManagerTests` its two-type registry four times (about 9).

- #prio/medium · **`Scene` has no tree-order walk, so every caller writes its own**: four walks
  call `getChildren`, which builds a new vector for each node. Two are depth-first and track the
  depth: `EditSession::buildSnapshot` (`apps/editor/src/edit/EditSession.cpp:74`) and
  `RuntimeApp::logSceneTree` (`apps/runtime/src/RuntimeApp.cpp:100`). Two are breadth-first:
  `SceneAsset::write` (`engine/core/src/scene/SceneAsset.cpp:33`) and
  `SceneAsset::visitReferences` (`:300`). A walk inside `Scene` could follow the `Hierarchy`
  sibling links and allocate nothing. **Decide with it whether `SceneAsset::write` moves to
  depth-first**, so that all four share one order and as much of the same logic as possible.
  Its order is the row order on disk, so the change alters the bytes a save writes. The reader
  only requires a parent's row to come before its children's (`SceneAsset.cpp:137`), and a
  depth-first walk keeps that. Found while pairing on S10-T1, Nov 1. Since S10-B2 (#197, Nov 10)
  the roots are a sibling list too, so the walk can start at the first root and allocate
  nothing; S10-B2 left the walk out on purpose. S10-T18 (#199, Nov 10) added a fifth, breadth-first:
  the whole-scene `rebuildMaterialSlots` (`apps/editor/src/edit/MaterialSlotRebuild.cpp:54`), so
  the first trigger has fired. **Trigger:** a sixth hand-written walk, the next card that changes
  one of the five, or Miguel scheduling it now.

## client

- #prio/high · **CI's software GL cannot run R1's GL floor**: ADR-028 §2 requires GL 4.6 and
  `ARB_bindless_texture` with no fallback. Both CI legs draw with Mesa's `llvmpipe`
  (`.github/workflows/ci.yml:158`, `:211-212`), and on Mesa 25.2.8 it gives at most GL 4.5 core
  and no bindless (measured with `glxinfo` on Nov 9). The render thread starts only when its GL
  check passes (`engine/client/src/render/RenderThread.cpp:93`), so raising that check fails the
  window and render tests on every leg. Zink over lavapipe would not start under Xvfb in the
  lane's sandbox, so it is unproven. ADR-028 § *Consequences* does not mention CI. Found by S10-P2
  ([[2026-11-09 14-12 Auto Run]]). **Trigger:** R1's first card that raises the GL check, or
  S10-D6's cut of R1.
- #prio/low · **No test can make the render thread fail**: `Client` has no way to fail on
  purpose, so `ClientApp`'s failure handling has no test. That covers the stop it requests from
  the render thread, the stop in `mainThreadUpdate()` when `failed()` is set, and the throw in
  `shutdown()` (`apps/clientapp/src/ClientApp.cpp:16-18`, `:52-54`, `:67-69`, S8-T19, #151).
  They were untested before the move too. **Trigger:** the next change to how `Client` reports
  a render failure, or to `ClientApp`'s handling of it.

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

- #prio/medium · **An adopted `Startup.tescene` opens empty and cannot be saved**: when the
  startup load adopts an existing, indexed `Startup.tescene`, it points `project.toml` at it but
  does not load it, so that launch shows an empty scene and refuses every save; the next launch
  loads it. Since S10-B4 (#204, Nov 14) a manifest that names a scene no file holds reaches this
  too, not only a manifest with no scene. The fix is to load the adopted file, as a created one is
  ([[Editor - Design]] § *Decided*, "A created startup scene is loaded back"). Found at S10-B4's
  build, Nov 14. **Trigger:** the next card on the startup load, or a missing startup scene seen
  in use.
- #prio/low · **An unindexed `Startup.tescene` stops the editor at startup**: when the startup
  load must create `Startup.tescene` and a file of that name exists but the asset index skipped
  it, `EditorApp::requireNewAssetPath` stops the editor through `TE_CHECK` instead of logging.
  Since S10-B4 (#204, Nov 14) a manifest that names a scene no file holds reaches this as well;
  only the no-scene case has a test. Found at S10-B4's build, Nov 14. **Trigger:** the next card
  on the startup load.
- #prio/low · **The hierarchy panel cannot reorder roots**: a drop between two roots draws no
  highlight, and a drop to the root always lands last. Since S10-B2 (#197, Nov 10) `Scene` can do
  both: `reorderChild` accepts a root, and `unparent(child, position, mode)` puts a child at a
  position among the roots. What is missing is `EditorSnapshot::resolveDrop` giving a root
  position, and `ReparentEntityCommand` passing it through for a reorder and a move to the root
  ([[Editor - Design]] § *The hierarchy panel*). Miguel kept it out of S10-B2 on Nov 10.
  **Trigger:** Miguel wants to order roots in the editor, or the next card on the hierarchy panel.
- #prio/xhigh · **Deleting an asset in the editor**: Miguel's wanted behaviour, Oct 26, 2026.
  Before the delete, a warning lists the scenes that use the asset. After it, each reference
  points at its type's default asset. Loading a scene with an asset that is not there warns
  instead of failing. Not decided and not designed. It changes the Decided row "a reference
  that fails to be added or loaded fails the scene load" ([[Resources - Design]]), and it needs
  a default asset per resource type, which does not exist yet. Today a deleted file goes
  unnoticed until the next export (`NotFound`) or launch (the editor opens on an empty scene).
  **Trigger:** the asset browser ([[Editor - Brief]], *Must, demo*).
- #prio/high · **Design the asset edit path**: the editor cannot edit a value that lives in an
  asset. Every edit command changes a component on an entity
  (`apps/editor/src/edit/InspectorCommands.hpp:26`, `:47`), and a material's roughness lives in
  its own file, shared by every entity that uses it. Decided by Miguel on Nov 9: each edit is an
  undo step, and the file is written on Save. Still to design: the command and what it changes
  in the cache, how an undo record names an asset, how the editor tracks an unsaved asset and
  which file Save writes, what Play does with an edited asset, and how an edit stays behind
  render's fence (ADR-028 §4). Textures and settings assets will use the same path. Read ADR-024
  and ADR-027 first: if their rules already cover it, this is a section in [[Editor - Design]]
  and not a new ADR. It is a design card, not a build card. Found at S10-D7's `/card-start`
  ([[ADR-029 - Materials, surfaces and lobes]] §7). **Trigger:** the material inspector's card;
  it does not block S10-T18 or S10-D11.
- #prio/low · **The Euler cache is untested**: `InspectorPanel::syncEuler` holds a small state
  machine that no test reaches while it is private to the panel. It waits for the exact
  quaternion it sent in Local mode, and within 1e-4 per component in World mode (S10-T6, #188). Moving it into a class in `edit/` would make it testable. Found at S9-T17;
  the other half of this entry, one rotation edit leaving four records, was fixed by S10-T2's
  set-rotation-axis command (#182). **Trigger:** the rung after R1 that brings undo
  ([[Editor - Brief]]).
- #prio/low · **A `.glb` is read twice at import**: the `extensionsUsed` check reads the whole
  file before assimp reads it again (`ModelImporter::checkGltfExtensions`, S10-T19, #201), while it
  needs only the 20-byte header and the JSON chunk. `FileAccess::readRange` can read just those.
  Nothing is measured. Found while filling S10-T19's stubs. **Trigger:** an import of a large
  `.glb` that is measured to be slow.
- #prio/low · **Clear an `AssetRef` in the inspector**: the asset picker has no None entry,
  because `SetAssetFieldCommand` refuses an id the index does not hold, and an empty id never is.
  Clearing needs its own rule for the empty id (no dependency to add) and a row in
  [[Editor - Design]]. Found at S10-T8. **Trigger:** the first time a reference must be removed
  without removing its component, likely with E2's materials.
- #prio/low · **Inspector field hints and a drawer registry**: a generic field has no range,
  speed or display name, and `drawComponent` picks a drawer with an `if` chain on the type. Hints
  would be an optional argument to `visit`'s `field`, which the other archives ignore, so they
  are a [[Serialization - Design]] decision first. Found at S9-T17. **Trigger:** the first
  component with a field that needs a range, or the third custom drawer, likely in R1.
- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).
- #prio/medium · **The Profiler panel's build**: recording each Play session's tick, render and
  main-frame samples, a file per run under `editorSettings/profiler/`, and the panel that lists
  the runs and graphs the selected one. Designed by S10-D3 on Nov 3, 2026, in [[Editor -
  Design]] § *The Profiler panel*; it opens with how the producers' buffers reach main at Stop.
  About two 🟠 cards. **Trigger:** Play in the editor (E11, [[Editor - Brief]]).
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
- #prio/low · **A folder picker for File → Export**: E1's export always writes to the editor's
  executable folder, because no file-dialog dependency exists ([[Resources - Design]] § *The
  export command*). A picker needs a new dependency or per-OS dialog code in `platform`, and the
  chosen folder needs a home in the per-user settings ([[Project - Design]] § *Open questions*).
  Folder reuse makes a picked folder riskier than the fixed one, since the export replaces files
  in it. Found at S10-D1 on Nov 2, 2026. **Trigger:** T5's distributable, or the first export a
  user wants somewhere other than `bin/`.
- #prio/low · **clang-format puts a subfolder's paired header in the private group**: the #174
  nit asked for `<ui/PanelsManager.hpp>` first in `PanelsManager.cpp`, as `CONVENTIONS.md`
  § *Includes* says, but clang-format 19.1.5 (the CI pin) moves it back among `<edit/…>` and
  `<ui/…>`, so the format gate fails. Every `apps/editor` file with a paired header under a
  subfolder has the same order (`SaveSceneCommand.cpp`, `ExportCommand.cpp`). Either
  `.clang-format`'s main-include detection learns these paths, or `CONVENTIONS.md` accepts
  the order. Found by S10-T3 (#179) on Nov 2, 2026; [[2026-11-02 14-37 Auto Run]]. #179 merged
  without deciding it. **Trigger:** the next change to `.clang-format`. **Fired Nov 9:** S10-T15
  (#194) added `assimp` to its third-party include roots, and did not decide this.
- #prio/low · **Import's untested paths**: no FBX fixture exists, so only glTF and OBJ are imported
  in tests, and the cleanup that removes a half-written import folder has no case, because
  nothing in `FileAccess` lets a test fail one write. Found at S10-T15 (#194) on Nov 9, 2026.
  **Trigger:** S10-T19, which rewrites the import's mesh write. **Fired Nov 11, still true after
  #203 (Nov 14):** Story H added glTF, `.glb` and OBJ/MTL fixtures, and still no FBX one.
- #prio/low · **Cancel an import**: closing the editor waits for every running import, so a large
  source holds the close until assimp returns ([[Content Pipeline - Design]] § *The import*).
  assimp's `ProgressHandler` can stop a read. Found at S10-T15 (#194) on Nov 9, 2026.
  **Trigger:** the asset browser's import, or the first close that waits long enough to notice.
- #prio/medium · **Sponza ships in `projects/dev` with no licence file**: S10-T16 (#196) added
  `Sponza.gltf`, `Sponza.bin` and its import to `projects/dev/assets/client`, about 14.5 MB, by
  Miguel's choice. The Khronos sample carries its own licence and credits, and nothing in the
  repo states them. Copy the sample's LICENSE beside the source and credit it wherever a
  showcase uses it. Found at S10-T16's close on Nov 10, 2026. **Trigger:** before the first
  showcase or public release that shows Sponza.
- #prio/low · **Placement loads its meshes in one blocking step**: `PlaceModelCommand` runs the
  cache's loading phase on the simulation thread and waits, as `SetAssetFieldCommand` does. The
  UI keeps drawing, since main reads snapshots, but the hierarchy shows the model late. Loading
  over several frames needs a decision on a placement that is still waiting when the scene is
  saved, cleared or replaced. Found at S10-T16 on Nov 10, 2026. **Trigger:** a measured stall,
  or R1 if render then waits on the simulation thread.
- #prio/low · **Child entities of a split mesh have assimp's names**: Sponza's one unnamed mesh
  arrives as about a hundred primitives, so placement gives the root children named
  `meshes[0]-0` and onwards. Naming each after its material would read better once import
  writes materials. Found at S10-T16 on Nov 10, 2026. **Trigger:** S10-T19, or the material
  file card. **Fired Nov 14:** #203 writes materials at import, and the names are unchanged.
- #prio/high · **Story H has not met a real asset or a window**: #203 (Nov 14) was tested on
  fixtures only. *Import image...*, *Re-import...* and placing a `.temesh` have never been run by
  hand, BC7's encode time is unmeasured, and Sponza was not re-imported, so its committed meshes
  still name null materials and its images are not in the repo. Re-import Sponza with its images
  through *Re-import...*, which also checks that the ids are kept. Found at the Story H close on
  Nov 14, 2026. **Trigger:** before R1's first textured frame, which is the first code that
  would show a wrong texture.

- #prio/low · **The console repeats `Log.cpp`'s `localTime`**: `ConsolePanel.cpp` formats a
  record's local time with its own copy of the reentrant `localtime_s` / `localtime_r` helper,
  because the one in `engine/base/src/diagnostics/Log.cpp` is `static`. A small helper in
  `base` would serve both. Found at S10-T12 (#189) on Nov 6, 2026. **Trigger:** a third place
  that formats a record's time, or the next change to the console's row format.

- #prio/medium · **Code sweep leftovers: apps**: Found by the code sweep on Nov 10, 2026
  ([[2026-11-10 14-12 Auto Run]]). Lines are at engine `9c93b8f`; #195 shifts some of them in `InspectorCommands.cpp`.
  - Eight commands open their entity loop with the same two guards, an `!entity.valid()` warning and
    a `!scene.contains(entity)` warning (`apps/editor/src/edit/HierarchyCommands.cpp:36`, `:66`,
    `:171`; `apps/editor/src/edit/InspectorCommands.cpp:54`, `:156`, `:233`, `:293`, `:357`).
    `contains` already refuses an invalid entity, so one check would do, but the two warnings would
    become one. About 30 lines.
  - `SetFieldCommand::apply` and `SetAssetFieldCommand::apply` share their per-entity loop, from
    the guard to the `FieldEditRecord` (`apps/editor/src/edit/InspectorCommands.cpp:53-86`,
    `:155-188`). Their logging and their slot differ, so a shared helper needs choosing. About 25
    lines.
  - The single-entity `EditorSnapshot::resolveDrop` (`apps/editor/src/edit/EditorSnapshot.cpp:99`)
    gives the same answer as the span overload for one entity, except when the parent is not in
    the snapshot. Dropping it changes `HierarchyPanel.cpp:176` and the tests that call it. About
    20 lines.
  - `EditorApp::configureSimulation` and `RuntimeApp::configureSimulation` make the same three
    registrations (`apps/editor/src/EditorApp.cpp:99`, `apps/runtime/src/RuntimeApp.cpp:39`).
    `ClientApp` could make them once, but that is a new override in its public header. About 12
    lines.
  - `EULER_MIXED_EPSILON` (`apps/editor/src/edit/EditSession.cpp:20`) must equal the inspector's
    `EULER_DISPLAY_EPSILON` (`apps/editor/src/ui/panels/InspectorPanel.cpp:33`). One shared
    constant would remove the "must match" comment. About 2 lines.
  - Test copies in the editor's test executable, about 50 lines together:
    - The triangle `meshBytes` (`apps/editor/tests/project/ProjectTests.cpp:617`,
      `apps/editor/tests/edit/AssetEditHarness.hpp:159`). About 6 lines.
    - `registerExportComponents` (`apps/editor/tests/project/ProjectTests.cpp:91`) is typed out
      again at `apps/editor/tests/EditorAppTests.cpp:283`. About 3 lines.
    - A directory entry count, three times (`apps/editor/tests/assets/ModelImportTests.cpp:133`,
      `apps/editor/tests/EditorAppTests.cpp:203`, `apps/editor/tests/edit/SaveSceneCommandTests.cpp:72`).
      About 5 lines.
    - "Records nothing, revision kept" checks, about ten times in
      `apps/editor/tests/edit/InspectorCommandsTests.cpp` (from `:171`), and "asset set refused"
      five times (from `:926`). About 12 lines.
    - "File content unchanged", six times in `apps/editor/tests/EditorAppTests.cpp` (from `:641`),
      and "scene held once" twice (`:521`, `:562`). About 13 lines.
    - `ExportScratch::readBootRecord`'s body typed out again at
      `apps/editor/tests/project/ProjectTests.cpp:589`. About 6 lines.
    - Six fixtures mount a scratch project as `MountedProject` does
      (`apps/editor/tests/project/ProjectTests.cpp:69`). About 10 lines.

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
  **Fired Nov 6:** the step took between 4 min 7 s and 5 min 46 s on each of the last six
  `master` runs (Nov 5-6, `db72fe6` to `e59d77c`), and 5 min 41 s on run 42282140339 for
  `e59d77c`. The step has no timeout of its own, so the job's 20 minutes is the only cap.

- #prio/low · **`delete_branch_on_merge` is off**: [[ADR-009 - Branching strategy & merge rules]]
  §1 says topic branches are deleted after merge, and the repo setting does not enforce it, so
  merged branches accumulate by hand. **Trigger:** the next settings pass, or the first time a
  stale branch is mistaken for live work.
- #prio/medium · **Assert the private-plumbing gates still match something**: `ci.yml`'s
  `check()` greps literals, so a rename empties the pattern and the gate passes on an empty
  search instead of failing (S4-T2). **Trigger:** a third gate, or the next rename that
  crosses one of the existing patterns.
  **Fired Oct 18:** S8-T10 (#141) added a `check` to `ci.yml`, for
  `internal::g_(componentTypeSlot|resourceTypeTag)` under `engine/core/include/`. That made four
  gates, not three: the Tracy-spelling gate (#37, Aug 8) is the fourth (`ci.yml:96-107` at
  `e59d77c`). **Re-armed Oct 24:** not picked for Sprint 09; the trigger is now one gate more than
  those four, or the next rename that crosses a pattern. All three log and slot patterns still
  match code at `e59d77c` (checked Nov 6).
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
  **Fired Nov 5:** the lane swept `RenderThreadTests.cpp` (#185) and `AppTests.cpp` (#191) and
  kept every name, commas included: `engine/client/tests/render/RenderThreadTests.cpp:92` and
  `engine/app/tests/AppTests.cpp:243`, `:721` and `:1026` at `e59d77c`.
## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
