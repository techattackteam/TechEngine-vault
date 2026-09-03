# 🗃️ Backlog

A parking lot for ideas. **One bullet each, and nothing more.** It is not a design doc, and it
is not a planning source. Groom it at `/sprint-plan`.

- **Each entry is one bullet, a `#prio/…` and a `Trigger:`.** An entry that grows a decision, a
  rationale or a `How:` has outgrown this file. It belongs in an ADR or a design note
  ([[Planning Workflow — Artifact Gate]]).
- **Prio means *want*. `Trigger:` means *readiness*.** They are orthogonal, and both must hold.
  A `#prio/xhigh` whose trigger has not fired is **not** pullable, so draining top-down means
  top-down *among the entries whose trigger has fired*.
  This is not the board's `P1/P2/P3`. That scores value against one sprint's goal
  ([[Planning Workflow — Artifact Gate]] → *Priority + weight*). This scores whether a thing
  has value at all.
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
- #prio/medium · **Allocators** — a Pool primitive. **Trigger:** a first consumer. Events
  declined it ([[ADR-014 — Events (buffered streams) & StringId]] §7 — contiguous streams, no
  node churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting
  ADR).

## platform

- #prio/medium · **File watching** — v1's `IFileWatcher`, for editor hot-reload; its
  callback-subscription shape needs re-reading against
  [[ADR-014 — Events (buffered streams) & StringId]]. **Trigger:** hot-reload being wanted (M6+).
- #prio/medium · **[[File Access — Design]] § *The demo mount is throwaway* describes code that
  no longer exists** — the section is written in the present tense about a mount of
  `engine/app/assets/` through `TE_DEMO_ASSETS_DIR`, with a `TODO(S3-T13)` in both `App.cpp`
  and `engine/app/CMakeLists.txt`. #63 deleted the demo body and #65 deleted the define, the
  TODO and the assets directory; `TE_DEMO_ASSETS_DIR` and `S3-T13` now appear nowhere under
  `engine/`, `apps/` or `cmake/`. **Nothing in the tree calls `mount()` outside tests**, so the
  section's framing — a throwaway mount set that M3 will replace — is wrong in the other
  direction: there is no mount set to replace. The `platform::executablePath()` fix it points
  at is still a live [[Backlog]] entry and has to survive whatever replaces the section.
  **Trigger:** S5-T3 or whichever M3 card first mounts through `project.toml` — that card's
  author reads this section for the prior art.
- #prio/low · **[[File Access — Design]] § *Wiring* has the composition root and the
  `EngineContext` field count wrong** — it says `run()` in `engine/app/src/App.cpp` owns
  `MountTable` and `FileAccess` by value. Since #63 the owner is the `App` class itself
  (`engine/app/include/TechEngine/app/App.hpp:16-17`); by-value is still right, the owner is
  not. The same section says "**`EngineContext` has one field today**, `FileAccess& files`" and
  it has carried two since `jobs` landed (`EngineContext.hpp:8-9`). **The paragraph under it is
  the reason this is more than a count:** it argues a service earns a field only when something
  needs to reach it through the context "and nothing does yet", which `jobs` has already
  falsified. The Catch2 case the section credits does still exist and still pins
  reference-not-snapshot (`engine/app/tests/AppTests.cpp:55`). **Trigger:** the next edit to
  that note, or a second service being proposed for `EngineContext`.

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

- #prio/high · **Frame pacing** — S2-T7's spin-to-deadline stand-in is not shippable; the
  Windows 15.6 ms timer evidence and the open questions live on [[Game Loop — Frame Flow]].
  **Trigger:** the first build that runs unattended.
- #prio/high · **`App::run()` is untestable** — it hardcodes 120 frames and spins to a 60 Hz
  deadline, so any case asserting "`update` runs once per frame" costs ~2 s of a busy CPU.
  S5-T11 shipped with its central bug (`run()` shadowing every member it owned) invisible to
  the suite for exactly this reason. A frame budget on the constructor makes such a case cheap.
  **Trigger:** the next `App::run()` change, or M4 replacing the count with `shouldClose`.
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

