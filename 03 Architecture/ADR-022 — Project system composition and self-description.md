# ADR-022 — Project system composition and self-description

- **Status:** Accepted
- **Date:** 2026-09 (Accepted 2026-09-26)
- **Deciders:** Miguel (Lead Engineer)
- **Task:** S7-D1 ([[2026-09 Sprint 07 — Scene Events and Input Boundary]])
- **Amended 2026-09-26 — decision:** “the stream and per-reader cursor remain the
  internal delivery primitive” → the executor presents Tick N's immutable event
  batch once to each selected handler during Tick N+1, then discards it after the
  system phase. The fixed schedule makes cursor tracking unnecessary for scheduled
  delivery. Trigger: S7-D1's Tick-only event contract.
- **Partial supersessions:** ADR-014 §2's blanket “no callbacks” clause permits
  scheduled system-local handlers only. ADR-020 §7 and *What would move this* suggest
  a future live enable/disable command; that path is rejected, and the graph remains
  fixed for each simulation session. Both scopes are recorded in [[ADR Index]].
- **Related:** [[ADR-006 — v2 core architecture & module layout]] §4–5 ·
  [[ADR-007 — v2 networking & ECS replication foundation]] §1 §6 ·
  [[ADR-014 — Events (buffered streams) & StringId]] §2–4 ·
  [[ADR-020 — System scheduling and task-graph execution]] §2–4 §7 ·
  [[Task Graph — Execution Flow]] · [[Scene — Design]] · [[Events — Design]]

## Context

`RuntimeApp::configureSimulation` names each demo system and repeats its component access,
priority and slot beside component registration
(`apps/runtime/src/RuntimeApp.cpp:30-36`, engine `742fed7e`). A project system needs a way
to join an app or editor's schedule without adding its declarations to the engine app.
The SDK is still a smoke-tested placeholder (`sdk/include/TechEngine/sdk/ScriptContext.hpp:4-9`);
it supplies no system registration API. This ADR decides the composition boundary; it
does not claim that project loading or a system SDK has shipped.

`ISystem` has `tick` and `name`, but no startup hook
(`engine/core/include/TechEngine/core/systems/ISystem.hpp:9-16`). The graph constructs a
temporary system to obtain its name (`engine/core/src/systems/TaskGraph.cpp:20-25`), then
the executor constructs the lasting instance after graph build
(`engine/core/src/systems/SerialExecutor.cpp:29-35`). The temporary construction only
supplies diagnostic names; per-type static name metadata could do that without creating
an instance. The lasting instance still needs to exist before graph build to declare
its dependencies during startup.

The app must still own composition and the component registry (ADR-006 §4; ADR-007 §1).
The schedule must remain immutable during simulation (ADR-020 §7). The editor may later
choose which systems are enabled before building a schedule. Changing that selection
while simulation runs is prohibited.

## Decision

**The project supplies available systems; the app chooses the active set; each system
describes itself.** A project-facing registration entry point contributes system types
or factories to the app's catalog through a public project-facing boundary. The app
or editor selects entries and owns their instances. The project contribution is
explicit, not a file-scope self-registration side effect. The composition root remains
in `app`; lower modules do not discover or own sibling systems. The exact SDK surface
and module-loading mechanism remain design and implementation work.

Each selected persistent system receives one startup initialization opportunity before
the task graph is built and frozen. Through a constrained registration surface, it
declares component access, event handlers, priority, slot and pairwise ordering. The
same instance later executes ticks. Constructor injection remains the way to provide
services; startup registration is not a service locator. ADR-020's conflict, priority,
terminal-slot and immutable-graph rules are unchanged. This replaces the app-authored
access and ordering arguments in the current `Schedule::add` spelling, not the app's
choice of systems. Graph diagnostics obtain each system's name from registration
metadata, such as a static per-type field; graph construction does not create a
temporary instance for its name.

Event handlers declared there are **scheduled system work**. The executor drains a
reader's visible buffered events and invokes its handlers at that system's slot before
calling `tick`, under the same component access declaration. Publishing never invokes
a handler immediately or creates a publisher-to-reader graph edge. The stream and
per-reader cursor remain the internal delivery primitive. This is a narrow
exception to ADR-014 §2's “no callbacks”: it permits system-local scheduled handlers,
not subscriptions to an immediate event bus. S7-D1 still must settle retention and
deterministic ordering across different event types before implementation.
Event type registration remains composition-root setup under ADR-014 §6; declaring a
handler does not register a new event type.

> **Amended 2026-09-26:** The per-reader cursor requirement above is historical.
> Every selected handler runs on the visible batch in the next Tick before its
> system's `tick`; the batch retires after all scheduled systems finish that phase.
> A failed phase leaves it retained. Cross-type handler order remains for S7-D1.

Component **schema registration is independent of system activation**. The app and
project contribution register built-in and project component types with the app-owned
registry before access declarations are resolved. A system names the components it
requires; it does not exclusively own them or register a second copy. Disabling a
system before a session leaves component types and existing Scene values available to other systems,
serialization and editor inspection. The existing duplicate-tag checks remain errors.

Selecting a different set of systems before simulation builds a different immutable
graph. The active set cannot change during a simulation session. To change it, stop
the session, destroy its executor and graph, select the new set, and build a new graph
before starting another session. Project-code loading and unloading are outside this
decision and cannot bypass that boundary.

## Consequences

- **Benefit:** Project systems can join runtime or editor composition without engine-app
  edits. Their access, handlers and ordering stay with their implementation, while an
  app can select or replace systems between sessions without copying those declarations.
- **Cost:** Startup must construct lasting systems before graph build and validate their
  collected declarations. It needs a project registration boundary and clear ownership
  of factories and code until all corresponding system instances are destroyed. The
  current diagnostic-only temporary construction must be replaced with name metadata.
- **Risk:** A system that hides component writes in a handler could evade scheduling and
  change tracking. Handler work must use the same declared access and validation as
  `tick`; registration must finish before graph construction.
- **Revisit when:** A project integration shows that explicit contribution cannot express
  its system catalog, or construction before graph validation causes costly or unsafe
  partial startup.

## Alternatives considered

- **Keep declarations at the composition call site.** A project module could contribute
  its own `Schedule::add` calls without engine-app edits. This preserves the current
  construction order and keeps one readable schedule, but the module must repeat each
  system's access, handlers and ordering in every composition that uses it. Replacing
  a system can leave stale declarations behind.
- **Use a static per-type description for all graph declarations.** This keeps metadata
  beside the system without constructing instances before graph validation; handlers
  can be bound later. It cannot use instance-specific startup state. Prefer the selected
  instance's startup registration so its actual configuration is the graph's source.
  A static name alone remains suitable for diagnostics.
- **Self-register each system at load through static initialization.** This removes the
  project catalog call, but hides selection and initialization order, and static-library
  translation units can be stripped. It complicates project-code lifetime and editor
  discovery. Explicit project contribution keeps composition visible.
- **Let each enabled system register its own component types.** This looks local, but
  shared types such as `Velocity` acquire multiple registrars, while a disabled system
  may still leave saved component data. Keeping schemas separate avoids tying data
  validity to one system's enabled state.
