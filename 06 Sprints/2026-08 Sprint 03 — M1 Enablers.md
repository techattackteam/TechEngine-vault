# 2026-08 · Sprint 03 — M1 Enablers

- **Quarter:** [[2026-Q3]]
- **Dates:** **Sat Aug 1 – Fri Aug 28 2026** (4 weeks, Sat→Fri — the **first clean cycle**;
  Sprint 02 closed 4 weeks early, see its note). Review + plan on the **Aug 29–30** weekend,
  which is day 1 of Sprint 04.
- **Epic:** M1 · enablers ([[Roadmap]] → *The chain*)
- **Decisions behind it:** [[ADR-006 — v2 core architecture & module layout]] §1 §4 §5 §6 ·
  [[ADR-005 — v2 tech stack & toolchain]] · [[v1 Code Audit]] F28 · F30 · F19

## 🎯 Sprint goal

> **M1's two gates decided, and the vocabulary every later module is written against, built.**
> The Profiler and Events ADRs land; math ships; file access gets its note. **Decide first,
> then build** — the sprint is deliberately artifact-heavy at the front.

M0 is done. M1 is the rung whose contents are *written against* by everything above it, and
two of its items ([[Profiler — Design|Profiler]], Events) are named [[Roadmap]] **gates** — the
Profiler one also gates **M2's threading ADR**, so closing it here is what keeps the next rung
plannable at the Aug 29–30 boundary.

### Scope calls locked at planning (2026-08-02)

| Question | Call | Why |
|---|---|---|
| How much of M1 | **Gates + leaf enablers** | Profiler ADR · Events ADR · `IFileSystem` note · math. Both gates close, so M1 closes on the [[Roadmap]]'s own definition (*gate Accepted + unlock demonstrable*) even with items carrying |
| Deterministic RNG · crash handler | **Out** — Sprint 04 | Narrow, and neither has an M1 consumer. The crash handler also wants `platform`, which does not exist |
| Memory tracking | **Out — it is S3-D1's consequence** | [[Profiler — Design]] § Direction routes it *through* the profiler, so it is downstream of that ADR, not a parallel item |
| `StringId` | **Folded into S3-D2** | The Events ADR names the event-id type, which is what pins `StringId`'s shape. Building it first is sizing past an open decision — the S2-T2 mistake |
| cvars + dev console | **Moved to the T1 editor lane** | Recorded on [[Roadmap]] § *Why this shape*; it was silently dropped from M1's contents in a table reflow |

## 🚦 Artifact gate

| Item | ADR? | Design note? | Outcome |
|---|---|---|---|
| **Profiler** (hooks + memory tracking) | ✅ | ✅ exists | Cross-module (zones land in every system) and hard to reverse — a version-pinned wire protocol and a socket that must not ship. **Heavy → S3-D1, ordered first.** [[Profiler — Design]] stays the living *how*; its interim *Direction* table collapses to §refs when the ADR lands |
| **Events** (F28) + **`StringId`** | ✅ | ADR decides if one is owed | [[Roadmap]] names "Events redesign" as an M1 gate. Blast radius = every publisher/subscriber, plus [[Game Loop — Frame Flow]]'s open *dispatch point*. **Heavy → S3-D2** |
| **`IFileSystem`** (F30) | ❌ | ✅ **owed** | ADR-006 §4/§5 already decided the seam and its injection; what is open — mount/virtual-path scheme, sync vs async, error model — is one module's shape, not a cross-module decision. **Not light** (needs v1 prior art + how M3/M6 consume it) → **S3-D3, a task** |
| **math** | ❌ | ✅ | Library (ADR-005) and placement (ADR-006 §5) already decided; the rest is naming and surface. **Light → drafted in this session:** [[Math — Design]] |
| **Diagnostics init in `app`** | ❌ | ❌ | A bug, not a decision. Straight to a card |
| **ADR amendment policy** | ❌ | ❌ | Process/meta — it edits [[ADR Index]]'s own rules. Straight to task |
| **Skill `te-review`** | ❌ | ❌ | Tooling. Straight to task |

> **Coverage finding, said out loud** ([[Planning Workflow — Artifact Gate]] § *Coverage check*):
> M1 has **seven** items and **one** design note. This sprint closes that for the four items it
> takes; RNG and the crash handler carry into Sprint 04 **still artifact-less**, and that is the
> first thing to fix when they are pulled — not after.

## Stories & tasks

> Each task: `· P1/P2/P3 · 🟢 Deep / 🟠 Moderate / 🟡 Light`. Pick **weight-fits-day first**,
> then priority ([[Planning Workflow — Artifact Gate]]).

### Story A — M1's gates *(Design — ordered first; Stories D/E/F wait on these)*

