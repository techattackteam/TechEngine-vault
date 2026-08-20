---
type: weekly-review
date: 2026-08-20
---

# Weekly Review — 2026-08-20 *(catch-up: Aug 3 to 20)*

Three weeks in one entry. The **Aug 8-9 and Aug 15-16 reviews did not run**, because no
weekend was available. Sprint [[2026-08 Sprint 03 — M1 Enablers]], weeks 2 to 4. Written on a
Thursday under the weekday-fallback rule adopted today.

## ✅ Completed

**Sprint 03's board is complete: 17 of 17 cards, 8 days early.** Both M1 gates closed Aug 2.

| Story | Cards | Landed |
|---|---|---|
| **B · math** | S3-T2 | Aug 3 · `5afb6d28` |
| **D · profiler** | T3 → T4 → T5 → T6 | Aug 3-8 · `7610b931` → `44a845f1` |
| **E · events + `StringId`** | T7 → T8 → T9 → T10 | Aug 4-8 · `7e4564db` → `ad47ec20` |
| **C · S2 loose ends** | S3-B1 | Aug 8 · `10258eec` |
| **F · file access** | T11 → T12 → T13 | Aug 10 · `da864fa5` → `a82a5c5d` |
| **G · process** | S3-P2 · S3-P1 | Aug 13 `42e32981` · Aug 20 `f52e332b` |

F30 closed at T13, F28 at T10.

## 🚧 In progress

- **Nothing.** In Progress and Review/Demo are both empty.
- **Sprint 04 is unplanned**, and that is the entire next slot.

## ⛔ Blockers

- None hard. Watch items unchanged: CI-minute budget · clang-tidy unproven on Windows ·
  Tracy's Linux leg never built in CI.
- [[Known Issues]] **D2** (`mount()` validates nothing, blocks M3) and **D3** still open.

## 📐 Artifact drift

Four findings against the 15 commits since the stamp. **D1 and D2 are live poison.**

| # | Where | Drift |
|---|---|---|
| **D1** | [[ADR-006 — v2 core architecture & module layout]] header, Aug-2 amendment | Reads §4's field as `IFileAccess& files` and claims the seam is unchanged. S3-T12 **deleted the interface** on Aug 10; `EngineContext.hpp:6` is a concrete `FileAccess&`. Needs a `decision` amendment, not the vocabulary one it carries. |
| **D2** | [[Profiler — Design]] `:46` *(a Decided row)* and `:200` | Both still cite ADR-013 §6's "under 5%". S3-P1 amended §6 to **+0.1377 µs** today and did not sweep its own note. The hub is read first, so the note overrides the amendment. |
| **D3** | [[Profiler — Design]] `:59` | The mermaid node says `base/Profile.hpp`; the prose at `:84` says `base/diagnostics/`. The note contradicts itself. |
| **D4** | [[Game Loop — Frame Flow]] `:102` and `:108` | Says `EngineContext` carries a `const Clock&`. It has one field, and `App.cpp:49` builds a local `Clock`. Written before T13 created the type. |

> **All four reconciled same day (2026-08-20).** D1 is a `decision` amendment on ADR-006's
> header plus inline markers at §4 and §5, per the policy S3-P1 landed hours earlier: the ADR
> did decide the seam, and a design note now says otherwise, which [[ADR Index]] § *What is not
> an amendment* names as an undeclared `decision`. D2 to D4 are living-note edits, no decision
> moved. Bonus: [[ADR Index]]'s *Partial supersessions* rows cited line numbers that had
> already drifted 6 lines, and D1's own header entry would have drifted them further, so the
> line refs are gone and the rule is now "cite the § and the clause".

Clean: [[Logger — Design]] · [[Assert — Design]] · [[Events — Design]] · [[StringId — Design]] ·
[[File Access — Design]] · [[Math — Design]]. S3-B1's and S3-T10's changes all propagated.

## 🎯 Objective for next slot

- **Run `/sprint-plan` and open Sprint 04, the first 2-week sprint.** Nothing is plannable
  while the board is empty, and Sprint 03's retro plus demo fold into it.
- **Reconcile D1 to D4 first**, before any `/card-start` session reads them.

## 🔋 Sustainability check

- **Two halves.** Aug 2-10 closed **13 of 17 cards**. Aug 14-19 was **six days with zero
  commits**. That was not planned rest: the board emptied and no weekend came to refill it.
- **Cadence held on weekdays** (Tue light, Wed off, Sun 9 off, Aug 15-16 off), with two
  overruns. Fri Aug 7 closed four PRs including a 🟢 Deep card. Mon Aug 3 and Mon Aug 10
  closed three cards each, on evenings sized for one.
- **The repeat.** Jul 25 already flagged "Friday moderate, delivered a deep day's volume".
  Aug 7 is the same failure, unchanged. Bank-the-slack is still untested.
- **The fix is structural, decided today.** 2-week sprints, so the plan and the calendar end
  together. A weekday ceremony fallback, so a lost weekend no longer costs 10 days. Job and
  karting balance held throughout.
