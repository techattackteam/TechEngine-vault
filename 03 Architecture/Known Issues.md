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

### D8: A zero or negative import scale is not refused

`importModel` multiplies every baked position and node translation by `ImportSettings::scale`
without checking it. A scale of zero collapses the model onto its origin. A negative scale
mirrors it, so every triangle's winding is reversed and its front faces turn away.

**Silent because the files are valid.** The model and its meshes write and read back without an
error; the first symptom is a renderer drawing the model inside out, or not at all. Today the
only caller is the startup import, which passes the default scale of 1, so nothing misbehaves.

`apps/editor/src/assets/ModelImport.cpp:61` at `9c93b8f4`. Logged by S10-T15's PR (#194).

**Fix:** refuse a scale that is not a finite number above zero with an error code, before
assimp reads the file.

**Trigger:** the first caller with settings other than the defaults (the asset browser's
import), or the next change to the bake (S10-T19 or S10-T20).
