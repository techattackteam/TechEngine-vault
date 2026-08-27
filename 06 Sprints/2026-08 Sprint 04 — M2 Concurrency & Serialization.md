# 2026-08 · Sprint 04 — M2 Concurrency & Serialization

- **Quarter:** [[2026-Q3]]
- **Dates:** **Sat Aug 22 to Fri Sep 4, 2026.** The first 2-week sprint ([[Dashboard]]
  § *Rhythm*). Weekly review on the Aug 29-30 weekend; the Sep 5-6 boundary weekend is day 1
  of Sprint 05.
- **Epic:** M2 · concurrency + serialization ([[Roadmap]] → *The chain*)
- **Decisions behind it:** [[Roadmap]] § *M2 — what the concurrency ADR must settle* ·
  [[ADR-005 — v2 tech stack & toolchain]] (the reserved trait seam; binary serialization named
  critical path) · [[ADR-007 — v2 networking & ECS replication foundation]] §7 ·
  [[Task Graph — Execution Flow]] § *Open questions*

## 🎯 Sprint goal

> **Decide M2: the threading and serialization ADRs both Accepted, each proven by first code
> against its real interface.**
>
> Decide first, then build, same as Sprint 03. The two ADRs are unrelated and can land in
> either order.

### Scope calls locked at planning (2026-08-22)

| Question | Call | Why |
|---|---|---|
| M3 in this sprint? | **No. M2 only; M3 is Sprint 05's candidate.** | The [[Roadmap]] row pre-named this call. A 2-week box holds two heavy ADRs plus their first code, not a third lane. |
| RNG, crash handler | **Carry again.** | Still no consumer and still artifact-less, the same reasoning as Sprint 03's scope call. Memory tracking left the carry list: it shipped at S3-T5. |
| Bugs and [[Known Issues]] | **None enter.** No carried B cards; D1, D2 and D3 neither block nor touch M2 work. D1 may ride S4-T3's PR (see the card). | The list working as designed. |
| "Code coverage" had no backlog entry | **Carded as S4-P3, a per-PR CI job** (one job). | Decided at planning; it is new work, not a pull. |

## 🚦 Artifact gate

| Item | ADR? | Design note? | Outcome |
|---|---|---|---|
| **Threading** (topology · GL context owner · pool shape · level mapping) | ✅ | **Coverage gap, said out loud: no note exists.** The ADR session creates it as the hub. | Hard to reverse, cross-module. **Heavy, so S4-D1, ordered first.** |
| **Serialization** (binary format · trait/registration seam) | ✅ | **Same gap, same fix.** | ADR-005 reserved the seam and calls the serializer critical path. **Heavy, so S4-D2.** |
| `<format>` weight · rename · te-review findings · the CI cards | ❌ | ❌ | Reversible and local, straight to cards. One caveat: S4-P4's scope rule becomes a dated [[ADR-009 — Branching strategy & merge rules]] amendment if it moves that ADR's self-review consequence. |

## Stories & tasks

> Every task carries `· P1/P2/P3 · 🟢 Deep / 🟠 Moderate / 🟡 Light`. Weight fits the day
> first, then priority ([[Planning Workflow — Artifact Gate]]).

### Story A — M2's gates *(Design · ordered first; Stories B and C wait on these)*

