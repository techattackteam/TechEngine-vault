# 🔧 B3 — Build & Testing Notes

Working notes feeding the **B3 build + testing baseline ADR** (the *how* — executes
ADR-005/006). Decisions already made live in the ADRs (linked); this collects
**net-new conventions** + a scaffold checklist so B3 starts warm.

## CMake conventions (net-new here)

- **Link what you use.** Every target links *exactly* the libraries it **directly**
  uses (directly `#include`s / calls). **Never rely on transitive visibility for
  correctness** — e.g. `client` declares `base` itself, even though `base` is reachable
  via `platform`; otherwise a change to `platform`'s link visibility silently breaks
  `client`. Static libs dedup at the final exe link, so a direct edge costs nothing.
- **Link visibility rule:** `PUBLIC` if the dep appears in the target's **public
  headers** (propagate to consumers); `PRIVATE` if used only in `.cpp`. Applies to both
  `target_link_libraries` and `target_include_directories`.
- **Per-module include boundary** (from [[ADR-006 — v2 core architecture & module layout]] §3):
  `include/TechEngine/<module>/` **PUBLIC**, `src/` **PRIVATE** — a private include must
  not resolve for a consumer.
- **No `GLOB`** — explicit source lists (v1 F6).
- **One shared `techengine_module()` helper** to stamp out the per-module boilerplate
  (include dirs, visibility, warnings) consistently.

## What B3 executes (decisions already in the ADRs — don't restate, link)

- **Toolchain / std / deps / CI / sanitizers / test framework** → [[ADR-005 — v2 tech stack & toolchain]]:
  C++20, MSVC + Linux/Clang CI matrix, **CMakePresets**, **FetchContent** (+ CI
  dependency **caching** — ccache / actions cache — or build times creep), Catch2 v3 +
  CTest, clang-format + clang-tidy CI-enforced, `/W4 /WX`, ASan (Win) / UBSan+TSan (Linux).
- **Module/target graph + linkage** → [[ADR-006 — v2 core architecture & module layout]] §1:
  `base → platform → core → client → app` static libs + leaf exes (`runtime`, `editor`,
  `tests`), one linkage story, no engine DLLs.
- **Tests** → per-module Catch2 targets under CTest, **not core-only**; rendering
  verified by demo scenes + captures, not unit tests.
- **★ SDK smoke CI target** → compile a sample script against `TechEngine::sdk` **alone**; a
  private type leaking into the SDK fails CI (the F11 acid test, automated).
- **Test-bed = sample project(s)** loaded by `runtime`/`editor` (content), not a
  separate exe; `app` exposes a headless/sim-only mode (exercised by `tests`).

## CI operational notes (observed on the first real runs, 2026-07-24)

**Why the `push` → `master` backstop stays — it warms the shared ccache.** The obvious
argument for deleting it is redundancy: with "require branches up to date" on
([[ADR-009 — Branching strategy & merge rules]] §2), a squash-merge produces the tree the PR
already tested, so the backstop re-tests it. The reason to keep it anyway is **GitHub Actions
cache scoping**: a cache saved on a branch is visible to that branch and its children, but a
cache saved on the **default branch is visible to every branch**. PR runs restore only from
their own branch or `master`, so the backstop run is what keeps the cache every future PR
pulls from fresh. Delete it and each PR starts from whatever stale `master` cache was last
written — directly against ADR-008 §9's "CI time rides entirely on caching working".
(Backstop guarantees are ADR-009 §4; this is the *practical* reason, which that ADR doesn't
state.)

**clang-tidy is verified on the Linux leg only.** The MSVC-side tidy integration segfaults
locally, so the Linux/Clang leg is the only place the gate has actually been exercised. Treat a
clean local Windows build as *no evidence* about tidy — the Linux leg is the authority.

**Phantom `CI / matrix.name` check on push runs — cosmetic, don't chase it.** The sanitizer
job is `pull_request`-only (`ci.yml` `if: github.event_name == 'pull_request'`, ADR-008 §9
amended + ADR-009 §4). When a job is skipped by a **job-level `if:`** the matrix never
expands, so `name: ${{ matrix.name }}` has no matrix context and GitHub renders the literal
expression — **one** skipped check called `matrix.name` instead of three named ones. On a PR
the job runs, the matrix expands, and the real contexts (`win ASan`, `linux UBSan`,
`linux TSan`) report normally — which is where required checks are evaluated, so branch
rulesets are unaffected. Clean fix if it ever matters: split sanitizers into their own
`pull_request`-only workflow; costs ~40 lines of duplicated setup for a cosmetic win.

