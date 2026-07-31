# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-08 Sprint 02 — Base Foundation]] *(Jul 25 – Aug 28)* |
| **Sprint goal** | **`base` you can trust:** Logger, Assert and Clock — unit-tested and proven by a real consumer, the first sliver of the app loop. Horizontal base, **not** the vertical slice. |
| **Current focus** | ⚪ **Board is empty — all Sprint-02 cards closed** (S2-P2/P3 Jul 31; T8 landed Jul 30, PR #19). `base` has Logger, Assert, Clock + tests; headless `FrameLoop` accumulator with tick-exact + clamp tests; `CONVENTIONS.md` live; vault split done. **[[Roadmap]] rewritten Jul 31** — C2 reversed, build order is now the chain + lanes ladder. Sprint runs to **Aug 28** and the goal is met — the capacity note's rule applies: **bank the slack, don't refill it.** Next work is the **Aug 1–2** review's call. |
| **Top blocker** | _none_ — watch: CI-minute budget (≈22 billed min/merged change, ADR-008 §9) · clang-tidy unproven on Windows |
| **Next milestone** | `base` done (Aug 28) → Sprint 03 (Aug 29 – Sep 25) opens **M1 · enablers** on the [[Roadmap]] ladder |
| **Direction** | Fresh start ([[ADR-004 — Fresh start (v2) with v1 as reference]]); v1 = reference prototype |
| **Reconciled against** | engine `2b4bc38e` (2026-07-25) |

**Reading that stamp** ([[ADR-012 — Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against** — advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 2b4bc38e..origin/master
```

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (CLAUDE.md rule 2). Distance is a signal, not proof: it cannot tell
you *which* note drifted, only that nobody has looked. Currently the engine **is** ahead — PRs
#8–#19 all landed after this stamp, so `base` (Logger, Assert, Clock) and the `app` loop sliver
are the exposed area. First advance is due at the **Aug 1–2** weekly review.

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
→ **Next ceremony:** **weekend of Aug 1–2 2026** — weekly review.
*(Jul 25–26 weekend fully closed: [[2026-07-25 Weekly Review]] + [[2026-07-25 Sprint 01 Retrospective]]
+ Sprint 02 planned. Next **sprint boundary**: weekend of **Aug 29–30**.)*

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
| 4 | **Base foundation** | Logger · Assert · Clock · headless fixed-timestep loop — [[2026-08 Sprint 02 — Base Foundation]] | 🔨 active (Aug) |
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | ⚪ Sprint 03 opens M1 |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q3]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Claude — Operating Guide]]
- 📓 Journal: [[07 Journal]]

## Active decisions

Recently locked — full set in [[ADR Index]]:

- [x] Fresh start vs continue → **fresh (v2)**, [[ADR-004 — Fresh start (v2) with v1 as reference]]
- [x] v2 stack · architecture · networking · build/testing → ADRs 005–008 Accepted ([[ADR Index]])
- [x] Branching + merge rules → [[ADR-009 — Branching strategy & merge rules]] Accepted; `master` ruleset live
- [x] Diagnostics (Logger + Assert) → [[ADR-011 — Diagnostics (Logger & Assert)]] **Accepted** (S2-T1)
- [x] Vault as its own repo → [[ADR-012 — Vault repository split]] Accepted; cutover done (S2-T13)
- [x] User authoring model → [[ADR-010 — User authoring model (Systems & Scripts)]] stays **Proposed**, gated on the task-graph ADR
- [ ] Threading · task-graph · serialization · renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])

## Health check (update weekly · 2026-07-25)

- **Build:** 🟢 — CI green both legs, `ctest` 3/3, `master` ruleset Active (8 required checks).
  Caveats: clang-tidy proven on Linux only; CI-minute budget is now live.
- **Momentum:** 🟢 strong — the whole week's plan landed Monday; Thu/Fri went to design
  (ADR-010, [[Game Loop — Frame Flow]], vocabulary amendments) + process.
- **Sustainability:** 🟡 — cadence held (Wed off, Tue light), but early finish was refilled
  instead of banked and Friday ran a deep day's load on a moderate slot. Two sessions past
  midnight. **Rule for Sprint 02: finish early → the day stays empty.**
- **Artifact health:** 🟢 — all four drift findings **reconciled 2026-07-25** (`CLAUDE.md`
  de-v1'd, `04 Design Docs` refs fixed, B4 aligned to the CI format gate, scaffold
  checklist given one home). See [[2026-07-25 Weekly Review]] → *Artifact drift*.
