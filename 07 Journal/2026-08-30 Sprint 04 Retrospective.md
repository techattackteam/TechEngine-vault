---
type: retrospective
sprint: Sprint 04
date: 2026-08-30
---

# Retrospective — Sprint 04 (M2 Concurrency & Serialization)

**Closed 2026-08-30, day 9 of 14.** Goal met in full: both M2 ADRs Accepted on day 1, each
proven by first code against its real interface. 13 cards, all closed.
Boundary pulled forward to Aug 29-30 rather than Sep 5-6, so Sprint 05 starts a week early
([[2026-08 Sprint 05 — M3 Project & M4 Window]]).

**Kind mix: 7 Dev · 2 Design · 4 Process · 0 Bug.** Process was **31%** of the sprint.
Weight mix delivered: 5 🟢 · 4 🟠 · 4 🟡, with S4-P4 cut 🟠 and run as a 🟢.

## 🟢 What went well

- **Both gates closed on day 1.** ADR-015 and ADR-016 were Accepted 2026-08-22 with their
  design notes created alongside them. The mid-sprint checkpoint never had to fire, and no
  story ever sat under a week of runway.
- **The 2-week box did what it was adopted for.** Sprint 03 closed 8 days early of 4 weeks;
  this one closed 5 days early of 2. The overshoot shrank by more than half, and there was no
  empty stretch: the longest gap was the planned Tue/Wed rest pair.
- **Design notes held against the code.** Today's drift check found the shipped `JobSystem`,
  `FileAccess` and both formatter merges matching their notes exactly. Writing the note with
  the ADR rather than after it is what produced that.

## 🔴 What wasted time

- **Unplanned work entered twice with no card to hang it on.** #54 widened a required check;
  #56 merged S4-T3 inside an unrelated bug branch. Both changed the merge gate, and neither
  had a board card, so the sweep that should follow a scope change had nowhere to attach. Both
  findings surfaced days later at the drift check instead of at the merge.
- **The branch-name to card-ID link broke on three consecutive cards** (S4-T5, T6, T3). It was
  called out before the branch was cut on two of them and taken anyway. That link is the only
  path from a squashed commit back to its card (ADR-012 § *Consequences*).
- **Two cards merged their own verification out of reach.** S4-P1 and S4-P3 both needed a PR
  carrying engine C++ to prove anything, and both landed before one existed. They sat in Review
  for two days waiting on #59.

## 🔧 Process improvements (do next sprint)

- **Sizing, not discipline, is the fix for the overrun.** Every overrun this sprint was Process
  work, not engine work. That is what the 🤖 Auto lane exists to move, and Sprint 05 is its
  first real test.
- **A scope change to the merge gate gets a card, even mid-sprint.** #54 is the case. The card
  is what the ADR sweep and the B3 update attach to.
- **Do not merge a card whose proof needs a PR that does not exist yet.** Order it behind the
  card that proves it. S4-P1 and S4-P3 both paid two days in Review for this.

## 🤖 How AI helped (and where it didn't)

- **Helped:** both ADRs drafted and argued in one deep day each, with their design notes cut as
  hubs at the same time. Pre-merge review found the pool's four hang paths and the
  `BlobHeader` default that made a failed read look valid, none of which reached `master`.
- **Didn't:** it flagged the S4-T6 branch-name slip, gave the rename command, and the card
  shipped with the wrong prefix anyway. Flagging is not preventing, and this is the third card
  in a row where that gap cost the card-ID link.
- **New this sprint:** the autonomous lane went from idea to proven end-to-end in one day, with
  four probe findings that reasoning alone had gotten wrong. Its PR path is still unproven.

## ⚠️ Sustainability

**🟡, and the same finding for the third review running.** Fri Aug 28 is a 🟠 day and closed
four PRs. Thu Aug 27 closed three.

Rest days held where they were planned: Tue Aug 25 and Wed Aug 26 both zero commits.

**The weekend did not.** Sat Aug 29 ran the weekly review plus two merges, and Sun Aug 30 ran
two merges plus sprint planning. Zero rest days this weekend, against a guardrail asking for
one most weekends. Pulling the Sprint 05 boundary forward means there is no gap behind it
either, and Sprint 05 loses one weekend deep day (2-3 🟢) from its capacity as a result.

**Watch item for Sprint 05:** it is sized at zero slack in the 🟢 column and double in the 🟠.
That is a deliberate call, taken with the numbers on the table, and its cut order is pre-named
in the sprint note. If week 1 slips, cut rather than compress.

## Carry-over to next sprint

- **RNG and the crash handler carry for the third sprint running.** Still no consumer, still
  artifact-less. Worth a decision at the next boundary rather than a fourth silent carry.
- **Known Issues D1 and D2 are both carded.** D1 becomes the Auto lane's first code PR (S5-P2),
  having gone three sprints untouched, which is the list's own card-it-or-delete-it trigger.
  D2 becomes S5-T2, ordered before the M3 mount port that is its named trigger.
- Nothing else left the board unfinished. Every Sprint 04 card closed.
