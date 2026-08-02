# 🏛️ ADR Index

Architecture Decision Records. Every load-bearing decision gets one. Use
[[ADR Template]] to start a new record. Numbered sequentially, never reused.

> **An ADR is a dated decision + its rationale, frozen.** The *current shape* of a system
> lives in its **design note** (`04 Design Docs/`) — that's the one that gets updated, and
> it's the entry point at planning and mid-implementation. Come here for the **why**, or
> when a system has no note yet ([[Planning Workflow — Artifact Gate]] → *Where plans come from*).

| #   | Title                                               | Status   | Date    |
| --- | --------------------------------------------------- | -------- | ------- |
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
> ADR-001/002/003 describe the **v1 reference prototype** and are moved to
> `_archive v1/` — history/prior art, out of the active list. Mine them via
> [[v1 Code Audit]] and (post-audit) [[Lessons from v1 (reference prototype)]].
> Next number is **015** (numbers are never reused).

### Partial supersessions

A superseding ADR sometimes reverses **one clause** of an Accepted ADR, not the whole
record. The superseded ADR stays **Accepted** and its body is **never edited** — the
partial scope is tracked here.

| Clause | Superseded by | Scope |
| --- | --- | --- |
| [[ADR-006 — v2 core architecture & module layout]] §6 — assert **tier** clause (`TE_VERIFY` always-on abort) | [[ADR-011 — Diagnostics (Logger & Assert)]] §5 | **That clause only.** §6's logging bullet, `TE_ASSERT` semantics, the never-silent-`__debugbreak` rule and the `[[unlikely]]`/cold failure path all remain in force. |
| [[ADR-006 — v2 core architecture & module layout]] §5 — the `Profiler` **classification row** (`:233`, helper *service*, injected via `EngineContext`) | [[ADR-013 — Profiler (Tracy-backed instrumentation)]] §9 | **That row only.** The Profiler is a helper *utility* — global macros, no injection. §5's two-bucket test, the System/helper split, "profiler wraps the executor" and the F19 fix all remain in force. |
| [[ADR-006 — v2 core architecture & module layout]] §4 — the **`EventBus& events` field** of the `EngineContext` sketch (`:186`) | [[ADR-014 — Events (buffered streams) & StringId]] §5 | **That field only.** Event streams are per-`Scene` state. §4's DI rule, context immutability, "holds no systems", F13 ownership and the `app` composition root all remain in force. |
| [[ADR-007 — v2 networking & ECS replication foundation]] §6 — the **"or the `EventBus` service"** phrase of the no-locator bullet (`:216`) | [[ADR-014 — Events (buffered streams) & StringId]] §5 | **That phrase only** — read "via components or event streams". "Never a sibling-system ref" remains in force, strengthened. |

## Statuses

- **Proposed** — under discussion, not yet binding.
- **Accepted** — the current decision. Build to it.
- **Superseded by ADR-NNN** — replaced; kept for history.
- **Deprecated** — no longer relevant.

> ADRs are immutable once Accepted. To change a decision, write a new ADR that
> supersedes the old one — don't edit history.
