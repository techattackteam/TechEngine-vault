# StringId — Design

> Living design doc. **Status: active.** The decision itself is
> [[ADR-014 — Events (buffered streams) & StringId]] §1, accepted 2026-08-02.

**Module:** `base` (`base/stringid/StringId.hpp`) · **Kind:** helper (utility)
**ADRs:** [[ADR-014 — Events (buffered streams) & StringId]] §1 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §1 (the consumer that pinned it)

## Purpose

The engine's one hashed-string identity primitive. A `StringId` is a 64-bit FNV-1a hash of a
stable tag, computed at compile time wherever possible.

**Consumers today:** `ComponentTypeId` and `EventTypeId`, both typed wrappers over it.

**Consumers soon:** input action names (M5 action mapping), cvar and console names (the T1
lane), and possibly material and shader parameter names.

**Not consumers:** resources use a UUID model instead (ADR-006 §1). Physics keys off
`Entity` rather than strings, which is F17's fix.

## Decided

| Fact                                                                                                                     | Where                  |
| ------------------------------------------------------------------------------------------------------------------------ | ---------------------- |
| A `u64` FNV-1a hash. Case-sensitive, over the bytes as written. The algorithm is frozen, because disk and wire carry it. | ADR-014 §1             |
| `constexpr` from a literal, through a plain constructor. **No macro**, no `TE_SID`.                                      | ADR-014 §1             |
| No runtime intern table. The identity *is* the hash.                                                                     | ADR-014 §1             |
| Persistent ids must pass a registering seam, which holds a collision `TE_CHECK`. Ad-hoc keys stay unchecked.             | ADR-014 §1             |
| Debug reverse-lookup is tooling-only. Never per-frame.                                                                   | ADR-014 §1, ADR-013 §6 |
| SDK exposure is deferred. The first landing in `sdk/include/` trips the smoke gate by design.                            | ADR-014 §7             |

## Surface

Pinned 2026-08-02, before Story E.

### The type

A struct wrapping a **private** `std::uint64_t`.

It is not an enum class, because an enum cannot carry the hashing constructor. The field is
private, which is a change from the public field first sketched here (2026-08-04, with
S3-T7). Private is what makes the two entry points below the *only* two.

Reading the value back is a `constexpr value()` accessor. The type is what disk and wire
carry, so getting the raw value out is required, and a read reopens nothing.

`==` and `<=>` are defaulted. The `std::hash` specialization returns the value itself, since
the value already is a hash.

`u64` is spelled `std::uint64_t` in code. No alias exists and this card does not add one,
following `CONVENTIONS.md` → *Naming*. That is the same precedent that turned `dt` into
`deltaTime`.

### Construction

There is one canonical path: `constexpr explicit StringId(std::string_view)`.

It runs at compile time inside a constant expression. `constexpr StringId kHit{"Game.Hit"};`
static-asserts the hash at build time. It runs at runtime for names loaded from config, such
as input actions and cvars.

**No macro** (ADR-014 §1). **No user-defined literal for now** either. A `_sid` suffix would
be a second spelling of the same thing, so add it only if ergonomics demand it.

### Rebuilding an id from raw bytes

`static constexpr StringId fromValue(std::uint64_t)`, added 2026-08-04 with S3-T7.

ADR-007 §1 puts the hash on disk and on the wire, so a `StringId` has to be rebuildable from
those bytes. The explicit constructor makes the type a non-aggregate, so `StringId{raw}` will
not compile.

With the member private, this factory is the **only** way a value that was not hashed here
can enter the type. That is an invariant the compiler holds, not a convention we maintain.
So `grep fromValue` really does enumerate every wire and disk entry point, which is the
boundary worth naming for a frozen format.

The alternative shape was an aggregate plus a free `hashTag()` function. That makes *hashing*
the greppable seam instead, and it keeps the type structural, so it could serve as a non-type
template parameter. It was weighed and dropped. Neither shape can enforce "this value came
from a hash", and the C++ shape is reversible where the hash format is not.

### Hash the bytes as `unsigned char`

`char` is signed on both CI legs. XOR-ing it directly sign-extends, so any byte at `0x80` or
above hashes to a different value than the reference vectors give.

The algorithm is frozen, because it is on disk and on the wire. So this is cheap to get right
now and expensive to fix later.

The two published ASCII vectors in *Tests* cannot catch this, since ASCII stays below `0x80`.
The single-high-byte case is what does.

### The sentinel

`StringId{}` has `value == 0` and means invalid, or none.

