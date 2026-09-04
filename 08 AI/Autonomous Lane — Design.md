# 🤖 Autonomous Lane — Design

A second execution lane in every sprint. Claude runs eligible cards **unattended in a
claude.ai cloud routine**, on weekdays, while Miguel is at his day job and his PC is off.
Each run leaves a report he reads that evening.

**This note is the lane's only decision artifact. No ADR was cut** (2026-08-30). The lane is
process rather than a system, it is reversible by disabling one routine, and its boundary is a
list rather than an argument.

That puts weight on this note. § *Eligibility* and § *Hard stops* are **normative**, not
descriptive, and there is no second document to check them against.

The lane's interface: [[Autonomous Lane — Routine Prompt]] ·
[[Autonomous Run Report Template]]. Its gate: [[Planning Workflow — Artifact Gate]]
§ *The 🤖 Auto gate*.

Related: [[Technical Lead Charter]] · [[Working with Claude — Operating Guide]] ·
[[ADR-012 — Vault repository split]] · [[ADR-009 — Branching strategy & merge rules]]

## Why

Three sprints in a row closed with calendar left. Sprint 04 met its goal on **day 9 of 14**,
closing 13 cards in 7 working days against a model that sizes 6.5 per week. That is about
1.5x the sizing table.

**The 1.5x is not spare capacity.** The 2026-08-29 health check found the same overrun for
the third review running: two deep evenings each carried 1 🟢 + 1 🟠 + 1 🟡, and Fri Aug 28
closed four PRs on a 🟠 day. Refilling a sprint to 1.5x would make that overrun the plan.

**The finding underneath it is what this lane acts on.** Every overrun was *process* work,
not engine work. Sprint 04 ran **4 Process cards out of 13**, 31% of the sprint. Moving that
class of card off Miguel's days grows the sprint to roughly 17 cards while the attended half
stays at 13.

So the fix is a second lane, not a bigger per-day number. The [[Dashboard]] § *Rhythm*
capacity table does **not** change.

## Decided

| # | Question | Decision | Date |
|---|---|---|---|
| 1 | How far into code does the lane reach? | **Up to and including small bug fixes.** Mechanical work, plus real logic fixes that are small and well scoped. Not design, and not a card the artifact gate routes to an ADR or a note. | 2026-08-30 |
| 2 | Does a cloud run build before it opens a PR? | **Yes. Linux presets plus `ctest`, and a red build opens no PR.** CLAUDE.md's "Miguel compiles" rule is about his ownership of the toolchain, and he is not present in this lane, so the rule has no referent here. | 2026-08-30 |
| 3 | Where does the daily report land? | **A vault note in `docs/07 Journal/`**, falling back to a rolling GitHub issue in the engine repo if a cloud session cannot reach the vault repo. | 2026-08-30 |
| 4 | Does the run get the vault? | **Yes, and it does not clone it.** The routine checks it out as a second `sources` repo, and the session symlinks it to `docs/` as its first act. Proven by the probe; no credential of any kind is involved. | 2026-08-30 |
| 5 | Does the run watch its own PR? | **Yes. It reports whether its PR is failing CI**, not just that it opened one. Mechanism is unsettled, see § *Watching the PR*. | 2026-08-30 |
| 6 | Does the lane inherit the attended entry prompt? | **No. It gets its own.** The attended one assumes a human is present to compile, to decide and to answer a question mid-run. | 2026-08-30 |
| 7 | Does the lane move its card on the [[Sprint Board]]? | **Yes, and the columns are its state.** Done when every clause is met, Review / Demo when a PR is open or what is left needs Miguel. Only the board line; the rest of `/card-close` stays his. | 2026-09-04 |

**Decision 2 is the one to watch.** It is the first carve-out from a CLAUDE.md rule rather
than an application of one, and it is what makes decision 1 safe. A small logic fix that
nobody compiled is negative value, because Miguel debugs it in the evening he was meant to
spend building.

## Mechanism

**claude.ai routines**, created with `/schedule` (the `RemoteTrigger` API). They execute in
Anthropic's cloud on a cron schedule, so the PC being off is irrelevant.

