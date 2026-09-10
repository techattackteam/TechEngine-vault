# Working with Codex — Operating Guide

The human playbook for TechEngine with OpenAI Codex. Machine-facing rules
live in the engine's `AGENTS.md`; the role remains [[Technical Lead Charter]].
The original [[Working with Claude — Operating Guide]] and Claude configuration
remain unchanged as backups.

## Project in brief

TechEngine is Miguel's solo-built client/server 3D game engine in C++20, intended
to become a professional product and eventually a company. Its direction is a
data-oriented core, a physically grounded renderer, and documented architectural
decisions. See [[Vision]] for the ambition and [[Roadmap]] for the sequence.

The active implementation is v2; the frozen `v1-reference` tag supplies prior art.
Foundation work comes before scene scheduling, content, editor tools, rendering,
physics, and networking. The signature graphics goals include atmospheric
scattering, volumetric fog, and global illumination.

**Status snapshot, 2026-09-05:** [[Dashboard]] records M0–M2 complete and Sprint 05
(Aug 29–Sep 11) targeting M3 project loading, with M4 window/triangle as its reach.
The local engine is at `934cf999`, with project and editor-loading commits beyond
the Dashboard's `01ed7a30` reconciliation stamp. This is an orientation snapshot,
not a new drift check or a claim that the sprint goal has passed.

## Division of labor

- **Miguel writes and compiles the engine.** He owns its logic and decisions.
- Codex provides architecture, trade-offs, decomposition, research, ADR drafts,
  and reviews. It writes boilerplate and test scaffolds when requested.
- On process, Codex co-creates plans and runs ceremonies; Miguel decides scope.
- In attended work, builds and tests stay with Miguel unless he requests them,
  the task is a build/CI fix, or one targeted check has a stated reason.
- Code handed over without a build is explicitly **unverified**.
- Existing authorization carries forward; a skill does not require asking twice.

## The core loop

**Design together → Miguel implements → Miguel verifies → Codex reviews → iterate.**

1. Ground the card with `$card-start S5-T2`, using the actual card ID.
2. Discuss the design and its trade-offs. Draft an ADR when the artifact gate
   calls for one; Miguel deliberately accepts it.
3. Request scaffolding if useful, then implement the logic.
4. Build with the CMake presets. Use demo captures for rendering changes.
5. Run `$card-review` for acceptance, correctness, conventions, and architecture.
   Use `$te-review` or `$arch-review` when you want a narrower review.
6. Commit or open a PR when requested; the engine lands through PRs.
7. After merge, `$card-close` records what the card taught in the vault.

## Configuration and migration map

| Claude source | Codex equivalent |
|---|---|
| `CLAUDE.md` | `AGENTS.md` |
| `.claude/commands/<name>.md` | `.agents/skills/<name>/SKILL.md` |
| `.claude/agents/<name>.md` | `.codex/agents/<name>.toml` |
| Claude output style | Preserved as backup. Codex writing guidance lives in `AGENTS.md` and the vault templates. |
| Local Claude permission grants | Preserved as backup; Codex uses its own permissions. |
| This guide's Claude original | This Codex guide. |

Choose the model and reasoning level in Codex. The project leaves those settings
unset, so your selection and personal defaults apply. Specialists inherit them
and retain their read-only default.

