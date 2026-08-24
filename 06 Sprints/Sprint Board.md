---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M2 gates · ✅ **complete** *(D1 · D2, both Aug 22)*



## 📋 B · concurrency bring-up · ✅ **complete** *(T4 · T5, both Aug 24)*



## 📋 C · serialization first slice *(T6 → T7)*

- [ ] **S4-T6** · `Writer`/`Reader` primitives + bulk path + tests · P1 · 🟢 Deep
- [ ] **S4-T7** · visit seam + non-POD round-trip demo · P1 · 🟢 Deep


## 📋 D · measurements & cleanups

- [ ] **S4-T1** · `<format>` weight: measure, then decide · P2 · 🟠 Moderate
- [ ] **S4-T2** · rename `TechEngine::detail` to `internal` · P3 · 🟡 Light
- [ ] **S4-T3** · `te-review`'s `base` findings · P3 · 🟡 Light


## 📋 E · process *(first thing cut)*

- [ ] **S4-P1** · ccache: one warm entry per leg (+ sprint-plan skill wording) · P2 · 🟡 Light
- [ ] **S4-P3** · coverage job per PR · P2 · 🟠 Moderate
- [ ] **S4-P4** · skip CI on docs-only PRs + auto-merge · P3 · 🟠 Moderate


## 🔨 In Progress



## 👀 Review / Demo


## ✅ Done — [[2026-08 Sprint 04 — M2 Concurrency & Serialization]]

- [x] **S4-P2** · CMake source-listing research · P3 · 🟡 Light · **Aug 24.**
	  Vault-only, no code. The **No `GLOB`** rule stands. What was missing was the *reversal
	  trigger*, and [[ADR-008 — v2 build & testing baseline]] §2 now carries a dated amendment
	  naming it: a **self-registration `.cpp`** has no symbol another TU references, so leaving
	  one out of the list is the single way this rule fails *silently* rather than at link.
	  ADR-016's type-registration seam is the likely first, and the answer then is a **CI
	  staleness check, not a glob**, since a glob would also drop the filtering the list does.
	  Measured evidence in [[B3 — Build & Testing Notes]] → *Source listing*: across 54 commits,
	  **0** `.cpp` files missing from a `SOURCES` list, 4 headers drifted (IDE grouping only,
	  so nothing builds differently). `CONVENTIONS.md` needed no change. **Considered and
	  declined:** globbing `HEADERS` alone, which buys back cosmetic drift at the price of a
	  second rule inside one helper.
- [x] **S4-T5** · `EngineContext` wiring + capture demo · P2 · 🟠 Moderate · **Aug 24.**
	  a0d1d1b3 (#46), on S4-T4's branch. `EngineContext` gains `JobSystem& jobs`, one field at
	  a time, the S3-T13 pattern. The capture shows the fork-join shape ADR-015 §4 predicted:
	  `JobSystem.Wait` on main spanning the worker's task zones under the frame marks. Reading
	  it is what moved the worker count (see S4-T4). **Retro:** the card rode T4's branch, so
	  the squashed commit links only to T4 and T5 has no path back to its board card
	  (ADR-012 § *Consequences*). Called out before the branch was cut and taken anyway;
	  the cost is real but small, and one PR for a card and its proof is defensible.
	  **Story B complete.**
- [x] **S4-T4** · `JobSystem` interface + one-worker pool + tests · P1 · 🟢 Deep · **Aug 24.**
	  a0d1d1b3 (#46). Two `done:` clauses had **no referent**: `Profile.hpp` had no
	  thread-naming macro, so the card carried a `base` change (`TE_PROFILER_THREAD_NAME`),
	  and nothing in the tree linked threads at all, so `find_package(Threads)` landed too.
	  That is the third card running in a row whose clauses named something that did not
	  exist (S3-B1, S3-T13).
	  **The worker count moved mid-card, 1 → 4**, off T5's first capture showing the single
	  worker running a four-task batch end to end. Filed as a dated `decision` amendment on
	  [[ADR-015 — Threading (sim on main, render thread owns GL)]] §3 with an inline marker at
	  §4, whose determinism-by-construction claim rested on the count.
	  **Exception policy was undecided and got decided here**: a throwing task is caught,
	  reported, and its batch decremented, so `wait` cannot park forever. It does **not**
	  settle `CONVENTIONS.md`'s *Error handling* Open row. Recorded with four other
	  implementation calls in [[Concurrency — Design]] § *Mechanism*.
	  Review caught four ways to kill or hang the pool, all fixed in the same PR, none logged:
	  an exception escaping a task, `wait` called from a worker, concurrent `shutdown`
	  returning before the join, and a constructor throwing mid-spawn. Two missing tests were
	  written with them.
	  Naming drift resolved **toward the code**: the note pinned `te-worker-0`, the code
	  shipped `TEWorker0`, and ADR-015 §5 leaves the format to the note.
	  **Retro:** `linux-release` broke on a constant used only inside a `TE_ASSERT`. In
	  Release the macro discards its condition entirely, so the only reader vanishes and
	  `-Werror` kills the build. Anything named only inside a `TE_ASSERT` has this shape.
	  Ride-along, not the card: Tracy moved v0.13.1 → v0.14.1 and
	  `FETCHCONTENT_UPDATES_DISCONNECTED` went ON → OFF. **Unblocks M5's executor.**
- [x] **S4-D2** · serialization ADR · P1 · 🟢 Deep · **Aug 22.**
	  [[ADR-016 — Serialization (binary primitives & describe-once seam)]] **Accepted**;
	  [[Serialization — Design]] created as the hub, surface pinned before the cut. Two paths
	  one seam (bulk trivially-copyable · visited) · the visit function doubles as the
	  reflection seam · LE, deterministic, headered · one header version, re-bake over
	  migration · tags hash with `StringId`, macro-free (vocabulary amendment on ADR-007 §1's
	  `TE_COMPONENT` sketch) · document schemas stay with their consumers. Review finding: no
	  sprint-relative labels in durable artifacts; both new notes swept to card IDs and dates.
	  **Story C cut into S4-T6 → S4-T7. Story A complete: both M2 gates Accepted on day 1.**
- [x] **S4-D1** · threading ADR · P1 · 🟢 Deep · **Aug 22.**
	  [[ADR-015 — Threading (sim on main, render thread owns GL)]] **Accepted**;
	  [[Concurrency — Design]] created as the hub, surface pinned before the cut. Sim on main
	  (drag-stall named, reversal trigger'd) · render thread owns GL, fed complete command
	  lists · `JobSystem` in `core`, batch submit and wait, one worker at M2 · `publish`
	  sim-thread-only until P1. The fork-join idle bubble went into §4 on review, P2 owns the
	  upgrade behind a P1 measurement. Ride-along: [[Task Graph — Execution Flow]]'s two stale
	  M10 refs now read P1/P2. **Story B cut into S4-T4 → S4-T5; S4-D2 is Story A's last card.**




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,null,null,null,null,null,null,null,null,null]}
```
%%