- #prio/medium · **Frame capture / debug-visualization tools.** **Trigger:** a renderer to
  inspect (R2).

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
  (`engine/base/include/TechEngine/base/diagnostics/Log.hpp:116`) and `Reader` carries a sticky
  `ReadStatus` (`engine/core/include/TechEngine/core/serialization/Reader.hpp:15`, per ADR-016).
  Nothing throws across an API boundary and nothing uses `std::expected`, so it ratifies two
  existing shapes rather than opening a three-way choice. It also owns the `[[nodiscard]]`
  revisit (`CONVENTIONS.md` § *Attributes*). **Trigger:** fired — pull at the next
  `/sprint-plan`.

- #prio/high · **[[ADR-013 — Profiler (Tracy-backed instrumentation)]] and [[Profiler — Design]]
  both pin Tracy `v0.13.1`, and the tree is on `v0.14.1`** — the bump rode along in #46
  (S4-T4, 2026-08-24) and its only record is that card's Sprint Board entry. `cmake/deps.cmake`
  is on `v0.14.1`, while ADR-013 names `v0.13.1` as its decision and Profiler — Design's wiring
  table repeats it. `deps.cmake`'s own header says that tag is a **wire-protocol lock** rather
  than a version preference, because Tracy compiles its ProtocolVersion into both sides, so a
  reader trusting either artifact pairs the client with the wrong desktop app and gets a refused
  connection. It wants a dated amendment on an Accepted ADR, which is a decision rather than a
  sweep. **There is a third site:** [[B3 — Build & Testing Notes]] § *Profiling builds* also
  names `v0.13.1`, so the amendment sweeps three artifacts, not two.
  **Trigger:** fired — found by the 2026-08-30 freshness check; third site added by S5-P3.

- #prio/high · **The ccache key is write-once, so master's cache is frozen and hits are 21%** —
  S4-P1's key is `v1-<leg>-<hash of deps.cmake>`. GitHub caches are immutable per key and the
  action skips the save on an exact hit, so once master holds an entry **nothing can ever
  update it** until `deps.cmake` moves. Master's entries are stuck at whatever the
  2026-08-29 14:06 run happened to save, and they are a fraction of a full leg:
  `linux-debug` is **3.6 MB against the 14.2 MB** PR #59 produced, `windows-debug` 16 MB
  against 35 MB. Measured consequence on #59's `linux-clang Debug`: **39 hits out of 184
  cacheable calls, 21.2%**, with 145 misses. S4-P1 predicted the inverse, roughly 140 dep
  objects hitting while 43 engine TUs miss, and that premise is not holding. Two things to
  work out: **why the master entry is so small** (a cancelled run under
  `cancel-in-progress`, or something else), and whether the key needs a rotating component
  so master can refresh. Note the tension: a rotating key reopens the unbounded-growth
  problem S4-P1 was cut to fix, so this is a real trade and not a one-line change.
  **Trigger:** fired at S4-T7's merge run; pull at the next `/sprint-plan`.

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

- #prio/medium · **`FETCHCONTENT_UPDATES_DISCONNECTED` is OFF with a comment explaining why it
  is ON** — flipped as a ride-along in #46; the five lines above it still describe the old
  value and the Windows/MSBuild failure it avoided. Either restore it or rewrite the comment.
  **Trigger:** the next `cmake/deps.cmake` change, or the first re-appearance of that MSBuild
  path error.

