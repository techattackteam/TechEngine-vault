# Math — Design

> Living design doc. **Status: active.** Drafted in the 2026-08-02 planning session as a
> light artifact ([[Planning Workflow — Artifact Gate]]). ADR-005 chose the library and
> ADR-006 chose the placement, so what was left here is naming and surface. The types were
> built the same day (S3-T1, engine `05cf3718`), with the formatters still owed by S3-T2.
>
> The ADR holds the decision, this doc holds the *how*. No ADR is owed. Math is a `base`
> leaf, and every call below is reversible while `base` is its only consumer. The one
> irreversible question, handedness and depth range, is deliberately **not** answered here.
> See *Open questions*.

**Module:** `base` · **Kind:** utility (a helper you *call*, free functions and types, no lifecycle) ·
**Status:** active
**ADRs:** [[ADR-005 — v2 tech stack & toolchain]] (glm) ·
[[ADR-006 — v2 core architecture & module layout]] §1 §5 §6 ·
[[ADR-011 — Diagnostics (Logger & Assert)]] §1 (`glm::glm` stays PUBLIC on `te_base`)
**Consumers:** everything from M4 on. Transforms (M5), the renderer (R1), physics (S1),
replication (ADR-007 §2). Today there are **none**, which *Trigger* explains.
**Sprint:** [[2026-08 Sprint 03 — M1 Enablers]], S3-T1 and S3-T2

## Purpose

The engine's vector and matrix vocabulary, and nothing else.

Every module from M4 onwards writes its headers against these type names. That is the only
reason this lands at M1 instead of arriving with its first real consumer. Renaming `Vec3`
across thirty headers later is a sweep. Adding a `lerp` later is a single commit.

## Decided

| Fact | Where |
|---|---|
| The library is **glm**. | ADR-005 |
| Math lives in **`base`**, as a helper rather than a service. Free functions and types, no lifecycle. | ADR-006 §5 |
| `glm::glm` is **PUBLIC** on `te_base`, unlike `spdlog::spdlog`. The types are meant to be in our headers. | ADR-011 §1 |
| **Formatters live with math**, not with the Logger. | ADR-006 §6 |
| **Alias, do not wrap.** `using Vec3 = glm::vec3;`, with no engine-owned wrapper type. | This note |
| **`float` is the default precision.** Use `double` only where a domain argues for it. | This note |
| Formatters ship in a **separate header** from the types. | This note, below |
| Handedness and clip depth range are **not** decided here. | This note → *Open questions* |

## Design

### Alias, do not wrap

`using Vec3 = glm::vec3;`, not a `Vec3` class of our own.

A wrapper would buy one thing: a name that stays ours. It would cost every operator, every
glm free function, every `value_ptr` call at the GL boundary, and a conversion at each seam.

The encapsulation a wrapper offers is also something we already decided against. `glm::glm`
is PUBLIC on `te_base` (ADR-011 §1) precisely so these types can appear in our public
headers. An alias gives the rename-proofing, since only one header changes, without paying
that tax.

**The alias is its own escape hatch.** Swapping glm for another library later means editing
`Math.hpp`, plus fixing whatever used glm-only free functions directly. That is the cost we
are accepting, and it is why call sites should prefer the aliases over `glm::` spellings.

### Names

`Vec2/3/4` · `IVec2/3/4` · `UVec2/3/4` · `Mat3` · `Mat4` · `Quat`, in namespace `TechEngine`.

> **This is an explicit exception to `CONVENTIONS.md` → *Names are spelled out*.**
> `Vec3` is not a shortened `Vector3`. It is the domain's own term, and it is what the
> literature, glm, GLSL and every other engine call it. `Vector3` would read as a different
> type. The rule stands everywhere else.

### Surface

Types and formatters only, this sprint. **No helper library.** No `lerp`, no `decompose`, no
easing, no `AABB`.

glm already ships the ones that exist. The rest have no consumer, and Sprint 02 ran the same
pressure test: nothing gets built without a consumer that needs it now.

**The types have no behaviour, so they get no `TEST_CASE`.** `MathTests.cpp` is
`static_assert`s only. They pin each alias to its glm type, and pin `Vec3::value_type` to
`float`. That tests this note's decisions, not glm.

Its real job is smaller and more useful: **something has to compile the header.** Nothing
includes `Math.hpp` yet. Without that translation unit, a broken header would sit in a green
CI run until S3-T2 stumbled on it.

### Formatters get their own header

