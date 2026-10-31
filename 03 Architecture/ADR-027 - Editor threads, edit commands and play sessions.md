# ADR-027: Editor threads, edit commands and play sessions

- **Status:** Accepted
- **Date:** 2026-10 (Accepted 2026-10-25)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** S9-D2, the editor ADR that E1's panels (T1) are built on.
- **Amended 2026-10-31, decision:** §1's "the extra frames ImGui needs come from posted wakes" →
  **main asks for its own extra frames with a flag, and only other threads post a wake.** A
  posted wake from main to itself was a GLFW empty event whose only effect was to make the next
  wait return, so main now polls once instead of waiting. "Never from a periodic timer" stands:
  with no input, main still sleeps until another thread wakes it. #177 (`4ba9f60`, S9-T21);
  [[Editor - Design]] § *The ImGui frame on main*.
- **Related:** [[Editor - Brief]] · [[Editor - Research Brief]] ·
  [[ADR-015 - Threading (sim on main, render thread owns GL)]] §2 ·
  [[ADR-018 - Main and simulation threads, render-owned GL]] §1-2 ·
  [[ADR-019 - Fixed simulation ticks, render interpolation and shared clock]] §5 ·
  [[ADR-022 - Project system composition and self-description]] ·
  [[ADR-026 - Reference fields and scene-held acquires]] §1 §4 · living *how*: [[Editor - Design]]

## Context

[[Editor - Brief]] asks E1 for an ImGui editor that edits the hierarchy and component fields,
saves with an unsaved marker and remembers its layout. Edits must become undoable later, the
panels stay smooth at 1,000 entities, and E1 runs stopped only, with Play alongside E11.

The threads are already decided: main owns editor interaction, the simulation thread owns the
`Scene`, edits cross as data, main reads only published results (ADR-018 §1-2), and only render
issues GL (ADR-015 §2). None of that says where ImGui runs, how panels see a `Scene` they may
not touch, or what "stopped" means.

Checked at engine `5cc9ed8c`. The simulation loop ticks from startup until stop, with no idle
state (`engine/app/src/SimulationThread.cpp:188-199`). No edit command admission exists in
`engine/app`; [[Simulation Thread - Design]] § *Input and control handoffs* designs it but
nothing builds it. The executor ticks the one `App::m_scene` (`engine/app/src/App.cpp:124`).
Render reads one single-slot mailbox fed by the simulation (`engine/client/src/render/SnapshotMailbox.cpp:4-16`).
ImGui is not a dependency yet (`apps/editor/CMakeLists.txt:27`).

**The baseline**, from [[Editor - Research Brief]]; *memory* marks what it did not read.

- **Unity:** editor UI and the scene share the main thread *(memory)*. Inspector edits record
  undo, then write the live object. Play backs the scenes up and reverts them on exit.
- **Unreal:** Slate builds draw elements on the game thread and the render thread draws them
  from a buffer. `FScopedTransaction` and `Modify()` record undo and dirty the package. Play
  In Editor ticks a duplicated world, so the edited world is untouched.
- **Godot:** UI and scene share one tree on the main thread, and its editor forces rendering
  onto main. Undo actions carry explicit do and undo values; Play is a separate process.
- **None** puts editor UI and the edited world on different threads, so none answers how
  panels read a `Scene` owned by another thread. TechEngine has to, because of ADR-018.

## Decision

### 1. One window: main builds the ImGui frame, render draws it

ImGui uses the docking branch and draws into the client's one window. The main thread runs
ImGui's frame, because GLFW delivers events and creates windows only there and ImGui's GLFW
backend reads input there. The render thread draws the result after the scene, because it
holds the only GL context.

The frame crosses in its own channel beside the simulation's mailbox, not through it: it has a
different producer and rate. Draw data may skip a frame, newest wins, as ADR-018 §2 allows.
Texture requests may not skip, so they cross in order and are never dropped. `client` gains a
render-thread overlay seam that the editor fills and the runtime leaves empty, so `client` and
the runtime never link ImGui. The editor executable links ImGui's GLFW backend; `client`
still never calls GLFW.

Main stays event-driven (ADR-019 §5): it builds a frame on each wake, and the extra frames
ImGui needs come from posted wakes, never from a periodic timer.

> **Amended 2026-10-31:** main asks for its own extra frames with a flag that makes the next
> update poll, and only other threads post a wake. See the header entry.

Multi-viewport is off in E1. The channel carries one draw snapshot per viewport and render
owns every context, so enabling it later adds window glue and a flag, not a redesign.

### 2. Panels read a published editor view, never the live `Scene`

