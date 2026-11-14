# 🎛️ TechEngine Dashboard

> The one page you open first. Keep it short. `/card-close` keeps *Now* current; the weekly
> review owns the rest.

## Now

| | |
|---|---|
| **Quarter** | 2026 Q4 (Oct-Dec): [[2026-Q4]] |
| **Sprint** | [[2026-11 Sprint 11 - First Frame]] *(Nov 14 - Nov 27)*, planned Nov 14. Sprint 10 closed 41 of 43 cards, E1 among them ([[2026-11-14 Sprint 10 Retrospective]]). |
| **Sprint goal** | E2's first frame: Sponza, imported with its textures, is drawn through a camera in the runtime's window, on the new device, with base color only. The editor's scene view shows the same frame and is the first part to drop. |
| **Current focus** | S11-D5, the testing regime, is next: it decides where each test tier runs, and its PR wires it. Then S11-T1 (Story H meets a real asset) and R1's cards from S11-T2 to S11-T9, which Miguel writes with Claude pairing. Work days end on Nov 24. Hubs: [[Renderer - Design]], [[Content Pipeline - Design]]. |
| **Top blocker** | CI's software GL cannot meet R1's GL floor, and only zink on Linux can (S11-D1), so S11-D5 must land before any card raises the GL check. The routine owes a prompt paste before Mon Nov 16, and left no report on Fri Nov 13 ([[Autonomous Lane - Routine Prompt]]). For Sprint 12: the asset edit path that a material inspector needs is not designed ([[Backlog]] § *editor & tooling*). |
| **Next milestone** | **E2 · First renderer**, over about three sprints, of which Sprint 11 is the first ([[Roadmap]]). No showcase outline exists yet; `/showcase E2` is owed before the sprint that ends it. |
| **Direction** | An engine company, shown on YouTube ([[Vision]]). Phase 1 builds the engine one goal a month (E1 to E13, with E2 split in two, [[Capability Map]]), most goals ending in a showcase; the engine's first release ships when its contents are done, without waiting for TechAttack. Phase 2 builds TechAttack ([[Reference Game]], [[Channel]]). Decided 2026-10-23, revised at `/product-review` on 2026-10-31. |
| **Reconciled against** | engine `6836c87` (2026-11-14) |

**Reading that stamp** ([[ADR-012 - Vault repository split]] §6): the vault is its own repo,
so its HEAD and the engine's move independently and a design note can describe code that has
moved on. The stamp is the last engine commit a drift check **actually ran against**, advanced
by `/weekly-review` or `/sprint-plan` only as that check's output, never as a formality.

```bash
git log --oneline 6836c87..origin/master
```

**Anything it lists is unreviewed against the vault** → treat design notes as *suspect* and say
so when grounding an answer (`CLAUDE.md` § *How to work here*, rule 2). Distance is a signal, not
proof: it cannot tell you *which* note drifted, only that nobody has looked.

