# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 03 — M1 Enablers]] *(Aug 1 – Aug 28)* |
| **Sprint goal** | **M1's two gates decided, and the vocabulary every later module is written against, built.** Profiler + Events ADRs land; math ships; file access gets its note. **Decide first, then build.** |
| **Current focus** | ✅ **Sprint 03 is complete: 17 of 17 cards, 8 days early** (last card S3-P1, Aug 20, `f52e332b`). Both M1 gates were Accepted Aug 2; F28 closed at S3-T10 and F30 at S3-T13. **The board is empty** — In Progress and Review/Demo both have nothing in them. 🔨 Next: **run `/sprint-plan`** and open **Sprint 04, the first 2-week sprint**. Sprint 03's retro and demo fold into it. Before any `/card-start`, **reconcile the 4 drift findings** in [[2026-08-20 Weekly Review]]. |
| **Top blocker** | **Sprint 04 unplanned, and the board is empty** — nothing is workable until `/sprint-plan` runs. Watch: CI-minute budget (ADR-008 §9; S3-P1 spent ~14 min on three markdown files) · clang-tidy unproven on Windows · Tracy's Linux leg never built in CI |
| **Next milestone** | ✅ **M1 closed Aug 20** on the [[Roadmap]]'s own bar (gates Accepted + unlock demonstrable), 8 days ahead of plan → Sprint 04 opens **M2 ‖ M3** — M2 now carries **two** ADRs (threading · **serialization**, moved up from M6 on Aug 2). RNG · crash handler · memory tracking carry |
| **Direction** | Fresh start ([[ADR-004 — Fresh start (v2) with v1 as reference]]); v1 = reference prototype |
| **Reconciled against** | engine `32bc327c` (2026-08-20) |

**Reading that stamp** ([[ADR-012 — Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against** — advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 32bc327c..origin/master
```

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (CLAUDE.md rule 2). Distance is a signal, not proof: it cannot tell
you *which* note drifted, only that nobody has looked.

**Latest advance: 2026-08-20**, from `5afb6d28` (2026-08-03), covering 15 commits and PRs
#23 to #45. Two weekly reviews were missed, so this one check carried three weeks. It
spot-checked every system Sprint 03 touched: math, profiler, `StringId`, events, diagnostics
bring-up and file access. **Four findings, two of them live poison** — see
[[2026-08-20 Weekly Review]] § *Artifact drift*. Spot-check depth, not a line-by-line audit;
that is what this stamp has always meant. Previous advance: 2026-08-02, from `2b4bc38e`
([[2026-08-02 Sprint 02 Retrospective]]), which found no hub drift.

## 🗓️ Rhythm

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
→ **Next ceremony:** **weekend of Aug 22-23 2026** — `/sprint-plan`.
*(A **sprint boundary**, not the planned weekly review: Sprint 03 met its goal Aug 20 with
8 days left, so it closes early. Sprint 04 is the first **2-week** sprint; run on Aug 22 it
takes **Sat Aug 22 to Fri Sep 4**, with a weekly review on **Aug 29-30** and the next
boundary on **Sep 5-6**. The Aug 8-9 and Aug 15-16 reviews were missed and were caught up
in one entry on Thu Aug 20 — [[2026-08-20 Weekly Review]].)*

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
| 4 | **Base foundation** | Logger · Assert · Clock · headless fixed-timestep loop — [[2026-08 Sprint 02 — Base Foundation]] | ✅ done (Jul 30) |
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency + serialization · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | ✅ **M1 done** (Aug 20) → 🔨 **M2 ‖ M3**, planned at Sprint 04 |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q3]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Claude — Operating Guide]]
- 📓 Journal: [[07 Journal]]

## Active decisions

Recently locked — full set in [[ADR Index]]:
- [x] **Profiler** ([[ADR-013 — Profiler (Tracy-backed instrumentation)]]) + **Events/`StringId`** ([[ADR-014 — Events (buffered streams) & StringId]]) — **both Accepted 2026-08-02**, both M1 gates closed, and M2's threading ADR is unblocked
- [ ] Threading · task-graph · serialization · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [x] **How long is a sprint?** **2 weeks, decided 2026-08-20** — § *Rhythm*. Two sprints in
  a row closed with the calendar still running, and the unplanned tail is where momentum died.
- [x] **What happens when a ceremony's weekend is lost?** **Weekday fallback, 2026-08-20** —
  it runs the next Mon or Thu evening, time-boxed, and does not roll to the next weekend.
- [x] **Can an Accepted ADR be amended in place?** **Yes — resolved 2026-08-20 (S3-P1)**,
  [[ADR Index]] § *Amending an Accepted ADR*. The gate is how much argument the change needs,
  not whether a decision moved; the headline decision in a title is never amendable.

## Health check (update weekly · 2026-08-20)

- **Build:** 🟢 — 25 PRs merged Aug 2 to 20, **no revert in the log**, `master` ruleset Active
  (8 required checks). One build break, at S3-T13, caught and fixed before merge. Caveats
  unchanged and now three: clang-tidy proven on Linux only · CI-minute budget live · Tracy's
  Linux leg has never been built in CI. *(Read from merge subjects, not from CI runs.)*
- **Momentum:** 🟡 — throughput is strong, continuity is not. Sprint 03 closed **8 days
  early**, but **13 of its 17 cards landed in the first 9 days** and **Aug 14 to 19 produced
  zero commits**. The stall was not rest: the board emptied, and the refill point is a weekend.
  That is what the 2-week sprint and the weekday fallback are meant to fix.
- **Sustainability:** 🟡 — weekday cadence mostly held (Tue light, both Wednesdays off), and
  Aug 15-16 was a real full rest weekend. Two overruns: **Fri Aug 7 closed four PRs including a
  🟢 Deep card** on a 🟠 day, and Mon Aug 3 and Mon Aug 10 each closed three on an evening
  sized for one. Aug 7 is the **same failure the Jul 25 review already flagged**, so
  bank-the-slack remains untested after two sprints.
- **Artifact health:** 🟢 — the Aug 20 drift check found **four findings, two of them live
  poison**, and **all four were reconciled the same day** ([[2026-08-20 Weekly Review]]). Both
  poisonous ones came from process work amending an ADR without sweeping the design note that
  indexes it, so that is the habit to watch. Coverage improved too: every M1 item that shipped
  now has a design note.
