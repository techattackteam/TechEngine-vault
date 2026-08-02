---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 To Do — [[2026-08 Sprint 03 — M1 Enablers]] (Aug 1 – Aug 28)

- [ ] **S3-D2** — Events + `StringId` ADR (`/adr`, F28) · P1 · 🟢 Deep — unsound unsubscribe +
	  per-event alloc; **names the event-id type**, which pins `StringId`. Closes
	  [[Game Loop — Frame Flow]]'s *Event dispatch point*. **Cuts Story E.**
- [ ] **S3-B1** — Diagnostics init belongs in `app`, not the exe · P1 · 🟠 Moderate — carried
	  from `S2-B1`, which was created Jul 31 and **never reached this board**. Not droppable.
- [ ] **S3-T1** — `Math.hpp` alias set ([[Math — Design]]) · P1 · 🟠 Moderate — no
	  `GLM_FORCE_*` handedness/depth defines; that call is the renderer ADR's.
- [ ] **S3-D3** — `IFileSystem` design note (F30) · P2 · 🟠 Moderate — mount/virtual-path
	  scheme · sync vs async · error model · which module implements it. **Cuts Story F.**
- [ ] **S3-T2** — `Math/Format.hpp` + tests · P2 · 🟡 Light — separate header from the types,
	  so `<format>` stays opt-in.
- [ ] **S3-P1** — ADR amendment policy · P2 · 🟡 Light — ADR-011 amended in place twice vs
	  [[ADR Index]]'s immutability rule. One of the two is wrong.
- [ ] **S3-P2** — Skill `te-review` · P3 · 🟡 Light — **first to cut.** Dry-run must find
	  something real or the rubric gets trimmed.
- [ ] **S3-T3** — Tracy dep + `TE_PROFILE` option + profile presets · P1 · 🟢 Deep — Story D's
	  head. **Riskiest card of the story:** `/W4 /WX` hits Tracy's header inside our own TU and
	  the `SYSTEM` fix needs CMake 3.25 (we require 3.21). Spike is its first hour.
- [ ] **S3-T4** — `base/Profile.hpp` + frame mark · P1 · 🟠 Moderate — **the sprint's demo**:
	  a profiled capture of the headless loop. Needs S3-T3.
- [ ] **S3-T5** — memory tracking: global `new`/`delete` replacement · P2 · 🟠 Moderate —
	  lives in `app`'s TU, never a `base` static-lib TU. Needs S3-T4.
- [ ] **S3-T6** — overhead number + coverage statement · P2 · 🟡 Light — < 5% bar into
	  [[B3 — Build & Testing Notes]]; says out loud that the ON path is not unit-tested.
- [ ] ⏳ *Pointer, not a card* — **Stories E / F stay unsized.** Their ~6–8 cards get cut by
	  S3-D2 / S3-D3's own done-conditions. **Story D was cut Aug 2** (S3-T3…T6, off ADR-013).
	  Weight budget in the sprint note.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 03 — M1 Enablers]]

- [x] **S3-D1** — Profiler ADR (`/adr`) · P1 · 🟢 Deep — **Aug 2.**
	  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] Accepted; [[Profiler — Design]]
	  rewritten as the living *how*; Story D cut into S3-T3…T6.
	  **M2's threading ADR is unblocked.**





%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null]}
```
%%