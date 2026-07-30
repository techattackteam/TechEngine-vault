# 📐 B4 — Code Conventions

> **Moved 2026-07-25 → root `CONVENTIONS.md`.** The rules now live **next to the code**, at
> the repo root, where a contributor or AI reads them without the vault. This note is the
> vault-side pointer + the decision history; it holds **no rules**, so the two cannot drift.
>
> **Go to `CONVENTIONS.md`** (repo root) for naming, internal linkage, comments, includes,
> headers and CMake conventions.

**Task:** S2-T10 ([[2026-08 Sprint 02 — Base Foundation]]) — running **in parallel** with the
`base` tasks rather than late in the sprint, so a convention lands the day it's decided instead
of being reconstructed at sprint end. The "schedule late" trigger (*needs real code to have
opinions about*) fired on S2-T2.

## Why the split

| | Home | Holds |
|---|---|---|
| **Rules** | `CONVENTIONS.md` (repo root) | The house style. One home — no restating. |
| **Mechanical subset** | `.clang-format`, `.clang-tidy` | CI-enforced; wins on any conflict with prose. |
| **Short subset** | `CLAUDE.md` → *Code conventions* | What AI loads every session; points at the root file. |
| **Decisions / history** | this note | Why a convention changed, and when. |

## Decision history

- **2026-07-25 — comments bar raised.** "Comment *why*, not *what*" was already in force and
  still produced narrated code (the S2-T2 Logger scaffold). Replaced with **default: no
  comment** + three exceptions (gotcha · `TODO(S2-Tn)` · `§ref`). Driver: Miguel's review.
- **2026-07-25 — anonymous namespaces demoted.** `static` at file scope is the default for
  internal linkage; `namespace {}` is a last resort earned only by a `.cpp`-local type with a
  real ODR collision risk. Driver: Miguel's review of the same scaffold. The S2-T2 files were
  refactored to match (zero anonymous namespaces in `engine/`, `apps/`, `sdk/`).
- **2026-07-25 — constants are `SCREAMING_SNAKE_CASE`**, not `kPascalCase`. Overturns the
  provisional call Claude scaffolded from the ADRs' illustrative `kFixedDt`. `TE_` now carries
  the macro/constant distinction (both are `SCREAMING_SNAKE`). Driver: Miguel.
- **2026-07-25 — include order is ours-first, and mechanically enforced.** Our headers before any
  external or std header, tests included. Rationale: an external header above ours can satisfy
  what our header forgot to include, hiding the omission until the next call site — ours-first
  forces headers to be self-sufficient, which is what keeps include counts down. Moved from a
  remembered rule to `.clang-format` (`IncludeBlocks: Regroup` + `IncludeCategories` +
  `IncludeIsMainRegex: '(Tests)?$'`), so CLion and CI both enforce it and **no IDE
  configuration is needed**. Driver: Miguel.
- **2026-07-25 — private plumbing gets a CI guard, not just a naming convention.** Miguel
  demonstrated the hole by calling `TE_DETAIL_LOG` from `apps/editor`. Macros have no access
  control and `detail::` is a convention, so the boundary moved into `ci.yml`
  (*No reaching into private plumbing*), sibling to the `te_sdk_smoke` leak gate. Renamed
  `TE_DETAIL_LOG`/`TE_DETAIL_NO_LOG` → `TE_LOG_PRIVATE_EMIT`/`TE_LOG_PRIVATE_DISCARD`.
  Driver: Miguel.
- **2026-07-25 — formatting authority corrected.** This note previously claimed the CLion
  scheme was authoritative and a `.clang-format` "would be ignored" — written before the
  scaffold landed. The CI format gate has been live since 2026-07-20; `.clang-format` is the
  source of truth. (`ColumnLimit: 100`, not the 380 an earlier draft claimed — the file has since
  carried 380, then 280; read the checked-in `.clang-format`, never this line.)
- **2026-07-30 — names are spelled out.** `deltaTime`, not `dt`; the loop's `dt`/`fixedDt` were
  the trigger (S2-T7). Rule + its carve-outs (acronyms, domain notation, terms of art) live in
  `CONVENTIONS.md` → *Names are spelled out*; the ADRs' `dt`/`kFixedDt` spelling is read through
  it, not edited. `base` predates the rule and still carries `loc`/`fmtStr` — retrofit is a
  [[Backlog]] entry with a next-time-you-touch-it trigger, not a rename pass. Same day,
  `.clang-format` went `ColumnLimit: 380 → 280` with argument bin-packing off. Driver: Miguel.

## Open — local ergonomics (not a code rule)

- If CLion still has `EnableClangFormatSupport=false`, turn it **on** so the IDE and CI agree —
  otherwise local saves drift and CI catches it late.

## Related

- **`CONVENTIONS.md`** (repo root) — the rules.
- [[ADR-008 — v2 build & testing baseline]] §8 ("net-new build conventions feed B4") ·
  [[B3 — Build & Testing Notes]] — the build side.
- [[ADR-006 — v2 core architecture & module layout]] — the module graph the names describe.
