---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## Story A: Content primitives



## Story B: Scene files



## Story C: Content packs



## Story D: Editor index and export



## Story E: The runtime loads the startup scene

- [ ] **S8-T8** · Run a startup loading phase before the first Tick · P1 · 🟠 Moderate · 2-3h: after readiness, before Tick 1, timeline restart, a failure ends the run. Independent.
- [ ] **S8-T9** · Load the startup scene from packs beside the runtime · P1 · 🟢 Deep · 4-6h: mount `<exe dir>/assets`, follow the boot record, stream the scene in the startup phase; a headless case over packs in a scratch directory. Follows S8-T3, S8-T5, S8-T8, S8-T13 and S8-T14. The named rollover risk.
- [ ] **S8-T13** · Create the startup scene at editor startup · P1 · 🟠 Moderate · 2-3h: with no client startup scene, the editor builds a small `Transform`-only scene in code, writes it through the scene writer, indexes it and saves its id to `project.toml`; commit the result on `projects/dev`; `.gitattributes` marks `.tescene` and `.tepack` binary. Follows S8-T3 and S8-T6.


## Story F: Decide Sprint 09's references

- [ ] **S8-D1** · Decide how a component field declares a reference, and cut Sprint 09 · P2 · 🟡 Light · 2-3h: the field shape with the Unity and Unreal baseline, the mesh's authoring and draw policy, Sprint 09's cards cut before Oct 24. Follows S8-T3.


## Story G: Resource cache · stretch

- [ ] **S8-T10** · Build the resource cache core · P2 · 🟢 Deep · 4-6h: `ResourceId`, generational handles, never-moving slots, per-entry counts, loader registration closing after `configureSimulation()`, an inline loading phase. Test-only resource type.
- [ ] **S8-T11** · Run loads on the `JobSystem` · P2 · 🟢 Deep · 4-6h: a task per entry, the completion queue, dependency rounds, deferred frees, the shutdown wait. Follows S8-T10.


## Story H: Auto lane and fired backlog

- [ ] **S8-P2** · Record #112's CI change and re-measure the lane's CI cost · P3 · 🤖 Auto · 1-2h: a B3 line for the apt cache action, measured billed minutes against the 16.1 figure; pinning stays Miguel's question.
- [ ] **S8-P3** · Check *Clock - Design*'s several-simulations argument · P3 · 🤖 Auto · 1h: report-only, with a proposed paragraph.
- [ ] **S8-T15** · Fold the schedule's repeated bitmask and entry guards · P3 · 🤖 Auto · 2h: one mask helper and one checked-entry member in `ScheduleAccess.cpp` and `Schedule.cpp`; tests unedited.
- [ ] **S8-T16** · Check `SceneCommandBuffer`'s pending entities in one place · P3 · 🤖 Auto · 1-2h: one check on `Impl`, one template per operation; tests unedited.
- [ ] **S8-T17** · Share the engine-services test fixture across core and client · P3 · 🤖 Auto · 2-3h: shared fixture and `Window::terminate()` guard in `tests/support`; every `TEST_CASE` and `SECTION` kept.
- [ ] **S8-P5** · Add the `bool` to `std::error_code` gotcha to `CONVENTIONS.md` · P3 · 🤖 Auto · 1h: one bullet under *Error handling*.
- [ ] **S8-P6** · Write down why four CI legs never restore a ccache · P3 · 🤖 Auto · 1h: the reasoning in B3 § *ccache keys*; vault-only.
- [ ] **S8-P7** · Measure whether Jolt's precompiled header defeats ccache · P3 · 🤖 Auto · 1-2h: `ccache -sv` on a local `linux-debug` build, result in B3; report-only.
- [ ] **S8-P8** · Match the routine prompt note to what the lane does · P3 · 🤖 Auto · 1h: the xvfb test line and the footer re-send step; Miguel pastes it and re-points the cron for Oct 25.


## 🔨 In Progress



## 👀 Review / Demo

- [ ] **S8-T12** · Clean up `InputState`'s leftovers · P3 · 🤖 Auto · 1-2h: #133, branch `S8-T12/input-state-leftovers`, opened Oct 13 by the morning auto run. Built and tested green on `linux-debug`; Miguel to review and merge.


## ✅ Done: Sprint 08

