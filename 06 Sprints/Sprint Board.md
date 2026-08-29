---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 A · M2 gates · ✅ **complete** *(D1 · D2, both Aug 22)*



## 📋 B · concurrency bring-up · ✅ **complete** *(T4 · T5, both Aug 24)*



## 📋 C · serialization first slice *(T6 → T7)*

- [ ] **S4-T7** · visit seam + non-POD round-trip demo · P1 · 🟢 Deep


## 📋 D · measurements & cleanups

- [ ] **S4-T1** · `<format>` weight: measure, then decide · P2 · 🟠 Moderate
- [ ] **S4-T3** · `te-review`'s `base` findings · P3 · 🟡 Light


## 📋 E · process *(first thing cut)*



## 🔨 In Progress



## 👀 Review / Demo

- [ ] **S4-P1** · ccache: one warm entry per leg (+ sprint-plan skill wording) · P2 · 🟡 Light ·
	  **merged 50ca9360 (#53), held here deliberately.** The key is now
	  `v1-<leg>-<hash of deps.cmake>` with `append-timestamp: false`, so a run whose deps have
	  not moved hits the primary key and skips the save. Same content-addressed shape as the
	  `deps-*` cache beside it. **Creation is proven: 12 entries and 0.53 GB, down from 111 and
	  3.62 GB**, being 8 `ccache-v1-*` plus 2 `deps-*` plus 2 toolchain, exactly one per leg.
	  **What is NOT proven is the warm path, and no run has tested it yet.** Only one real
	  matrix run has happened under these keys, the cold one that created the entries. The
	  intended retrigger never ran: #54 merged first and put `.github/workflows/**` in the skip
	  list, so #53's own three files were all excluded and only the stand-in reported. The push
	  backstop skipped for the same reason. The count staying at 12 since is **not** evidence
	  the save is skipped, because nothing has written to it.
	  **Closes when a PR carrying engine C++ shows high ccache hits on the Linux legs.** That is
	  also the only run that tests the design's actual trade: 140 dep compilations hit while the
	  43 engine TUs miss and recompile. Watch the `ccache stats` step and re-count the caches.
	  **Retro:** the sequencing was called out before #54 was cut and taken anyway, so the card
	  merged its own verification out of reach. Same shape as S4-T5 riding T4's branch.
	  Mechanism and the compiler-bump failure mode are in [[B3 — Build & Testing Notes]]
	  § *ccache keys*; `ci.yml`'s header carries the `v1` bump instruction.
- [ ] **S4-P3** · coverage job per PR · P2 · 🟠 Moderate · **merged a8aee849 (#49), held here
	  deliberately.** The gate has never been evaluated on real changed lines in CI: its own PR
	  carried only CMake, YAML and Markdown, so `diff-cover` reported "no lines with coverage
	  information" and passed without testing anything. **Closes when the first PR carrying C++
	  produces a real percentage.** Two of the three things that were open are now closed: the
	  `diff coverage` context **is in the `Master` ruleset**, added once the first run had
	  reported it (GitHub only lists contexts it has seen), so the gate is 9 checks not 8 ·
	  ADR-008 §9 carries its dated `decision` amendment, covering both the ninth required check
	  and the retired "affordable because legs run in parallel" rationale, since the jobs are
	  now chained (filed 2026-08-28 alongside S4-P4's, not at this card's close) · the minute
	  cost is measured and below.
	  **Cost, from the merged PR run (warm caches):** 16.1 billed minutes total, of which
	  coverage is 1.5 (Linux, 1x). Baseline was 14.6, so about **+10%**. A cold coverage cache
	  costs far more, and that number is not captured. Local workflow is in
	  [[B3 — Build & Testing Notes]] § *Code coverage*.


## ✅ Done — [[2026-08 Sprint 04 — M2 Concurrency & Serialization]]

- [x] **S4-P4** · skip CI on no-code PRs · P3 · 🟠 Moderate (**was a 🟢 in practice**) ·
	  **Aug 28.** fdca32c8 (#50) + 753a7c08 (#51) + **e7562bf5 (#54)**. `ci.yml` carries
	  `paths-ignore` for **three** paths, `**.md` · `.claude/**` · `.github/workflows/**`, and
	  `ci-docs.yml` is a stand-in whose matrix spells the 9 required context names, so the merge
	  gate still reports.
	  **#54 folded in here 2026-08-29** (weekly review). It landed hours after this card was
	  marked done and widened the skip list to the third path, so it had no card of its own and
	  its only record was a clause inside S4-P1's entry. Two things follow from it. **One:
	  `ci.yml` is never tested by its own PR** — break the YAML or rename a leg and the PR still
	  shows nine green from the stand-in, and since `ci-docs.yml` hardcodes those nine names, a
	  rename silently uncovers it and later docs-only PRs hang unmergeable. The mitigation is in
	  `ci.yml`'s header: land workflow edits alone, read the run they produce on `master`.
	  **Two: the card's "no ADR-009 amendment owed" call was answered for docs and never re-asked
	  for workflows.** § *Consequences* leans on strict CI, and for this one class of change there
	  is none. Filed on [[Backlog]] as A3 from the 2026-08-29 drift check.
	  **Measured: 9 billed minutes against 16.1**, because GitHub rounds every job up to the
	  minute. The card was cut expecting a bigger win than that.
	  **The clause said 8 checks and the ruleset carries 9** — `diff coverage` joined it once
	  S4-P3's first run had reported. Fourth card running whose clauses did not match the tree.
	  **`if:` gating was measured dead, not argued dead.** On #49's push run a skipped *plain*
	  job still reports its context, but a skipped *matrix* job never expands: `sanitizers`
	  reported one check literally named `matrix.name` and its three legs reported nothing.
	  Seven of the nine contexts are matrix legs. That also makes `ci.yml`'s comment at the
	  `build-test` gate wrong; filed on [[Backlog]] rather than edited inside another card's text.
	  **Retro, and why auto-merge left scope:** #50 merged itself the moment its checks went
	  green, carrying half the change. `ci-docs.yml` was untracked, so `git commit -a` never
	  staged it, and master could not merge a docs-only PR at all until #51 landed. Green checks
	  cannot see an unstaged file, and auto-merge removed the look that can.
	  **Retro, second git slip in the same card:** a concurrent checkout put a commit on local
	  `master` instead of the topic branch. Caught before any push, nothing reached the remote.
	  **Proof was #52, closed on purpose and never merged.** `CI` did not fire, `CI (docs-only)`
	  reported all 9 contexts green in 3-4s each, and the PR went `MERGEABLE`/`CLEAN` with no
	  build. The clause is satisfied by that observation, not by a merge.
	  **Sizing retro, added 2026-08-29:** cut as 🟠, it ran a 🟢 day and spilled into a fourth
	  PR. Every process card this sprint that touched the merge gate was under-sized the same
	  way (S4-P1 was a 🟡 and did the same). See [[2026-08-29 Weekly Review]].
	  Story E stays open (S4-P1).
- [x] **S4-T6** · `Writer`/`Reader` primitives + bulk path + tests · P1 · 🟢 Deep · **Aug 27.**
	  1ca9ae9c (#48). The design note's **error-surface** question is answered in code: `Reader`
	  carries its own `ReadStatus` (`Ok`/`Truncated`/`BadMagic`/`BadVersion`), not `FileResult`,
	  whose vocabulary is `platform`'s (`NoMount`, `IsADirectory`) and wrong for a memory decoder.
	  The status is **sticky, not per-call**: the first failure latches and later reads no-op. That
	  is what makes S4-T7's `visit` body usable, since it reads many fields and checks once.
	  Length and count prefixes are pinned at **`u32`**, guarded by `TE_CHECK` with a defined path
	  instead of a silent narrowing. That is v1's `writeString`/`readBuffer` width mismatch made structural.
	  Pre-commit review changed the shipped design twice: `BlobHeader`'s defaults went to `0`, since
	  seeding them with the real magic and version made a header that *failed* to read look valid;
	  and `read(bool&)` stopped clobbering its out param on failure. Nothing logged not fixed.
	  **Retro:** the branch was `S4-T2/writer-reader-serialization`, so #48 points at a card that
	  merged as #47. Flagged before the commit, rename command given, shipped anyway. **Second card
	  running** where the ADR-012 § *Consequences* link broke (S4-T5 was the first).
	  Story C stays open (T7).
- [x] **S4-T2** · rename `TechEngine::detail` to `internal` · P3 · 🟡 Light · **Aug 27.**
	  4928447c (#47). The card sized the sweep at 13 files off a `namespace detail` grep. It was
	  15. `LogInternal.hpp` declares the namespace qualified and on one line, so that grep never
	  saw it. A rename estimate has to count the qualified spelling too.
	  `ci.yml`'s private-plumbing gate greps a literal, so the rename would have emptied it:
	  `\bdetail::log` matches nothing afterwards and the check then passes on an empty search
	  rather than failing. The card's `done:` clause named the guard, so it was swept. **A grep
	  gate fails open on a rename and nothing announces it.** Filed on [[Backlog]] § *etc*.
	  `CONVENTIONS.md`'s *Nested impl namespace* row is respelled and dated; the Jul 30 rationale
	  for having the namespace at all stands unchanged.
	  No review comments and no findings logged. Story D stays open (T1, T3).
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