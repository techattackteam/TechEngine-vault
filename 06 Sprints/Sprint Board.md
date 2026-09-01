---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M3's gate · ✅ **complete** *(S5-D1, Aug 31)*



## 📋 F · the bootstrap seam · ✅ **complete** *(S5-T10 + S5-T11, Aug 31)*



## 📋 B · M3 build *(T2 → T1 → T3 → T4 → T5; after Story F)*

- [ ] **S5-T1** · `platform::executablePath()` · P1 · 🟠 Moderate
	  done: `GetModuleFileNameW` / `/proc/self/exe` behind one signature in `platform`; a Catch2
	  case asserts the path exists and names the running test binary; no `current_path()`
	  fallback anywhere.
- [ ] **S5-T3** · the five mutating `FileAccess` calls · P1 · 🟢 Deep
	  **Rewritten Aug 31.** done: `createDirectory` · `remove(path, recursive)` · `copy` ·
	  `move` · `rename(path, newName)` over files and directories, all on `FileResult`, all
	  through `resolveForCreate`; **`FileResult` gains `AlreadyExists` and `NotEmpty`**;
	  **`write` returns `NotFound` for a missing parent instead of `IoError`**, and
	  `createDirectory` is the call that creates parents; Catch2 pins each against a scratch
	  directory including the mount-root, missing-parent, already-exists and non-empty cases;
	  green on all legs. Needs S5-D1.
- [ ] **S5-T4** · `project.toml` + the `Project` type · P1 · 🟢 Deep
	  **Rewritten Aug 31: editor-local, and `root` is derived not stored.** done: `Project` in
	  `apps/editor/src/project/` loads `project.toml` through toml++ in its **non-throwing**
	  form, carrying `name` · `shaderDir` · `assetDirs`, root derived from the manifest's own
	  location; load and save both owned by `Project`, both through `FileAccess`; malformed,
	  unreadable or missing returns a `ProjectResult`; Catch2 in `apps/editor/tests/` pins good,
	  malformed, missing, and a path escaping the root. Needs S5-D1, S5-T10.
- [ ] **S5-T5** · the two bootstraps + `projects/dev/` testbed · P1 · 🟠 Moderate
	  **Rewritten Aug 31: the old "runtime loads it by default" is reversed by ADR-017.** done:
	  `EditorApp::init()` mounts `project` from `argv` and `engine` off `executablePath()`,
	  reads the manifest, mounts the `assets` and `shaders` it names; `RuntimeApp::init()`
	  mounts a fixed layout and **reads no manifest**; **the `TODO(S3-T13)` demo-mount block is
	  deleted from `App.cpp` and `engine/app/CMakeLists.txt`**; `projects/dev/` exists at repo
	  root as data with a real `project.toml` and **the editor** loads it by default.
	  Needs S5-T1, S5-T4, S5-T11.


## 📋 C · M4's gate · ✅ **complete** *(S5-D2, Aug 30)*



## 📋 D · M4 build *(T6 → P4 → T7 → T8; T9 last)*

- [ ] **S5-T6** · glad2 generated, vendored and wired · P1 · 🟠 Moderate
	  done: `external/glad/` holds `include/glad/gl.h` + `src/gl.c` from
	  `glad --api gl:core=4.5 --extensions= --out-path external/glad --reproducible c`, that
	  command in a comment above the target; wrapped in `cmake/deps.cmake`, **not** linking
	  `te_warnings`, include dir `SYSTEM` (ADR-008 §5); `client` links it, `platform` does not.
	  Ride-along: `deps.cmake`'s `FETCHCONTENT_UPDATES_DISCONNECTED` comment is backwards.
- [ ] **S5-T7** · `platform::Window` + the context on the render thread · P1 · 🟢 Deep
	  done: `Window` owns the `GLFWwindow*`; `initialize`/`open`/`pollEvents`/`close` are
	  main-thread-only, `makeContextCurrent`/`releaseContext`/`swapBuffers`/`procLoader` serve the
	  render thread; `client` spawns that thread, claims the context once and calls
	  `gladLoadGL(window.procLoader())` **there, not at startup**; joined before `close()`;
	  `platform/CMakeLists.txt`'s glad comment corrected; `linux-tsan` green.
	  Needs S5-T6, S5-P4.
