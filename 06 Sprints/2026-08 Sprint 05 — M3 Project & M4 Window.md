# 2026-08 · Sprint 05 — M3 Project & M4 Window

- **Quarter:** [[2026-Q3]]
- **Dates:** **Sat Aug 29 to Fri Sep 11, 2026.** The boundary was pulled **one week early**
  because Sprint 04 met its goal on day 9 and left an empty board
  ([[Dashboard]] § *Rhythm* → an early close moves the boundary). Sat → Fri is intact and the
  next boundary is **Sat Sep 12**. Weekly review on the Sep 5-6 weekend.
- **Epic:** M3 · project **+** M4 · window ([[Roadmap]] → *The chain*) — **two rungs in one
  box**, decided 2026-08-30 with the capacity numbers on the table. See *Capacity note*.
- **Decisions behind it:** [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]]
  (Accepted 2026-08-31, **written mid-sprint out of S5-D1** — see *Artifact gate*) ·
  [[File Access — Design]] § *The write surface* · § *Who uses it* ·
  [[ADR-015 — Threading (sim on main, render thread owns GL)]] §2 (M4's gate, Accepted) ·
  [[ADR-006 — v2 core architecture & module layout]] §1 (`platform` owns window + input) ·
  [[ADR-008 — v2 build & testing baseline]] §4 case 3 (glad2 is the one vendored dep) ·
  [[Roadmap]] § *M3 — the dev testbed*

## 🎯 Sprint goal

> **Ship M3 and open the window: `projects/dev/` loads through a real `project.toml`, and a
> triangle draws on the render thread.**
>
> M3 is the commitment. M4 is the reach, and it is honestly at risk. See *Capacity note*.

### Scope calls locked at planning (2026-08-30)

| Question | Call | Why |
|---|---|---|
| Merge M3 and M4 into one box? | **Yes**, against the sizing advice. | Miguel's call, taken after the 🟠 column was shown at double capacity. The mitigation is a pre-named cut order, not a smaller plan. |
| Start a week early? | **Yes.** Boundary moves to Aug 29-30. | Sprint 04 closed with an empty board and 5 days left. The cost is one weekend deep day, which is real and is priced into *Capacity note*. |
| M3's design note: draft in session, or a card? | **A 🟢 Design card, ordered first.** | The five mutating calls' semantics and v1's mount set need reading, not a planning sidebar. |
| M4's build story: sized at planning? | **No. Deliberately unsized** at the time. **Discharged 2026-08-30** when S5-D2 landed and cut it. | Its note had open mechanism: the glad2 shape, headless CI, and the M4-level render-thread seam. [[Planning Workflow — Artifact Gate]] § *Don't size past an open decision*. The estimate behind it (~2 🟢 + 2 🟠) turned out exact. |
| RNG, crash handler | **Carry, third sprint running.** | Still no consumer, still artifact-less. Flagged in the retro as owing a decision rather than a fourth silent carry. |
| Error handling ADR, ccache key, branch-link guard | **Not pulled**, though all three triggers have fired. | The sprint is already at zero slack. They stay on [[Backlog]] at `#prio/high`. |

## 🚦 Artifact gate

| Item | ADR? | Design note? | Outcome |
|---|---|---|---|
| **Project / M3** — manifest schema · root resolution · the mount set · the five mutating calls | ❌ → **✅ ADR-017** | ✅ | **Coverage gap, said out loud: no note exists.** [[File Access — Design]] covers the VFS and stops at the project. → **S5-D1**, done 2026-08-31. <br>**The `❌ ADR` call was wrong, and this is the sprint's main planning miss.** "The decisions are largely settled" held for the manifest and the mount set. It did not hold for *who bootstraps*: the runtime's relationship to the manifest was never decided anywhere, and settling it took [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]]. That ADR added **Story F**, and Story B did **not** size normally. |
| **Window / M4**: glad2 vendoring · what `platform` owns · the M4-level context handoff · headless CI | ❌, ADR-015 §2 already decided the owner | ✅ | **Second coverage gap.** No ADR is owed: ADR-006 §1, ADR-008 §4 and ADR-015 §2 between them decide module, vendoring and ownership. What is open is **mechanism**, which is a note's job. Heavy, so Story D was held unsized. → **S5-D2**, done 2026-08-30, and it moved ADR-006 §1 by dated amendment |
| `executablePath` · mount validation · the routine · the two Auto cards | ❌ **→ mount validation needed an ADR amendment** | ❌ | Reversible and local, straight to cards. <br>**The second gate miss of the sprint, and the same shape as the first.** "Reversible and local" held for the three alias rules. It did not hold for *what a fatal check guarantees*: writing the card's `TE_CHECK` clause exposed that ADR-011 §5 never said whether the abort was reachable-past, and the engine had shipped both readings. Settled by a dated amendment on 2026-09-01, which then re-tiered ten call sites across `core`. See S5-T2. |

