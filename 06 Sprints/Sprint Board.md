---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M3's gate · ✅ **complete** *(S5-D1, Aug 31)*



## 📋 F · the bootstrap seam · ✅ **complete** *(S5-T10 + S5-T11, Aug 31)*



## 📋 B · M3 build · ✅ **complete** *(S5-T5, Sep 4)* · S5-B1 closed Sep 5



## 📋 C · M4's gate · ✅ **complete** *(S5-D2, Aug 30)*



## 📋 D · M4 build · ✅ **complete** *(S5-T17, Sep 11)*

## 📋 E · Process · ✅ **complete** *(S5-P4, Sep 6)*



## 🔨 In Progress

## 👀 Review / Demo


## ✅ Done — [[2026-08 Sprint 05 — M3 Project & M4 Window]]

- [x] **S5-T17** · simulation independence integration proof · P1 · 🟠 Moderate ·
	  **Sep 11**, `7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)).
	  Miguel confirmed the native Windows move/resize demo while Tracy showed render and
	  simulation progress continuing across `Main.WaitEvents`; the focused profile test consumed
	  delayed input after the stall. PR CI supplied the integrated Linux TSan evidence.
	  **Completes Story D** and closes the remaining Sprint 05 implementation cards.
- [x] **S5-T9** · Window input to fixed ticks · P2 · 🟠 Moderate ·
	  **Sep 11**, `7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)).
	  No acceptance deviation: callbacks publish ordered keyboard, mouse and focus input, and
	  simulation consumes it before fixed ticks. Gamepad, text and editor/CLI commands remain
	  outside this card as cut. Evidence is in [[2026-09-11 Threaded Engine Validation]].
- [x] **S5-T16** · bounded raw-input ingress · P2 · 🟢 Deep ·
	  **Sep 11**, `7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)).
	  The small ordered queue retained explicit overflow recovery and a separate latest-value
	  presentation path; neither consumer drains the other. No acceptance deviation.
- [x] **S5-T15** · editor and simulation integration · P1 · 🟠 Moderate ·
	  **Sep 11**, `7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)).
	  Review found that an unconditional metrics-title write made X11 wake its own event loop.
	  Caching the applied title fixed the loop before merge. The direct `<string>` include did
	  not ride the merge and is recorded on [[Backlog]].
