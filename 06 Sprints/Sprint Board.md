---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Finalize Tick-event delivery



## Story B: Deliver Scene events at the Tick barrier

- [ ] **S7-T4** · Bind ordered event handlers to selected systems · P1 · 🟢 Deep · 3-5h: typed handlers on the persistent instance, recorded in declaration order.
- [ ] **S7-T5** · Replace event cursors with stable Tick batches · P1 · 🟢 Deep · 4-6h: next-Tick visibility and stable reads during same-type publication.
- [ ] **S7-T6** · Place registered event streams on Scene · P1 · 🟢 Deep · 3-5h: app registration, per-Scene ownership and isolation.
- [ ] **S7-T7** · Deliver handlers and advance batches at the Tick barrier · P1 · 🟢 Deep · 4-6h: dispatch before `tick`, retire after successful systems, and replace no-op event flushing.
- [ ] **S7-T8** · Prove the integrated event path · P1 · 🟢 Deep · 3-5h: App-level boundary proof.


## Story C: Deliver engine input events

- [ ] **S7-T9** · Translate GLFW controls to engine identifiers · P1 · 🟢 Deep · 4-6h: known/unknown codes, ordered edges and repeat handling.
- [ ] **S7-T10** · Deliver input edges to selected systems · P1 · 🟢 Deep · 4-6h: follows T9 and S7-T3; current-Tick delivery at each system slot.
- [ ] **S7-T11** · Generate held input and handle focus resets · P1 · 🟢 Deep · 3-5h: follows T10; held once per Tick and neutral regain.
- [ ] **S7-T12** · Prove overflow recovery and runtime delivery · P1 · 🟢 Deep · 4-6h: follows T11; lost-range notice plus headless/windowed witnesses.


## Story D: Close other fired decisions and implementation seams

- [ ] **S7-D3** · Decide the public error-handling policy · P2 · 🟢 Deep · 4-6h: settle the open conventions row and `[[nodiscard]]` policy in an ADR.
- [ ] **S7-T1** · Correct app-local includes · P3 · 🤖 Auto · 2-3h: four quoted includes in `apps/` to angle brackets, plus `<string>` in `EditorApp.hpp`; `platform` is already public.
- [ ] **S7-T2** · Route GLFW allocations through profiler hooks · P3 · 🟠 Moderate · 3-4h: install and verify the GLFW allocator seam.


## Story E: Repair fired process and evidence gaps

- [ ] **S7-P1** · Reconcile build/profiler and App coverage policy · P2 · 🟢 Deep · 4-6h: carry S6-P1 and record the App coverage exclusion.
- [ ] **S7-P2** · Guard the merged branch-to-card link · P3 · 🤖 Auto · 4-6h: a `/card-close` gate step checking the merged branch prefix.
- [ ] **S7-P3** · Validate vault code citation paths and line bounds · P3 · 🤖 Auto · 4-6h: `tools/check-vault-citations.py` against the reconciliation SHA.
- [ ] **S7-P4** · Reconcile workflow-only CI policy · P3 · 🟠 Moderate · 2-3h: amend ADR-009 and fix the skipped-check comment.
- [ ] **S7-P5** · Resolve old routine-prompt drift · P3 · 🟡 Light · 2h: check the old routine's status and reconcile prompt guidance.
- [ ] **S7-P6** · Keep fired backlog witnesses current · P3 · 🟡 Light · 2h: settle the widened sweep's workflow home.
- [ ] **S7-P7** · Measure ccache refresh after successive master revisions · P3 · 🤖 Auto · 2h: record comparable cache evidence; report-only.
- [ ] **S7-P8** · Define a small recorded-demo workflow · P3 · 🟡 Light · 2h: record capture storage and sprint-review links.


## Story F: Backlog code hygiene for the Auto lane

- [ ] **S7-B1** · Build with the log gate above Info · P3 · 🤖 Auto · 2h: `-DTE_LOG_ACTIVE_LEVEL=3` builds; fix `MathFormatTests.cpp:47`.
- [ ] **S7-T13** · Give `techengine_app()` a `LIBS_PRIVATE` · P3 · 🤖 Auto · 2h: mirror `techengine_module()`; toml++ goes private.
- [ ] **S7-T14** · Test `Log.hpp`'s `NDEBUG` fallback · P3 · 🤖 Auto · 2h: a TU that undefines the gate, in debug and release.
- [ ] **S7-T15** · Spell out `loc` and `fmtStr` in `base` · P3 · 🤖 Auto · 1-2h: parameter renames only; tests unedited.

## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done: Sprint 07

- [x] **S7-T3** · Construct and describe selected systems before graph build · P1 · 🟢 Deep · 4-6h: #94 `7e52fe3a`, Sep 26. `Schedule::add<T>()` constructs the instance and calls `ISystem::init(ScheduleRegistration&)`; the schedule owns instances and the executor borrows them. Deleted before shipping: a `SystemCatalog` (project contribution stays parked in [[Backlog]]) and a `SystemDeclaration` wrapper that only forwarded to `ScheduleRegistration`. Diagnostic names are cached from the persistent instance's `name()`, not a static per-type field. Absorbed S7-T8's frame→Tick rename, including the log stamp `[f N]`→`[t N]`. Call-site declarations still override `init` → [[Backlog]] § core. **Retro:** the card opened on static self-registration, which ADR-022 had rejected that morning; the ADR was reopened and re-accepted unchanged the same day. Unblocks S7-T4 and S7-T10.
- [x] **S7-D1** · Finalize Tick-event delivery and handler order · P1 · 🟢 Deep · 4-6h: settled declaration order and next-Tick batches; cut Story B cards. Vault changes remain local.
- [x] **S7-D2** · Review v1 input and settle the engine input contract · P1 · 🟢 Deep · 4-6h: accepted engine codes and same-Tick input notifications; amended ADR-014/019/020, created the Input hub and cut S7-T9-T12. Vault changes remain local.




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%