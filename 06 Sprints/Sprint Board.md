---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A — Ground the ECS port



## Story B — Port Scene identity, storage, queries and hierarchy

- [ ] **S6-T4** · Built-in hierarchy · P1 · 🟢 Deep · 3–4h
- [ ] **S6-T5** · Transform component and propagation · P1 · 🟢 Deep · 3–4h · ⛔ T4


## Story C — Settle system dependencies and execution



## Story D — Schedule, graph and serial execution

- [ ] **S6-T6** · Schedule and access declarations · P1 · 🟠 Moderate · 3–4h
- [ ] **S6-T7** · Graph builder · P1 · 🟢 Deep · 4–6h · ⛔ T6
- [ ] **S6-T8** · Serial executor and barrier · P1 · 🟢 Deep · 4–6h · ⛔ T7


## Story E — Scene integration and headless proof

- [ ] **S6-T9** · Wire executor into the simulation tick · P1 · 🟠 Moderate · 3–4h · ⛔ T5 + T8


## Story F — Repair bounded documentation drift

- [ ] **S6-P1** · Align the documented build/profiler policy with shipped decisions · P3 · 🟡 Light · 2h
- [ ] **S6-P2** · Report remaining Sprint 05 artifact and backlog drift · P3 · 🤖 Auto


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done

- [x] **S6-T3** · Queries and iteration · P1 · 🟠 Moderate · 3–4h —
	  Merged as PR #85 (`150f8f0d`). Queries cache matching archetypes by revision
	  while reacquiring current column spans for every iteration. Read/write access,
	  explicit `eachEntity` traversal, clear invalidation and structural-mutation rejection
	  are covered by focused tests. Retained queries keep a storage pointer, so storage is
	  non-movable; an atomic iteration depth also preserves concurrent disjoint-query use
	  for the future task-graph executor. Story B remains open for hierarchy and transforms.
- [x] **S6-T2** · Archetype storage and transitions · P1 · 🟢 Deep · 4–6h —
	  Merged as PR #84 (`4bcc71d0`). Review exposed that default construction and
	  shared-column copying may throw even though committed row relocation is nothrow;
	  destination rows now roll back before the source archetype is mutated. Dedicated
	  archetype tests were added to scrutinize canonical reuse and entity/column alignment.
	  This unblocks S6-T3, S6-T4 and S6-T8 without completing Story B.
	  **Retro:** the PR also carried the unrelated member-initializer convention sweep,
	  broadening a storage card across existing engine files.
- [x] **S6-T1** · Entity handles and ComponentRegistry · P1 · 🟠 Moderate · 3–5h —
	  Merged as PR #82 (`9fb6aeaf`). Slot exhaustion was clarified as a fatal `TE_CHECK`,
	  so it has no null-return recovery path. The registry freeze mechanism shipped, while
	  composition-root ownership and the actual before-first-tick freeze remain S6-T9
	  integration. This unblocks S6-T2 and the identity side of S6-T4 without completing Story B.
	  **Retro:** PR #82 also removed the tracked Codex context-window request; that conflicts
	  with the repository instructions and needs Miguel's call.
- [x] **S6-D2** · Task-graph/System ADR and execution design · P1 · 🟢 Deep · 4–6h —
	  ADR-020 drafted (Proposed). Three design calls changed during review: conflict direction
	  uses numeric priority instead of registration order, schedule is fully immutable (not
	  mutable between ticks) for multiplayer determinism, and the phase model collapsed from
	  two (Input + FixedUpdate) to one (Tick). Design note reconciled, ADR Index updated,
	  Stories D/E cut as 4 cards (T6–T9). ADR-020 is Proposed, not Accepted. DoD line 2 is
	  not yet satisfied; acceptance is Miguel's call.
- [x] **S6-D1** · Review the v1 ECS and draft Scene — Design · P1 · 🟢 Deep · 4–6h




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%
