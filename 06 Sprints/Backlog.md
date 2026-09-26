# 🗃️ Backlog

A parking lot for ideas, observed problems and future work. **One bullet per item.**
It supplies candidates at `/sprint-plan`, not design decisions or implementation specs.

- **Each triaged entry is one bullet with `#prio/…`; `Trigger:` is optional.** Use a
  trigger only when a concrete event would make the work timely. An entry that grows
  a decision, a rationale or a `How:` has outgrown this file. Move that content to an
  ADR or a design note ([[Planning Workflow — Artifact Gate]]).
- **Prio means *want*; a trigger marks a reason to act now.** At sprint planning, turn
  every still-valid fired entry into a task after checking its evidence. Then review
  the rest by priority with Miguel, choose one to three to add to the sprint, remove
  rejected or obsolete entries, and keep useful unselected items with an updated priority.
  An item does not need a fired trigger to be chosen.
  This is not the board's `P1/P2/P3`. That scores value against one sprint's goal
  ([[Planning Workflow — Artifact Gate]] → *Priority + weight*). This scores whether a thing
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

Entries are grouped by module ([[ADR-006 — v2 core architecture & module layout]] §1). Empty
groups are kept, because they show where future work will land.

---

## base

- #prio/medium · **Get `<chrono>` out of `Log.hpp`** — `LogRecord`'s `system_clock::time_point`
  is the only reason it is there, and `<chrono>` costs ~1200 ms and 73k preprocessed lines per
  TU on MSVC (S4-T1's numbers, [[B3 — Build & Testing Notes]]). It is the engine's most widely
  included header. **Trigger:** a full-rebuild time that actually hurts, measured not guessed.
- #prio/low · **Setting `TE_LOG_ACTIVE_LEVEL` above Info fails the build** — `TE_LOGGER_*`
  expands to `TE_LOG_PRIVATE_DISCARD`, which drops its arguments unevaluated by design, so a
  local that only a discarded call site reads becomes unused and `-Werror` kills the leg.
  `engine/base/tests/math/MathFormatTests.cpp:47`'s `position` is the one site today, found at
  S5-P2 with `cmake --preset linux-debug -DTE_LOG_ACTIVE_LEVEL=3`. The cache variable is
  offered in `engine/base/CMakeLists.txt:18`, and no CI leg sets it, so nothing catches this.
  **Trigger:** the first build that sets the gate explicitly — a shipping Release config is
  the likely one.
- #prio/low · **`Log.hpp`'s `NDEBUG` fallback has no test.** No TU in the tree includes the
  header without linking `base`, so the branch #66 (S5-P2) added is reached by nothing and is
  correct by inspection only. The config-table case that shipped proves the linked gate.
  Covering the fallback needs its own TU that `#undef`s `TE_LOG_ACTIVE_LEVEL` before the
  include, plus a `CMakeLists` entry, for a branch nothing reaches today. **Trigger:** the
  first TU that includes `Log.hpp` without linking `base`, or a bug traced to the fallback.
- #prio/medium · **Allocators** — a Pool primitive. **Trigger:** a first consumer. Events
  declined it ([[ADR-014 — Events (buffered streams) & StringId]] §7 — contiguous streams, no
  node churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting
  ADR).

## platform

- #prio/medium · **File watching** — v1's `IFileWatcher`, for editor hot-reload; its
  callback-subscription shape needs re-reading against
  [[ADR-014 — Events (buffered streams) & StringId]]. **Trigger:** hot-reload being wanted (M6+).

- #prio/low · **`executablePath()` aborts on a Windows path longer than `MAX_PATH`** —
  `resolveExecutablePath` calls `GetModuleFileNameW` into a fixed `wchar_t[MAX_PATH]` and
  `TE_CHECK`s that the result fit (`engine/platform/src/ExecutablePath.cpp:16-19`). 260
  characters is not the Windows limit, so a deep install path is legal and kills the process.
  The alternative is retrying into a growing buffer until the call stops truncating. Taken
  deliberately at S5-T1 with the trade named: a fatal is honest, and nothing ships to a deep
  path today. **Loud, not silent**, so it is here rather than in [[Known Issues]].
  **Trigger:** the first install or CI checkout under a long path, or long-path support being
  turned on.

- #prio/low · **`FileAccess::move` cannot cross a filesystem boundary** —
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

- #prio/medium · **`FileAccess::remove` resolves a must-exist path through `resolveForCreate`** —
  `remove` takes the highest-priority mount for the alias and never probes
  (`engine/platform/src/files/FileAccess.cpp:190`), so a file held only by a lower-priority
  mount in an overlay comes back `NotFound` while `read` and `list` both find it. That is the
  same shape S5-T3's review corrected for `copy`, `move` and `rename`, whose sources moved to
  `resolveExisting`; `remove`'s argument must already exist for exactly the same reason and did
  not move with them. [[Project — Design]] § *The five mutating calls* names only those three in
  its sources rule, so the note decides `remove` neither way. **Both readings are defensible**,
  which is why this is a decision and not a one-line change: a delete that reaches through an
  overlay into a lower and possibly read-only mount may be precisely what should not happen.
  `copy` has an overlay case (`engine/platform/tests/files/FileAccessTests.cpp:526`) and
  `remove` has none. **Silent**, because `NotFound` is a legitimate answer and the caller cannot
  tell it from the resolver having taken the wrong mount. **Trigger:** the first overlay mount
  set with a delete over it, which S5-T5's editor bootstrap makes reachable, or the next edit to
  that section.

- #prio/medium · **Restore a read-only FileAccess boundary** — `copy`, `move` and
  `rename` are `const` but write to disk. [[File Access — Design]] § *Open questions*
  records the options. **Trigger:** the SDK boundary or the next FileAccess API edit.

## core

- #prio/medium · **Resources — hot-reload / eviction** — candidate ADR; depends on the
  UUID/cache model ported from v1 (F7, F13, F31). **Trigger:** the resource cache being real (M6).

- #prio/low · **A test for `wait()` called from a pool worker** — the `TE_CHECK` added at
  S4-T4 is the only guard, and it has no case, because without it the test hangs rather than
  fails and costs a CI timeout to catch. **Trigger:** a test helper that can fail a case on a
  deadline.

- #prio/low · **Remove call-site access and ordering from `Schedule::add`** — S7-T3 moves
  declarations into `ISystem::init`, but `add<T>(DeclareAccess<…>)` and the returned
  registration's `setPriority`, `setSlot`, `before` and `after` still work. They run after
  `init`, so they silently merge with or override a system's own declaration. The schedule
  and graph tests use them heavily. **Trigger:** a bug where a call-site declaration hides a
  system's own, or the next rewrite of those tests.

- #prio/low · **Intra-system chunking for heavy systems** — parallelize a system's entity
  iteration without changing whole-system graph semantics. **Trigger:** profiling after the
  parallel executor shows one system node dominates a tick.

## client

- *(none)*

## app

- #prio/medium · **Expose project system contribution and pre-session selection** —
  complete [[ADR-022 — Project system composition and self-description]]'s public
  catalog boundary beyond App's built-in schedule selection. **Trigger:** the first
  project-supplied system or project-code loading card.

## net

- #prio/medium · **Assign NetIds at the Tick barrier** — connect server-authoritative NetId
  allocation to newly spawned replicated entities. **Trigger:** the first networking or N2
  replication card; move this requirement into that card when scheduled.

- #prio/low · **Debug assert on raw entity indices arriving over the wire** — catches a user
  component holding a slotmap index instead of a `NetId`. **Trigger:** the first replicated
  user component.

## server *(future module)*

- *(none — lands with N1)*

## scripting / `te_sdk` *(future module)*

- *(none)*

## editor & tooling *(exe)*

- #prio/xlow · **Include `<string>` directly in `EditorApp.hpp`.** PR #81 added
  `std::string m_appliedTitle` at `apps/editor/src/EditorApp.hpp:16`, but the header receives
  `<string>` transitively through `Project.hpp`. The build is green, so this is header hygiene
  rather than a current defect. **Trigger:** the next edit to `EditorApp.hpp` or its include set.

- #prio/low · **`techengine_app()` has no `LIBS_PRIVATE`, so every third-party dep an app links
  is PUBLIC on its object library** — `cmake/techengine_app.cmake:36` puts `LIBS` on the PUBLIC
  side with the `DEPS`, and its sibling `techengine_module()` carries both `LIBS` and
  `LIBS_PRIVATE` (`cmake/techengine_module.cmake:58-59`). Found at S5-T4, where toml++ is an
  implementation detail of one `.cpp` and now reaches the editor exe and `TechEngineEditorTests`
  as well. Nothing misbehaves: it widens an include path and a link line, and the acid test for
  a leaking private type is `sdk-smoke`, which does not cover apps. **Trigger:** the second
  third-party dep an app links, or the next edit to that helper — the asymmetry between two
  sibling helpers is the part that will confuse someone.

- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).
- #prio/medium · **Project launcher UI** — list, open and create projects inside the
  editor executable. [[Project — Design]] records the placement and open storage choice.
  **Trigger:** the first editor UI card.