- [x] **S3-D1** — Profiler ADR via `/adr` · **P1** · 🟢 Deep — **done 2026-08-02**
      ([[ADR-013 — Profiler (Tracy-backed instrumentation)]]) — done: ADR **Accepted** in
      [[ADR Index]], freezing the thin-`base`-façade → Tracy direction; [[Profiler — Design]]'s
      **five open questions closed** (in-proc vs separate process · Tracy version pin · socket
      off in shipping builds · clock resolution · overhead budget); its interim *Direction*
      table collapses to §refs; its ***Trigger* section rewritten** to M1 — the [[Roadmap]]
      already flags that section as stale, so leaving it is shipping a note that argues against
      its own sprint. Also settles whether **memory tracking** rides the profiler.
      **Cuts Story D's cards. Gates M2's threading ADR.**
- [x] **S3-D2** — Events + `StringId` ADR via `/adr` · **P1** · 🟢 Deep — **done 2026-08-02**
      ([[ADR-014 — Events (buffered streams) & StringId]]) — done: ADR **Accepted** — buffered
      per-type streams, **no subscriptions/callbacks** (F28 made inexpressible, not fixed);
      visibility flips at phase barriers (closes [[Game Loop — Frame Flow]]'s *event dispatch
      point* into its *Decided*); `EventTypeId` over **`StringId`** (FNV-1a/64, frozen,
      macro-free); **no Pool** — [[Backlog]] trigger re-armed toward script storage; two
      partial supersessions rowed in [[ADR Index]] (ADR-006 §4's `EventBus&` field ·
      ADR-007 §6's "service" phrase); [[Events — Design]] + [[StringId — Design]] created
      **active**, mechanism pinned pre-cut. **Story E cut into S3-T7…T10.**
- [x] **S3-D3** — file-access design note · **P2** · 🟠 Moderate — **done 2026-08-02**
      ([[File Access — Design]]) — done: note in `04 Design Docs/**Utilities**/` — the
      card said `Systems/`, which was wrong for the same reason the *type* was: it is a
      helper **service** (ADR-006 §5), and the README puts those in `Utilities/`.
      **`IFileSystem` → `IFileAccess`** — v1's was `FileSystem : public System` (F16) and
      "System" is a reserved word in this vocabulary; recorded as a dated vocabulary
      amendment on ADR-006's header, the same mechanism §5 already used on 2026-07-24, with
      **no body edit**. Decided: **`platform`** (not "platform/core" — §1's own contents
      table lists *file I/O* there) · v1's `alias://` + priority mount scheme kept ·
      `FileResult` status enum over v1's bare `bool` · **sync-only, no async seam** (M2's
      ADR is unwritten) · surface **split** read / mutating, with the **write side left
      unbuilt — no consumer at M1** · `mount()` moved off the interface onto a
      composition-root `MountTable`, which is what makes the read path lock-free.
      **Story F cut into S3-T11…T13.**

### Story B — math *(sized: [[Math — Design]] drafted this session)*

