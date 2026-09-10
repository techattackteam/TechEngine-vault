---
type: weekly-review
date: 2026-09-05
---

# Weekly Review — 2026-09-05

## Completed this week

- The editor loads `projects/dev/project.toml` and mounts its content. Application lifecycle, app test targets, executable-path lookup and file operations also shipped. Runtime packaging remains M6 work. See [[Sprint Board]], S5-T1–T5 and S5-T10–T11.
- The autonomous lane delivered its first merged code PR, the logging-default fix. S5-P1 and S5-P3 also closed. See [[Sprint Board]] for delivery and prior validation records.

## Blockers

- S5-B1: the editor's default project path depends on its working directory. The fix must work when launched elsewhere and preserve the explicit argument override.
- M4 needs the GL loader and Linux CI setup before window implementation. GL 4.5 support on the runner remains unverified; S5-P4 owns that check.

## Artifact drift

Compared Project, App, executable-path resolution, app CMake wiring and FileAccess with
their design notes, and Project's decision summary with ADR-017. Findings remain open:

- ADR-017 specifies one pure lifecycle hook and `main()` in a shared header. The implementation has four pure hooks and a separate `main()` per executable.
- Project documentation still says the manifest names content paths, although the editor derives them. The note also calls T5 open and omits `parent_path()` from its engine-mount example.
- FileAccess documentation promises read-only access through const, but `copy`, `move` and `rename` are const methods. Its surface summary is stale. Project's description of `write()` checking for a missing parent also differs from the implementation, which returns `NotFound` for any failed stream open.
- T5's board entry and the sprint note disagree about the revised completion criterion.

Reconciliation remains outstanding; existing follow-ups are in [[Backlog]]. Update living
notes to reflect the agreed behavior and use [[ADR Index]] for any accepted-decision changes.

The check used local HEAD and cached `origin/master` at `934cf999`. No fetch, build, test,
demo or live CI check ran. Other touched systems were not fully audited. The Dashboard
stamp stays at `01ed7a30` because reconciliation is unfinished.

## Objective for next week

Fix S5-B1, then work toward M4's render-thread triangle through T6 → P4 → T7 → T8, with
raw input remaining optional until the September 12–13 sprint-planning weekend.

## Sustainability

Miguel felt good about the week and believes programming work could increase a little.
The estimates need adjustment in both directions: some light tasks were moderate, and
some moderate tasks were light. S5-T2 and S5-T1 provide examples for the next planning session.

Use actual effort and unresolved design work to size the next set of tasks before adding
more programming work. Specific rest days and the job/karting balance were not discussed.
