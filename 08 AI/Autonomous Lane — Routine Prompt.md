# 🤖 Autonomous Lane — Routine Prompt

The exact text pasted into a routine's `job_config.ccr.session_context.events[].data.message`.
It is the lane's real interface, so it lives here in version control rather than only in the
API. Model in [[Autonomous Lane — Design]].

**A cloud run starts with zero context**, so this prompt has to be self-contained. It cannot
assume the conversation that designed the lane, and it cannot ask a question, because nobody is
there to answer one.

## Routine configuration

| Field | Value |
|---|---|
| `environment_id` | `env_017WeubibNtrowPL6ouZRUpZ` (Default, `anthropic_cloud`) |
| `sources` | both repos, engine first: `TechEngine`, then `TechEngine-vault` |
| `model` | `claude-opus-5`. The lane's risk is judgment on bug fixes, not throughput. |
| `cron_expression` | UTC, minimum interval 1 hour. Lisbon is UTC+1 in summer, so a 10:00 local weekday fire is `0 9 * * 1-5`. |
| `mcp_connections` | **none.** Pass `clear_mcp_connections: true`; the server attaches Google Drive and Claude Code Remote by default and the lane needs neither. |

## The environment, as measured

From the 2026-08-30 probe run. Everything here was observed, not assumed.

| | |
|---|---|
| Layout | `/home/user/TechEngine` and `/home/user/TechEngine-vault`, **siblings**. The engine repo arrives with no `docs/`. |
| Auth | Both repos clone over **https**, and a global `url.https://github.com/.insteadOf git@github.com:` rewrite is set, so even an ssh-form URL resolves. No token, PAT or key is involved. |
| Git state | **Both checkouts are shallow (50 commits) and on a detached HEAD.** The local `master` ref is stale: in the vault it sat 16 commits behind the real tip. |
| Toolchain | cmake 3.28.3 · ninja 1.11.1 · clang 18.1.3 · git 2.43.0. Runs as **root**, `apt-get` works. |
| Presets | `linux-debug`, `linux-release`, `linux-relwithdebinfo`, `linux-profile`, `linux-ubsan`, `linux-tsan`, `linux-coverage`. **There is no preset named `linux`**, unlike the Windows leg where one configure preset covers both configs. |
| System deps | **Missing on arrival, and configure fails without them.** GLFW needs the X11 and Wayland headers that `ci.yml` installs. |
| Build cost | With the deps in place: configure **20 s**, build **64 s**, `ctest` **1 s**, so about **85 s** end to end. Build tree 479 MB, of which `_deps` is 281 MB. |
| Push | After the re-anchor in step 2, `git push --dry-run origin master` on the vault reports **Everything up-to-date**. The report path is proven. |

**Two traps, both measured rather than guessed.**

The **shallow, detached checkout** is the first. A naive `git push origin master` pushes the
stale local ref and is rejected non-fast-forward, which reads like an auth failure and is not.
Step 2 handles it.

The **missing system packages** are the second. A cold configure dies at 8 seconds on GLFW's
X11 and Wayland headers, and nothing in the error says "install these". The runner logs
`No setup script configured`, so the environment supports a setup script and that is the
better home for this than the prompt. Until one is configured, step 3 does it.

## Verified 2026-08-30: `allowed_tools` is not a sandbox

Probe 2 was created with `allowed_tools: ["Bash","Read","Glob","Grep"]` and it used `Write`,
`ToolSearch`, two GitHub MCP tools and `PushNotification` anyway.

**Treat that field as a hint, not a boundary.** Every constraint that actually matters has to
be written into the prompt, and the lane's safety rests on the prompt plus the branch
protection on `master`, never on the tool list.

## The prompt