- [x] **S8-T7** · Export a project's client target from the editor · P1 · 🟢 Deep · 4-6h: #132 `eb62d607`, **Oct 12**. All build legs, the sanitizers, clang-format and diff coverage passed. **The card was rescoped mid-card.** It started as one bake of three packs with the startup scene in `common`. Miguel renamed the action export, then reversed the rule that a startup scene lives in `common`, because a client may start in a menu while a server starts in the world. He then saw that the client and the server ship as separate programs, so one bake was the wrong foundation. An **export target** is now a `Role`: `exportTo(target, folder)` writes one target's packs straight into `<folder>/assets/`, T2's command will write several targets into one subfolder each, and `[export.client]` replaced `exportStartupScene`. Only the client target is built; the server rows sit commented out in the target table under a TODO. The `done:` clause was rewritten to match, and the calls are in [[Resources - Design]] § *Export targets* and [[Project - Design]] § *The manifest*. **Two clauses had no referent at `/card-start`.** "Returns its error" had no code, so `ProjectError` gained `NoStartupScene` and `UnknownStartupScene` rather than a new enum (ADR-023 §2); `StartupSceneNotInTarget` came with the targets. "An output folder" could not be written, because `FileAccess` writes only through a mount. Miguel wanted the folder free per export, so `exportTo` mounts it in a private table, which breaks [[Project - Design]]'s rule that `Project` carries no mount knowledge; its *Mount authority* row now names the exception. **Written and deleted before merge:** a free `exportProject` in two files of its own (Miguel: two files for one function, so it became a member of `Project`), a `StartupSceneNotCommon` error, and the server pack with the listen-server and dedicated-server role lists. `SchemaInvalid`'s message, wrong since S8-T6, was fixed in passing. Unblocks S8-T9 (with S8-T8 and S8-T13); completes Story D. **Retro:**
	  - The branch was cut from S8-T6's branch while #131 was in CI, by Miguel's choice. After #131 merged it was rebased onto `origin/master` with `--onto`, cleanly, because the squash matched the stacked commit.
	  - Miguel's first `exportTo` wrote the pack header by hand instead of using `PackWriter`, looped over every indexed asset, kept `PackWriter` views of payloads that died each iteration, and added the scene twice, which `add`'s duplicate check would have stopped. His `EditorApp` call passed `<exe>/engine/assets` and ended the editor with `TE_CHECK` on a failed export, which would have aborted every editor test. Claude rewrote `exportTo` at Miguel's request.
	  - Claude claimed that mounting a folder that does not exist yet fails; `MountTable` canonicalises an empty root again at resolve time. A test helper built on the claim was removed before merge.
	  - The two `TODO:`s for the server targets carry no card ID, against CONVENTIONS' comment rule, because no card exists for them yet.
	  - The startup export will write into `bin/` from every editor test once S8-T13 lands; logged in [[Backlog]] → *editor & tooling*.
	  - Claude wrote the scaffold, the tests, `exportTo` and its target table, and the move to `[export.client]`, at Miguel's request. Miguel wrote the first `exportTo` and the `EditorApp` wiring. The sprint note's capacity section asked for this to be recorded.
	  - The PR has no body or review conversation, and no `/card-review` is recorded, so this entry is the only record of these calls.