- [x] **S5-T14** · App simulation runner and lifecycle · P1 · 🟢 Deep ·
	  **Sep 11**, `7d2546fc` ([#81](https://github.com/techattackteam/TechEngine/pull/81)).
	  ADR-019 changed the card's time model during review. The merged result replaces the legacy
	  combined `FrameLoop` with fixed simulation ticks, render-owned interpolation and one shared
	  Clock; it does not retain a compatibility path. [[Simulation Thread — Design]] records the
	  shipped lifecycle and evidence.
- [x] **S5-T13** · adopt the shared thread mechanism · P1 · 🟠 Moderate ·
	  **Merged Sep 9; closed Sep 10**, `a60b64bd` ([#79](https://github.com/techattackteam/TechEngine/pull/79)).
	  The PR had no description, review comments or reviews; GitHub reported 11 checks passed.
	  `JobSystem` now gives pool workers and `RenderThread` the shared registration path, while
	  `App` registers the existing main thread as `TEMain`. Dedicated owners retain their handles
	  and stop/join order; JobSystem shutdown still joins only its pool workers. **Unblocks
	  S5-T14.** The main/simulation split and Story D proof remain open.
- [x] **S5-T12** · dedicated-thread handles and registration · P1 · 🟢 Deep ·
	  **Merged Sep 8; closed Sep 9**, `5c0764bd` ([#78](https://github.com/techattackteam/TechEngine/pull/78)).
	  Empty PR body, comments and reviews; the build corrections and policy choices happened in session.
	  **Retro:** Jolt exported `_HAS_EXCEPTIONS=0` into core while Catch2 used normal exception
	  types. The failure tests reported “Unknown exception”; enabling Jolt's exception support
	  fixed the mismatch. [[Simulation Thread — Design]] records the startup/result contract.
	  **Build policy changed mid-card:** Miguel removed compiler warnings-as-errors and made
	  clang-tidy advisory after Catch2's unreachable fallback and performance suggestions blocked
	  builds. Warning levels and formatting enforcement remain. ADR-005/008 updates are on [[Backlog]].
	  The three classes now have separate files; enums and result structs stay with `DedicatedThread`.
	  **Unblocks S5-T13.** Pool/render adoption and main registration remain there; Story D stays open.
- [x] **S5-D3** · simulation independence during window moves/resizes · P1 · 🟢 Deep ·
	  **Sep 8**, vault-only design; no engine PR. ADR-018 accepted Sep 7; Miguel accepted
	  the mechanism Sep 8. [[Simulation Thread — Design]] records the completed contract.
	  The proposed double buffer is deferred; the small value mailbox already meets the
	  accepted delivery policy. Overflow explicitly reports lost transitions and resynchronizes
	  held state. D3 closes on design, not on simulation independence already working.
	  Unblocks T12–T17 and re-cut T9. Seven implementation/verification sessions are sized;
	  Miguel authorized rollover instead of fitting them to the remaining sprint calendar.
- [x] **S5-T8** · clear + triangle through the frame command buffer · P1 · 🟢 Deep ·
	  **Sep 7**, `681ddf6b` ([#77](https://github.com/techattackteam/TechEngine/pull/77)).
	  PR body and discussion were empty; review and demo confirmation happened in session.
	  **The first triangle did not prove the command path:** drawing initially ignored the
	  clear colour and draw flag. Review fixed those, an unlocked framebuffer read, a
	  cross-thread GLFW close-flag read, the wrong resize callback and startup failure paths.
	  The final review found no remaining actionable findings.
	  **Retro:** independent rendering does not keep simulation ticking while main is in
	  native event processing. Miguel rejected that limitation for future work; S5-D3 now
	  owns the topology revision. T8 still closes against ADR-015's current contract.
	  Miguel confirmed Tracy and continued drawing during resize on Sep 7. Evidence and
	  the private Buffer/VertexArray seam are recorded in [[Window — Design]].
	  **Completes the Tier 2 triangle proof and unblocks S5-D3.** Story D remains open on
	  D3 and T9; T9 waits for D3's input handoff decision.
- [x] **S5-T7** · `platform::Window` + the context on the render thread · P1 · 🟢 Deep ·
	  **Sep 6**, `a053486c` ([#76](https://github.com/techattackteam/TechEngine/pull/76)).
	  Empty PR body and no review comments; corrections were discussed in session.
	  `ClientSession` was introduced and then folded into `Client`: one owner was enough.
	  Explicit GLFW termination and blocking startup reporting were settled during the card;
	  [[Window — Design]] records the lifetime order and `std::jthread` stop/join contract.
	  **Retro:** a desktop runner did not imply GL 4.5 support. Windows window tests failed,
	  and Debug/ASan stalled in the test step; their exact blocking point was not captured.
	  Pinned Mesa, GLFW diagnostics and timeouts shipped in this PR. Linux also caught two
	  stop-token copies and an empty catch via tidy.
	  FPS/TPS moved into FrameLoop; the editor gained a close-driven loop while runtime kept
	  its 120-frame demo. Ccache refresh and Mesa caching also landed during the CI repair.
	  **Unblocks S5-T8.** The thread currently waits after GL startup; drawing and resize
	  presentation are T8. Story D and the triangle DoD remain open.
- [x] **S5-P4** · xvfb on the Linux legs · P2 · 🟡 Light ·
	  **Sep 6**, `1482e927` ([#75](https://github.com/techattackteam/TechEngine/pull/75)).
	  Empty PR body and no review comments. **Closes Story E.**
	  The original master-run gate missed that workflow-only pushes are filtered too.
	  Miguel instead kept P4 in Review until T7 exercised real windows. The final
	  [T7 CI run](https://github.com/techattackteam/TechEngine/actions/runs/34063333725)
	  confirmed llvmpipe GL 4.5 core and window tests under Xvfb, including Linux TSan.
	  Coverage needed Xvfb around its CMake target because that target invokes CTest internally.
- [x] **S5-T6** · glad2 generated, vendored and wired · P1 · 🟠 Moderate **→ 🟡 Light** ·
	  **Sep 6**, `f71b128d` ([#74](https://github.com/techattackteam/TechEngine/pull/74)).
	  Empty PR body, no review comments or deferred findings.
	  **Sizing correction, Sep 6:** Miguel reports light work: generation and CMake dependency
	  wiring. With the design already settled, the moderate estimate overstated the work.
	  The root project also needed C enabled for `gl.c`; the generator version is pinned at
	  2.0.8 alongside the command. [[Window — Design]] § *glad2: generation and vendoring*
	  records the shipped wiring. S5-T7's stale platform comment was corrected early here.
	  The FetchContent comment ride-along shipped; its resolved [[Backlog]] entry is removed.
	  Closes the loader's Tier 2 DoD line. **S5-P4 is next**; S5-T7 still needs it.
	  Story D remains open.
- [x] **S5-B1** · editor default project root · P1 · 🟡 Light ·
	  **Sep 5**, `4512024d` ([#73](https://github.com/techattackteam/TechEngine/pull/73)).
	  The configure-time option shipped; [[Project — Design]] § *The mount set* records why
	  executable-relative discovery was rejected and why this default belongs only to the editor.
	  No PR body or review comments. CLion launch and explicit-argument checks were not recorded.
	  **Retro:** the bug merged without a recorded capacity displacement call.
	  Closes the follow-up to Story B, already complete at S5-T5. M4 continues at S5-T6.
- [x] **S5-T5** · the two bootstraps + `projects/dev/` testbed · P1 · 🟠 Moderate ·
	  **Sep 4**, `934cf999` (#71). Empty PR body, no review comments; the fifth card reviewed in
	  session. **Closes Story B.**
	  **The runtime clause had no referent when the card shipped.** The clause said
	  `RuntimeApp::init()` mounts a fixed layout. [[Project — Design]] § *Open questions* deferred
	  that to M6 the same morning, because the layout beside the exe is whatever export writes,
	  and nobody rewrote the clause a third time. What merged mounts nothing there. The Tier 1 DoD
	  line stays open on that half and on "relative to the binary": the editor's default root is
	  `projects/dev` **from the working directory**, and the launcher entry on [[Backlog]] owns
	  replacing it.
	  **`Project::load` stopped being static.** The note had a static with an out-param so a
	  failed load could not half-populate. It is a member now and the guarantee survives, because
	  the two writes are the last thing on the success path. § *Load and save* records it.
	  **The three `App.cpp` citations were repointed at this close**, as their entry said: ADR-017
	  § *Context* anchored at `76056402`, the note's reference line now names `App::run()` and
	  `EditorApp::init()`.
	  **Retro line: rewritten three times, the last one silently.** Aug 31 for ADR-017, Sep 4 for
	  the layout, and Sep 4 again by a deferral that reached the design note and not the card.
- [x] **S5-P3** · 🤖 vault `file:line` citation sweep · P3 · 🤖 Auto ·
	  **Sep 4**, vault-only, no PR. Run unattended 2026-09-01 ([[2026-09-01 Auto Run]]), closed
	  attended three days later.
	  **"The 8 known-wrong ones" were 10, and not of a kind.** The run resolved ~120 v2 and ~50
	  v1 sites, corrected 10 across four artifacts, and refused three: two Accepted-ADR snapshots
	  whose claims their own decision made false, and the `App.cpp` trio, which point past the
	  end of a file S5-T5 moves again. Repointing a snapshot leaves a right number under a false
	  sentence, so the fix was a convention. Landed at close: ADR-011 and ADR-015 § *Context* are
	  anchored at the sha they were read at, each under a dated header entry, and the
	  [[ADR Template]] now says a Context citation carries its sha. The `App.cpp` three stay on
	  [[Backlog]], pulled by S5-T5.
	  **The second clause answered "both, split by failure mode."** Exists-and-in-range is a
	  cheap CI check and would have caught 3 of ~14. Points-at-the-right-thing is a read and stays
	  with `/weekly-review`. The CI half is carded `#prio/low`, not built.
	  **Retro line: a card that refuses part of its work had nowhere to go.** It sat in To Do
	  from Sep 1 to Sep 4 while fires reported no takeable card. Decision 7 in
	  [[Autonomous Lane — Design]] came out of this card and S5-P2 together.
	  Story E stays open on S5-P4.
- [x] **S5-P2** · 🤖 [[Known Issues]] D1's fallback fix · P3 · 🤖 Auto ·
	  **Sep 3**, `0ac1a9b0` (#66). No review comments; a silent merge a day after the PR opened.
	  **The lane's first code PR, and the path is proven end to end**: branched from a fresh
	  `origin/master`, built and tested on `linux-debug`, opened under the right `S5-P2/` prefix,
	  never merged by the lane. The inherited clause holds too: the Sep 2 second fire read the PR
	  in the day's note and took report-only work, so the one-PR-per-day cap is observed.
	  **The test clause was met and still does not cover the fix.** D1 asked for a config-table
	  case mirroring `AssertTests.cpp`, and that case pins the library's compiled gate to the
	  TU's. The fallback branch itself is reached by no TU in the tree, because nothing includes
	  `Log.hpp` without linking `base`, which is D1's own trigger condition. The run stopped short
	  of a dedicated `#undef` TU rather than widen an unattended diff. Correct by inspection of
	  six preprocessor lines; [[Backlog]] § *base* carries the gap. [[Logger — Design]] records
	  where the fallback lands RelWithDebInfo.
	  **Found not fixed:** `-DTE_LOG_ACTIVE_LEVEL=3` breaks the Linux build. On [[Backlog]].
	  **Retro line: merged Sep 3, closed Sep 4, and the card sat in To Do in between.** Four
	  fires reported an empty lane while its own finished card looked untaken. That is decision 7
	  in [[Autonomous Lane — Design]]: the lane now moves its card.
	  Closes the Tier 3 DoD line. Story E stays open on S5-P4.
- [x] **S5-T4** · `project.toml` + the `Project` type · P1 · 🟢 Deep ·
	  **Sep 4**, `e0495146` (#70). Empty PR body, no review comments; the review happened in
	  session, the fourth card running.
	  **The toml++ trap cost a debugging round, and a test caught it rather than review.**
	  `TOML_EXCEPTIONS` defaults to 1 whenever the compiler has exceptions, and in that mode
	  `toml::parse_result` is a plain alias for `toml::table` — so the first failure check
	  compiled, could never fire, and `parse()` threw instead. `cmake/deps.cmake` now wraps the
	  dep as `TechEngine::tomlplusplus` carrying `TOML_EXCEPTIONS=0`, so no consumer can pick up
	  the throwing mode by forgetting a define.
	  **`mounts()` was written and deleted before it shipped**, twice over: scaffolded, given a
	  `Role` parameter, then removed once the one-key schema left it deriving from convention for
	  a single caller. [[Project — Design]] § *Why `Project` does not mount* records it, and
	  corrects a wrong reason on the way — the composition-root rule is **legibility**, not
	  thread safety.
	  **`ProjectResult` had no value for a failed write.** Raised at card-start, left unsettled,
	  and it blocked `save` at implementation time. `WriteFailed` added mid-card.
	  **Retro line: the design settled under the card, not before it.** The clause was rewritten
	  twice on the build day, for the three-way `assets/` split and then the one-key schema.
	  S5-D1 exists to prevent that and did not, because the layout question it parked in
	  § *Open questions* turned out to gate the type's whole surface.
	  **Retro line: `.claude/output-styles/techengine.md` rode along** — 93 lines, no clause
	  named it, flagged pre-PR as not belonging, merged anyway.
	  **Unblocks S5-T5**, the last card in Story B. Closes neither the story nor a DoD line.
- [x] **S5-T3** · the five mutating `FileAccess` calls · P1 · 🟢 Deep ·
	  **Sep 3**, `84181fae` (#68). Empty PR body, no review comments; the review happened in
	  session, the third card running.
	  **The clause "all resolving through `resolveForCreate`" was wrong, and writing it is what
	  showed why.** `copy`, `move` and `rename` each name a **source that must already exist**,
	  and `resolveForCreate` takes the top mount and never probes. A source held by a
	  lower-priority mount would have come back `NotFound` for a file the caller can read.
	  Corrected Sep 3 on the card and in [[Project — Design]] § *The five mutating calls*:
	  destinations through `resolveForCreate`, sources through `resolveExisting`. A Catch2 case
	  puts the source in the low mount and the destination in the high one, so the regression
	  cannot come back quietly.
	  **`write` was widened past its clause.** The clause asked for `NotFound` on a **missing
	  parent**. What shipped returns `NotFound` for **any** failed stream open, so a permission
	  error or a locked file now also reads as "no such file". Nothing misbehaves today; the
	  first symptom would be a wrong diagnosis. Raised at close, not during review, so it is
	  a report line rather than a [[Known Issues]] ID.
	  **Two `MountTable.cpp` comments were deleted that no clause asked for**, including the one
	  naming the invariant that `resolveForCreate`'s "first match wins" is correct **only**
	  because `mount()` keeps `m_entries` in descending priority order. That invariant lives in
	  another function, and the comment was its only in-code pointer.
	  **Two of the card's own Catch2 cases were wrong, not the code.** Both put a destination
	  under a parent that did not exist and expected `Ok`. `NotFound` was correct per the design
	  table both times, which is the table doing its job.
	  **Retro line: four bugs in one review pass, three of them inverted conditions** — a
	  `NotEmpty` gate testing whether the *path string* was empty, an `exists` check reading the
	  wrong way, and a `rename` block that could never pass. Same shape as S5-T1's inverted
	  `TE_CHECK` earlier the same evening. Two cards in a row lost time to a condition written
	  as the failure rather than as the invariant.
	  **Unblocks S5-T4 and S5-T5.** Does not close Story B or a Definition of Done line.
- [x] **S5-T1** · `platform::executablePath()` · P1 · 🟠 Moderate **→ 🟡 Light** ·
	  **Sep 3**, `a7908904` (#67). Empty PR body, no review comments; the review happened in
	  session, same as #64.
	  **The clause said "one signature in `platform`" and named no home.** Header, return type
	  and failure tier were all unwritten. Settled at card-start: `Platform.hpp` rather than a
	  `system/` subdir for one function, `const std::filesystem::path&` off a function-local
	  static, and a bare `TE_CHECK` with no recovery path — S5-T2's shape, for the same reason.
	  **Three things changed in review before merge.** Both `TE_CHECK`s were written asserting
	  the *failure* (`length == 0`), which fires on every success; `read_symlink`'s throwing
	  overload made its own check unreachable, so a real failure escaped as an exception past the
	  fatal handler; and only the Linux branch cached, leaving Windows to re-run the syscall per
	  call.
	  **`MAX_PATH` shipped as a fatal rather than a growing buffer**, deliberately and with the
	  trade named. A Windows install path over 260 characters aborts. It is loud, not silent, so
	  it is on [[Backlog]] rather than [[Known Issues]].
	  **Retro line: sized 🟠, came in light**, the first card this sprint to move *down* a column.
	  Two syscalls behind one signature is what the clause always said; the 🟠 came from the
	  cross-platform framing rather than from the work. It buys back one 🟠 in the column the
	  sprint's capacity note calls the plan's failure point.
	  **Unblocks S5-T5.** Does not close Story B or a Definition of Done line.
- [x] **S5-T2** · `MountTable::mount()` validation · P2 · 🟡 Light **→ 🟠 Moderate** ·
	  **Sep 1**, `4e3c6f7f` (#64). Empty PR body, no review comments; the review happened in
	  session. **[[Known Issues]] D2 deleted.**
	  **The `done:` clause named a shape that cannot work.** It asked for `TE_CHECK` "with a
	  defined path, following the `EventRegistry::registerType` shape". That shape writes a
	  recovery path after a **fatal** check, which no sanctioned handler ever reaches. Two
	  versions were written and deleted proving it: an `if (!TE_VERIFY(...)) return;` form, wrong
	  tier for composition-root config, then a bare-`TE_CHECK` form whose cases asserted a
	  post-rejection state production cannot produce.
	  **It produced an ADR amendment the gate did not expect** — the sprint's second gate miss,
	  the same shape as the first. ADR-011 §5 never said whether a fatal check's abort was
	  reachable-past, and the engine had shipped **both** readings. Settled by a dated `decision`
	  amendment on Sep 1.
	  **Ten mis-tiered sites moved `TE_CHECK` → `TE_ENSURE`**, pulled into the card mid-flight:
	  five in `EventRegistry.cpp`, three in `JobSystem.cpp`, one each in `Writer.cpp` and
	  `Writer.hpp`, all carrying graceful degradation after a fatal check. **Not re-tiered:**
	  `EventStream.cpp:13-14` and `JobSystem.cpp:143-145`, which have no recovery path — the
	  latter's continuation runs for every task, throwing or not, so it is normal flow.
	  **`AssertCapture.hpp` moved to `tests/support/`** and gained a second, **throwing** guard,
	  which ADR-011 §5 had already anticipated ("tests scope-swap a throw/flag policy"). It makes
	  the stop observable rather than swallowed.
	  **Report-once bit back.** Two `EventRegistryTests` cases hit one `TE_ENSURE` call site, so
	  the later one's fire count survives only because `catch_discover_tests` gives each case its
	  own process. The count was dropped from that case rather than left to break a direct exe
	  run. On [[Backlog]].
	  **Retro line: a 🟡 became a 🟠 mid-flight**, taking the 🟠 column to six against two.
	  Nothing about the three alias rules was wrong. The sizing missed that writing them would
	  ask a question ADR-011 had left open.
	  **Unblocks S5-T1.** Does not close Story B.
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
	  first. Swept Sep 1 in a PR of its own, `40f7171e` (#65), which also found the `.gitignore` rule for
	  `demo-material.bin` still standing with nothing left to write it.
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
	  is a single-slot **frame command buffer**, newest-complete-wins, with the real list format left to R1 ·
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
