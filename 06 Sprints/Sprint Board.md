---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 C — S2 loose ends · [[2026-08 Sprint 03 — M1 Enablers]] (Aug 1 – Aug 28)

- [ ] **S3-B1** — Diagnostics init belongs in `app`, not the exe · P1 · 🟠 Moderate — carried
	  from `S2-B1`, which was created Jul 31 and **never reached this board**. Not droppable.


## 📋 D — profiler hooks — ✅ **complete** *(T3 → T4 → {T5, T6})*



## 📋 E — events + `StringId` — ✅ **complete** *(T7 → T8 → T9 → T10)*



## 📋 F — file access *(T11 → T12 → T13)*

- [ ] **S3-T11** — `MountTable` + path resolution + tests ([[File Access — Design]]) · P1 ·
	  🟡 Light — `alias://` + priority; `mount()` lives **here only**, not on an interface.
	  Case-sensitivity test is the one that differs across CI legs. Story F's head.
- [ ] **S3-T12** — `IFileAccess` + `FileAccess` + tests · P1 · 🟠 Moderate — interface **and**
	  impl in `platform` — that placement *is* the F30 fix. `FileResult`, never a log on a
	  miss. Needs S3-T11.
- [ ] **S3-T13** — wiring + runtime proof · P2 · 🟡 Light — `EngineContext.files`; a headless
	  `runtime` reads through a virtual path — F30's regression test. Needs S3-T12.


## 📋 G — process *(first to cut)*

- [ ] **S3-P1** — ADR amendment policy · P2 · 🟡 Light — ADR-011 amended in place twice vs
	  [[ADR Index]]'s immutability rule. One of the two is wrong.
- [ ] **S3-P2** — Skill `te-review` · P3 · 🟡 Light — **first to cut.** Dry-run must find
	  something real or the rubric gets trimmed.


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 03 — M1 Enablers]]

- [x] **S3-T6** — overhead number + coverage statement · P2 · 🟡 Light — **Aug 8**.
	  **Story D complete — all four cards done.** OFF `0.0206` · ON-disconnected `0.0339` ·
	  ON-connected `0.1583` µs/frame; **+0.1377 µs = 0.0008% of a 16.6 ms frame** against
	  ADR-013 §6's < 5% ([[B3 — Build & Testing Notes]] § *Overhead*). Tracy-spelling grep in
	  `ci.yml`, one OFF-path Catch2 case, coverage stated in [[Profiler — Design]].
	  **The card's own recipe could not produce a number** — timing the headless loop measures
	  the 60 Hz spin pacer, which pins both builds at 16.6 ms; the run needed the pacer out and
	  a synthetic `deltaTime`, on a throwaway patch that did not merge. **`TRACY_ON_DEMAND`
	  made it three runs, not two**, and the disconnected one turned out to be the interesting
	  one: 2.2 ns per call site, Tracy's own quoted figure. **§6's ratio form is not evaluable
	  at M1** — against a 0.02 µs baseline the delta is +669%, which measures the empty loop;
	  the absolute cost is the checkable form until M2/R1 give it real frame content.