- [x] **S8-T6** · Index the project's assets and read them by id · P1 · 🟢 Deep · 4-6h: #131 `6acd0781`, **Oct 12**. All build legs, the sanitizers, clang-format and diff coverage passed. **Two `done:` clauses had no referent at `/card-start`.** "Kind" had none: a header carries only a magic, while S8-T7's pack table needs a `StringId` type tag, and no list of asset kinds existed. Miguel chose a table in the index that pairs a magic with a type tag, with `SCENE_TYPE_TAG` beside `SCENE_KIND`. "Every runtime-form file" had no test to apply, and the raw GLSL shaders that S8-T2's retro predicted sit under `assets/client/`; Miguel chose to skip anything else with a warning, and to fail only when a side folder cannot be listed. A third call no artifact made: a duplicate id is indexed under neither path, the literal reading of ADR-024 §2. "Name" is the virtual path, and "optional" is a null `ResourceId`, so no `std::optional`. These are in [[Resources - Design]] § *The editor's id index* and [[Project - Design]] § *Load and save*. **The key is now `exportStartupScene`.** Mid-card, Miguel proposed dropping it from `Project` and tracking the scene the editor has open; it stayed, because the startup scene is an export setting that changes only when chosen, which is how Unity's build scene list and Unreal's `GameDefaultMap` work too. The reopen-last-scene idea went to [[Backlog]] → *editor & tooling*. Renaming `AssetIndex` to `AssetsBank` was considered and dropped, because a bank suggests it holds asset data. `/card-review` found an unrelated IDE reformat of `publishSnapshot` and an index failure logged at critical level while the editor carried on; the reformat was reverted and the failure became a `TE_CHECK`, before merge. Unblocks S8-T7 (its last predecessor) and S8-T13; Story D stays open with S8-T7. **Retro:**
	  - Miguel's first `exportStartupScene` parse read an integer key as absent, because toml++'s `value<std::string>()` returns nothing for a non-string; `save` wrote the id in decimal with `std::to_string`; and `stoull` accepted trailing garbage. Fixed with `value_exact`, `std::from_chars` (which must consume every digit) and `std::format("{:#018x}")`. Miguel's first `AssetIndex::find` compared a record to an id and did not compile; it became a binary search, so the records must stay sorted by id.
	  - `LooseSource` has no caller in Sprint 08's product code. Miguel kept it so the cache (S8-T10, or Sprint 09) starts with both sources.
	  - The editor wanted to warn and add a startup scene when `project.toml` names none; that is S8-T13's clause, so it was left out of this card.
	  - Claude wrote the scaffold, the tests, `AssetIndex::build`, `find` and `LooseSource`, and the `Project` fix after the failing run, at Miguel's request. Miguel wrote the `exportStartupScene` parse and save and the `EditorApp` wiring. The sprint note's capacity section asked for this to be recorded.
	  - The PR has no body or review conversation, so this entry is the only record of these calls.
- [x] **S8-P4** · Research brief for S8-D1: how engines declare and walk references · P2 · 🤖 Auto · 2-3h: report-only, **Oct 12**, worked by the afternoon auto run. The brief is in [[2026-10-12 14-09 Auto Run]]: how Unity, Unreal and Godot declare a reference, how each finds dependencies for the build and releases them, and six patterns mapped onto `visit`, ending in four questions for S8-D1 without choosing. Documentation sites were unreachable from the sandbox, so Godot and Unity were read in source on GitHub, Unreal only from Epic's pages as search excerpts, and every fact taken from memory is marked.
- [x] **S8-P1** · Add the Unity and Unreal comparison rule · P2 · 🤖 Auto · 1-2h: #130 `af8181c`, **Oct 12**, worked by the morning auto run. The rule is in [[Technical Lead Charter]] § *Compare against Unity and Unreal*, scoped to ADR and design-note decisions as Miguel narrowed it on Oct 11. `/adr` step 3 and `engine-researcher` point to it in one line each. Nothing deviated from the `done:` clause. The PR changed only docs, so CI ran only the stand-in checks.
- [x] **S8-T5** · Boot record, merged table and pack source · P1 · 🟢 Deep · 4-6h: #129 `71c5c7e4`, **Oct 11**. CI passed, including clang-format and diff coverage. **Three `done:` clauses had no referent at `/card-start`.** "The sides" had no type, so `Side` landed in `core/resources/`. "Reported absent for that role" had no way to say it: `PackReader::find` returns `bool`, and there are three outcomes. Claude first proposed a `ResourceError` enum, which breaks ADR-023 §2's one enum per module; it was caught before any code. Miguel chose a query instead: `AssetSource::find` returns `Present`, `AbsentForRole` or `Unknown`, and only `read` returns errors. "A side the role never opens" had no rule, because a pack carries no side; Miguel chose that an id missing from the merged table but listed in the sides is absent for the role. Two more calls no artifact made: a known section at a newer version is `BadVersion` (Miguel), and a role the record does not list is `Malformed` (Claude's call, pinned by a test). The note's unnamed "source" interface is `AssetSource` in a new `core/assets/` folder, renamed mid-card from `ResourceSource` because it serves asset bytes, not resources (ADR-024 §10). All of these are in [[Resources - Design]] § *Two sources, one cache*, § *The boot record* and § *The pack source*. **Scope added** (the sprint note's card lists it): `Pack.hpp` split into `PackFormat.hpp`, `PackReader.hpp` and `PackWriter.hpp`, and the scene asset became a `SceneAsset` struct, because Miguel wants a type's operations to be its members; a nested namespace was considered and dropped, because CONVENTIONS keeps public API in one flat namespace. Unblocks S8-T7 (with S8-T6) and S8-T9 (with S8-T8 and S8-T13); completes Story C. **Retro:**
	  - `/card-review` found that no test put a real boot record inside a pack, which is the first clause's own words; a round-trip case in `PackTests` was added before merge. It also found four files that the format gate would reject, all written by Claude; they were fixed before merge.
	  - Claude wrote the scaffold and the tests, `PackSource::open` and `read`, both `BootRecord` bodies, the header split and the `SceneAsset` change, at Miguel's request. Miguel wrote `PackSource::find` and started `read`. The sprint note's capacity section asked for this to be recorded.
	  - "A type's operations are its members" now governs three types, but `CONVENTIONS.md` does not say it; this entry and [[Resources - Design]] are its only record.
	  - The PR has no body or review conversation, so this entry is the only record of these calls.