- [x] **S3-T1** — `Math.hpp` alias set · **P1** · 🟠 Moderate — **done 2026-08-02**
      (engine `05cf3718`, PR #21) — done: `engine/base/include/TechEngine/base/Math.hpp` carries
      the [[Math — Design]] alias set in namespace `TechEngine`; `glm::glm` was **already**
      PUBLIC on `te_base` (`LIBS`, not `LIBS_PRIVATE` — ADR-011 §1), so the condition held with
      **no CMake change**; **no `GLM_FORCE_*`** — the renderer-ADR deferral is recorded in the
      note *only*, since the header carries no marker; `MathTests.cpp` added beyond the card —
      `static_assert`s, no `TEST_CASE`, because **nothing includes `Math.hpp` yet** and an
      uncompiled header would sit green in CI until S3-T2.
- [x] **S3-T2** — `math/Format.hpp` + tests · **P2** · 🟡 Light — **done 2026-08-03**
      (engine `5afb6d28`, PR #23). Shipped **three partial specializations over glm's own
      templates** (`glm::vec` · `glm::mat` · `glm::qua`) rather than one per alias, so
      `IVec`/`UVec`/`Mat3` came free; renders glm's spelling (`vec3(1, 2.5, 3)`) with the
      format spec **forwarded to the elements** (`{0:.2f}` → `vec3(1.00, …)`); quaternions
      print **xyzw**, the one divergence from `glm::to_string`. Separate header held
      (ADR-006 §6). Two things the card didn't foresee:
      **(1)** a latent **Jolt `/MTd` vs our `/MDd` CRT mismatch** surfaced the moment
      `<format>` pulled a Jolt object into the link — pre-existing since Jolt was added,
      invisible until something referenced it. Fixed in `cmake/deps.cmake` by forcing
      `USE_STATIC_MSVC_RUNTIME_LIBRARY OFF`.
      **(2)** two `Format.hpp` files in `base` triggered a **layout decision**: one folder per
      utility, named after its design note (`diagnostics/` · `math/` · `time/`), `src/` and
      `tests/` mirroring it, and `base/Format.hpp` renamed **`diagnostics/FormatString.hpp`**
      to match its primary type. Rule recorded in `CONVENTIONS.md` → *Headers*.

**Story B complete.**

### Story C — Sprint 02 loose ends

- [ ] **S3-B1** — diagnostics init belongs in `app`, not the exe · **P1** · 🟠 Moderate —
      carried from S2-T2's parked list, reclassified `S2-B1` on Jul 31 and **never reached the
      board** (retro → *Process improvements*). done: `initLogging()`, channel/module
      registration and the assert-handler install move into the **`app` composition root**
      (ADR-011 §2 §8), so `apps/runtime` and `apps/editor` stop each owning a copy;
      S2-T3's residual — `initLogging`/`spdlogSink` uncovered by ctest — is either **closed or
      explicitly re-parked with the reason**, not left silent.

### Story D — Profiler hooks *(sized 2026-08-02, off [[ADR-013 — Profiler (Tracy-backed instrumentation)]])*

> Ordering: **T3 → T4 → {T5, T6}**. Gate said **neither** on all four — the ADR is Accepted
> and [[Profiler — Design]] is the hub. Dep allocator hooks (Jolt · miniaudio · GLFW) have
> **no consumer yet** and went to [[Backlog]], not a card.

- [x] **S3-T3** — Tracy dep + `TE_PROFILE` option + profile presets · **P1** · 🟢 Deep —
      **done 2026-08-03** (engine `7610b931`, PR #24) — done: option-guarded Tracy `v0.13.1`
      (`cmake/deps.cmake:91`), `option(TE_PROFILE … OFF)` (`CMakeLists.txt:16`),
      `Tracy::TracyClient` **PUBLIC** + `TE_PROFILE_ENABLED` via follow-up calls
      (`engine/base/CMakeLists.txt:32`), `windows-profile` / `linux-profile` presets, all four
      ADR-013 §4 Tracy options ON. `windows-profile` **311/311 + ctest 73/73**; the default
      preset fetches no Tracy at all.
      **The card's three stacked risks were all non-risks, and two were answerable by reading
      Tracy's own `CMakeLists.txt` before compiling anything:** Tracy already declares its
      include dir `SYSTEM`, so the manual re-export the card specced is absent and the
      CMake-3.25 blocker never applies; CMake emits `-external:W0` beside `-external:I`, so
      `/W4 /WX` needed **no `te_warnings` exemption**; and no OS-header breakage appeared in
      any of the 311 targets, discharging ADR-013 § Context's "five headers checked" — **on
      MSVC only** ([[Profiler — Design]] § *Open questions*).
      Two card claims corrected: CI's `_deps` key **is** invalidated (it hashes `deps.cmake`,
      so the next run re-clones every dep, once), and the presets built on **one** leg —
      `linux-profile` is unverified and CI does not build it ([[B3 — Build & Testing Notes]]
      § *Profiling builds*).
- [x] **S3-T4** — `base/profiler/Profile.hpp` + frame mark · **P1** · 🟠 Moderate —
      **done 2026-08-03** (engine `87ed6dd0` PR #25, then `dd866aa7` PR #26) — done:
      `TE_PROFILER_SCOPE/FUNCTION/FRAME` per [[Profiler — Design]] § *Surface*, OFF-path
      expansion `((void)0)` and **no third-party include**; `TE_PROFILER_FRAME()` last in
      `App.cpp`'s loop body (after the pacer, so the mark closes a whole frame),
      `TE_PROFILER_FUNCTION()` opening `FrameLoop::advance`, `TE_PROFILER_SCOPE("FixedSteps")`
      around the accumulator loop. **The sprint's demo is shipped**: a `windows-profile`
      capture against the pinned Tracy `0.13.1` desktop build shows `advance` → `FixedSteps`
      nested under each frame mark. Four things the card didn't foresee:
      **(1) the header moved** to `base/profiler/` — CONVENTIONS' folder-per-utility rule
      (S3-T2, Aug 3) postdates ADR-013 §2's `base/Profile.hpp` and wins; the same refinement
      precedent as `dt` → `deltaTime`, recorded in [[Profiler — Design]] with **no ADR edit**.
      **(2) "no Tracy symbol when OFF" is a build-graph fact**, not a binary hunt —
      `TE_PROFILE=OFF` never runs the `FetchContent`, so `Tracy::TracyClient` does not exist
      to link. Stated that way rather than implying a `dumpbin` run happened.
      **(3) The zone macros collide in one scope** — both declare a fixed-name RAII object,
      so `FixedSteps` needs its own nested block. It only breaks under the profile presets,
      which **CI never compiles**, so it is a `GOTCHA` comment in the header.
      **(4) Two PRs.** #25 merged an exercise — a throwaway `testFunction` with a
      `sleep_for(30ms)`, a 1000-zone inner loop (ADR-013 §6's named anti-pattern), two zones
      placed where they measured nothing, and a declaration leaked into `app`'s **public**
      header. #26 replaced it with the carded call sites. **Retro line: "it works" and "it is
      the card" are different reviews, and the exercise passed the first.**
- [x] **S3-T5** — memory tracking: global `operator new`/`delete` replacement · **P2** ·
      🟠 Moderate — **done 2026-08-07** (engine `dc790d7d`, PR #34). Shipped
      `TE_PROFILER_ALLOC/FREE` plus **all 20 replaceable forms** — throwing · nothrow · array ·
      aligned · sized — in `engine/app/src/diagnostics/MemoryTracking.cpp`: `new_handler` loop
      honoured, null-guarded frees, aligned traffic split onto `_aligned_malloc`/`_aligned_free`
      on MSVC. **Demo shipped** — a `windows-profile` capture carries a live Memory-usage plot
      and the session survives to frame 120, so the asymmetric-delete hazard did not fire; the
      link is clean, with **no LNK2005** against `msvcprt.lib`'s own `operator new`. Four things
      the card didn't foresee:
      **(1) The pull-in needs a symbol, not a rule.** `app` is a static lib too, so a TU holding
      only definitions is never pulled into the exe. `memoryTrackingAnchor()` — a no-op called
      from `run()` — is what forces it. ADR-013 §7 named the hazard and left the fix open.
      **(2) Tracy's *secure* variants**, not §7's `TracyAlloc`/`TracyFree`. `TracySecureAlloc`/
      `TracySecureFree` pass `secure = true`, which gates the record on `ProfilerAvailable()`;
      a global `operator new` fires during CRT static init and can precede Tracy's own
      construction. Mechanism, so [[Profiler — Design]] absorbs it and the ADR is unedited.
      **(3) The sanitizer collision is S3-T9's, one module over.** An allocator-interposing TU
      cannot coexist with ASan/TSan, which replace the same functions. ADR-013 §4 keeps the
      sanitizer *legs* `TE_PROFILE=OFF`, but that is CI policy, not a mechanical block —
      `techengine_test` links `TechEngine::app`, so `windows-asan -DTE_PROFILE=ON` was one flag
      from a red link. The TU now **detects the sanitizer itself** (`__has_feature` /
      `__SANITIZE_*`) and compiles the replacements out, which survives any preset combination.
      Cost: a **silently absent memory plot** under a sanitizer, named because the build won't.
      **(4) It carries a conventions change.** `Profile.hpp` moved `base/profiler/` →
      **`base/diagnostics/`**, and `CONVENTIONS.md` → *Headers* relaxed from one folder per
      **design note** to one per **subject area** — the profiler is instrumentation, which is
      what a reader opening `diagnostics/` is already looking for. This reverses S3-T4's folder
      call **deliberately**; that write-up and [[Sprint Board]]'s are dated history and stay,
      [[Profiler — Design]] carries the current path, and S3-T6's grep directory moves with it.
      **Residual, accepted.** The plot's witness was a deliberate 12-byte `new` in the loop, so
      the capture proves *the pipe works* — not that the Logger's own allocations are covered,
      which is what the card's condition asked for. That throwaway did **not** merge (PR #25's
      lesson, applied). `linux-profile` still has never been built.
- [ ] **S3-T6** — overhead number + coverage statement · **P2** · 🟡 Light — done:
      `windows-release` built twice, `TE_PROFILE` ON vs OFF, headless loop timed, delta
      recorded in [[B3 — Build & Testing Notes]] against ADR-013 §6's **< 5%** bar; a miss
      gets its **cause named** (zone placement vs Tracy) before anything is changed.
      **Check what the loop is doing before trusting the number** — S3-T4's first capture ran
      **~54 ms/frame** (115 frames / 6.2 s) against a 16.6 ms pacer. That was a deliberate
      `sleep_for(30ms)` in the throwaway `testFunction`, since deleted — **not** a real cost,
      and not the per-frame `TE_LOGGER_INFO` it was first read as. The rule outlives its wrong
      first diagnosis: a 5% delta taken on an inflated loop measures the inflation, so record
      what the loop was doing alongside the number.
      **The automated coverage is a grep, not a test** *(folded in 2026-08-03)* — one `check`
      line in `.github/workflows/ci.yml:61` banning
      `ZoneScoped|ZoneTransient|FrameMark|Tracy(Secure)?(Alloc|Free)|tracy/` outside
      `engine/base/include/TechEngine/base/diagnostics/`, which makes ADR-013 §2 (every call site
      spells **our** name, so swapping Tracy stays a one-header edit) and §6 (no transient
      zones — F19's exact failure mode) structural instead of review-only. The Catch2
      side-effect-free case stays, with its value stated honestly: `App.cpp` / `FrameLoop.cpp`
      already compile the OFF path on all four legs, so it guards only against the macros
      evaluating their argument.
      **Stated out loud** in [[Profiler — Design]] — the ON path is demo-verified, *not*
      unit-tested, and **CI never compiles `TE_PROFILE=ON` at all**. The antidote (one profile
      leg on ADR-008 §9's nightly schedule) stays **deferred** per ADR-013 § *Consequences*,
      with its trigger named on the card: a profile build found broken by someone trying to
      use it, rather than by CI.

> **Riskiest card is S3-T3, and it is not close.** Three unknowns stack: (a) `te_warnings`'
> `/W4 /WX` applies to *our* compiland, so a warning inside Tracy's header — included by
> `base/Profile.hpp` — is our error, which ADR-008 §5 does not cover because it guards the
> other direction; (b) the fix is version-blocked — `FetchContent_Declare(... SYSTEM)` is
> **CMake 3.25**, we require **3.21**, so it needs the manual re-export `miniaudio` already
> uses (`cmake/deps.cmake:85`); (c) the open OS-header question. **De-risk in T3's first
> hour:** configure `TE_PROFILE=ON`, `#include <tracy/Tracy.hpp>` into one existing `base`
> `.cpp`, build Windows only. All three answered before the real plumbing is written — and if
> it goes badly, **re-scope T3 rather than push through**.
>
> **Resolved 2026-08-03 — all three were non-risks, and the sizing was wrong in a way worth a
> retro line.** (a) and (b) were both answerable by **reading Tracy's own `CMakeLists.txt` at
> the pinned tag** — it already declares its includes `SYSTEM`, and CMake supplies
> `-external:W0` — so the spike confirmed rather than discovered. The card had specced a
> workaround for a problem that did not exist, because the risk was assessed against ADR-013's
> reading of Tracy's *client headers* and never against its *build files*. Cheap lesson:
> **when a dep's risk is a build-integration risk, read its build, not its source.** No
> re-scope, no deep day burned.

> **Budget check.** D draws **1 🟢 · 2 🟠 · 1 🟡** against D+E+F's reserved ~7 🟢 · 2 🟠 ·
> 3 🟡. Deep days — the scarce, protected resource — come in at 1 against ~3, so this is
> **ahead**. But D takes **both** moderate slots and Story F will want them too.
> **Re-check the 🟠 column after S3-D2**, when two of three stories are sized. Not a problem
> yet; a signal that the reserve was guessed before any of the three ADRs existed.
>
> **Re-checked 2026-08-02 (S3-D2 done):** Story E cut at **0 🟠 · 2 🟢 · 2 🟡** — the 🟠
> column stays **5 planned vs 4 Fridays** (D3 · T1 · B1 · T4 · T5), unresolved and now
> **Story F's problem**: the D/E/F reserve has **0 🟠 and 0 🟡 left** for F as-is (🟡 has
> Wed-opt-in headroom; 🟠 does not). Deep is fine — D+E draw 3 of ~7. Honest options at
> S3-D3's sizing: one 🟠 rides a Wed opt-in, or one slips to Sprint 04. **Pre-named for the
> Aug 15–16 review.**

### Story E — Events + `StringId` *(sized 2026-08-02, off [[ADR-014 — Events (buffered streams) & StringId]])*

> Ordering: **T7 → T8 → T9 → T10**, a strict chain, independent of Stories D/F. Gate said
> **neither** on all four — ADR-014 is Accepted and [[Events — Design]] / [[StringId — Design]]
> carry the pinned mechanism. **M5 hand-off, named not carded:** streams move onto `Scene`,
> cursors onto schedule entries, event access into `SystemAccess` when those exist
> (task-graph ADR) — at M1 the streams container is owned by the headless driver and cursors
> are free-standing objects. **E draws 0 🟠 · 2 🟢 · 2 🟡** — see the budget note.

- [x] **S3-T7** — `base/StringId.hpp` + tests · **P1** · 🟡 Light — **done 2026-08-04**
      (engine `7e4564db`, PR #27) — full write-up on [[Sprint Board]]'s Done column. Three
      calls landed against the note as first written: header in **`base/stringid/`**, the
      value **private behind `value()`**, and the formatter takes **no spec**. done:
      `struct StringId { u64 value; }` with a `constexpr explicit` ctor from `string_view`
      (FNV-1a/64, case-sensitive — ADR-014 §1); defaulted `==`/`<=>`; `std::hash` = identity;
      `StringId{}` = 0 invalid sentinel; **no macro, no UDL, no table** ([[StringId — Design]]
      § *Design*); `std::formatter` prints hex, placement per the Math split; Catch2 pins the
      known vectors (`""` → `0xcbf29ce484222325`, `"a"` → `0xaf63dc4c8601ec8c`),
      `static_assert`s constexpr evaluation, case-sensitivity, sentinel.
- [x] **S3-T8** — event registry in `core` · **P1** · 🟡 Light — **done 2026-08-07**
      (engine `6e881d5e`, PR #31 — **one commit carries T8 and T9**). Shipped
      `EventRegistry` + `EventTypeRecord` {id, tag, `streamIndex`, size, alignment,
      `EventWire`} with `registerEvent<T>(tag, wire)` and a `static_assert` on
      trivially-copyable. Two things the card didn't foresee:
      **(1) `EventTypeId` is its own type**, a `constexpr` wrapper over `StringId` with the
      value private behind `value()` — the S3-T7 privacy call applied one level up, which is
      what stops an event id and a raw tag hash being interchangeable.
      **(2) The T → id mapping is process-global** — `detail::g_eventTypeSlot<T>`, an inline
      template variable, written by `registerEvent` and read by `publish`/`read`. Registries
      are therefore **not isolated**: a second `EventRegistry` overwrites the first's slots,
      and the tests exploit this (a throwaway registry, discarded, still leaves `publish`
      working). Fine for a single composition root; **name it in [[Events — Design]]** before
      anything grows a second registry. done:
      `registerEvent<T>("Tag.Name")`-shaped call, invoked from the composition root **only**
      (no file-scope statics — ADR-014 §6), recording {`EventTypeId`, dense stream index,
      size/align, reserved wire flag} and rejecting non-trivially-copyable payloads at compile
      time (ADR-014 §2); registry **keeps the tag string** → always-on collision `TE_CHECK`
      (incl. a tag hashing to 0) + tooling-only id→tag lookup ([[StringId — Design]] § *Reverse
      lookup*); Catch2: collision fires, lookup resolves. Needs S3-T7.
- [x] **S3-T9** — `EventStream` core mechanics + tests · **P1** · 🟢 Deep — **done 2026-08-07**
      (engine `6e881d5e`, PR #31 — same commit as T8). Shipped the absolute-`u64` ring with
      three positions, `publish<T>` staging by value, batch marks, the AND-shaped retire, and
      cursor reads that clamp to the head; retire-rule cases written first, 9 `TEST_CASE`s.
      Three deviations from the card, none of them silent:
      **(1) the barrier method is `makeVisible`, not the note's `flip`** — [[Events — Design]]
      needs the rename or the code does; S3-T10 is where that gets settled.
      **(2) The zero-steady-state-alloc test outgrew its mechanism.** It counted allocations
      by replacing global `operator new`/`delete` in the test exe, which **collides with
      TSan's own replacements** in `libclang_rt.tsan_cxx` and broke the `linux-tsan` link — an
      allocator-interposing test cannot coexist with a sanitizer that interposes the allocator.
      Removed under a red CI, then **re-expressed the same day without touching the allocator**:
      `grow()` always doubles, so `capacity() == 64` after a publish/flip/read/retire loop is an
      exact witness that the ring never reallocated. **Residual, accepted:** `m_marks` is
      `reserve(64)`'d and holds ≤1 mark in that loop, so it cannot allocate either — but nothing
      observable asserts it.
      **(3) A throwaway publish/read demo landed in `App.cpp`** under `TODO(S3-T10)`. Carded
      work, not an exercise this time — but PR #25's lesson says the removal is T10's job to
      actually do. done: ring with
      absolute `u64` sequences and three positions (retire head · visible end · staging tail);
      `publish<T>` stages by value; `flip(frame, tick)` records marks; `retire(frame, tick)`
      drops batches only after a frame boundary **and** a fixed tick have both passed
      (ADR-014 §3 → [[Events — Design]] § *Retire*); cursor reads clamp to the head,
      exactly-once while retained; **steady-state publish/read allocates nothing** (counting
      `operator new` in the test exe); Catch2 scripts barrier sequences — ×N catch-up frames,
      back-to-back 0-tick frames (events must survive to the next tick), lagging cursor,
      ring wraparound. **Write the retire-rule cases first — the story's spike, in place.**
      Needs S3-T8.
- [ ] **S3-T10** — loop wiring + headless demo · **P1** · 🟢 Deep — done: `FrameLoop::advance`
      flips at the end of every fixed sub-step and once at the frame tail, retires at frame
      start ([[Events — Design]] § *Flip* / *Retire*); `TE_PROFILER_SCOPE` literal-name zones
      on flip + retire (expand to nothing until Story D lands — **no ordering dep on D**); the
      headless driver (`engine/app/src/App.cpp`) publishes in a fixed step and a frame-tail
      read consumes it **exactly once** at the next barrier — the first event across a
      deterministic barrier; the streams container stays driver-owned, named as the M5 `Scene`
      hand-off. Needs S3-T9.
### Story F — File access *(sized 2026-08-02, off [[File Access — Design]])*

> Ordering: **T11 → T12 → T13**, a strict chain, independent of Stories D/E. Gate said
> **no ADR** — the note is the hub and ADR-006 §1/§4/§5 already carry the seam.
> **The write side is not carded — it belongs to M3, one rung out.** `IFileWriteAccess`'s
> consumer is M3's project creation (`project.toml` + asset dirs), which opens in Sprint 04
> alongside M2, so it is on the [[Roadmap]] as an **M3 content**, not in [[Backlog]]. Held
> back so its surface is shaped by M3's actual writes instead of guessed a sprint early.
> **F draws 0 🟢 · 1 🟠 · 2 🟡** — the 🟠 squeeze the D/E budget notes pre-named resolves;
> see below.

- [ ] **S3-T11** — `MountTable` + virtual-path resolution + tests · **P1** · 🟡 Light —
      done: `engine/platform/…/MountTable.hpp` holds {alias, physical root, `int` priority},
      sorted highest-first; `mount`/`unmount` **only here**, never on an interface
      ([[File Access — Design]] § *Design*); splits `alias://rel` and exposes the two
      resolution policies — read (probe candidates in priority order, first **existing**
      wins) vs write (highest-priority mount, **no** existence probe); Catch2 pins priority
      order, unknown alias → `NoMount` vs known-alias-no-file → `NotFound`, and a
      **wrong-case path returns `NotFound`** — the case rule is the one that behaves
      differently on the two CI legs if it is ever folded.
- [ ] **S3-T12** — `IFileAccess` + `FileAccess` + tests · **P1** · 🟠 Moderate — done:
      interface and impl **both in `platform`** (ADR-006 §1 — this is F30's actual fix, so
      `runtime` gets an implementation without linking the editor); `read`/`status`/`list`/
      `resolve` per the note's *Surface*, every one returning `FileResult` with data via
      out-param, **no exceptions and no logging on a miss** (v1 logged an error when a
      caller probed for an optional file); reads into `std::vector<std::byte>` and
      **nothing more** — serialization moved to M2 (Sprint 04), so its `Buffer` is one rung
      out and a bridging abstraction here would be dead on arrival; **no lock** — say out
      loud in the note if that stops being true. Needs S3-T11.
- [ ] **S3-T13** — wiring + runtime proof · **P2** · 🟡 Light — done: composition root
      owns `MountTable` + `FileAccess` **by value**, `EngineContext` carries
      `IFileAccess& files` (ADR-006 §4, per its 2026-08-02 amendment); a mount is
      established and a headless `runtime` **reads a file through the virtual path** —
      that run is F30's regression test, since v1 could not do it at all;
      `TechEngineSDKSmoke` still compiles (no `platform` type leaking into the SDK).
      Needs S3-T12.

#### How D / E / F get planned

**Mid-sprint, into this note — not at the Aug 29–30 boundary.** This note is deliberately
incomplete on Aug 2 and gets filled in twice more.

1. **The ADR lands** — `/adr` on a deep day, Accepted in [[ADR Index]].
2. **Same session, before the Design card is ticked** — decompose the story it unblocks with
   `/feature-breakdown` ([[Planning Workflow — Artifact Gate]] § *Which command when*: a story
   too big to decompose in the ceremony gets a dedicated pass).
3. **Write the cards in both places** — under Story D/E/F here **with done-conditions**, and
   onto [[Sprint Board]]'s To Do column with their `· P1 · 🟢 Deep` tags. The board's ⏳
   placeholder line for these stories goes when the last of the three is sized.
4. **They must fit the reserved budget** — ~7 🟢 · 2 🟠 · 3 🟡 across D+E+F **combined**
   (capacity note). If an ADR's shape means Story D wants six deep cards instead of three, that
   is a **scope conversation**, not silent expansion into the 2 protected deep slots.

**Checkpoint — the risk this creates.** If **S3-D1 and S3-D2 have not landed by ~Aug 14**
(end of week 2), the stories they gate have under two weeks of runway and this sprint quietly
becomes an artifacts-only sprint. That is the question the **Aug 15–16 weekly review** exists
to ask; the honest answer at that point is to cut a story, not to compress it.

### Story G — Process *(first thing cut when capacity tightens)*

- [ ] **S3-P1** — ADR amendment policy · **P2** · 🟡 Light — [[ADR Index]] says an Accepted ADR
      is immutable and changes need a superseding record; **ADR-011 has been amended in place twice** (the ENSURE guard, and rotation → truncate-on-open in `ef50f44`). One of the two
      is wrong. done: § *Statuses* states whether in-place amendment is allowed, by what
      **mechanism** (the dated `**Amended:**` header entry ADR-011 already uses) and what is
      **off-limits** (reversing a *Decision* — that still needs a superseding ADR); ADR-011's
      two amendments either conform or are converted; the `/adr` skill matches.
- [ ] **S3-P2** — Skill `te-review` · **P3** · 🟡 Light — [[Backlog]] trigger fired
      (`CONVENTIONS.md` landed Jul 30). done: a review rubric over `CONVENTIONS.md` + the ADR
      structural invariants (module DAG · no third-party type in a public header · the SDK acid
      test · no `[[nodiscard]]` · internal linkage is `static`); **dry-run on a Sprint-02 file
      finds something real, or the rubric is trimmed until it does** — a rubric that only ever
      says "looks fine" is worse than none.

## Definition of Done

- [x] **Both M1 gates Accepted** — **done Aug 2**: [[ADR-013 — Profiler (Tracy-backed instrumentation)]]
      + [[ADR-014 — Events (buffered streams) & StringId]] in [[ADR Index]], so
      **M2's threading ADR is unblocked** at the Aug 29–30 boundary.
- [x] Every system touched has a **design note as its hub**, *Decided* rows §ref'ing the ADR
      with **no copied rationale** — **done Aug 2**: [[Profiler — Design]] · [[Events — Design]]
      + [[StringId — Design]] · [[File Access — Design]] · [[Math — Design]]. M1's design-note
      gap is closed for the four items this sprint takes; RNG + crash handler still carry.
- [x] `math/Math.hpp` + `math/Format.hpp` in `base` with Catch2 tests, **CI green both legs** —
      **met.** `Math.hpp` Aug 2 (`05cf3718`), `Format.hpp` + the first real `TEST_CASE`s Aug 3
      (`5afb6d28`). **Story B complete.**
- [x] Stories D/E/F's cards were **written after** their artifact, never before —
      **held Aug 2**, all three cut the same day their artifact landed.
- [ ] **S3-B1 closed** — one composition root owns diagnostics init.
- [ ] **Nothing built without a consumer, with one recorded exception:** math is a *vocabulary*,
      argued in [[Math — Design]] § Trigger. If a second exception appears, the rule is the thing
      to re-examine — not the exception.
- [x] Demo: a **profiler capture of the headless frame loop** — the first thing this engine can
      *measure* rather than print. **Met Aug 3** (S3-T4): `advance` → `FixedSteps` nested under
      each frame mark, `windows-profile` → Tracy `0.13.1` desktop over loopback. ADR-013 §3's
      topology held, so no re-naming was needed.

## Capacity note

**Sized up materially, not proportionally.** Sprint 02 planned 15 cards for ~5 weeks and closed
them in **6 days**; this plans ~20 in 4 weeks — a third more work in a fifth less time, and
still deliberately **below** the observed rate. The Sprint-02 rate was bought with **both
weekend days worked** and a Thursday that closed **six cards** (retro → *Sustainability*), and
its cards were small utilities behind an ADR written first. M1's are new subsystems whose
decisions do not exist yet.

Capacity from the [[Dashboard]] cadence: **12 🟢 Deep** (Mon + Thu + one weekend day × 4) ·
**4 🟠 Moderate** (Fri) · **4–8 🟡 Light** (Tue, plus Wed only if wanted).

| | Sized now | Stories D/E/F draw | Left empty |
|---|---|---|---|
| 🟢 **Deep** | 2 — D1, D2 | ~7 | **2 — protected** |
| 🟠 **Moderate** | 3 — D3, T1, B1 | ~2 | — |
| 🟡 **Light** | 3 — T2, P1, P2 | ~3 | Wed stays optional |

> **Fully sized 2026-08-02 — all three stories cut, and the reserve was wrong in an
> instructive direction.** Actual: **3 🟢** (T3, T9, T10) · **6 🟠** (D3✓, T1, B1, T4, T5,
> T12) · **8 🟡** (T2, P1, P2, T6, T7, T8, T11, T13) = 17 cards. Against capacity
> **12 🟢 · 4 🟠 · 4–8 🟡**, that is **9 deep days spare** while both cheap columns sit at
> or over their ceiling — the reserve guessed ~7 🟢 for D/E/F and they drew 3.
>
> **So the 🟠 squeeze the D and E notes pre-named for the Aug 15–16 review does not need a
> cut.** It was read as "5 🟠 vs 4 Fridays" — but weight is *fits-the-day*, not
> *is-the-day*: a 🟢 Deep day absorbs a 🟠 and more, and there are nine of them free. Both
> earlier options (ride a Wed opt-in · slip to Sprint 04) stay unused. **Take the review
> question off the agenda and record why** — the honest finding is not a capacity problem
> but a **sizing-model one**: three ADRs' worth of work decomposed into far lighter cards
> than the pre-ADR reserve assumed, which is exactly what *don't size past an open
> decision* is supposed to produce. Worth a retro line.
>
> Two deep slots still stay protected, and the surplus is still **banked, not filled**.

> **Two deep slots stay empty, and this is the sprint where that rule finally gets tested.**
> Sprint 01's "finish early → the next deep day stays empty" has **never** been exercised —
> Sprint 02 was *finished*, not run dry, so the slack was never reached. If Stories D/E/F come
> in under budget, the answer is still **bank it**.

Weekend days are a **swappable pair** — nothing here is assigned to Sat or Sun.

**Ordering:** S3-D1 → Story D · S3-D2 → Story E · S3-D3 → Story F. Those three are the only
hard sequence. Story B (math), S3-B1 and Story G float — they are what a light or moderate day
picks up while an ADR is still unwritten.

**The trade, pre-authorised:** if capacity tightens, cut **S3-P2** first, then **S3-P1**. Never
touch a 🟢 Deep slot, and **never cut S3-B1** — a Bug card is the one kind that is not
droppable ([[Planning Workflow — Artifact Gate]] § *Task attributes*).

## Sprint review (fill Aug 29–30)

- What shipped:
- Demo / artifact:

→ Retrospective in [[07 Journal]].