**Ruled out: `CronCreate` and `/loop`.** Both are session-only and in-memory, and jobs fire
only while the local REPL is idle. The `durable` flag has no effect. Neither survives the PC
going to sleep, which is the whole requirement.

**The routine is live**, created 2026-08-30 and cut to two fires a weekday on 2026-08-31. Its
configuration is in [[Autonomous Lane — Routine Prompt]] § *Routine configuration*. Everything
below has been observed working except the PR path — see § *State*.

```mermaid
flowchart LR
    R["Routine fires<br/>weekday morning"] --> D["Clone the vault<br/>into docs/ over HTTPS"]
    D --> C["Pick the top eligible<br/>Auto card"]
    C --> W["Work it in the<br/>cloud sandbox"]
    W --> B{"Code card?"}
    B -->|yes| V["cmake --preset linux-debug<br/>+ ctest"]
    B -->|no| N["Vault or report only"]
    V -->|green| P["Open a PR.<br/>Never merge."]
    V -->|red| X["No PR.<br/>Say so in the report."]
    P --> CI["Watch the PR's CI"]
    CI --> MV["Move the card:<br/>Done, or Review / Demo"]
    X --> MV
    N --> MV
    MV --> REP["Daily report"]
    REP --> M(["Miguel reads it that evening"])
```

## Watching the PR

Decision 5 says the run reports its PR's CI result. **How is not settled**, and the three
shapes are a real trade rather than a detail.

| Shape | Cost | Report quality |
|---|---|---|
| **Wait in-session**, polling until the checks settle | ~16 min of wall clock the run sits idle | Same-day and complete |
| **Next-day pickup**: open the PR, end the run, and let tomorrow's run read yesterday's result | Free | Lags a day, and a red PR sits unreported overnight |
| **A webhook trigger** on the PR's check failure, firing a second routine that diagnoses it | Free, and it is the shape `RemoteTrigger` already supports | Same-day, and it reacts instead of polling |

**Decided 2026-08-30: none of the three as written. Push early, check late.** The run opens
its PR as soon as the work is green locally, then continues with the rest of its card list,
then reads the PR's checks as its last act before writing the report. CI runs during work the
session was doing anyway, so the wait costs nothing and the report is same-day.

**Floor:** if the checks have not settled by then, the report says so, and the next day's run
reads the result as its first act. A red PR is therefore reported within one day at worst.

The webhook stays the upgrade path if that floor ever gets hit often. It is not worth a second
routine before the first one has run.

## Getting the vault into the sandbox

**A routine's `job_config.ccr.session_context.sources` is an array**, so it checks out more
than one repository. The vault rides the same GitHub authorization the engine repo does, and
no token, PAT or deploy key is involved.

```json
"sources": [
  {"git_repository": {"url": "https://github.com/techattackteam/TechEngine"}},
  {"git_repository": {"url": "https://github.com/techattackteam/TechEngine-vault"}}
]
```

**Proven by the 2026-08-30 probe run.** Both repos land as siblings under `/home/user`, the
engine one arrives with no `docs/`, and `ln -s /home/user/TechEngine-vault docs` makes the
whole vault readable at the path every rule assumes. Auth needed no token: the clones are
https, and a global `url.https://github.com/.insteadOf git@github.com:` rewrite is configured,
so even the ssh-form URL in `CLAUDE.md` resolves. The authorization question is closed.

**The symlink was not safe in the engine tree, and now is.** `.gitignore` held `/docs/`, and a
pattern with a trailing slash matches a directory only. The mount is a *symlink*, so git saw it
as untracked and an auto PR could have committed it. Confirmed by the probe: `git check-ignore`
found no match. The pattern is now `/docs`, and the routine prompt also forbids `git add -A`.

**Considered: make the vault public.** No longer needed, and it was always the weaker option.
It publishes the whole project brain, including the vision and the company intent, which is a
much larger decision than this lane. It also fixes reads only, since pushing the daily report
still needs a credential.

