# Window — Design

> Living design doc. The decision that is hard to reverse is [[ADR-015 — Threading (sim on main, render thread owns GL)]] §2. This doc holds the *how*.

**Module:** `platform` (the window and input) · `client` (the context, glad2, the render thread) · **Kind:** system · **Status:** draft, nothing built
**ADRs:** [[ADR-015 — Threading (sim on main, render thread owns GL)]] §1 §2 ·
[[ADR-006 — v2 core architecture & module layout]] §1 ·
[[ADR-008 — v2 build & testing baseline]] §4 case 3 · §5 ·
[[ADR-005 — v2 tech stack & toolchain]] (GLFW, glad2, GL 4.5 core)
**v1:** [[v1 Code Audit]] F22 (the device seam) · **Backlog:** [[Backlog]] → `platform`, `client`

## Purpose

M4 opens the engine's first window and draws its first triangle. That is the visible goal, and
it is the smaller half of the job.

The real job is proving [[ADR-015 — Threading (sim on main, render thread owns GL)]] §2's seam
in code: **a GL context that is current on the render thread and nowhere else**, fed only by
complete per-frame data. Every renderer decision after this is written against that seam, and
retrofitting it across a written renderer is the rewrite M2 exists to prevent.

So M4's output is not a triangle. It is a triangle drawn on the correct thread.

## Decided

This table is the summary. Every row that needed an argument has one in *Design* below.

| What | Call | Ref |
|---|---|---|
| **Module split** | `platform` owns the window and raw input and issues **no GL call ever**. `client` owns the context, glad2 and every GL call. | See *The seam*, 2026-08-30 |
| **GLFW stays inside `platform`** | `client` never calls a `glfw*` function. The three context operations it needs are methods on `Window`. | See *The seam* |
| **glad2 lives in `client`** | Moved off `platform`'s dependency row. **This reverses ADR-006 §1** and is filed there as a dated `decision` amendment. | ADR-006 §1 amendment, 2026-08-30 |
| **glad2 is generated, committed, and never fetched** | GL 4.5 core, no extensions, `--reproducible`. Committed under `external/glad/`, wrapped in `cmake/deps.cmake`. The one vendored dep. | ADR-008 §4 case 3 |
| **Context handoff** | Main creates the window and never makes the context current. The render thread claims it once and holds it until shutdown. | See *Startup and shutdown order* |
| **`gladLoadGL` runs on the render thread** | It needs a current context, so it cannot run at startup on main. | See *Startup and shutdown order* |
| **Frame handoff at M4** | A single-slot **mailbox** carrying a `FramePacket`. Newest complete wins; main may overwrite an unconsumed packet, and the render thread may re-consume the last one. | See *The frame mailbox* |
| **The packet's contents are M4's, not R1's** | Clear colour plus a draw flag. The real command-list format belongs to R1's renderer ADR. | ADR-015 §2 |
| **CI opens a real window** | `xvfb-run` wraps `ctest` on the Linux legs, with Mesa's llvmpipe providing software GL 4.5. | See *How CI proves this*, 2026-08-30 |
| **No `IWindow` interface** | One implementation, and no carded work needs a second. Same reasoning as [[File Access — Design]] § *Why there is no interface*. | 2026-08-30 |

## The seam

ADR-006 §1 lists **window** and **input** under both `platform` and `client`, and lists glad2
under `platform`. That row cannot be followed as written, so this note resolves it.

| Concern | Owner | Why |
|---|---|---|
| GLFW init, window creation, `pollEvents`, destruction | `platform` | It is the OS seam. A dedicated server links `platform` for files and the timer and never creates a window. |
| Raw keyboard, mouse and gamepad events | `platform` | Same seam. Input is an OS fact before it is a presentation one, and ADR-007 §2 already turns it into command data a rung above. |
| The GL context, glad2, every `gl*` call | `client` | `client` **is** the presentation module and owns the GL 4.5 device seam (F22). |
| The render thread | `client` | `app` is the composition root and is explicitly presentation-agnostic (ADR-006 §1), so it cannot own a thread whose whole job is GL. |

## The `Window` surface

**`client` never calls a `glfw*` function.** The context operations it needs are methods on
`platform`'s `Window`, so GLFW's headers stay entirely inside one module:

