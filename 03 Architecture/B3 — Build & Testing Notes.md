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
  Re-tested 2026-08-24, rule stands: see *Source listing* below.
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

## Source listing: re-tested 2026-08-24 (S4-P2)

The **No `GLOB`** rule above came from v1's F6 and was never re-tested against v2. S4-P2
tested it. **The rule stands, unchanged.** What did change is
[[ADR-008 — v2 build & testing baseline]] §2, which stated the rule without ever naming the
condition that would reopen it. It now carries one.

### What the tree costs today

Measured across the whole repo at engine `a0d1d1b3`:

| Measure | Value |
|---|---|
| Tracked `.cpp` and `.hpp` files | 74 |
| Commits on `master` | 54 |
| Commits that added a source file | 21, median 2 to 3 files each |
| `.cpp` files on disk missing from a `SOURCES` list | **0** |
| Headers on disk missing from a `HEADERS` list | **4** |

The explicit list costs roughly **one added line per new file**, and it has never once been
wrong for a `.cpp`. That is the entire tax the alternatives exist to remove.

The four header misses are `base/src/diagnostics/{FormatBuffer,LogInternal,SourceName}.hpp`
and `core/tests/events/AssertCapture.hpp`. `HEADERS` is IDE grouping only
(`cmake/techengine_module.cmake:3`), so nothing builds differently. `sdk` and
`tests/support` list no headers at all, and that is correct: both are INTERFACE targets.

### The three options

| Option | Cost here | How it fails |
|---|---|---|
| **Explicit lists** (current) | ~1 line per new file | An unlisted `.cpp` fails **loud** at link. It is silent only when nothing references its symbols. |
| **`CONFIGURE_DEPENDS` glob** | A directory re-scan on every build | The portability guarantee does not exist. See the quote below. |
| **Generator script** | A new tool, plus a CI check to catch a stale list | It trades a one-line edit for a tool to maintain, and drift only becomes visible when CI runs. |

CMake's own documentation is the deciding evidence against the glob. It says plainly:

