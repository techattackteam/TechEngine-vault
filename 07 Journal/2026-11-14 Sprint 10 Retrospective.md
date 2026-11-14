---
type: retrospective
sprint: Sprint 10
date: 2026-11-14
---

# Retrospective: Sprint 10

## Outcome

41 of 43 cards closed: **24 Dev, 10 Design, 3 Bug and 4 Process**, and S10-B1 was folded into
S10-T10. Process was 10% of the sprint, all four of them report-only lane cards. E1 closed on
Nov 14 (S10-T7), both of R1's ADRs are Accepted (ADR-028, ADR-029), and all of Story H shipped,
although the plan allowed its build to open Sprint 11. The delivery record is
[[2026-10 Sprint 10 - Close E1]] § *Sprint review*.

- **Bugs:** S10-B2 was planned. S10-B3 (Nov 1) and S10-B4 (Nov 6) arrived mid-sprint and were
  stacked on top; neither has a scope-change note that names what it displaced.
- **Showcase:** none owed. E1 ended in an internal demo ([[Principles]] P4), and that demo never
  ran as one recorded run: S10-T7 closed on Miguel's statement.

## What went well

- **Decide first held for a whole new system.** The content pipeline went from no brief (Oct 31)
  to brief, design note, four design cards and thirteen build cards, all merged by Nov 14.
- **The lane's reports fed the designs.** S10-P4 read assimp's source and found two import traps
  before S10-D10 decided the mesh file; S10-P2 measured that CI's GL cannot run R1's floor.
- **The sanitizer legs caught what the reviews missed:** the ring's slot race (S10-T10), the
  destructor race (S10-T15, now D9) and the console's dangling record (S10-T11).

## What wasted time

- **Diff coverage failed the first push four times** (S10-T8, S10-T16, S10-T18, S10-B3), each on
  refusal branches that could not fire or had no test.
- **Design cards started before their inputs:** S10-D9 before S10-D4, and S10-D10 before
  S10-D7. S10-D9 then split in two and S10-D10 was narrowed.
- **`done:` clauses with no referent** on six cards (S10-T5, T15, T16, T18, T7, D3): no asset
  browser card, no re-import, no `ci.yml` exclude list.
- **Sprint 10 found its inputs missing after planning** (Miguel): TEMesh, materials and textures
  were all cut mid-sprint. S11-P1 adds the inputs check to `/sprint-prep`.

## Process improvements

- **A handed-over card gets Miguel's windowed check and a read of its decision list before
  `/card-close`.** #203 and #204 merged with no review conversation and nothing run in a window.
- **A mid-sprint bug gets its dated scope-change note**, naming what it pushes out.
- **A PR is cut from a card-named branch.** #203's branch names no card, and #204 carries two.

## How AI helped

Claude wrote most of Miguel's 🟢 cards at his request: S10-T8, S10-T14's reads, S10-T17, S10-T19,
S10-B2, and all of Story H's last six cards and Story F as subagent runs (#203, about 8,700
lines; #204). That is the pace, and it is also the risk: the sprint's largest PR was built on
`linux-debug`, passed CI and merged without a human read or a windowed run. Sprint 11's first
card (S11-T1) exists to pay that back. For R1, Miguel writes and Claude pairs (Nov 14).

## 🤖 Claude features

Story B (S10-D1, S10-T3, S10-T4) and S10-T6 shipped in three PRs (#179, #181, #188), all merged.
They list 21 decisions, and Miguel reversed **1**: Run exports first (#181). The lane stopped on
no card. The 14 decisions in #203 and #204 were accepted as merged, so they measure nothing.

## 🤖 Auto lane

Eighteen weekday fires from Nov 2 to Nov 12 (`autoruns/2026-11-02` to `2026-11-12`). **No report
exists for Fri Nov 13**, and the cause is not known; check the routine's run list.

- **Cards closed:** S10-D1, S10-T3, S10-T4, S10-T6 (🤖 Claude); S10-P1 to S10-P4 (report-only).
- **PRs:** eight (#179, #181, #188 and the sweeps #184, #185, #191, #195, #200), all merged.
- **Papers:** seven moved to *TO VALIDATE - MIGUEL REVIEW* (five on Nov 10, two on Nov 11). The
  column is empty again. No paper host is reachable from the sandbox, so both paper reports rest
  on search extracts and other engines' documents.
- **Runs that stopped:** none on an error. The Nov 12 `platform` sweep tried one fix, which did
  not build, and reverted it without a PR.

| Sweep (source / tests, lines) | Previous sweep | Before | After |
|---|---|---|---|
| `core` #184 | 6950 / 9555 (Oct 20) | 7844 / 11879 | 7819 / 11857 |
| `client` #185 | 875 / 535 (Oct 21) | 934 / 742 | 934 / 725 |
| `app` #191 | 952 / 1446 (Oct 22) | 1174 / 2078 | 1174 / 2065 |
| `apps` #195 | 1048 / 2040 | 6740 / 8540 | 6722 / 8509 |
| `base` #200 | 1521 / 1313 (Oct 29) | 1600 / 1575 | 1600 / 1569 |
| `platform`, no PR | 1812 / 2051 (Oct 30) | 2099 / 2292 | unchanged |

The sweeps removed 132 lines in all and filed leftovers for `core`, `apps`, `base` and
`platform`. `apps` grew more than six times since its last sweep, which is the editor.

## The prep

S10-D6 ran on Sat Nov 14, one day after its window and on the boundary itself, and S10-P2's
brief was five days stale by then. All 17 drafts survived the fit unchanged, because nothing
merged between the prep and the planning. Sprint 11's prep has one possible day, Tue Nov 24.

## Artifact drift

Checked against fetched `origin/master` at `6836c87`, the 12 engine commits since `e59d77c` (#193
to #204). The lane's freshness checks on Nov 10, 11 and 12 covered #193 to #201. For #203 and
#204, every note they touch was edited after the commit, and these claims were read against the
code: the shear approximation and its threshold ([[Scene - Design]]), the reload and the
completion that carries the payload ([[Resources - Design]]), the name-first match
([[Content Pipeline - Design]] § *Re-import*), `createFile` ([[File Access - Design]]) and the
three file kinds. `tools/check-vault-citations.py` found no new break. No build or test was run.

- **Fixed:** [[Resources - Design]] § *Handles, counts and the load lifecycle* still said a load
  task decodes into its entry's payload slot; since #203 the completion carries the payload.
- **Hub drift:** none in [[Scene - Design]]'s row against ADR-021's Nov 14 amendment, or in
  [[Resources - Design]]'s reload row against ADR-024 §9.
- **Not checked:** [[Renderer - Design]]'s and [[Content Pipeline - Design]]'s *Decided* rows
  against ADR-028 and ADR-029, and the rows S10-D6 added on Nov 14, which have no code yet.
- **Known and left:** [[Backlog]]'s apps-leftovers entry cites `ModelImportTests.cpp:133`, which
  #201 renamed; the next apps sweep corrects it.

## Sustainability

Miguel: **fine, but stretched.** Week 1 spent three off or light days (Sun Nov 1, Wed Nov 4,
Fri Nov 6), and Nov 7-8 was a race weekend, which is not rest. Sprint 11 packs its work into
Nov 14 to Nov 23, with Fri Nov 20 to Sun Nov 22 as three work days in a row, and then karting
and a vacation. Keep one of those three days free if the week has been heavy.

## Carry-over to next sprint

- **S10-T9** becomes S11-T14, 🤖 Auto. **S10-D5** becomes S11-D2, 🤖 Claude, by Miguel's
  exception to the gate ([[2026-11 Sprint 11 - First Frame]]).
