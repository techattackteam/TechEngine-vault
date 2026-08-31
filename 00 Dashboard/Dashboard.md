# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 04 — M2 Concurrency & Serialization]] *(Aug 22 to Sep 4, the first 2-week sprint)* |
| **Sprint goal** | **Decide M2: the threading and serialization ADRs both Accepted, each proven by first code against its real interface.** Both stories were sized and cut on day 1. |
| **Current focus** | 🔨 **S4-T7**, the visit seam and the non-POD round-trip. It is the sprint's last 🟢 card and the last piece of the Definition of Done. It also **closes both Review cards**: S4-P1 and S4-P3 each need a PR carrying engine C++, and T7 is that PR, so run it before either close. Story A closed Aug 22, Story B Aug 24, and S4-T2/T6/P2/P3/P4/P1 all landed in week 1. Left over: S4-T1 (🟠) and S4-T3 (🟡), still the cut-first list. |
| **Top blocker** | None hard. Watch: CI-minute budget, now **measured at 16.1 billed minutes per PR** with coverage on (ADR-008 §9) · **a workflow-only PR draws no CI at all** since #54, so `ci.yml` is never tested by its own PR · clang-tidy unproven on Windows · Tracy's Linux leg never built in CI |
| **Next milestone** | **M2** ([[Roadmap]]): both ADRs Accepted (Aug 22), the pool shipped (Aug 24) and the primitives Aug 27. **The headless binary round-trip is all that is left**, at S4-T7. **M3 waits for Sprint 05** (scope call recorded on the [[Roadmap]]). RNG · crash handler carry (memory tracking shipped at S3-T5) |
| **Direction** | Fresh start ([[ADR-004 — Fresh start (v2) with v1 as reference]]); v1 = reference prototype |
| **Reconciled against** | engine `875991e2` (2026-08-29) — *repointed 2026-08-30, see below* |