- [x] **S8-T4** · Write and read `.tepack` files · P1 · 🟢 Deep · 4-6h: #128 `d44092ec`, **Oct 11**, with S8-T14 on the branch `S8-T4/Read-Write-tepack-files`. All build legs, clang-format and diff coverage passed. **Four calls that no artifact made were settled at `/card-start`.** The design note said the boot record is found "through its header", but the `done:` clause named only `flags` and the entry count; Miguel had this card lay the boot range in the header now (a `u64` offset and size, both zero when absent), so S8-T5 does not reopen the layout. "An absent id is reported" had no error code to use, because `core` owns only `ReadError`, so `find` returns `bool` (`CONVENTIONS.md` § *`std::optional`*). "A corrupt table fails soft" did not say what `open` checks: it checks everything at open, returns `Malformed` or `Truncated`, and passes file errors through unchanged. The writer builds the pack in memory. **Mid-card, Miguel turned the free `writePack` into a `PackWriter` class**, whose `add` keeps views and asserts on a null or duplicate id at the call that caused it. These calls are now in [[Resources - Design]] § *Pack layout and the boot record*. Unblocks S8-T5; Story C stays open. **Retro:**
	  - Miguel's first `open` read from an empty span, used `TE_CHECK` on file contents, took `flags` as the entry count and read the id as a `u32`. At Miguel's request, Claude wrote `PackWriter::write` and the whole reader, as well as the scaffold and the tests; Miguel wrote `add`'s null check and `setBootRecord`. The sprint note's capacity section asked for this to be recorded.
	  - `/card-review` for overengineering found two extras in the tests, both cut before merge: priorities copied onto the test systems that no assertion depended on, and a corrupt-table section that tested the same branch as another.
	  - Left open: `open` ignores `flags`, so a future compressed pack would be read as raw bytes. It is in [[Resources - Design]] § *Open questions*.
	  - The PR has no body or review conversation, so this entry is the only record of these calls.
- [x] **S8-T14** · Remove the runtime demo systems · P2 · 🟠 Moderate · 2-3h: #128 `d44092ec`, **Oct 11**. **It shipped on S8-T4's branch**, by Miguel's choice, so this entry is the only link from the squashed commit back to this card. `RuntimeApp` no longer overrides `configureSimulation`. `RuntimeAppTests` keeps S7-T8's event cases through four test-only systems, one test component and four events that a probe registers; they keep the demo's timings, so every assertion kept its numbers. The case that ran the demo systems was replaced by one proving that the runtime configures no systems or event types. [[Events - Design]], [[Scene - Design]], [[Simulation Thread - Design]] and [[B3 - Build & Testing Notes]] no longer cite the demo as evidence. Clears S8-T9's edit of `RuntimeApp.cpp`; Story E stays open. **Retro:**
	  - One commit also deleted `App::configureSimulation` and its call in `finalizeSimulation`. The card did not ask for that, and ADR-024 §4 closes loader registration there, which S8-T10 builds on. It was restored before merge. The override declaration left in `RuntimeApp.hpp` then broke the link (LNK2001) until it was removed.
	  - B3 linked a [[Backlog]] item, *Undriven demo code*, that no longer existed; the link went with the demo paragraph.
	  - Claude wrote the test file at Miguel's request.
