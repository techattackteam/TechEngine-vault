# 04 Design Docs — v2

Living docs, one per v2 subsystem or utility. Each is filled in as that piece gets built.

- **`Utilities/`**: helper facilities such as Logger, Profiler, Assert and Clock. One doc
  each.
- **`Systems/`**: one doc each at the top level, added as they are built.
- The shape of a design doc is [[Design Doc Template]]. The ADR holds the decision that is
  hard to reverse. The design doc holds the *how*.
- For v1's subsystems, see [[v1 Code Audit]], which covers the reference prototype.

**On writing style.** Bullets and tables beat prose, but write them as real sentences. No
dropped articles and no keyword shorthand. A note is read months later with the context gone,
so shorthand that saves five words costs a re-read. Keep sections under about 30 lines. File
length is uncapped. The full rules are in `CLAUDE.md` → *The vault*.