**Latest check: Nov 14, 2026**, against fetched `origin/master` at `6836c87`, covering the 12
engine commits since `e59d77c` (#193 to #204). The lane's freshness checks covered #193 to #201
as they merged; this check read the notes that #203 and #204 touch against the code, not every
note. `tools/check-vault-citations.py` ran at `c99bf04` and at `6836c87` with the same excludes
and found no new break. One fix: [[Resources - Design]] § *Handles, counts and the load
lifecycle* still said a load task writes its entry. No hub drift in the Scene and Resources rows; the Renderer and Content
Pipeline rows were not read against ADR-028 and ADR-029. Details in
[[2026-11-14 Sprint 10 Retrospective]].

**Latest full reconciliation: Oct 10, 2026**, against fetched `origin/master` at `82d7a11c`,
covering the 63 engine commits since `01ed7a30`. Every Systems design note was read against
the code its section describes. The Utilities notes were checked against the commits that
changed their code, and all had been edited after those commits. `tools/check-vault-citations.py`
ran against `82d7a11c`; its remaining reports are v1 or at-commit citations, not drift.
Fixed in place: the `std::error_code` returns from #124 in [[Window - Design]]; the
`fixedUpdate` hook that S6-T9 removed, in [[Simulation Thread - Design]],
[[Game Loop - Frame Flow]] and [[Project - Design]]; claims that S7-T7's event barrier and
S7-T8's tests were still unbuilt, in [[Scene - Design]], [[Game Loop - Frame Flow]] and
[[Task Graph - Execution Flow]]; and six shifted line citations in [[Events - Design]] and
[[Project - Design]]. The Decided rows showed no hub drift against the ADRs. No build, test
or demo was run.

## 🗓️ Rhythm

> **The one home for cadence.** Sprint length, ceremony timing, the weekday fallback and the
> weekly rhythm table live here. Everything else links to this section instead of restating
> it, so there is one place to change when the cadence moves again.

**Sprints: 2 weeks**, one headline goal (**changed from 4 on 2026-08-20**). A sprint **week
runs Sat → Fri**, so a sprint starts on a **Saturday** and ends on the **Friday** 2 weeks
later. Every sprint therefore contains **2 weekends**: the boundary weekend (`/sprint-plan`:
demo + retro + next-sprint planning) followed by **1 weekly review** (`/weekly-review`).
Counting them is the cheapest way to tell where you are in a sprint.

**Why it changed.** Two sprints in a row closed early with the calendar still running.
Sprint 02 met its goal in 6 days of a 5-week box; Sprint 03 closed **8 days early**, with
13 of its 17 cards done in the first 9 days. The last stretch of a 4-week sprint had no
plan in it, so the board sat empty and momentum stopped. A 2-week box makes the plan and
the calendar end together. Sizing does not change: the box shrank to match the observed
close rate, not to demand more per day.

**`/sprint-plan` absorbs `/weekly-review` on a boundary weekend; never run both**
(2026-07-26). The retro covers the final week, and it inherits the weekly review's
stale-artifact + hub-drift check. Running both wrote two journal entries and updated this
Dashboard twice before any code got written.
**Planning is split in two since 2026-10-23** ([[Planning Workflow - Artifact Gate]] § *Decide
first, then plan*). `/sprint-prep` runs as a standing Design card in **week 2, Tuesday to
Friday**, and drafts the next sprint; a 🤖 Auto prep brief feeds it from the Monday. The
boundary's `/sprint-plan` then only runs the retro and fits the draft.

→ **Next ceremony:** `/weekly-review` on the **Nov 21-22** weekend. `/sprint-prep` (S11-D4) runs
on **Tue Nov 24**, its only free day. `/sprint-plan` for the Sprint 11 boundary is due on **Nov
28-29**, a vacation weekend, so it falls back to Mon Nov 30 if that weekend is lost.
*(Sprint 09's boundary ran Sat Oct 31, a week ahead of its published Nov 7-8, to line up with
Miguel's day-job sprints. See [[2026-10-31 Sprint 09 Retrospective]].)*
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
more reliable slot all along: a 2-week sprint has only one spare weekend, so it cannot
absorb a lost one.

**The boundary weekend is day 1 of the new sprint, and stays a dev day.** Because the week
starts Saturday, both weekend days already fall inside the new sprint, so the Sat/Sun swap
never moves the boundary. Time-box the ceremonies and spend the rest of the day on code; the
artifact gate and a groomed [[Backlog]] are what keep planning short.

**Sprints no longer track calendar months** (2 weeks ≠ 1 month → 26/yr, and the boundary
walks backwards through the calendar). Don't derive dates from the month. The sprint note's
own date range is the source of truth. Adopted 2026-07-26. Sprint 02 was a 5-week one-off
transition, Sprint 03 the first clean 4-week cycle, and **Sprint 04 is the first 2-week one**.

**Weekly rhythm**: energy is *planned*, not aspirational; protect the light/off days.

| Day | Mode        | Typical work                                             | Capacity   |
| --- | ----------- | -------------------------------------------------------- | ---------- |
| Mon | 🟢 Deep     | Implementation (core loop)                               | ~1 🟢      |
| Tue | 🟡 Light    | Docs, reading, small fixes, ADR drafting                 | 1 🟡       |
| Wed | ⚪ Relaxed   | Recovery: optional light planning, else rest            | 0          |
| Thu | 🟢 Deep     | Implementation                                           | ~1 🟢      |
| Fri | 🟠 Moderate | Lighter implementation: finish/refactor, prep next week | 1 🟠       |
| Sat | 🔴 Off*     | Karting: no engine work                                 | 0          |
| Sun | 🟢 Deep*    | Implementation + weekly review                           | **2-3 🟢** |

**Weekday deep ≠ weekend deep.** Mon/Thu are *after the day job*: one evening block, one
🟢 task. The weekend deep day is a **full day**: size it for **2-3 🟢**, not one. Sizing a
sprint by counting "deep days" without this split under-fills it by ~1 task/week.

*Weekend days are a **pair**, not fixed: default Sat off / Sun deep, but swap them or use
both when there's no karting. Guardrail: keep **≥1 rest day most weekends**. Mon-Fri
already carries 2 deep days.

## 🧭 Plan

Phase 1-3 compressed into Jul 19-26 (audit → plan → ground), each gating the next.
Build order from here: the [[Roadmap]] ladder: **chain M0-M6, then lanes**.

| # | Phase | What | State |
|---|-------|------|-------|
| 1 | **Deep v1 audit** | Read (not skim) each subsystem → deepen [[v1 Code Audit]] | ✅ done (Jul 19) |
| 2 | **Plan v2 + set up AI** | Foundation ADRs 005-008 · AI agents + ceremony loop | ✅ done |
| 3 | **Ground** | Git flow · build scaffold green on CI · `master` ruleset Active | ✅ done (Jul 24) |
| 4 | **Base foundation** | Logger · Assert · Clock · headless fixed-timestep loop, [[2026-08 Sprint 02 - Base Foundation]] | ✅ goal met (Jul 30); sprint closed Aug 2 |
| 5 | **Climb the ladder** | Chain M1-M6 (enablers · concurrency + serialization · project + testbed · window · Scene & scheduling · content), then the Phase 1 goals, [[Roadmap]] | ✅ **M1 done** (Aug 20) · ✅ **M2 done** (Aug 30) → ✅ **M3 editor testbed + M4 complete** · ✅ **M5 done** (Oct 9) · ✅ **M6 done** (Oct 31) · ✅ **E1 done** (Nov 14); 🔨 **E2** in progress since Sprint 11 |

_Tasks → [[Sprint Board]]._

## Quick links

- 📌 [[Roadmap]] · [[2026-Q4]]
- 🏃 [[Sprint Board]] · [[Backlog]]
- 🏛️ [[ADR Index]] · [[Known Issues]] · [[v1 Code Audit]] · [[Lessons from v1 (reference prototype)]]
- 🧠 [[Technical Lead Charter]] · [[Working with Claude - Operating Guide]]
- 📓 Journal: [[07 Journal]]
- 🔗 [[Research]] · [[References]]

## Active decisions

Recently locked. Full set in [[ADR Index]]:
- [x] **Resources and content packs** ([[ADR-024 - Resources (64-bit ids, value handles, async loads)]], [[ADR-025 - Content packs (.tepack and the runtime load path)]]):
  **Accepted Oct 10**, the first decisions of the decide-first trial. 64-bit ids with value
  handles counted per entry; async loads on the `JobSystem`, hard references in loading
  phases and soft references at the Tick barrier from A1; one `.tepack` per side, read by
  ranged reads; the bake ships only what scenes and settings assets reference; an extensible
  boot record names the startup scene. Closes M6's missing gate.
- [x] **Project system composition** ([[ADR-022 - Project system composition and self-description]]):
  **Accepted Sep 26**. Projects explicitly contribute available systems; the app selects
  persistent instances before simulation. Each selected system declares its access,
  handlers and ordering before graph build. The active set stays fixed for that session.
  Sep 26 amendments set next-Tick batch delivery without scheduled-reader cursors.
  S7-D1 settled handler declaration order and cut six implementation cards locally.
- [x] **System scheduling** ([[ADR-020 - System scheduling and task-graph execution]]):
  **Accepted Sep 12**, amended Sep 19. One Tick phase, component access declarations,
  numeric priority for conflicts and an immutable schedule. S6-T6-T9 shipped;
  shared-resource access waits for a concrete consumer.
- [x] **Threaded time model** ([[ADR-019 - Fixed simulation ticks, render interpolation and shared clock]]),
  **Accepted Sep 10** after S5-T14 review. Fixed simulation ticks, render-owned interpolation,
  one shared Clock, copied timing metrics, event-driven main thread and separate Tracy frame streams.
  Implemented and validated in #81 (`7d2546fc`); remaining hub drift is recorded in the Sep 12 retrospective.
- [x] **Main/simulation split** ([[ADR-018 - Main and simulation threads, render-owned GL]]),
  **Accepted Sep 7**. JobSystem also supplies dedicated-thread creation and registration;
  subsystem owners retain handles and stop/join control. S5-D3 closed Sep 8 with the accepted
  mechanism and seven sized cards. The topology and integration proof shipped in #81 (`7d2546fc`).
- [x] **Profiler** ([[ADR-013 - Profiler (Tracy-backed instrumentation)]]) + **Events/`StringId`** ([[ADR-014 - Events (buffered streams) & StringId]]): **both Accepted 2026-08-02**, both M1 gates closed, and M2's threading ADR is unblocked
- [x] **Threading** ([[ADR-015 - Threading (sim on main, render thread owns GL)]]) + **Serialization** ([[ADR-016 - Serialization (binary primitives & describe-once seam)]]): **both Accepted 2026-08-22**, both M2 gates closed on day 1. ADR-015 §3 amended 2026-08-24: the pool ships four workers, not one
- [x] **Bootstrapping** ([[ADR-017 - Bootstrapping (editor manifest, fixed runtime layout)]]):
  **Accepted 2026-08-31**, written mid-sprint out of S5-D1 against an artifact gate that had
  said no ADR was owed. `project.toml` is **editor-only**; the runtime mounts a fixed layout and
  reads no manifest; `app` owns the lifecycle through an `App` base class every executable
  subclasses. **Partially supersedes [[ADR-006 - v2 core architecture & module layout]] §1**'s
  "editor out of the frame loop" clause. It cut **Story F** into Sprint 05 and rewrote three
  Story B cards, which is where the 🟠 overload came from. The original implementation diverged on optional hooks and the entry point. #81 supplies optional hooks; the per-executable `main()` / `runApp<>()` wording still needs reconciliation ([[Backlog]]).
- [x] **Claude autonomous lane:** S5-P1, P2 and P3 are closed. The first code PR (#66)
  merged Sep 3. PR #88 moved attended work to OpenAI Codex; on Sep 26 the project returned
  to Claude and the Codex files were removed. The routine has run
  twice each weekday since Sep 27 (it was paused Sep 4-26); Sprint 07 gave it eight cards and
  it opened twelve PRs, all merged. Reports land one note per fire in
  `07 Journal/autoruns/<date>/`. Its cron was re-pointed for the Oct 25 clock change on Oct 23, and Sprint 08 gave it thirteen cards and ten PRs, all merged.
- [ ] renderer · netcode transport · scripting SDK · game UI → owed ADRs, each gating a rung ([[Roadmap]])
- [x] **How long is a sprint?** **2 weeks, decided 2026-08-20**, § *Rhythm*. Two sprints in
  a row closed with the calendar still running, and the unplanned tail is where momentum died.
- [x] **What happens when a ceremony's weekend is lost?** **Weekday fallback, 2026-08-20**:
  it runs the next Mon or Thu evening, time-boxed, and does not roll to the next weekend.
- [x] **Can an Accepted ADR be amended in place?** **Yes, resolved 2026-08-20 (S3-P1)**,
  [[ADR Index]] § *Amending an Accepted ADR*. The gate is how much argument the change needs,
  not whether a decision moved; the headline decision in a title is never amendable.

## Health check (2026-11-14)

- **Delivery:** Sprint 10 closed 41 of 43 cards. E1 is closed, R1's two ADRs are Accepted, and
  Story H shipped in full, a sprint ahead of its plan.
- **Evidence:** thin at the end. #203 and #204 were built on Linux, passed CI and merged with no
  review conversation and no windowed run. S11-T1 is the first run of that code on a real asset.
- **Sustainability:** Miguel reports "fine, but stretched". Sprint 11 packs its work into Nov 14
  to Nov 24, with three full days in a row on Nov 20-22, then karting and a vacation.
- **CI:** `win ASan`'s test step takes 4-6 minutes at twice the Linux rate. S11-D1's spike pushes
  spend minutes too, so batch them.
- **Artifact health:** reconciled against `6836c87` on Nov 14, a check of the systems Sprint 10's
  second week touched. The last full reconciliation was Oct 10.
