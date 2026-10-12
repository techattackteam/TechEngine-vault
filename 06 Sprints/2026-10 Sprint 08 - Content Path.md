# 2026-10 · Sprint 08: Content Path

- **Quarter:** [[2026-Q4]]
- **Dates:** Saturday Oct 10 - Friday Oct 23, 2026.
- **Epic:** M6 · content ([[Roadmap]]). Hub: [[Resources - Design]].

## Sprint goal

The editor bakes a project into `.tepack` files, and the runtime loads
the exported startup scene from the packs beside its executable before its first Tick.

This is the vertical slice of M6, chosen at planning on Oct 11: it delivers [[2026-Q4]]'s
"a project names a scene that the runtime loads" and five of M6's six roadmap items. The
resource cache is the sixth; its core is this sprint's P2 stretch, and the rest is Sprint 09.

## Artifact gate

- First sprint of the decide-first trial ([[Planning Workflow - Artifact Gate]] § *Trial from
  Sprint 08*). Every Dev card is cut against [[Resources - Design]]'s *Decided* rows, which
  index ADR-024 and ADR-025 (both Accepted Oct 10). No story is left unsized.
- Settled at planning, now in [[Resources - Design]]: the bake is a function in the editor
  that T2's export command will call. Until then the editor calls it at startup, and its output
  defaults to the editor's own executable folder. The editor's engine folder moves to
  `<exe dir>/engine`. The runtime loads only an exported project. Until T1's scene save, the
  editor also creates `projects/dev`'s startup scene in code at startup (S8-T13), through the
  same scene writer T1 will call, so the slice runs end to end on product code.
- How a component field declares a reference stays open. Nothing this sprint writes a
  reference field, so it blocks no card here; S8-D1 settles it before the Sprint 09 boundary.
- [[Known Issues]]: D3 and D5 neither block nor touch this work. No Bug card carries.

## Stories & tasks

### Story A: Content primitives

- [x] **S8-T1** · Split the blob header per kind and add a ranged `FileAccess` read · P1 · 🟠 Moderate · 2-3h ·
  done: `Writer` and `Reader` take a blob kind's magic and version, and the single
  `BLOB_MAGIC` and `BLOB_FORMAT_VERSION` are gone. Reading a blob of another kind fails with
  `BadMagic`, and a wrong version with `BadVersion`. `FileAccess` reads a byte range of a file
  into a vector; a range past the end fails with a `FileError` and leaves the out-param
  untouched. Tests cover both halves.
- [x] **S8-T2** · Clear the editor's mount layout for M6 · P2 · 🟡 Light · 1-2h ·
  done: the dev shaders live in `projects/dev/assets/client/`, and `projects/dev/shaders/` and
  the `shaders` mount are gone. The editor mounts `engine` at `<exe dir>/engine`, which frees
  `<exe dir>/assets` for packs. `EditorAppTests`' mount-set case asserts the new set of four
  mounts.

### Story B: Scene documents

- [x] **S8-T3** · Write and read scene files · P1 · 🟢 Deep · 4-6h ·
  done: a component registered as serializable carries a payload adapter on its registry record,
  bound through the existing `visit` seam. The writer emits the scene kind's header, the scene's
  `ResourceId`, the entity table (authoring ids and parent links) and one block per component,
  framed by tag and byte length. The reader rebuilds the Scene and remaps parent links.
  `Transform` round-trips, and `Hierarchy` is rebuilt from parent links rather than written.
  Prove a small hierarchy round-trips and a truncated document fails soft. Follows S8-T1.
  **Scope added on Oct 11:** `Hierarchy` keeps a last-child link, so `setParent` appends a
  child at the end without walking the sibling list. The scene reader appends every child, so
  without the link a parent with n children took about n²/2 steps to load. `HierarchyTests`
  prove that an append still lands last after each change to the previous last child.

### Story C: Content packs

- [x] **S8-T4** · Write and read `.tepack` files · P1 · 🟢 Deep · 4-6h ·
  done: the writer emits the pack kind's header (with `flags` and the entry count), a table
  sorted by id, the names block and 16-byte-aligned payloads. The reader reads only the header
  and table when it opens a pack, and each entry with one ranged read. Prove several entries
  round-trip, every payload offset is aligned, an absent id is reported, and a corrupt table
  fails soft. Follows S8-T1.
