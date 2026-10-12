# ADR-025: Content packs (.tepack and the runtime load path)

- **Status:** Accepted
- **Date:** 2026-10 (Accepted 2026-10-10)
- **Deciders:** Miguel (Lead Engineer), with AI as technical lead
- **Task:** the Sprint 08 decide-first trial ([[Planning Workflow - Artifact Gate]] § *Trial
  from Sprint 08*). Gates M6 together with [[ADR-024 - Resources (64-bit ids, value handles, async loads)]].
- **Amended 2026-10-12, vocabulary:** "bake" → **"export"** for the editor step that writes
  packs, in §1, §2, §4, §6, *Consequences* and *Alternatives*; the quotes of ADR-016 and ADR-006
  keep their own words. The code and the design notes call it `Project::exportTo`. S8-T7.
- **Amended 2026-10-12, decision:** §4, "The bake writes `common.tepack`, `client.tepack` and
  `server.tepack`" → one export writes the packs of the sides its **export target** ships. The
  client and the server ship as separate programs, so a client's folder holds no server pack and
  a dedicated server's holds no client pack ([[Resources - Design]] § *Export targets*). S8-T7.
- **Partially supersedes:** [[ADR-016 - Serialization (binary primitives & describe-once seam)]],
  two clauses only, each rowed in [[ADR Index]] § *Partial supersessions*:
  - §6, "asset containers to T4's bake". The scene layout (M5/M6), the snapshot packets (N3),
    the compression trigger and the 2026-08-30 amendment remain.
  - §4, "one format version ... re-bake assets and re-save scenes": each blob kind gets its own
    magic and version (§2). Re-bake over migration and the per-type trigger remain.
- **Related:** [[ADR-006 - v2 core architecture & module layout]] §1 · ADR-016 §3 §4 ·
  [[ADR-017 - Bootstrapping (editor manifest, fixed runtime layout)]] § *Decision* 1-2 ·
  living *how*: [[Resources - Design]] · [[Project - Design]] · [[File Access - Design]]

## Context

ADR-006 §1 says the runtime consumes only baked binary, written by the editor. ADR-017 says
the runtime reads no manifest and mounts a fixed layout produced by the editor's export.
Neither defines that binary or that layout. [[Project - Design]] leaves export and "what the
runtime mounts" to M6, and `RuntimeApp::init()` mounts nothing today
(`apps/runtime/src/RuntimeApp.cpp:27-34`, engine `82d7a11c`).

v1 had no pack. Export was a recursive file copy that shipped the source art
(`runtime/editor/src/project/ProjectManager.cpp:90-162` at `v1-reference`), and the exported
runtime had no loader to read any of it.

Miguel's direction: the editor works on raw files, and the runtime loads `.tepack` files that
hold assets already in their runtime form, so loading skips parsing and conversion.
[[2026-Q4]]'s first objective needs the runtime to load a project's scene.

Two constraints shape the options. [[Project - Design]] splits `assets/` into `common`,
`client` and `server`, and a dedicated server must not ship client content. And `platform`
sits below `core` (ADR-006 §1), so file access cannot parse a format that `core` encodes.

## Decision

### 1. A pack is runtime-form assets keyed by id

A `.tepack` opens with ADR-016's header, then a table sorted by `ResourceId`, with a type tag,
offset, size and a debug name per entry. Payloads are **16-byte aligned**, so a
trivially-copyable payload is usable where it lies. Sorting makes lookup a binary search and
two exports of the same input byte-identical (ADR-016 §3).

"Faster" means this: a pack skips import and conversion. A visited payload still goes through
`Reader`; only a trivially-copyable payload skips parsing entirely.

### 2. Its own magic and version

A pack carries its own magic and format version, so a pack change never strands a saved
scene. Today one magic and one version serve every blob
(`engine/core/include/TechEngine/core/serialization/BlobHeader.hpp:10-12`), as ADR-016 §4
decided; this splits them per kind, scenes included. A pack version bump means a re-export while every pack can be
rebuilt from its project. The first shipped build whose packs a newer runtime must still read
(a patch, downloadable content) is ADR-016 §4's trigger for packs. Compression sits behind the
header's existing `flags` when an export-size or load-time problem is measured, as ADR-016 says.

### 3. Ranged reads through `FileAccess`, mappable by layout

A pack is never read whole. The runtime reads each pack's table when it opens the pack, and
each entry with a **ranged read** at its offset, so memory follows what is loaded, not the size
of the pack. This is how Unreal reads one `.pak` for a whole game. `FileAccess` gains one call
that reads a byte range of a file; it still knows nothing of packs. Offsets are absolute and
nothing holds a pointer, so a pack can later be memory-mapped as it is.

### 4. One pack per side, no overrides

The export writes `common.tepack`, `client.tepack` and `server.tepack`, mirroring the asset
split. An id lives on exactly one side, so a duplicate id across packs is an export error; a
variant is a separate asset with its own id. The runtime merges the tables of the packs it
opens into one id index. The boot record (§7) lists the packs each role opens, so finer packs
(per scene, per chunk) stay an export-side change.

> **Amended 2026-10-12:** one export no longer writes all three packs. An export target (the
> client game, a dedicated server or a listen-server) writes `common.tepack` and the packs of
> the sides it ships, and its boot record lists only its own role
> ([[Resources - Design]] § *Export targets*). One pack per side and one side per id still hold.

