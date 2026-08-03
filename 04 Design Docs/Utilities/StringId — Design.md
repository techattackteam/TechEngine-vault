# StringId — Design

> Living design doc. **Status: active** — the decision is
> [[ADR-014 — Events (buffered streams) & StringId]] §1 (**Accepted 2026-08-02**).

**Module:** `base` (`base/StringId.hpp`) · **Kind:** helper (utility)
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
| `constexpr` from literal; `TE_SID("…")` | ADR-014 §1 |
| No runtime intern table; identity = the hash | ADR-014 §1 |
| Persistent ids must pass a registering seam (collision `TE_CHECK`); ad-hoc keys unchecked | ADR-014 §1 |
| Debug reverse-lookup tooling-only, never per-frame | ADR-014 §1, ADR-013 §6 |
| SDK exposure deferred; first `sdk/include/` landing trips the smoke gate by design | ADR-014 §7 |

## Design — surface (pinned 2026-08-02, pre-Story-E)

**Type shape.** `struct StringId { u64 value; }` — plain struct, not enum-class (an
enum can't carry the hashing constructor). Defaulted `==` / `<=>`; `std::hash`
specialization is the identity (the value *is* a hash).

**Construction.** One canonical path: `constexpr explicit StringId(std::string_view)`.
Compile-time in constant expressions (`constexpr StringId kHit{"Game.Hit"};`
static-asserts the hash at build time), runtime for config-loaded names (input actions,
cvars). **No macro** (ADR-014 §1), **no UDL for now** — a second spelling of the same
thing; add only if ergonomics demand it.

**Sentinel.** `StringId{}` (`value == 0`) = invalid/none. FNV-1a of `""` is the offset
basis, not 0, so 0 never collides with a real literal hash by construction; a tag that
*computes* to 0 is rejected by the same registration `TE_CHECK` as a collision.

**Reverse lookup & collision check — `base` holds no table.** The registering seams
(component/event registries, `core`) already receive the tag string at the composition
root; they **keep it** (startup-only, trivial memory). That storage does double duty:
duplicate id + different tag ⇒ the always-on collision `TE_CHECK` (ADR-007 §1); id → tag
queries for tooling (ADR-014 §1's tooling-only rule — never per-frame). `StringId`
itself stays a pure value type below everything, per layering.

**Formatting.** `std::formatter<StringId>` prints the hex value; it cannot resolve tags
(`base` can't reach `core` registries — layering). Tag resolution is the tooling layer's
job. Header placement follows the Math split (formatters separate from the type);
whether it rides the existing `base/diagnostics/FormatString.hpp` or its own header is an implementation
call.

**Tests (write with the card).** Known FNV-1a/64 vectors (`""` →
`0xcbf29ce484222325`, `"a"` → `0xaf63dc4c8601ec8c`); `static_assert` on constexpr
evaluation; case-sensitivity (differing case ⇒ differing id); sentinel invalid;
collision `TE_CHECK` fires on duplicate-id-different-tag registration.

## Open (deliberately)

- **UDL sugar** (`"…"_sid`) — only if literal-heavy call sites demand it; naming pass.
- **SDK exposure** — scripting ADR; first `sdk/include/` landing trips the smoke gate
  by design (ADR-014 §7).

## References

- [[ADR-014 — Events (buffered streams) & StringId]] §1 — rationale + alternatives
  (interned pointer, `type_index` — both rejected)
- FNV-1a 64: offset `14695981039346656037`, prime `1099511628211`