- [x] **S8-T5** · Boot record, merged table and pack source · P1 · 🟢 Deep · 4-6h ·
  done: `common.tepack` carries a boot record of tagged sections (a `StringId` tag, a `u16`
  version and a byte length) with the startup scene, the packs per role, the sides, and an
  empty system-settings section; a reader skips a section it does not know. Opening a role's
  packs builds one table from id to pack, offset and size. An id on a side the role never opens
  is reported absent for that role, and the pack source returns an id's bytes by ranged read.
  Prove an unknown section is skipped and two packs merge. Follows S8-T4.
  **Scope added on Oct 11:** `Pack.hpp` splits into `PackFormat.hpp`, `PackReader.hpp` and
  `PackWriter.hpp`, so each `.cpp` pairs with its own header. `writeSceneAsset` and
  `readSceneAsset` become a `SceneAsset` struct that holds the asset's id, and the boot record
  writes and reads itself through members, because Miguel wants a type's operations to be its
  members, not free functions. The calls settled while grounding the card are in
  [[Resources - Design]] § *Two sources, one cache*, § *The boot record* and § *The pack source*.

### Story D: Editor index and bake

- [ ] **S8-T6** · Index the project's assets and read them by id · P1 · 🟢 Deep · 4-6h ·
  done: at project open the editor reads the header of every runtime-form file under
  `project://assets/<side>/` for all three sides, and records each id's kind, name and side. A
  duplicate id is reported with both paths. The loose source returns the bytes of a `common`
  or `client` id and reports a `server` id as absent for the client role. `Project` reads and
  writes an optional `startupScene`. Follows S8-T1.
- [ ] **S8-T7** · Bake a project from the editor · P1 · 🟢 Deep · 4-6h ·
  done: a bake function takes the indexed project and an output folder, and packs what
  `startupScene` reaches (this sprint, the scene alone) into `<out>/assets/common.tepack`,
  `client.tepack` and `server.tepack`, with the boot record in `common`. A missing or unknown
  `startupScene` returns its error. Until T2's export command exists, the editor calls it once
  at startup after opening the project, with its own executable folder as `<out>`; a failed
  bake is logged and the editor keeps running. Prove a bake of a scratch project in
  `EditorAppTests` by calling the function directly. Follows S8-T2, S8-T5 and S8-T6.

### Story E: The runtime loads the startup scene

- [ ] **S8-T8** · Run a startup loading phase before the first Tick · P1 · 🟠 Moderate · 2-3h ·
  done: a simulation-thread hook runs after readiness and before the first Tick, and the
  timeline restarts after it, so load time is not replayed as catch-up Ticks. A failure ends
  the runtime's run with its `std::error_code`, and no Tick runs. Prove the order (ready, then
  the phase, then Tick 1), no catch-up after a slow phase, and the failure path in
  `SimulationThreadTests`.
- [ ] **S8-T9** · Load the startup scene from packs beside the runtime · P1 · 🟢 Deep · 4-6h ·
  done: `RuntimeApp` mounts `assets` at `<exe dir>/assets`, opens `common.tepack`, reads the
  boot record, opens its role's packs, and streams the startup scene into the Scene during the
  startup phase. A missing pack or startup scene ends the run with its error. Prove it with a
  headless `RuntimeAppTests` case over packs that the test writes into a scratch directory, and
  record Miguel's windowed run: launch the editor on `projects/dev`, then `runtime.exe` loads
  what it baked. Follows S8-T3, S8-T5, S8-T8, S8-T13 and S8-T14.
- [ ] **S8-T13** · Create the startup scene at editor startup · P1 · 🟠 Moderate · 2-3h ·
  done: after opening the project and before the startup bake, an editor whose project names no
  `startupScene` builds a small scene in code (a parent with two children, `Transform` only). It writes the scene to
  `project://assets/common/` through the scene document writer with a fresh `ResourceId`, adds
  it to the id index, and saves its id as `startupScene` through `Project::save`. A later launch
  finds the id and creates nothing. The file and the `project.toml` change made on
  `projects/dev` are committed, so a fresh clone skips creation. `.gitattributes` marks
  `*.tescene` and `*.tepack` as binary. T1's scene save replaces the code-built scene. Follows
  S8-T3 and S8-T6; the startup bake then has a scene to export.