- [x] **S8-T3** · Write and read scene files · P1 · 🟢 Deep · 4-6h: #127 `824e2111`, **Oct 11**, with S8-T2 on the branch `S8-T3/Scene-file`. All seven build legs, clang-format and diff coverage passed. **Two `done:` clauses had no referent at `/card-start`.** `ResourceId` belonged to S8-T10, a stretch card, so this card pulled in a minimal strong `u64` type with no generator. Nothing said how a component is "registered as serializable": Miguel chose that registration fills the adapters automatically when the type has a `visit` for both archives. **The design note's layout could not detect every truncation**, because its block list named no owning entity and carried no count; blocks now follow their entity, behind a count. The note also said unknown blocks are kept, which the sprint had moved to Sprint 09, so they are skipped with a warning. The code says *scene asset*, not *scene document*, after ADR-024 §10's vocabulary (Miguel). A structurally invalid table returns the new `ReadError::Malformed`. These calls are now in [[Resources - Design]] § *Scene assets*, [[Serialization - Design]] and [[Scene - Design]]. **Scope added:** `Hierarchy` keeps a last-child link, because appending at the end walked every sibling and made a wide parent quadratic to load; Miguel's call, made without a measurement. Unblocks S8-T13 (with S8-T6) and S8-D1, and is one of S8-T9's predecessors; completes Story B. **Retro:**
	  - `/card-review` for overengineering found that the reader accepted any authoring id through a map, on a claim that T1 would keep ids stable across saves that no artifact made, and that it rejected duplicate blocks the writer cannot produce, with no test. Both were cut before merge: an id must equal its row, a parent must be an earlier row, and a duplicate block keeps its last value. A rejected `setParent` became unreachable and is now a `TE_CHECK`. The review's third finding, an unmeasured per-type scratch cache in the reader, was kept.
	  - Claude wrote almost all of this card at Miguel's request: the scaffold, the tests, both functions, the adapters, `Transform`'s `visit` and the last-child link. The sprint note's capacity section asked for this to be recorded at the review.
	  - The PR has no body or review conversation, so this entry is the only record of these calls.
- [x] **S8-T2** · Clear the editor's mount layout for M6 · P2 · 🟡 Light · 1-2h: #127 `824e2111`, **Oct 11**. **It shipped on S8-T3's branch**, by Miguel's choice because it was small, so this entry is the only link from the squashed commit back to this card. The `shaders` mount is gone, the dev shaders sit in `projects/dev/assets/client/shaders/` (a subfolder, with the old `.gitkeep` moved along), and the editor mounts `engine` at `<exe dir>/engine`; [[Project - Design]] records both. Completes Story A. **Retro:**
	  - The first commit left `engine` at `<exe dir>/assets`. `/card-review` caught it, and the fix landed before merge. `EditorAppTests` checks that four mounts exist but not where `engine` points, so no test would have failed.
	  - S8-T6 inherits two raw GLSL files under `assets/client/` with no blob header, and its index reads the header of every file there.
- [x] **S8-T1** · Split the blob header per kind and add a ranged `FileAccess` read · P1 · 🟠 Moderate · 2-3h: #126 `089ea289`, **Oct 11**. All seven build legs, clang-format and diff coverage (89%) passed. **Two signatures that no artifact pinned were settled at `/card-start` on Oct 11.** [[File Access - Design]] left the ranged read's signature to "the M6 card", and nothing said how `Writer` and `Reader` take a kind. Miguel chose a `BlobKind` passed to each header call, not to the constructor, because component blocks and pack entries are read by readers over a slice with no header. The scene and pack kinds belong to S8-T3 and S8-T4, so this card ships no kind constant. The read is `readRange(path, u64 offset, u64 size, out)`, with a new `FileError::OutOfRange`, so a corrupt pack offset is not mistaken for a disk failure. Both calls are now in [[Serialization - Design]] and [[File Access - Design]]. **A deliberate asymmetry with `read`:** `readRange` leaves `out` untouched on every failure, even a read that fails after the range check, while `read` clears it. Unblocks S8-T3, S8-T4 and S8-T6; Story A stays open with S8-T2. **Retro:**
	  - Miguel's first `readRange` ended by calling itself instead of reading. Every level held an open stream until Windows ran out of handles, so each of the eight success cases failed with `IoError` after about 550 ms. The past-end and miss cases passed, because they return before the call. At Miguel's request, Claude wrote the seek and the read, plus the `tellg() < 0` guard that `read` also has.
	  - Diff coverage first failed at 84% against the 85% gate, on three `IoError` paths. A permission case now covers the failed open on Linux, and it calls `SKIP` where the file still opens (Windows, or root). CI then reached 89%. A failed `tellg` and a read that fails after the range check stay uncovered, because no test can set them up.
	  - Claude wrote the scaffold, the tests and the `readRange` fix. Miguel wrote the header bodies and the first `readRange`. The PR has no body or review conversation, and the squash is titled "Headers blob", so this entry is the only record of the two signature calls.




%% kanban:settings
```
{"kanban-plugin":"board"}
```
%%