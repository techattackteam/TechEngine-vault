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

### Error surface (decided at S4-T6, 2026-08-27)

`Reader` carries its own `ReadStatus`: `Ok`, `Truncated`, `BadMagic`, `BadVersion`. It does
not reuse `FileResult`. That enum's vocabulary belongs to `platform`'s mount layer
(`NoMount`, `IsADirectory`) and says nothing useful about a memory buffer.

The status is **sticky**. The first failure latches, every later read is a no-op, and out
params keep whatever the caller left in them. Reads return `void`, so the caller checks
`ok()` once at the end instead of per field. That is the shape a `visit` body needs, because
it enumerates many fields in a row and cannot branch after each one.

Length and count prefixes are `u32`, for strings and for the bulk path alike, so either caps
at 4 GB. Exceeding the cap is a `TE_CHECK` with a defined path (an empty write), never a
silent narrowing. v1 is the reason: `StreamWriter::writeString` wrote a `size_t` length that
`StreamReader::readBuffer` read back as a `uint32_t`.

### The visit shape

One function enumerates fields in a fixed order; both archives walk it. Field order **is**
the format, so reordering fields in a visit is a format change and rides the header version.
A drift guard (a field-count or layout check a test can pin) is wanted; its shape is open
below.

### What the M2 slice proves

A hand-made non-POD struct and a trivially-copyable one both round-trip through memory:
write, read back, compare equal, and a corrupted or truncated buffer fails soft. No file
I/O (M3), no schema, no compression.

### Composing with `FileAccess`

`FileAccess` moves bytes and `Reader` interprets them. Neither knows the other exists, and
`platform` sits below `core` (ADR-006 §1) so it could not call into serialization anyway.
They compose at the caller, with no glue, because they already speak the same types: `read`
fills a `std::vector<std::byte>` and `Reader` takes a `std::span<const std::byte>`.

```cpp
std::vector<std::byte> bytes;
if (engine.files.read("assets://level.bin", bytes) != FileResult::Ok) {
    return;                            // the file never opened
}

Reader reader{bytes};                  // the vector converts to a span
BlobHeader header;
reader.readHeader(header);

std::uint32_t entityCount = 0;
reader.read(entityCount);
// ... more reads, none of them checked individually

if (!reader.ok()) {
    return;                            // reader.status() names which of the four
}
```

There are two failure surfaces and they stay separate on purpose. `FileResult` answers "did
the file open", `ReadStatus` answers "did the bytes make sense". Checking the first is not
optional. On `NoMount`, `NotFound` or `IsADirectory` the out-param is left untouched, so a
reused buffer still holds the previous file's bytes. A read that *succeeds* replaces the
vector's contents, so reusing one across loads needs no `clear()`.

### The write path (M3)

`Writer` **appends** to the caller's vector, where `read` replaces it. Reusing one buffer
across saves means clearing it first. That asymmetry is the cost of letting the caller own
the destination, and it is what lets M3 hand the finished vector straight to the file writer
and lets N3 reuse one pooled vector every frame.

```cpp
std::vector<std::byte> bytes;          // reused across saves: bytes.clear() first
Writer writer{bytes};
writer.writeHeader();
writer.write(entityCount);
// ... more writes, then hand `bytes` to the M3 file writer
```

No file lands before M3 (ADR-016 §6), so the whole M2 slice round-trips through memory. The
write call above is not built yet and its exact signature is M3's to pin, described in
[[File Access — Design]] § *The write surface (M3)*.

## Open questions

- **Visit drift guard.** A struct whose visit forgets a new field silently writes a stale
  shape. What can a test actually pin: `sizeof` assertions per visited type, a field count,
  or nothing honest? Owner: S4-T7.
- **Binding mechanism for `visit`**: ADL free function vs trait specialization. Owner:
  S4-T7, decided in code review against `CONVENTIONS.md`.
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
- Code: `engine/core/include/TechEngine/core/serialization/` (the pair and the header,
  S4-T6) · `engine/core/include/TechEngine/core/events/EventRegistry.hpp:15` (`EventWire`,
  the seam's first edge).