### 5. A pack reader in `core`, on top of `FileAccess`

The runtime does not reach packs through an archive mount. The resource cache resolves an id
through a **source**: a pack source in the runtime, and in the editor a loose-file source that
maps an id to a virtual path. The editor loads from `common` and `client`, which is what a
client mounts, and reads `server` headers only to learn each id's side. Both sources read bytes through
`FileAccess`, which stays a byte mover that knows nothing of packs.

### 6. Writer and reader land together, in `core`, at M6

**The export ships only what is used.** It walks hard and soft references from its roots, the
exported scenes and the selected systems' settings assets (in M6, the startup scene), and
packs what they reach, each asset into its side's pack. An asset nothing
references is not shipped. Engine-owned assets, such as a default material, travel the same
way, so the runtime needs no `engine` alias.

The pack writer is a format primitive, symmetric with `Writer` and `Reader`, and it is
round-trip tested with the pack reader. The export driver, which walks the references, assigns
sides and writes the layout, stays in the editor. So ADR-006 §1's "editor owns the asset
pipeline" holds, and ADR-017's `tooling` trigger does not fire before T4's importers.

M6 has no converter: every M6 asset is engine-native, and its source already is its runtime
form. T4's importers will write runtime-form files that this same export packs.

### 7. The runtime layout and the boot record

- The runtime mounts the alias `assets` at an `assets/` directory beside its executable. It
  opens `common.tepack`, reads the boot record, and then opens the packs its role lists.
- The **boot record** is in `common.tepack`, found through its header. This ADR fixes its
  **role**: it is the runtime's only configuration channel, produced by export, and the runtime
  reads nothing else to start. It is not a manifest in ADR-017's sense: it is binary and not
  meant to be edited. The editor takes its inputs from `project.toml`, which stays editor-only.
- Its **contents are meant to grow** as real projects need them. It is a list of tagged
  sections, each with its own version, and a runtime skips a section it does not know. M6
  starts with four: the startup scene's id, the settings-asset id for each selected system
  keyed by registration name (ADR-024 §4), the pack list for each role, and the side of every
  id (ADR-024 §7). A new section is a [[Resources - Design]] change, not an amendment here.
- What would need an amendment is a change of role: the record selecting systems instead of
  the runtime's `App` (ADR-022), or the runtime reading configuration from anywhere else.
- A system that declares a settings asset and finds none in the record fails startup. A system
  that declares none needs no entry.

## Consequences

- **Benefit:** the runtime never parses an editor file and never links an importer, so F30
  stays closed by structure.
- **Benefit:** a project and a shipped game use one folder name, `assets/`, and a shipped game
  carries only the assets its scenes reference.
- **Benefit:** granularity, compression and mapping are export-side or reader-side changes. No
  loader and no handle moves with them.
- **Cost:** the editor reads loose files and the runtime reads packs, so a pack bug can hide
  until the runtime is run. Round-trip tests and T2's export run are the guard. This is
  ADR-017's two-bootstrap cost, extended to content.
- **Cost:** one pack per side means a change to one asset rewrites its whole pack, so a patch
  would ship the whole pack. That matters only once patches ship (see *Revisit when*).
- **Cost:** two lanes move. T2 shrinks to the editor's save and export commands on top of this
  ADR's export, and T4 narrows to importers ([[Roadmap]]).
- **Revisit when:**
  - Ranged-read cost is measured as a problem: memory mapping.
  - An export-size or load-time problem is measured: compression behind the header flags.
  - A shipped build must be patched: finer packs, per-entry hashes, and ADR-016 §4's migration story.
  - A dedicated server must be re-pointed at content without a rebuild: ADR-017's trigger.
  - A project needs the boot record to choose systems or be edited after export: a change of
    its role (§7).
  - The listen-server's mount set is decided ([[Project - Design]] § *Open questions*).

## Alternatives considered

| Option | For it | Why not |
|---|---|---|
| Archive mount in `MountTable` | One read path for loose and packed files; [[File Access - Design]] lists it as open. | `platform` cannot parse a format `core` encodes, and `MountTable` keys by path where packs key by id. |
| One pack per project | Simplest export and layout. | A dedicated server would ship client content. |
| One pack per scene | Fits the one-live-scene model. | Duplicates content that scenes share. Nothing in M6 needs it, and the boot record keeps it an export-side change. |
| Pack every file in `assets/` | No reference walk in the export. | Ships unused content; Miguel wants only what the exported scenes need. |
| Side overrides common | A client-only variant of shared content under one id. | A priority rule in the merged index for a need nobody has yet; a separate id does the same job. |
| Format and reader only; writer at T2 or T4 | A smaller M6. | The runtime has nothing to load, Q4's objective fails, and the reader is tested only against hand-built bytes. |
| An existing archive (zip, PhysFS) | Free tooling and compression. | No id-keyed table, no alignment guarantee, and a third-party dependency on the load path for compression nobody needs yet. |
| A separate `resources/` folder for packs | Names the packed form apart. | Two folder names for one thing; Miguel rejected it. |
| Startup scene as a launcher argument | No record inside a pack. | Launcher arguments are T5's, and the runtime would need a second configuration channel. |

> Add to [[ADR Index]]. Once Accepted, change it only per [[ADR Index]] § *Amending an
> Accepted ADR*: a dated header entry for what fits one, a superseding ADR for what needs its
> own argument.
