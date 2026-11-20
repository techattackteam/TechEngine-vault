# 🐞 Known Issues

Defects that are **found, diagnosed, and latent**: nothing misbehaves today, but it will,
and it will do so **silently**. Sibling of [[v1 Code Audit]], pointed at v2.

## What belongs here

Two tests, both required:

1. **Nothing is currently misbehaving.** If something is broken *now* (a wrong output, a
   dead code path, a failing check) that is a **bug**, and a bug is a **card on the
   [[Sprint Board]] this sprint**, not an entry here ([[Planning Workflow - Artifact Gate]] →
   *Task attributes*).
2. **It would fail silently.** A defect that announces itself (build error, failed test,
   visibly wrong output) needs no list: fix it or forget it. The entries worth keeping are
   the ones where the first symptom is *shipping the wrong thing*.

Not a backlog. A [[Backlog]] entry is a **want**; an entry here is a **known wrong**.

## How it works

- **`D<n>`, numbered, never reused.** Code can cite `TODO(D<n>)`
  (`CONVENTIONS.md` → *Comments*).
  Cards die and their IDs go stale: `TODO(S2-T9)` already points at a descoped card. A
  defect ID doesn't.
- **No schedule, by design.** An entry becomes work three ways, and none of them is a date:
  it **blocks** planned work (ordered before it) · it **touches a file** planned work touches
  (fixed in that PR, no card, this is what the `Trigger:` lines mean) · or its condition
  **fires**, and it graduates to a **bug card** and is deleted from here.
- **Read at `/sprint-plan`**, one question: *does any of this block or touch what we're
  planning?*
- **Exit is a commit.** Deleted when fixed, no tombstone, same rule as the [[Backlog]].
- **3+ sprints untouched ⇒ decide.** Card it or delete it. Without that the file only grows,
  and a list nobody empties is one nobody reads.

---

### D14: A reload never frees its old GPU copy

A reload sends a new upload for the same slot, and `GpuCopies::apply` replaces the copy with
`insert_or_assign` (`engine/client/src/render/GpuCopies.cpp:38` at `4af204b`). What the old copy
held goes with it, and nothing frees it:

- **A mesh's `GeometryRange`** stays taken, because nothing calls `GeometryBuffers::free`.
  Logged at S11-T7's close (#217), as planned when S11-T16 was split out of S11-T6.
- **A texture** stays allocated and its bindless handle stays resident, because
  `GpuCopies::shutdown` only destroys the textures of the copies it still holds;
  `RenderDevice::shutdown` frees it at exit. Added at S11-T8's close (#219).

**Silent because** nothing fails: each re-import of a mesh takes a new range, and when a block
fills, a new 64 MB block is added. Each re-import of a texture keeps one more texture in GPU
memory. Neither is named by any packet or material.

**Fix:** S11-T16 drops a copy on a release and a reload's old copy, and frees its range or
destroys its texture then. The replaced copy must survive `insert_or_assign` long enough for
that.

**Trigger:** S11-T16, or the first editor session that re-imports meshes or textures often
enough for a second geometry block or a GPU memory warning to show up.

### D13: A dependency added after an upload never reaches render

An upload carries the dependency slots its entry held when it turned Ready
(`engine/core/src/resources/ResourceCache.cpp:490` at `8f2a444`). `addDependency` appends to the
entry's list later (`:142`) and records no new upload, so render's copy keeps the old list. Found
by S11-T6's `/card-review` (#213).

**Not reached today** (checked Nov 17): every caller adds to the scene's handle
(`SceneAsset.cpp`, `MaterialSlotRebuild.cpp`, `PlaceModelCommand.cpp`, `InspectorCommands.cpp`),
and a scene is not a marked type.

**Silent because** a material's handler finds its textures through those slots (S11-T8), so a
texture added this way would simply not be bound, and the material would draw without it.

**Fix:** not decided. `addDependency` on a marked type could record a fresh upload, or refuse.

**Trigger:** the first `addDependency` call whose holder is a `Mesh`, `Texture` or `Material`.

### D12: Two processes in one working directory share one session log

