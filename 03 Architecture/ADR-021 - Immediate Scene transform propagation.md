# ADR-021: Immediate Scene transform propagation

- **Status:** Accepted
- **Date:** 2026-09-18
- **Deciders:** Miguel (Lead Engineer)
- **Task:** S6-T5
- **Partial supersessions:** ADR-020 §1's next-tick hierarchy propagation and §3/§5's separate `TransformPropagation` schedule entry. Tick, barrier and access-order rules remain.
- **Amended 2026-11-14, decision:** "If the conversion requires shear that local TRS cannot
  represent, the edit fails without changing the local value or world cache" → the edit is
  accepted with the closest local TRS, as Unity does. Trigger: S10-B3, after a drop under a
  rotated, non-uniformly scaled parent moved nothing in the editor (S10-T1, Nov 1).

## Context

A system can edit a parent Transform and then use a child's world transform in the
same tick. A propagation pass after all writers would leave that child stale at the
point of use. S6-T5's direct component setters and hierarchy are in
`engine/core/src/scene/Transform.cpp:13` and `Scene.cpp:177` on the `S6-T5/Transform`
worktree based on `c3674c6a`.

## Decision

An accepted local or world edit synchronously refreshes the edited entity and its
descendants before the setter returns. A world edit first converts the requested
world TRS to local TRS using the current parent chain. If the conversion requires
shear that local TRS cannot represent, the edit fails without changing the local
value or world cache.

> **Amended 2026-11-14 (S10-B3):** a conversion that needs shear is accepted. The entity keeps
> its world position exactly, and its local rotation and scale are the closest a local TRS can
> hold, so its world matrix picks up the parent's shear and its world rotation and scale move.
> No bound limits how far they move. A zero scale axis is still refused, in the parent chain or
> in the result, because no local scale can undo it. A world edit, a `PreserveWorld` reparent and
> a `PreserveWorld` detach share the rule. [[Scene - Design]] holds the mechanism.

Scene traverses the affected subtree parent-first. Each exact world matrix is
computed from its parent's matrix and its local TRS. The world TRS cache remains
an approximation when the matrix contains shear. Hierarchy changes refresh the
moved subtree when committed; post-Tick barrier changes are therefore ready for
the next Tick. No separate propagation system is scheduled.

`Write<Transform>` includes the Scene's internal hierarchy traversal. Hierarchy
topology changes only at the single-threaded structural barrier during execution,
so this read does not introduce a concurrent hierarchy writer. S6-T9 must account
for the implicit read in access validation without exposing writable hierarchy links.

## Consequences

- **Benefit:** A system may edit a parent and immediately read or edit a descendant
  using current world values. Snapshot extraction sees completed values.
- **Cost:** Repeated edits to ancestors in one tick can recalculate the same
  descendants. Profile this before adding batching or dirty tracking.
- **Cost:** The bound runtime Transform contains process-local owner data. It cannot
  be opted into ADR-007's raw replicated-column path; replication must extract
  portable local values or revisit the binding.
- **Revisit when:** Profiling shows repeated subtree updates are material, or the
  replication implementation needs Transform itself to be a raw replicated column.

## Alternatives considered

- A scheduled pass after local writers leaves interleaved parent/child operations
  stale unless another pass is inserted at every dependency boundary.
- Updating direct children without continuing to their children leaves deeper
  descendants stale.
- Calculating world transforms on every read avoids eager descendant work, but
  changes the current direct `Transform::getWorld()` cache contract and makes
  world reads traverse ancestry.