- [x] **S3-T10** — loop wiring + headless demo · P1 · 🟢 Deep — **Aug 8**, engine `ad47ec20`
	  (PR #35). **Story E complete — all four cards done.** `advance(deltaTime, onFixedStep)`
	  calls a hook per fixed sub-step and the **driver** publishes, flips, reads and retires
	  around it, so `app`'s loop still knows nothing about events; that hook is `FixedUpdate`'s
	  slot at M5. `EventStreamManager` owns the streams by dense index and **seals** the
	  registry when it builds them, so a late `registerEvent` fails at the registration rather
	  than at the first publish. Two things the card learned:
	  **`frameIndex` had to move to the top of `advance`** — stamped from the bottom, every
	  batch retires a frame early, and **no end-of-call assertion can see it**; the three hook
	  cases came out of review, not the card. And **`TE_ASSERT` was the wrong tier for a
	  lookup miss** — it vanishes in Release *and* fell through into the vector; `TE_VERIFY`
	  plus a null return is the registry's own check-then-defined-path shape.
- [x] **S3-T5** — memory tracking: global `new`/`delete` replacement · P2 · 🟠 Moderate —
	  **Aug 7**, engine `dc790d7d` (PR #34). All 20 replaceable forms in `app`'s
	  `diagnostics/MemoryTracking.cpp`; a `windows-profile` capture shows a live Memory-usage
	  plot with the session intact at frame 120, and the link is clean against `msvcprt.lib`.
	  **Story D's last code card — only S3-T6 (the overhead number) remains.** Three things
	  the card learned: `app` is a static lib too, so the replacement needs a **called anchor
	  symbol**, not a rule; the macros forward to Tracy's **secure** variants, because a global
	  `operator new` runs during CRT static init and can precede Tracy's construction; and the
	  TU **detects ASan/TSan itself** rather than trusting ADR-013 §4's OFF policy. Carries the
	  `CONVENTIONS.md` folder-rule relaxation (design note → subject area) that moved
	  `Profile.hpp` into `base/diagnostics/`.
- [x] **S3-T8** — event registry in `core` · P1 · 🟡 Light — **Aug 7**, engine `6e881d5e`
	  (PR #31, shared with T9). `EventRegistry` + a distinct `EventTypeId` wrapping `StringId`;
	  record keeps tag, dense index, size/align, `EventWire`; `static_assert` on
	  trivially-copyable. **The mapping T → id is a `detail::g_eventTypeSlot<T>` template
	  variable — process-global, not registry-scoped**, so registries are not isolated from
	  each other. Recorded in [[Events — Design]] as the type-check mechanism.
- [x] **S3-T9** — `EventStream` core + tests ([[Events — Design]]) · P1 · 🟢 Deep — **Aug 7**,
	  engine `6e881d5e` (PR #31, same commit as T8). Absolute-`u64` ring, three positions,
	  `makeVisible`/`retire`/cursors; retire-rule cases written first, 9 `TEST_CASE`s.
	  The zero-steady-state-alloc test lost its mechanism to TSan's own `operator new`
	  replacement and was **re-expressed as `capacity() == 64`** — no allocator interposition,
	  same guarantee for the ring. Its one open condition — the method is `makeVisible`, not
	  the note's `flip` — **closed at S3-T10**: the note carries the rename and T10's §ref
	  follows it.
- [x] **S3-T7** — `base/stringid/StringId.hpp` + tests ([[StringId — Design]]) · P1 · 🟡 Light —
	  **Aug 4**, engine `7e4564db` (PR #27). **Story E's head done; T8 unblocked.** constexpr
	  FNV-1a/64; no macro, no UDL, no table. Three calls landed **against the note as first
	  written**, all recorded there: header in **`base/stringid/`** (CONVENTIONS' folder rule
	  beats ADR-014 §1's root path — same resolution as S3-T4, ADR unedited); the value is
	  **private behind `value()`**, which turns `fromValue` from a convention into an invariant
	  the compiler holds; the formatter takes **no spec** and rejects one with
	  `std::format_error`, not an assert tier. Byte-hashing is `unsigned char` — the `"\x80"`
	  case is the only test that catches a sign-extended XOR, and a wrong hash would have
	  frozen on disk and wire.
- [x] **S3-T4** — `base/profiler/Profile.hpp` + frame mark · P1 · 🟠 Moderate — **Aug 3**,
	  engine `87ed6dd0` (PR #25) + `dd866aa7` (PR #26). **The sprint's demo shipped** — a
	  `windows-profile` capture shows `FrameLoop::advance` → `FixedSteps` nested under each
	  frame mark, Tracy `0.13.1` on both sides. Header landed in **`base/profiler/`**, not
	  ADR-013 §2's `base/Profile.hpp`: CONVENTIONS' folder-per-utility rule (S3-T2) landed a
	  day after the ADR and won, recorded in [[Profiler — Design]] with the ADR unedited.
	  **Moved again at S3-T5** to `base/diagnostics/` when that rule was relaxed.
	  "No Tracy symbol when OFF" is discharged **by construction** — `TE_PROFILE=OFF` never
	  runs the fetch, so there is no target to link — not by inspecting a binary.
	  **Two PRs, because the first merged an exercise rather than the card** — retro line.
	  **Story D's head done; T5 + T6 unblocked.**
- [x] **S3-T3** — Tracy dep + `TE_PROFILE` option + profile presets · P1 · 🟢 Deep — **Aug 3**,
	  engine `7610b931` (PR #24). **Story D's head; T4 unblocked.** Tracy `v0.13.1`
	  option-guarded, `TE_PROFILE` OFF by default, `windows-profile` / `linux-profile` presets;
	  311/311 + ctest 73/73, default preset fetches no Tracy. **All three of the card's stacked
	  risks were non-risks** — Tracy declares its own includes `SYSTEM` (no re-export, no
	  CMake-3.25 blocker), CMake emits `-external:W0` so `/W4 /WX` needed no exemption, and no
	  OS-header breakage in any target. Two of the three were answerable by **reading Tracy's
	  build files, not its source** — retro line. **Linux leg unverified and CI never builds
	  it** ([[B3 — Build & Testing Notes]] § *Profiling builds*).
- [x] **S3-T2** — `math/Format.hpp` + tests ([[Math — Design]]) · P2 · 🟡 Light — **Aug 3**,
	  engine `5afb6d28` (PR #23). **Story B complete.** Three partial specializations over glm's
	  templates (`vec`/`mat`/`qua`), not one per alias — `IVec`/`UVec`/`Mat3` free; glm's
	  spelling, spec forwarded to elements, quats **xyzw**. Two unplanned: a latent **Jolt
	  `/MTd` vs our `/MDd` CRT mismatch** that `<format>` finally surfaced (fixed in
	  `cmake/deps.cmake`), and a **`base` layout rule** — folder per utility named after its
	  design note, `base/Format.hpp` → `diagnostics/FormatString.hpp` (`CONVENTIONS.md` →
	  *Headers*).
- [x] **S3-T1** — `Math.hpp` alias set ([[Math — Design]]) · P1 · 🟠 Moderate — **Aug 2**,
	  engine `05cf3718` (PR #21). Alias set in `TechEngine`; `glm::glm` was already PUBLIC on
	  `te_base`, **no CMake change needed**; no `GLM_FORCE_*` — the deferral lives in the note
	  only. `MathTests.cpp` = `static_assert`s, so CI compiles the header before S3-T2 does.
	  [[Math — Design]] → **active**.
- [x] **S3-D3** — file-access design note (F30) · P2 · 🟠 Moderate — **Aug 2.**
	  [[File Access — Design]] · **`IFileSystem` → `IFileAccess`** (v1's was a `System` —
	  F16), recorded as a dated vocabulary amendment on ADR-006's header. `platform` ·
	  `alias://` mounts kept · `FileResult` over `bool` · sync-only · read/write split with
	  the **write side deferred to M3** (Sprint 04's first writer). Story F cut into S3-T11…T13 —
	  **all three stories now sized.**
- [x] **S3-D2** — Events + `StringId` ADR (`/adr`) · P1 · 🟢 Deep — **Aug 2.**
	  [[ADR-014 — Events (buffered streams) & StringId]] Accepted (buffered streams ·
	  barrier flip · `StringId` FNV-1a/64 · no Pool); two partial supersessions rowed;
	  [[Events — Design]] + [[StringId — Design]] active; Story E cut into S3-T7…T10.
	  **Both M1 gates closed.**
- [x] **S3-D1** — Profiler ADR (`/adr`) · P1 · 🟢 Deep — **Aug 2.**
	  [[ADR-013 — Profiler (Tracy-backed instrumentation)]] Accepted; [[Profiler — Design]]
	  rewritten as the living *how*; Story D cut into S3-T3…T6.
	  **M2's threading ADR is unblocked.**




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,null,null,null,null,null,null,null,null,null]}
```
%%