`initLogging()` opens `logs/techengine.log`, a path relative to the working directory, and
truncates it (`engine/base/src/diagnostics/Log.cpp:28`, `:257` at `f932dd21`). A second process
started in the same directory truncates the first one's log and then writes into it beside it.
Found when parallel `ctest` turned it into a Windows failure (#205): every `App::run()` case of
one test exe writes that file at once, and only the diagnostics case, now in its own folder,
checks its contents.

**Silent because** nothing reads the session log except a person after something went wrong,
which is when a clobbered log costs the most.

**Fix:** not decided. A per-process or per-role file name is one option.

**Not reached by *File, Run* today** (checked Nov 14): it starts the exported runtime in
`<editor executable folder>/<project name>/` (`apps/editor/src/EditorApp.cpp:100`, `:400`,
`apps/editor/src/main.cpp`), which is not the editor's working directory in any normal launch,
and it stays disabled until that runtime exits. Two editors launched from one folder do reach it.

**Trigger:** any change that starts a second engine process or moves the runtime's working
directory, or a card that reads the session log back.

### D11: A flat `.hdr` cut short after its header imports as a black sky

A Radiance file whose pixel data is missing or cut short, and stored flat rather than
run-length encoded, decodes without an error: stb_image fills the missing pixels with zeros
and returns the image. *Import image...* then writes a valid `RGB9E5` texture that is partly
or wholly black. Logged in #203's description, not fixed.

**Silent because the file is valid.** Every check after the decode passes, the texture loads,
and nothing in the editor draws a sky until R1.

`apps/editor/src/assets/ImageDecoder.cpp:70-74` at `25c93a4b`.

**Fix:** not decided. The decoder could compare the bytes a flat image needs against the bytes
after the header before calling stb_image.

**Trigger:** R1's sky card, the first code that draws the image, or the next change to
`ImageDecoder`.

### D10: Two spellings of one source re-import at the same time

`ReimportCommand` refuses a second re-import of a source that has one running, because two
jobs would give one new output two ids. It compares the source path as typed, so
`assets/client/Kit.gltf` and another spelling of the same file, or `Kit.gltf` and `Kit.fbx`
importing into one `Kit/` folder, are both let through. If the finishing command cannot be
submitted, the path also stays in the list until the editor restarts. Logged in #203's
description, not fixed.

**Silent because both jobs succeed.** Neither job sees the other's ids, so a new output can
end up with two ids, and nothing reports it.

`apps/editor/src/edit/ReimportCommand.cpp:34-39` at `25c93a4b`; the list is
`EditorApp::m_reimportsInFlight` (`apps/editor/src/EditorApp.hpp:51`).

**Fix:** not decided. The key could be the output folder, resolved to one form, instead of the
typed source path.

**Trigger:** the asset browser's import or re-import, which stops paths from being typed, or
any second caller of `ReimportCommand`.

### D9: An editor destroyed during an import races the import's log lines

`EditorApp::~EditorApp()` waits for running imports, but the destructor has already rewritten
the object's vptr when the wait starts. A job that logs meanwhile wakes main through the console,
a virtual call on the app, so the job's read of the vptr races the destructor's write. TSan
reported it on the Linux leg of #194, and the test that reached it was deleted instead of
fixed. `shutdown()` waits first, so it is safe.

**Silent because no normal path reaches it.** `App::run()` calls `shutdown()` whenever `init()`
completed, and the startup import starts after `init()`, in the startup load. Only a caller
that skips `shutdown()` reaches the race: a test that bootstraps an editor and destroys it, or a
new entry point. Outside TSan it is undefined behaviour with no symptom.

`apps/editor/src/EditorApp.cpp:63-68` at `9c93b8f4`.

**Fix:** not decided. The job could stop logging through the app before the app dies, or the
editor's imports could be owned by a member destroyed before the app's virtual calls end.

**TSan is the only detector, and it is off for editor tests for now.** From S11-D5's merge until
the null render device lands ([[Backlog]], *client*), a test that bootstraps an editor is `[gpu]`,
and TSan does not run `[gpu]`. A new test that reaches this race would go unreported.

**Trigger:** the next change to how `EditorApp` starts or stops imports (the asset browser's
import, or cancelling an import in the [[Backlog]]), or any test that destroys an editor
without `shutdown()`.
