# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 05 — M3 Project & M4 Window]] *(Aug 29 to Sep 11 — the boundary was pulled **one week early**)* |
| **Sprint goal** | **Ship M3 and open the window: `projects/dev/` loads through a real `project.toml`, and a triangle draws on the render thread.** M3 is the commitment; M4 is the reach, and it is the half at risk. |
| **Current focus** | 🔨 **S5-T2**, `MountTable::mount()` validation, first of Story B. **Both Design cards are closed**: S5-D2 on Aug 30 ([[Window — Design]]) and S5-D1 on Aug 31 ([[Project — Design]] plus [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]]). **Story F closed Aug 31** with S5-T10 and S5-T11 (#62, #63). Remaining order is T2 → T1 → T3 → T4 → T5 for M3, and Story D (T6 → P4 → T7 → T8, T9 last) interleaves behind S5-T6. |
| **Top blocker** | None hard. Watch: **the 🟠 column is at 2.5× capacity**, five cards against two, after ADR-017 cut Story F into the sprint. **Story D is the expected casualty** now, not a checkpoint decision · **whether CI's llvmpipe advertises GL 4.5** is unverified and S5-P4 owns it, with a fallback written · `external/glad/` is **empty** until S5-T6 · CI-minute budget at 16.1 billed min/PR · a workflow-only PR draws no CI since #54, so S5-P4 must land alone · clang-tidy unproven on Windows |
| **Next milestone** | **M2 ✅ closed 2026-08-30** — both ADRs Accepted day 1, the four-worker pool Aug 24, the primitives Aug 27, the non-POD file round-trip Aug 30. Next is **M3 + M4 together** ([[Roadmap]]). M4's gate is already Accepted (ADR-015 §2), so only M3 stands between here and the window. RNG · crash handler carry a third sprint |
| **Direction** | Fresh start ([[ADR-004 — Fresh start (v2) with v1 as reference]]); v1 = reference prototype |
| **Reconciled against** | engine `01ed7a30` (2026-08-30) |

**Reading that stamp** ([[ADR-012 — Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against** — advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 01ed7a30..origin/master
```

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (CLAUDE.md rule 2). Distance is a signal, not proof: it cannot tell
you *which* note drifted, only that nobody has looked.

**Latest advance: 2026-08-30** (Sprint 05 planning), from `875991e2`, covering PRs #56, #58,
#59 and #60. **No new drift.** The shipped `JobSystem` matches [[Concurrency — Design]]
§ *Surface* (`DEFAULT_WORKER_COUNT = 4`, `submit`/`wait`/`workerCount`), `FileAccess` matches
[[File Access — Design]]'s five-method surface with `write` the only non-const one, and both
`Math.hpp` and `StringId.hpp` carry their formatters with no separate `Format.hpp`, matching
the S4-T1 reversal recorded in [[Math — Design]] and [[StringId — Design]].

**Two known drifts stay open and both are carded on [[Backlog]]:** ADR-013 and
[[Profiler — Design]] still pin Tracy `v0.13.1` while the tree is on `v0.14.1`
(`#prio/high` — a wire-protocol lock, so a reader trusting either artifact gets a refused
connection), and `file:line` citations point at the wrong line. The second one is **S5-P3**,
an 🤖 Auto card that ran 2026-09-01 and **is still open at 5 of 8**: 10 sites were corrected,
and the remaining three are snapshot citations inside Accepted ADRs, where repointing the
number would leave a right pointer under a false sentence. Carded, not touched.

**#62 and #63 were checked 2026-09-01, outside a ceremony, so the stamp does not move for
them.** That day's second autonomous fire ran the freshness fallback over `01ed7a3..b627332`
(#61 is `CLAUDE.md`-only; #62 and #63 are the real subject) and filed **four findings**, none
fixed. Only `/weekly-review` or `/sprint-plan` advances this stamp, so read those two commits
as checked but unstamped rather than as unreviewed drift. See [[2026-09-01 Auto Run]].

**The stamp was repointed 2026-08-30 before this advance.** It read `50ca9360`, an object that
no longer exists: `master` was rewritten after the Aug 29 check and the same commit became
`875991e2`. Found by the autonomous-lane probe. A rewrite invalidates every engine sha the
vault records, so treat commit citations older than that with suspicion.

Previous advance: 2026-08-29, from `32bc327c`, covering 8 commits, three findings, two
reconciled the same day ([[2026-08-29 Weekly Review]]).

## 🗓️ Rhythm

> **The one home for cadence.** Sprint length, ceremony timing, the weekday fallback and the
> weekly rhythm table live here. Everything else links to this section instead of restating
> it, so there is one place to change when the cadence moves again.

**Sprints: 2 weeks**, one headline goal (**changed from 4 on 2026-08-20**). A sprint **week
runs Sat → Fri**, so a sprint starts on a **Saturday** and ends on the **Friday** 2 weeks
later. Every sprint therefore contains **2 weekends**: the boundary weekend (`/sprint-plan` —
demo + retro + next-sprint planning) followed by **1 weekly review** (`/weekly-review`).
Counting them is the cheapest way to tell where you are in a sprint.

**Why it changed.** Two sprints in a row closed early with the calendar still running.
Sprint 02 met its goal in 6 days of a 5-week box; Sprint 03 closed **8 days early**, with
13 of its 17 cards done in the first 9 days. The last stretch of a 4-week sprint had no
plan in it, so the board sat empty and momentum stopped. A 2-week box makes the plan and
the calendar end together. Sizing does not change: the box shrank to match the observed
close rate, not to demand more per day.

**`/sprint-plan` absorbs `/weekly-review` on a boundary weekend — never run both**
(2026-07-26). The retro covers the final week, and it inherits the weekly review's
stale-artifact + hub-drift check. Running both wrote two journal entries and updated this
Dashboard twice before any code got written.
→ **Next ceremony:** **weekend of Sep 5-6 2026**: `/weekly-review`, Sprint 05's mid-sprint
checkpoint. It is **not** a boundary. The Sprint 05 → 06 boundary is the **Sep 12-13** weekend,
and `/sprint-plan` runs there.
*(Sprint 04's boundary ran Sun Aug 30, a week ahead of its published Sep 5-6, because the sprint
met its goal on day 9 with an empty board. See [[2026-08-30 Sprint 04 Retrospective]].)*

**An early close moves the boundary, not the cadence.** A sprint that meets its goal with time
to spare is re-planned at the next weekend, and the new sprint's 2-week range is set from that
Saturday. Sprint 02 → 03 happened to land the boundary back on its published date; Sprint 03 → 04
moved it from Aug 29-30 to Aug 22-23; Sprint 04 → 05 moved it again, to **Aug 29-30**. Do not
assume it holds either way.

**An early close costs a weekend, and that cost is not free.** Sprint 05 was pulled forward on
Sun Aug 30, so its first weekend was already spent on the review and the planning session. It
therefore contains **one** weekend deep day rather than two, and its capacity is **6-7 🟢**
rather than 8-10. Price that into the sizing rather than discovering it in week 2.

**Ceremony anchor = the weekend, not a fixed day.** Run each on whichever weekend day you
work; if you work both, pick one.

**Weekday fallback, if the weekend is lost (2026-08-20).** A ceremony that cannot run on its
weekend runs on the **next Mon or Thu evening** instead, time-boxed to about 45 minutes, and
the rest of that evening stays build time. It does not roll forward to the following weekend.
Driver: two weekends vanished in August, the reviews rolled instead of falling back, and the
board stayed empty for 10 days because nothing refilled it. Weekday evenings have been the
more reliable slot all along — a 2-week sprint has only one spare weekend, so it cannot
absorb a lost one.

**The boundary weekend is day 1 of the new sprint, and stays a dev day.** Because the week
starts Saturday, both weekend days already fall inside the new sprint — so the Sat/Sun swap
never moves the boundary. Time-box the ceremonies and spend the rest of the day on code; the
artifact gate and a groomed [[Backlog]] are what keep planning short.

**Sprints no longer track calendar months** (2 weeks ≠ 1 month → 26/yr, and the boundary
walks backwards through the calendar). Don't derive dates from the month — the sprint note's
own date range is the source of truth. Adopted 2026-07-26. Sprint 02 was a 5-week one-off
transition, Sprint 03 the first clean 4-week cycle, and **Sprint 04 is the first 2-week one**.

**Weekly rhythm** — energy is *planned*, not aspirational; protect the light/off days.

| Day | Mode        | Typical work                                             | Capacity   |
| --- | ----------- | -------------------------------------------------------- | ---------- |
| Mon | 🟢 Deep     | Implementation (core loop)                               | ~1 🟢      |
| Tue | 🟡 Light    | Docs, reading, small fixes, ADR drafting                 | 1 🟡       |
| Wed | ⚪ Relaxed   | Recovery — optional light planning, else rest            | 0          |
| Thu | 🟢 Deep     | Implementation                                           | ~1 🟢      |
| Fri | 🟠 Moderate | Lighter implementation — finish/refactor, prep next week | 1 🟠       |
| Sat | 🔴 Off*     | Karting — no engine work                                 | 0          |
| Sun | 🟢 Deep*    | Implementation + weekly review                           | **2–3 🟢** |

**Weekday deep ≠ weekend deep.** Mon/Thu are *after the day job* — one evening block, one
🟢 task. The weekend deep day is a **full day**: size it for **2–3 🟢**, not one. Sizing a
sprint by counting "deep days" without this split under-fills it by ~1 task/week.

*Weekend days are a **pair**, not fixed: default Sat off / Sun deep, but swap them or use
both when there's no karting. Guardrail: keep **≥1 rest day most weekends** — Mon–Fri
already carries 2 deep days.

## 🧭 Plan

Phase 1–3 compressed into Jul 19–26 (audit → plan → ground), each gating the next.
Build order from here: the [[Roadmap]] ladder — **chain M0–M6, then lanes**.

| # | Phase | What | State |
|---|-------|------|-------|
| 1 | **Deep v1 audit** | Read (not skim) each subsystem → deepen [[v1 Code Audit]] | ✅ done (Jul 19) |
| 2 | **Plan v2 + set up AI** | Foundation ADRs 005–008 · AI agents + ceremony loop | ✅ done |
| 3 | **Ground** | Git flow · build scaffold green on CI · `master` ruleset Active | ✅ done (Jul 24) |
| 4 | **Base foundation** | Logger · Assert · Clock · headless fixed-timestep loop — [[2026-08 Sprint 02 — Base Foundation]] | ✅ goal met (Jul 30); sprint closed Aug 2 |
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency + serialization · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | ✅ **M1 done** (Aug 20) · ✅ **M2 done** (Aug 30) → 🔨 **M3 + M4 together** in [[2026-08 Sprint 05 — M3 Project & M4 Window]]; M5 needs the task-graph ADR |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q3]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Claude — Operating Guide]]
- 📓 Journal: [[07 Journal]]
- 🔗 [[References]]

## Active decisions

Recently locked — full set in [[ADR Index]]:
- [x] **Profiler** ([[ADR-013 — Profiler (Tracy-backed instrumentation)]]) + **Events/`StringId`** ([[ADR-014 — Events (buffered streams) & StringId]]) — **both Accepted 2026-08-02**, both M1 gates closed, and M2's threading ADR is unblocked
- [x] **Threading** ([[ADR-015 — Threading (sim on main, render thread owns GL)]]) + **Serialization** ([[ADR-016 — Serialization (binary primitives & describe-once seam)]]) — **both Accepted 2026-08-22**, both M2 gates closed on day 1. ADR-015 §3 amended 2026-08-24: the pool ships four workers, not one
- [x] **Bootstrapping** ([[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]]) —
  **Accepted 2026-08-31**, written mid-sprint out of S5-D1 against an artifact gate that had
  said no ADR was owed. `project.toml` is **editor-only**; the runtime mounts a fixed layout and
  reads no manifest; `app` owns the lifecycle through an `App` base class every executable
  subclasses. **Partially supersedes [[ADR-006 — v2 core architecture & module layout]] §1**'s
  "editor out of the frame loop" clause. It cut **Story F** into Sprint 05 and rewrote three
  Story B cards, which is where the 🟠 overload came from. **Two clauses of § *Decision* 3 did
  not ship as written:** all four virtuals are pure, and `main()` stayed per-exe behind a
  `runApp<>()` template. Both are logged and neither is amended yet ([[Backlog]])
- [x] **Autonomous lane — live 2026-08-30, two fires a weekday; the PR path still unproven**
  ([[Autonomous Lane — Design]]). A second, unattended execution lane in every sprint: 🤖 Auto
  cards run in a weekday cloud routine while Miguel is at the day job. Scope reaches small bug
  fixes · the run builds and tests on Linux before opening a PR (`CLAUDE.md` § *Build & run*
  carries the carve-out) · it checks out the vault as a second `sources` repo and symlinks it
  to `docs/` · it opens the PR early and reads CI last · it never merges · the daily report is
  a vault note in [[07 Journal]]. **Deliberately no ADR:** the lane is process, and disabling
  one routine reverses it. **Three probes plus one full run on the real prompt**, all on the
  `TechEngineLinux` cloud environment. The run landed [[2026-08-30 Auto Run]] authored as Miguel
  with no AI attribution, and filed two [[Backlog]] entries of its own. The build carve-out
  costs ~75 s and passes 200/200. **The routine went live 2026-08-30 at 18:00**, on **weekdays
  only** — the weekend is Miguel's own dev time and a run pushing to vault `master` mid-session
  would collide with him. Cron is UTC, so every fire shifts an hour earlier on 25 October.
  **Cut from four fires a weekday to two on 2026-08-31**: the binding cost is Claude's weekly
  usage limit, not CI minutes, which never bound because the cap was already one PR per day.
  **Four fires have now run**, two on Aug 31 and two on Sep 1, each appending to that day's
  report note and reading what the earlier ones did. **Still unproven: the PR path**, because
  every run so far was report-only. **S5-P1** closes the observation half; **S5-P2** is the
  lane's first code card ([[Known Issues]] D1's fallback fix) and is what finally tests the PR
  path. Both Sep-1 fires declined S5-P2 on [[Sprint Board]]'s "**ordered before P2**" clause, so
  **closing S5-P1 is what unblocks it**.
