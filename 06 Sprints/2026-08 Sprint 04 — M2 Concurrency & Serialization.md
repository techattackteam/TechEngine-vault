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

- [ ] **S4-D1** · threading ADR via `/adr` · P1 · 🟢 Deep · done: Accepted in [[ADR Index]];
      settles thread topology, GL context ownership, the pool interface plus the minimal pool's
      shape, and how [[Task Graph — Execution Flow]]'s levels map onto it; the concurrency
      design note is created as the hub; Story B is cut into carded tasks fitting the reserve.
- [ ] **S4-D2** · serialization ADR via `/adr` · P1 · 🟢 Deep · done: Accepted; settles the
      binary format and ADR-005's trait/registration seam (the "serializable" fact ADR-007 §7
      has every component register); names its consumers (M5 components · M6 resources ·
      T2/T4 bake · N3 snapshots) without building for them; the design note is created as the
      hub; Story C is cut.

### Story B — concurrency bring-up · ~2-3 tasks · **size after S4-D1**

> Heavy-gated, so deliberately unsized ([[Planning Workflow — Artifact Gate]] § *Don't size
> past an open decision*). Expected shape: the minimal pool against the real interface, with a
> Tracy capture showing named worker threads as the demo hook.

### Story C — serialization first slice · ~2-3 tasks · **size after S4-D2**

> Heavy-gated, so deliberately unsized. Expected shape: the trait seam plus a headless binary
> round-trip.

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
- [ ] **S4-P2** · CMake source-listing research · P3 · 🟡 Light · done: explicit lists,
      `CONFIGURE_DEPENDS` glob and a generator script are compared with evidence in
      [[B3 — Build & Testing Notes]]; the rule lands in `CONVENTIONS.md`, or is carded if it
      needs a sweep.
- [ ] **S4-P3** · coverage job per PR · P2 · 🟠 Moderate · done: one coverage job (Linux leg)
      runs on each PR and surfaces a report; it is not a required check; its minute cost is
      measured and recorded against the CI budget.
- [ ] **S4-P4** · skip CI on docs-only PRs, plus auto-merge · P3 · 🟠 Moderate · done: the
      dummy-job pattern reports all 8 required checks on docs-only PRs; the "no code" scope
      rule is written (as a dated ADR-009 amendment if it moves the self-review consequence);
      proven on one real docs PR.

## Definition of Done

- [ ] Both M2 ADRs are Accepted, each with a design note as its hub, and Stories B and C were
      cut **after** their artifact, never before.
- [ ] M2's unlock is demonstrable: a Tracy capture with pool workers visible, and a headless
      binary round-trip through the trait seam.
- [ ] Every pulled backlog entry was deleted at planning (six were), and nothing was built
      without a consumer.
- [ ] The checkpoint held: an ADR not Accepted by the Aug 29-30 review costs its story, not
      compression.

## Capacity note

2-week capacity from the [[Dashboard]] cadence: **8-10 🟢 · 2 🟠 · 2-4 🟡** (Mon and Thu are
one evening 🟢 each, the weekend deep day is 2-3 🟢, Fri is 🟠, Tue is 🟡, Wed is opt-in).

Sized now: **2 🟢** (D1, D2) · **3 🟠** (T1, P3, P4) · **4 🟡** (T2, T3, P1, P2). The reserve
for Stories B and C is **~4-6 🟢 plus whatever the deep days absorb**. Three 🟠 against two
Fridays is the same non-squeeze Sprint 03 recorded: a deep day absorbs a 🟠, and the deep
column has slack.

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
