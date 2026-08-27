# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 04 — M2 Concurrency & Serialization]] *(Aug 22 to Sep 4, the first 2-week sprint)* |
| **Sprint goal** | **Decide M2: the threading and serialization ADRs both Accepted, each proven by first code against its real interface.** Both stories were sized and cut on day 1. |
| **Current focus** | 🔨 **Story C — S4-T6 → S4-T7**, the serialization first slice, which carries the sprint's remaining 🟢 work. Story A closed Aug 22 (both ADRs) and Story B Aug 24 (the job system). S4-T2 is in flight. Side cards left — `<format>` measurement · ccache · coverage job · two cleanups · skip-CI — fill the light and moderate days and are still the cut-first list. |
| **Top blocker** | None hard. Watch: CI-minute budget (ADR-008 §9; S4-P3 adds a per-PR coverage job, so its cost gets measured) · clang-tidy unproven on Windows · Tracy's Linux leg never built in CI |
| **Next milestone** | **M2** ([[Roadmap]]): both ADRs Accepted (Aug 22) and the pool shipped (Aug 24) — **the headless binary round-trip is what is left**, at S4-T6 → S4-T7. **M3 waits for Sprint 05** (scope call recorded on the [[Roadmap]]). RNG · crash handler carry (memory tracking shipped at S3-T5) |
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

**Re-checked 2026-08-22** at the Sprint 04 boundary: `origin/master` was still `32bc327c`, zero
unreviewed commits, so the stamp stood without a new sweep. **`a0d1d1b3` (#46) has landed since,
on Aug 24**, so the stamp is one commit behind and the Aug 29-30 review owns the next sweep. The boundary found only
vault-internal staleness (memory tracking still listed as an M1 carry after S3-T5 shipped it;
a Current-focus order that was already done), fixed the same day.

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
→ **Next ceremony:** **weekend of Aug 29-30 2026**: `/weekly-review`, which is also
Sprint 04's mid-sprint checkpoint (an M2 ADR not Accepted by then costs its story, not
compression). The next boundary is **Sep 5-6**: `/sprint-plan` opens Sprint 05.
*(Sprint 04 ran its planning on Sat Aug 22, the moved-up boundary from Sprint 03's early
close: [[2026-08-22 Sprint 03 Retrospective]].)*

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

## Active decisions

Recently locked — full set in [[ADR Index]]:
- [x] **Profiler** ([[ADR-013 — Profiler (Tracy-backed instrumentation)]]) + **Events/`StringId`** ([[ADR-014 — Events (buffered streams) & StringId]]) — **both Accepted 2026-08-02**, both M1 gates closed, and M2's threading ADR is unblocked
- [x] **Threading** ([[ADR-015 — Threading (sim on main, render thread owns GL)]]) + **Serialization** ([[ADR-016 — Serialization (binary primitives & describe-once seam)]]) — **both Accepted 2026-08-22**, both M2 gates closed on day 1. ADR-015 §3 amended 2026-08-24: the pool ships four workers, not one
- [ ] task-graph · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
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
