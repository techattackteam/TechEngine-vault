---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 To Do — [[2026-08 Sprint 03 — M1 Enablers]] (Aug 1 – Aug 28)

- [ ] **S3-D1** — Profiler ADR (`/adr`) · P1 · 🟢 Deep — closes [[Profiler — Design]]'s 5 open
	  questions + rewrites its stale *Trigger*. **Gates M2's threading ADR. Cuts Story D.**
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
- [ ] ⏳ *Pointer, not a card* — **Stories D / E / F stay unsized.** Their ~9–12 cards get cut
	  by S3-D1 / S3-D2 / S3-D3's own done-conditions. Weight budget in the sprint note.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 03 — M1 Enablers]]




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null]}
```
%%