The project `.codex/config.toml` requests a 1,000,000-token context window through
`model_context_window`. This does not increase a model's actual capacity. On
2026-09-05, the local Codex catalog listed Astra's maximum as 872,000 tokens;
the full requested window has not been verified in a running task. When switching
to a smaller-context model, lower or remove this override to match its capacity.
Project configuration applies when the project is trusted.
See [OpenAI configuration docs](https://learn.chatgpt.com/docs/config-file/config-basic)
and [custom agent docs](https://learn.chatgpt.com/docs/agent-configuration/subagents).

## Skills replacing slash commands

Use `$name` followed by ordinary text, for example `$adr resource ownership`.
Skills can also be selected from a matching natural-language request. Their
instructions contain the original workflow gates and input defaults.

| Skill | Use it for |
|---|---|
| `$card-start [card]` | Ground a card, check predecessors and freshness, then create a branch if requested. |
| `$card-review [card]` | Review implementation and acceptance in one pass, without edits. |
| `$card-close [card]` | Close merged work: board, design note, Known Issues, backlog. |
| `$te-review [target]` | Review house rules that need judgment and structural invariants. |
| `$arch-review <area>` | Review architecture without editing code. |
| `$adr <decision>` | Draft a Proposed ADR; Miguel accepts the decision. |
| `$feature-breakdown <feature>` | Co-create session-sized stories and tasks behind the artifact gate. |
| `$weekly-review [notes]` | Run the non-boundary weekend review and update the vault. |
| `$sprint-plan [focus]` | Run the boundary retro and plan the next sprint. |
| `$vault-clean [folder]` | Apply mechanical vault cleanup and surface larger changes. |

Codex discovers repo skills in `.agents/skills/`; if new skills do not appear,
restart Codex. See [OpenAI skills docs](https://learn.chatgpt.com/docs/build-skills).
Ask “review this card” or use `$card-review S5-T2`. Start a new task when moving
to unrelated work.

## Session rhythm and planning

Follow [[Dashboard]] § Rhythm for capacity and ceremony dates. Deep work is Mon,
Thu, and one swappable weekend day. A weekend deep day has more capacity than an
after-job evening; protect light days and rest.

- Run `$sprint-plan` on a sprint-boundary weekend; it absorbs the weekly review.
- Run `$weekly-review` on the other weekend.
- Source tasks from design decisions that are unbuilt and have a consumer now.
- Keep work below an unresolved heavy artifact roughly sized until it is decided.
- Park unrelated ideas in [[Backlog]], with a trigger and a durable artifact link.

## Specialist agents

Ask Codex to delegate a bounded question to one of these agents. They support the
main conversation and return findings; they do not edit or decide architecture.

| Agent | Use it for |
|---|---|
| `v1-reference-miner` | Find prior art and audit evidence on the frozen `v1-reference` tag. |
| `engine-researcher` | Evaluate techniques, papers, and libraries against the actual stack. |
| `adr-consistency-checker` | Check a proposal against Accepted ADRs, amendments, and supersessions. |

## Writing

Lead with the answer and use short, complete sentences. Keep one point per paragraph
or bullet. Remove repetition rather than packing several ideas into a dense line.
Use tables for comparisons, and keep only the template sections that serve the note.
The full writing rules live in `AGENTS.md`.

## Quality and scope

- Keep diffs small enough to understand. Prefer refactoring; require evidence for rewrites.
- Prioritize correctness, then clarity, then measured performance.
- Deterministic core systems need unit tests; rendering needs demo evidence.
- Follow `CONVENTIONS.md`; mechanics remain with clang-format, clang-tidy, and CI.
- Keep notes readable, one topic each, with short sections and links instead of duplication.
- Never turn stale documentation or an unseen CI result into a verification claim.
- Flag session overrun and burnout risk; one task should not grow into an unplanned sprint.

## Repositories and the autonomous lane

The engine and `docs/` are separate repositories. Engine commits land through PRs;
vault commits go directly to its own `master`. Neither is committed or pushed
without a request. New engine branches start from freshly fetched `origin/master`
and use the card ID in their name.

The Claude cloud lane described in [[Autonomous Lane — Design]] is historical
provider-specific setup. This migration creates no Codex automation and transfers
no schedule. Its Linux-only unattended build exception applies only to an explicitly
configured scheduled cloud run, never to an attended desktop session.

## Remote checkout setup

Read this section when preparing a remote environment. Both the engine and vault
must be supplied; verify their actual paths and checkout state before work begins.

The existing Claude cloud lane checks the vault out as a second source at
`/home/user/TechEngine-vault`, beside the engine. Its setup script links it before
the session starts (measured 2026-08-30):

```bash
ln -s /home/user/TechEngine-vault docs
```

In that environment, the symlink survives between runs but git state does not.
Both checkouts arrive shallow and detached, so the routine re-anchors them first;
it does not clone the vault in-session. These are recorded Claude setup details,
not verified Codex remote behavior. Project guidance does not create or migrate
a scheduled cloud routine.
