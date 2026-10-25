---
tags: [research]
status: report
---

# Editor: Research Brief

The research report for S9-D2, the editor ADR ([[2026-10 Sprint 09 - Close M6]] § *Story C*).
Card S9-P1, written unattended on Oct 25, 2026. **It compares; it does not choose or recommend.**
Every decision below is Miguel's, in S9-D2.

It compares how Unity, Unreal and Godot run their editor UI beside the simulation and the
renderer, and how a Dear ImGui editor hands its draw data to a render thread that owns GL. Each
finding is then mapped onto [[ADR-018 - Main and simulation threads, render-owned GL]],
[[Window - Design]] § *The frame command buffer*, [[Editor - Brief]] and the four questions in
S9-D2's `done:` clause.

**How to read the sources.** Every claim names its source in the *Sources* table at the end, by
tag (for example **[G1]**). A claim marked **(memory)** comes from what I knew before this run
and was not checked against a source today. A claim marked **(inference)** is my own reading of
two sourced facts together. Unity's, Epic's and Godot's documentation sites could not be reached
from the sandbox, so the Unity and Unreal claims rest on search-result extracts of their
official pages, not on full reads. The Godot and ImGui claims were read in source, at the commits
in the *Sources* table. Engine code is cited at engine `5cc9ed8`.

## The questions this report answers

S9-D2's `done:` clause names four questions, and [[Editor - Brief]] § *Depends on and
constrains* adds the constraints listed after them.

| # | Question | Where it is open |
|---|---|---|
| Q1 | Does ImGui share the window, and which thread draws it? | ADR-015 § *Consequences*; [[Window - Design]] § *Open questions* |
| Q2 | How do panels read the `Scene`: published copies, or main's fence? | ADR-024 §6 |
| Q3 | How does an edit reach the simulation thread? | ADR-018 §2; [[Simulation Thread - Design]] § *Input and control handoffs* |
| Q4 | What is the stopped state? | [[Resources - Design]] § *Open questions* |
| C1 | The edit path must allow undo later. | [[Editor - Brief]], Decided "Undo" |
| C2 | The hierarchy and inspector stay smooth at 60 fps with 1,000 entities. | [[Editor - Brief]] § *Numbers* |
| C3 | The panel layout lives in a git-ignored file inside the project. | [[Editor - Brief]], Decided "Where the layout is stored" |
| C4 | Save shows an unsaved marker and prompts on close. | [[Editor - Brief]] § *Requirements* |

## Unity

| Topic | Finding | Source |
|---|---|---|
| Render thread | The editor picks its rendering threading mode once, at startup, from Player Settings and the platform. In *Direct* mode the main thread renders. In *MultiThreaded* mode the main thread produces intermediate graphics commands and the render thread turns them into API calls. | [U1] |
| Editor UI thread | Editor UI (IMGUI `OnGUI` and UI Toolkit) and editor scripts run on the main thread, the same thread that owns the scene. | (memory) |
| Edit mode | With `ExecuteInEditMode`, `Update` is called only when something in the scene changed, not every frame. `EditorApplication.update` is the usual way to run regular editor code. | [U2] |
| Inspector edits | Edits through `SerializedProperty` stay pending until `SerializedObject.ApplyModifiedProperties`, which first records undo, then syncs each target object. `ApplyModifiedPropertiesWithoutUndo` skips the record. | [U3] |
| Play mode | Unity backs up modified scenes before Play and reverts them when Play exits, so changes made during Play are lost. | [U4] |
| Layout | Window layouts are stored per user, outside the version-controlled assets. | (memory) |

**What Unity does not have:** a thread between the editor UI and the edited scene. The inspector
writes into the live object on the thread that owns it.

## Unreal

