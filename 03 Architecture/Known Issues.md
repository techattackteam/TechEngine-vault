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

### D1 — `TE_LOG_ACTIVE_LEVEL` fails open

Include `Log.hpp` **without linking `TechEngine::base`** and the `-D` never arrives, so
`Log.hpp:17` falls back to `TRACE`: every Trace/Debug call site in that TU compiles into
**Release** — args evaluated and type-erased per call, then dropped by the runtime filter.
[[ADR-011 — Diagnostics (Logger & Assert)]] §4's "compiled out" guarantee silently doesn't
hold there.

**Silent because it fails permissive.** Default to `OFF` and a missed link means *no logs at
all* — noticed in a minute.

`engine/base/include/TechEngine/base/diagnostics/Log.hpp:17` ·
`engine/base/CMakeLists.txt:29` (the PUBLIC define that didn't arrive)

**Proposed fix** — match the CMake per-config default instead of assuming Trace:

```cpp
#if !defined(TE_LOG_ACTIVE_LEVEL)
#  if defined(NDEBUG)
#    define TE_LOG_ACTIVE_LEVEL TE_LOG_LEVEL_INFO   // Release + RelWithDebInfo both set NDEBUG
#  else
#    define TE_LOG_ACTIVE_LEVEL TE_LOG_LEVEL_TRACE
#  endif
#endif
```

Conservative on purpose: an unlinked TU in RelWithDebInfo gets Info where CMake would give
Debug — errs toward *less* logging, the safe direction for a fallback. **Unverified, not
compiled.**

**+ a test**, mirroring `AssertTests.cpp`'s config-table case (it compares the library's
compiled view against the test TU's) — the guard `TE_ASSERT_DEV` already has and this gate
doesn't, despite being the identical PUBLIC-define shape (`engine/base/CMakeLists.txt:33`).

**Alternative considered:** `#error` when the define is absent — strictest, turns silent into
unbuildable. Rejected for now: ADR-011 §10 leaves SDK exposure open, and if `te_sdk` ships
`Log.hpp` without a `base` link edge, `#error` makes that impossible rather than merely wrong.
Revisit when §10 is decided.

**Trigger:** the first target that includes `Log.hpp` without linking `base` — `te_sdk` is
the likely one (ADR-011 §10). Cheap enough (~6 lines + a test case) to ride along with the
next card that touches the logging gate.

---

### D2 — `MountTable::mount()` accepts an alias no virtual path can match

`mount()` validates nothing. `mount("editorAssets://", root, 100)` stores the alias **with**
the separator; `splitVirtualPath` yields `"editorAssets"`, `entry.alias != parts.alias`, and
every read through that mount returns `NoMount`. Empty and `"a/b"` aliases are the same class.

**Silent because both ends look fine.** The mount call succeeds, `mountCount()` counts it,
`entries()` lists it — and every lookup misses. Nothing reports it at mount time, and
`NoMount` at resolve time reads as "you asked for the wrong alias".

`engine/platform/src/files/MountTable.cpp:27` (no validation) ·
`engine/platform/src/files/VirtualPath.cpp:33` (the alias the split produces)

**Proposed fix** — `TE_CHECK` in `mount()`: alias non-empty, no `/`, no `:`. `base` is already
a `DEPS` of `platform`, and `EventRegistry::registerType` is the precedent for the shape
(check, then a defined path). Plus a Catch2 case, which S3-T11 has no equivalent of.

**Trigger: M3 project creation.** v1 spelled every mount `"editorAssets://"`
(`runtime/editor/src/project/ProjectManager.cpp:262-271` @ `v1-reference`), and [[File Access — Design]]
§ *Consumers* has M3 lifting that mount set. Fix it **before** that port, not after.

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

`engine/platform/src/files/MountTable.cpp:7`

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