> "We do not recommend using GLOB to collect a list of source files from your source tree."
> ([`file()` command reference](https://cmake.org/cmake/help/latest/command/file.html))

The same paragraph adds that `CONFIGURE_DEPENDS` may not work reliably on all generators, and
it **declines to name which generators do work**. That silence is the finding. Our two legs
are both Ninja and would very likely work today, but there is no contract to hold CMake to,
and a future generator move would be a second F6.

### The one case where the explicit list fails silently

A `.cpp` whose only job is **self-registration** has no symbol that any other TU references.
Forget to list it and it does not fail to link. It simply is not there, and the type it would
have registered is missing at runtime.

This is not hypothetical here. ADR-016's type-registration seam, and the event and component
registries, are exactly that shape.

**The fix, when it arrives, is a CI staleness check, not a glob.** A glob would solve it by
removing the list, which costs the filtering the list does: a throwaway demo `.cpp` under
`src/` must not enter the build. A check keeps both.

### Decided

- **`SOURCES` and `HEADERS` both stay explicit.** One mechanism, not two. Relaxing `HEADERS`
  alone was considered and declined: it buys back cosmetic drift at the price of a second
  rule inside the same helper.
- **`CONVENTIONS.md` is unchanged.** Its *CMake* section already carries the rule, correctly.
- **The four drifted headers ride along** with the next card that touches `base` or `core`.
  They are IDE grouping only, so they may sit a while, and that is acceptable.

## Code coverage (S4-P3, 2026-08-27)

Clang source-based coverage on the Linux leg. The instrumentation flags ride `te_warnings`
(`cmake/coverage.cmake`), so first-party targets are measured and FetchContent deps never are.
`techengine_test()` appends each test exe to a global `TE_TEST_TARGETS` property and
`cmake/coverage_report.cmake` builds llvm-cov's `-object` list from it, so a new module needs
no coverage edit.

**The gate is 85% of changed lines, not of the project.** A global threshold falls every time
`client` grows, because rendering is proven by demo scenes rather than unit tests, and a gate
bypassed weekly teaches nothing. `diff-cover` computes it against the merge base.

**The bypass is `[skip-coverage]` in the pull request description.** The job still runs and
still reports: a required check skipped by a workflow `if:` never reports its context at all,
which leaves the pull request pending forever instead of mergeable.

### Running it locally

Two commands, and CI runs the identical target. Threshold, base branch and the bypass all
come from the environment, so there is no second code path to drift.

```bash
cmake --preset linux-coverage
cmake --build --preset linux-coverage --target coverage
```

The browsable per-file report lands at `build/linux-coverage/coverage/html/index.html`.

### Setup, and the four things that bit

Miguel develops on Windows, so local coverage means WSL. **Use Ubuntu 24.04**, because
`ubuntu-latest` is 24.04 and 22.04's libstdc++ 11 has neither `<format>` nor
`chrono::clock_cast`, so the tree does not compile there at all.

- **`diff-cover` is pinned to the version CI pins**, checked at configure time rather than
  after a build and 183 tests. The distro package is older and its CLI differs: it wants
  `--markdown-report FILENAME` where this expects `--format markdown:PATH`. Install with
  `pipx install diff-cover==10.5.1`, then `pipx ensurepath` and a new shell.
- **Set `core.autocrlf true` in WSL** when working through `/mnt/c`. Windows has it on and
  there is no `.gitattributes`, so the working tree holds CRLF while the index holds LF. WSL
  git defaults to `false`, sees every line of every file as modified, and diff coverage then
  measures the entire codebase instead of the diff.
- **Never build with `sudo`.** It leaves root-owned files in `build/` and in the tests' own
  `/tmp/TechEngineTests` scratch root, and the next ordinary run fails on permissions for an
  unrelated-looking reason. `/mnt/c` needs no elevation.
- **`llvm` is a separate apt package** from `clang`, and `llvm-profdata` must match clang's
  major version or the merge fails on an unsupported profile format.

### First numbers, 2026-08-27

Measured locally on `linux-coverage`, 183 of 183 tests passing under instrumentation.

| Scope | Regions | Lines |
|---|---|---|
| Whole project | 85.57% | 94.80% |
| The serialization card's diff (`4928447c...`) | — | 91% of 365 changed lines |

That second row is the useful one: real work on this codebase clears the 85% bar without
being written for it. **The CI minute cost is still unmeasured**, because the job has not run
yet. It belongs in this section once it has.

## ccache keys (S4-P1, 2026-08-28)

`hendrikmuhs/ccache-action` appends a timestamp to the key by default, so every run saved
under a fresh name and nothing ever replaced anything. Restores were fine throughout, via the
prefix match, at 100% hits. The growth was pure write-side: **111 entries and 3.62 GB in four
days**, roughly 1.2 to 1.6 GB per active dev day, against GitHub's 10 GB repo cap.

The key is now `v1-<leg>-<hash of cmake/deps.cmake>` with `append-timestamp: false`. GitHub
cache entries are immutable, so a stable key means an unchanged-deps run hits the primary key
and skips the save. A new entry appears only when a dependency actually moves. This is the
same content-addressed shape the `deps-*` cache has used from the start, which is why that one
has always sat at two entries per OS.

**Why it is keyed on deps and not on sources.** 140 of the 183 cacheable compilations are
dependencies (Jolt, glfw, spdlog, tomlplusplus, glm, Catch2), and those only change when
`deps.cmake` does. The other 43 are engine TUs, which stop being cached across runs and
recompile every time, worst case all 43 when a common header moves. **Revisit when engine TUs
stop being a small minority of the total.** Today it is 43 against 140.

### The failure mode it cannot recover from

ccache hashes the compiler internally, so a runner image bumping clang or MSVC invalidates
every entry. Because the save is skipped, nothing repopulates it, and every run then compiles
cold under a key that still looks valid. **The symptom is the `ccache stats` step falling from
high hits to near zero**, and the fix is bumping the `v1` segment in the key. That segment
exists only so the recovery is a one-character edit rather than a redesign under pressure.

## Docs-only PRs (S4-P4, 2026-08-28)

A change that cannot alter a build artifact does not get a build. `ci.yml` carries
`paths-ignore` for **three** paths: `**.md`, `.claude/**` and `.github/workflows/**`.
Everything else still runs the full matrix, `.gitignore` and `.githooks/` included. The rule
itself lives in `ci.yml`'s header, not here, because a fresh clone has no `docs/` (ADR-012 §1).

> **Corrected 2026-08-29.** This section shipped saying "the workflow files included, still
> runs the full matrix". That was true when it was written and false hours later: the third
> path landed the same day and nothing swept the note. Workflow files are now the one thing
> that does **not** get a build.

`ci-docs.yml` is the other half. A workflow skipped by a path filter never reports its
contexts, and a required context that never reports leaves the PR pending rather than
mergeable, so a stand-in has to report the same names. It is one matrix job spelling all nine.

**Cost, measured on #52:** **9 billed minutes against 16.1** for a real run. The saving is
about 44%, not the ~100% the card assumed, because GitHub rounds **every job up to the
nearest minute** and nine trivial jobs are still nine jobs. The cheaper shape, if that stops
being enough, is one job posting nine check runs through the Checks API for ~1 minute, at the
price of a token permission and more moving parts.

### Three things that bite

- **`ci.yml` is never tested by its own PR.** It excludes `.github/workflows/**`, so breaking
  the YAML, renaming a leg or dropping a job still shows nine green checks from the stand-in
  and merges clean. It is worse than it looks: `ci-docs.yml` hardcodes the nine context names,
  so renaming a leg silently uncovers it and every later docs-only PR hangs unmergeable with
  no clue why. **A workflow change is verified by watching the run it produces on `master`,
  never by its own PR.** Land workflow edits alone and read the next run before building on
  them. Same shape as S4-P1, whose fix merged its own verification out of reach.
- **A skipped matrix job does not expand.** Measured on #49's push run, where `sanitizers`
  was skipped by its `if:`: it reported **one** check literally named `matrix.name`, and
  `win ASan` / `linux UBSan` / `linux TSan` reported nothing at all. A skipped *plain* job is
  different and does keep its context (`diff coverage` came back `skipped`). Seven of the nine
  required contexts are matrix legs, so gating the real jobs with `if:` would hang every
  docs-only PR. This is why the stand-in is a separate workflow.
- **A mixed PR fires both workflows.** `paths` matches when *any* changed file matches, while
  `paths-ignore` skips only when *all* of them do, and Actions has no "all changed files
  match" filter. Both then report the same nine contexts and the merge box takes the most
  recent per name, which is the real run. That is ordering, not a guarantee: it holds only
  while the stand-in stays seconds long.

## Scaffold checklist

Moved — this note fed the ADR, and the ADR is where the checklist landed:
[[ADR-008 — v2 build & testing baseline]] → *Scaffold checklist*, **closed 2026-07-24**
(all green on CI, both legs). Kept in one place so it can't rot in two.
