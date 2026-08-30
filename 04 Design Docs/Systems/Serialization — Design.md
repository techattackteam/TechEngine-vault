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
A Catch2 case pins that mechanically: it compares a visit's bytes against a hand-written
field-by-field write of the same value.

### How `visit` binds (decided at S4-T7, 2026-08-30)

**An ADL free function**, templated on the archive so one body serves both directions.

```cpp
template<typename Archive>
void visit(Archive& archive, Mesh& value) {
    archive.field(value.id);
    archive.field(value.name);
    archive.field(value.bounds);        // nested, visited too
    archive.field(value.indices);       // std::vector, so the bulk path
}
```

The alternative was a `Serializer<T>` trait specialization. It was rejected because a
specialization has to be written inside the primary template's namespace, so every describing
type pays a close-namespace and reopen dance, and script types would pay it worst. ADL costs
nothing at the call site and is the shape a P2996 generator would emit (ADR-016 §2).

**The trait's one real advantage was a clean error**, and a concept recovers it.
`Visitable<T, Archive>` sits in `Visit.hpp`, and `field` falls through to `visit` behind a
`static_assert` on it, so an undescribed type is named rather than dumped as overload
resolution noise.

### `field` is the unifying member

`Writer::write` and `Reader::read` share no name, and the bulk path's types differ:
`span<const T>` on one side, `vector<T>&` on the other. So one visit body could not call
either archive as S4-T6 shipped them. `field` is the member added on both to fix that.

It probes with `if constexpr` for a `write`/`read` overload and falls through to `visit`.
**Probing the archive rather than the value is deliberate.** Testing for `visit` first would
put `std::visit` into the ADL set for any `std::string` or `std::vector` field, and that only
stays harmless while every `std::visit` overload happens to be SFINAE-friendly.

`field` takes `T&`, never `const T&`, because one body has to serve the reading direction.
The cost is that a `const` object cannot be written without a cast. That is inherent to
describe-once, not a gap.

### The drift guard, and what it cannot do

**Answered at S4-T7 (2026-08-30): a `static_assert(sizeof(T) == N)` at the top of the visit,
and only on types whose `sizeof` is stable.** Adding a field changes `sizeof`, so the build
breaks at the visit and somebody has to look. It is a tripwire, not a test.

| Limit | Consequence |
|---|---|
| It misses a reorder of two same-sized fields. | The struct and its visit disagree, the assert still passes, and the round-trip case is the only thing left that can catch it. |
| `sizeof` is not portable for a type holding `std::string` or `std::vector`. | MSVC and libstdc++ differ, and MSVC differs again by iterator-debug level. A constant there goes red on a CI leg that was never wrong. |

So the guard sits on the all-scalar types and the container-holding ones get the round-trip
case instead. **That split is the honest answer the card asked for, not a workaround.**

**Considered and not built:** an aggregate arity count through the brace-init trick. It is
portable, would reach the container-holding types, and costs about 15 lines of template
machinery. **Trigger:** the first visited type that holds a container and has no round-trip
case covering every field.

### What the M2 slice proves

A hand-made non-POD struct and a trivially-copyable one both round-trip: write, read back,
compare equal, and a corrupted or truncated buffer fails soft.

The unit cases stay in memory, because `core` sits above `platform` and a disk-touching test
would need a writable directory it does not otherwise want. **The headless demo goes further
and round-trips through a real file** (`engine/app/src/App.cpp`), which S4-T7 made possible
by shipping `FileAccess::write`. No schema and no compression.

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

### The write path

`Writer` **appends** to the caller's vector, where `read` replaces it. Reusing one buffer
across saves means clearing it first. That asymmetry is the cost of letting the caller own
the destination, and it is what lets the finished vector go straight to `FileAccess::write`
and lets N3 reuse one pooled vector every frame.

```cpp
std::vector<std::byte> bytes;          // reused across saves: bytes.clear() first
Writer writer{bytes};
writer.writeHeader();
writer.write(entityCount);
// ... more writes

engine.files.write("assets://level.bin", bytes);
```

**This section read "No file lands before M3" until 2026-08-30**, and S4-T7 changed it:
`FileAccess::write` shipped at that card ([[File Access — Design]] § *Why the write split was
dropped*), so the M2 demo writes a real file. ADR-016 §6 carries the matching amendment. The
module boundary did not move. Serialization still produces and consumes bytes, and `platform`
moves them.

## Open questions

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
- Code: `engine/core/include/TechEngine/core/serialization/` holds the pair and the header
  (S4-T6) plus `Visit.hpp` and `field` on both archives (S4-T7) ·
  `engine/core/include/TechEngine/core/events/EventRegistry.hpp:15` (`EventWire`, the seam's
  first edge) · `engine/app/src/App.cpp` (the disk round-trip demo).