## Profiling builds (Tracy) — the pin is two-sided

**Tracy `v0.13.1`** (`cmake/deps.cmake:91`). Recorded here because it is the one dep whose
version is **not** a local matter: Tracy compiles its wire `ProtocolVersion` into client *and*
consumer, so the **Tracy desktop app / `tracy-capture` in use must be the same release**
— a mismatched pair connects to nothing, silently. Bumping the tag means re-downloading the
app ([[ADR-013 — Profiler (Tracy-backed instrumentation)]] §1). Neither tool is built here.

Observed on the first `TE_PROFILE=ON` build (2026-08-03, S3-T3, MSVC only):

- **Default builds are untouched** — the fetch is `if(TE_PROFILE)`-guarded, so `build/windows`
  has no `tracy-src` at all.
- **`/W4 /WX` needed no exemption.** CMake 3.28 emits `-external:W0` beside `-external:I` for
  SYSTEM includes, and Tracy marks its own include dir SYSTEM. No `te_warnings` change.
- **Editing `deps.cmake` invalidates CI's dep cache once** — `ci.yml`'s key is
  `hashFiles('cmake/deps.cmake')`, so the next run re-clones every dep. One-time, per edit.
- **`linux-profile` is unverified and CI never builds it.** The profiled config can rot
  silently on the Clang leg; the named antidote is a nightly profile leg (ADR-008 §9).

### Overhead — measured 2026-08-08 (S3-T6)

`windows-release`, MSVC, one machine, median of 3 runs each.

| Build | µs/frame | vs OFF |
|---|---|---|
| `TE_PROFILE=OFF` | 0.0206 | — |
| ON, no consumer connected | 0.0339 | +0.0133 µs · +65% |
| ON, `tracy-capture` attached | 0.1583 | +0.1377 µs · +669% |

**What the loop was doing** — it is the denominator, so it is half the number. Unpaced (the
60 Hz spin pacer deleted), `advance` fed a synthetic `FIXED_DELTA_TIME` so every frame runs
exactly one fixed tick, `-DTE_LOG_ACTIVE_LEVEL=6` so no log line executes, 100 000 frames.
Per frame: **5 zones + 1 frame mark** — `FrameLoop::advance` · `FixedSteps` · `MakeVisible` ×2 ·
`Retire` · `TE_PROFILER_FRAME`. The harness was a throwaway local patch; none of it merged.

**Against ADR-013 §6's < 5% bar: 0.1377 µs on a 16.6 ms frame is 0.0008%.** Passes by ~6000×.

**The +669% is real and says nothing about the profiler.** The denominator is a loop doing
0.02 µs of work, so §6's *ratio* form is not evaluable at M1 — the absolute per-frame cost is
the checkable figure until the loop has real per-frame content. It becomes a ratio again at
M2's task graph and R1's renderer, which is when §6 says to re-run this anyway.

Two things the three-way split shows, neither of them a problem:

- **Disconnected costs 2.2 ns per call site** (13.3 ns ÷ 6). That is `TRACY_ON_DEMAND`'s
  early-out, and it lands on Tracy's own quoted ~2.25 ns/zone almost exactly.
- **Connected costs ~23 ns per record** (137.7 ns ÷ 6) — ~10× the disconnected path: the queue
  write plus the serialisation thread. Not chased; §6 is not missed, so there is no cause to
  name.

The ON builds also compile in S3-T5's global `new`/`delete` replacement, so the delta covers
every allocation as well as every zone. This loop allocates nothing in steady state, so that
contributes ~0 **here** — which will not survive the first system that allocates per frame.

## Scaffold checklist

Moved — this note fed the ADR, and the ADR is where the checklist landed:
[[ADR-008 — v2 build & testing baseline]] → *Scaffold checklist*, **closed 2026-07-24**
(all green on CI, both legs). Kept in one place so it can't rot in two.
