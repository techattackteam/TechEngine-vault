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
> The Profiler and Events ADRs land; math ships; `IFileSystem` gets its note. **Decide first,
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

- [ ] **S3-D1** — Profiler ADR via `/adr` · **P1** · 🟢 Deep — done: ADR **Accepted** in
      [[ADR Index]], freezing the thin-`base`-façade → Tracy direction; [[Profiler — Design]]'s
      **five open questions closed** (in-proc vs separate process · Tracy version pin · socket
      off in shipping builds · clock resolution · overhead budget); its interim *Direction*
      table collapses to §refs; its ***Trigger* section rewritten** to M1 — the [[Roadmap]]
      already flags that section as stale, so leaving it is shipping a note that argues against
      its own sprint. Also settles whether **memory tracking** rides the profiler.
      **Cuts Story D's cards. Gates M2's threading ADR.**
- [ ] **S3-D2** — Events + `StringId` ADR via `/adr` · **P1** · 🟢 Deep — done: ADR
      **Accepted**, answering **F28** (unsubscribe compares `std::function`s, which are not
      equality-comparable → observers can't be removed; every event is a per-frame
      `shared_ptr` alloc) and **naming the event-id type**, which is what pins `StringId`'s
      shape; [[Game Loop — Frame Flow]]'s ***Event dispatch point*** open question closed
      (drain at phase barriers vs continuously); states whether a **Pool** primitive is needed
      ([[Backlog]] → `base`, whose trigger is literally "Events, M1") and whether a separate
      design note is owed or the ADR is the hub. **Cuts Story E's cards.**
- [ ] **S3-D3** — `IFileSystem` design note · **P2** · 🟠 Moderate — done: note in
      `04 Design Docs/Systems/`, *Decided* rows **§ref'd to ADR-006 §4/§5 with no copied
      rationale**; decides the **mount / virtual-path scheme**, **sync-only vs an async seam**,
      the **error model**, and **which module implements it** (ADR-006 §5 says "platform/core"
      — pick one and say why); mines v1 for **F30** (impl was editor-only, so a shipped runtime
      could not load assets). **Cuts Story F's cards.**

### Story B — math *(sized: [[Math — Design]] drafted this session)*

- [ ] **S3-T1** — `Math.hpp` alias set · **P1** · 🟠 Moderate — done:
      `engine/base/include/TechEngine/base/Math.hpp` carries the [[Math — Design]] alias set in
      namespace `TechEngine`; `glm::glm` confirmed **PUBLIC** on `te_base` (ADR-011 §1);
      **no `GLM_FORCE_*` handedness/depth defines** — that call is deferred to the renderer ADR
      and the note is its record; `TechEngineSDKSmoke` still compiles.
- [ ] **S3-T2** — `Math/Format.hpp` + tests · **P2** · 🟡 Light — done: `std::formatter`
      specializations for `Vec2/3/4`, `Mat4`, `Quat` in a **separate header** from the types
      (ADR-006 §6 — formatters live with math; the split keeps `<format>` opt-in); Catch2 cases
      pin the rendered form; a `TE_LOGGER_INFO("{0}", position)` call site compiles with only
      that header added.

### Story C — Sprint 02 loose ends

- [ ] **S3-B1** — diagnostics init belongs in `app`, not the exe · **P1** · 🟠 Moderate —
      carried from S2-T2's parked list, reclassified `S2-B1` on Jul 31 and **never reached the
      board** (retro → *Process improvements*). done: `initLogging()`, channel/module
      registration and the assert-handler install move into the **`app` composition root**
      (ADR-011 §2 §8), so `apps/runtime` and `apps/editor` stop each owning a copy;
      S2-T3's residual — `initLogging`/`spdlogSink` uncovered by ctest — is either **closed or
      explicitly re-parked with the reason**, not left silent.

### Story D — Profiler hooks · ~3–4 tasks · **size after S3-D1**
### Story E — Events + `StringId` · ~4–5 tasks · **size after S3-D2**
### Story F — File access · ~2–3 tasks · **size after S3-D3**

> Heavy-gated → deliberately **unsized** ([[Planning Workflow — Artifact Gate]] § *Don't size
> past an open decision*). Cards get cut when their ADR/note is Accepted, per that Design
> card's own done-condition. Do not fill these in to make the note look complete — S2-T2 is
> what that produces. Their shared weight budget is in the capacity note.

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

- [ ] **Both M1 gates Accepted** — the Profiler and Events ADRs are in [[ADR Index]], so
      **M2's threading ADR is unblocked** at the Aug 29–30 boundary.
- [ ] Every system touched has a **design note as its hub**, *Decided* rows §ref'ing the ADR
      with **no copied rationale** — Profiler, Events, `IFileSystem`, math.
- [ ] `Math.hpp` + `Math/Format.hpp` in `base` with Catch2 tests, **CI green both legs**.
- [ ] Stories D/E/F's cards were **written after** their artifact, never before.
- [ ] **S3-B1 closed** — one composition root owns diagnostics init.
- [ ] **Nothing built without a consumer, with one recorded exception:** math is a *vocabulary*,
      argued in [[Math — Design]] § Trigger. If a second exception appears, the rule is the thing
      to re-examine — not the exception.
- [ ] Demo: a **profiler capture of the headless frame loop** — the first thing this engine can
      *measure* rather than print. Contingent on S3-D1's topology; if the ADR lands a different
      shape, the demo is whatever that shape produces, named at the review rather than skipped.

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
