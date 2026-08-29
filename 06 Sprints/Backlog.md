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
- #prio/medium · **Allocators** — a Pool primitive. **Trigger:** a first consumer. Events
  declined it ([[ADR-014 — Events (buffered streams) & StringId]] §7 — contiguous streams, no
  node churn); next candidate: script instance storage (ADR-010 §2a's pool option → scripting
  ADR).

## platform

- #prio/high · **`executablePath()`** — `GetModuleFileNameW` / `/proc/self/exe`, so a mount can
  be anchored to the binary rather than to CWD or a baked source path. S3-T13 shipped its demo
  mount as a configure-time `TE_DEMO_ASSETS_DIR` define precisely because this did not exist,
  and that resolves to nothing in an installed build. v1's own call was Windows-only
  (`ProjectManager.cpp:268` @ `v1-reference`) and everything else there used `current_path()`.
  **Trigger:** fired — M3 needs it for the editor's real `assets://` mount, and the S3-T13
  demo is thrown away in the same breath.
- #prio/medium · **File watching** — v1's `IFileWatcher`, for editor hot-reload; its
  callback-subscription shape needs re-reading against
  [[ADR-014 — Events (buffered streams) & StringId]]. **Trigger:** hot-reload being wanted (M6+).

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
- #prio/medium · **Throw the S3-T13 demo mount away** — `App.cpp`'s `TODO(S3-T13)` block,
  `engine/app/assets/`, and the `TE_DEMO_ASSETS_DIR` define in `engine/app/CMakeLists.txt`.
  Goes with M3's real mount set. **Trigger:** M3 project creation.

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

- #prio/xhigh · **Autonomous web-session cards** — research the shape, then adapt
  `/sprint-plan`, [[Planning Workflow — Artifact Gate]], [[Technical Lead Charter]] and
  [[Working with Claude — Operating Guide]] to carry it: which cards are eligible for an
  unattended Claude Code on the web session, what that session cannot do (no compiling; no
  `.github/workflows/` push — its OAuth token has no `workflow` scope), and the report it hands
  back. **Trigger:** fired — pull at the next `/sprint-plan`.

- #prio/high · **Decide `CONVENTIONS.md`'s Error handling row, as an ADR** — its own "first
  fallible API" trigger has fired twice without moving the row: `addLogSink` returns a bare bool
  (`engine/base/include/TechEngine/base/diagnostics/Log.hpp:116`) and `Reader` carries a sticky
  `ReadStatus` (`engine/core/include/TechEngine/core/serialization/Reader.hpp:14`, per ADR-016).
  Nothing throws across an API boundary and nothing uses `std::expected`, so it ratifies two
  existing shapes rather than opening a three-way choice. It also owns the `[[nodiscard]]`
  revisit (`CONVENTIONS.md` § *Attributes*). **Trigger:** fired — pull at the next
  `/sprint-plan`.

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
  run they produce on `master`. Found at the 2026-08-29 drift check (A3). **Trigger:** Sprint 05
  planning, or the first workflow break that reaches `master` green.
- #prio/low · **`ci.yml`'s `build-test` gate comment is wrong about skipped checks** — it says
  a required check skipped by an `if:` "never reports its context at all". Measured on #49's
  push run, a skipped *plain* job does report it (`diff coverage` came back `skipped`); it is
  the *matrix* job that collapses to a single check named `matrix.name` (S4-P4). The comment
  is S4-P3's text and reasons about the `needs:` wiring, which is itself fine. **Trigger:** the
  next PR touching that gate, or S4-P3's close.
- #prio/low · **`delete_branch_on_merge` is off** — [[ADR-009 — Branching strategy & merge rules]]
  §1 says topic branches are deleted after merge, and the repo setting does not enforce it, so
  merged branches accumulate by hand. **Trigger:** the next settings pass, or the first time a
  stale branch is mistaken for live work.
- #prio/medium · **Assert the private-plumbing gates still match something** — `ci.yml`'s
  `check()` greps literals, so a rename empties the pattern and the gate passes on an empty
  search instead of failing (S4-T2). **Trigger:** a third gate, or the next rename that
  crosses one of the existing patterns.
- #prio/low · **`.gitattributes` for committed test assets** — `engine/app/assets/demo.txt`
  gets CRLF on Windows checkout. Harmless while the demo only logs a byte count; silent the
  day a case asserts on a repo-committed file's *contents* and the two CI legs disagree
  (scratch-directory assets are written by the test, so they are unaffected).
  **Trigger:** the first test that reads a committed asset rather than a scratch one.
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