**Closed without a test.** The `workflow` token scope no longer matters, because workflow edits
are outside § *Eligibility*, so the lane never attempts the push that scope would block. A cold
`FetchContent` configure may be slow, but that is a cost to measure on the first runs rather
than a reason to reopen decision 2.

## Eligibility

Lane is **not a new kind**. A Process card run unattended is still a Process card, and the ID
keeps carrying the kind ([[Planning Workflow — Artifact Gate]] § *Task attributes*). Lane
rides the **weight** axis instead, because weight already answers "which slot does this run
in":

`· P2 · 🤖 Auto` joins `🟢 Deep` / `🟠 Moderate` / `🟡 Light`.

**Eligible.** Research and technique evaluation. Vault freshness and drift checks. Backlog
trigger sweeps. CI failure diagnosis. Mechanical code sweeps, of which S4-T2's `detail` to
`internal` rename across 15 files is the model case. Test scaffolding. Small, well-scoped bug
fixes with a green Linux build behind them.

**Not eligible.** Anything the artifact gate routes to an ADR or a design note, because
decisions are Miguel's. Anything touching `.github/workflows/`. Anything whose done-condition
needs a Windows leg, a demo capture or a visual check. Anything on the sprint's critical path,
since an unattended lane cannot be a dependency.

## Hard stops

- **It never merges.** A routine opens a PR and stops. This is not negotiable. #50 merged
  itself the moment its checks went green and carried half its change, because green checks
  cannot see an unstaged file.
- **It never commits to `master`**, in either repo, and it cuts branches as
  `<card ID>/<slug>` from a freshly fetched `origin/master` (CLAUDE.md rule 9).
- **No AI attribution in any commit or PR body** (CLAUDE.md rule 10), **and the author field
  counts.** Rule 10 names the trailer and the `🤖 Generated with` line, which are things a
  session *adds*. The sandbox ships a global git identity of `Claude <noreply@anthropic.com>`,
  so the author field is the one place this lane breaks the rule **by default rather than by
  slipping**. The environment's `GIT_AUTHOR_*` variables override it and step 1 of the prompt
  sets it again per repo, belt and braces, because losing either would be silent.
- **One PR-producing card per weekday, maximum.** See the cost model.

## Cost model

An Auto card costs zero of Miguel's day capacity and is **not free**.

| Cost | Amount | Notes |
|---|---|---|
| PR review | ~15 min each | Real capacity. Budget it on a 🟡 day, not on top of a 🟢 evening. |
| CI, code card | 16.1 billed min | Measured, ADR-008 §9. At one per weekday that is ~320 min/month against the ~2k budget, so about 16%. |
| CI, vault or report card | 0 | Vault commits take no PR, and a docs-only or `.claude/**` PR draws no CI since #54. |
| **Claude weekly usage** | the binding one | Every fire spends the weekly allowance whether or not it opens a PR, so a report-only day is **not** free here the way it is on the CI row. This is what cut the schedule from four fires to two on 2026-08-31. |

**The cap is one PR per day, not one per fire, and the routine fires twice.** Two code cards a
day would be ~650 CI minutes a month, a third of the budget for one lane. The day's report note
is what carries that state between fires: a fire that reads a PR already recorded there takes
report-only work instead.

**Two fires, not four, since 2026-08-31, and the reason is the usage row rather than the CI
row.** Four fires a weekday spent enough of the weekly Claude allowance to compete with
Miguel's own attended sessions, which are the thing this lane exists to protect. The CI cap
never bound, because it is per day and was already one.

Prefer report-only and vault cards anyway. They cost nothing and they are the lowest-risk half
of the eligibility list.

## State

**Written, 2026-08-30.** `CLAUDE.md` carries the build carve-out and the HTTPS clone command.
[[Planning Workflow — Artifact Gate]] carries 🤖 Auto on the weight axis and § *The 🤖 Auto
gate*. `/sprint-plan` fills the two lanes separately and adds no board column.
[[Technical Lead Charter]] § *The autonomous lane* carries the exception, and
[[Working with Claude — Operating Guide]] points at it. The interface exists as
[[Autonomous Lane — Routine Prompt]] and [[Autonomous Run Report Template]].

