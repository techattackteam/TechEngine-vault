---
type: weekly-review
date: 2026-11-21
---

# Weekly Review: 2026-11-21

Sprint 11, day 8 of 14. Covers Sat Nov 14 to Sat Nov 21. [[Sprint Board]] holds every card's
record.

## Completed this week

- **The sprint goal is met.** The exported runtime drew Sponza, textured with base color,
  through the scene's main camera on Nov 20 (S11-T9 with S11-T1, #220), with Miguel's windowed
  check and a screenshot.
- Day 1 settled CI and testing: zink gives CI the GL floor (S11-D1), the tests run in tiers and
  in parallel (S11-D5, #205), and the window asks for GL 4.6 with bindless textures (S11-T2,
  #206).
- Story B built R1's path to the first frame: the device (S11-T3, #207), frame packets in place
  of the snapshot (S11-T4, #210), ordered uploads under render's fence (S11-T6, #213), shared
  geometry buffers (S11-T7, #217) and the material buffer with bindless textures (S11-T8, #219).
- Story C closed: the scene and game views are render targets (S11-T10, #221), and the scene
  view has a fly camera (S11-T11, #222). The fly camera's controls were redesigned twice after
  Miguel's windowed checks.
- The lane merged eight PRs: the camera component (S11-T5, #208), S11-P1 (#209), S11-T12 (#211),
  S11-T14 (#212), the README (S11-P2, #214), the whole-scene queries (S11-T15, #215), and the
  `core` and `client` sweeps (#216, #218). No lane PR is open.
- S11-D3 designed the asset browser ([[Content Pipeline - Design]] § *The asset browser*).
  Re-import is removed, and Story G (S11-T17 to S11-T24) joined this sprint to carry freely.
- Three of the five Definition of Done lines are met.

## In progress

- S11-D3's design is committed (vault `f6706cd`), and `/card-close` is still owed.
- Open cards: S11-T16 (render drops its GPU copies), S11-D2 (the cinematic showcase triage),
  the lane's S11-T13, S11-P3 (not before Mon Nov 23), S11-D4 (Tue Nov 24) and Story G.

## Blockers

- None block Sprint 11; its goal is met.
- For Sprint 12, the asset edit path is still not designed, so a material cannot be edited in
  the editor ([[Backlog]] § *editor & tooling*).
- E2 has no showcase outline. `/showcase E2` is owed before the sprint that ends E2.

## Artifact drift

Checked against fetched `origin/master` at `a4c65ce`, the 18 engine commits since `6836c87`
(#205 to #222). `tools/check-vault-citations.py` ran at both commits with the same excludes
(journal, research and closed sprint notes): 117 breaks now against 122 before, and four new
ones, each opened in the code. No build or test was run.

- **Hub drift:** none found. [[Renderer - Design]]'s rows on how a draw finds its data, the four
  textures and the draw buckets match ADR-028 §2 (amended Nov 20) and ADR-029 §4 and §7.
- **Fixed:** the [[Editor - Design]] row *Edits publish through their own hook* gave a reason
  that #210 removed. It now cites `PacketHistory.cpp:33`, where render takes a same-tick
  packet with a newer sequence. [[Content Pipeline - Design]] now cites `Mesh.cpp:175`.
- **Reconciled at Miguel's go:** the snapshot path that S11-T4 replaced is now the packet path in
  [[Game Loop - Frame Flow]] (status, two Decided rows, the diagram, publication, § *Packet
  acquisition and alpha*, the payload and the handoff table), [[Simulation Thread - Design]]
  (three Decided rows, the diagram, § *Render handoff and pacing* and the `publishFrame`
  lifecycle row), [[Editor - Design]] (the channels diagram and § *Commands and the idle
  simulation*), [[Project - Design]], [[Window - Design]] and § *References* in
  [[Renderer - Design]]. [[Window - Design]] also moved from GL 4.5 to 4.6 with bindless, and
  from M4's wrappers to `RenderDevice`. Each passage was checked against
  `SimulationThread.cpp`, `PacketHistory.cpp`, `Window.cpp` and glad's header at `a4c65ce`.
- **History, not drift:** ADR-028's *Context* cites the deleted `SnapshotMailbox.cpp` and
  `SnapshotHistory.cpp`, because it describes what came before.
- **Backlog, corrected:** `Window.cpp:59-60`, `apps/editor/CMakeLists.txt:99`, and the comma
  test names now at `a4c65ce`. Four finished entries were deleted at Miguel's call: toml++ in
  `core` (dropped by #216), the `Mesh.cpp` citation, the six snapshot notes and Window's GL 4.5.
  The stale glad command and every `#version 450` in the engine were moved to 4.6 in the working
  tree, not yet in a PR.
- **The citation checker** now reports 113 breaks, down from 122 at `6836c87`. Those left are v1,
  assimp and older citations that this week did not touch.
- **Not checked line by line:** the *as built* sections that #219 to #222 added, beyond the
  checker. Each was written at its card's close this week.
- **The stamp moves to `a4c65ce`.**

## Objective for next week

Close S11-T16 and run S11-D4's `/sprint-prep` on Tue Nov 24. Start at most one Story G card
before it (S11-T19 or S11-T23); the rest carries into Sprint 12.

## Sustainability

- **Miguel reports his energy as good.** Since he has had no car after last month's accident,
  he goes to the office one day a week, which leaves more engine time than the Rhythm table
  assumes. He also took Fri Nov 20 off work and spent it on the engine. That is why most of the
  sprint closed in one week and Story G had to be cut early.
- **The week ran outside the table's shape, by choice.** Sun Nov 15 had no engine work, and Wed
  Nov 18 had only lane merges. The light Tuesday shipped S11-T6, Fri Nov 20 closed four cards,
  and Sat Nov 21, the default day off, shipped S11-T11, S11-D3 and this review.
- **Sunday Nov 22 is a full deep day**, Miguel's plan. With Saturday worked, this weekend has no
  rest day, and the Rhythm table asks for one most weekends. Karting on Thu and Fri and the Nov
  28-29 vacation are the rest that follows.
- **Scope grew twice on Nov 21.** S11-T11 grew in the session, and S11-D3 turned into a
  re-import removal plus eight cards. That is the extra capacity being used, not overreach,
  and Story G carries into Sprint 12 freely.
- **The capacity is temporary.** It ends when Miguel has a car and goes back to the office more
  days, so Sprint 12's sizing should ask whether it still holds rather than assume it.