After it changes the `Scene`, the simulation thread publishes a copy of what the panels show:
the hierarchy in tree order, the selected entity's components, and an edit revision. Main draws
every panel from the newest copy. Collapsing a branch is main's own UI state. This is ADR-018
§2's "published results", applied to the editor; ADR-024 §6's fence governs cache entries and
is not used for the `Scene`.

### 3. Every edit is a command the simulation thread applies

A panel never mutates; it sends a command through the bounded, never-dropping admission that
[[Simulation Thread - Design]] already designs. The simulation applies each batch as a loading
phase (ADR-026 §4), records each target's old value as it applies, and raises the edit revision.
Undo is therefore a later command built from those records, with no change to the edit path.
The title's unsaved marker compares the published revision with the last saved one.

### 4. Stopped, Playing and Paused are editor states

Only Playing ticks. Stopped edits the real scene; Paused edits the play session, and both keep
the simulation thread alive and idle, woken by a command or by stop. The runtime has none of
these states and keeps ticking from startup until it quits. E1 builds Stopped only.

### 5. Play ticks a copy; Stop discards it

There is one live scene at any moment. Play copies the edit scene, makes the copy the live
scene and parks the original, which nothing ticks, edits or draws. Stop destroys the copy and
makes the original live again, exactly as it was. The copy is made with the scene save and read
that already exist. It acquires nothing: it uses the handles that the edit scene's entry holds
(ADR-026 §1), and it never outlives that entry.

A play session is an ADR-022 simulation session. Play builds the executor, graph and fresh
system instances; Stop destroys them, which resets every system's state with the scene.

Handles taken before Play belong to the parked original and are valid again after Stop, so
nothing is remapped. While Playing, no handle taken before Play is used on the live copy, so
the undo history from before Play is frozen until Stop.

E11 builds this. E1 keeps to §2 and §3 and holds its undo records and selection in one place
that Play can freeze and move, so Play adds code without rewriting the edit path.

### 6. The layout lives in the project, per user

The layout file is `<project>/editorSettings/layout.ini`. The `editorSettings/` folder is
git-ignored and holds only per-user editor settings, so later ones join it; a setting the team
shares belongs somewhere committed. ImGui does not write the file on its own; the editor saves
it through file access when ImGui asks.

## Consequences

- **Benefit:** the editor and the runtime share every thread and every hook; the editor adds
  a channel, an overlay and commands. Main never stalls the simulation, now or once Play ticks.
- **Benefit:** undo, the unsaved marker and Play's revert all come from one rule, that every
  edit is a command applied by the owner. Play cannot damage the edit scene.
- **Cost:** a published copy and a command hop for each edit, about one frame of latency, which
  ImGui's own widget state hides while you type. The view is published only after a change.
- **Cost:** E1 builds the command admission and the idle simulation state, which nothing has
  needed until now. Play holds two scenes in memory while it runs.
- **Risk:** an asset acquired by a Paused edit stays held by the scene entry after Stop, until
  the next reload (ADR-026's cost, widened).
- **Risk:** threaded draw data with texture requests is newer ImGui ground; the research found
  one crash it caused before the queue existed.

## Alternatives considered

| Option | Why not |
|---|---|
| **UI on the simulation thread in edit mode** (the three engines' shape) | It saves the copy and the queue, but reverses ADR-018 §1-2, and once Play ticks, a slow tick freezes the editor. |
| **Main reads the live `Scene` behind a fence** | No copy code, and stopped means it rarely waits. It contradicts ADR-018 §2, and during Play every frame would stall the ticks. |
| **ImGui in its own window** | It needs a second context from day one for no requirement. |
| **A hand-written platform backend over `Window`** | It keeps GLFW out of the editor, but every viewport callback becomes ours to write. |
| **Play by save and restore** (Unity's shape) | One scene object, but the restore clears the `Scene`, which kills every editor handle by design, so undo and selection would need a remap at each Stop. |
| **Play in a separate process** (Godot's shape) | It is not play in the editor: the game would get its own window. |

## What would move this

- **A measured edit latency** that ImGui cannot hide, such as a slider drag at 1,000 entities.
  That points to sending only changed rows, or to a fence while Stopped.
- **The threaded draw path failing**, as Godot's separate render thread does for its own
  editor. That would move the editor's rendering onto main and amend ADR-015 §2 for it.
- **Play's copy measured too slow or too large** at TechAttack's scene size, which reopens save
  and restore with a remap.
- **A second consumer of GLFW outside `platform`**, beyond ImGui's backend, which would move the
  backend into `platform` instead.