```cpp
namespace TechEngine {
    class Window {                       // platform. Owns the GLFWwindow*.
    public:
        // --- main thread only (GLFW pins these) ---
        static bool  initialize();       // glfwInit + the 4.5 core hints
        bool         open(int width, int height, std::string_view title);
        void         pollEvents();
        void         close();

        bool         shouldClose() const;

        // --- callable from the render thread ---
        void         makeContextCurrent();      // and (nullptr) to release
        void         releaseContext();
        void         swapBuffers();
        GlProcLoader  procLoader() const;       // feeds gladLoadGL, never a GL call itself
    };
}
```

`procLoader()` returns `glfwGetProcAddress` behind a typedef. That is the one place the two
modules touch, and it moves a function pointer rather than a GL call.

## Why glad2 moved out of `platform`

ADR-006 §1 put it there because `platform` owns the window. But a loader is only useful to
whoever holds a current context, and ADR-015 §2 puts that on the render thread inside `client`.

Leaving it in `platform` would put a GL loader on the link line of a dedicated server that
links no GL at all (ADR-006 §2).

The amendment is filed on ADR-006 §1 rather than left implicit, because a reader following that
row would wire it the other way and only find out at link time, or not at all.

## glad2: generation and vendoring

Generated once with the `glad2` Python package, not the web service, so the command is a
recorded fact rather than a set of clicked checkboxes:

```bash
glad --api gl:core=4.5 --extensions= --out-path external/glad --reproducible c
```

| Choice | Call | Why |
|---|---|---|
| Profile | `gl:core=4.5` | ADR-005's row. DSA is core in 4.5, so the renderer never needs the ARB spelling. |
| Extensions | **none** | 4.5 core already contains DSA and `glDebugMessageCallback` (`KHR_debug` became core at 4.3). An empty list keeps the generated file small and the loader honest. |
| `--reproducible` | on | Byte-identical output across regenerations, so a regenerate produces an empty diff unless the API selection actually moved. |
| Output | committed | ADR-008 §4 case 3. It is not a fetchable CMake project, so it is the one vendored dep. |

It produces `external/glad/include/glad/gl.h` and `external/glad/src/gl.c`, wrapped in
`cmake/deps.cmake` beside the other declares.

**Two gotchas that will bite.** `gl.c` is third-party, so the target must **not** link
`te_warnings` and must declare its include directory `SYSTEM`. Otherwise `-Werror` fails the
build on code we do not own (ADR-008 §5). And the generator command belongs in a comment above
the target, because a vendored file with no recorded provenance cannot be regenerated when GL
4.6 or a new extension is wanted.

## Startup and shutdown order

This is the part that is easy to get backwards, because GLFW pins some calls to the main thread
and the context to exactly one thread, and those two rules point in opposite directions.

```mermaid
sequenceDiagram
    participant M as main thread (app)
    participant R as render thread (client)
    participant W as Window (platform)

    M->>W: initialize() + open()
    Note over M,W: context exists, current on NO thread
    M->>R: spawn, hand over Window&
    R->>W: makeContextCurrent()
    R->>R: gladLoadGL(window.procLoader())
    loop every frame
        M->>W: pollEvents()
        M->>M: FrameLoop: Input .. PostUpdate
        M->>R: publish(FramePacket)
        R->>R: issue GL for newest packet
        R->>W: swapBuffers()
    end
    M->>R: stop + join
    R->>W: releaseContext()
    M->>W: close()
```

## The rules that are easy to get backwards

| Rule | Consequence if broken |
|---|---|
| `glfwInit`, `open`, `pollEvents` and `close` are **main thread only**. | GLFW's own contract. Calling them elsewhere is undefined and fails differently per platform. |
| `open()` does **not** make the context current. GLFW does not do this for you. | The render thread would find the context owned by main, and `makeContextCurrent` on a second thread is an error while it is current on the first. |
| `gladLoadGL` runs **after** `makeContextCurrent`, on the render thread. | Every loaded pointer is null and the first GL call segfaults. |
| The render thread is **joined before** `close()`. | The window is destroyed under a thread still issuing GL against it. |
| `swapBuffers` blocks on vsync, **on the render thread**. | This is the one frame of present latency ADR-015 §2 accepts. If it ran on main, the sim would be pinned to the display's refresh rate, which is the coupling the render thread exists to break. |

**Input callbacks fire inside `pollEvents`, on main.** They write into `platform`'s input
buffer and must never touch the render thread's data or issue a GL call.

## The frame mailbox

ADR-015 §2 says the render thread "consumes the most recent complete list". At M4 that is a
single-slot mailbox rather than a queue, and the packet is deliberately trivial:

```cpp
struct FramePacket {
    std::array<float, 4> clearColor = {};
    bool                 drawTriangle = false;
    std::uint64_t        frameIndex = 0;
};
```

