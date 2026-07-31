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
`Log.hpp:13` falls back to `TRACE`: every Trace/Debug call site in that TU compiles into
**Release** — args evaluated and type-erased per call, then dropped by the runtime filter.
[[ADR-011 — Diagnostics (Logger & Assert)]] §4's "compiled out" guarantee silently doesn't
hold there.

**Silent because it fails permissive.** Default to `OFF` and a missed link means *no logs at
all* — noticed in a minute.

`engine/base/include/TechEngine/base/Log.hpp:13` ·
`engine/base/CMakeLists.txt:17` (the PUBLIC define that didn't arrive)

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
doesn't, despite being the identical PUBLIC-define shape (`engine/base/CMakeLists.txt:20`).

**Alternative considered:** `#error` when the define is absent — strictest, turns silent into
unbuildable. Rejected for now: ADR-011 §10 leaves SDK exposure open, and if `te_sdk` ships
`Log.hpp` without a `base` link edge, `#error` makes that impossible rather than merely wrong.
Revisit when §10 is decided.

**Trigger:** the first target that includes `Log.hpp` without linking `base` — `te_sdk` is
the likely one (ADR-011 §10). Cheap enough (~6 lines + a test case) to ride along with the
next card that touches the logging gate.
