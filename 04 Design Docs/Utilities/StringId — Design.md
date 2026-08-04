# StringId — Design

> Living design doc. **Status: active** — the decision is
> [[ADR-014 — Events (buffered streams) & StringId]] §1 (**Accepted 2026-08-02**).

**Module:** `base` (`base/stringid/StringId.hpp`) · **Kind:** helper (utility)
**ADRs:** [[ADR-014 — Events (buffered streams) & StringId]] §1 ·
[[ADR-007 — v2 networking & ECS replication foundation]] §1 (the consumer that pinned it)

## Purpose

The one hashed-string identity primitive: `u64` FNV-1a of a stable tag, `constexpr`.
Consumers **today**: `ComponentTypeId` and `EventTypeId` (typed wrappers). Near:
input action names (M5 action mapping), cvar/console names (T1 lane), maybe
material/shader parameter names. **Not**: resources (UUID model, ADR-006 §1) ·
physics keys (F17's fix keys off `Entity`, not strings).

## Decided

| Fact | Where |
|---|---|
| `u64` FNV-1a, case-sensitive, bytes-as-written — frozen (disk + wire carry it) | ADR-014 §1 |
| `constexpr` from a literal via a plain ctor — **no macro**, no `TE_SID` | ADR-014 §1 |
| No runtime intern table; identity = the hash | ADR-014 §1 |
| Persistent ids must pass a registering seam (collision `TE_CHECK`); ad-hoc keys unchecked | ADR-014 §1 |
| Debug reverse-lookup tooling-only, never per-frame | ADR-014 §1, ADR-013 §6 |
| SDK exposure deferred; first `sdk/include/` landing trips the smoke gate by design | ADR-014 §7 |

## Design — surface (pinned 2026-08-02, pre-Story-E)

**Type shape.** A struct over a **private** `u64` — not an enum-class (an enum can't carry
the hashing constructor), and **not the public field first sketched here**: private is what
makes the two entry points below the *only* ones (2026-08-04, with S3-T7). Read access is a
`constexpr value()` accessor — the type is what disk and wire carry, so getting the value
out is required, and a read reopens nothing. Defaulted `==` / `<=>`; `std::hash`
specialization is the identity (the value *is* a hash). `u64` is spelled
`std::uint64_t` in code — no alias exists and this card does not add one
(`CONVENTIONS.md` → *Naming*, the same `dt` → `deltaTime` precedent).

**Construction.** One canonical path: `constexpr explicit StringId(std::string_view)`.
Compile-time in constant expressions (`constexpr StringId kHit{"Game.Hit"};`
static-asserts the hash at build time), runtime for config-loaded names (input actions,
cvars). **No macro** (ADR-014 §1), **no UDL for now** — a second spelling of the same
thing; add only if ergonomics demand it.

**Raw-value round-trip: `static constexpr StringId fromValue(u64)`** *(2026-08-04, with
S3-T7)*. ADR-007 §1 puts the hash on disk and the wire, so a `StringId` must be
rebuildable from bytes — and the explicit ctor makes the type a non-aggregate, so
`StringId{raw}` cannot. With the member private, the factory is the **only** way a value
that was not hashed here enters the type — an invariant the compiler holds, not a
convention, so `grep fromValue` really does enumerate every wire/disk entry point. That is
the boundary worth naming for a frozen format. The alternative shape — aggregate + a free
`hashTag()`, which makes *hashing* the greppable seam and keeps the type structural
(usable as a non-type template parameter) — was weighed and dropped; neither shape
enforces "this came from a hash", and the C++ shape is reversible where the hash is not.

**Hash the bytes as `unsigned char`.** `char` is signed on both legs, so XOR-ing it
directly sign-extends and any byte ≥ `0x80` hashes to a different value than the
reference vectors. The algorithm is frozen (disk + wire), so this is cheap to get right
now and expensive later. The two published ASCII vectors below **cannot** catch it — the
single-high-byte case in the tests is what does.

**Sentinel.** `StringId{}` (`value == 0`) = invalid/none. FNV-1a of `""` is the offset
basis, not 0, so 0 never collides with a real literal hash by construction; a tag that
*computes* to 0 is rejected by the same registration `TE_CHECK` as a collision.

**Reverse lookup & collision check — `base` holds no table.** The registering seams
(component/event registries, `core`) already receive the tag string at the composition
root; they **keep it** (startup-only, trivial memory). That storage does double duty:
duplicate id + different tag ⇒ the always-on collision `TE_CHECK` (ADR-007 §1); id → tag
queries for tooling (ADR-014 §1's tooling-only rule — never per-frame). `StringId`
itself stays a pure value type below everything, per layering.

**Formatting.** `std::formatter<StringId>` prints the hex value, `0x` + 16 digits, fixed
width; it takes **no format spec** (there is one sensible rendering of an opaque id, and
a silently-ignored spec is worse than a rejected one). It cannot resolve tags (`base`
can't reach `core` registries — layering); tag resolution is the tooling layer's job.

**Placement** *(2026-08-04, with S3-T7)*. `base/stringid/StringId.hpp` +
`base/stringid/Format.hpp` — **not** ADR-014 §1's `base/StringId.hpp`. `CONVENTIONS.md` →
*Headers* (folder per utility, named after its design note) landed 2026-08-03, a day after
the ADR, and wins; the same resolution S3-T4 reached for `base/profiler/`. The ADR is not
edited. The formatter gets its own header per the Math split — `<format>` is a heavy
include and this type is pulled in by everything that carries an id. It does **not** ride
`diagnostics/FormatString.hpp`: that file is the positional-format-string wrapper, not a
home for formatters.

**Tests (write with the card).** Known FNV-1a/64 vectors (`""` →
`0xcbf29ce484222325`, `"a"` → `0xaf63dc4c8601ec8c`, `"foobar"` →
`0x85944171f73967e8`); a **single `0x80` byte** against the algorithm restated for one
byte — the signed-`char` trap above, which no ASCII vector reaches; `static_assert` on
constexpr evaluation; case-sensitivity (differing case ⇒ differing id); sentinel invalid;
runtime `std::string` and compile-time literal agree; `fromValue` round-trips. Collision
`TE_CHECK` fires on duplicate-id-different-tag registration — **that one lands with the
registry (S3-T8)**, not here; `base` holds no table.

## Open (deliberately)

- **Runtime hashing on hot paths** — `StringId{"Game.Hit"}` is free *only* in a constant
  expression. In a non-constexpr context it re-hashes on every call, and Debug folds nothing
  — ADR-013 §6's per-frame-names trap wearing a different hat. The convention is a
  `static constexpr` local at the call site; open is whether that needs a CI grep or just the
  habit. **Owner:** the first hot consumer (M5 input actions).
- **Untrusted ids** — FNV-1a is not collision-resistant: given one tag, a second colliding
  tag is cheap to construct. ADR-007 §1 puts `ComponentTypeId` on the wire, so a
  **peer-supplied id must resolve against the registry and be rejected if unknown** — never
  trusted as identity, and never used to index anything before that check. The registry's
  `TE_CHECK` (S3-T8) catches *authoring* collisions only; this is a different threat. **Owner:**
  the netcode transport ADR (M4) — no note exists yet, so this line is the only record.
- **UDL sugar** (`"…"_sid`) — only if literal-heavy call sites demand it; naming pass.
- **SDK exposure** — scripting ADR; first `sdk/include/` landing trips the smoke gate
  by design (ADR-014 §7).

## References

- [[ADR-014 — Events (buffered streams) & StringId]] §1 — rationale + alternatives
  (interned pointer, `type_index` — both rejected)
- FNV-1a 64: offset `14695981039346656037`, prime `1099511628211`