| Topic | Finding | Source |
|---|---|---|
| Render thread | The renderer runs on its own thread, typically one or two frames behind the game thread. | [E1] |
| Crossing to render | The game thread enqueues render commands. `FRenderCommandFence` lets it wait for, or poll, the render thread's progress. `FlushRenderingCommands` blocks the game thread until the render thread catches up, and Epic names it as the tool for editor operations that modify memory the renderer reads. | [E1] |
| Editor UI | Slate batches its draw elements on the game thread (`DrawWindow_GameThread`), into an `FSlateDrawBuffer`, then renders them on the render thread (`DrawWindowToTarget_RenderThread`). The buffer pools element lists from the previous frame. | [E2] |
| Editor UI thread | Slate ticks on the game thread, which also ticks the editor's world. | (memory) |
| Edit mode | The editor's world ticks as `LEVELTICK_ViewportsOnly`: time and viewports only. An actor ticks there only if it overrides `ShouldTickIfViewportsOnly`. | [E3] |
| Edits and undo | `FScopedTransaction` opens a transaction for its scope. `Modify()` on an object inside it records the object's current state in the undo buffer and marks its package dirty. The buffer is in memory only. | [E4] |
| Play In Editor | PIE duplicates the editor's world (`GetDuplicatedWorldForPIE`), so the editor's copy stays unchanged. *Keep Simulation Changes* copies chosen edits back. | [E5] |
| Layout | The editor layout is an `.ini` under the project's `Saved/` folder, which projects normally do not commit. | (memory) |

**What Unreal does have:** a UI that is built on one thread and drawn on another, through a
buffer. That is the shape ImGui needs below.

## Godot

| Topic | Finding | Source |
|---|---|---|
| Render thread | The *Separate* thread model is experimental, with known crashes. **The editor and the project manager force rendering onto the main thread**: "Editor and project manager cannot run with rendering in a separate thread (they will crash on startup)." | [G1], [G2], [G3] |
| Editor UI thread | The editor is itself a Godot application, built from `Control` nodes in a `SceneTree` on the main thread. The edited scene lives in the same tree. | (memory) |
| Scene thread safety | The active scene tree is not thread-safe. Other threads use `call_deferred` or `set_deferred` to reach it. | [G2] |
| Edit mode | Game scripts do not run in the editor unless they are marked `@tool`. | (memory) |
| Edits and undo | `UndoRedo` records each action as explicit do and undo operations: `create_action`, `add_do_property`, `add_undo_property`, `commit_action`, with merge modes. `EditorUndoRedoManager::create_action` takes `p_mark_unsaved = true`, so the unsaved marker follows the undo history. | [G4], [G5] |
| Play | The editor runs the game as a **separate OS process**, through `OS::create_instance`. | [G6] |
| Layout | Per-project editor state lives in the project's `.godot/` folder, which Godot's default `.gitignore` excludes. | (memory) |

**What Godot shows:** with an editor thread and a render thread, its own editor did not hold up,
so it gave the render thread up for the editor.

## Dear ImGui over a render thread

| Topic | Finding | Source |
|---|---|---|
| Threads | One ImGui context must not be used from several threads in parallel. | [I1] |
| The pattern | To build UI on one thread and render on another, the app must stage **two** things: the `ImDrawData` and, since 1.92, the texture requests. The official helpers are `ImDrawDataSnapshot` and `ImTextureQueue` in `imgui_threaded_rendering.h`. | [I1], [I3] |
| Snapshot cost | `SnapUsingSwap` takes the draw lists' buffers instead of copying them, and leaves the source unusable. It keeps capacity between frames, aiming at zero allocations once the UI is stable. | [I3], [I4] |
| How many | The maintainer: "For multi-threading you would indeed need to alternate between two `ImDrawDataSnapshot`", and more snapshots for more frames in flight. | [I4] |
| Textures | Since 1.92 the font atlas grows at runtime, and draw data is no longer self-contained. `ImTextureQueue` (v0.20, Jul 22 2026) needs every call under one mutex. The UI thread queues requests **before** it publishes the snapshot, and the render thread processes them before it renders. Destruction is deferred by `InFlightFrames`. | [I3], [I5] |
| Without the queue | A v1.92.5 app with a render thread and snapshots but no texture queue had missing glyphs and crashes in the backend's texture upload. It was closed by the queue on Jul 22 2026. | [I6] |
| Shutdown | Stop both threads, shut the queue down, clear the snapshots, then shut the backends down and destroy the context. | [I3] |
| Multi-viewport | Threaded multi-viewport is "untested": viewport position and size are queued both ways and expected to be handled at once, and each viewport needs its own snapshot. `UpdatePlatformWindows()` creates and updates the OS windows from the main loop. | [I3], [I2] |
| Platform backend | `imgui_impl_glfw` installs and chains GLFW callbacks, and its new-frame call reads the cursor and window size and sets the cursor through GLFW. GLFW restricts event processing and window and context creation to the main thread, and runs every callback there. | [I7], [W1] |
| GL backend | `imgui_impl_opengl3` embeds its own GL loader unless `IMGUI_IMPL_OPENGL_LOADER_CUSTOM` is defined. | [I8] |
| Layout file | `io.IniFilename` defaults to `imgui.ini`, relative to the working directory. Set to `NULL`, the app saves by hand with `SaveIniSettingsToMemory` when `io.WantSaveIniSettings` is set. Saving happens a few seconds after a change, no more often than `IniSavingRate` (5 s). | [I2] |
| Large lists | `ImGuiListClipper` submits only the visible rows of a long, evenly spaced list. | [I2] |
| Idle | ImGui issues the whole UI every frame. It has no built-in idle mode, so an app that wants to sleep must decide when to draw. | (memory) |

