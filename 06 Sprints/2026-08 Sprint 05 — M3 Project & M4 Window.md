# 2026-08 · Sprint 05 — M3 Project & M4 Window

- **Quarter:** [[2026-Q3]]
- **Dates:** **Sat Aug 29 to Fri Sep 11, 2026.** The boundary was pulled **one week early**
  because Sprint 04 met its goal on day 9 and left an empty board
  ([[Dashboard]] § *Rhythm* → an early close moves the boundary). Sat → Fri is intact and the
  next boundary is **Sat Sep 12**. Weekly review on the Sep 5-6 weekend.
- **Epic:** M3 · project **+** M4 · window ([[Roadmap]] → *The chain*) — **two rungs in one
  box**, decided 2026-08-30 with the capacity numbers on the table. See *Capacity note*.
- **Decisions behind it:** [[File Access — Design]] § *The write surface* · § *Who uses it* ·
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
| **Project / M3** — manifest schema · root resolution · the mount set · the five mutating calls | ❌ | ✅ | **Coverage gap, said out loud: no note exists.** [[File Access — Design]] covers the VFS and stops at the project. The decisions are largely settled, since [[Roadmap]] pins the manifest minimal and v1's mount set is documented prior art, so **Story B sizes normally**. → **S5-D1** |
| **Window / M4**: glad2 vendoring · what `platform` owns · the M4-level context handoff · headless CI | ❌, ADR-015 §2 already decided the owner | ✅ | **Second coverage gap.** No ADR is owed: ADR-006 §1, ADR-008 §4 and ADR-015 §2 between them decide module, vendoring and ownership. What is open is **mechanism**, which is a note's job. Heavy, so Story D was held unsized. → **S5-D2**, done 2026-08-30, and it moved ADR-006 §1 by dated amendment |
| `executablePath` · mount validation · the routine · the two Auto cards | ❌ | ❌ | Reversible and local, straight to cards. |

## Stories & tasks

> Every task carries `· P1/P2/P3 · 🟢 Deep / 🟠 Moderate / 🟡 Light / 🤖 Auto`. Weight fits the
> day first, then priority ([[Planning Workflow — Artifact Gate]]).

### Story A — M3's gate *(Design · ordered first; Story B waits on it)*

- [ ] **S5-D1** · project design note via the Design Doc template · P1 · 🟢 Deep — done: a
      `Project — Design` note exists in `docs/04 Design Docs/Systems/` with a filled *Decided*
      table covering the `project.toml` schema (root · name · shader dir · asset dirs, and
      nothing more, per [[Roadmap]] § *M3 — the dev testbed*), the mount set lifted from v1
      (`ProjectManager.cpp:262-271` @ `v1-reference`), and the semantics of all five mutating
      `FileAccess` calls on the `FileResult` convention; it answers
      [[File Access — Design]] § *Open questions* → "should `write` create missing parent
      directories?"; Story B's cards are cut against it.

### Story B — M3 build *(Dev · sized normally: the decisions are settled, only the shape needs writing)*

> Ordering: **T2 → T1 → T3 → T4 → T5.** T2 is first because [[Known Issues]] **D2** names the
> M3 mount port as its trigger and says to fix it *before* that port.

- [ ] **S5-T2** · `MountTable::mount()` validation · P2 · 🟡 Light — done: `mount()` rejects an
      empty alias, one containing `/`, and one containing `:` via `TE_CHECK` with a defined
      path, following the `EventRegistry::registerType` shape; a Catch2 case pins each;
      **[[Known Issues]] D2 is deleted in the same commit.** Optional ride-along: **D3** lives
      in the same file (`MountTable.cpp`), so its per-component spelling check may ride this
      PR. Its fix costs a directory scan per component, so taking it is a deliberate call
      rather than automatic.
- [ ] **S5-T1** · `platform::executablePath()` · P1 · 🟠 Moderate — done: `GetModuleFileNameW`
      on Windows and `/proc/self/exe` on Linux behind one signature in `platform`, with a
      Catch2 case asserting the returned path exists and names the running test binary; no
      `current_path()` fallback anywhere.
- [ ] **S5-T3** · the five mutating `FileAccess` calls · P1 · 🟢 Deep — done: `createDirectory`,
      `remove`, `copy`, `move` and `rename` ship on `FileAccess` over both files and
      directories, all returning `FileResult` and all resolving through
      `MountTable::resolveForCreate`; Catch2 pins each against a scratch directory, including
      the mount-root case (`InvalidPath`), the missing-parent case and the already-exists case;
      green on all legs. Needs S5-D1.
- [ ] **S5-T4** · `project.toml` + the `Project` type · P1 · 🟢 Deep — done: a `Project` type
      loads and validates a `project.toml` through toml++, already pinned in
      `cmake/deps.cmake`, carrying only root · name · shader dir · asset dirs; a malformed or
      missing file returns a defined error rather than throwing; Catch2 pins a good file, a
      malformed one and a missing one. Needs S5-D1.
- [ ] **S5-T5** · the real mount set + `projects/dev/` testbed · P1 · 🟠 Moderate — done:
      `App.cpp` mounts the project's directories relative to `executablePath()` instead of the
      configure-time define; **the `TODO(S3-T13)` demo-mount block is deleted from both
      `App.cpp` and `engine/app/CMakeLists.txt`**; `projects/dev/` exists at repo root as data,
      not a CMake target, with a real `project.toml`, and the runtime loads it by default.
      Needs S5-T1, S5-T4.

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