## Stories & tasks

> Every task carries `· P1/P2/P3 · 🟢 Deep / 🟠 Moderate / 🟡 Light / 🤖 Auto`. Weight fits the
> day first, then priority ([[Planning Workflow — Artifact Gate]]).

### Story A — M3's gate *(Design · ordered first; Story B waits on it)*

- [x] **S5-D1** · project design note via the Design Doc template · P1 · 🟢 Deep —
      **done 2026-08-31.** [[Project — Design]] created with a filled *Decided* table: the
      `project.toml` schema (name · shader dir · asset dirs, with the **root derived** from the
      manifest's own location rather than stored in it), the mount set mapped off v1's
      (`ProjectManager.cpp:262-271` @ `v1-reference`), and the semantics of all five mutating
      `FileAccess` calls. It answers [[File Access — Design]] § *Open questions* →
      **`write` does not create missing parents and returns `NotFound`; `createDirectory`
      does create them.**
      **It also produced an ADR the gate did not expect.** Three decisions had no artifact:
      the manifest is editor-only, `Project` is exe-local editor code, and `app` owns the
      lifecycle through a base class every executable subclasses. That is
      [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]], Accepted 2026-08-31,
      and it **partially supersedes ADR-006 §1**'s "editor out of the frame loop" clause.
      **Story B was re-cut against it and Story F was added ahead of both.**

### Story F — the bootstrap seam *(Build · ordered before Story B; cut 2026-08-31 off ADR-017)*

> Ordering: **T10 → T11.** T10 gives every app a test target, and T11's cases need one.
> Neither card existed at planning. Both are the price of the ADR the gate missed.

