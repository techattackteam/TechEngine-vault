---
type: retrospective
sprint: Sprint 11
date: 2026-11-27
---

# Retrospective: Sprint 11

## Outcome

33 of 33 cards closed: **25 Dev, 5 Design, 0 Bug and 3 Process**. Process was 9% of the
sprint, and two of the three were lane cards. The goal was met on day 7 (S11-T9, Nov 20). 21
cards were planned and 12 were added mid-sprint: S11-D5, S11-T15, S11-T16, S11-T25 and Story G's
eight. Nothing carries over. The delivery record is [[2026-11 Sprint 11 - First Frame]]
§ *Sprint review*.

- **Bugs:** none were carded. [[Known Issues]] D14 and D15 opened and closed inside the sprint
  (S11-T16, S11-T22), and D10 left with re-import (S11-T17).
- **Showcase:** none owed, because E2 does not end here. S11-D2 added rung T9, camera paths, to
  E2's showcase on Nov 27.

## What went well

- **The first frame landed on day 7.** Decide first held for R1: ADR-028 and ADR-029 were
  Accepted before the sprint, so its nine build cards started with no design open.
- **`/card-review` caught real defects before every R1 merge:** eleven in S11-T3, six in S11-T7,
  five in S11-T8, nine in S11-T9 and five in S11-T6.
- **Miguel's windowed checks found what green suites missed:** S11-T10's clear-colour editor,
  S11-T11's dead rotation and S11-T21's two dead menu entries.
- **Story G went from design to merged in a week.** S11-D3 designed the browser on Nov 21, and
  all eight of its cards merged by Nov 27.

## What wasted time

- **Most attended PRs carry no description** (#207, #210, #213, #217, #219 to #221, #225, #227,
  #229, #236), and most of those titles carry no card ID. Every Done entry had to be rebuilt from
  the session.
- **Cards grew and were never re-sized:** S11-T4 (4-6h, 57 files), S11-T10 (🟠, ran as 🟢) and
  S11-T21 (🟠, several times that). The sprint's sizing record is wrong for all three.
- **Diff coverage failed the first push three more times** (S11-T7, S11-T10, S11-T17), each at 84%.
- **S11-T9's first frame came out white**, because nothing ordered it after S11-T1's textures.

## Process improvements

- **The lane's prep card runs after the prep**, at Miguel's call (Nov 27): `/sprint-prep` sets
  the theme, then the lane checks the cut for what it missed ([[Planning Workflow - Artifact
  Gate]] § *Decide first, then plan*). S12-P2 changes the commands.
- **Every sprint takes at least one [[Backlog]] entry, ideally two or three** (Miguel, Nov 27).
  A pulled entry that turns out invalid may be dropped mid-sprint, said out loud.
- **A card that grows at `/card-start` gets a new weight there**, so the record shows its real size.

## How AI helped

Claude wrote much of Miguel's work at his request: all of S11-T24 (a 🟢), most of S11-T21, every
ImGui function in S11-T22, the v1 port in S11-T20, and S11-T16's scaffold and fixes. That kept
the pace, but S11-T24's local Windows build wiped `build/windows` on its first try, and its
dialog was not checked in a running editor before the merge.

## 🤖 Claude features

S11-T5 (#208), S11-T11 (#222) and S11-T23 (#231) shipped, all merged. They list 18 decisions, and
Miguel reversed **2**, both in S11-T11's session (the WASD speed model and the teleported cursor).
The lane stopped on no card.

## 🤖 Auto lane

18 reports for 20 weekday fires (`autoruns/2026-11-16` to `2026-11-27`). **The Nov 25 and Nov 27
morning fires left no report and no commit**, and the cause is unknown; check the routine's run list.

- **Cards closed:** S11-P1, S11-T12, S11-T14, S11-P2, S11-T15, S11-T13, and S11-P3 (report-only).
  S11-T17 ran in an attended session acting as the lane.
- **PRs:** #209, #211, #212, #214, #215, #228 and five sweeps (#216, #218, #232, #237, #238), all merged.
- **Papers:** none. *TO VALIDATE* was empty all sprint.
- **Runs that stopped:** S11-D2 sat in To Do for three fires, because the lane never runs a
  Design card; it was retagged 🟡 Light on Nov 17.

| Sweep (source / tests, lines) | Previous sweep | Before | After |
|---|---|---|---|
| `core` #216 | 7819 / 11857 (Nov 4) | 9199 / 15626 | net −1 from the lane |
| `client` #218 | 934 / 725 (Nov 5) | 2682 / 2893 | 2667 / 2893 |
| `app` #232 | 1174 / 2065 (Nov 6) | 1184 / 2173 | 1184 / 2153 |
| `apps` #237 | 6740 / 8540 (Nov 10) | 12360 / 15698 | 12336 / 15656 |
| `base`, no PR | 1600 / 1569 (Nov 11) | 1588 / 1551 | unchanged |
| `platform` #238 | 2099 / 2292 (Nov 12) | 2168 / 2450 | net −1, tests only |

The sweeps removed about 100 lines and filed leftovers for every module. `client` nearly tripled
and `apps` nearly doubled since their last sweeps: that is the renderer and the asset browser.

## The prep

S11-P3's brief ran Mon Nov 23 and S11-D4 ran Tue Nov 24, inside its window. All 17 drafts
survived the fit unchanged. Miguel added two fired Backlog entries as Design cards, and the
fit added S12-P2 for the new prep order.

## Artifact drift

Checked against fetched `origin/master` at `f89e866`, the 17 engine commits since `a4c65ce`
(#223 to #239). `tools/check-vault-citations.py` ran at both commits with the Nov 21 excludes:
112 breaks at `f89e866`, and none new. No build or test was run.

- **Fixed:** [[Content Pipeline - Design]] named three symbols the code lost
  (`RegisterImportedAssetsCommand`, `uniqueSlotName`, `drawImportImagePopup`) and still asked
  which way a texture is sampled. [[Renderer - Design]]'s fly camera lock now names raw motion and
  ImGui's `NoMouse` (#226).
- **Hub drift:** none. Content Pipeline's *No re-import* row matches ADR-024's Nov 21 amendment,
  Resources' missing-id row matches S11-T23, and Renderer's *GPU copy's lifetime* row matches
  ADR-028 §4 as S11-T16 built it.
- **Not checked:** the *as built* sections from #225 to #239 were not read line by line.
- **[[Backlog]]:** two finished entries deleted (the two drift entries above). Two fires marked:
  the null render device (S11-D5, Nov 14) and the create's progress window (S11-D4, Nov 24). One
  citation corrected (`AppTests.cpp:1292`), and the Sponza entry now asks only for the credit.

## Sustainability

Miguel: **the sprint went well.** It started too empty for his real capacity, so he added cards:
12 of 33 arrived mid-sprint. Working from home four days a week still holds (Nov 27), so evenings
run longer than the Rhythm table assumes. The work packed into Nov 14 to Nov 24, with Nov 20-22 as
three full days in a row, then karting and the vacation. Sprint 12 sizes to that capacity.

## Carry-over to next sprint

- None. Every card merged, and no card was dropped.
