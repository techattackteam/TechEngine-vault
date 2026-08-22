---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M2 gates · ✅ **complete** *(D1 · D2, both Aug 22)*


## 📋 B · concurrency bring-up *(T4 → T5)*

- [ ] **S4-T4** · `JobSystem` interface + one-worker pool + tests · P1 · 🟢 Deep
- [ ] **S4-T5** · `EngineContext` wiring + capture demo · P2 · 🟠 Moderate


## 📋 C · serialization first slice *(T6 → T7)*

- [ ] **S4-T6** · `Writer`/`Reader` primitives + bulk path + tests · P1 · 🟢 Deep
- [ ] **S4-T7** · visit seam + non-POD round-trip demo · P1 · 🟢 Deep


## 📋 D · measurements & cleanups

- [ ] **S4-T1** · `<format>` weight: measure, then decide · P2 · 🟠 Moderate
- [ ] **S4-T2** · rename `TechEngine::detail` to `internal` · P3 · 🟡 Light
- [ ] **S4-T3** · `te-review`'s `base` findings · P3 · 🟡 Light


## 📋 E · process *(first thing cut)*

- [ ] **S4-P1** · ccache: one warm entry per leg (+ sprint-plan skill wording) · P2 · 🟡 Light
- [ ] **S4-P2** · CMake source-listing research · P3 · 🟡 Light
- [ ] **S4-P3** · coverage job per PR · P2 · 🟠 Moderate
- [ ] **S4-P4** · skip CI on docs-only PRs + auto-merge · P3 · 🟠 Moderate


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 04 — M2 Concurrency & Serialization]]

- [x] **S4-D2** · serialization ADR · P1 · 🟢 Deep · **Aug 22.**
	  [[ADR-016 — Serialization (binary primitives & describe-once seam)]] **Accepted**;
	  [[Serialization — Design]] created as the hub, surface pinned before the cut. Two paths
	  one seam (bulk trivially-copyable · visited) · the visit function doubles as the
	  reflection seam · LE, deterministic, headered · one header version, re-bake over
	  migration · tags hash with `StringId`, macro-free (vocabulary amendment on ADR-007 §1's
	  `TE_COMPONENT` sketch) · document schemas stay with their consumers. Review finding: no
	  sprint-relative labels in durable artifacts; both new notes swept to card IDs and dates.
	  **Story C cut into S4-T6 → S4-T7. Story A complete: both M2 gates Accepted on day 1.**

- [x] **S4-D1** · threading ADR · P1 · 🟢 Deep · **Aug 22.**
	  [[ADR-015 — Threading (sim on main, render thread owns GL)]] **Accepted**;
	  [[Concurrency — Design]] created as the hub, surface pinned before the cut. Sim on main
	  (drag-stall named, reversal trigger'd) · render thread owns GL, fed complete command
	  lists · `JobSystem` in `core`, batch submit and wait, one worker at M2 · `publish`
	  sim-thread-only until P1. The fork-join idle bubble went into §4 on review, P2 owns the
	  upgrade behind a P1 measurement. Ride-along: [[Task Graph — Execution Flow]]'s two stale
	  M10 refs now read P1/P2. **Story B cut into S4-T4 → S4-T5; S4-D2 is Story A's last card.**





%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,null,null,null,null,null,null,null,null,null]}
```
%%