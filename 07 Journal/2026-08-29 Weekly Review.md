---
type: weekly-review
date: 2026-08-29
---

# Weekly Review — 2026-08-29

Sprint [[2026-08 Sprint 04 — M2 Concurrency & Serialization]], week 1 of 2. Also the
**mid-sprint checkpoint, and it passes**: both M2 ADRs were Accepted on day 1, no story is cut.

## ✅ Completed this week

**8 of 13 sized cards closed, plus 2 merged and held in Review.** 8 PRs, 4 working days.

- **Sat Aug 22** · S4-D1 · S4-D2 — both M2 ADRs Accepted, both design notes created as hubs.
- **Mon Aug 24** · S4-T4 · S4-T5 · S4-P2 — `a0d1d1b3` (#46), the job system and its capture.
- **Thu Aug 27** · S4-T2 · S4-T6 · S4-P3 — `4928447c` · `1ca9ae9c` · `a8aee849` (#47 to #49).
- **Fri Aug 28** · S4-P4 · S4-P1 — `fdca32c8` + `753a7c08` · `50ca9360`. Plus `e7562bf5`
  (#54), unplanned.

## 🚧 In progress

- **S4-T7** · 🟢 · the last piece of the sprint goal and of the Definition of Done.
- **S4-T1** · 🟠 · and **S4-T3** · 🟡. Side cards, still cut-first.
- **S4-P1 and S4-P3 in Review wait on the same thing, and one PR closes both.** S4-T7 carries
  engine C++, so it gives a warm ccache run and a real diff-coverage number in one matrix.

## ⛔ Blockers

- **None hard.** The two Review cards are held on purpose, not stuck.
- Watch, unchanged: CI-minute budget (16.1 billed minutes per PR) · clang-tidy unproven on
  Windows · Tracy's Linux leg never built in CI.
- **New watch: a workflow-only PR now gets no CI at all** (#54). `ci.yml`'s header carries the
  gotcha and the mitigation. Nothing in the vault does.

## 📐 Artifact drift

Three findings against the 8 commits since the stamp. **All three come from #54**, which
widened the CI skip list after S4-P4 had closed and documented the old scope.

| # | Where | Drift |
|---|---|---|
| **A1** | [[ADR-008 — v2 build & testing baseline]] header, 2026-08-28 amendment | Names the exclusion as `**.md` or `.claude/**`. `ci.yml` has a third entry, `.github/workflows/**`. An Accepted ADR understating its own gate. |
| **A2** | [[B3 — Build & Testing Notes]] § *Docs-only PRs* | **Actively false, not just stale.** It says the workflow files "still run the full matrix". They are the one thing that no longer does. A reader grounding here concludes the opposite of the truth. |
| **A3** | [[ADR-009 — Branching strategy & merge rules]] § *Consequences* | "Correctness leans on strict CI" now has an uncovered exception. S4-P4 pre-named this test, answered it correctly for docs, and nobody re-asked it when #54 widened the scope past docs. |

Clean: [[Concurrency — Design]] and [[Serialization — Design]] both match shipped code.

**Reconciled same day.** A1 and A2 are edits, no decision moved: ADR-008's amendment names the
third path and carries a *Corrected* marker, and B3's section is rewritten with the workflow
self-test gotcha promoted to its own bullet. **A3 is carded on [[Backlog]]**, not fixed here,
because it is a decision on an Accepted ADR rather than a sweep.

**Process gap, and the second half of the same finding.** #54 had **no card and no Done entry**,
so its only vault record was a clause inside S4-P1's board text. **Folded into S4-P4** on both
the board and the sprint note rather than given its own card: it landed hours after that card
closed and is the same scope. A merged PR that moves a required check should not be findable
only by reading a different card.

## 🎯 Objective for next week

- **S4-T7 first.** It closes the sprint goal, the Definition of Done, and both Review cards.
- ~~Reconcile A1 to A3~~ **A1 and A2 done 2026-08-29; A3 is on [[Backlog]] for Sprint 05.**
- Then S4-T1 and S4-T3. Both fit the light and moderate days.

## 🔋 Sustainability check

- **Energy good, rest days held.** Sun Aug 23 off, Tue Aug 25 and Wed Aug 26 both zero commits.
- **The overrun is unchanged, and this is the third review in a row to say so.** Mon Aug 24 and
  Thu Aug 27 each delivered 1 🟢 + 1 🟠 + 1 🟡 on an evening sized for one 🟢. Fri Aug 28 closed four PRs on a 🟠 day. Jul 25 flagged it, Aug 20 called it unchanged, and bank-the-slack is still untested after three sprints.
- **What is new is where it happened: every overrun was process work, not engine work.** The
  deep days went to M2 as planned. So the fix is **sizing, not discipline**. S4-P4 was sized 🟠
  and was a 🟢 day's work (Miguel's call); S4-P1 was sized 🟡 and spilled across two PRs and a
  sequencing mistake. **Proposal for Sprint 05: a process card touching the merge gate is 🟢,
  never 🟡.** That is testable next sprint, which "bank the slack" never was.
- **Lead-side failure, recorded because it cost real time.** On S4-P1 I went in circles and
  kept pulling in adjacent work. The board's own retro shows the shape: the #54-before-#53
  sequencing was called out and taken anyway, which merged the card's verification out of
  reach. Job and karting balance held.