| Behaviour | Call | Why |
|---|---|---|
| Main publishes a packet each frame. | Overwrites whatever is in the slot. | A slow render thread must never stall the sim. Dropping a frame of *presentation* is correct; blocking the sim is not. |
| The render thread takes the newest packet. | If none is new, it re-draws the last one. | It must not block waiting for the sim either. |
| Synchronisation | A mutex around the slot at M4. | It is one small struct per frame. A lock-free triple buffer is a P-lane optimization with no measurement behind it, which CLAUDE.md § *Performance* rules out. |

`frameIndex` exists so the render thread can tell a re-consumed packet from a new one, and so a
Tracy zone can be matched across the two threads.

**The packet's contents are throwaway and its shape is not.** R1's renderer ADR replaces
`clearColor` and `drawTriangle` with a real command list. The mailbox, the newest-wins rule and
the ownership boundary all survive that, which is why M4 is worth building against them now.

## How CI proves this

**Decided 2026-08-30: the Linux legs open a real window under `xvfb-run`.**

The alternative considered was compile-only verification with a demo capture on Windows, which
is what CLAUDE.md § *Testing* prescribes for rendering. It was rejected here for one reason:
**the required `diff coverage` gate**. No CI job runs the `runtime` exe, so a window and GL
diff is uncoverable by construction and would land near the same 55% that forced `App.cpp`'s
exclusion at S4-T7. Excluding all of `client` to get M4 merged would hollow out the gate on the
largest module still to be written.

Running the code is the option that keeps both the gate and the Linux window path honest.

| Piece | Change |
|---|---|
| Packages | Add `xvfb` and `libgl1-mesa-dri` to the existing Linux install step in `ci.yml`. `libgl1-mesa-dev` is already there but is headers plus `libGL`, not the llvmpipe driver. |
| Invocation | `xvfb-run -a ctest --preset <leg>` on the Linux legs only. Windows runners have a real desktop session. |
| Forcing software GL | `LIBGL_ALWAYS_SOFTWARE=1` in the test step's environment, so a runner never silently picks a different driver. |

**Unverified, and it is the note's biggest risk.** Nothing here has been run. Two things could
break it. Mesa's llvmpipe must advertise **GL 4.5 core**, which it has done since Mesa 20 but
which depends on the runner image's Mesa build. And `ci.yml` edits draw no CI on their own PR
since #54, so this change has to land alone and be read from the run it produces on `master`
(`ci.yml`'s own header carries that instruction).

If llvmpipe turns out to cap below 4.5, the fallback is to keep the window test and drop the
context to whatever llvmpipe offers for the CI leg only, since the window and thread seam is
what the test is really proving.

## Open questions

- **Does the editor's ImGui share this window or open its own?** Owner: **T1**. ADR-015
  § *Consequences* already names the ImGui thread as a T1 question, and this note does not
  pre-empt it.
- **Vsync, frame pacing and the swap interval.** Owner: **R1**. The [[Backlog]] frame-pacing
  entry is a sibling of this and neither should be decided against a triangle.
- **Multiple windows.** No consumer. `Window` is a type rather than a singleton, so nothing
  here forbids a second one.
- **Gamepad and text input.** M4 carries keyboard and mouse only. Text input needs
  `glfwSetCharCallback` and an IME story that no consumer wants yet.
- **Does `Window` outlive a project reload?** Owner: M6, when the project can be swapped at
  runtime.

## References

- [[ADR-015 — Threading (sim on main, render thread owns GL)]] §1 (topology) · §2 (context
  ownership, and the clear-plus-triangle proof this note implements)
- [[ADR-006 — v2 core architecture & module layout]] §1 (the module rows, and the
  2026-08-30 amendment moving glad2) · §2 (why a dedicated server links no `client`)
- [[ADR-008 — v2 build & testing baseline]] §4 case 3 (glad2 is the one vendored dep) ·
  §5 (`te_warnings` never reaches third-party code)
- [[Concurrency — Design]] § *Topology* (the thread picture this sits inside) ·
  § *Open questions* (the render-thread handoff detail is R1's)
- Code, once it exists: `engine/platform/include/TechEngine/platform/window/` ·
  `engine/client/src/render/` · `external/glad/` · `cmake/deps.cmake`
- Today: `engine/platform/CMakeLists.txt` already links `glfw`; `external/` exists and is
  empty; `.github/workflows/ci.yml` already installs GLFW's Linux build dependencies.
