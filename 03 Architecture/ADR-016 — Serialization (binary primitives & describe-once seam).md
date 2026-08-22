# ADR-016 — Serialization (binary primitives & describe-once seam)

- **Status:** Accepted
- **Date:** 2026-08 (Accepted 2026-08-22)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Related:** [[ADR-005 — v2 tech stack & toolchain]] (custom binary decided; this ADR pays
  the debt it names: format, versioning, endianness, the reflection seam) ·
  [[ADR-006 — v2 core architecture & module layout]] §1 (`core` owns serialization) ·
  [[ADR-007 — v2 networking & ECS replication foundation]] §1 §2 (identity, the three-fact
  registration seam, the bulk column encoder) ·
  [[ADR-014 — Events (buffered streams) & StringId]] §1 (the frozen hash) · living *how*:
  [[Serialization — Design]]
- **Task:** S4-D2 ([[2026-08 Sprint 04 — M2 Concurrency & Serialization]]). The seam M5's
  components, M6's resources, T4's bake and N3's snapshots all register against.

## Context

ADR-005 already decided *custom binary* for assets and scenes and named exactly what the
system ADR owes: format, versioning, endianness and the reflection seam. The [[Roadmap]]
moved this rung from M6 to M2 because every later registrar declares against it: ADR-007 §2
has each component register stable-id, on-disk-serializable and on-wire-replicated through
**one** seam, and building M5 and M6 first would declare all of that against a seam that does
not exist.

v1's serialization pain was **identity, not reflection** (F1): yaml-cpp plus a resettable id
counter. ADR-007 §1 already fixed identity (authoring-id plus remap on load; UUID as an
opt-in component; runtime indices never on disk), so this ADR does not re-open it.

The tree today: the seam's first edge already exists as `EventWire::Replicated`
(`engine/core/include/TechEngine/core/events/EventRegistry.hpp:15`, a reserved flag with a
pinning test); `StringId` is the engine's frozen hash (FNV-1a/64, macro-free, `fromValue`
tested as a serialized round-trip); and **no file writer exists until M3**
([[File Access — Design]] § *The write surface*), so the M2 slice round-trips through memory.

## Decision

### 1. Two paths, one seam

**Bulk path:** a trivially-copyable span (an ECS column, an event batch) is copied as raw
bytes, never visited per field. This preserves ADR-007 §2's column encoder and is the path
N3's snapshots and `EventWire` streams ride. **Visited path:** everything else describes
itself once (§2). Registration stays ADR-007 §2's single three-fact seam; this ADR adds the
visit hook to it rather than a parallel mechanism.

### 2. A describe-once visitor is the seam, and it is the reflection seam

Each non-POD type provides **one** `visit` function enumerating its fields. `Writer` and
`Reader` are two visitors over the same description; a future editor inspector is a third.
When MSVC ships production P2996 reflection and a prototype beats the hand-written form
(ADR-005's standing trigger), reflection **generates** the visit function and nothing
downstream changes. No base class, no virtuals; the binding mechanism (ADL vs trait
specialization) is [[Serialization — Design]]'s to pin.

### 3. Format: little-endian, deterministic, headered

Bytes are **little-endian, always**, on disk and wire. Every ship and CI target is LE; a
compile-time check documents the assumption and no swap code exists. Blobs open with
`{magic, u16 formatVersion, flags}`; strings are length-prefixed; `StringId` is its raw
`u64`. **Encoding adds no nondeterminism**: the same input bytes produce identical output
bytes, which is what makes bake reproducible (T4) and snapshot diffs meaningful (N3). No
promise is made about cross-compiler float *computation*, only that encoding copies bits.

### 4. Versioning: one header version, re-bake over migration

One format version lives in the header. A bump means **re-bake assets and re-save scenes**;
no migration machinery exists. That is honest while every file is regenerable from source by
the editor pipeline. Per-type versions and upgrade hooks get a named trigger instead of
speculative machinery: **the first content that can no longer be regenerated** (shipped
builds, external user projects).

### 5. Type tags hash with `StringId`, macro-free

Component and type tags are author-declared strings (`"TechEngine.Transform"`), registered
as plain `constexpr` arguments and hashed with **`StringId`'s frozen FNV-1a/64** (ADR-014
§1). ADR-007 §1's `TE_COMPONENT(...)` spelling was a macro sketch that predates the
macro-free precedent; its decided content (author-declared stable tag, content-derived
64-bit hash, carried on disk and wire) is unchanged, recorded as a vocabulary amendment on
ADR-007's header. Registration keeps the tag string and collision `TE_CHECK`, the
`EventRegistry` shape.

### 6. Scope: primitives and seam here, document schemas with their consumers

This system lives in `core` (ADR-006 §1). It owns the encoding primitives (`Writer`/`Reader`
over memory buffers), the seam, and the rules above. **Document schemas are not here**: the
scene file layout belongs to M5/M6, asset containers to T4's bake, snapshot packets to N3,
each written against this format. The M2 slice is memory-buffer round-trip only; files wait
for M3's writer, compression waits for a measured bake-size or load-time problem.

## Consequences

**Positive**

- M5, M6, T4 and N3 all declare against a real seam, which is the entire reason the rung
  moved from M6 to M2.
- One description per type serves write, read, and later inspection; the reflection pivot
  stays a generation change, not a rewrite.
- Disk and wire share primitives and the bulk path, so N3's encoder needs no second format.
- Determinism is testable from the first round-trip case.

**Negative / open**

- Every non-POD type carries a hand-written visit until reflection lands; drift between a
  struct and its visit is a real bug class (a field-count check is the note's to design).
- A format bump strands old files by design; acceptable only while content is regenerable,
  and the per-type trigger in §4 is the tripwire.
- No compression and no encryption; both are deliberate absences with triggers.
- The M2 slice has no in-tree consumer beyond its own tests and demo until M5 registers
  components; the seam is being built exactly one rung before its users, and that is the
  Roadmap's own argument, not an accident.

## Alternatives considered

- **Schema-compiler serializers (FlatBuffers, protobuf, Cap'n Proto)** — rejected: a codegen
  step in every build, a foreign format on the critical path, and ADR-005 already decided
  custom binary. Zero-copy reads matter for streamed assets we do not have.
- **Header-only archive libraries (cereal, bitsery)** — the closest shape to §2, honestly
  weighed: they are visitor archives too. Rejected because the surface we need is small, the
  format must be ours for §3's determinism and §4's versioning policy, and a dep here sits on
  the critical path of every asset (ADR-005's dep bar).
- **Text formats for scenes** — decided out at ADR-005 (yaml-cpp retired; toml++ is config
  only).
- **Per-type versioning now** — rejected: migration machinery before any file is worth
  migrating. §4 names the trigger.
- **Network byte order on the wire** — rejected: every target is LE, so it taxes the hottest
  path (snapshot encode) to serve no real platform.

## What would move this decision

- **Reflection:** production P2996 in MSVC plus a prototype that beats hand-written visits
  moves §2's authoring to generated visits through the same seam (ADR-005's trigger,
  restated).
- **Non-regenerable content** (a shipped build, external user projects) triggers §4's
  per-type versions and a migration story before that content exists, not after.
- **A measured bake-size or load-time problem** adds a compression layer behind the header
  flags.
- **A big-endian ship target** forces §3's swap code and a format version bump; until one is
  named, none is written.

> Add to [[ADR Index]]. Once Accepted, change it only per [[ADR Index]] § *Amending an Accepted ADR*: a dated header entry for what fits one, a superseding ADR for what needs its own argument.
