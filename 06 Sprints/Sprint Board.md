---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Content primitives

- [ ] **S8-T1** · Split the blob header per kind and add a ranged `FileAccess` read · P1 · 🟠 Moderate · 2-3h: per-kind magic and version in `Writer` and `Reader`; a byte-range read with a `FileError` past the end. The root card: S8-T3, S8-T4 and S8-T6 follow it.
- [ ] **S8-T2** · Clear the editor's mount layout for M6 · P2 · 🟡 Light · 1-2h: shaders into `projects/dev/assets/client/`, no `shaders` mount, `engine` at `<exe dir>/engine`; `EditorAppTests` asserts four mounts.


## Story B: Scene documents

- [ ] **S8-T3** · Write and read scene documents · P1 · 🟢 Deep · 4-6h: payload adapters on the registry record, entity table with authoring ids and parent links, tag-and-length blocks; round-trip and truncation cases. Follows S8-T1.


## Story C: Content packs

- [ ] **S8-T4** · Write and read `.tepack` files · P1 · 🟢 Deep · 4-6h: sorted table, names, 16-byte-aligned payloads, table read at open and one ranged read per entry. Follows S8-T1.
- [ ] **S8-T5** · Boot record, merged table and pack source · P1 · 🟢 Deep · 4-6h: tagged sections that a reader can skip, one merged table per role, absent-for-role, the pack source. Follows S8-T4.


## Story D: Editor index and bake

- [ ] **S8-T6** · Index the project's assets and read them by id · P1 · 🟢 Deep · 4-6h: headers of all three sides, duplicate ids reported, the loose source, an optional `startupScene`. Follows S8-T1.
- [ ] **S8-T7** · Bake a project from the editor · P1 · 🟢 Deep · 4-6h: a bake function writes the three packs and the boot record; the editor calls it at startup into its own exe folder until T2's export command, and a failed bake is logged without stopping the editor. Follows S8-T2, S8-T5 and S8-T6.


## Story E: The runtime loads the startup scene

- [ ] **S8-T8** · Run a startup loading phase before the first Tick · P1 · 🟠 Moderate · 2-3h: after readiness, before Tick 1, timeline restart, a failure ends the run. Independent.
- [ ] **S8-T9** · Load the startup scene from packs beside the runtime · P1 · 🟢 Deep · 4-6h: mount `<exe dir>/assets`, follow the boot record, stream the scene in the startup phase; a headless case over packs in a scratch directory. Follows S8-T3, S8-T5, S8-T8, S8-T13 and S8-T14. The named rollover risk.
- [ ] **S8-T13** · Create the startup scene at editor startup · P1 · 🟠 Moderate · 2-3h: with no `startupScene`, the editor builds a small `Transform`-only scene in code, writes it through the scene writer, indexes it and saves its id to `project.toml`; commit the result on `projects/dev`; `.gitattributes` marks `.tescene` and `.tepack` binary. Follows S8-T3 and S8-T6.
- [ ] **S8-T14** · Remove the runtime demo systems · P2 · 🟠 Moderate · 2-3h: delete `apps/runtime/src/demo/`; keep S7-T8's App-level event proof in `RuntimeAppTests` through test-only systems. Before S8-T9 (both edit `RuntimeApp.cpp`).


## Story F: Decide Sprint 09's references

- [ ] **S8-D1** · Decide how a component field declares a reference, and cut Sprint 09 · P2 · 🟡 Light · 2-3h: the field shape with the Unity and Unreal baseline, the mesh's authoring and draw policy, Sprint 09's cards cut before Oct 24. Follows S8-T3.


## Story G: Resource cache · stretch

- [ ] **S8-T10** · Build the resource cache core · P2 · 🟢 Deep · 4-6h: `ResourceId`, generational handles, never-moving slots, per-entry counts, loader registration closing after `configureSimulation()`, an inline loading phase. Test-only resource type.
- [ ] **S8-T11** · Run loads on the `JobSystem` · P2 · 🟢 Deep · 4-6h: a task per entry, the completion queue, dependency rounds, deferred frees, the shutdown wait. Follows S8-T10.


## Story H: Auto lane and fired backlog

- [ ] **S8-P1** · Add the Unity and Unreal comparison rule · P2 · 🤖 Auto · 1-2h: the rule once in [[Technical Lead Charter]], scoped to ADR and design-note decisions only, not chat or planning; one-line pointers from `/adr` and `engine-researcher`.
- [ ] **S8-T12** · Clean up `InputState`'s leftovers · P3 · 🤖 Auto · 1-2h: drop `isHeld`'s redundant `focused` check, `std::size_t` casts, cases for the `Unknown` guards; existing tests unedited.
- [ ] **S8-P2** · Record #112's CI change and re-measure the lane's CI cost · P3 · 🤖 Auto · 1-2h: a B3 line for the apt cache action, measured billed minutes against the 16.1 figure; pinning stays Miguel's question.
- [ ] **S8-P3** · Check *Clock - Design*'s several-simulations argument · P3 · 🤖 Auto · 1h: report-only, with a proposed paragraph.
- [ ] **S8-P4** · Research brief for S8-D1: how engines declare and walk references · P2 · 🤖 Auto · 2-3h: Unity, Unreal and Godot, sources named, mapped onto `visit` without choosing. Report-only; week 1.
- [ ] **S8-T15** · Fold the schedule's repeated bitmask and entry guards · P3 · 🤖 Auto · 2h: one mask helper and one checked-entry member in `ScheduleAccess.cpp` and `Schedule.cpp`; tests unedited.
- [ ] **S8-T16** · Check `SceneCommandBuffer`'s pending entities in one place · P3 · 🤖 Auto · 1-2h: one check on `Impl`, one template per operation; tests unedited.
- [ ] **S8-T17** · Share the engine-services test fixture across core and client · P3 · 🤖 Auto · 2-3h: shared fixture and `Window::terminate()` guard in `tests/support`; every `TEST_CASE` and `SECTION` kept.
- [ ] **S8-P5** · Add the `bool` to `std::error_code` gotcha to `CONVENTIONS.md` · P3 · 🤖 Auto · 1h: one bullet under *Error handling*.
- [ ] **S8-P6** · Write down why four CI legs never restore a ccache · P3 · 🤖 Auto · 1h: the reasoning in B3 § *ccache keys*; vault-only.
- [ ] **S8-P7** · Measure whether Jolt's precompiled header defeats ccache · P3 · 🤖 Auto · 1-2h: `ccache -sv` on a local `linux-debug` build, result in B3; report-only.
- [ ] **S8-P8** · Match the routine prompt note to what the lane does · P3 · 🤖 Auto · 1h: the xvfb test line and the footer re-send step; Miguel pastes it and re-points the cron for Oct 25.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done: Sprint 08





%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%
