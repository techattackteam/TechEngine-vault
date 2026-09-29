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
- #prio/low · **The format-with-fallback block is written twice**: `internal::logDispatch`
  (`engine/base/src/diagnostics/Log.cpp:355-372`) and `internal::assertDispatch`
  (`engine/base/src/diagnostics/Assert.cpp:130-149`) carry the same `vformat_to` into a
  `FormatBuffer`, the same `catch` that writes `<format error: …>`, and the same
  `markTruncated()`. The simpler shape is one inline `internal` helper in the private
  `src/diagnostics/FormatBuffer.hpp` that both call. It would remove about 12 lines. It was not
  fixed by the sweep because the two copies are in different `.cpp` files. Found by the code
  sweep on Sep 28, 2026. **Trigger:** the next edit to either dispatch function.
- #prio/low · **The version anchors no longer anchor anything**: `baseVersion()`
  (`engine/base/include/TechEngine/base/Base.hpp:4`), `platformVersion()`
  (`engine/platform/src/Platform.cpp:7`) and `coreVersion()` (`engine/core/src/Core.cpp:8`)
  are the S1 skeleton's link-order stubs. Each one calls the one below it, and nothing calls
  `coreVersion()` at all. Every module now has real symbols that prove the link. The simpler
  shape deletes the three functions, `Base.hpp` and `Base.cpp`, and `BaseTests.cpp`'s
  "version anchor" case. Its glm case duplicates `MathTests.cpp` too. That removes about 35
  lines. It was not fixed by the sweep because it removes public headers and a tested symbol.
  Found by the code sweep on Sep 28, 2026. **Trigger:** the next change to a module's
  `CMakeLists.txt` source list.
- #prio/low · **`moduleLevel()` has no caller, not even a test**:
  `engine/base/include/TechEngine/base/diagnostics/Log.hpp:115`, defined at
  `engine/base/src/diagnostics/Log.cpp:277`. Its three siblings (`setModuleLevel`,
  `channelLevel`, `setChannelLevel`) all have test cases. Either delete it (6 lines) or give it
  a case beside `setModuleLevel`'s. It was not fixed by the sweep because it is public API.
  Found by the code sweep on Sep 28, 2026. **Trigger:** the next Logger API edit.
- #prio/low · **Three test files each write their own log-capture sink and guard**:
  `SinkGuard` (`engine/base/tests/diagnostics/LogTests.cpp:36-68`), `LogCaptureGuard`
  (`engine/base/tests/diagnostics/AssertTests.cpp:60-82`) and `GraphLogCaptureGuard`
  (`engine/core/tests/systems/TaskGraphTests.cpp:134-160`). Each one copies the record into a
  vector, calls `addLogSink` in its constructor and `removeLogSink` in its destructor, and two
  of them also save and restore `minLevel`. The simpler shape is one guard in
  `te_test_support`, next to `AssertCapture.hpp`. It would remove about 30 lines. The copied
  fields differ between the three, so which fields the shared record keeps is a choice. Found
  by the code sweep on Sep 28, 2026. **Trigger:** a fourth test file that needs to capture
  log output.

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
- #prio/low · **`inputKindLabel` has no caller**: `engine/platform/src/window/Window.cpp:178`,
  a `static` function unused since #92. **Trigger:** the next edit to `Window.cpp`.

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

## client

- *(none)*

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

## etc: cross-cutting

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
  **Trigger:** the lane's next PR.
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

## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
