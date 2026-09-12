# 🏛️ ADR Index

Architecture Decision Records. Every load-bearing decision gets one. Use
[[ADR Template]] to start a new record. Numbered sequentially, never reused.

> **An ADR is a dated decision + its rationale, frozen.** The *current shape* of a system
> lives in its **design note** (`04 Design Docs/`) — that's the one that gets updated, and
> it's the entry point at planning and mid-implementation. Come here for the **why**, or
> when a system has no note yet ([[Planning Workflow — Artifact Gate]] → *Where plans come from*).

| #   | Title                                               | Status   | Date    |
| --- | --------------------------------------------------- | -------- | ------- |
| 020 | [[ADR-020 — System scheduling and task-graph execution]] | Accepted | 2026-09 |
| 019 | [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] | Accepted | 2026-09 |
| 018 | [[ADR-018 — Main and simulation threads, render-owned GL]] | Accepted | 2026-09 |
| 017 | [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] | Accepted | 2026-08 |
| 016 | [[ADR-016 — Serialization (binary primitives & describe-once seam)]] | Accepted | 2026-08 |
| 015 | [[ADR-015 — Threading (sim on main, render thread owns GL)]] | Accepted | 2026-08 |
| 014 | [[ADR-014 — Events (buffered streams) & StringId]]  | Accepted | 2026-08 |
| 013 | [[ADR-013 — Profiler (Tracy-backed instrumentation)]] | Accepted | 2026-08 |
| 012 | [[ADR-012 — Vault repository split]]                | Accepted | 2026-07 |
| 011 | [[ADR-011 — Diagnostics (Logger & Assert)]]         | Accepted | 2026-07 |
| 010 | [[ADR-010 — User authoring model (Systems & Scripts)]] | Proposed | 2026-07 |
| 009 | [[ADR-009 — Branching strategy & merge rules]]      | Accepted | 2026-07 |
| 008 | [[ADR-008 — v2 build & testing baseline]]           | Accepted | 2026-07 |
| 007 | [[ADR-007 — v2 networking & ECS replication foundation]] | Accepted | 2026-07 |
| 006 | [[ADR-006 — v2 core architecture & module layout]]  | Accepted | 2026-07 |
| 005 | [[ADR-005 — v2 tech stack & toolchain]]             | Accepted | 2026-07 |
| 004 | [[ADR-004 — Fresh start (v2) with v1 as reference]] | Accepted | 2026-07 |

> **Active ADRs only.** v2 foundation ADRs get written **after** the deep v1 audit.
>
> [[ADR-001 — Render graph architecture]], [[ADR-002 — Resource system refactor]] and
> [[ADR-003 — Renderer direction (rendergraph vs rewrite)]] describe the **v1 reference
> prototype** and are moved to `_archive v1/` — history/prior art, out of the active list.
> Mine them via [[v1 Code Audit]] and (post-audit) [[Lessons from v1 (reference prototype)]].
> Next number is **021** (numbers are never reused).

### Partial supersessions

A superseding ADR sometimes reverses **one clause** of an Accepted ADR, not the whole
record. The superseded ADR stays **Accepted** and its body is **never edited** — the
partial scope is tracked here.

**Cite the § and the clause, never a line number.** Line refs rot every time an ADR gains a
dated header amendment, and three of the rows below had already drifted by 6 lines before
anyone noticed (2026-08-20).

