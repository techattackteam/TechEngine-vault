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

## client

- *(none)*

## app

- #prio/low · **`engine/app` declares `platform` PRIVATE while its public header uses it** —
  `engine/app/CMakeLists.txt:6` says `DEPS_PRIVATE platform`, but since #63 the public header
  `engine/app/include/TechEngine/app/App.hpp` includes `FileAccess.hpp` and `MountTable.hpp`
  (`:8-9`) and holds `MountTable m_mounts` and `FileAccess m_files` as members (`:16-17`).
  ADR-008 §8 and `CONVENTIONS.md` § *CMake* both say `PUBLIC` when the dep appears in the
  target's public headers. It compiles regardless, because `core` links `platform` PUBLIC
  (`engine/core/CMakeLists.txt:21`) and `app` takes `core` PUBLIC, so every consumer and
  `TechEngineAppTests` receive platform's include directories through that edge instead.
  Nothing will ever go red over it, which is why it is worth writing down rather than waiting
  for it to break. **Trigger:** fired — #65 changed that file on 2026-09-01, about five hours
  after this entry was written, and the fix did not ride along. `DEPS_PRIVATE platform` is
  still line 6, so the citation holds.

## net

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

- #prio/high · **Decide `CONVENTIONS.md`'s Error handling row, as an ADR** — its own "first
  fallible API" trigger has fired twice without moving the row: `addLogSink` returns a bare bool
  (`engine/base/include/TechEngine/base/diagnostics/Log.hpp:123`) and `Reader` carries a sticky
  `ReadStatus` (`engine/core/include/TechEngine/core/serialization/Reader.hpp:15`, per ADR-016).
  Nothing throws across an API boundary and nothing uses `std::expected`, so it ratifies two
  existing shapes rather than opening a three-way choice. It also owns the `[[nodiscard]]`
  revisit (`CONVENTIONS.md` § *Attributes*). **Trigger:** fired — pull at the next
  `/sprint-plan`.


- #prio/medium · **Measure cache refresh and storage after #76** — ccache now saves once per
  commit and restores compatible older snapshots; Mesa archives are cached separately.
  The frozen-key mechanism is fixed, but the hit-rate improvement and snapshot growth need
  observations from successive master runs. **Trigger:** the next weekly review after
  multiple source revisions have populated the new keys.
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

- #prio/medium · **`App.cpp` is excluded from the coverage gate and only a cmake comment says
  so** — S4-T7 added `engine/app/src/App.cpp` to `diff-cover`'s `--exclude` list
  (`cmake/coverage_report.cmake`), because no CI job runs the runtime exe and the composition
  root's demo blocks are uncoverable by construction. The reasoning is real, but it weakens a
  **required** check and [[B3 — Build & Testing Notes]] § *Code coverage* does not mention it,
  so the next person to read the gate's story will not know the exclusion exists. Write it
  there, and decide at the same time whether the exclusion should be the file or only its demo
  blocks. **Trigger:** fired at S4-T7; pull with the next coverage or B3 work.

