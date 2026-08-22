---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M2 gates *(D1 cuts Story B · D2 cuts Story C)*

- [ ] **S4-D1** · threading ADR via `/adr` · P1 · 🟢 Deep
- [ ] **S4-D2** · serialization ADR via `/adr` · P1 · 🟢 Deep


## 📋 B · concurrency bring-up *(⏳ size after S4-D1)*

- [ ] ⏳ ~2-3 tasks · cut when S4-D1 is Accepted


## 📋 C · serialization first slice *(⏳ size after S4-D2)*

- [ ] ⏳ ~2-3 tasks · cut when S4-D2 is Accepted


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




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,null,null,null,null,null,null,null,null,null]}
```
%%