**Probed 2026-08-30**, one-shot, `trig_01LDrC66Jkra1mDkgav4Pevr`, read-only and no CI. The
two-source checkout, the symlink, vault reads and the toolchain are all confirmed. Measured
environment in [[Autonomous Lane — Routine Prompt]] § *The environment, as measured*.

**Four things the probe broke that reasoning had gotten wrong**, all now fixed in the prompt:

| Found | Consequence |
|---|---|
| **There is no `linux` configure preset.** Each config has its own (`linux-debug`, `linux-release`, …), unlike the Windows leg where one covers both. | The prompt's build line was simply invalid. |
| **Both checkouts arrive shallow (50 commits) and on a detached HEAD**, with a stale local `master`. The vault's sat 16 commits behind its real tip. | A naive push is rejected non-fast-forward, and the error reads like an auth failure. Step 2 now re-anchors both repos first. |
| **`.gitignore`'s `/docs/` does not match a symlink.** A trailing slash matches directories only. | An auto PR could have committed the vault mount. Pattern is now `/docs`. |
| **The one-shot fired twice**, 58 seconds apart. | Harmless for a probe. For a PR-opening lane it is two PRs per card. Step 3 is now an idempotency check. |

**Probe 2, same day**, `trig_01Gp38qRCui3rwoNHaXR6DK1`. It confirmed the `.gitignore` fix, and
it closed the two remaining questions with real numbers.

- **The vault push works.** After the re-anchor, `git push --dry-run origin master` returns
  *Everything up-to-date*. Probe 1's rejection was a stale ref, never auth, as suspected.
- **The engine builds and its tests pass**, in **85 seconds** cold: configure 20 s, build 64 s,
  `ctest` 1 s. Build tree 479 MB. The lane's build carve-out costs about a minute and a half,
  not the many minutes `FetchContent` had me worried about.
- **But a cold sandbox cannot build at all until five apt packages are installed.** Configure
  dies at 8 seconds on GLFW's X11 and Wayland headers, and the error names none of them. The
  runner logs `No setup script configured`, so the environment supports a setup script and that
  is the right home for it. The prompt does it meanwhile.
- **`allowed_tools` is not a sandbox.** Probe 2 was created with four read-only tools and used
  `Write`, `ToolSearch`, GitHub MCP tools and `PushNotification` regardless. The lane's safety
  rests on the prompt and on branch protection, never on that field.

**It also found a vault bug that has nothing to do with this lane.** The [[Dashboard]]'s
`Reconciled against` sha, `50ca9360`, does not exist in the current history. The same commit is
now `875991e2`, so `master` was rewritten after the Aug 29 check. The stamp is repointed with
its date unchanged, because repointing is not re-earning. Every engine sha the vault records
from before that rewrite is suspect.

**Probe 3, on the new `TechEngineLinux` environment**, `trig_014YiZDGZyMKqdMGp7DjiFkJ`. The
environment's **setup script** does the three jobs the prompt used to, before Claude Code even
starts, so they are structural now rather than instructions a run might skip.

- **The build passes with the run touching no apt.** Configure 18 s, build 54 s, `ctest` 1 s,
  **200 of 200 tests passing**. About 75 seconds end to end.
- **The vault mount, the re-anchor and the deps were all already done** on arrival.
- **One finding worth the whole probe.** The image ships `/root/.gitconfig` naming
  `Claude <noreply@anthropic.com>`. Without the environment's `GIT_AUTHOR_*` and
  `GIT_COMMITTER_*` variables, **every autonomous commit would have violated CLAUDE.md rule 10
  by default.** Those variables override it, confirmed: `git var GIT_AUTHOR_IDENT` resolves to
  `Miguel Faria <miguel.al.faria@gmail.com>`. They are load-bearing, not cosmetic.
- **One cosmetic gap.** The vault checkout stays `SHALLOW` where the engine comes out
  `COMPLETE`. It commits and pushes fine, so nothing is blocked.

