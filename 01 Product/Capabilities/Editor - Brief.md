# Editor: Brief

**Map:** [[Capability Map]] § *Editor*
**Goals:** E1 (T1, T2); viewport tools alongside E2 (T3); terrain tools alongside E6 (T7); play in
the editor alongside E11 (T6); the project launcher with packaging (T5).
**Status:** agreed (2026-10-25)
**Feeds:** the editor ADR (S9-D2) and `Editor - Design` (S9-D3).

## Who uses it

- **Players:** nobody. The editor never ships to players.
- **Developers:** in E1, only Miguel. Viewers do not get a build. Later, the developers who
  follow the channel, once builds go out with T5 packaging.

## Scenarios

1. Miguel opens the editor on `projects/dev`, and the startup scene appears in the hierarchy.
2. He creates entities, nests one under another, deletes one, adds a component, and edits a
   field in the inspector.
3. The title shows unsaved changes. He saves. Closing with unsaved edits asks first.
4. He exports, starts `runtime.exe` from the export folder by hand, and the runtime's log names
   the entities and values he edited.
5. He relaunches the editor. The panels are where he left them, and the saved scene is open.

## Requirements

| | Requirement | Why |
|---|---|---|
| **Must, E1** | The hierarchy creates, deletes and reparents entities. | Scenario 2 |
| **Must, E1** | The inspector adds and removes components and edits their fields. | Scenario 2 |
| **Must, E1** | Every entity has a name. The hierarchy shows it, the inspector renames it, it is saved with the scene, and the runtime's log prints it. Names need not be unique. | Scenarios 1, 2 and 4; `/triage`, 2026-10-26 |
| **Must, E1** | A placeholder scene view. It does not draw the scene. | No renderer until E2 |
| **Must, E1** | Save, with an unsaved marker in the title and a prompt on close. | Scenario 3 |
| **Must, E1** | Export, then the runtime is started by hand. Its log naming the edited entities and values is the proof. | Scenario 4 |
| **Must, E1** | The panel layout is remembered between launches, in a file inside the project that git ignores, so each user keeps their own and can reuse it in other projects. | Scenario 5; a must for Miguel's development |
| **Must, demo** | The map's § *Editor* demo row, unchanged: edit scenes, play and return, terrain tools, an asset browser with import, a visual game UI designer. | [[Capability Map]], 2026-10-23 |
| **Should** | A Run button that starts the runtime from the editor. A console and cvars. A Profiler panel. | Cut first if E1 runs long |
| **Won't, for now** | A public video of E1. A build for viewers. | E1 is an internal demo; showcases are cinematic |
| **Won't, for now** | A project launcher. | Returns with T5 packaging |
| **Won't, for now** | More than one scene, and reopening the last one. | Returns after R1 |
| **Won't, for now** | Play in the editor. | Alongside E11 (T6); E1 runs stopped only |
| **Won't, for now** | Undo. Edits must become undoable later, so E1's edit path must allow it. | Returns after R1 |
| **Won't, for now** | Syncing the layout to an account over the cloud. | Ideal, but overkill for now |
| **Won't, for now** | A scene view that draws the scene, picking and gizmos. | E2 (R1, T3) |

## Numbers

| Budget | Value |
|---|---|
| Scene size | The hierarchy and inspector stay smooth at 60 fps with 1,000 entities. |

## What developers will expect

From memory, not checked against current docs:

- **Undo (Ctrl+Z):** all three engines have it. Left out of E1 on purpose, and planned.
- **An unsaved-changes prompt and a remembered layout:** all three have them. E1 meets both.
- **A project launcher** (Unity Hub, Godot's Project Manager): left out until T5.
- **Play mode:** all three have it. It comes alongside E11.
- **Picking and gizmos in the scene view:** standard everywhere. They come with E2 (T3).

## Depends on and constrains

- **Leans on:** M6's scene load through the cache, and S9-T6 for reopening the saved startup
  scene. ImGui is the editor's only UI ([[Roadmap]] § *Guardrails*). The launcher's place is
  already decided: inside the editor executable ([[Project - Design]], 2026-09-03).
- **Leans on, open:** where the runtime finds the export folder ([[Resources - Design]] §
  *Open questions*, owner T2). Starting the runtime by hand depends on it.
- **Constrains S9-D2:** the edit path must allow undo later; the editor runs stopped only; the
  panels must hold 1,000 entities at 60 fps; the layout lives in a git-ignored file inside the
  project. That answers [[Project - Design]] § *Open questions*' per-user settings for the
  layout only; the launcher's known-project list is not in a project and stays open.

## Open questions

Owed to `/product-review`, because they change notes a brief does not own. Until then, E1's
Definition of Done in the [[Roadmap]] still names a showcase.

- **E1 has no public video**, which contradicts [[Principles]] P4, [[Channel]] § *How a video
  fits the plan* and the [[Roadmap]]'s E1 row.
- **Showcases are cinematic**, not live footage of editing. [[Channel]] does not say so yet, and
  nothing on the [[Capability Map]] covers what a cinematic needs from the engine. That is a
  `/triage` before any design.
- **The rung after R1** that brings back more than one scene, reopening the last one, and undo
  is not in the [[Roadmap]]'s rung catalogue yet.

## Decided

| Question | Answer | Date |
|---|---|---|
| E1's scope | One project and one scene. The editor runs stopped only. Play stays alongside E11. | 2026-10-25 |
| Launcher, more than one scene, reopening the last one | Won't for E1. | 2026-10-25 |
| Console and cvars, Profiler panel | Should. | 2026-10-25 |
| Who uses the E1 editor | Only Miguel. Viewers watch; nobody else gets a build before the demo. | 2026-10-25 |
| What editing E1 shows | Create and delete entities, reparent them, add and remove components, edit component fields. | 2026-10-25 |
| What proves the scene reached the runtime | The scene view is a placeholder and the runtime still draws the fixed triangle. The runtime's log naming the edited entities is the proof. | 2026-10-25 |
| Undo | Not in E1, but edits must become undoable later, and S9-D2 designs the edit path for it. | 2026-10-25 |
| How the runtime starts after export | By hand from the export folder. A Run button is a Should. | 2026-10-25 |
| Scene size | The hierarchy and inspector stay smooth at 60 fps with 1,000 entities. | 2026-10-25 |
| Closing with unsaved edits | The title shows unsaved changes, and closing asks whether to save. | 2026-10-25 |
| When the launcher comes back | With T5 packaging. Until then the editor opens `projects/dev`. | 2026-10-25 |
| E1's video | E1 is too early for a YouTube video. It ends in an internal demo, and nothing is promised about when the editor first appears on the channel. | 2026-10-25 |
| Where that change is recorded | This brief and the map now. P4, the Channel note and the Roadmap row are owed to `/product-review`. | 2026-10-25 |
| Panel layout | Remembered between launches, as a Must. | 2026-10-25 |
| Where the layout is stored | In the project, in a file git ignores. Each user can customize it, save that file and reuse it in other projects. Syncing it to an account over the cloud would be ideal, but is overkill for now. | 2026-10-25 |
| The layout Must against P1 | It is a must for Miguel's development. | 2026-10-25 |
| When more than one scene, reopening the last one and undo come back | After the first phase of the renderer (R1) is done, possibly as a rung between T2 and T3. | 2026-10-25 |
| Why E1 has no video | Showcases are meant to be professional, higher-quality cinematic videos, not generic ones or live footage of editing, and E1 has nothing good enough to show that way. | 2026-10-25 |
| Entity names | A Must for E1, through `/triage`: names are shown, edited, saved and logged by the runtime. Looking an entity up by name from gameplay is not part of it. | 2026-10-26 |
| A persistent id per entity, as v1's `Tag` had | Not a product capability. [[ADR-007 - v2 networking & ECS replication foundation]] §1 already decides it: an opt-in component for entities referenced across documents, revisited when prefabs arrive. | 2026-10-26 |
