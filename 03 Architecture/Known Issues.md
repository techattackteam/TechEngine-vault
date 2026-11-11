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

**Trigger:** the next change to how `EditorApp` starts or stops imports (the asset browser's
import, or cancelling an import in the [[Backlog]]), or any test that destroys an editor
without `shutdown()`.