- #prio/medium · **Guard the branch-name to card-ID link** — the branch prefix is the only path
  from a squashed commit back to its board card (ADR-012 § *Consequences*), and it has now
  broken on three consecutive cards: S4-T5 rode T4's branch, S4-T6 kept the `S4-T2/` prefix
  after the slip was called out, and S4-T3's correctly-named branch was merged inside an
  unrelated bug PR (#56). The third one changes the shape of the fix: a pre-push check on the
  branch name would not have caught it, so the guard has to compare the **merged** commit
  against the open cards on [[Sprint Board]]. Nothing mechanical checks it today, so the entry
  is only ever written after the fact.
  **A merged commit naming a still-open card is legal, so that comparison cannot be an
  equality test.** #65 merged on branch `S5-T5/demo-mount-removal` while S5-T5 is still in To Do,
  because the card landed in halves. Four cards have been named correctly since the three
  misses — #64, #66, #67 and #68 all carry their own prefix — so what the guard must catch is a
  prefix matching **no** card, not one matching an open card.
  **Trigger:** fired — pull at the next `/sprint-plan`.
- #prio/medium · **ADR-009 owes an amendment: a workflow-only PR gets no CI** — § *Consequences*
  says correctness leans on strict CI plus self-review. Since #54 (2026-08-28) a PR touching only
  `.github/workflows/**` runs no build at all, so for that one class of change CI is not a
  backstop and self-review is the whole gate. S4-P4 pre-named this exact test, answered it
  correctly for docs-only PRs, and nobody re-asked it when the scope widened past docs. The
  mitigation exists but lives only in `ci.yml`'s header: land workflow edits alone and read the
  run they produce on `master`. Found at the 2026-08-29 drift check (A3). **Trigger:** fired —
  Sprint 05 planning ran on 2026-08-30 and passed the entry over, deliberately or not. Pull at
  the next `/sprint-plan`.
- #prio/low · **`ci.yml`'s `build-test` gate comment is wrong about skipped checks** — it says
  a required check skipped by an `if:` "never reports its context at all". Measured on #49's
  push run, a skipped *plain* job does report it (`diff coverage` came back `skipped`); it is
  the *matrix* job that collapses to a single check named `matrix.name` (S4-P4). The comment
  is S4-P3's text and reasons about the `needs:` wiring, which is itself fine.
  **Trigger:** fired — S4-P3 closed 2026-08-30, which was the second half of this entry's own
  trigger. It stayed unmarked because a card's close does not sweep the entries that name it.
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
- #prio/low · **A CI check that every vault `path:line` citation exists and is in range** —
  S5-P3's answer to "`/weekly-review` or CI" was to split by failure mode. Exists-and-in-range
  is mechanical and cheap, and would have caught 3 of the ~14 wrong sites the two sweeps
  found. Points-at-the-right-thing is a read, and stays with `/weekly-review`. The vault has
  its own HEAD, so the check resolves against the Dashboard's `Reconciled against` sha, not
  `master`: it proves "nothing dangles as of the last reconciliation". Citations anchored
  "at `<sha>`" resolve at that sha. **Trigger:** fired during the Sep 18 vault sweep:
  [[Known Issues]] D4 still cited the removed `FrameContext.hpp`; the obsolete issue
  was removed here, but a citation check is still wanted.

- #prio/medium · **Four app-local headers still use quoted `#include`** —
  `apps/editor/src/main.cpp`, `apps/runtime/src/main.cpp` and the matching app test
  files include their local headers with quotes. `CONVENTIONS.md` § *Includes* calls for
  angle brackets throughout; recheck the include paths before changing these four lines.
  **Trigger:** fired — the Sep 18 vault sweep rechecked the surviving sites.

- #prio/low · **Reconcile ADR-017's `main()` clause** — each executable defines `main()`
  and calls `runApp<AppType>()`; ADR-017 § *Decision* 3 instead places `main()` in a shared
  header. [[Project — Design]] § *Entry point and presentation boundary* records the
  divergence. **Trigger:** the next ADR-017 decision amendment.

- #prio/medium · **A prompt edit in the vault does not reach the running routine, and nothing
  catches the gap** — `1f4ebfb` updated [[Autonomous Lane — Routine Prompt]] § *The prompt* on
  Aug 31 at 11:06 Lisbon, and the fire five hours later still received the old four-fire text.
  Five sentences differed, all of them the fire count, and it was harmless only because the
  one-PR-per-day cap is worded identically in both. The vault copy is supposed to be the one
  you edit against, so every prompt change silently owes a manual paste into the routine and a
  missed paste looks like nothing at all. It is not a card the lane can take: a fire can only
  see the prompt it received, never the one it should have. Options: a version line at the top
  of the prompt that each report echoes back, or a step in `/weekly-review` that diffs the two.
  **Trigger:** fired — found by the 2026-08-31 second fire, carded at S5-P1's close.
  Recorded as a permanent property in [[Autonomous Lane — Design]] § *State* meanwhile.
- #prio/low · **An entry whose trigger has already fired is re-checked by nothing, so its
  witness rots unnoticed** — a trigger sweep reads the *unfired* triggers, because a fired one
  has nothing left to decide, and grooming reads a fired entry only when it pulls it. Between
  those two moments the code the entry cites keeps moving. Two entries in this file were
  invalidated by #65 within hours of being filed: the `DEPS_PRIVATE platform` one, caught on
  2026-09-03 because its trigger was still unfired, and the `App.cpp` citation one, which the
  same sweep passed over because its trigger was marked fired and which was still describing a
  deleted `TODO(S3-T13)` block five days later. The cost is bounded — grooming re-reads the
  code before it acts — but it acts on a false premise until it does. Fix is one line of scope:
  a sweep re-resolves a fired entry's citations too, and only skips re-deciding its trigger.
  **Trigger:** fired — the 2026-09-04 sweep adopted the widened scope and it paid immediately.
  Re-resolving the fired entries caught the `#prio/high` Error-handling-row entry citing
  `Log.hpp:116`, a blank line since #66 inserted seven lines above it; `addLogSink` is at `:123`
  and the entry is corrected. That entry is pulled at the next `/sprint-plan`, so under the old
  scope grooming would have opened a pointer to nothing. **Keep the widened scope.** What is
  left to decide is whether it belongs in `/weekly-review` rather than in an ad-hoc sweep.

- #prio/high · **Memory-management design note** — the engine-wide map (lifetime tiers,
  per-module memory, handles-not-pointers). **Trigger:** after M5 + M6 + R1 are real.
- #prio/medium · **Point each dep's allocator hook at the profiler** — Jolt
  (`JPH::Allocate`/`Free`/aligned + `JPH_OVERRIDE_NEW_DELETE`), miniaudio
  (`ma_allocation_callbacks`), GLFW 3.4 (`glfwInitAllocator`) →
  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §7. **Trigger:** the first init of each dep.
- #prio/medium · **Recorded-demo workflow** — capture + store. **Trigger:** the first demo
  worth keeping.
- #prio/low · **README at repo root** (public-facing). **Trigger:** T2 — the first build that
  runs outside the editor.
- #prio/xlow · **Retrofit `base` to the spelled-out-names rule** — `loc` / `fmtStr` predate it.
  **Trigger:** the next PR that touches those signatures for another reason.
- #prio/xlow · **Command `/catch-up`** — session re-entry after a multi-day gap. **Trigger:**
  the first session that opens with "where was I".

## Ideas (unsorted)

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and, when useful, a `Trigger:`_