- [ ] **S5-P1** · watch the routine's first real fires · P2 · 🟡 Light — **re-scoped
      2026-08-30**: the card was written as *create the routine*, and the routine went live at
      18:00 that same day, four fires a weekday (05:07 / 10:07 / 15:07 / 00:07 Lisbon). What is
      left is watching it. done: the first weekday's fires are read and three things confirmed
      against [[Autonomous Lane — Design]] — **one** report note per day with a section
      appended per fire, each fire reading what the earlier ones did rather than redoing it,
      and the **one-PR-per-day** cap holding across four fires (per run it would be ~1300 CI
      minutes a month against a 2000 budget). Anything that misbehaves becomes a `B` card, not
      a note edit. **Ordered before S5-P2**, which is the first fire allowed to open a PR.
      DST edge: cron is UTC, so every fire shifts an hour earlier on 25 October.
- [ ] **S5-P2** · 🤖 [[Known Issues]] **D1's fallback fix** · P3 · 🤖 Auto — done: `Log.hpp`'s
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
- [ ] **S5-P3** · 🤖 vault `file:line` citation sweep · P3 · 🤖 Auto — done: every `path:line`
      citation in the durable artifacts is resolved against the tree and the 8 known-wrong ones
      are corrected (three in `App.cpp`, two in [[Known Issues]], two in [[Profiler — Design]]);
      the report says whether the check is cheap enough to belong in `/weekly-review` or in CI.
      Vault-only, so no PR and no CI cost.

## Definition of Done

**Tier 1 — the commitment. The sprint fails without these.**

- [ ] M3's rung is closed: `projects/dev/` exists as data, the runtime loads it through a real
      `project.toml`, and every mount resolves relative to the binary rather than to a
      configure-time source path.
- [ ] The `TODO(S3-T13)` demo mount is gone from the tree, and [[Known Issues]] D2 is deleted.
- [ ] Both coverage gaps are closed: a `Project — Design` and a `Window — Design` note exist,
      each with a filled *Decided* table, and neither story was cut before its artifact.

**Tier 2 — the reach. Named separately because it is the half at risk.**

- [ ] M4's unlock is demonstrable: a window opens, its GL 4.5 context is current on the render
      thread, and a triangle draws there. The main thread issues no GL call (ADR-015 §2).
- [ ] `external/glad/` holds the generated loader and CI builds it on both legs.

**Tier 3 — process.**

- [ ] The autonomous lane has opened, and Miguel has reviewed, **one** unattended code PR.
      Nothing has yet proven that path.

## Capacity note

**This box is smaller than a normal 2-week box, and that is the price of starting early.**
A 2-week sprint contains two weekends. This one's first weekend, Aug 29-30, was spent on the
Sprint 04 review, its last two merges and this planning session, so **only Sep 5-6 remains**.

| | Normal 2-week box | Sprint 05, as pulled |
|---|---|---|
| 🟢 Deep | 8-10 | **6-7** |
| 🟠 Moderate | 2 | 2 |
| 🟡 Light | 2-4 | 2 |

**Re-counted 2026-08-30 once S5-D2 landed and Story D was cut. Remaining draw:
5 🟢 · 4 🟠 · 3 🟡 · 2 🤖.**

- 🟢 — D1, T3, T4, T7, T8. **5 against 6-7, so 1-2 slots of slack**, better than the plan. S5-D2
  was written on the boundary weekend and cost nothing from this table.
- 🟠 — T1, T5, T6, T9. **Double capacity, unchanged.** Story D's estimate was exact.
- 🟡 — T2, P1, P4. **Over by one.** S5-P4 (xvfb) did not exist at planning; it was cut at S5-D2
  once CI was chosen as the verification route.

**The 🟠 column is the honest overrun**, and it is where Sprint 04 also overran. It fits only
if two 🟠 get absorbed by deep days, as Sprints 03 and 04 both did, and nothing goes wrong,
and no bug arrives mid-sprint. That is a hope rather than a plan, so the cut order below is
the actual mitigation.

**What sizing Story D changed:** the deep column got easier and the moderate column did not.
The riskiest unknowns are now priced rather than guessed, and the one genuinely unverified
thing left is whether CI's llvmpipe reaches GL 4.5 (S5-P4 carries its own fallback).

**Cut order if capacity tightens:**

1. **S5-T9** (raw input). Named first inside Story D and buys back a whole 🟠. M4's proof is the
   triangle on the render thread, and input is not part of it.
2. **S5-P1** and the two 🤖 cards with it. Buys back 1 🟡 and about 30 minutes of PR review.
3. **S5-T5's testbed half.** Keep the mount set, defer `projects/dev/`'s contents.
4. **All of Story D**, meaning T6 → P4 → T7 → T8 together. This is the Tier 2 drop and it is
   the Sep 5-6 checkpoint's decision, not an in-the-moment one. Cutting the story cuts S5-P4
   with it, since nothing else needs xvfb.
5. **Never** S5-D1 or M3's T3/T4. S5-D2 is already banked, so the sprint's durable design
   output survives even if no M4 code ships.

**Said out loud: 3 of 11 sized cards are Process (27%), and 2 of those 3 cost no day capacity**
because they run in the 🤖 lane. That is the lane doing exactly what it was cut for
([[Autonomous Lane — Design]] § *Why*).

**Checkpoint at the Sep 5-6 weekly review:** if Story B is not complete by then, **cut Story D
to S5-D2 alone** and let M4's build be Sprint 06's. Compressing it instead is how the 🟠 column
becomes another four-PR Friday. This checkpoint is a pre-named decision, not a suggestion.

Weekend days stay a swappable pair; nothing here is assigned to Sat or Sun.

## Sprint review (fill Sep 12-13)

- What shipped:
- Demo / artifact:

→ Retrospective in [[07 Journal]].
