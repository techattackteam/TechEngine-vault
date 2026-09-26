# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. Update it during the weekly review.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q3 (Jul–Sep) |
| **Sprint** | [[2026-09 Sprint 07 — Scene Events and Input Boundary]] *(Sep 26–Oct 9)* |
| **Sprint goal** | Deliver Scene events at the Tick barrier and engine-coded input notifications during the consuming Tick. |
| **Current focus** | S7-D1 and S7-D2 are complete locally; Story B event delivery and Story C input delivery are committed implementation work. |
| **Top blocker** | S7-T10 needs S7-T3's persistent-system startup seam and S7-T9's engine control identifiers. |
| **Next milestone** | Complete M5 event and input seams before M6 content. |
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
so when grounding an answer (`AGENTS.md` § *Design and evidence*). Distance is a signal, not
proof: it cannot tell you *which* note drifted, only that nobody has looked.

**Latest targeted check: Sep 26, 2026**, after fetching `origin/master` at `742fed7e`.
The Sprint 06 boundary compared the merged Scene, task-graph and input/event seams with
their design notes. Miguel supplied attended showcase evidence for repeated Scene values
and headless/windowed parity. At that boundary, event lifetime/cursor binding and input
translation remained design work; the Sep 26 amendments later settled the event rule.
The wider vault reconciliation did not run, so **the stamp is unchanged**.
No build, test, live CI check or demo was run by Codex in this planning session.

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
→ **Next ceremony:** **Oct 3–4, 2026**: `$weekly-review`, Sprint 07 midpoint.
The Sprint 06 boundary is recorded in [[2026-09-26 Sprint 06 Retrospective]].
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
| 5 | **Climb the ladder** | Chain M1–M6 (enablers · concurrency + serialization · project + testbed · window · Scene & scheduling · content), then the lanes — [[Roadmap]] | ✅ **M1 done** (Aug 20) · ✅ **M2 done** (Aug 30) → ✅ **M3 editor testbed + M4 complete**; 🔨 **M5** in [[2026-09 Sprint 07 — Scene Events and Input Boundary]]; event and input delivery are committed |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q3]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Codex — Operating Guide]] · [[Working with Claude — Operating Guide]]
- 📓 Journal: [[07 Journal]]
- 🔗 [[Research]] · [[References]]

## Active decisions

Recently locked — full set in [[ADR Index]]:
- [x] **Project system composition** ([[ADR-022 — Project system composition and self-description]]) —
  **Accepted Sep 26**. Projects explicitly contribute available systems; the app selects
  persistent instances before simulation. Each selected system declares its access,
  handlers and ordering before graph build. The active set stays fixed for that session.
  Sep 26 amendments set next-Tick batch delivery without scheduled-reader cursors.
  S7-D1 settled handler declaration order and cut six implementation cards locally.
- [x] **System scheduling** ([[ADR-020 — System scheduling and task-graph execution]]) —
  **Accepted Sep 12**, amended Sep 19. One Tick phase, component access declarations,
  numeric priority for conflicts and an immutable schedule. S6-T6–T9 shipped;
  shared-resource access waits for a concrete consumer.
- [x] **Threaded time model** ([[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]]),
  **Accepted Sep 10** after S5-T14 review. Fixed simulation ticks, render-owned interpolation,
  one shared Clock, copied timing metrics, event-driven main thread and separate Tracy frame streams.
  Implemented and validated in #81 (`7d2546fc`); remaining hub drift is recorded in the Sep 12 retrospective.
- [x] **Main/simulation split** ([[ADR-018 — Main and simulation threads, render-owned GL]]),
  **Accepted Sep 7**. JobSystem also supplies dedicated-thread creation and registration;
  subsystem owners retain handles and stop/join control. S5-D3 closed Sep 8 with the accepted
  mechanism and seven sized cards. The topology and integration proof shipped in #81 (`7d2546fc`).
- [x] **Profiler** ([[ADR-013 — Profiler (Tracy-backed instrumentation)]]) + **Events/`StringId`** ([[ADR-014 — Events (buffered streams) & StringId]]) — **both Accepted 2026-08-02**, both M1 gates closed, and M2's threading ADR is unblocked
- [x] **Threading** ([[ADR-015 — Threading (sim on main, render thread owns GL)]]) + **Serialization** ([[ADR-016 — Serialization (binary primitives & describe-once seam)]]) — **both Accepted 2026-08-22**, both M2 gates closed on day 1. ADR-015 §3 amended 2026-08-24: the pool ships four workers, not one
- [x] **Bootstrapping** ([[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]]) —
  **Accepted 2026-08-31**, written mid-sprint out of S5-D1 against an artifact gate that had
  said no ADR was owed. `project.toml` is **editor-only**; the runtime mounts a fixed layout and
  reads no manifest; `app` owns the lifecycle through an `App` base class every executable
  subclasses. **Partially supersedes [[ADR-006 — v2 core architecture & module layout]] §1**'s
  "editor out of the frame loop" clause. It cut **Story F** into Sprint 05 and rewrote three
  Story B cards, which is where the 🟠 overload came from. The original implementation diverged on optional hooks and the entry point. #81 supplies optional hooks; the per-executable `main()` / `runApp<>()` wording still needs reconciliation ([[Backlog]]).
- [x] **Claude autonomous lane:** S5-P1, P2 and P3 are closed. The first code PR (#66)
  merged Sep 3. This provider-specific lane is now historical. PR #88 migrated attended
  guidance to Codex but created no OpenAI schedule or remote environment; that lane remains
  missing. The old scheduler was not inspected during this review.
- [ ] renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [x] **How long is a sprint?** **2 weeks, decided 2026-08-20** — § *Rhythm*. Two sprints in
  a row closed with the calendar still running, and the unplanned tail is where momentum died.
- [x] **What happens when a ceremony's weekend is lost?** **Weekday fallback, 2026-08-20** —
  it runs the next Mon or Thu evening, time-boxed, and does not roll to the next weekend.
- [x] **Can an Accepted ADR be amended in place?** **Yes — resolved 2026-08-20 (S3-P1)**,
  [[ADR Index]] § *Amending an Accepted ADR*. The gate is how much argument the change needs,
  not whether a decision moved; the headline decision in a title is never amendable.

## Health check (2026-09-26)

- **Delivery:** Sprint 06 closed 12 board cards. S7-D1 cut six Scene event
  implementation cards; S7-D2 cut four input Dev cards. Both stories are
  committed to Sprint 07. [[Sprint Board]] holds the live plan.
- **Evidence:** Miguel reports repeated Scene values and headless/windowed parity from
  his showcase, with order visible in logs and Tracy. The committed App test remains
  one tick/one entity. PR #93's hosted Linux TSan path still awaits a code PR.
- **Sustainability:** Miguel rushed the final Sprint 06 weekend but ended okay. One
  Sprint 07 weekend is unavailable and a Tuesday is free from his day job. He chose
  an intentional overfill that now includes input delivery; preserve a rest day.
  No card is pre-deferred; name any rollover at review if sessions do not fit.
- **Artifact health:** this was a targeted check, not a complete reconciliation against
  `742fed7e`. The Sep 26 ADR amendments settled Tick-event lifetime and removed
  scheduled-reader cursors; S7-D1 settled cross-type handler order and cut Story B.
  S7-D2 settled the input contract, added [[Input — Design]] and cut Story C.
  The reconciliation stamp stays at `01ed7a30`.
