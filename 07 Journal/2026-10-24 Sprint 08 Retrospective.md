---
type: retrospective
sprint: Sprint 08
date: 2026-10-24
---

# Retrospective: Sprint 08

## Outcome

All 36 cards closed: **21 Dev, 4 Design, 0 Bug and 11 Process**. Process was 31% of the
sprint, but 8 of those 11 ran in the Auto lane; the attended Process cards were S8-P8, S8-P9 and
S8-P11. S8-D3 carries a Design ID, but after its rescope it was CI work. The goal was met on
Oct 15 (day 6) and the P2 stretch on Oct 18; week 2 was refilled with Story I on Oct 19. The
delivery record is [[2026-10 Sprint 08 - Content Path]] § *Sprint review*.

## What went well

- **Deciding first worked for the goal.** ADR-024 and ADR-025 were accepted on day 1, the slice
  shipped by day 6, and S8-D1 and S8-D2 decided and cut Sprint 09's work inside week 2. The trial
  became the rule on Oct 23 ([[Planning Workflow - Artifact Gate]] § *Decide first, then plan*).
- **A PR's first push went from 17.5 to 4.9 minutes** (S8-D3), because the card was rescoped at
  `/card-start` to the real goal before any work started.
- **The lane carried 13 cards and three sweeps with no merge conflict** against an attended
  sprint that touched `core`, `app` and `apps/` every week.

## What wasted time

- **Deciding first did not reduce the card-level forks.** 13 of the 16 attended Dev cards still
  settled at least one call at `/card-start` that no artifact had made, against 9 of 10 in
  Sprint 07. The forks were smaller (a signature, an error code, a channel, a test-access
  shape), but most `done:` clauses still named something that did not exist yet.
- **Six cards shipped on another card's branch** (S8-T2, S8-T14, S8-D3, and the stacked S8-T7,
  S8-T9 and S8-T11). For S8-T2, S8-T14 and S8-D3, the board entry is now the only link from the
  squashed commit back to the card.
- **Most attended PRs have no body and no review conversation**, so the board's Done entries are
  the only record of the calls made in them. That is why those entries grew so long.
- **Fri Oct 23 was planned light and was not.** It carried S8-P11 (its scope grew twice), the
  vault's new product layer and the first `/sprint-prep`, in commits until 22:11.

## Process improvements

- **A draft card names every referent it cannot point at, and says it is settled at
  `/card-start`**, as Sprint 09's first card already does for its function's name and header.
  The Sprint 09 retro counts planned forks against discovered ones.
- **When two cards ship on one branch, the PR title carries both IDs**, so the squash message
  keeps the link that the branch name cannot.

## How AI helped

Claude wrote most of the file-handling code at Miguel's request: nearly all of S8-T3, the pack
reader in S8-T4, most of S8-T5, the index in S8-T6, `exportTo` in S8-T7, the load in S8-T9, and
the cache in S8-T10. Miguel says that is why the sprint went well. It is also why the cards
closed early against estimates that assumed Miguel wrote them, and it led to the Oct 23 split
of who writes the code ([[Technical Lead Charter]] § *Who writes the code*). The rework it caused:
S8-T3's reader accepted more than the format needed (`/card-review` cut it), S8-T5 first
proposed an error enum that broke ADR-023 §2 and failed the format gate in four files, and
S8-T7's tests relied on a false claim that mounting a missing folder fails.

## 🤖 Auto lane

Every one of the 20 fires (Oct 12-23) wrote a report, in folders `autoruns/2026-10-12` to
`autoruns/2026-10-23`.

- **Cards closed: 13** (S8-P1 to S8-P7, S8-P10, S8-T12, S8-T15, S8-T16, S8-T17 and S8-T20).
- **PRs: 10 opened, 10 merged**: seven card PRs (#130, #133, #135, #136, #137, #140 and #144) and
  three sweeps (#149, #150 and #152). S8-P2, S8-P3, S8-P4, S8-P6, S8-P7 and S8-P10 were
  report-only or vault-only.
- **Stopped runs: one.** On Oct 19 at 14:15, the sandbox refused S8-P8's edit to the lane's own
  prompt as instruction poisoning, so the card moved to attended work. The Oct 20 fire then
  proved that the lane can still edit the board.
- **Papers: 15 screened** (Oct 21-23): 3 could not be resolved, and 3 are recommended rejects.
  25 wait in *MIGUEL REVIEW*, and only 2 are left to screen.
- #144's body kept the harness's attribution footer. The prompt pasted on Oct 23 re-sends the
  body to strip it, which no PR has tested yet.
- **🤖 Claude features: none.** The gate was decided on Oct 23, and Sprint 09's mesh path is the first.

| Module | Sweep | Source lines (previous) | Test lines (previous) | Net removed |
|---|---|---|---|---|
| `engine/core` | Oct 20, #149, 10 leftovers filed | 7074 → 6950 (5118, Oct 1) | 9581 → 9555 (6251) | 150 |
| `engine/client` | Oct 21, nothing to fix or file | 875 (813, Oct 5) | 535 (507) | 0 |
| `engine/app` | Oct 22, #150 | 952 (865, Oct 6) | 1464 → 1446 (1154) | 18 |
| `apps/` | Oct 23, #152 | 1048 (962, Oct 7) | 2048 → 2040 (507) | 8 |

`engine/core` grew by about 1,950 source lines and 3,300 test lines since its Oct 1 sweep: the
resources, assets and scene-asset code of M6.

## Prep and showcase

- **Prep:** S8-D4 ran on Fri Oct 23, the sprint's last evening, with no prep brief, because the
  split was decided the same day. All 14 of its drafts survived the boundary's first step unchanged.
- **Showcase:** none owed. M6 has no video, and E1 does not end in Sprint 09.

## Sustainability

Miguel says the sprint went well, mostly because Claude wrote much of the file-handling code.
Week 2 was hard, mainly because of a car crash. The rib injury kept him off karting, and no
weekend had a rest day. He chose to work both days of the Oct 24-25 weekend as well. Sprint 09
is sized so that its stretch (E1's first panels) absorbs that, and its next weekend keeps one
rest day.

## Carry-over to next sprint

- No card carries; every Sprint 08 card closed.
- The drift check advanced the stamp to `19f57f6` after reconciling ADR-024 §8, ADR-006, ADR-008
  and three design-note lines ([[Dashboard]] § *Now*).
