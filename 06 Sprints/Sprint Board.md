---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 B — math · [[2026-08 Sprint 03 — M1 Enablers]] (Aug 1 – Aug 28)

- [ ] **S3-T2** — `Math/Format.hpp` + tests · P2 · 🟡 Light — separate header from the types,
	  so `<format>` stays opt-in.


## 📋 C — S2 loose ends

- [ ] **S3-B1** — Diagnostics init belongs in `app`, not the exe · P1 · 🟠 Moderate — carried
	  from `S2-B1`, which was created Jul 31 and **never reached this board**. Not droppable.


## 📋 D — profiler hooks *(T3 → T4 → {T5, T6})*

- [ ] **S3-T3** — Tracy dep + `TE_PROFILE` option + profile presets · P1 · 🟢 Deep — Story D's
	  head. **Riskiest card of the story:** `/W4 /WX` hits Tracy's header inside our own TU and
	  the `SYSTEM` fix needs CMake 3.25 (we require 3.21). Spike is its first hour.
- [ ] **S3-T4** — `base/Profile.hpp` + frame mark · P1 · 🟠 Moderate — **the sprint's demo**:
	  a profiled capture of the headless loop. Needs S3-T3.
- [ ] **S3-T5** — memory tracking: global `new`/`delete` replacement · P2 · 🟠 Moderate —
	  lives in `app`'s TU, never a `base` static-lib TU. Needs S3-T4.
- [ ] **S3-T6** — overhead number + coverage statement · P2 · 🟡 Light — < 5% bar into
	  [[B3 — Build & Testing Notes]]; says out loud that the ON path is not unit-tested.


## 📋 E — events + `StringId` *(T7 → T8 → T9 → T10)*

- [ ] **S3-T7** — `base/StringId.hpp` + tests ([[StringId — Design]]) · P1 · 🟡 Light —
	  constexpr FNV-1a/64 value type; **no macro, no UDL, no table**. Story E's head.
- [ ] **S3-T8** — event registry in `core` · P1 · 🟡 Light — tag-at-call registration from
	  the composition root; keeps tag strings → collision `TE_CHECK` + tooling lookup.
	  Needs S3-T7.
- [ ] **S3-T9** — `EventStream` core + tests ([[Events — Design]]) · P1 · 🟢 Deep —
	  ring/flip/retire/cursors; **retire-rule tests first**; zero steady-state alloc.
	  Needs S3-T8.
- [ ] **S3-T10** — loop wiring + headless demo · P1 · 🟢 Deep — flip per fixed sub-step,
	  retire at frame start; first event across a deterministic barrier. Needs S3-T9.


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