## Q1 mapped: the window and the drawing thread

| Fact in TechEngine | What the research says about it |
|---|---|
| Only the render thread issues GL, and it holds the one context until shutdown ([[Window - Design]] § *Decided*). | The ImGui GL backend's render call issues GL, so it can only run on the render thread under this rule [I8]. What stays open is **which thread builds the frame**, not which one draws. |
| ADR-018 §1: the client main thread owns window events and editor interaction. | All three engines build editor UI on the thread that owns the OS events: Unity's main thread (memory), Unreal's game thread (memory), Godot's main thread [G3]. The GLFW backend expects the same, because it calls GLFW at every new frame [I7], [W1]. |
| `client` never calls a `glfw*` function, and GLFW stays inside `platform` ([[Window - Design]] § *Decided*). | `imgui_impl_glfw` calls GLFW directly [I7]. Wherever it is linked, it either breaks that row or needs a home that row allows; a hand-written platform backend over `Window` is the other road (inference). |
| glad2 is the one vendored GL loader, in `client` (ADR-008 §4 case 3). | The GL backend brings its own loader unless told not to [I8]. |
| One window, one context. | A second OS window means a second context, and ImGui's multi-viewport path is untested over a render thread [I3]. Sharing the one window keeps today's context model as it is (inference). |
| Main is event-driven, with no periodic timer (ADR-019 §5). | ImGui only saves its layout and runs animations during frames [I2], (memory). An event-driven main gets no frame between events unless `waitEvents(timeout)` or a posted wake supplies one (inference). |

## Q1 mapped: the frame command buffer

[[Window - Design]] § *The frame command buffer*: one slot, newest wins, render redraws its
last value, a mutex around the slot. Today `SnapshotMailbox::snapshot` copies the whole value out
under the lock (`engine/client/src/render/SnapshotMailbox.cpp:9-16`), and the value is small
and fixed (`engine/client/include/TechEngine/client/render/RenderSnapshot.hpp:10-18`).

| Property of the buffer | What ImGui's data does to it |
|---|---|
| **Newest wins, and render may skip.** | Skipping a draw-data snapshot is harmless: the next one is complete [I4]. Skipping a **texture request** is not: the snapshot after it can reference a texture that was never created [I3], [I6]. The texture queue is a second channel that drops nothing, beside the newest-wins slot (inference). |
| **The producer never overwrites what render still owns** (ADR-018 §2). | `SnapUsingSwap` hands buffers over instead of copying, and the maintainer pairs it with two alternating snapshots [I4]. With a consumer that can hold one snapshot while the producer publishes twice, two buffers are not enough without an exchange that returns the held one (inference). |
| **Copy under a short lock.** | Draw data grows with the UI: vertex and index buffers, not a fixed struct. A deep copy under the lock costs time in proportion to the UI; the swap avoids the copy [I4]. |
| **One producer: the simulation thread** (`engine/app/src/SimulationThread.cpp:195-198`). | If main builds the ImGui frame, main becomes a second producer of render input, as Slate's draw buffer is separate from Unreal's scene commands [E2]. Whether it shares the slot or gets its own is open (inference). |
| **Resource lifetime is part of snapshot ownership** (ADR-018 §2; [[Simulation Thread - Design]] § *Render handoff and pacing*). | ImGui's font atlas and textures are GPU resources whose destroy must wait for frames in flight [I3]. They are the first resource lifetime protocol this seam would carry, ahead of R1 (inference). |

## Q2 and Q3 mapped: reading the Scene and applying an edit

