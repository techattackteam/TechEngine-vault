# 🧭 Principles

Guardrails for decisions. When a choice is hard, these break the tie. Product principles decide
*what* gets built; engineering principles decide *how*. Process rules (cadence, card sizing,
who writes the code) live in [[Dashboard]] § *Rhythm*, [[Planning Workflow - Artifact Gate]]
and [[Technical Lead Charter]].

## Product principles (2026-10-23)

- **P1 · The reference game decides.** A capability [[Reference Game|TechAttack]] does not need
  is not built yet, however interesting. The [[Capability Map]] is where that is written down.
- **P2 · Built the way users build.** TechAttack is made only through the public SDK and the
  editor. Game rules never live in the engine, and a gap the game hits is fixed in the engine for
  everyone.
- **P3 · What before how.** A system's capability brief comes before its first ADR. An ADR with
  no requirements is decided by taste.
- **P4 · Show it, or it is not done.** Every Phase 1 goal ends in a showcase a developer can
  watch ([[Channel]]). Something that cannot be shown is not a goal yet.
- **P5 · General in shape, narrow in scope.** Build an engine feature in its general form when
  that costs the same, but only to the scope the reference game needs. The engine widens to
  general-purpose 3D later, from a base that already works.

## Engineering principles

1. **Decide once, write it down.** Load-bearing decisions get an [[ADR Index|ADR]]. If it is
   not written, it is not decided.
2. **Refactor by default, rewrite only with evidence.** A rewrite must be justified by
   concrete, documented pain, not by "it feels messy".
3. **Design before code, whoever writes it.** Miguel's cards and Claude's features alike start
   from an agreed design or a written one; the highest leverage is in the design, not in typing
   faster.
4. **Explicit over implicit.** The render graph, resource lifetimes and system ordering are
   visible and inspectable, not emergent side effects.
5. **Done means documented.** Every feature ends in a doc update: the design note or ADR it
   touched describes what shipped.
6. **Sustainable pace wins.** The plan is measured in years. Protect rest, karting and the day
   job; burnout ends the project faster than any bug.

See also: [[Vision]] · [[Reference Game]]
