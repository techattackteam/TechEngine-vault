# ADR-003 — Renderer direction (finish render graph vs rewrite)

- **Status:** Superseded by [[ADR-004 — Fresh start (v2) with v1 as reference]]
- **Date:** 2026-07
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead

> **Resolved by the fresh-start decision.** The question "finish the v1 migration
> vs rewrite the renderer" is moot: v1 is now a reference prototype and the
> renderer will be **designed fresh in v2**. The v1 render-graph work (`graph/` +
> `passes/`) becomes prior art to mine — see [[Lessons from v1 (reference prototype)]].
> A future ADR will capture the v2 renderer design.


## Context

The render graph ([[ADR-001 — Render graph architecture]]) is partway migrated:
`graph/` and `passes/` exist but are untracked WIP, and old renderer paths still
exist alongside. Separately, there's an open question of whether the renderer —
or even the whole engine core — warrants a **ground-up rewrite** now that a
proper planning process is in place.

This draft captured the v1 alternatives before ADR-004 superseded the question.

## Options on the table

1. **Finish the migration** — move all remaining rendering onto the render graph,
   delete old paths, stabilize. Lowest risk, keeps momentum.
2. **Rewrite the renderer** on top of the current core — new abstractions
   (e.g. declared resource edges / frame graph) but reuse ECS, resources, scene.
3. **Rewrite the engine** — core + renderer together under the new architecture.
   Highest risk; must clear a high evidence bar (see [[Principles]] #2).

## Decision criteria considered

- Where is the *actual* pain (measured, not vibes)?
- What % of each subsystem would survive a rewrite unchanged?
- Cost to finish migration vs cost to rewrite, in coding sessions.
- Risk to the "years-long sustainable pace" — a stalled rewrite is the failure mode.

## Decision

No choice among the three v1 options was made. ADR-004 chose a fresh v2 start with
v1 as reference, superseding this question before this draft was completed.

## Consequences

The unfinished v1 render-graph migration remains prior art. The v2 renderer needs
its own design decision when its roadmap rung begins.