## etc — cross-cutting

- #prio/medium · **A `TE_ENSURE` case passes under `ctest` and fails when the test exe is run
  directly** — report-once is per call site through a function-local static (ADR-011 §5), and
  `catch_discover_tests` hides that by giving every Catch2 case its own process. Two
  `EventRegistryTests` cases hit the duplicate-tag site, and S5-T2 dropped the fire count from
  the second rather than leave the trap armed. That is a patch, not a fix: the next suite that
  asserts a fire twice through one site inherits the same split behaviour, and it will look
  like a flake. Options are a test-only reset hook on the report-once static, or a rule that a
  fire count is asserted at exactly one case per site. **Trigger:** the next card that adds a
  `TE_ENSURE` case, or the first developer confused by a green `ctest` and a red exe.

- #prio/low · **Four CI legs can never restore a ccache, and it is scoping, not the key** —
  a cache written on `refs/pull/N/merge` is readable only by that PR; only caches on
  `refs/heads/master` are shared across branches. `sanitizers` and `coverage` are
  `pull_request`-only by design (`ci.yml`, ADR-008 §9 Option A), so master never writes their
  entries. Measured on #59: master holds ccache entries for exactly `linux-debug`,
  `linux-release`, `windows-debug`, `windows-release`, and the ASan, UBSan, TSan and coverage
  legs all logged "No cache found". **The likely answer is to leave it.** Adding the four to
  the master push costs roughly 15 billed minutes per merge, Windows ASan at 2×, to save one
  or two minutes per leg on the next PR. At one PR per merge that is a net loss against the
  2k budget. What this needs is the reasoning written into
  [[B3 — Build & Testing Notes]] § *ccache keys*, not a fix. **Trigger:** more than one open
  PR per master merge becomes normal, or a sanitizer leg's cold build gets slow enough to
  notice.