- [x] **S8-T14** · Remove the runtime demo systems · P2 · 🟠 Moderate · 2-3h ·
  done: `apps/runtime/src/demo/` is gone (the five systems, `Velocity`, `RigidBody` and the four
  event types), and `RuntimeApp::configureSimulation` registers none of them. They existed to
  exercise the task graph, which is done for now (Miguel, Oct 11). `RuntimeAppTests` keeps the
  App-level event proof S7-T8 built (no same-Tick delivery, next-Tick delivery to regular and
  terminal handlers, zero-Tick, multi-Tick catch-up, a handler-published chain and the pulse
  burst) through test-only systems that a probe registers in the test file. Touched notes stop
  citing the demo as evidence. Ordered before S8-T9, because both edit `RuntimeApp.cpp`.

S8-T1 is the root: S8-T3, S8-T4 and S8-T6 start from it. S8-T8 is independent and fits any
🟠 or 🟢 slot. S8-T9 is the last card and the named rollover risk.

### Story F: Decide Sprint 09's references

- [ ] **S8-D1** · Decide how a component field declares a reference, and cut Sprint 09 · P2 · 🟡 Light · 2-3h ·
  done: [[Resources - Design]] records the reference field shape for asset and `Entity`
  references, with the Unity and Unreal baseline: what the field holds in memory, how the scene
  document remaps it, how the bake walks it, and how removing a component releases it. It
  settles the mesh as the second resource type, how a mesh is authored before T4, and whether
  it is drawn through a published copy or only loaded until R1. Sprint 09's mesh and reference
  cards are cut against it before the Oct 24 boundary. Follows S8-T3.

### Story G: Resource cache · stretch

Pulled in on Oct 11 because Miguel is off karting for both weekends. Both are P2: dropping
them never costs the goal. Neither depends on S8-D1; both are tested with a test-only resource
type.

- [ ] **S8-T10** · Build the resource cache core · P2 · 🟢 Deep · 4-6h ·
  done: `ResourceId`, a typed generational handle and slot blocks that never move. Entries
  carry their state and a count of acquires, and hold acquires on their dependencies. A request
  finds or creates an entry, and an unknown id fails at once. `release` frees an entry at zero
  in the next drain. Loaders register by type tag and registration closes after
  `configureSimulation()`. A loading phase runs loaders inline, including dependency rounds.
  `App` owns the cache, not `EngineContext`. Prove stale handles, slot reuse, per-entry counts,
  dependency acquires, free on release, and late registration rejected.
- [ ] **S8-T11** · Run loads on the `JobSystem` · P2 · 🟢 Deep · 4-6h ·
  done: each new entry's read and decode run as a `JobSystem` task that writes only its own
  entry and pushes a completion naming its dependencies. The owner drains completions,
  publishes ready entries and requests dependencies as the next round. A failed load keeps its
  error on the entry. A free waits only for its own entry's task, and an entry still loading
  defers its free. Shutdown waits for in-flight batches and logs every non-zero count. Prove
  concurrent loads, a failed load, a deferred free and shutdown with loads in flight. Follows
  S8-T10.

### Story H: Auto lane and fired backlog

- [x] **S8-P1** · Add the Unity and Unreal comparison rule · P2 · 🤖 Auto · 1-2h ·
  done: [[Technical Lead Charter]] holds the rule once, scoped to drafting or discussing an
  ADR or a design note's decisions: before the question round on such a fork, show how Unity
  and Unreal (Godot when relevant) solve it as a baseline to beat, say when those facts are from
  memory, then say per option where TechEngine's constraints allow better. It does not apply to
  ordinary chat, sprint planning or card work. `.claude/commands/adr.md` and
  `.claude/agents/engine-researcher.md` point to it in one line instead of restating it.
  Narrowed by Miguel on Oct 11, from a rule for every session.
- [ ] **S8-T12** · Clean up `InputState`'s leftovers · P3 · 🤖 Auto · 1-2h ·
  done: `InputState::isHeld` drops its `focused` check, because `apply` already keeps both
  bitsets empty while unfocused (`engine/platform/src/input/InputState.cpp:53`, `:60`); the
  `size_t` casts become `std::size_t`; and new cases cover the `Unknown` guards in `apply` and
  `isHeld`. Existing tests pass unedited.
