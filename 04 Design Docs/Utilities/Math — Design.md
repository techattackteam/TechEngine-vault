# Math — Design

> Living design doc. **Status: draft** — drafted in the 2026-08-02 planning session (light
> artifact per [[Planning Workflow — Artifact Gate]]: the library was chosen in ADR-005 and
> the placement in ADR-006; what's left is naming and surface).
> **ADR = the decision; this doc = the _how_.** No ADR is owed — math is a `base` leaf and
> every call below is reversible while `base` is its only consumer. The **one** irreversible
> question (handedness + depth range) is deliberately **not answered here** — see *Open questions*.

**Module:** `base` · **Kind:** utility (helper you *call* — free functions/types, no lifecycle) ·
**Status:** draft
**ADRs:** [[ADR-005 — v2 tech stack & toolchain]] (glm) ·
[[ADR-006 — v2 core architecture & module layout]] §1 §5 §6 ·
[[ADR-011 — Diagnostics (Logger & Assert)]] §1 (`glm::glm` stays PUBLIC on `te_base`)
**Consumers:** everything from M4 on — transforms (M5), the renderer (R1), physics (S1),
replication (ADR-007 §2). Today: **none** — see *Trigger*.
**Sprint:** [[2026-08 Sprint 03 — M1 Enablers]] — S3-T1 / S3-T2

## Purpose

The engine's vector/matrix vocabulary, and **nothing else**. Every module from M4 on writes its
headers against these type names, which is the only reason this lands at M1 rather than with its
first real consumer: renaming `Vec3` across thirty headers later is a sweep, adding a `lerp`
later is a commit.

## Decided

| Fact | Where |
|---|---|
| The library is **glm** | ADR-005 |
| Math lives in **`base`**, as a **helper (utility)** — free functions/types, no service | ADR-006 §5 |
| `glm::glm` is **PUBLIC** on `te_base` (unlike `spdlog::spdlog`) — the types are in our headers by design | ADR-011 §1 |
| **Formatters live with math**, not the Logger | ADR-006 §6 |
| **Alias, don't wrap** — `using Vec3 = glm::vec3;`, no engine-owned wrapper type | this note |
| **`float` is the default precision**; `double` only where a domain argues for it | this note |
| Formatters ship in a **separate header** from the types | this note, below |
| Handedness + clip depth range are **not decided here** | this note → *Open questions* |

### Alias, don't wrap

A wrapper buys a stable name and costs every operator, every glm free function, every
`value_ptr` at the GL boundary, and a conversion at each seam. glm is already PUBLIC on
`te_base` (ADR-011 §1) precisely because these types are meant to be in our public headers —
so the encapsulation a wrapper would buy is one we already decided not to want. The alias gives
the rename-proofing (one header changes) without the tax.

**The escape hatch is the alias itself:** swapping glm for another library later means editing
`Math.hpp`, plus whatever used glm-only free functions directly. That is the cost we are
accepting, and it is why call sites should prefer the aliases over `glm::` spellings.

### Names

`Vec2/3/4` · `IVec2/3/4` · `UVec2/3/4` · `Mat3` · `Mat4` · `Quat`, in namespace `TechEngine`.

> **Explicit exception to `CONVENTIONS.md` → *Names are spelled out*.** `Vec3` is the domain's
> own term, not a shortened `Vector3` — it is what the literature, glm, GLSL and every engine
> call it, and `Vector3` would read as a different type. The rule stands everywhere else.

### Surface

Types + formatters only, this sprint. **No helper library**: no `lerp`, no `decompose`, no
easing, no `AABB`. glm already ships the ones that exist, and the rest have no consumer — the
same pressure test Sprint 02 ran (nothing built without a consumer *now*).

### Formatters in their own header

`std::formatter<TechEngine::Vec3>` etc. live in **`Math/Format.hpp`**, not `Math.hpp`.

Putting them together forces `<format>` into every TU that wants a vector. [[Logger — Design]]
already carries an unmeasured open question about `<format>`'s compile cost in a header every
TU includes; math would be the second such header, and math is included **far** more widely
than logging. Splitting keeps that cost opt-in and costs one `#include` at the handful of call
sites that log a vector.

## Trigger

**M1, ahead of its first consumer** — deliberate, and the exception to the consumer rule rather
than a violation of it. The consumer clause exists to stop *speculative behaviour* being built;
this is a **vocabulary**, and vocabulary is exactly the thing that is cheap now and a
cross-module rename later ([[Roadmap]] — the chain is ordered by irreversibility).

The pressure test still applies to the *surface*: types and formatters, no helper library.

## Open questions

- **Handedness + clip depth range → the renderer ADR (R1), not here.** glm switches this
  globally (`GLM_FORCE_LEFT_HANDED`, `GLM_FORCE_DEPTH_ZERO_TO_ONE`) and GL 4.5 defaults to
  right-handed with a `[-1, 1]` depth range, while `[0, 1]` — better depth precision, and what
  every other API uses — needs `glClipControl` and matching shader expectations. That is a
  **renderer** decision written against by every projection matrix and depth read; deciding it
  at M1 with no renderer would be exactly the "designs it against an imaginary consumer"
  mistake the [[Roadmap]] chain exists to avoid. **Named here so it is not a surprise at R1** —
  and because the `GLM_FORCE_*` defines belong in this header when it is answered.
- **SDK exposure → the scripting ADR**, same deferral as [[ADR-011 — Diagnostics (Logger &
  Assert)]] §10. Math is the **most likely first type to cross** into `te_sdk` (user Systems
  read transforms, ADR-010 §3), so it will be the acid test for whether `TechEngine::sdk` can
  carry a glm type without dragging `base` in — `TechEngineSDKSmoke` is what would catch it
  (ADR-008 §7).
- **`double` for world coordinates** — a large-world question, not an M1 one. Recorded so the
  `float` default reads as a decision.

## References

- [[ADR-005 — v2 tech stack & toolchain]] — glm chosen
- [[ADR-006 — v2 core architecture & module layout]] §1 (base's deps) · §5 (helper taxonomy) ·
  §6 (formatters live with math)
- [[Logger — Design]] — the `<format>`-in-a-wide-header cost this note splits around
- `CONVENTIONS.md` → *Names are spelled out* — the rule `Vec3` is an explicit exception to
- Code: *(none yet — S3-T1/S3-T2)*