- [ ] **S5-T8** · clear + triangle through the frame mailbox · P1 · 🟢 Deep
	  done: main publishes a `FramePacket` per frame, the render thread consumes the newest and
	  re-draws the last when none is new; a triangle renders; **the main thread issues no GL
	  call**, and a Tracy capture shows GL zones on the render thread only — that capture is the
	  real proof, not the triangle. `linux-tsan` green. **Tier 2 demo.** Needs S5-T7.
- [ ] **S5-T9** · raw input through `Window` · P2 · 🟠 Moderate
	  done: keyboard and mouse arrive through GLFW callbacks into a `platform` input buffer that
	  main drains inside `pollEvents`; no callback touches the render thread or issues a GL call;
	  a Catch2 case pins the drain semantics. Gamepad and text input explicitly out.
	  **First cut inside this story.**


## 📋 E · Process *(first thing cut)*

- [ ] **S5-P2** · 🤖 [[Known Issues]] D1's fallback fix · P3 · 🤖 Auto
	  done: `TE_LOG_ACTIVE_LEVEL`'s fallback matches CMake's per-config default (`INFO` under
	  `NDEBUG`, else `TRACE`) per D1's written fix, plus a config-table Catch2 case mirroring
	  `AssertTests.cpp`; **D1 deleted in the same commit**; the run builds Linux and passes
	  `ctest` before opening the PR, and never merges it.
	  **The lane's first code card — the PR path is unproven, so this tests the lane too.**
	  **Unblocked Sep 1: S5-P1's "ordered before P2" clause is discharged and that card is
	  closed.** Two fires declined this card on that ordering; the next one should take it.
	  It also inherits S5-P1's dropped clause: **confirm the one-PR-per-day cap** across the
	  day's fires, which only a PR-opening run can observe.
- [ ] **S5-P4** · xvfb on the Linux legs · P2 · 🟡 Light
	  done: `ci.yml`'s Linux install step gains `xvfb` and `libgl1-mesa-dri` (the existing
	  `libgl1-mesa-dev` is headers + `libGL`, not the llvmpipe driver); the test step runs
	  `xvfb-run -a ctest` with `LIBGL_ALWAYS_SOFTWARE=1`; a run on `master` confirms llvmpipe
	  advertises **GL 4.5 core**. **Cut at S5-D2, not in the original sizing.**
	  **Lands alone** and is read from the `master` run, since a workflow-only PR draws no CI
	  since #54. If llvmpipe caps below 4.5, drop the CI leg's context version, not the test.
	  Ordered before S5-T7.
- [ ] **S5-P3** · 🤖 vault `file:line` citation sweep · P3 · 🤖 Auto
	  done: every `path:line` citation in the durable artifacts is resolved against the tree and
	  the 8 known-wrong ones corrected (three in `App.cpp`, two in [[Known Issues]], two in
	  [[Profiler — Design]]); the report says whether the check belongs in `/weekly-review` or in
	  CI. Vault-only, so no PR and no CI cost.


## 🔨 In Progress

- [ ] **S5-T2** · `MountTable::mount()` validation · P2 · 🟡 Light
	  done: `mount()` rejects an empty alias, one with `/`, and one with `:` via `TE_CHECK` with
	  a defined path; a Catch2 case pins each; **[[Known Issues]] D2 deleted in the same commit.**
	  **First, because D2's own trigger says fix it before the M3 mount port.**
	  Optional ride-along: D3 is in the same file, but its fix costs a directory scan per
	  component, so taking it is a deliberate call.


## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 05 — M3 Project & M4 Window]]