- #prio/medium · **Guard the branch-name to card-ID link** — the branch prefix is the only path
  from a squashed commit back to its board card (ADR-012 § *Consequences*), and it has now
  broken on three consecutive cards: S4-T5 rode T4's branch, S4-T6 kept the `S4-T2/` prefix
  after the slip was called out, and S4-T3's correctly-named branch was merged inside an
  unrelated bug PR (#56). The third one changes the shape of the fix: a pre-push check on the
  branch name would not have caught it, so the guard has to compare the **merged** commit
  against the open cards on [[Sprint Board]]. Nothing mechanical checks it today, so the entry
  is only ever written after the fact. **Trigger:** fired — pull at the next `/sprint-plan`.
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
- #prio/medium · **No CI job and no test carries a timeout, so one hang burns the runner's
  6-hour ceiling** — `.github/workflows/ci.yml` sets `timeout-minutes` on no job,
  `cmake/techengine_test.cmake`'s `catch_discover_tests()` passes no per-test timeout, and
  nothing sets a CTest `TIMEOUT` property, so a deadlocked case runs until GitHub's 360-minute
  default kills the job. On a Windows leg, billed at 2×, that is up to **720 billed minutes
  from a single hang** against the ~2k monthly budget the [[Dashboard]] already watches as a
  live constraint. The engine now ships a thread pool with `wait` and a join, which is the
  class of code that hangs, and the *test for `wait()` called from a pool worker* entry above
  names a CI timeout as the price of catching it. A ceiling is a few lines and does not need
  the deadline-capable helper that entry is waiting for. **Trigger:** fired — found by the
  2026-08-31 trigger sweep.

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
- #prio/medium · **Snapshot citations in Accepted ADRs cannot be swept, and S5-P3 had to skip
  them** — [[ADR-011 — Diagnostics (Logger & Assert)]] § *Grounding* says
  `engine/base/CMakeLists.txt:4` "links `spdlog::spdlog` as **PUBLIC** today", and
  [[ADR-015 — Threading (sim on main, render thread owns GL)]] § *Context* says "no
  `std::thread` exists outside a pacer `yield`". Both were true when written and **both were
  made false by their own ADR's decision**: spdlog is now `LIBS_PRIVATE` on line 15, and
  `JobSystem` ships four worker threads. Repointing the line numbers would leave a correct
  pointer under a false present-tense claim, which is worse than the stale one. The fix is a
  convention, not an edit: a citation inside a Context or Grounding section is a snapshot and
  should carry the sha or tag it was taken at, the way [[Project — Design]] already writes
  "v1 prior art at the `v1-reference` tag". Four sites across the two ADRs.
  **Trigger:** fired — found by S5-P3, 2026-09-01. Pull with the next ADR amendment either
  one needs anyway.

- #prio/medium · **Three `App.cpp` citations now point past the end of the file** — #63 cut
  `engine/app/src/App.cpp` from about 250 lines to 55, and the demo body went with it.
  [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] § *Context* cites
  `App.cpp:95` for the `TE_DEMO_ASSETS_DIR` mount, and [[Project — Design]] § *Where this lands*
  cites `App.cpp:82` as the composition root "and the demo mount it replaces is at line 95".
  The mount is gone from `App.cpp` entirely.
  **The block this entry deferred to has already gone:** #65 deleted `TE_DEMO_ASSETS_DIR`, its
  `TODO(S3-T13)` and `engine/app/assets/` on 2026-09-01, hours after this was filed, so neither
  symbol appears anywhere in the tree and the citations no longer wait on that deletion. The
  deferral still holds on its other leg — S5-T5 moves the composition root, so the line the
  artifacts should point at does not exist yet. This is the one citation class a mechanical
  in-range check would have caught.
  **Trigger:** fired — pull with S5-T5.

- #prio/medium · **[[Game Loop — Frame Flow]]'s dated callout is stale on both of its claims** —
  the block reads "Not wired yet (checked 2026-08-20). The shipped `EngineContext` has exactly
  one field, `FileAccess& files` … The loop still constructs its own `Clock` locally, at
  `engine/app/src/App.cpp:49`." `EngineContext` now carries **two** fields, `files` and `jobs`
  (`engine/core/include/TechEngine/core/EngineContext.hpp:8-9`), and the `Clock` is an `App`
  member (`engine/app/include/TechEngine/app/App.hpp:20`), not a loop local. Re-dating the
  block means re-deciding how much of the split is built, which is a design read rather than a
  sweep. **Trigger:** fired — found by S5-P3, 2026-09-01. Pull with S5-T5 or the next Frame
  Flow edit.

- #prio/low · **[[Project — Design]] says `apps/editor/CMakeLists.txt:2` repeats ADR-006 §1's
  `tooling` composition, and it no longer does** — the note's § *A third tier is the standing
  alternative* leans on that file echoing "app + client + core + **tooling**". Line 2 now reads
  "Composition = app + client + core (ADR-006 §1). ADR-017 decided no `tooling` tier is created
  for now", so the file **contradicts** the sentence citing it. The argument still stands on
  ADR-006 §1 alone; only the second witness is gone. **Trigger:** fired — found by S5-P3,
  2026-09-01. Pull with the next [[Project — Design]] edit.

- #prio/medium · **Every quoted `#include` in the tree arrived in #62 and #63, and the house
  rule is angle brackets** — `CONVENTIONS.md` § *Includes* says "angle brackets throughout"
  and "never `"FormatBuffer.hpp"`", and 372 of the 385 `#include` lines under `engine/`,
  `apps/` and `sdk/` obey it. All 13 that do not sit in the two commits no drift check had
  covered: `engine/app/src/App.cpp:3-5`, and the mirrored pairs under `apps/editor/` and
  `apps/runtime/` — each app's own header, its `.cpp`, its `main.cpp` and its test file.
  Nothing mechanical catches the delimiter: `.clang-format` regroups includes but never
  rewrites them, and `misc-include-cleaner` is not in `.clang-tidy`'s conservative set. It
  also costs the sort order the rule exists for — `apps/editor/src/EditorApp.hpp` puts
  `<TechEngine/core/FrameContext.hpp>` at `:3` and `"TechEngine/app/App.hpp"` at `:5` in two
  separate blocks, where one delimiter would sort `app` above `core` in a single group.
  A 13-line mechanical sweep. **Trigger:** fired — found by the 2026-09-01 freshness check.

- #prio/low · **ADR-017 § *Decision* 3's `main()` clause did not ship either, and this half is
  recorded nowhere** — the clause reads "`main()` lives in a header included once per
  executable, never in the `app` library", and [[Project — Design]] § *The entry point*
  repeats it. What shipped at S5-T11 is a `runApp<AppType>()` function template
  (`engine/app/include/TechEngine/app/EntryPoint.hpp:8-14`), with each executable keeping its
  own `main()` (`apps/runtime/src/main.cpp:5`, `apps/editor/src/main.cpp:5`). The
  § *Consequences* bullet built on that clause — `Catch2WithMain` handing `TechEngineAppTests`
  a second `main()` — is moot as a result. The four-pure-virtuals divergence in the same clause
  is already recorded in [[Project — Design]] § *The App base class* as owing either a fix or a
  dated amendment; this half is not, so that amendment would be written without it.
  **Trigger:** fired — pull with whatever amendment ADR-017 § *Decision* 3 gets.

- #prio/low · **[[Project — Design]] still reads as pre-build in three places** — its header
  says "**Status:** draft, nothing built" while two of its sections now describe merged code.
  § *Testing an executable*'s cmake sketch splices `$<TARGET_OBJECTS:editor_obj>` into both
  executables, and § *`techengine_app()`, as shipped* then records that linking the object
  library was chosen instead, so a reader who reaches the sketch first gets the shape that did
  not ship. And § *Consequences*' "S5-T5's `done:` clause contradicts this note and needs
  rewording" was carried out on [[Sprint Board]] on Aug 31 — ADR-017 § *Consequences* carries
  the same now-satisfied bullet. **Trigger:** fired — pull with the next [[Project — Design]]
  edit.
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
  **Trigger:** the next [[Backlog]] trigger sweep, which is the run that would carry the change.

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

- _drop raw ideas here; untagged until triage gives them a `#prio/…` and a `Trigger:`_