**Reading that stamp** ([[ADR-012 — Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against** — advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 875991e2..origin/master
```

**The stamp was broken and is repointed, not re-earned (2026-08-30).** It read `50ca9360`, and
that object does not exist in the current history: `git cat-file -t 50ca9360` fails in a fresh
clone and locally. The same logical commit, *Cache leak should be fixed (#53)*, is now
`875991e2`, so `master` was rewritten at some point after the Aug 29 check. Found by the
autonomous-lane probe run, whose freshness fallback is the one task that depends on this sha
resolving. **The date is unchanged on purpose**: this repoints a stamp at the commit it always
meant, and no new drift check has run. A rewrite invalidates every engine sha the vault
records, so treat older `file:line` and commit citations with the same suspicion.

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (CLAUDE.md rule 2). Distance is a signal, not proof: it cannot tell
you *which* note drifted, only that nobody has looked.

**Latest advance: 2026-08-29**, from `32bc327c` (2026-08-20), covering 8 commits and PRs
#46 to #54. It spot-checked concurrency, serialization and the CI/build layer against the
shipped code. **Three findings, all from #54 widening the CI skip list.** Two were reconciled
the same day: ADR-008's 2026-08-28 amendment named two paths where `ci.yml` has three, and
[[B3 — Build & Testing Notes]] § *Docs-only PRs* was **actively false**, claiming workflow
files still run the full matrix when they are the one thing that no longer does. The third is
carded on [[Backlog]], because it needs a decision on an Accepted ADR: § *Consequences* of
[[ADR-009 — Branching strategy & merge rules]] leans on strict CI, and a workflow-only PR now
gets none. The two M2 design notes are clean. See [[2026-08-29 Weekly Review]] § *Artifact
drift*. Spot-check depth, not a line-by-line audit; that is what this stamp has always meant.

Previous advance: 2026-08-20, from `5afb6d28`, covering 15 commits, four findings, all four
reconciled the same day ([[2026-08-20 Weekly Review]]).

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
→ **Next ceremony:** **weekend of Sep 5-6 2026**: `/sprint-plan`, the Sprint 04 boundary. It
opens Sprint 05 and absorbs that weekend's review, so do not run both.
*(Sprint 04's mid-sprint checkpoint ran Sat Aug 29 and **passed**: both M2 ADRs were Accepted
on day 1, so no story was cut. See [[2026-08-29 Weekly Review]].)*

**An early close moves the boundary, not the cadence.** A sprint that meets its goal with weeks
to spare is re-planned at the next weekend, and the new sprint's 2-week range is set from that
Saturday. Sprint 02 → 03 happened to land the boundary back on its published date; Sprint 03 → 04
does not, and moves it from Aug 29-30 to **Aug 22-23**. Do not assume it holds either way.

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
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency + serialization · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | ✅ **M1 done** (Aug 20) → 🔨 **M2** in [[2026-08 Sprint 04 — M2 Concurrency & Serialization]]; M3 at Sprint 05 |

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
- [x] **Autonomous lane — live since 2026-08-30, two fires a weekday**
  ([[Autonomous Lane — Design]]). A second, unattended execution lane in every sprint: 🤖 Auto
  cards run in a weekday cloud routine while Miguel is at the day job. Scope reaches small bug
  fixes · the run builds and tests on Linux before opening a PR (`CLAUDE.md` § *Build & run*
  carries the carve-out) · it checks out the vault as a second `sources` repo and symlinks it
  to `docs/` · it opens the PR early and reads CI last · it never merges · the daily report is
  a vault note in [[07 Journal]]. **Deliberately no ADR:** the lane is process, and disabling
  one routine reverses it. **Three probes plus one full run on the real prompt**, all on the
  `TechEngineLinux` cloud environment. The run landed [[2026-08-30 Auto Run]] authored as Miguel
  with no AI attribution, and filed two [[Backlog]] entries of its own. The build carve-out
  costs ~75 s and passes 200/200. **The recurring routine is live**, cut from four fires a
  weekday to **two** on 2026-08-31 — the binding cost is Claude's weekly usage limit, not CI
  minutes. **Still unproven: the PR path**, since every run so far was report-only.
  **Next: a small code card at Sprint 05 planning**, which is that test.
- [ ] task-graph · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [x] **How long is a sprint?** **2 weeks, decided 2026-08-20** — § *Rhythm*. Two sprints in
  a row closed with the calendar still running, and the unplanned tail is where momentum died.
- [x] **What happens when a ceremony's weekend is lost?** **Weekday fallback, 2026-08-20** —
  it runs the next Mon or Thu evening, time-boxed, and does not roll to the next weekend.
- [x] **Can an Accepted ADR be amended in place?** **Yes — resolved 2026-08-20 (S3-P1)**,
  [[ADR Index]] § *Amending an Accepted ADR*. The gate is how much argument the change needs,
  not whether a decision moved; the headline decision in a title is never amendable.

## Health check (update weekly · 2026-08-29)

- **Build:** 🟢 — 8 PRs merged Aug 22 to 28, **no revert in the log**, `master` ruleset Active
  and now at **9 required checks** (`diff coverage` joined at S4-P3). Caveats are now four:
  clang-tidy proven on Linux only · CI-minute budget live and measured at 16.1 billed minutes
  per PR · Tracy's Linux leg has never been built in CI · **a workflow-only PR draws no CI**,
  so `ci.yml` is never tested by its own PR. *(Read from merge subjects, not from CI runs.)*
- **Momentum:** 🟢 — upgraded from 🟡. The 2-week box is doing what it was adopted for:
  **8 of 13 cards closed in week 1 with no empty stretch**, and the longest gap was the planned
  Tue/Wed rest pair. Both M2 gates closed on day 1, so the mid-sprint checkpoint cost nothing.
- **Sustainability:** 🟡 — rest days held cleanly (Sun off, Tue and Wed both zero commits),
  but the overrun repeated for the **third review running**: two deep evenings each carried
  1 🟢 + 1 🟠 + 1 🟡, and Fri Aug 28 closed four PRs on a 🟠 day. What is new is that
  **every overrun was process work, not engine work** — so the fix on the table is sizing, not
  discipline ([[2026-08-29 Weekly Review]]).
- **Artifact health:** 🟢 — the Aug 29 check found **three findings, one of them actively
  false rather than stale, and two were reconciled the same day**. The third is carded because
  it needs an ADR-009 decision. All three trace to **#54, a merged PR that moved a required
  check with no card behind it**, now folded into S4-P4. The habit to watch has shifted: last
  month it was amending an ADR without sweeping its design note, this month it is shipping a
  scope change with no card to hang the sweep on.