`std::formatter<TechEngine::Vec3>` and its siblings live in **`Math/Format.hpp`**, not in
`Math.hpp`.

Keeping them together would force `<format>` into every translation unit that wants a vector.
[[Logger — Design]] already carries an open, unmeasured question about what `<format>` costs
in a header that every TU includes. Math would be the second such header, and math is
included far more widely than logging.

Splitting makes that cost opt-in. The price is one extra `#include` at the handful of call
sites that log a vector.

**Shape**, decided at S3-T2 on 2026-08-03:

| Call | Choice |
|---|---|
| Granularity | **Partial specializations over glm's templates**: `glm::vec<L,T,Q>`, `glm::mat<C,R,T,Q>`, `glm::qua<T,Q>`. Three of them, not one per alias. `IVec`, `UVec` and `Mat3` then fall out free. |
| Rendered form | **glm's own spelling**: `vec3(1, 2.5, 3)`, `ivec3(…)`, `mat4((c0…), (c1…))`, `quat(…)`. The type name is in the output, so a log line says what it printed. |
| Format spec | **Forwarded to the elements.** `{0:.2f}` on a `Vec3` gives `vec3(1.00, 2.50, 3.00)`. `parse` delegates to a held `std::formatter<T>`. |
| Quaternion order | **xyzw**, which is storage order. Not `glm::to_string`'s wxyz. The printed components then line up with `q.x` through `q.w` at a breakpoint. This is the one place we diverge from glm. |

The generic partial specialization has one cost: it formats **any** glm vector, not only the
aliased ones. That is accepted. The aliases are the same types underneath, so a narrower
spelling would not have prevented it.

## Trigger

This lands at **M1, ahead of its first consumer.** That is deliberate, and it is an exception
to the consumer rule rather than a violation of it.

The consumer rule exists to stop speculative *behaviour* being built. This is a
**vocabulary**. Vocabulary is exactly the thing that is cheap now and a cross-module rename
later, which is why the [[Roadmap]] chain is ordered by irreversibility.

The pressure test still applies to the surface: types and formatters, and no helper library.

## Open questions

### Handedness and clip depth range

**Deferred to the renderer ADR at R1. Not decided here.**

glm switches both globally, through `GLM_FORCE_LEFT_HANDED` and
`GLM_FORCE_DEPTH_ZERO_TO_ONE`. GL 4.5 defaults to right-handed with a `[-1, 1]` depth range.
A `[0, 1]` range gives better depth precision and is what every other API uses, but it needs
`glClipControl` and shaders that expect it.

That is a renderer decision. Every projection matrix and every depth read is written against
it. Deciding it at M1, with no renderer to check against, would be exactly the "design it
against an imaginary consumer" mistake the [[Roadmap]] chain exists to avoid.

It is named here so it is not a surprise at R1, and because the `GLM_FORCE_*` defines belong
in this header once it is answered.

**Nothing in `Math.hpp` marks the absence.** This note is the only record. An R1 reader who
never opens it will read glm's defaults as a deliberate choice.

### SDK exposure

Deferred to the scripting ADR, the same deferral as
[[ADR-011 — Diagnostics (Logger & Assert)]] §10.

Math is the most likely first type to cross into `te_sdk`, because user Systems read
transforms (ADR-010 §3). So it will be the acid test for whether `TechEngine::sdk` can carry
a glm type without dragging `base` in with it. `TechEngineSDKSmoke` is what would catch a
failure (ADR-008 §7).

### `double` for world coordinates

A large-world question, not an M1 one. Recorded here so the `float` default reads as a
decision rather than an oversight.

## References

- [[ADR-005 — v2 tech stack & toolchain]]: where glm was chosen
- [[ADR-006 — v2 core architecture & module layout]] §1 (base's dependencies) · §5 (the
  helper taxonomy) · §6 (formatters live with math)
- [[Logger — Design]]: the `<format>`-in-a-wide-header cost this note splits around
- `CONVENTIONS.md` → *Names are spelled out*: the rule `Vec3` is an explicit exception to
- Code: `engine/base/include/TechEngine/base/math/Math.hpp` (the alias set) ·
  `engine/base/tests/math/MathTests.cpp` (`static_assert`s only, no `TEST_CASE`, see
  *Surface*) · `engine/base/include/TechEngine/base/math/Format.hpp` ·
  `engine/base/tests/math/MathFormatTests.cpp` (pins the rendered form, S3-T2)