- [x] **S5-P1** · watch the routine's first real fires · P2 · 🟡 Light · **Sep 1**. Attended
	  and vault-only, so no branch and no PR. **Both surviving clauses confirmed across four
	  fires**, two on Aug 31 and two on Sep 1: one report note per day with a section appended
	  per fire, and each fire reading what the earlier ones did rather than redoing it. The
	  Sep-1 second fire is the clearest case, declining to re-enter S5-P3 because the morning
	  fire had left it open.
	  **The third `done:` clause was unreachable, and dropping it is why this card closes.** It
	  asked for the one-PR-per-day cap confirmed across the day's fires. The lane has never
	  opened a PR, S5-P2 is the card that would, and this card was **ordered ahead of S5-P2**.
	  So the clause could only be satisfied after the card it blocked. It moves to S5-P2, which
	  proves the PR path anyway. Its "four fires" wording was stale on top of that: `1f4ebfb`
	  cut the schedule to two on the morning of the first fires it was written to count.
	  **Retro line: re-scoped twice, once on its own planning day.** Aug 30 turned *create the
	  routine* into *watch it*, because the routine went live hours after it was planned. Sep 1
	  dropped the PR clause. A card rewritten that often had a subject still moving under it.
	  **Two misbehaviours found, neither reaching the `B` card the card's escape hatch names:**
	  the live routine still ran the four-fire prompt text after `1f4ebfb` updated the vault's
	  copy (a paste, not a card), and an empty Auto lane leaves a second fire with no work by
	  construction (moot once Sprint 05 filled the lane).
	  **Unblocks S5-P2.** Does not close Story E.