| TechEngine | Unity | Unreal | Godot |
|---|---|---|---|
| ADR-018 puts editor interaction on main and the `Scene` on the simulation thread. | UI and scene on one thread (memory). | UI and editor world on one thread (memory). | UI and scene in one tree on one thread [G2], (memory). |

**None of the three references has the editor UI and the edited world on different threads in
edit mode** (memory for Unity and Unreal; [G2], [G3] for Godot). So none of them answers Q2 for
TechEngine directly. The nearest pattern is Unreal's render thread: it reads game data through
enqueued copies, and the editor blocks with `FlushRenderingCommands` when it must change memory
the renderer reads [E1]. Those are the two options ADR-024 §6 already names: a published copy,
or a fence.

| ADR-024 §6 option | What the research attaches to it |
|---|---|
| **Published copies.** | The render snapshot is the precedent ([[Simulation Thread - Design]] § *Render handoff and pacing*). C2 sizes it: the panels must stay smooth at 1,000 entities, though the clipper means only visible rows are drawn [I2]. A hierarchy is a tree, so the clipper needs it flattened to rows first (inference). |
| **Main's fence.** | Unreal's flush is this shape, used for editor operations [E1]. In E1 the simulation does not tick when stopped ([[Resources - Design]] § *Open questions*), so a fence would rarely wait on a tick (inference). |

**Q3, how an edit reaches the simulation thread.** [[Simulation Thread - Design]] § *Input and
control handoffs* already decides the transport: bounded FIFO admission, applied at safe mutation
boundaries, rejected visibly when full, cancelled on shutdown. What the research adds is the
**shape of an edit**, which decides C1 and C4:

| Shape | Who | Fits the command queue | Source |
|---|---|---|---|
| Record the object's state, then mutate it | Unreal `Modify()`; Unity's undo record inside `ApplyModifiedProperties` | The before-state lives on the simulation thread, so it is taken there when the command applies (inference). | [E4], [U3] |
| An action with explicit do and undo values | Godot `UndoRedo` | A command that carries the old and the new value is already an undo entry (inference). | [G4] |
| The unsaved marker | Godot ties it to the undo history; Unreal's `Modify()` dirties the package | Both derive "unsaved" from the edit path, not from a separate flag. | [G5], [E4] |

## Q4 mapped: the stopped state

[[Resources - Design]] § *Open questions* decided on Oct 10: only Play ticks; stopped and paused
do not, and the simulation thread stays alive and idle between commands. Today every App ticks
from startup until stop (`engine/app/src/SimulationThread.cpp:188-200`).

| Engine | What "not playing" means | Source |
|---|---|---|
| Unity | Edit mode has no regular frame loop for scripts; `Update` runs when the scene changes. | [U2] |
| Unreal | The editor world ticks viewports only; actors opt in. | [E3] |
| Godot | Game scripts do not run unless they are `@tool`. | (memory) |

**How each keeps edits apart from Play** (Play is a Won't for E1, but the edit path must not
block it): Unity reverts scenes from a backup [U4], Unreal plays a duplicated world [E5], and
Godot plays in another process [G6]. All three leave the edited scene untouched by Play.

**C3, the layout file.** All three keep editor layout per user and out of version control:
Unreal under `Saved/` (memory), Godot under `.godot/` (memory), Unity per user (memory). ImGui
writes its file relative to the working directory by default, so a project-local path means
setting `io.IniFilename` or saving by hand [I2].

## What S9-D2 still has to decide

The report closes none of these; it only lists where the research found them.

- **Q1:** which thread builds the ImGui frame, given that only render may draw it.
- **Q1:** where `imgui_impl_glfw` (or a replacement) lives against "GLFW stays inside `platform`".
- **Q1:** whether ImGui's draw data shares the snapshot slot or gets its own, and the buffer count.
- **Q1:** how texture requests cross without being skipped.
- **Q1:** how an event-driven main gets the frames ImGui needs.
- **Q2:** published copies or main's fence.
- **Q3 and C1:** whether an edit command carries its old value, or the simulation records it.
- **Q4:** how the idle simulation thread wakes when a command arrives.

## Sources