- [ ] **S8-P2** · Record #112's CI change and re-measure the lane's CI cost · P3 · 🤖 Auto · 1-2h ·
  done: [[B3 - Build & Testing Notes]] records #112's switch to
  `awalsh128/cache-apt-pkgs-action@v1` and the explicit X11 package list. The billed minutes of
  recent code PRs are measured from Actions run data and compared with the 16.1 in
  [[Autonomous Lane - Design]] § *Cost model*. Pinning by tag or by sha is listed as Miguel's
  question, not decided.
- [ ] **S8-P3** · Check *Clock - Design*'s several-simulations argument · P3 · 🤖 Auto · 1h ·
  done: a report says whether [[Clock - Design]] § *Why simulation time is not here* still
  holds without the "several headless sims per process" reason, given that its conclusion rests
  on ADR-019, and proposes the corrected paragraph. Report-only; Miguel applies it.
- [ ] **S8-P4** · Research brief for S8-D1: how engines declare and walk references · P2 · 🤖 Auto · 2-3h ·
  done: a report compares how Unity, Unreal and Godot declare an asset reference in a component
  or property, and how one walk serves save, load, cooking and release. It names the sources it
  read and marks anything taken from memory. It maps each answer onto TechEngine's `visit` seam
  (ADR-016 §2) without choosing; S8-D1 decides. Report-only, and best done in week 1.
- [ ] **S8-T15** · Fold the schedule's repeated bitmask and entry guards · P3 · 🤖 Auto · 2h ·
  done: `ScheduleAccess`'s two identical bit-setting loops and the word and bit arithmetic in
  `reads` and `writes` use one private mask helper, `Schedule::addAccess`'s two resize-and-OR
  blocks use it too, and the five `Schedule` setters share one private member that checks the
  index and returns the entry (`engine/core/src/systems/ScheduleAccess.cpp:22-63`,
  `Schedule.cpp:44-94`). Behaviour-preserving; existing tests pass unedited.
- [ ] **S8-T16** · Check `SceneCommandBuffer`'s pending entities in one place · P3 · 🤖 Auto · 1-2h ·
  done: the bufferId and epoch `TE_CHECK` repeated in `despawn`, `queueAdd`, `queueRemove` and
  `apply` becomes one check on `Impl`, and the identical `Entity` and `PendingEntity` overloads
  of the private add and remove templates become one template each over the target type
  (`engine/core/src/scene/SceneCommandBuffer.cpp:105-134`, `SceneCommandBuffer.hpp:108-130`).
  Behaviour-preserving; existing tests pass unedited.
- [ ] **S8-T17** · Share the engine-services test fixture across core and client · P3 · 🤖 Auto · 2-3h ·
  done: one header in `tests/support/include/TechEngine/testing/` builds the `MountTable`,
  `FileAccess`, `JobSystem`, `Clock`, `EngineContext`, `InputFrame` and `SimulationContext` set
  that `SerialExecutorTests`, `SceneEventTests` and the three `ClientTests` cases each build by
  hand; one header holds the `Window::terminate()` guard that `FrameRendererTests`,
  `RenderThreadTests` and `WindowTests` each define. The copied `amountsOf` and
  `registerMaskComponents` helpers go too. Every `TEST_CASE` and `SECTION` is kept.
- [ ] **S8-P5** · Add the `bool` to `std::error_code` gotcha to `CONVENTIONS.md` · P3 · 🤖 Auto · 1h ·
  done: one bullet under `CONVENTIONS.md` § *Error handling* says a caller that tests the result
  (`REQUIRE(f())`, `if (!f())`) still compiles after such a migration and silently inverts,
  because an empty code is false, citing S7-D3's seven sites.
- [ ] **S8-P6** · Write down why four CI legs never restore a ccache · P3 · 🤖 Auto · 1h ·
  done: [[B3 - Build & Testing Notes]] § *ccache keys* explains that a cache saved on
  `refs/pull/N/merge` serves only that PR, that `sanitizers` and `coverage` never run on
  `master`, and why pushing them on `master` costs more billed minutes than it saves.
  Vault-only.
