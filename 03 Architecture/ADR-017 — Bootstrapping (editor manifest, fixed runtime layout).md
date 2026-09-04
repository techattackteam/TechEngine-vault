# ADR-017 — Bootstrapping (editor manifest, fixed runtime layout)

- **Status:** Accepted
- **Date:** 2026-08 (Accepted 2026-08-31)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Related:** [[ADR-006 — v2 core architecture & module layout]] §1 (module and executable
  graph, the baked-only runtime rule) · §4 (composition root, one per exe) ·
  [[ADR-008 — v2 build & testing baseline]] §6 (per-module test exes) ·
  [[ADR-015 — Threading (sim on main, render thread owns GL)]] §2 (what `update()` may not do) ·
  living *how*: [[Project — Design]] · [[File Access — Design]]
- **Partially supersedes:** [[ADR-006 — v2 core architecture & module layout]] §1, the editor
  row's "out of the frame loop" clause. Rowed in [[ADR Index]].
- **Task:** S5-D1 ([[2026-08 Sprint 05 — M3 Project & M4 Window]]). Gates S5-T4 and S5-T5.
- **Amended 2026-09-04 — citations and a stale consequence:** § *Context*'s `App.cpp:95` is
  anchored at `76056402`, the engine tip when it was written; #63 cut the file to 55 lines and
  #65 deleted the mount. § *Consequences*' last bullet said S5-T5's `done:` clause "needs
  rewording before that card starts"; it was reworded on 2026-08-31 and 2026-09-04, and the
  card closed on 2026-09-04 (#71). No decision moved.

## Context

M3 exists to delete the demo mount. `App.cpp:95` at `76056402` mounts one alias from `TE_DEMO_ASSETS_DIR`, a
source-tree path baked in at configure time under a `TODO(S3-T13)`, which resolves to nothing
in an installed build. The real mount set has to come from somewhere.

v1 answered it once, for everybody: a `ProjectManager` in the editor loaded a `.teproj`
manifest and mounted from it. Being editor-only, it left the shipped runtime unable to load an
asset ([[v1 Code Audit]] **F30**). [[File Access — Design]] already fixed the file-access half
by putting `FileAccess` in `platform`.

**The project half is not the same question.** F30 was a missing implementation. This is
whether the two executable families should share a bootstrap at all. An editor opens an
arbitrary directory a user picked and must be told where its content is. A shipped game
arrives with its content already laid out beside the binary, because the editor put it there.

There is no seam to hang either answer on yet. Both `main()` files are identical four-line
stubs and `run()` takes no arguments (`App.hpp:4`). ADR-006 §4 says the composition root is
"one per exe", and one shared no-argument `run()` is not that.

## Decision

**1. The project manifest is editor-only.** `project.toml` is authoring data, and authoring
is the editor's job. A runtime or a dedicated server never reads one. It mounts a fixed layout
relative to `platform::executablePath()`, which the editor's export step produces. This is the
same seam as ADR-006 §1's rule that the runtime consumes only baked binary.

**2. `Project` is exe-local editor code**, in `apps/editor/src/project/`, not a library. No
`tooling` tier is created to hold it. ADR-006 §1's executable table names `tooling` in the
editor's composition without ever defining it as one, and that stays undecided here.

**3. `app` owns the lifecycle through a base class, and every executable subclasses it.**
`App` owns `MountTable`, `FileAccess`, `Clock`, `JobSystem` and the `FrameLoop`, and calls four
virtuals: `init`, `fixedUpdate`, `update` and `shutdown`. Only `init()` is pure, because it is
where an executable states its mount set and none is correct without doing so. `main()` lives
in a header included once per executable, never in the `app` library.

The editor's `init()` therefore holds the real `FileAccess`. It mounts `project`, reads the
manifest, and mounts what that names, all into the one table that already exists.

**Three constraints, each closing a specific v1 failure.** v1 ran three dispatch mechanisms in
parallel: a stored `std::function` walked by `Application::run()` (`Application.cpp:4-8`),
`update`/`fixedUpdate` virtuals the base class never called, and `Entry::run(onFixedUpdate,
onUpdate)` a layer below (`Entry.hpp:17`).

- The virtuals are the **only** dispatch. No `std::function` member, no second loop driver.
- The virtuals **take** `const FrameContext&`. v1's took nothing, which is exactly why state
  needed the `Entry` layer to reach them.
- `update()` produces a render command list and issues **no GL call** (ADR-015 §2).

**This reverses ADR-006 §1's editor row**, which puts the editor "out of the frame loop". The
editor is a subclass like the others. Rowed in [[ADR Index]] § *Partial supersessions*.

The signatures, the `init()` sequence and the manifest schema are [[Project — Design]]'s.

## Consequences

**Positive**

- `app` stays free of `Project`, so ADR-006 §1's dependency DAG is untouched and the editor's
  concepts do not reach the simulation library.
- ADR-006 §4's "one composition root per exe" becomes literal. Each subclass **is** that root.
- **One `MountTable` ever.** `init()` runs inside the object that owns it, so the editor reads
  its manifest through the same `FileAccess` the engine will use.
- The shipped runtime carries no toml++ code path, and ships no manifest a player can edit.
- A `runtime-server` is then a subclass with an empty `update()`, which is the headless
  composition ADR-006 §2 wants.

**Negative / open**

- **`main()` in a header must be included exactly once per executable**, and the `app` library
  must not carry one. `techengine_test(app …)` links `Catch2::Catch2WithMain`, so a `main()`
  inside the library gives `TechEngineAppTests` two of them.
- **The editor moves into the frame loop**, reversing ADR-006 §1. That clause fixes
  [[v1 Code Audit]] **F14**, where editor systems and `client.tick` ran sequentially on one
  thread so a script build froze the render (`Editor.cpp:134-144`). Reversing it is safe
  because §1 predates ADR-015: the render thread consumes the last complete command list, so a stalled main thread no longer freezes presentation. What is left of F14 is heavy editor work
  delaying **sim ticks**, and the audit's own fix for that is off-thread tasks, not loop
  position. **The cost is that this becomes discipline rather than structure**, so heavy editor
  work must go to the `JobSystem` and play-mode stepping must be explicit.
- **ADR-008 §6 gains a case it never covered: tests for an executable.** An exe is not
  linkable without `ENABLE_EXPORTS`, so each app compiles into an **OBJECT library** its exe
  and its test exe both consume. That produces no archive and can be nobody's link dependency,
  so the exe stays §1's leaf. A `techengine_app()` helper stamps the three targets and appends
  to `TE_TEST_TARGETS`. Mechanism in [[Project — Design]] § *Where the type lives*.
- **Two bootstrap paths diverge.** A mount bug that reproduces in the editor may not reproduce
  in the runtime, and the reverse. Nothing tests the runtime path until `projects/dev/` ships.
- **S5-T5's `done:` clause contradicted clause 1** when this was accepted: it read "the
  runtime loads it by default". Reworded 2026-08-31. The card closed 2026-09-04 (#71) with
  the runtime half deferred to M6 by [[Project — Design]] § *Open questions*.

## Alternatives considered

| Option | Why not |
|---|---|
| **The runtime reads the manifest too** | One code path and no divergence, and a shipped game could be re-pointed at other content without a rebuild. It costs the boundary: `Project` moves to `core`, every runtime links toml++, and an editable manifest ships beside the game. It also contradicts ADR-006 §1's baked-only rule. The merit is real, so take it if the divergence above actually bites. |
| **`run(std::span<const MountSpec>)`** | Each `main()` computes its mount set as plain data and `run()` applies it. No base class, and the set can be logged before it is applied. It fails on the manifest: reading `project.toml` needs a `FileAccess` and `run()` owns the only one, so the editor would build a throwaway `MountTable` and mount `project` twice across two tables. |
| **A mount callback into `run()`** | `run(const MountFn&)` reaches the same place with a lambda and no base class. It carries no state between the mount step and the loop, so whatever the editor loads at startup has nowhere to live. A subclass gives that for free. |
| **A `tooling` static library** | Fills the tier ADR-006 §1's executable table already names, and earns `Project` a real test target through `techengine_test()`. It is also where M6's asset pipeline has to land. Deferred, not rejected: defining a module tier for one type is scope M3 does not need, and the move is a file move plus a CMake edit. |
| **Keep the configure-time define** | `TE_DEMO_ASSETS_DIR` is the thing M3 exists to delete. A source-tree path means nothing in an installed build, which is why it already carries a `TODO`. |

## What would move this decision

- **A dedicated server that must be re-pointed at content without a rebuild.** That is the
  strongest case for the manifest reaching the runtime, and netcode is when it stops being
  hypothetical. It flips clause 1.
- **A mount bug that reproduces in one executable and not the other.** Two bootstrap paths is
  the price being paid here. One such bug is evidence the price was too high.
- **Editor code another executable needs.** An object library is nobody's dependency by
  design. The first type the runtime also wants is the signal that ADR-006 §1's undefined
  `tooling` tier is the real answer, and clause 2 flips. M6's asset pipeline is the candidate.
- **An editor task that stalls a sim tick.** That is F14 returning through the discipline this
  ADR substitutes for structure, and it means the work belongs on the `JobSystem`.
- **A fifth lifecycle virtual.** Four is a deliberate trim of v1's seven, where `init`/`start`
  and `stop`/`shutdown` were never distinguished. The first hook that fits none of the four
  says the lifecycle was modelled wrong, not that it needs another entry.

> Add to [[ADR Index]]. Once Accepted, change it only per [[ADR Index]] § *Amending an
> Accepted ADR*: a dated header entry for what fits one, a superseding ADR for what needs its
> own argument.
