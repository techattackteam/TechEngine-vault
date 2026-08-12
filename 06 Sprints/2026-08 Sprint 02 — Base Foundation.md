# 2026-08 · Sprint 02 — Base Foundation

- **Quarter:** [[2026-Q3]]
- **Dates:** **Jul 25 to Jul 31, 2026**, so one week. **Closed 4 weeks early, on 2026-08-02.**
  The goal was met Jul 30 and the board emptied Jul 31, so the remaining four weeks became
  Sprint 03 rather than an idle sprint.
  It had been planned as a 5-week one-off transition, since the 4-week Sat-to-Fri cadence was
  adopted mid-sprint on 2026-07-26. It was never sized for five weeks of work, and that
  under-fill is exactly why it ran out.
  Review and retro: **2026-08-02** → [[2026-08-02 Sprint 02 Retrospective]].
  **Downstream dates are unaffected.** [[2026-08 Sprint 03 — M1 Enablers]] takes
  **Aug 1 to Aug 28**, so the already-published **Aug 29 to 30** boundary still stands.
- **Epic:** v2 base foundation
- **Decisions behind it:** [[ADR-006 — v2 core architecture & module layout]] §4 §6 ·
  [[ADR-007 — v2 networking & ECS replication foundation]] §5

## 🎯 Sprint goal

> **A `base` you can trust.** Logger, Assert and Clock, unit-tested and proven by a real
> consumer, which is the first sliver of the app loop.
>
> This is the horizontal base, not the vertical slice.

This is the first v2 code that is not a skeleton.

The scope is narrow on purpose. The rest of `base`, meaning the Profiler, memory tracking,
Pool, SlotMap and the ring buffer, has **no Sprint 02 consumer**. Building any of it now would
be speculation ([[Planning Workflow — Artifact Gate]]).

The C2 vertical slice is **Sprint 03**.

### Scope calls locked at planning (2026-07-25)

| Question | Call | Why |
|---|---|---|
| Loop depth | **The accumulator plus `FrameContext`.** No phases, no `Schedule`, no ECS. | ADR-007 §5 is already decided, and this is the only consumer that genuinely exercises the Clock's tick and frame correlation. Phase stubs without ECS systems would be scaffolding for a consumer that does not exist. |
| Window | **Out. Headless instead.** | A window pulls in `platform`, GLFW, input and glad2. That is C2's opening move a sprint early, and none of it is unit-testable. |
| Fixed timestep | **Now.** It rides along with the accumulator. | It falls out of the loop-depth call. |
| Process work | **In**, meaning `CONVENTIONS.md` and the `te-module` skill. | Both triggers fired this sprint: the first module code exists, and so does the scaffold. |

## 🚦 Artifact gate

| Item | ADR? | Design note? | Outcome |
|---|---|---|---|
| **Diagnostics**, meaning Logger and Assert | ✅ | They already exist. | Cross-module and hard to reverse, since it sets `base`'s public header surface and an engine-wide failure contract. **Heavy, so task S2-T1, ordered first.** [[Logger — Design]] and [[Assert — Design]] stay the *living how*, and the ADR freezes only the calls. |
| **Clock** | ❌ | ✅ | Local to `base`, reversible, and the decision was already made on 2026-07-24. **Light, so drafted in this session:** [[Clock — Design]]. |
| **App loop sliver** | ❌ | ✅ It exists. | [[Game Loop — Frame Flow]] is its note. No new artifact is owed. |
| **`CONVENTIONS.md`** | ❌ | ❌ | It *is* documentation, not a decision. Straight to a task. |
| **`te-module` skill** | ❌ | ❌ | Tooling. Straight to a task. |

> **One decision home.** ADR-011 will freeze the load-bearing Diagnostics calls. The two design
> notes then get *Decided* one-liners plus section references pointing at it, and **never
> copied rationale**. Copies drift, which is exactly what this weekend's review had to clean
> up.