- [x] **S4-D1** · threading ADR via `/adr` · P1 · 🟢 Deep · **done 2026-08-22**
      ([[ADR-015 — Threading (sim on main, render thread owns GL)]] **Accepted**;
      [[Concurrency — Design]] created active, surface pinned pre-cut). Sim on main with the
      drag-stall named and its reversal trigger'd · render thread owns GL, fed complete
      per-frame command lists · `JobSystem` in `core`, batch submit and wait, one worker at
      M2 · level = batch, barriers never on workers · `publish` sim-thread-only until P1
      (re-scoped from [[Events — Design]]'s M2 reservation). The fork-join idle bubble went
      into §4 on review, with P2 owning the upgrade behind a P1 measurement. Ride-along: the
      grounding pass found and fixed [[Task Graph — Execution Flow]]'s two stale M10 refs
      (now P1/P2). **Story B cut into S4-T4 → S4-T5. M4 and M5 are unblocked on this half.**
- [x] **S4-D2** · serialization ADR via `/adr` · P1 · 🟢 Deep · **done 2026-08-22**
      ([[ADR-016 — Serialization (binary primitives & describe-once seam)]] **Accepted**;
      [[Serialization — Design]] created active, surface pinned pre-cut). Two paths one seam
      (bulk trivially-copyable · visited) · the describe-once visit is both archive driver
      and the reflection seam · little-endian, deterministic, `{magic, version, flags}`
      header · one header version, re-bake over migration, per-type versions trigger'd on
      the first non-regenerable content · tags hash with `StringId`, macro-free, recorded as
      a vocabulary amendment on ADR-007 §1's `TE_COMPONENT` sketch · document schemas stay
      with M5/M6/T4/N3. Review finding, applied to both new notes: **sprint-relative labels
      ("Story C") do not belong in durable artifacts**; card IDs and dates replaced them.
      **Story C cut into S4-T6 → S4-T7. Story A complete: both M2 gates Accepted on day 1.**

### Story B — concurrency bring-up *(sized 2026-08-22, off ADR-015)*

> Ordering: **T4 → T5**, independent of Story C. Gate said **neither** on both: ADR-015 is
> Accepted and [[Concurrency — Design]] § *Surface* carries the pinned shape. The render
> thread is **not** built here; it waits for M4's window (ADR-015 §2 decides, M4 proves).

- [x] **S4-T4** · `JobSystem` interface + one-worker pool + tests · P1 · 🟢 Deep ·
      **done 2026-08-24** (a0d1d1b3, #46). The pool ships **four** workers, not one: ADR-015
      §3 amended mid-card off T5's capture. Entry on [[Sprint Board]]. Original acceptance:
      `core` carries the [[Concurrency — Design]] § *Surface* shape (submit a batch, wait
      that batch, `workerCount()`, the worker named for Tracy, submit-after-shutdown behind
      `TE_CHECK` with a defined path); Catch2 pins: every task runs exactly once, `wait`
      returns only after the batch completes, tasks execute on the worker thread (thread id
      observed), the shutdown path; green on all legs, `linux-tsan` included.
- [x] **S4-T5** · `EngineContext` wiring + capture demo · P2 · 🟠 Moderate ·
      **done 2026-08-24** (a0d1d1b3, #46), on S4-T4's branch. Entry on [[Sprint Board]].
      Original acceptance: the
      composition root owns `JobSystem` by value and `EngineContext` gains `JobSystem& jobs`
      (ADR-006 §4's sketch made real one field at a time, the S3-T13 pattern); the headless
      driver submits a demo batch per frame; a `windows-profile` capture shows zones on the
      named worker under the frame marks (half of the sprint's demo);
      `TechEngineSDKSmoke` still compiles. Needs S4-T4.

### Story C — serialization first slice *(sized 2026-08-22, off ADR-016)*

> Ordering: **T6 → T7**, independent of Story B. Gate said **neither** on both: ADR-016 is
> Accepted and [[Serialization — Design]] § *Surface* carries the pinned shape. No file I/O
> anywhere here: the writer is M3's, so everything round-trips through memory.

- [ ] **S4-T6** · `Writer`/`Reader` primitives + bulk path + tests · P1 · 🟢 Deep · done:
      `core` carries the pinned surface (primitives · `{magic, version, flags}` header
      written and checked by the pair · bulk `span<const T>` path · fail-soft `Reader` with
      a status, whose shape answers the note's error-surface question in code); Catch2 pins:
      every primitive round-trips, a bulk span round-trips, truncated and corrupted buffers
      fail soft, wrong magic and wrong version are rejected; green on all legs.
- [ ] **S4-T7** · visit seam + non-POD round-trip demo · P1 · 🟢 Deep · done: the
      describe-once `visit` binding is decided in code (ADL vs trait, recorded in the note)
      and a hand-made non-POD struct round-trips through both archives; the drift-guard
      question gets its honest answer recorded in the note (what a test can actually pin);
      the headless driver round-trips a struct through the seam and logs it, the sprint
      demo's other half; `TechEngineSDKSmoke` still compiles. Needs S4-T6.

### Story D — measurements & cleanups *(Dev)*

- [ ] **S4-T1** · `<format>`'s header weight: measure, then decide · P2 · 🟠 Moderate · done:
      the per-TU cost of the `<format>`-carrying headers is measured; numbers land in
      [[B3 — Build & Testing Notes]]; the call (drop `<format>`, keep the split, or fold back)
      is recorded in [[Math — Design]]; header changes are carded separately if the call wants
      them.
- [ ] **S4-T2** · rename `TechEngine::detail` to `internal` · P3 · 🟡 Light · done: the 13
      files and `ci.yml`'s `\bdetail::log` guard are swept, no `detail` namespace remains, CI
      is green.
- [ ] **S4-T3** · `te-review`'s `base` findings · P3 · 🟡 Light · done: `Log.cpp`'s quoted
      includes fixed together with `.clang-format`'s category regex (fixing one alone moves
      the problem); `RingEntry` becomes `LogRingEntry`; the discarded `addLogSink` bool gets
      the `CONVENTIONS.md` *Error handling* Open row decided. Optional ride-along:
      [[Known Issues]] D1's fallback fix is ~6 lines plus a test in the same area; delete D1
      if taken.

### Story E — Process *(first thing cut; the mix is called out below)*

- [ ] **S4-P1** · ccache: one warm entry per leg · P2 · 🟡 Light · done: a per-leg cache key
      replaces the timestamped accumulation, storage sits under the 10 GB cap, and a later run
      shows hits on the Linux legs. Rides along: `.claude/commands/sprint-plan.md` still says
      4-week sprints; fix the wording in the same PR.
- [x] **S4-P2** · CMake source-listing research · P3 · 🟡 Light ·
      **done 2026-08-24** (vault-only, no code). Entry on [[Sprint Board]]. The card's last
      `done:` clause had no work behind it: the rule was **already** in `CONVENTIONS.md`, in
      [[B3 — Build & Testing Notes]], and in ADR-008 §2 as an Accepted decision enforced by a
      `FATAL_ERROR` in both helpers. So the real shape was the opposite one, re-testing an
      Accepted rule rather than deciding an open one. **The rule stands**, both `SOURCES` and
      `HEADERS` stay explicit, and ADR-008 §2 gains the reversal trigger it never had.
      Original acceptance: explicit lists, `CONFIGURE_DEPENDS` glob and a generator script
      compared with evidence in B3; the rule lands in `CONVENTIONS.md`, or is carded if it
      needs a sweep.
- [ ] **S4-P3** · coverage job per PR · P2 · 🟠 Moderate · done: one coverage job (Linux leg)
      runs on each PR and surfaces a report; it is not a required check; its minute cost is
      measured and recorded against the CI budget.
- [ ] **S4-P4** · skip CI on docs-only PRs, plus auto-merge · P3 · 🟠 Moderate · done: the
      dummy-job pattern reports all 8 required checks on docs-only PRs; the "no code" scope
      rule is written (as a dated ADR-009 amendment if it moves the self-review consequence);
      proven on one real docs PR.

## Definition of Done

- [x] Both M2 ADRs are Accepted, each with a design note as its hub, and Stories B and C were
      cut **after** their artifact, never before. **Met 2026-08-22, day 1**: ADR-015 with
      [[Concurrency — Design]], ADR-016 with [[Serialization — Design]].
- [ ] M2's unlock is demonstrable: a Tracy capture with pool workers visible, and a headless
      binary round-trip through the trait seam. **Concurrency half met 2026-08-24**
      (a0d1d1b3, #46): the capture shows named worker zones under the frame marks. The
      serialization half waits on S4-T6 → S4-T7.
- [ ] Every pulled backlog entry was deleted at planning (six were), and nothing was built
      without a consumer.
- [ ] The checkpoint held: an ADR not Accepted by the Aug 29-30 review costs its story, not
      compression.

## Capacity note

2-week capacity, derived from [[Dashboard]] § *Rhythm*: **8-10 🟢 · 2 🟠 · 2-4 🟡**.

Sized now: **2 🟢** (D1, D2) · **3 🟠** (T1, P3, P4) · **4 🟡** (T2, T3, P1, P2). The reserve
for Stories B and C is **~4-6 🟢 plus whatever the deep days absorb**. Three 🟠 against two
Fridays is the same non-squeeze Sprint 03 recorded: a deep day absorbs a 🟠, and the deep
column has slack.

> **Story B cut 2026-08-22, off ADR-015: 1 🟢 · 1 🟠**, against a shared ~4-6 🟢 reserve.
> Under the guess again, the same direction as Sprint 03's sizing lesson.
>
> **Story C cut 2026-08-22, off ADR-016: 2 🟢.** B and C together draw **3 🟢 · 1 🟠**
> against the reserve, so the sprint is fully sized on day 1 with deep slack to spare, the
> Sprint 03 pattern repeating. The slack stays banked.

**Said out loud: 4 of the 9 sized cards are Process (about 44%, and about 30% once B and C
are cut).** All four were pulled deliberately at planning, every trigger fired. They live on
light and moderate days; the deep days belong to M2.

**Cut order if capacity tightens:** S4-P4, then S4-P2, then S4-T2/T3, then S4-P3, then S4-P1.
Never a 🟢 slot. Stories B and C are the goal.

**Checkpoint at the Aug 29-30 weekly review:** an M2 ADR not Accepted by then leaves its
story under a week of runway. The honest answer is to cut that story, not compress it, the
same rule Sprint 03 pre-named.

Weekend days stay a swappable pair; nothing here is assigned to Sat or Sun. The sprint's
first `/card-start` doubles as S3-P2's real acceptance test.

## Sprint review (fill Sep 5-6)

- What shipped:
- Demo / artifact:

→ Retrospective in [[07 Journal]].