- [x] **S5-T11** · the `App` base class and `EntryPoint.hpp` · P1 · 🟢 Deep · **Aug 31**,
	  `b6273327` (#63). No review comments on the PR; the review happened in session. Merged
	  with **`[skip-coverage]`** in the description, so the diff-coverage gate reported no
	  number for a card that deleted ~200 lines and added a suite.
	  **The demo body was deleted, not moved.** The clause said `run()`'s body "moves into a
	  `RuntimeApp` subclass unchanged". Events, the S4-T7 serialization round-trip, the job
	  batch and the math format lines are all gone instead. That leaves the `TODO(S3-T13)`
	  block, `TE_DEMO_ASSETS_DIR`, `engine/app/assets/demo.txt` and `demo-material.bin`
	  **orphaned**: S5-T5 was going to delete them with their consumer, and the consumer went
	  first. S5-T5 should now sweep them.
	  **All four virtuals shipped pure**, against both this card's clause and
	  [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] § *Decision* 3, which
	  makes `init()` the only pure one. The cost the ADR predicted is already visible: four
	  empty bodies across the two subclasses. **Live divergence — no amendment filed.**
	  **The lifecycle went the wrong way and came back.** `EntryPoint.hpp` first called
	  `init()`, `run()`, `shutdown()` itself and returned a literal `0`, discarding `run()`'s
	  `int`. That is v1's `EntryPoint.cpp:6-11` shape by structure. Review pulled the sequence
	  into `App::run()`, which now owns it and returns its own code; the hooks went `protected`.
	  **The card's central bug shipped to review invisible to every test.** `App::run()`
	  declared locals shadowing all six members it owned, so the subclass's role never reached
	  the loop and anything `init()` mounted was unreachable from it. **Retro line:** the new
	  `AppTests` mount case was claimed in review to catch this. It does not — it never touches
	  `run()`. Fixed before merge, still untested, and [[Backlog]] carries why.
	  **Logged not fixed: [[Known Issues]] D4** (`toString(Role)` allocating per frame).
	  **Closes Story F.** Unblocks S5-T5.
- [x] **S5-T10** · `techengine_app()` and apps as object libraries · P1 · 🟠 Moderate ·
	  **Aug 31**, `76056402` (#62). No review comments, no findings logged.
	  **The card's own `done:` clause had no referent when it was written.** It asked for an
	  OBJECT library "of its sources", and both apps held nothing but `main.cpp`, which belongs
	  to the exe. CMake rejects an object library with no sources. Grounding caught it, and
	  Miguel's call was to give each app a placeholder `.hpp`/`.cpp` rather than make `SOURCES`
	  optional in the helper. So `SOURCES` stayed required, matching `techengine_module()`, and
	  the helper shipped with no special case in it. The placeholders are `runtimeRole()` and
	  `editorRole()`, both `TODO(S5-T11)`, both returning `Role::Client`.
	  **The helper's usage block was written and deleted before it shipped.**
	  `cmake/techengine_app.cmake` now starts at `function(`, so it is the only helper in
	  `cmake/` without the argument contract and rationale at the top that
	  `techengine_module.cmake` and `techengine_test.cmake` both carry. Worth a retro line:
	  either the block was cut deliberately and that convention has changed, or it went by
	  accident and the next reader of the helper pays for it.
	  **Unblocks S5-T11 and S5-T4**, both of which needed an app test target to exist. Does not
	  close Story F.
- [x] **S5-D1** · project design note · P1 · 🟢 Deep · **Aug 31**. [[Project — Design]] created
	  with a filled *Decided* table: the schema (`name` · `shaderDir` · `assetDirs`, with the
	  **root derived** from the manifest's location, not stored in it), v1's mount set mapped
	  across, and the semantics of all five mutating `FileAccess` calls. Vault-only, no branch,
	  no PR. It answered [[File Access — Design]]'s open question: **`write` does not create
	  missing parents and returns `NotFound`; `createDirectory` is the call that does.**
	  **It produced an ADR the artifact gate said was not needed.** The gate marked M3 `❌ ADR`
	  on the grounds that the decisions were largely settled. That held for the manifest and the
	  mount set. It did not hold for *who bootstraps*: whether a shipped runtime reads a
	  manifest at all had no artifact anywhere.
	  [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] settles it. The
	  manifest is **editor-only**, `Project` is exe-local editor code, and `app` owns the
	  lifecycle through a base class every executable subclasses.
	  **It partially supersedes ADR-006 §1**'s "editor out of the frame loop" clause, which was
	  the F14 fix. Safe because §1 predates ADR-015: the render thread consumes the last
	  complete command list, so a stalled main thread no longer freezes presentation. The cost
	  is that keeping editor work off the sim frame becomes discipline, not structure.
	  **Cost to the sprint:** three Story B cards rewritten and **Story F added ahead of them**,
	  putting the 🟠 column at 2.5× capacity. Story D is now the expected casualty rather than a
	  checkpoint decision.
	  **Left unverified:** none of it is compiled. `techengine_app()` does not exist yet and the
	  `App` base class is a design, so S5-T10 and S5-T11 carry the first real proof.
- [x] **S5-D2** · window design note · P1 · 🟢 Deep · **Aug 30**, on the boundary weekend, so it
	  cost nothing from the Aug 31 to Sep 11 capacity. [[Window — Design]] created as the hub,
	  surface pinned ahead of the cards. Vault-only, no branch, no PR.
	  **Taken out of order:** the sprint note ordered S5-D1 first. D2 was pulled forward because
	  it held the sprint's biggest unknowns, and answering them early is what tells you whether
	  the merged-rung gamble pays. The two Design cards are independent, so nothing was blocked.
	  **All four clauses settled.** glad2 is `gl:core=4.5`, no extensions, `--reproducible`,
	  committed under `external/glad/` · `platform` owns GLFW, the window and raw input and
	  issues **no GL call ever**, while `client` owns the context, glad2 and every `gl*` call,
	  reaching the window through three methods rather than through `glfw*` · the frame handoff
	  is a single-slot **mailbox**, newest-complete-wins, with the real list format left to R1 ·
	  CI runs `xvfb-run`.
	  **It moved an Accepted ADR.** ADR-006 §1 listed window and input under **both** `platform`
	  and `client` and put glad2 in `platform`. That row could not be followed as written, so a
	  dated `decision` amendment resolves the overlap toward `platform` and moves glad2 to
	  `client`. A latent contradiction nobody had read closely, not new drift.
	  **xvfb was chosen over the house rule, and the reason is the merge gate.** CLAUDE.md
	  § *Testing* says rendering is verified by demo captures, not unit tests. But `diff coverage`
	  is required at 85% and no CI job runs the `runtime` exe, so M4's diff would have forced
	  excluding all of `client` — hollowing out the gate on the largest module still unwritten.
	  Running the code keeps both the gate and the Linux window path honest.
	  **One planning claim was wrong and is corrected in the note:** CI already installs GLFW's
	  Linux build dependencies on every leg, so clause (d) was only ever about a display at
	  *test* time, never the build.
	  **Left unverified, and it is the note's biggest risk:** nothing here has been run, and
	  whether llvmpipe advertises GL 4.5 on the runner image is unknown. S5-P4 carries the
	  fallback.
	  **Cut Story D** into S5-T6 → S5-P4 → S5-T7 → S5-T8, with S5-T9 last, per this card's own
	  done-condition.




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,null,null,null,null,null,null,null,null]}
```
%%