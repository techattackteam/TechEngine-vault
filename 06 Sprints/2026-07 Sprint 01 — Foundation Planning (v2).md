# 2026-07 · Sprint 01 — Foundation Planning (v2)

- **Quarter:** [[2026-Q3]]
- **Dates:** Jul 19 to 26, 2026. A short, special first sprint. The regular cadence starts at
  **Sprint 02**.
  *(This was planned as a monthly sprint. That was superseded on 2026-07-26 by the 4-week
  Sat-to-Fri rule, on [[Dashboard]] → Rhythm. The prose below still says "monthly", because it
  records what was true at the time.)*
- **Epic:** Foundation & Direction
- **Decision behind it:** [[ADR-004 — Fresh start (v2) with v1 as reference]]

## 🎯 Sprint goal

> Stand up the v2 foundation. Mine v1 for lessons, decide the architecture on paper, set up
> the operating model, and get a build skeleton compiling **green on CI**. It ends with the
> first ceremony, on Jul 26.
>
> Design before code. The plan exists before the engine.

This was a special short sprint. The timeline collapsed into the **Jul 19 to 26** window: the
audit was pulled forward to Jul 19, and the ADRs landed the same week.

So it ran audit, then design, then ground, back to back, rather than spreading across a month.
The regular rhythm begins at Sprint 02.

## ✅ Delivered

- **A deep v1 audit**, written up as [[v1 Code Audit]] (F1 to F35), with the salvage verdicts
  in [[Lessons from v1 (reference prototype)]].
- **The v2 foundation ADRs, all Accepted:** [[ADR-005 — v2 tech stack & toolchain]] ·
  [[ADR-006 — v2 core architecture & module layout]] ·
  [[ADR-007 — v2 networking & ECS replication foundation]] ·
  [[ADR-008 — v2 build & testing baseline]].
  *(B2, the renderer, and B4, the conventions, were **deferred** to the [[Backlog]]. They get
  written when coding starts.)*
- **The AI operating model:** the technical-lead and scrum-master role, 5 commands, 3
  subagents, and the weekly and sprint cadence. See [[Dashboard]] and
  [[Technical Lead Charter]].
- **Git flow (C1):** `v1-reference` is tagged, and `v2` is the working mainline. *(Miguel)*

## ✅ Story C — first buildable slice

The build scaffold became the first CI-green skeleton, landing on **Jul 24**. The day plan is
below.

**C2**, the first v2 vertical slice, was defined at the Jul 25 ceremony and **re-sequenced to
Sprint 03**. Sprint 02 lays the base foundation first.

## 🗓️ Week of Jul 20 to 26, then the Sprint 02 ceremony

*As planned at the time.* The deep days start the build scaffold, following
[[ADR-008 — v2 build & testing baseline]]'s checklist. The month's last weekend, Jul 25 to 26,
is the first true ceremony.

| Day | Mode | Plan |
|-----|------|------|
| Mon 20 | 🟢 Deep | Scaffold part 1: `cmake/` helpers, the top `CMakeLists`, `CMakePresets`, and 5 library skeletons compiling with the public/private split |
| Tue 21 | 🟡 Light | **Free.** Command polish was pulled forward to Sun 19. |
| Wed 22 | ⚪ Relaxed | Rest. Optionally, consolidate the stale memory tail. |
| Thu 23 | 🟢 Deep | Scaffold part 2: the leaf executables (`apps/runtime`, `editor`), `te_base_tests` on Catch2 and CTest, `sdk/`, `te_sdk_smoke`, and `.clang-format` / `.clang-tidy` |
| Fri 24 | 🟠 Moderate | `ci.yml`, covering the build matrix, tidy, ctest, sanitizers and the SDK smoke, taken to green. **Then the GitHub repo setup** if it is green: branch protection, §9's required checks, and visibility. Then backlog grooming. |
| Sat 25 / Sun 26 | 🟢 Deep + 🔴 Off | Ceremony weekend. One day covers the weekly review plus the **Sprint 01 demo, retro and Sprint 02 planning** (`/sprint-plan`). The other day is off, for karting. |

**Demo target for the weekend of Jul 25 to 26.** The v2 skeleton builds **green on CI** on both
legs, and the tests plus the SDK smoke pass. The GitHub repo task is gated on `ci.yml` going
green first.

## Definition of Done

- [x] The deep audit is complete, with salvage verdicts filled in.
- [x] The v2 foundation ADRs are **Accepted**: stack, architecture, networking, build and
      testing.
- [x] The AI collaborators are set up: agents, role and commands. *(The v2 `CLAUDE.md` and
      prompt refresh, plus the code conventions, were deferred to B4 and to coding.)*
- [x] `v1-reference` is tagged, and `v2` is the mainline.
- [x] The build skeleton compiles **green on CI**, as of Jul 24.
- [x] Sprint 02 has a concrete headline goal, set Jul 25
      ([[2026-08 Sprint 02 — Base Foundation]]).

## Capacity note

The weekly rhythm lives on the [[Dashboard]]. Respect it.

If a deep session runs long, stop and continue on the next deep day. Do not force it into one
sitting.

## Sprint review, closed 2026-07-25 ✅

- **Lessons captured.** [[v1 Code Audit]] F1 to F35, plus the salvage verdicts in
  [[Lessons from v1 (reference prototype)]].
- **Architecture decided.** ADRs 005 to 009 are **Accepted**, covering the stack, the module
  layout, networking and the ECS, build and testing, and branching. ADR-010 was deliberately
  held at **Proposed**.
- **Ground laid.** The scaffold is **green on CI** on both legs, `ctest` is 3 of 3, and
  `master`'s ruleset is Active.
- **First slice defined**, and re-sequenced. Sprint 02 lays the **base foundation**
  ([[2026-08 Sprint 02 — Base Foundation]]), and the C2 vertical slice moves to **Sprint 03**.

→ Retrospective: [[2026-07-25 Sprint 01 Retrospective]] · Week detail:
[[2026-07-25 Weekly Review]]