FNV-1a of the empty string is the offset basis rather than 0, so 0 never collides with a real
literal hash by construction. A tag that happens to *compute* to 0 is rejected by the same
registration `TE_CHECK` that catches collisions.

### Reverse lookup and collision checking

**`base` holds no table.**

The registering seams, meaning the component and event registries in `core`, already receive
the tag string at the composition root. They keep it. That is startup-only and costs trivial
memory.

That stored string then does two jobs. A duplicate id with a different tag fires the
always-on collision `TE_CHECK` (ADR-007 §1). And an id can be mapped back to its tag for
tooling, under ADR-014 §1's rule that reverse lookup is tooling-only and never per-frame.

`StringId` itself stays a pure value type sitting below all of that, which is what layering
requires.

### Formatting

`std::formatter<StringId>` prints the hex value: `0x` followed by 16 fixed-width digits.

It takes **no format spec**. There is one sensible way to render an opaque id, and a silently
ignored spec is worse than a rejected one.

It cannot resolve tags. `base` cannot reach `core`'s registries, per layering. Turning an id
back into its tag is the tooling layer's job.

### Placement

`base/stringid/StringId.hpp`, decided 2026-08-04 with S3-T7. The sibling
`base/stringid/Format.hpp` was folded into it at S4-T1, for the reason below.

This is **not** ADR-014 §1's `base/StringId.hpp`. `CONVENTIONS.md` → *Headers* says one
folder per utility, named after its design note. That rule landed 2026-08-03, a day after the
ADR, and it wins. S3-T4 reached the same resolution for `base/profiler/`. The ADR is not
edited.

**The formatter ships in `StringId.hpp`**, not in a header of its own. This reverses the
S3-T7 call, which followed the Math split on the belief that `<format>` was too heavy to put
in a header everything includes.

S4-T1 measured that belief on 2026-08-29 and it did not hold. `<chrono>` already contains all
of `<format>`, so any TU that logs has paid for it already. Splitting saved **+7 ms on MSVC**
in such a TU. The reasoning and the condition that would reverse it live in
[[Math — Design]] § *Formatters ship with the types*; the numbers are in
[[B3 — Build & Testing Notes]] § *`<format>` header weight*.

It does **not** ride on `diagnostics/FormatString.hpp`. That file is the positional
format-string wrapper. It is not a home for formatters.

### Tests

Write these with the card.

- The known FNV-1a/64 vectors: `""` → `0xcbf29ce484222325`, `"a"` → `0xaf63dc4c8601ec8c`,
  `"foobar"` → `0x85944171f73967e8`.
- A **single `0x80` byte**, checked against the algorithm restated by hand for one byte. This
  is the signed-`char` trap above, and no ASCII vector reaches it.
- A `static_assert` proving the hash evaluates at compile time.
- Case sensitivity, so two tags differing only in case give different ids.
- The sentinel is invalid.
- A runtime `std::string` and a compile-time literal produce the same id.
- `fromValue` round-trips.

The collision `TE_CHECK` on a duplicate-id-different-tag registration **lands with the
registry at S3-T8**, not here. `base` holds no table to check against.

## Open (deliberately)

### Runtime hashing on hot paths

`StringId{"Game.Hit"}` is free *only* inside a constant expression. Anywhere else it re-hashes
the string on every call, and a Debug build folds nothing.

This is ADR-013 §6's per-frame-names trap wearing a different hat.

The convention is a `static constexpr` local at the call site. What is open is whether that
needs a CI grep to enforce, or whether the habit is enough. **Owner:** the first hot consumer,
which is M5 input actions.

### Untrusted ids

FNV-1a is not collision-resistant. Given one tag, constructing a second tag that collides with
it is cheap.

ADR-007 §1 puts `ComponentTypeId` on the wire. So a **peer-supplied id must be resolved
against the registry, and rejected if it is unknown.** It is never trusted as identity, and
never used to index anything before that check.

The registry's `TE_CHECK` at S3-T8 catches *authoring* collisions only. This is a different
threat and needs a different answer. **Owner:** the netcode transport ADR at M4. No note
exists for it yet, so this line is the only record.

### UDL sugar

`"…"_sid`, only if literal-heavy call sites end up demanding it. A naming pass, not a design
question.

### SDK exposure

Goes to the scripting ADR. The first `StringId` landing in `sdk/include/` will trip the smoke
gate, by design (ADR-014 §7).

## References

- [[ADR-014 — Events (buffered streams) & StringId]] §1: the rationale and the alternatives.
  An interned pointer and `type_index` were both rejected there.
- FNV-1a 64: offset basis `14695981039346656037`, prime `1099511628211`
