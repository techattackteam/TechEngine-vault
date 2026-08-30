---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M3's gate *(ordered first)*

- [ ] **S5-D1** · project design note · P1 · 🟢 Deep
	  done: `Project — Design` exists with a filled *Decided* table — the `project.toml` schema
	  (root · name · shader dir · asset dirs, nothing more), v1's mount set
	  (`ProjectManager.cpp:262-271` @ `v1-reference`), and the semantics of all five mutating
	  `FileAccess` calls; it answers [[File Access — Design]]'s "should `write` create missing
	  parent directories?"; **Story B's cards are cut against it.**


## 📋 B · M3 build *(T2 → T1 → T3 → T4 → T5)*

- [ ] **S5-T2** · `MountTable::mount()` validation · P2 · 🟡 Light
	  done: `mount()` rejects an empty alias, one with `/`, and one with `:` via `TE_CHECK` with
	  a defined path; a Catch2 case pins each; **[[Known Issues]] D2 deleted in the same commit.**
	  **First, because D2's own trigger says fix it before the M3 mount port.**
	  Optional ride-along: D3 is in the same file, but its fix costs a directory scan per
	  component, so taking it is a deliberate call.
- [ ] **S5-T1** · `platform::executablePath()` · P1 · 🟠 Moderate
	  done: `GetModuleFileNameW` / `/proc/self/exe` behind one signature in `platform`; a Catch2
	  case asserts the path exists and names the running test binary; no `current_path()`
	  fallback anywhere.
- [ ] **S5-T3** · the five mutating `FileAccess` calls · P1 · 🟢 Deep
	  done: `createDirectory` · `remove` · `copy` · `move` · `rename` over files and directories,
	  all on `FileResult`, all through `resolveForCreate`; Catch2 pins each against a scratch
	  directory including the mount-root, missing-parent and already-exists cases; green on all
	  legs. Needs S5-D1.
- [ ] **S5-T4** · `project.toml` + the `Project` type · P1 · 🟢 Deep
	  done: `Project` loads and validates a manifest through toml++ (already pinned in
	  `deps.cmake`), carrying only root · name · shader dir · asset dirs; malformed or missing
	  returns a defined error rather than throwing; Catch2 pins good, malformed and missing.
	  Needs S5-D1.
- [ ] **S5-T5** · the real mount set + `projects/dev/` testbed · P1 · 🟠 Moderate
	  done: `App.cpp` mounts relative to `executablePath()`, not the configure-time define;
	  **the `TODO(S3-T13)` demo-mount block is deleted from `App.cpp` and
	  `engine/app/CMakeLists.txt`**; `projects/dev/` exists at repo root as data with a real
	  `project.toml` and the runtime loads it by default. Needs S5-T1, S5-T4.


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

- [ ] **S5-P1** · watch the routine's first real fires · P2 · 🟡 Light
	  **Re-scoped Aug 30:** the card said *create the routine*, and it went live at 18:00 the
	  same day — four fires a weekday, 05:07 / 10:07 / 15:07 / 00:07 Lisbon. Watching it is what
	  is left, and no fire has happened yet because it went live on a Sunday.
	  done: the first weekday's fires are read and three things confirmed against
	  [[Autonomous Lane — Design]] — **one** report note per day with a section appended per
	  fire, each fire reading what the earlier ones did rather than redoing it, and the
	  **one-PR-per-day** cap holding across four fires. Anything that misbehaves becomes a `B`
	  card, not a note edit. **Ordered before P2**, the first fire allowed to open a PR.
	  DST edge: cron is UTC, so every fire shifts an hour earlier on 25 October.
- [ ] **S5-P2** · 🤖 [[Known Issues]] D1's fallback fix · P3 · 🤖 Auto
	  done: `TE_LOG_ACTIVE_LEVEL`'s fallback matches CMake's per-config default (`INFO` under
	  `NDEBUG`, else `TRACE`) per D1's written fix, plus a config-table Catch2 case mirroring
	  `AssertTests.cpp`; **D1 deleted in the same commit**; the run builds Linux and passes
	  `ctest` before opening the PR, and never merges it.
	  **The lane's first code card — the PR path is unproven, so this tests the lane too.**
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



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 05 — M3 Project & M4 Window]]

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