- #prio/medium · **Make sanitizer workflow edits testable in hosted CI** — PR #93
  changed the Linux TSan test step but received only docs-only stand-in checks.
  A manual `workflow_dispatch` on `master` cannot validate it because `sanitizers`
  runs only for `pull_request`. The local WSL TSan suite passed, but the hosted leg
  remains unverified. Find a targeted validation path that preserves the normal
  PR-only sanitizer cost. **Trigger:** before the next sanitizer workflow edit;
  inspect the next code PR's Linux TSan result for #93's first hosted evidence.
- #prio/low · **`delete_branch_on_merge` is off** — [[ADR-009 — Branching strategy & merge rules]]
  §1 says topic branches are deleted after merge, and the repo setting does not enforce it, so
  merged branches accumulate by hand. **Trigger:** the next settings pass, or the first time a
  stale branch is mistaken for live work.
- #prio/medium · **Assert the private-plumbing gates still match something** — `ci.yml`'s
  `check()` greps literals, so a rename empties the pattern and the gate passes on an empty
  search instead of failing (S4-T2). **Trigger:** a third gate, or the next rename that
  crosses one of the existing patterns.
- #prio/low · **`.gitattributes` for committed test assets** — a repo-committed text asset gets
  CRLF on a Windows checkout, so the day a case asserts on such a file's *contents* the two CI
  legs disagree. Scratch-directory assets are written by the test and are unaffected.
  **The witness this was written against is gone:** #65 deleted `engine/app/assets/demo.txt`,
  and the tree now carries no committed data asset of any kind, so the entry is entirely
  prospective and further from firing than when it was filed.
  **Trigger:** the first test that reads a committed asset rather than a scratch one.
- #prio/low · **Reconcile ADR-017's `main()` clause** — each executable defines `main()`
  and calls `runApp<AppType>()`; ADR-017 § *Decision* 3 instead places `main()` in a shared
  header. [[Project — Design]] § *Entry point and presentation boundary* records the
  divergence. **Trigger:** the next ADR-017 decision amendment.

- #prio/high · **Memory-management design note** — the engine-wide map (lifetime tiers,
  per-module memory, handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- #prio/medium · **Point later dependency allocator hooks at the profiler** — Jolt
  (`JPH::Allocate`/`Free`/aligned + `JPH_OVERRIDE_NEW_DELETE`) and miniaudio
  (`ma_allocation_callbacks`) remain under [[ADR-013 — Profiler (Tracy-backed instrumentation)]]
  §7. GLFW's fired hook is S7-T2. **Trigger:** the first init of Jolt or miniaudio.
- #prio/low · **README at repo root** (public-facing). **Trigger:** T2 — the first build that
  runs outside the editor.
- #prio/xlow · **Retrofit `base` to the spelled-out-names rule** — `loc` / `fmtStr` predate it.
  **Trigger:** the next PR that touches those signatures for another reason.
- #prio/xlow · **Command `/catch-up`** — session re-entry after a multi-day gap. **Trigger:**
  the first session that opens with "where was I".

## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