- [ ] task-graph · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [x] **How long is a sprint?** **2 weeks, decided 2026-08-20** — § *Rhythm*. Two sprints in
  a row closed with the calendar still running, and the unplanned tail is where momentum died.
- [x] **What happens when a ceremony's weekend is lost?** **Weekday fallback, 2026-08-20** —
  it runs the next Mon or Thu evening, time-boxed, and does not roll to the next weekend.
- [x] **Can an Accepted ADR be amended in place?** **Yes — resolved 2026-08-20 (S3-P1)**,
  [[ADR Index]] § *Amending an Accepted ADR*. The gate is how much argument the change needs,
  not whether a decision moved; the headline decision in a title is never amendable.

## Health check (update weekly · 2026-08-30)

- **Build:** 🟢 — 12 PRs merged Aug 22 to 30, **no revert in the log**, `master` ruleset Active
  at **9 required checks** (`diff coverage` joined at S4-P3). Caveats are still four:
  clang-tidy proven on Linux only · CI-minute budget live and measured at 16.1 billed minutes
  per PR · Tracy's Linux leg has never been built in CI · **a workflow-only PR draws no CI**,
  so `ci.yml` is never tested by its own PR. *(Read from merge subjects, not from CI runs.)*
- **Momentum:** 🟢 — Sprint 04 closed its goal **on day 9 of 14**, 13 of 13 cards, with no
  empty stretch. The 2-week box is doing what it was adopted for, and its overshoot shrank from
  Sprint 03's 8 days to 5.
- **Sustainability:** 🟡, and now with a second cause. The overrun repeated for the **third
  review running**: two deep evenings each carried 1 🟢 + 1 🟠 + 1 🟡, and Fri Aug 28 closed
  four PRs on a 🟠 day. **Every overrun was process work, not engine work**, which is what the
  🤖 Auto lane was cut to move (S5-P1 makes it real). New this weekend: **zero rest days** —
  Sat Aug 29 ran the review plus two merges, Sun Aug 30 two merges plus planning, and the
  boundary was then pulled forward so nothing sits behind it. Sprint 05 is **deliberately sized
  over capacity** on the 🟠 column with a pre-named cut order; if week 1 slips, cut rather than
  compress.
- **Artifact health:** 🟢 — the Aug 30 check found **no new drift**. `JobSystem`, `FileAccess`
  and both formatter merges all match their notes against the shipped code. Two known drifts
  stay carded: the Tracy `v0.13.1` pin in ADR-013 and [[Profiler — Design]], and 8 of 30
  `file:line` citations pointing at the wrong line (now S5-P2's sibling, **S5-P3**). The habit
  to watch is unchanged from last month: **a scope change shipping with no card to hang the
  sweep on** (#54, then #56 absorbing S4-T3).