**First end-to-end run, 2026-08-30**, `trig_01YLjHhWfxnHepEgEyKDwoAo`, on the real 9-step
prompt. It landed [[2026-08-30 Auto Run]] and two [[Backlog]] entries, committed and authored as
`Miguel Faria`, no AI attribution. **The chain works end to end.**

It also earned its keep as a critic. Four corrections came out of it, all now in the prompt.

| Found | Why it mattered |
|---|---|
| **The setup script runs once and is then cached, but the repos are re-fetched every run.** The deps and the symlink survive; the git re-anchor does not. | Step 1 had been softened to "verify, do not redo". It is back to doing the work every time. |
| **The engine repo arrives shallow too**, not just the vault. | Its task is `git log <stamp>..origin/master`. A shallow clone makes a valid old sha fail `cat-file`, which is **indistinguishable from a sha a rewrite removed**, and step 4 sends those to opposite answers. It would have reported a false finding. |
| **Rule 10 names the trailer and the `Generated with` line, and never the author field.** | That is the one place an unattended lane breaks the rule by default rather than by slipping. Now in § *Hard stops* and in the prompt. |
| **Step 4 never said whether to fix what it finds**, and the template's wording pulls toward filing. | It filed, correctly. The opposite reading would have quietly rewritten six Accepted artifacts. Now explicit: file, never fix. |

**The work itself was real.** It confirmed no design note describes code the four commits moved
past, then went further than asked: it resolved **all 30 `file:line` citations** in the durable
artifacts and found **8 pointing at the wrong line**, none of which fail loudly. It also caught
[[ADR-013 — Profiler (Tracy-backed instrumentation)]] and [[Profiler — Design]] both pinning
Tracy `v0.13.1` against a tree on `v0.14.1`, where the tag is a wire-protocol lock. Both are
carded and neither was touched.

**The routine went live 2026-08-30** and ran unattended for the first time on 2026-08-31,
filing a [[Backlog]] trigger sweep. It was cut from four fires a weekday to **two** the same
day, on Claude's weekly usage limit rather than on CI — § *Cost model* carries the reasoning.
Note when creating or recreating one: pass `clear_mcp_connections: true` immediately after, as
the server attaches Google Drive and Claude Code Remote by default and `mcp_connections: []` on
create is ignored.

**Observed across four fires, 2026-08-31 and 2026-09-01** (S5-P1). The report shape holds: one
note per day, a section appended per fire, and each fire reading what the earlier ones did
rather than redoing it. The sharpest evidence is the Sep-1 second fire declining to re-enter
S5-P3, because the morning fire had taken it and left it open.

**Three gaps the watching found.**

| Found | Consequence |
|---|---|
| **A prompt edit in the vault does not reach the running routine.** `1f4ebfb` updated [[Autonomous Lane — Routine Prompt]] on Aug 31, and the fire five hours later still received the old four-fire text. | The vault is supposed to be the copy you edit against. Nothing propagates it, so every prompt change owes a manual paste into the routine. |
| **An empty Auto lane leaves a second fire with no work by construction.** With no card takeable and a static `master`, both report-only fallbacks are exhausted by the first fire. | The fire still spends the weekly usage allowance, which is the cost the schedule was cut on. Pause the routine, or seed the lane, across a gap with no cards. |
| **The lane read the board and never wrote it.** S5-P2 sat in To Do a day after #66 merged, S5-P3 sat there needing a call, and the Sep 3 and Sep 4 fires all reported an empty lane while refusing both. | A finished or stalled card in To Do is indistinguishable from an untaken one. Decision 7: the lane moves its card, and Review / Demo means "needs Miguel". Prompt step 9. |

One thing left.

1. **The PR path is still unproven.** Every run so far has been report-only, so nothing has yet
   branched, built and opened a PR unattended. **S5-P2 is that test**, unblocked on 2026-09-01
   when S5-P1 closed and its ordering clause was discharged. It also inherits S5-P1's dropped
   clause, the **one-PR-per-day cap**, which only a PR-opening run can observe.