| Clause | Superseded by | Scope |
| --- | --- | --- |
| ADR-007 §5 — variable tail, simulation alpha and combined FrameContext | [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] | Accepted Sep 10: ADR-019 §1–3: fixed simulation context, no-delta publication, render-owned interpolation. Server-master timing and catch-up remain. |
| ADR-007 §6 — Input → FixedUpdate → Update → PostUpdate → Present as one pipeline; Scene-taking presentation Systems; physics/audio staging example | [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] | Accepted Sep 10: ADR-019 §2: per-tick input/fixed phases and barriers; presentation stages use snapshot data on render. Scene-dependent work stays fixed; no cross-thread phase barrier. |
| ADR-006 §4 — combined frame-context sketch; §5 — presentation Systems operate on live ECS and share its scheduling interface | [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] | Accepted Sep 10: ADR-019 §2: separate simulation/presentation contexts and schedules; presentation operates on snapshots. Replaceable defaults and module boundaries remain. |
| ADR-011 §9 — app publishes the diagnostic stamp once per frame | [[ADR-019 — Fixed simulation ticks, render interpolation and shared clock]] | Accepted Sep 10: ADR-019 §5: primary simulation advances and pushes it once per completed fixed tick. App-owned push and correlation-only meaning remain. |
| [[ADR-015 — Threading (sim on main, render thread owns GL)]] §1 — client and dedicated-server simulation run on main | [[ADR-018 — Main and simulation threads, render-owned GL]] §1 | Accepted Sep 7: main owns window/editor or CLI/control input; simulation has a dedicated thread. GL ownership and phase-barrier rules remain. |
| [[ADR-015 — Threading (sim on main, render thread owns GL)]] §3 — JobSystem exposes only batch submit/wait | [[ADR-018 — Main and simulation threads, render-owned GL]] §4 | Accepted Sep 7: add dedicated-thread creation, registration and diagnostics. Finite-batch execution remains; dedicated handles belong to subsystems. |
| [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] § *Decision* 3 — single loop driver and four-hook restriction | [[ADR-018 — Main and simulation threads, render-owned GL]] §3 | Accepted Sep 7: distinct main and simulation loops under one app-owned lifecycle. App subclasses, composition ownership and manifest rules remain. |
| [[ADR-006 — v2 core architecture & module layout]] §6 — assert **tier** clause (`TE_VERIFY` always-on abort) | [[ADR-011 — Diagnostics (Logger & Assert)]] §5 | **That clause only.** §6's logging bullet, `TE_ASSERT` semantics, the never-silent-`__debugbreak` rule and the `[[unlikely]]`/cold failure path all remain in force. |
| [[ADR-006 — v2 core architecture & module layout]] §5 — the `Profiler` **classification row** (helper *service*, injected via `EngineContext`) | [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §9 | **That row only.** The Profiler is a helper *utility* — global macros, no injection. §5's two-bucket test, the System/helper split, "profiler wraps the executor" and the F19 fix all remain in force. |
| [[ADR-006 — v2 core architecture & module layout]] §4 — the **`EventBus& events` field** of the `EngineContext` sketch | [[ADR-014 — Events (buffered streams) & StringId]] §5 | **That field only.** Event streams are per-`Scene` state. §4's DI rule, context immutability, "holds no systems", F13 ownership and the `app` composition root all remain in force. |
| [[ADR-007 — v2 networking & ECS replication foundation]] §6 — the **"or the `EventBus` service"** phrase of the no-locator bullet | [[ADR-014 — Events (buffered streams) & StringId]] §5 | **That phrase only** — read "via components or event streams". "Never a sibling-system ref" remains in force, strengthened. |
| ADR-007 §6 — five-phase pipeline (`Input → FixedUpdate → Update → PostUpdate → Present`) and `Input` as a separate phase | [[ADR-020 — System scheduling and task-graph execution]] §1 | Accepted Sep 12: ADR-020 §1 collapses to a single `Tick` phase per fixed tick. ADR-019 already removed the variable tail; ADR-020 retires `Input` as a separate concept and the `FixedUpdate` name. System interface, conflict DAG, command buffer and `.after<>()` remain. |
| [[ADR-006 — v2 core architecture & module layout]] §1 — the editor row's **"out of the frame loop"** clause | [[ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)]] § *Decision* 3 | **That clause only.** The editor subclasses `App` like every other executable, so it is in the loop. §1's module table, the strict acyclic DAG, the editor's composition and the editor-owned asset pipeline all remain in force. |

## Statuses

- **Proposed** — under discussion, not yet binding.
- **Accepted** — the current decision. Build to it.
- **Superseded by ADR-NNN** — replaced; kept for history.
- **Deprecated** — no longer relevant.

## Amending an Accepted ADR

*Adopted 2026-08-20 (S3-P1), replacing a blanket "never edit an Accepted ADR" that five of
the eleven active ADRs had already broken.*

An Accepted ADR is a **history, not a claim about the present**. What immutability really
protects against is the **silent** edit, where a value changes and no reader can tell what
it used to be. So the body is appended to, never quietly rewritten, and the gate is **how
much argument the change needs**, not whether a decision moved.

- **Amend in place** when the change fits **one dated header entry**: one clause, one value
  or one term, with the **old value quoted** and the trigger named.
- **Write a superseding ADR** when the change needs its own *Context* and *Alternatives*.
  That is the test. Would you have to **argue** for it, or can you just record it?
- **Never amendable: the headline decision in the title.** ADR-011 dropping spdlog is a new
  ADR, however small the wording change looks.

Cross-ADR reversals are unchanged. A superseding ADR that reverses one clause of another is
rowed in *Partial supersessions* above, and the superseded body is still never edited.

### Mechanism

One entry per amendment, in the header directly under `**Task:**`, oldest first:

```
- **Amended YYYY-MM-DD — <kind>:** <old → new>. <why>. <trigger card>.
```

| Kind | Covers | Also needs |
| --- | --- | --- |
| `vocabulary` | A rename or a repositioning that reverses no decision. | nothing |
| `correction` | The ADR contradicted itself, or stated a fact that turned out false, and nobody would build differently. | nothing |
| `decision` | A clause changed value. | An inline `> **Amended YYYY-MM-DD:**` marker at the point of change, so a reader landing mid-document sees it. |

**When two kinds fit, the stronger wins.** Anything somebody would build differently
against is a `decision`, whatever prompted it.

### What is not an amendment

- **A design note refining a detail the ADR never decided.** A header's folder, a method
  name, a table layout: the note owns those and the ADR stays untouched. This is the common
  case, and [[Planning Workflow — Artifact Gate]] § *An ADR or a design note* is why.
- **Template boilerplate**, which is not decision content.

The mirror case **is** an amendment. If the ADR *did* decide it and a design note now says
otherwise, that is an undeclared `decision` amendment, not a free pass. Left alone, the note
quietly becomes the source of truth and the ADR rots without anyone noticing.