## Stories & tasks

> Every task carries `· P1/P2/P3 · 🟢 Deep / 🟠 Moderate / 🟡 Light`. Pick by **weight fits the
> day first**, then by priority ([[Planning Workflow — Artifact Gate]]).

### Story A — Diagnostics decided

- [x] **S2-T1** — Write the Diagnostics ADR (Logger + Assert) via `/adr` · **P1** · 🟢 Deep —
      **✅ Jul 25** → [[ADR-011 — Diagnostics (Logger & Assert)]] **Accepted**. T2–T6 unblocked.
      Two planning assumptions did **not** survive contact: the `fmt`-in-header + spdlog-private
      seam is **unbuildable** (bundled fmt lives inside spdlog's include tree) → seam is
      **`std::format`**, spdlog private, no new dep; and the frame stamp is **pushed by `app`**,
      not pulled from an ambient `Clock`. Also closed 12 parked open questions across both notes.
      done: **ADR-011 Accepted** in [[ADR Index]], freezing: spdlog hidden behind a
      type-erased façade in **one** `.cpp` · channel registration model · `LogRecord` shape +
      sink set · four assert tiers + one hookable handler · no external assert lib · release
      behaviour (no silent `__debugbreak`, F10). [[Logger — Design]] + [[Assert — Design]]
      updated to *index* it. **Blocks T2–T6.**

### Story B — Logger

- [x] **S2-T2** — Logger core: levels, macros, `source_location`, `do{}while(0)` · **P1** · 🟢 Deep —
      **✅ Jul 25** → PR #8 (`6f054b6b`), required checks green. Shipped: `TE_LOGGER_*` over the
      **`std::format` seam**, spdlog private to `Log.cpp`, `spdlog::spdlog` → `LIBS_PRIVATE`
      (ADR-011 §1 — the `:4` visibility breach the ADR flagged is closed); compile-time gate wired
      **per config** via genex (Debug 0 · RelWithDebInfo 1 · Release 2) + `TE_LOG_ACTIVE_LEVEL`
      cache override (§4); 9 Catch2 cases; `.clang-format` aligned to the CLion scheme so IDE == CI.
      **ADR-011's `std::format` exit trigger did not fire** — the Linux/Clang legs merged green, so
      the standalone-`fmt` fallback stays parked.
      Carried into T3: default-sink path untested · `LogRecord` has no `time` field (§3) · rendered
      line is still `[f-N][file:line:func()]`, not §3's. Found in flight and parked: `SYSTEM`
      third-party includes · coverage in CI · gate fails open · diagnostics init belongs in `app`.
      **All four were cut from [[Backlog]] on 2026-07-31** — they are defects, not ideas, and the
      vault has no home for defects yet. Unfixed as of that date; this line is the only record.
- [x] **S2-T3** — Channels + `LogRecord` + console/file sinks · **P1** · 🟢 Deep —
      **✅ Jul 25** → PR #9. Shipped: module/channel **handles** in fixed tables, registered
      explicitly from the composition root (ADR-011 §2); filtering at
      `max(process, module, channel)`; `LogRecord` gains `time` + module tag; a **sink array**
      (`addLogSink`/`removeLogSink`) replacing the single slot; one spdlog logger over console +
      a session file (`logs/techengine.log`) that degrades to console-only if the file
      won't open; the [[Logger — Design]] line, flattened **once** per record and shared by the
      pre-init stderr fallback. Call site picks its channel via a per-TU `TE_LOG_CHANNEL` +
      `_CH` escape.
      **Test-reachability criterion met** (the one T2's green-but-unreached bug earned):
      `flattenRecord` sits behind a `src/`-internal header the test target includes —
      `techengine_test()` now puts every module's `src/` on its test include path — and the
      capture sink **adds** instead of replacing, so no path exists that only runs when the
      default sink is installed. 9 new cases, incl. the stderr fallback (fd save/restore) and a
      buffer canary. *(Ring sink → T5; editor sink still excluded.)*
      **Corrected 2026-08-02:** this card originally read "rotating file, 5 MB × 3" — true when
      written, superseded Jul 30 when ADR-011 §3 was amended to one file truncated on open
      (`ef50f44`; `Log.cpp:232` is `basic_file_sink_mt(..., true)`).
      **Residual:** `initLogging`/`spdlogSink` stay uncovered by ctest — the suite never calls
      `initLogging()` so it writes no log files. **T9's demo was descoped, so nothing proves
      them** → carried into [[2026-08 Sprint 03 — M1 Enablers]] as part of **S3-B1**.

### Story C — Assert

- [x] **S2-T4** — Four tiers + single handler · **P1** · 🟢 Deep —
      done: `ASSERT` (debug-only, compiled out) · `VERIFY` (always evaluates, debug abort) ·
      `CHECK` (always-on fatal) · `ENSURE` (always-on non-fatal, report-once); failure path
      `[[unlikely]]`/cold; tests prove VERIFY still evaluates its expression in release and
      ENSURE reports once.
- [x] **S2-T5** — Assert → Logger integration + flush-on-fail · **P2** · 🟠 Moderate —
      **+ owns the in-memory ring sink** (moved from T3, 2026-07-25: this is the task whose flush
      path consumes it — ADR-011 §3).
      done: failure logs **Critical** through the Logger, flushes, controlled abort; the
      debugger-break-if-attached path is a **documented `platform` hook left unimplemented**
      (no `platform` module this sprint). Test: `ENSURE` logs and continues; `CHECK` aborts.

### Story D — Clock

- [x] **S2-T6** — Clock implementation · **P1** · 🟠 Moderate —
      done: `now()` / `wallClock()` / `totalTime()` / diagnostic `frame()` per
      [[Clock — Design]]; **no `platform` seam**; tests cover monotonicity + `totalTime`
      accumulation; Logger's `[f N]` stamp reads it.

### Story E — App loop sliver *(the consumer that proves the base)*

- [x] **S2-T7** — `FrameContext` + fixed-timestep accumulator · **P1** · 🟢 Deep —
      **✅ Jul 30** → PR #18 (`b5a9e4dc`). `FrameContext` in `core`, `FrameLoop` in `app`,
      headless. Outcome + what it cost → [[Sprint Board]] card; the calls it made
      (`Role`, `MAX_FRAME_DELTA_TIME`, loop-holds-no-`Clock`, the Windows `sleep_for`
      evidence) are *Decided* rows in [[Game Loop — Frame Flow]] — read them there, not here.
- [x] **S2-T8** — Determinism + clamp tests · **P1** · 🟢 Deep — **✅ Jul 30** → PR #19.
      done: a fixed delta sequence produces an *exact* expected tick count; a simulated stall
      produces clamped catch-up, **not** a spiral of death.
      **The card's "injected/fake time source" premise did not survive T7** — `advance()` is
      pure, so the tests feed it a synthetic sequence directly; no fake clock, no seam. That
      closes [[Clock — Design]]'s testability-seam question by removal.
- [x] **S2-T9** — End-to-end wire-up = **the sprint demo** · **P2** · 🟠 Moderate —
      **descoped Jul 30, not built.** Written as "wire the base into a headless run and record
      it"; by the time T7/T8 landed there was nothing left to wire — this sprint is horizontal
      utilities, and `App::run` already emits the correlated frame/tick lines the demo was
      meant to show. The throwaway `main.cpp` runs **are** the demo; no artifact recorded.
      Live leftover: `App::run`'s pacer is still the spin-to-deadline stand-in with a
      `TODO(S2-T9)` that now points at a dead card — real pacing is an open question on
      [[Game Loop — Frame Flow]].

### Story F — Process & tooling

- [x] **S2-T10** — Root `CONVENTIONS.md` (B4) · **P2** · 🟠 Moderate —
      done: one root `CONVENTIONS.md` with **judgment** rules only (include order, file
      skeletons, const-correctness, ownership default), linking `.clang-format`/`.clang-tidy`
      for the mechanical subset; CLAUDE.md "Code conventions" shrinks to a pointer.
      **Re-scheduled 2026-07-25 → runs in PARALLEL with T2–T9**, not late. The "needs real
      code" trigger fired on S2-T2, and Miguel flags conventions *as he reviews* — catching
      them live beats reconstructing them at sprint end. File **opened 2026-07-25** with the
      B4 migration + the comments and internal-linkage rules; [[B4 — Code Conventions]] is now
      a pointer + decision history (rules have **one** home). Remaining: fill the *Open* rows
      as they bite, then shrink CLAUDE.md's section — **deferred to sprint end**, since
      shrinking it now would drop rules out of Claude's session context mid-sprint.
- [x] **S2-T11** — Skill `te-module` scaffolder · **P3** · 🟡 Light —
      **cut Jul 30, not built.** Written as "stamp out a module skeleton"; module scaffolding
      turned out to happen alongside dev work (`app` got its tests target by hand in the same
      PR as its code), so a standalone skill had no moment to fire. This is the trade the
      mid-sprint scope-change note below pre-authorised — T11 was named as the thing to drop.
- [x] **S2-T12** — Land the accumulated vault + AI-config work through the ruleset ·
      **P3** · 🟡 Light — done: PR opened, 8 required checks green, squash-merged. First real
      exercise of the protection rules. *(Written as "land `feat/improving-vault`"; that
      branch is gone and the work accumulated uncommitted on `master` instead — mechanism
      changed, goal unchanged.)*

**Vault repo split — added mid-sprint 2026-07-27** on
[[ADR-012 — Vault repository split]] (Accepted). Urgent: the pain is *per-merge* and
*per-overlap*, so every day it waits costs another orphaned board edit or a board conflict.
T13 blocks T14 and T15.

- [x] **S2-T13** — Vault repo cutover · **P1** · 🟠 Moderate —
      done: `docs/` is its own private GitHub repo **with its history preserved** (subtree
      split / `filter-repo`, *not* a fresh `init`), removed from the engine index;
      `.gitignore` gains `docs/` and a root `.ignore` gains `!docs/` **in the same commit**
      (ADR-012 §1 — split them and vault search silently dies); verified both ways —
      `git check-ignore` reports `docs/` ignored *and* a repo-root ripgrep search returns
      vault hits; `CLAUDE.md` + root README document the two-repo clone so a fresh machine
      works. **Atomic:** do not leave `docs/` both tracked and separately-repo'd.
- [x] **S2-T14** — Retire `/task-start` + `/task-wrap` · **P2** · 🟡 Light —
      done: both files deleted from `.claude/commands/`; **no command anywhere runs git**
      against `docs/` — checked, not assumed. No command is left needing a `git -C docs`
      retarget, because these two were the only ones that ran git at all.
      **Preconditions — the files do not go until these land:** CLAUDE.md rule 9 carries
      (a) cut from `origin/master`, never local `master` and never a merged branch, and
      (b) branch = `<card ID>/<slug>`. Both earned their place from observed failures —
      (a) is the fix for the squash-merge reuse that conflicted #8–#10; (b) is, post-split,
      the only surviving commit→card link ([[ADR-012 — Vault repository split]]
      §Consequences). Delete the commands and lose these and T14 is a net regression.
      Also: [[Working with Claude — Operating Guide]] loses both table rows, both flowchart
      nodes, and the "every task is bracketed" bullet.
      **Rescoped 2026-07-27** from "retarget the vault-writing commands" — T13 removed the
      friction they existed to manage, and `/sprint-plan` · `/weekly-review` · `/vault-clean`
      turned out to only write files, never commit. ADR-012 §Consequences still reads
      "must retarget"; it is Accepted and stays unedited — this card is the record that the
      consequence was resolved by removal instead.
- [x] **S2-T15** — Reconciliation stamp · **P2** · 🟡 Light —
      done: [[Dashboard]] carries `**Reconciled against:** engine <sha> (YYYY-MM-DD)`;
      `/weekly-review` and `/sprint-plan` advance it **only after** the drift check has
      actually run (a formality stamp is worse than none — ADR-012 §6); CLAUDE.md rule 2
      says to compare it against `origin/master` and treat design notes as **suspect** while
      the engine is ahead.

## Definition of Done

- [x] **ADR-011 (Diagnostics) is Accepted.** Both design notes index it, with no copied
      rationale.
- [x] **The vault split is done (ADR-012).** `docs/` is its own repo, board edits no longer
      touch engine PRs, and the reconciliation stamp is live. *Added mid-sprint on 2026-07-27.
      See the capacity note.*
- [x] **Logger, Assert and Clock** live in `base`, each with Catch2 tests, and **CI is green on
      both legs**.
- [x] **The headless app loop** runs a fixed-timestep accumulator that publishes
      `FrameContext`, with a **tick-exact** determinism test and a **clamp** test. *(S2-T7 and
      S2-T8, PRs #18 and #19.)*
- [x] Demo: correlated frame and tick log output from a headless run. It was **shown, not
      recorded.** S2-T9 was descoped, so there is no stored artifact, and `App::run`'s output
      is the demo. *(A recorded artifact was offered as a new card at the 2026-08-02 review and
      **not pulled**. See the sprint review below.)*
- [x] A root `CONVENTIONS.md` exists, and CLAUDE.md's conventions section is a pointer to it.
- [x] **Nothing was built without a Sprint 02 consumer.** The pressure test holds: no Profiler,
      no FrameAllocator, and no Pool, SlotMap or ring buffer.

## Capacity note

**This sprint is deliberately under-filled.** Twelve tasks across about 5 weeks, which is
roughly 15 deep slots, is slack by design.

That is the point. Sprint 01's retro identified **refilling freed time** as the live burnout
risk, not overload.

> **The rule, in writing: finish early, and the next deep day stays empty.** Slack is the
> deliverable, not a gap to fill. If the sprint runs genuinely dry, pull *nothing*. Bank it,
> and let Sprint 03, the C2 vertical slice, start rested.

Weight matches the day type, following the rhythm on the [[Dashboard]]: deep on Mon and Thu
plus one weekend day, moderate on Fri, light on Tue, relaxed on Wed, and the other weekend day
off. Weekend days are a **swappable pair**, so nothing here is assigned to Sat or Sun
specifically.

**Ordering constraint.** S2-T1, the ADR, gates T2 through T6. T13 gates T14 and T15.
Everything else is free.

### Mid-sprint scope change, 2026-07-27

**Twelve tasks became fifteen**, with T13, T14 and T15 covering the ADR-012 vault split, added
on day 3. It is recorded here rather than absorbed silently, because the rule above forbids
refilling freed time.

**This is not that case.** The rule targets *refilling slack when the sprint runs dry*. This is
new work arriving with a real trigger.

The distinction matters, so it was handled deliberately: **zero 🟢 Deep tasks were added.** The
added weights are 🟠, 🟡 and 🟡, which draw on moderate and light capacity, meaning Fri and Tue.
The protected resource, the deep slots for T4, T7 and T8, is untouched. That is why T13 is
**P1 but Moderate**: prioritised without displacing the sprint goal.

**It is still a net increase, and the trade is on the table.** If light capacity gets tight,
push **S2-T11** (`te-module`, P3 🟡) to Sprint 03. It is the same tooling category, it is the
lowest priority in the sprint, and it has no consumer waiting. Take that trade before letting
anything touch the Deep slots.

## Sprint review — 2026-08-02

**What shipped.** Fifteen cards across 12 PRs, green on both legs, with no revert.

These were folded in from the [[Sprint Board]]'s Done column before it was reset. The board
holds live state, never history.

| Card | Shipped |
|---|---|
| **S2-T1** | [[ADR-011 — Diagnostics (Logger & Assert)]] **Accepted** — unblocked T2–T6. Two planning assumptions died under review: `fmt`-in-header **unbuildable** → `std::format`; frame stamp **pushed**, not pulled |
| **S2-T2** | Logger core → PR #8 (`6f054b6b`). `std::format` seam, spdlog private, per-config compile-time gate, 9 Catch2 cases. ADR-011's fmt-fallback trigger **did not fire** on the Linux leg |
| **S2-T3** | Channels + `LogRecord` + console/session-file sinks → PR #9. Handles + explicit registration, `max(process, module, channel)` filtering, sink **array**. Earned the test-reachability criterion |
| **S2-T4** | Four assert tiers + one hookable handler → PR #13. `SourceName.hpp`, `thread_local` recursion guard, `TE_ASSERT_DEV` **PUBLIC** on purpose. RelWithDebInfo presets added, run by hand |
| **S2-T5** | Assert → Logger + flush-on-fail → PR #17, **and the in-memory ring sink** (moved from T3). Debugger-break left a documented `platform` hook |
| **S2-T6** | `Clock` → PR #10 (`2e16a067`). `now()`/`totalTime()`/`wallClock()`/`frame()`, plain `uint64_t`, **no seam**, 6 lower-bounds-only cases |
| **S2-T7** | `FrameContext` (in `core`) + `FrameLoop` (in `app`) → PR #18. **Measured** that `sleep_for` cannot pace 60 Hz on Windows: 120 frames × 16.67 ms ran **221** ticks |
| **S2-T8** | Determinism + clamp tests → PR #19 (`486fff6b`), 12 cases. **No fake clock** — `advance()` is pure, so T7 deleted the seam T8 was written to need |
| **S2-T9** | **Descoped** — nothing left to wire; `App::run`'s output *is* the demo |
| **S2-T10** | Root `CONVENTIONS.md` → CLAUDE.md shrunk to a pointer + 3 AI-default corrections; 3 provisional rows ratified |
| **S2-T11** | **Cut** — module scaffolding happens alongside dev work, so `te-module` never had a moment to fire |
| **S2-T12** | Landed the accumulated vault + AI config through the ruleset → PR #11, 24 files, zero code. First real exercise of the protection rules |
| **S2-T13** | Vault repo cutover → PR #14. `docs/` is `TechEngine-vault`, **17 commits of history preserved** via subtree split; `.gitignore` + root `.ignore` verified both directions |
| **S2-T14** | `/task-start` + `/task-wrap` retired → PR #15. Rescoped once checked: they were the **only** commands that ran git. Rule 9 absorbed the two rules that earned their keep |
| **S2-T15** | Reconciliation stamp on [[Dashboard]] → PR #16. Shipped **already reading "behind"**, which is the mechanism working |
| **V0 · V2 · S2-P1/P2/P3** | Opus-5 prompting patterns applied · [[Backlog]] compressed 382 → 103 lines · planning flow rebuilt (four task kinds, [[Known Issues]], defect-vs-bug bar) · [[Roadmap]] rewritten to the chain + lanes · Q3 + Dashboard realigned |

**Demo and artifact.** None was recorded.

S2-T9 was descoped, so the demo was the throwaway `main.cpp` runs emitting correlated frame
and tick lines. It was **shown, not stored.**

The recorded-demo workflow ([[Backlog]] → *etc*) was **not** pulled into Sprint 03. M1 is
headless utilities, and the first capture worth keeping is the profiler one that Sprint 03's
Definition of Done names.

→ Retrospective: [[2026-08-02 Sprint 02 Retrospective]].
