# TechEngine: Project Vault

This folder is an **Obsidian vault** and the "brain" of TechEngine. Open it by
pointing Obsidian at `C:\dev\TechEngine\docs`.

## This is its own repository

`TechEngine-vault`, cloned in place inside the engine checkout, not a submodule
([[ADR-012 - Vault repository split]]). The engine repo ignores this path; a root
`.ignore` there keeps ripgrep able to see it anyway.

```bash
git clone git@github.com:techattackteam/TechEngine-vault.git docs
```

Commit straight to `master`, no branch, no PR, no CI (ADR-012 §2). That is this repo
only; the engine is still PR-only under ADR-009 §2.

**The two repos move independently, so this vault can describe code that has moved on.**
The [[Dashboard]]'s **Reconciled against** stamp records how far behind it was last
actually checked (ADR-012 §6). Read it before trusting a design note as current, and if
a tool can't find something in here, suspect the ignore rules before concluding it's gone.

## Core philosophy

| Layer | Tool | Purpose |
|-------|------|---------|
| Think | Obsidian (this vault) | Product, architecture, research, planning |
| Execute | Obsidian Sprint board | Epics → Stories → Tasks |
| History | Git | What actually changed |

| Role | Who | Does |
|------|-----|------|
| **Product owner** | You | Decides what gets built and why: the [[Vision]], the [[Reference Game]], the [[Capability Map]], and which 🤖 Claude features run |
| **Lead engineer** | You | Writes your 🟢 Deep and 🟠 Moderate cards, and accepts every ADR |
| **Technical lead, PO analyst, scrum master** | Claude Code, attended | Architecture, reviews and research; interviews you and drafts the product notes; runs the ceremonies |
| **Implementer** | Claude Code, in the unattended lane | 🤖 Auto cards and 🤖 Claude features, as PRs you review |

Who writes which card, and what stays yours: [[Technical Lead Charter]] § *Who writes the code*.

> Planning happens in dedicated planning sessions. Implementation happens in
> coding sessions. The goal is to reduce decision fatigue and protect
> uninterrupted implementation time at a pace sustainable for years.

## Folder map

| Folder | Holds |
|--------|-------|
| `00 Dashboard` | Single at-a-glance status page. Start here. |
| `01 Product` | Why TechEngine exists and who it is for, the reference game, the capability map and briefs, the channel, principles |
| `02 Roadmap` | The goal ladder and the quarter notes |
| `03 Architecture` | ADRs, system overview, diagrams, [[Known Issues]] |
| `04 Design Docs` | Living design docs per system + utility, the *how* behind the ADRs |
| `05 Research` | Paper review board, approved papers, SIGGRAPH notes, technique write-ups |
| `06 Sprints` | Sprint board, active sprint, backlog |
| `07 Journal` | Weekly reviews, sprint retrospectives, autonomous run reports |
| `08 AI` | Technical-lead charter, the operating guide, and the autonomous lane |
| `09 References` | External links and resources |
| `10 AI Agent` | A friend's research chatbot, which reads the vault for the engine's context |
| `Templates` | Note templates (ADR, capability brief, design doc, sprint, story, review, research) |

## Weekly rhythm

Lives on the [[Dashboard]]: day modes, the weekend rule, and the next ceremony.