| Tag | Source | Read how |
|---|---|---|
| U1 | Unity Scripting API, [`Rendering.RenderingThreadingMode`](https://docs.unity3d.com/ScriptReference/Rendering.RenderingThreadingMode.html) (6000.x) | Search extract |
| U2 | Unity Scripting API, [`ExecuteInEditMode`](https://docs.unity.cn/es/current/ScriptReference/ExecuteInEditMode.html) | Search extract |
| U3 | Unity Scripting API, [`SerializedObject.ApplyModifiedProperties`](https://docs.unity3d.com/kr/2022.3/ScriptReference/SerializedObject.ApplyModifiedProperties.html) | Search extract |
| U4 | Unity Manual, [Configurable Enter Play Mode](https://docs.unity3d.com/2022.3/Documentation/Manual/ConfigurableEnterPlayMode.html) | Search extract |
| E1 | Epic, [Threaded Rendering in Unreal Engine](https://dev.epicgames.com/documentation/unreal-engine/threaded-rendering-in-unreal-engine) | Search extract |
| E2 | Epic API, [`FSlateDrawBuffer`](https://dev.epicgames.com/documentation/unreal-engine/API/Runtime/SlateCore/FSlateDrawBuffer), [`DrawWindow_GameThread`](https://dev.epicgames.com/documentation/unreal-engine/API/Runtime/SlateRHIRenderer/ISlate3DRenderer/DrawWindow_GameThread) | Search extract |
| E3 | Epic API, [`ELevelTick`](https://dev.epicgames.com/documentation/unreal-engine/API/Runtime/Engine/ELevelTick) | Search extract |
| E4 | Epic API, [`FScopedTransaction`](https://dev.epicgames.com/documentation/unreal-engine/API/Editor/UnrealEd/FScopedTransaction), [`UTransactor`](https://docs.unrealengine.com/4.26/API/Editor/UnrealEd/Editor/UTransactor/index.html) | Search extract |
| E5 | Epic, [In-editor testing: Play and Simulate](https://dev.epicgames.com/documentation/unreal-engine/ineditor-testing-play-and-simulate-in-unreal-engine); [`GetDuplicatedWorldForPIE`](https://docs.unrealengine.com/4.27/en-US/API/Runtime/Engine/Engine/UWorld/GetDuplicatedWorldForPIE/index.html) | Search extract |
| G1 | Godot `doc/classes/ProjectSettings.xml`, `rendering/driver/threads/thread_model`, at `c8256a8` | Source read |
| G2 | godot-docs, [Thread-safe APIs](https://github.com/godotengine/godot-docs/blob/master/tutorials/performance/thread_safe_apis.rst) | Source read |
| G3 | Godot [`main/main.cpp`](https://github.com/godotengine/godot/blob/c8256a8ecec068340753869e423dd478c84ef167/main/main.cpp), the `separate_thread_render` block | Source read |
| G4 | Godot `core/object/undo_redo.h`, at `c8256a8` | Source read |
| G5 | Godot `editor/editor_undo_redo_manager.h`, at `c8256a8` | Source read |
| G6 | Godot `editor/run/editor_run.cpp`, `OS::create_instance`, at `c8256a8` | Source read |
| I1 | Dear ImGui [`docs/FAQ.md`](https://github.com/ocornut/imgui/blob/docking/docs/FAQ.md), threads, docking `d88f238` (1.93.1 WIP) | Source read |
| I2 | Dear ImGui `imgui.h`, docking `d88f238` | Source read |
| I3 | [`imgui_threaded_rendering.h`](https://github.com/ocornut/imgui_club/blob/main/imgui_threaded_rendering/imgui_threaded_rendering.h) v0.21, imgui_club `b083116` | Source read |
| I4 | [ocornut/imgui#1860](https://github.com/ocornut/imgui/issues/1860), "Double-buffered ImDrawData" | Page read |
| I5 | [ocornut/imgui#8597](https://github.com/ocornut/imgui/issues/8597), threaded rendering with texture updates (1.92) | Page read |
| I6 | [ocornut/imgui#9136](https://github.com/ocornut/imgui/issues/9136), the texture-update crash | Page read |
| I7 | Dear ImGui `backends/imgui_impl_glfw.cpp`, docking `d88f238` | Source read |
| I8 | Dear ImGui `backends/imgui_impl_opengl3.cpp`, docking `d88f238` | Source read |
| W1 | GLFW [`docs/intro.md`](https://github.com/glfw/glfw/blob/master/docs/intro.md) § *Thread safety* | Source read |
