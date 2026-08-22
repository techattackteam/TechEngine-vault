# Serialization — Design

> Living design doc. **Status: active.** The decisions live in
> [[ADR-016 — Serialization (binary primitives & describe-once seam)]]; this note is the
> working shape. Created with the ADR at S4-D2 (2026-08-22), mechanism pinned ahead of the
> implementation cards.

**Module:** `core` · **Kind:** system · **Status:** active
**ADRs:** [[ADR-016 — Serialization (binary primitives & describe-once seam)]] ·
[[ADR-005 — v2 tech stack & toolchain]] · [[ADR-007 — v2 networking & ECS replication
foundation]] §1 §2 · [[ADR-014 — Events (buffered streams) & StringId]] §1
**Roadmap:** M2 builds the primitives and the seam · M3 brings the file writer · M5/M6/T4/N3
bring the document schemas · consumers registered, none built for (ADR-016 §6)

## Decided

| Fact | Where |
|---|---|
| Two paths, one seam: trivially-copyable spans copy as raw bytes; everything else is visited. | ADR-016 §1 |
| One `visit` function per non-POD type; `Writer` and `Reader` are visitors over it. | ADR-016 §2 |
| The visit function is the reflection seam: P2996 would generate it, nothing downstream moves. | ADR-016 §2, ADR-005 |
| Little-endian on disk and wire, no swap code, compile-time check documents it. | ADR-016 §3 |
| Blob header is `{magic, u16 formatVersion, flags}`; strings length-prefixed; `StringId` as raw `u64`. | ADR-016 §3 |
| Encoding adds no nondeterminism: same input bytes, identical output bytes. | ADR-016 §3 |
| One header version; a bump means re-bake and re-save; per-type versions wait for non-regenerable content. | ADR-016 §4 |
| Type tags are macro-free `constexpr` strings hashed with `StringId` (FNV-1a/64). | ADR-016 §5, ADR-007 §1 as amended |
| Primitives and seam live in `core`; document schemas belong to their consumers. | ADR-016 §6, ADR-006 §1 |
| Disk identity (authoring-id + remap, opt-in UUID) is ADR-007's, not re-opened here. | ADR-007 §1 |

## Design

### Surface (pinned 2026-08-22)

- `Writer` appends to a caller-owned `std::vector<std::byte>`; `Reader` walks a
  `std::span<const std::byte>` and fails soft: a truncated or malformed read returns a
  status, never asserts, because the input is data, not program state.
- Primitives: fixed-width integers, `float`/`double` (bit copy), `bool` as one byte,
  length-prefixed `std::string_view`/`std::string`, `StringId` as `u64`, raw byte spans.
- The bulk path takes `std::span<const T>` for trivially-copyable `T` and writes count plus
  bytes; the visited path is `visit(archive, value)` with the archive deciding direction.
- The header is written and checked by the same pair, so no consumer hand-rolls it.

### The visit shape

One function enumerates fields in a fixed order; both archives walk it. Field order **is**
the format, so reordering fields in a visit is a format change and rides the header version.
A drift guard (a field-count or layout check a test can pin) is wanted; its shape is open
below.

### What the M2 slice proves

A hand-made non-POD struct and a trivially-copyable one both round-trip through memory:
write, read back, compare equal, and a corrupted or truncated buffer fails soft. No file
I/O (M3), no schema, no compression.

## Open questions

- **Visit drift guard.** A struct whose visit forgets a new field silently writes a stale
  shape. What can a test actually pin: `sizeof` assertions per visited type, a field count,
  or nothing honest? Owner: S4-T7.
- **Binding mechanism for `visit`**: ADL free function vs trait specialization. Owner:
  S4-T7, decided in code review against `CONVENTIONS.md`.
- **Error surface**: whether `Reader`'s status reuses `FileResult`'s shape or gets its own
  enum. Owner: S4-T6.
- **Compression layer** behind the header flags. Trigger: a measured bake-size or load-time
  problem (ADR-016 § *What would move*).
- **Per-type versions + migration.** Trigger: the first non-regenerable content
  (ADR-016 §4).

## References

- [[ADR-016 — Serialization (binary primitives & describe-once seam)]]: the decisions
- [[ADR-007 — v2 networking & ECS replication foundation]] §1 §2: identity and the
  three-fact registration seam this plugs into
- [[StringId — Design]]: the frozen hash and `fromValue`
- [[File Access — Design]] § *The write surface*: why no file lands before M3
- [[v1 Code Audit]]: F1 (identity, the real v1 pain)
- Code: `engine/core/include/TechEngine/core/events/EventRegistry.hpp:15` (`EventWire`, the
  seam's first edge). Serialization files land with S4-T6.
