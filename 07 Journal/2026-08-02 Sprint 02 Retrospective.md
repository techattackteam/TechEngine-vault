---
type: retrospective
sprint: Sprint 02
date: 2026-08-02
---

# Retrospective — Sprint 02

Closed **6 days into a 5-week plan.** Goal met Jul 30, board emptied Jul 31. Sprint re-dated
**Jul 25 – Jul 31**; Sprint 03 takes **Aug 1 – Aug 28**, which leaves the already-published
**Aug 29–30** boundary intact. No downstream date moves.

Covers the final week too — `/weekly-review` did not run this weekend ([[Dashboard]] § Rhythm).

## 🟢 What went well

- **ADR-first paid.** S2-T1 landed day 1 and T2–T6 became transcription. The two planning
  assumptions it broke — `fmt`-in-header **unbuildable**, frame stamp **pushed** not pulled —
  were caught *before* code. That is the whole argument for ordering the artifact first.
- **15 cards, 12 PRs, green both legs.** No CI firefight, no revert, no force-push.
- **A bug became an invariant.** T2 shipped green-but-unreached; T3 answered it with a *rule* —
  every module's `src/` on the test include path, capture sinks **add** instead of replace, so
  no path exists that only runs under the default sink.
- **The vault split (ADR-012) went in mid-sprint without touching the goal.** Three cards,
  **zero 🟢 Deep slots**, recorded as an explicit scope change rather than absorbed silently.
- **Measured instead of assumed.** T7 measured Windows' 15.6 ms timer rather than trusting
  `sleep_for`: 120 frames × 16.67 ms ran **221** ticks. That is now evidence on a design note
  instead of a surprise three sprints out.

## 🔴 What wasted time

- **Two cards specified work that could not be done as written.** S2-T2 (the `fmt` seam) and
  S2-T8 (an injected time source) were both sized past an open decision. The rule that forbids
  it landed mid-sprint — this sprint is the evidence that earned it.
- **Two cards died on the board.** T9 had nothing left to wire by the time T7/T8 landed; T11
  (`te-module`) never found a moment to fire because scaffolding happens alongside dev work.
  Neither was wrong to plan; both were written against a future the intervening cards changed.
- **`TODO(S2-T9)` outlived its card.** The pacer stand-in now cites a descoped ID. Produced the
  `TODO(D<n>)` rule and [[Known Issues]].
- **S2-T4 cost four compile-fix commits**, mostly the Linux leg. RelWithDebInfo is run by hand
  (ADR-008 §9's minute budget), so the config→knob half of the assert table stays unproven in
  CI **by design** — a recurring cost, not a one-off.

## 🟡 Sustainability — the honest read

Weekday cadence **held**: Tue Jul 28 and Wed Jul 29 closed zero cards. Two breaches:

| Breach | Detail |
|---|---|
| **No rest day, opening weekend** | Jul 25 **and** Jul 26 both worked, against the [[Dashboard]] ≥1-rest-day guardrail |
| **Thu Jul 30 closed six cards** | T5, T7, T8, T9, T10, T11. A deep day absorbing six is not a deep day |

**The Sprint-01 rule was never tested.** "Finish early → the next deep day stays empty" targets
a sprint that runs *dry*; this one was **finished**, so the slack was never reached. It carries
into Sprint 03 untested, and Sprint 03 is sized to leave it 2 empty deep slots to be tested with.

**Rate, for sizing:** ~4–6 cards on a deep day — but they were small utilities behind an ADR
written first, and one rest weekend paid for it. Sprint 03 sizes **up materially, not
proportionally** (see its capacity note).

**Job + engine + karting balance:** Since the sprint was cut short so far is great

## 🔧 Process improvements (do next sprint)

- **A `B` card reaches the board the day it is created.** `S2-B1` was created Jul 31 and exists
  in **no column** — the exact evaporation S2-P1 claims to have closed. Carried as **S3-B1**.
- **ADR amendment policy.** ADR-011 was amended in place **twice** (ENSURE guard; rotation →
  truncate-on-open, `ef50f44`) while [[ADR Index]] says ADRs are immutable and changes need a
  superseding record. One of the two is wrong. → **S3-P1**.
- **Design-note coverage is a rung-level question, not a per-card one.** M1 has **seven** items
  and **one** note. Ask it when the rung opens, not when each card is written — asking late is
  how a rung starts artifact-less.

## 🤖 How AI helped (and where it didn't)

- **Helped:** drafting ADR-011/012 and the artifact-gate mechanics; catching that `S2-B1` had no
  home and that ADR-011 had been amended against its own index rule.
- **Didn't:** I'm still learning how to use the tool. It definitely failed to keep the backlog correct and the planning working flow is still shacky. Creating and making decisions on the fly instead of properly asking me.

## Carry-over to Sprint 03

| Item | State |
|---|---|
| **S3-B1** — diagnostics init belongs in `app`, not the exe | **carded** (from S2-T2's parked list → `S2-B1`, never boarded) |
| **D1** — `TE_LOG_ACTIVE_LEVEL` fails open | [[Known Issues]]; rides along with the next card touching the logging gate |
| **Frame pacing** — `App::run`'s spin-to-deadline stand-in | parked: [[Backlog]] → `app`, trigger (first unattended build) **not fired** |
| **Linux debugger-aware assert handler** | ADR-011 §6 wants an equivalent or explicit no-op; lands with `platform`, **not M1** |
| **Recorded demo artifact** | Sprint 02's DoD left it as "a new card if wanted" — **not pulled**; M1 is headless utilities, still nothing worth recording |
