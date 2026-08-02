# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 03 — M1 Enablers]] *(Aug 1 – Aug 28)* |
| **Sprint goal** | **M1's two gates decided, and the vocabulary every later module is written against, built.** Profiler + Events ADRs land; math ships; `IFileSystem` gets its note. **Decide first, then build.** |
| **Current focus** | ✅ **S3-D1 done Aug 2** — [[ADR-013 — Profiler (Tracy-backed instrumentation)]] Accepted, **M2's threading ADR unblocked**, Story D cut into **S3-T3…T6** (head: S3-T3, the riskiest card in the story). 🔨 Next 🟢 Deep is **S3-D2 (Events + `StringId` ADR)**, which gates Story E. Non-deep days: math (S3-T1/T2), **S3-B1**, the two Process cards. **M0 ✅** — Sprint 02 closed Aug 2, four weeks early. |
| **Top blocker** | _none_ — watch: CI-minute budget (≈22 billed min/merged change, ADR-008 §9) · clang-tidy unproven on Windows |
| **Next milestone** | **M1 closes Aug 28** on the [[Roadmap]]'s own bar (gates Accepted + unlock demonstrable) → Sprint 04 opens **M2 ‖ M3**. RNG · crash handler · memory tracking carry |
| **Direction** | Fresh start ([[ADR-004 — Fresh start (v2) with v1 as reference]]); v1 = reference prototype |
| **Reconciled against** | engine `486fff6b` (2026-08-02) |

**Reading that stamp** ([[ADR-012 — Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against** — advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 486fff6b..origin/master
```

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (CLAUDE.md rule 2). Distance is a signal, not proof: it cannot tell
you *which* note drifted, only that nobody has looked.

**First real advance: 2026-08-02**, from `2b4bc38e`. The Sprint-02 retro spot-checked the
exposed area — Logger, Assert, Clock and the `app` loop sliver — against PRs #8–#19: the
rendered-format contract, the file-sink mode, the ring sink and every `path:line` the notes
cite. **No hub drift found**; ADR-011's rotation amendment had propagated correctly into
[[Logger — Design]]. Four findings were recorded instead, all carded or corrected — see the
retro. Spot-check depth, not a line-by-line audit; that is what this stamp has always meant.

## 🗓️ Rhythm

**Sprints: 4 weeks**, one headline goal. A sprint **week runs Sat → Fri**, so a sprint starts
on a **Saturday** and ends on the **Friday** 4 weeks later. Every sprint therefore contains
**4 weekends**: the boundary weekend (`/sprint-plan` — demo + retro + next-sprint planning)
followed by **3 weekly reviews** (`/weekly-review`). Counting them is the cheapest way to
tell where you are in a sprint.

**`/sprint-plan` absorbs `/weekly-review` on a boundary weekend — never run both**
(2026-07-26). The retro covers the final week, and it inherits the weekly review's
stale-artifact + hub-drift check. Running both wrote two journal entries and updated this
Dashboard twice before any code got written.
→ **Next ceremony:** **weekend of Aug 8–9 2026** — weekly review.
*(Aug 1–2 was a **sprint boundary**, not the planned weekly review: Sprint 02 met its goal
Jul 30 with four weeks left, so it was **closed early** and `/sprint-plan` ran instead —
[[2026-08-02 Sprint 02 Retrospective]] + [[2026-08 Sprint 03 — M1 Enablers]]. Sprint 03 takes
Aug 1 – Aug 28, so the next **sprint boundary** is still **Aug 29–30**, with weekly reviews on
**Aug 8–9**, **Aug 15–16** and **Aug 22–23**.)*

**An early close moves the boundary, not the cadence.** A sprint that meets its goal with weeks
to spare is re-planned at the next weekend, and the new sprint's 4-week range is set from that
Saturday. Sprint 02 → 03 happened to land the boundary back on the published Aug 29–30 date; do
not assume that always holds.

**Ceremony anchor = the weekend, not a fixed day.** Run each on whichever weekend day you
work; if you work both, pick one.

**The boundary weekend is day 1 of the new sprint, and stays a dev day.** Because the week
starts Saturday, both weekend days already fall inside the new sprint — so the Sat/Sun swap
never moves the boundary. Time-box the ceremonies and spend the rest of the day on code; the
artifact gate and a groomed [[Backlog]] are what keep planning short.

**Sprints no longer track calendar months** (4 weeks ≠ 1 month → 13/yr, and the boundary
walks backwards through the calendar). Don't derive dates from the month — the sprint note's
own date range is the source of truth. Adopted 2026-07-26; Sprint 02 is a 5-week one-off
transition, Sprint 03 is the first clean cycle.

**Weekly rhythm** — energy is *planned*, not aspirational; protect the light/off days.

| Day | Mode        | Typical work                                             |
| --- | ----------- | -------------------------------------------------------- |
| Mon | 🟢 Deep     | Implementation (core loop)                               |
| Tue | 🟡 Light    | Docs, reading, small fixes, ADR drafting                 |
| Wed | ⚪ Relaxed   | Recovery — optional light planning, else rest            |
| Thu | 🟢 Deep     | Implementation                                           |
| Fri | 🟠 Moderate | Lighter implementation — finish/refactor, prep next week |
| Sat | 🔴 Off*     | Karting — no engine work                                 |
| Sun | 🟢 Deep*    | Implementation + weekly review                           |

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
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | 🔨 **M1** — [[2026-08 Sprint 03 — M1 Enablers]] |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q3]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Claude — Operating Guide]]
- 📓 Journal: [[07 Journal]]

## Active decisions

Recently locked — full set in [[ADR Index]]:
- [ ] **Profiler** (S3-D1) + **Events/`StringId`** (S3-D2) → **being written this sprint**; both gate M1, and the Profiler one gates M2's threading ADR
- [ ] Threading · task-graph · serialization · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [ ] **Can an Accepted ADR be amended in place?** ADR-011 has been, twice; [[ADR Index]] says no → **S3-P1**

## Health check (update weekly · 2026-08-02)

- **Build:** 🟢 — CI green both legs across 12 PRs, no revert, `master` ruleset Active
  (8 required checks). Caveats unchanged: clang-tidy proven on Linux only; CI-minute budget live.
- **Momentum:** 🟢 strong — a 5-week sprint closed in 6 days. That is the *reason* Sprint 03 is
  sized up a third; it is not a reason to size it to the observed rate.
- **Sustainability:** 🟡 — weekday cadence **held** (Tue + Wed closed zero cards), but **both
  weekend days were worked** Jul 25–26 (guardrail wants ≥1 rest day) and **Thu Jul 30 closed
  six cards**. The bank-the-slack rule was never tested — the sprint was *finished*, not run
  dry. **Sprint 03 leaves 2 deep slots empty specifically to test it.**
- **Artifact health:** 🟢 code, 🟠 coverage. The Jul 30 drift check found **no hub drift** —
  the ADR-011 rotation amendment propagated correctly, and the notes' `path:line` claims hold
  ([[2026-08-02 Sprint 02 Retrospective]]). But **M1 has seven items and one design note**;
  Sprint 03 closes that for four of them and RNG + the crash handler carry artifact-less.
