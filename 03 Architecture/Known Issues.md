# 🐞 Known Issues

Defects that are **found, diagnosed, and latent** — nothing misbehaves today, but it will,
and it will do so **silently**. Sibling of [[v1 Code Audit]], pointed at v2.

## What belongs here

Two tests, both required:

1. **Nothing is currently misbehaving.** If something is broken *now* — a wrong output, a
   dead code path, a failing check — that is a **bug**, and a bug is a **card on the
   [[Sprint Board]] this sprint**, not an entry here ([[Planning Workflow — Artifact Gate]] →
   *Task attributes*).
2. **It would fail silently.** A defect that announces itself (build error, failed test,
   visibly wrong output) needs no list — fix it or forget it. The entries worth keeping are
   the ones where the first symptom is *shipping the wrong thing*.

Not a backlog. A [[Backlog]] entry is a **want**; an entry here is a **known wrong**.

## How it works

- **`D<n>`, numbered, never reused.** Code cites `TODO(D4)` (`CONVENTIONS.md` → *Comments*).
  Cards die and their IDs go stale — `TODO(S2-T9)` already points at a descoped card. A
  defect ID doesn't.
- **No schedule, by design.** An entry becomes work three ways, and none of them is a date:
  it **blocks** planned work (ordered before it) · it **touches a file** planned work touches
  (fixed in that PR, no card — this is what the `Trigger:` lines mean) · or its condition
  **fires**, and it graduates to a **bug card** and is deleted from here.
- **Read at `/sprint-plan`**, one question: *does any of this block or touch what we're
  planning?*
- **Exit is a commit.** Deleted when fixed — no tombstone, same rule as the [[Backlog]].
- **3+ sprints untouched ⇒ decide.** Card it or delete it. Without that the file only grows,
  and a list nobody empties is one nobody reads.

---

### D3 — the case check rejects any path through a symlink

`matchesOnDiskCase` compares `canonical(candidate)` against `canonicalRoot / relative`.
`canonical()` resolves symlinks, so a symlinked directory **below** the mount root makes the
left side the link target and the right side the logical path. They never compare equal, and
a correctly-cased file resolves to `NotFound`.

A symlinked *root* is fine — both sides get canonicalised. Only links inside the mount break.

**Silent because `NotFound` is a legitimate answer.** The caller cannot tell "no such file"
from "the resolver disqualified it", and the case rule that caused it is invisible from the
call site.

`engine/platform/src/files/MountTable.cpp:11`

**Proposed fix** — per-component `directory_iterator` spelling check instead of `canonical`:
it never leaves the logical path, so links are transparent. Costs a directory scan per
component, which is why `canonical` was chosen first. Only `matchesOnDiskCase` changes.

**Trigger:** the first symlinked or junctioned asset directory — a Linux/macOS dev layout, or
`mklink /D` on Windows. Also revisit if M6's resource loading makes the per-component cost
measurable, since that decides which way the trade goes.

---

### D4 — `toString(Role)` allocates a `std::string` per call, in a per-frame path

`toString` is `inline std::string toString(Role)` at
`engine/core/include/TechEngine/core/FrameContext.hpp:11`. It returns by value, so every call
heap-allocates. Both `RuntimeApp` and `EditorApp` call it from `fixedUpdate` **and** `update`,
and `fixedUpdate` runs once per catch-up tick, up to 15 of them under the 0.25 s clamp. That
is up to 16 allocations a frame for a string that is one of three compile-time constants.

It also pulls `<string>` into `FrameContext.hpp`, which nearly every translation unit above
`core` includes.

**Not urgent today, and that is the trap.** The only callers are the placeholder log lines
S5-T11 left in both subclasses, so nothing measurable is happening yet. The function itself
stays, and the next caller inherits the allocation without knowing.

**Proposed fix** — `constexpr std::string_view toString(Role)`. The three returns are string
literals, so nothing else changes and `<string>` leaves the header. Raised in review at S5-T11
and deliberately not taken there.

**Trigger:** any real per-frame consumer, or the first frame-time measurement. Also the moment
a second enum in `core` wants the same treatment, since this one sets the pattern.
