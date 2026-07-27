# TechEngine — Project Vault

This folder is an **Obsidian vault** and the "brain" of TechEngine. Open it by
pointing Obsidian at `C:\dev\TechEngine\docs`.

## This is its own repository

`TechEngine-vault`, cloned in place inside the engine checkout — not a submodule
([[ADR-012 — Vault repository split]]). The engine repo ignores this path; a root
`.ignore` there keeps ripgrep able to see it anyway.

```bash
git clone git@github.com:techattackteam/TechEngine-vault.git docs
```

Commit straight to `master` — no branch, no PR, no CI (ADR-012 §2). That is this repo
only; the engine is still PR-only under ADR-009 §2.

**The two repos move independently, so this vault can describe code that has moved on.**
The [[Dashboard]]'s **Reconciled against** stamp records how far behind it was last
actually checked (ADR-012 §6). Read it before trusting a design note as current — and if
a tool can't find something in here, suspect the ignore rules before concluding it's gone.

## Core philosophy

| Layer | Tool | Purpose |
|-------|------|---------|
| Think | Obsidian (this vault) | Vision, architecture, research, planning |
| Execute | Obsidian Sprint board | Epics → Stories → Tasks |
| History | Git | What actually changed |
| Technical Lead | Claude Code | Architecture reviews, trade-off analysis, research |
| Studio Director + Lead Engineer | You | Direction and implementation |

> Planning happens in dedicated planning sessions. Implementation happens in
> coding sessions. The goal is to reduce decision fatigue and protect
> uninterrupted implementation time at a pace sustainable for years.

## Folder map

| Folder | Holds |
|--------|-------|
| `00 Dashboard` | Single at-a-glance status page. Start here. |
| `01 Vision` | Why TechEngine exists, principles, non-goals |
| `02 Roadmap` | Quarterly goals, 4-week sprints, milestones |
| `03 Architecture` | ADRs, system overview, diagrams |
| `04 Design Docs` | Living design docs per system + utility — the *how* behind the ADRs |
| `05 Research` | Papers, SIGGRAPH notes, technique write-ups |
| `06 Sprints` | Sprint board, active sprint, backlog |
| `07 Journal` | Weekly reviews, sprint retrospectives |
| `08 AI` | Technical-lead charter + the day-to-day operating guide |
| `09 References` | External links and resources |
| `Templates` | Note templates (ADR, sprint, story, review, research) |

## Weekly rhythm

Lives on the [[Dashboard]] — day modes, the weekend rule, and the next ceremony.