```text
You are running unattended in a scheduled cloud session for TechEngine. Nobody is available
to answer a question, so never ask one: decide, or stop and say why in the report.

STEP 1 — GET THE VAULT IN PLACE, OR STOP.
The project brain is a second repository checked out beside the engine one. Link it:
  cd /home/user/TechEngine && ln -s /home/user/TechEngine-vault docs
If that path is wrong, find it: find /home/user -maxdepth 2 -type d -name 'TechEngine-vault'
Verify by reading docs/00 Dashboard/Dashboard.md.
If that file cannot be read, STOP. Do no other work. Report that the vault was unreachable
and what you tried. Every rule below assumes docs/ is present.

STEP 2 — FIX THE GIT STATE BEFORE TOUCHING ANYTHING.
Both checkouts arrive SHALLOW and on a DETACHED HEAD, with a stale local master ref. In each
of the engine repo and docs/, run:
  git fetch --unshallow origin || git fetch --depth=200 origin
  git fetch origin master
  git checkout -B master origin/master
Confirm with `git status -sb` that you are on master and it matches origin/master.
Skipping this is the single most likely way this run fails: a push of the stale ref is
rejected non-fast-forward, which looks like an auth error and is not one.

STEP 3 — INSTALL THE BUILD DEPENDENCIES, ONCE, EARLY.
The sandbox has clang, cmake and ninja but NOT GLFW's system headers, and a cold configure
dies at 8 seconds without them with an error that does not name them. You are root here:
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    xorg-dev libgl1-mesa-dev libwayland-bin libwayland-dev libxkbcommon-dev
This is the same list ci.yml installs for its Linux leg. Some PPAs 403 through the proxy
during `apt-get update`; that is harmless, the main archive works. Skip this step only if the
card touches no code.

STEP 4 — DO NOT REPEAT A RUN.
If docs/07 Journal/<today's date> Auto Run.md already exists, this routine has already fired
today. STOP and change nothing. A double fire has been observed.

STEP 5 — READ IN.
Read, in order: CLAUDE.md, CONVENTIONS.md, docs/00 Dashboard/Dashboard.md,
docs/06 Sprints/Sprint Board.md, docs/08 AI/Autonomous Lane — Design.md.
Then read yesterday's report in docs/07 Journal/ if one exists, and if it names a PR whose
CI had not settled, check that PR now and carry the result into today's report.

STEP 6 — PICK ONE CARD.
From the Sprint Board's To Do column, take the highest-priority card tagged "🤖 Auto".
Take exactly one. If none is open, run a vault freshness check instead: read the Dashboard's
"Reconciled against" sha, then `git log --oneline <sha>..origin/master` in the engine repo,
and report any design note that now describes code that has moved on. Two ways that sha fails
to resolve, and they need different answers: step 2's unshallow did not run, which you fix; or
the sha is genuinely absent from the rewritten history, which you REPORT and do not fix,
because restamping is a ceremony's job and a stamp nobody earned is worse than none.
Do not advance the stamp under any circumstances.

STEP 7 — DO THE WORK.
Follow CLAUDE.md and CONVENTIONS.md exactly. Rule 0 is match the surrounding file.
If the card turns out to need a decision, a Windows leg, a demo capture, a visual check, or
any change under .github/workflows/, it was mis-scoped: stop, do not improvise, and say so in
the report so it can be re-planned as an attended card.

STEP 8 — IF IT CHANGED CODE, PROVE IT.
  cmake --preset linux-debug && cmake --build --preset linux-debug && ctest --preset linux-debug
Note there is NO preset called plain "linux" on this leg; each config has its own.
A red build or a failing test means NO PR. Report what broke and stop there.
You may build here. This is the carve-out in CLAUDE.md's "Miguel compiles" rule, and it
applies only to this unattended lane and only to the Linux presets.

STEP 9 — OPEN A PR, EARLY, AND NEVER MERGE.
Branch from the freshly fetched origin/master of step 2, named <card ID>/<slug>, for example
S5-P2/ccache-key. That branch name is the only link from a squashed commit back to its board
card, so get it right. Open the PR as soon as the build is green, before writing the report.
Stage explicit paths. NEVER use `git add -A` or `git commit -a`: the docs symlink lives in
the engine working tree and must never be committed.
NEVER merge. NEVER enable auto-merge. NEVER push to master in either repository.
NEVER put "Co-Authored-By: Claude", "Generated with Claude Code", or any other AI attribution
in a commit message or PR body. Write in Miguel's voice: what changed and why.
One PR-producing card per run, maximum.

STEP 10 — CHECK CI LAST.
After the work is done, read the PR's checks. They have been running while you worked.
If they have not settled, say so; the next run picks it up.

STEP 11 — WRITE THE REPORT.
Create docs/07 Journal/<YYYY-MM-DD> Auto Run.md from
docs/Templates/Autonomous Run Report Template.md. Commit it straight to the vault's master
and push. The vault takes no branch, no PR and no CI. The engine repo is PR-only.
Lead with the "Needs you" section. Miguel reads this after a full work day, so it must be
triageable in two minutes. Say plainly what is unverified. A false "green" is the worst
thing this lane can produce.
```

## Why the prompt is shaped this way

- **Step 1 fails closed.** A run without the vault is a run grounded in nothing, and it would
  still look busy. Stopping is the correct output.
- **Steps 2 and 3 are the ones the probes earned.** Both failures are invisible until they
  bite, and both produce an error that names the wrong cause: a stale-ref push reads as an auth
  problem, and a missing X11 header reads as a broken preset.
- **Step 4 exists because probe 1 fired twice**, 58 seconds apart. For a read-only probe that
  was harmless. For a lane that opens PRs it would mean two PRs for one card.
- **Step 6 always has work.** A freshness check is free, always useful and needs no PR, so an
  empty Auto lane never wastes a fire.
- **Step 7's escape hatch is the important one.** The gate is applied at planning by a human,
  so the run's job when the gate was wrong is to notice and stop, not to improvise past it.
- **Step 9 repeats four rules the lane is most likely to break**: the branch name, the staging
  ban, the merge ban, and AI attribution. All four have a history in this repo.