- [ ] **S8-P7** · Measure whether Jolt's precompiled header defeats ccache · P3 · 🤖 Auto · 1-2h ·
  done: a local `linux-debug` build, run twice under ccache, reports with `ccache -sv` whether
  the 138 Jolt objects and Jolt's PCH object are the 139 uncacheable calls, and why. The result
  goes into [[B3 - Build & Testing Notes]] § *ccache keys*; any fix touches `ci.yml` and stays
  Miguel's. Report-only.
- [ ] **S8-P8** · Match the routine prompt note to what the lane does · P3 · 🤖 Auto · 1h ·
  done: [[Autonomous Lane - Routine Prompt]]'s test line runs
  `LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a ctest --preset linux-debug`, and its PR step re-sends the
  body once after creation to strip the harness's attribution footer. Vault-only; the report
  asks Miguel to paste the prompt into the routine and to re-point the cron for Oct 25.

## 🤖 Auto lane

- Auto cards: twelve. **PRs (six):** S8-T12, S8-T15, S8-T16 and S8-T17 are code PRs; S8-P1
  (`.claude/`) and S8-P5 (`CONVENTIONS.md`) are docs-only, so CI runs the stand-in. **Free
  (six):** S8-P2, S8-P4, S8-P6, S8-P7 and S8-P8 are vault-only or report-only, and S8-P3 is
  report-only. S8-P4 is P2 so the lane takes it early, for S8-D1. With no Auto card open, the
  morning fire screens papers and the afternoon fire sweeps one module.
- Eight were added on Oct 11 at Miguel's request ("it could do a bit more"). Every code card
  stays off the files the attended M6 cards change: no `serialization/`, `FileAccess`,
  `Scene.cpp`, `ComponentRegistry`, `SimulationThread`, `apps/` or `RuntimeAppTests`.
- Review cost: six PRs at about 15 minutes each is about 1h30 of Miguel's time across the
  sprint, best taken on 🟡 days, plus the afternoon sweeps' PRs.
- Attended slots freed: one 🟡 Light (S8-P1). The rest are [[Backlog]] entries that would
  otherwise have stayed parked.
- **Sweep collision risk:** the afternoon rotation reaches `engine/core` on Mon Oct 12, the
  module S8-T1, S8-T3 and S8-T10 change. The sweep's file check sees only cards marked In
  Progress, so keep that column honest, and do not merge a sweep that collides with an open
  M6 branch.

## Definition of Done

- [ ] A headless test writes packs into a scratch directory, and `RuntimeApp` loads the startup
  scene from them before its first Tick; a missing pack ends the run with its error.
- [ ] Windowed: the editor opens `projects/dev` and bakes it, and `runtime.exe` then loads the
  committed startup scene from `bin/assets/`.
- [ ] The bake function turns a project with a `startupScene` into the three packs and a boot
  record, and the editor runs it at startup until T2's export command replaces that call.
- [ ] Touched design notes ([[Resources - Design]], [[Serialization - Design]],
  [[Project - Design]], [[Simulation Thread - Design]], [[File Access - Design]]) describe what
  shipped; validation records keep tests, CI, attended runs and unrun checks apart.

## Capacity note

Day 1 (Oct 10) went to ADR-024 and ADR-025. Miguel is off karting both weekends, so Oct 11 and
both days of Oct 17-18 are dev days: about **9-12 🟢, 2 🟠 and 2 🟡**. The slice uses 6 🟢,
4 🟠 and 2 🟡 (the 🟠 cards can take a 🟢 slot; S8-T13 and S8-T14 were added on Oct 11); Story G adds 2 🟢 as stretch. Using all
four weekend days leaves no rest day, against the Dashboard guardrail; the stretch is P2 so
that a rest day costs nothing.

Sized on the assumption that Miguel writes the code (the question Sprint 07's lost weekly
review never answered). If Claude writes large parts again, as in Sprint 07, the cards will
close early; record that at review rather than refilling the sprint.

**Moved to Sprint 09:** the mesh, reference fields and their remap, the bake's reference walk,
the editor's own startup load, and keeping unknown component blocks (its consumer is T1's scene
save).

## Sprint review (end)

<!-- Keep this section while the sprint is active. Fill it at the end. -->

- Link what shipped and the demo or artifact that proves it.

Retrospective: [[07 Journal]]