- [x] **S5-T10** · `techengine_app()` and apps as object libraries · P1 · 🟠 Moderate —
      **done 2026-08-31**, `76056402` (#62). `SOURCES` stayed **required**: rather than teach
      the helper to tolerate an empty object library, each app got a placeholder `.hpp`/`.cpp`
      carrying a `TODO(S5-T11)`. Entry on [[Sprint Board]].
      **As cut:** a `cmake/techengine_app.cmake` helper stamps out three targets per app — an **OBJECT**
      library holding the app's sources, the exe that consumes its objects plus `main.cpp`, and
      a Catch2 test exe consuming the same objects — and appends the test exe to
      `TE_TEST_TARGETS` so coverage picks app tests up exactly like a module's; `apps/runtime`
      and `apps/editor` both go through it; one placeholder Catch2 case per app proves the test
      exe links and is discovered by CTest. **An object library, not a static one**: it
      produces no archive and can be nobody's link dependency, so the exe stays the leaf
      ADR-006 §1 calls it. Sharing the exe itself would need `ENABLE_EXPORTS`
      (ADR-017 § *Consequences*).
- [x] **S5-T11** · the `App` base class and `EntryPoint.hpp` · P1 · 🟢 Deep —
      **done 2026-08-31**, `b6273327` (#63). Two clauses did not hold: the demo body was
      **deleted** rather than moved, and **all four virtuals shipped pure** rather than only
      `init()`. Entry on [[Sprint Board]]. **As cut:** done: `App` in
      `engine/app` owns `MountTable`, `FileAccess`, `Clock`, `JobSystem` and the `FrameLoop`,
      and calls `init` · `fixedUpdate` · `update` · `shutdown`, where `init()` is the **only**
      pure one and the two loop hooks take `const FrameContext&`; `main()` lives in
      `<TechEngine/app/EntryPoint.hpp>` and **never in the `app` library**, so
      `TechEngineAppTests` still links Catch2's own `main`; `run()`'s current demo body moves
      into a `RuntimeApp` subclass unchanged, so this card changes shape and not behaviour;
      `apps/editor` gains an `EditorApp` whose `init()` stays empty until S5-T5.
      **No `std::function` member on `App`, and no second loop driver** — that is the v1 shape
      ADR-017 § *Decision* 3 rules out by name. Needs S5-T10.

### Story B — M3 build *(Dev · **re-cut 2026-08-31**; it did not size normally, see *Artifact gate*)*

> Ordering: **T2 → T1 → T3 → T4 → T5**, after Story F. T2 is first because [[Known Issues]]
> **D2** names the M3 mount port as its trigger and says to fix it *before* that port.

- [x] **S5-T2** · `MountTable::mount()` validation · P2 · 🟡 Light **→ 🟠 Moderate** —
      **done 2026-09-01**, `4e3c6f7f` (#64). Entry on [[Sprint Board]].
      **rewritten 2026-09-01 mid-card. The original clause named the wrong mechanism, and
      following it surfaced a contract the ADR never settled.** It read "via `TE_CHECK` with a
      defined path, following the `EventRegistry::registerType` shape". That shape writes a
      recovery path after a fatal check, which no sanctioned handler ever reaches, and building
      it required a test that inspected a state production cannot produce. Settling it took
      [[ADR-011 — Diagnostics (Logger & Assert)]] § *Amended 2026-09-01*, which the artifact
      gate marked as needing no ADR work. **The re-tier below is the price of that amendment,
      and it is what moved the weight.**
      done: `mount()` rejects an empty alias, one containing `/`, and one containing `:` with
      three bare `TE_CHECK`s and **no recovery path**, since a fatal tier does not return;
      a `FatalAssertGuard` in `tests/support` swaps in a throwing handler so a Catch2 case reads
      `REQUIRE_THROWS_AS` rather than inspecting a table after an abort; `AssertCapture.hpp`
      moves from `engine/core/tests/events/` into `tests/support/` so a second module can reach
      it; **the ten mis-tiered `TE_CHECK` sites move to `TE_ENSURE`** — five in
      `EventRegistry.cpp`, three in `JobSystem.cpp`, one each in `Writer.cpp` and `Writer.hpp`,
      all of which carried graceful degradation after a fatal check; their Catch2 cases assert
      `AssertKind::Ensure`; **[[Known Issues]] D2 is deleted in the same commit.**
      **Not re-tiered, and the distinction is the rule:** `EventStream.cpp:13-14` and
      `JobSystem.cpp:143-145` have no recovery path. The job-worker pair sits inside a `catch`,
      so the throwing guard cannot reach it and that suite keeps the counting guard.
      Optional ride-along: **D3** lives in the same file (`MountTable.cpp`), so its
      per-component spelling check may ride this PR. Its fix costs a directory scan per
      component, so taking it is a deliberate call rather than automatic.
- [x] **S5-T1** · `platform::executablePath()` · P1 · 🟠 Moderate **→ 🟡 Light** —
      **done 2026-09-03**, `a7908904` (#67). Entry on [[Sprint Board]]. **As cut:** `GetModuleFileNameW`
      on Windows and `/proc/self/exe` on Linux behind one signature in `platform`, with a
      Catch2 case asserting the returned path exists and names the running test binary; no
      `current_path()` fallback anywhere.
- [x] **S5-T3** · the five mutating `FileAccess` calls · P1 · 🟢 Deep —
      **done 2026-09-03**, `84181fae` (#68). Entry on [[Sprint Board]].
      **rewritten 2026-08-31
      against [[Project — Design]] § *The five mutating calls*: the old clause named no results
      and the enum had no value for two of the cases it asked to be pinned.** done:
      `createDirectory`, `remove(path, recursive)`, `copy(from, to)`, `move(from, to)` and
      `rename(path, newName)` ship on `FileAccess` over both files and directories, all
      returning `FileResult`; **the clause "all resolving through
      `MountTable::resolveForCreate`" is corrected 2026-09-03: that holds for a destination
      only.** `copy`, `move` and `rename` each take a source that must already exist, and
      `resolveForCreate` never probes, so a source living in a lower-priority mount would come
      back `NotFound`. Sources resolve through `resolveExisting`, destinations through
      `resolveForCreate`;
      **`FileResult` gains `AlreadyExists` and `NotEmpty`**; **`write` stops returning the
      generic `IoError` for a missing parent and returns `NotFound`**, while `createDirectory`
      is the call that does create parents; Catch2 pins each against a scratch directory,
      including the mount-root case (`InvalidPath`), the missing-parent case, the
      already-exists case and the non-empty-directory case; green on all legs. Needs S5-D1.
- [x] **S5-T4** · `project.toml` + the `Project` type · P1 · 🟢 Deep —
      **done 2026-09-04**, `e0495146` (#70). Entry on [[Sprint Board]].
      **rewritten 2026-08-31:
      the type is editor-local, not engine code (ADR-017 § *Decision* 2), and the old clause
      put `root` inside the manifest. Rewritten again 2026-09-04: [[Project — Design]]
      § *The manifest* cut the schema to one key, so `shaderDir` and `assetDirs` no longer
      exist and the mount roots are derived by convention.** done: `Project` lives in
      `apps/editor/src/project/` and loads `project.toml` through toml++ in its
      **non-throwing** form, carrying only `name`, with the root **derived** from the
      manifest's own location and **no mount knowledge on the type at all**; load and save are
      both owned by `Project` and both go through `FileAccess`, which is the v1 split this
      fixes; a malformed, unreadable or missing file returns a `ProjectResult` rather than
      throwing; Catch2 cases live in `apps/editor/tests/project/` and pin a good file, a
      malformed one, a missing one, a `manifestPath` that escapes the root, a missing `name`
      and a `name` of the wrong type. Needs S5-D1, S5-T10.
      **Three things landed that the clause did not name.** `ProjectResult` gained
      **`WriteFailed`**, because the four values it was written with had none for a failed
      write and `save` would otherwise have reported a read error. `cmake/deps.cmake` gained a
      **`TechEngine::tomlplusplus` wrapper carrying `TOML_EXCEPTIONS=0`**: the upstream default
      makes `toml::parse_result` an alias for `toml::table`, so the non-throwing form the
      clause asks for is a build setting rather than a call choice. And the
      `.claude/output-styles/techengine.md` change **rode along uninvited**, 93 lines of it.
- [x] **S5-T5** · the two bootstraps + `projects/dev/` testbed · P1 · 🟠 Moderate —
      **rewritten 2026-08-31: the old clause read "the runtime loads it by default", which
      ADR-017 § *Decision* 1 reverses outright. Rewritten again 2026-09-04, when
      [[Project — Design]] § *The project layout* decided the on-disk shape: the old mount
      clause had the manifest naming the asset roots, and the role selects them now.** done:
      `EditorApp::init()` mounts `project` at the root from `argv` and `engine` off
      `executablePath()`, reads the manifest, and **derives three roots from `project.root()`**
      — `shaders`, plus `assets` at `assets/common` (priority 0) and `assets/client` (100) —
      mounting all of them into the one `MountTable` the base owns;
      `RuntimeApp::init()` mounts a fixed layout off `executablePath()` and **reads no
      manifest**; `projects/dev/` exists at repo root as data, not a CMake target, with a real
      `project.toml` and the **three-way `assets/` split** (`common` · `client` · `server`)
      beside `shaders/`, and **the editor** loads it by default.
      Needs S5-T1, S5-T4, S5-T11.
      **The demo-mount clause is struck, 2026-09-01, `40f7171e` (#65): it landed early and in
      two halves.**
      It read "the `TODO(S3-T13)` demo-mount block is deleted from both `App.cpp` and
      `engine/app/CMakeLists.txt`". S5-T11 took the `App.cpp` half by deleting the demo body
      rather than moving it, which left the define feeding nothing, and the CMake half went
      with the assets in its own PR ahead of this card. **A fifth item came with it that no
      card had named:** `.gitignore` still hid `engine/app/assets/demo-material.bin`, a blob
      written by the S4-T7 demo, so the rule outlived its writer and would have masked a real
      file at that path.

### Story C — M4's gate *(Design · ordered before Story D)*

- [x] **S5-D2** · window design note · P1 · 🟢 Deep — **done 2026-08-30**, on the boundary
      weekend, so it cost nothing from the Aug 31 to Sep 11 capacity below.
      [[Window — Design]] created as the hub, surface pinned ahead of the cards.
      All four clauses settled: **(a)** glad2 generated `gl:core=4.5`, no extensions,
      `--reproducible`, committed under `external/glad/` and wrapped in `deps.cmake`;
      **(b)** `platform` owns GLFW, the window and raw input and issues **no GL call ever**,
      `client` owns the context, glad2 and every `gl*` call, reaching the window through three
      methods rather than through `glfw*`; **(c)** a single-slot **mailbox** carrying a trivial
      `FramePacket`, newest-complete-wins, with the real list format left to R1;
      **(d)** **`xvfb-run` on the Linux legs**, chosen over compile-only because the required
      `diff coverage` gate would otherwise force excluding all of `client`.
      **It moved an Accepted ADR.** ADR-006 §1 listed window and input under *both* modules and
      put glad2 in `platform`; a dated `decision` amendment now resolves the overlap toward
      `platform` and moves glad2 to `client`. The overlap was a latent contradiction nobody had
      read closely, not new drift.
      **One planning claim was wrong and is corrected**: CI already installs GLFW's Linux build
      dependencies on every leg, so clause (d) was only ever about a *display at test time*.

### Story D — M4 build *(cut 2026-08-30 off [[Window — Design]])*

> Ordering: **T6 → P4 → T7 → T8**, with T9 last because it is the pre-named first cut inside
> this story. P4 comes before T7 because a window test cannot pass CI until xvfb is in place.
>
> **ADR-015 §2 forbids the cheap version.** The context is current on the render thread from
> the first line. A main-thread clear "for now" is the retrofit M2 exists to prevent, and that
> ADR's § *Alternatives considered* rejected it by name.

- [ ] **S5-T6** · glad2 generated, vendored and wired · P1 · 🟠 Moderate — done:
      `external/glad/` holds `include/glad/gl.h` and `src/gl.c` from
      `glad --api gl:core=4.5 --extensions= --out-path external/glad --reproducible c`, with
      that command in a comment above the target; the target is wrapped in `cmake/deps.cmake`,
      **does not link `te_warnings`**, and declares its include dir `SYSTEM` (ADR-008 §5), so
      `-Werror` never reaches it; `client` links it and `platform` does not; green on all legs.
      Ride-along: `deps.cmake`'s `FETCHCONTENT_UPDATES_DISCONNECTED` comment describes the
      opposite of its value ([[Backlog]] → `etc`).
- [ ] **S5-T7** · `platform::Window` + the context on the render thread · P1 · 🟢 Deep — done:
      `Window` owns the `GLFWwindow*` and exposes `initialize`/`open`/`pollEvents`/`close` as
      main-thread-only, plus `makeContextCurrent`/`releaseContext`/`swapBuffers`/`procLoader`
      for the render thread; `client` spawns the render thread, claims the context once and
      calls `gladLoadGL(window.procLoader())` **there, not at startup**; the thread is joined
      before `close()`; `platform/CMakeLists.txt`'s glad comment is corrected to match the
      ADR-006 amendment; `linux-tsan` is green. Needs S5-T6, S5-P4.
- [ ] **S5-T8** · clear + triangle through the frame mailbox · P1 · 🟢 Deep — done: main
      publishes a `FramePacket` per frame and the render thread consumes the newest, re-drawing
      the last when none is new; a triangle renders; **the main thread issues no GL call**, and
      a Tracy capture shows the GL zones on the render thread only, which is M4's real proof;
      `linux-tsan` green. **This is the sprint's Tier 2 demo.** Needs S5-T7.
- [ ] **S5-T9** · raw input through `Window` · P2 · 🟠 Moderate — done: keyboard and mouse
      arrive through GLFW callbacks into a `platform` input buffer that main reads inside
      `pollEvents`; no callback touches the render thread or issues a GL call; a Catch2 case
      pins the buffer's drain semantics. Gamepad and text input are explicitly out
      ([[Window — Design]] § *Open questions*). **First cut inside this story.**

### Story E — Process *(first thing cut; the mix is called out below)*

- [x] **S5-P1** · watch the routine's first real fires · P2 · 🟡 Light — **done 2026-09-01**,
      attended and vault-only. **Re-scoped twice.** 2026-08-30 turned *create the routine* into
      *watch it*, because the routine went live hours after the card was planned. 2026-09-01
      **dropped the third `done:` clause**, the one-PR-per-day cap, as unreachable: the lane has
      never opened a PR, S5-P2 is the card that would, and this card was ordered ahead of it.
      That clause now lives on S5-P2. What closed: **one report note per day with a section
      appended per fire, and each fire reading what the earlier ones did**, both confirmed
      across four fires on Aug 31 and Sep 1 ([[2026-08-31 Auto Run]], [[2026-09-01 Auto Run]]).
      Two misbehaviours were found and neither warranted the `B` card the card allowed for.
      **Unblocks S5-P2.** The DST edge it used to carry has its durable home in
      [[Autonomous Lane — Routine Prompt]] § *Routine configuration*.
- [x] **S5-P2** · 🤖 [[Known Issues]] **D1's fallback fix** · P3 · 🤖 Auto — done: `Log.hpp`'s
      `TE_LOG_ACTIVE_LEVEL` fallback matches CMake's per-config default (`INFO` under `NDEBUG`,
      else `TRACE`) per D1's written fix, plus a config-table Catch2 case mirroring
      `AssertTests.cpp`; **D1 is deleted in the same commit**; the run builds Linux and passes
      `ctest` before opening the PR, and never merges it. **This is the lane's first code
      card** — the PR path is unproven, so the card tests the lane as much as the fix.
- [ ] **S5-P4** · xvfb on the Linux legs · P2 · 🟡 Light — done: `ci.yml`'s Linux install step
      gains `xvfb` and `libgl1-mesa-dri` (the existing `libgl1-mesa-dev` is headers plus
      `libGL`, not the llvmpipe driver), the test step runs `xvfb-run -a ctest` with
      `LIBGL_ALWAYS_SOFTWARE=1`, and a run on `master` confirms llvmpipe advertises **GL 4.5
      core**. **Cut at S5-D2, so it is not in the original sizing.** It **lands alone** and is
      read from the run it produces on `master`, because a workflow-only PR draws no CI since
      #54 (`ci.yml`'s own header carries that rule). **If llvmpipe caps below 4.5**, drop the
      CI leg's context version rather than the test: the window and thread seam is what it
      proves. Ordered before S5-T7.
- [x] **S5-P3** · 🤖 vault `file:line` citation sweep · P3 · 🤖 Auto — done: every `path:line`
      citation in the durable artifacts is resolved against the tree and the 8 known-wrong ones
      are corrected (three in `App.cpp`, two in [[Known Issues]], two in [[Profiler — Design]]);
      the report says whether the check is cheap enough to belong in `/weekly-review` or in CI.
      Vault-only, so no PR and no CI cost.

## Definition of Done

**Tier 1 — the commitment. The sprint fails without these.**

- [x] M3's editor half is closed: `projects/dev/` exists as data, **the editor** loads it
      through a real `project.toml`, and the `engine` alias resolves relative to the binary
      rather than to a configure-time source path. **2026-09-04**, `934cf999` (#71).
      **Rewritten at that close.** The line used to also ask for the runtime's fixed layout
      and for every mount to be binary-relative. The runtime half is deferred to M6 by
      [[Project — Design]] § *Open questions*, and the editor's default project root is read
      from the working directory until the launcher replaces it ([[Backlog]]).
- [x] Every executable subclasses `App`, and both apps have a test exe that CTest discovers.
      **2026-08-31**, `76056402` (#62) and `b6273327` (#63).
- [x] The `TODO(S3-T13)` demo mount is gone from the tree, and [[Known Issues]] D2 is deleted.
      **2026-09-01, in two PRs.** D2 deleted in `4e3c6f7f` (#64). The demo mount removed in
      `40f7171e` (#65), which was cut off S5-T5's clause because both halves landed before that
      card starts. **This line closed ahead of the card that owned it**, which is why the
      demo-mount clause is struck on S5-T5 rather than waiting there.
- [ ] Both coverage gaps are closed: a `Project — Design` and a `Window — Design` note exist,
      each with a filled *Decided* table, and neither story was cut before its artifact.

**Tier 2 — the reach. Named separately because it is the half at risk.**

- [ ] M4's unlock is demonstrable: a window opens, its GL 4.5 context is current on the render
      thread, and a triangle draws there. The main thread issues no GL call (ADR-015 §2).
- [ ] `external/glad/` holds the generated loader and CI builds it on both legs.

**Tier 3 — process.**

- [x] The autonomous lane has opened, and Miguel has reviewed, **one** unattended code PR.
      **2026-09-03**, `0ac1a9b0` (#66), S5-P2. The review was a silent merge, a day after the
      PR opened. Correctly prefixed branch, Linux build and `ctest` before the PR, never merged
      by the lane.

## Capacity note

**This box is smaller than a normal 2-week box, and that is the price of starting early.**
A 2-week sprint contains two weekends. This one's first weekend, Aug 29-30, was spent on the
Sprint 04 review, its last two merges and this planning session, so **only Sep 5-6 remains**.

| | Normal 2-week box | Sprint 05, as pulled |
|---|---|---|
| 🟢 Deep | 8-10 | **6-7** |
| 🟠 Moderate | 2 | 2 |
| 🟡 Light | 2-4 | 2 |

**Re-counted 2026-08-31, after S5-D1 landed and Story F was cut off ADR-017, then again
2026-09-01 when S5-T2 changed weight. Remaining draw: 5 🟢 · 6 🟠 · 2 🟡 · 2 🤖.**

- 🟢 — T11, T3, T4, T7, T8. **5 against 6-7.** D1 is banked and left the table; T11 took the
  slot it freed, so the slack the 2026-08-30 recount found is gone rather than spent.
- 🟠 — **T10**, T1, T5, T6, T9, **T2**. **Six against two.** This was double capacity on
  2026-08-30 and is now **three times** it.
- 🟡 — P1, P4. **At capacity**, for the first time this sprint, and only because T2 left.

**Re-counted again 2026-09-01: T2 moved 🟡 → 🟠 mid-card.** It was sized as a three-line
`TE_CHECK` and turned into an ADR-011 amendment plus a ten-site re-tier across `core`. The 🟡
column coming back to capacity is not slack: the same work moved into the column that was
already the failure point.

**The 🟠 column stopped being an overrun and became the plan's failure point.** At double it
fit only if two got absorbed by deep days and nothing went wrong, which the 2026-08-30 note
already called a hope rather than a plan. At 2.5× that hope needs three absorptions in a
box that has **one weekend left**. It will not happen.

**What Story F changed, said plainly.** The gate marked M3 as needing no ADR. Settling the
bootstrap took one, and the ADR added a 🟢 and a 🟠 to the sprint's tightest column. Neither
card is optional: T10 gates S5-T4's tests and T11 gates S5-T5, so Story F cannot be the thing
that gets cut. **Story D is now the pre-named casualty, and the decision has moved earlier —
see the cut order.**

**Cut order if capacity tightens:**

1. **S5-T9** (raw input). Named first inside Story D and buys back a whole 🟠. M4's proof is the
   triangle on the render thread, and input is not part of it.
2. **The two 🤖 cards.** Buys back about 30 minutes of PR review and no day capacity, since they
   run in the lane. **S5-P1 left this rung on 2026-09-01**, closed rather than cut, so the 🟡 it
   used to buy back is already banked.
3. **S5-T5's testbed half.** Keep the mount set, defer `projects/dev/`'s contents.
4. **All of Story D**, meaning T6 → P4 → T7 → T8 together. This is the Tier 2 drop. Cutting
   the story cuts S5-P4 with it, since nothing else needs xvfb.
   **Moved up 2026-08-31.** This was the Sep 5-6 checkpoint's decision. With the 🟠 column at
   2.5× it is now the *expected* outcome, and the checkpoint's job is to confirm it rather
   than to discover it.
5. **Never** S5-D1, Story F, or M3's T3/T4. Story F is not optional: T10 gates S5-T4's tests
   and T11 gates S5-T5. S5-D2 is already banked, so the sprint's durable design output
   survives even if no M4 code ships.

**Said out loud: 3 of 11 sized cards are Process (27%), and 2 of those 3 cost no day capacity**
because they run in the 🤖 lane. That is the lane doing exactly what it was cut for
([[Autonomous Lane — Design]] § *Why*).

**Checkpoint at the Sep 5-6 weekly review:** if **Story F and Story B** are not complete by
then, **cut Story D to S5-D2 alone** and let M4's build be Sprint 06's. Compressing it instead
is how the 🟠 column becomes another four-PR Friday. This checkpoint is a pre-named decision,
not a suggestion. **Widened 2026-08-31** from "Story B" to include Story F, which now sits
ahead of it.

Weekend days stay a swappable pair; nothing here is assigned to Sat or Sun.

## Sprint review (fill Sep 12-13)

- What shipped:
- Demo / artifact:

→ Retrospective in [[07 Journal]].
