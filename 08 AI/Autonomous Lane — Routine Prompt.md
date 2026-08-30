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
| `environment_id` | `env_016JsaV5uNQ9FpqHm9WFaour` — **TechEngineLinux**, the purpose-built environment. Its setup script installs the build deps, re-anchors both repos and mounts the vault, so the prompt only verifies them. Not the `Default` environment. |
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
| Git state | On the raw image **both checkouts are shallow (50 commits) and on a detached HEAD**, with a stale local `master` that sat 16 commits behind the real tip. TechEngineLinux's setup script re-anchors both; the engine comes out `COMPLETE`, the vault stays `SHALLOW` and that is harmless. |
| Toolchain | cmake 3.28.3 · ninja 1.11.1 · clang 18.1.3 · git 2.43.0. Runs as **root**, `apt-get` works. |
| Presets | `linux-debug`, `linux-release`, `linux-relwithdebinfo`, `linux-profile`, `linux-ubsan`, `linux-tsan`, `linux-coverage`. **There is no preset named `linux`**, unlike the Windows leg where one configure preset covers both configs. |
| System deps | Missing on the stock image, and configure fails without them: GLFW needs the X11 and Wayland headers `ci.yml` installs. **TechEngineLinux's setup script installs them**, verified present. |
| Build cost | On TechEngineLinux, with the run touching no apt: configure **18 s**, build **54 s**, `ctest` **1 s** and **200/200 passing**. About **75 s** end to end, build tree 479 MB. |
| Push | `git push --dry-run origin master` on the vault reports **Everything up-to-date**. The report path is proven. |
| Git identity | **The image ships `/root/.gitconfig` naming `Claude <noreply@anthropic.com>`.** The environment's `GIT_AUTHOR_*` and `GIT_COMMITTER_*` variables override it, confirmed by `git var GIT_AUTHOR_IDENT` resolving to `Miguel Faria <miguel.al.faria@gmail.com>`. **Those variables are load-bearing, not cosmetic:** without them every autonomous commit violates CLAUDE.md rule 10 by default. |

## The setup script

It lives on the TechEngineLinux environment, runs **after both repos are checked out and
before Claude Code starts**, and does three jobs the prompt would otherwise have to. Source of
truth is the environment itself; this is the copy to edit against.

```bash
#!/bin/bash
# TechEngine autonomous lane. Never fails the session: it warns instead,
# and the routine prompt verifies each of these before it works.

echo "=== setup 1/3: system deps (same list ci.yml installs) ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || echo "WARN: apt-get update had failures (PPA 403s are expected)"
apt-get install -y -qq \
  xorg-dev libgl1-mesa-dev libwayland-bin libwayland-dev libxkbcommon-dev \
  || echo "WARN: apt install failed, the Linux build will not configure"

echo "=== setup 2/3: de-shallow and re-anchor both repos ==="
for repo in /home/user/TechEngine /home/user/TechEngine-vault; do
  [ -d "$repo/.git" ] || { echo "WARN: $repo is not a git checkout"; continue; }
  echo "--- $repo"
  git -C "$repo" fetch --unshallow origin || git -C "$repo" fetch --depth=1000 origin
  git -C "$repo" fetch origin master
  git -C "$repo" checkout -B master origin/master
  git -C "$repo" status -sb
done

echo "=== setup 3/3: mount the vault at docs/ ==="
[ -e /home/user/TechEngine/docs ] || ln -s /home/user/TechEngine-vault /home/user/TechEngine/docs
ls -ld /home/user/TechEngine/docs
test -f "/home/user/TechEngine/docs/00 Dashboard/Dashboard.md" \
  && echo "OK: vault readable at docs/" \
  || echo "WARN: vault NOT readable at docs/, the session must stop"

echo "=== setup done ==="
```

**Known gap, cosmetic.** On the 2026-08-30 verification the engine came out `COMPLETE` and the
vault stayed `SHALLOW` at 50 commits. It does not block anything: the vault only needs to
commit and push a report, and the dry-run push is clean. It does mean a `git log <sha>..` over
vault history can fail, so the `2>/dev/null` was dropped from the fetch above to make the next
failure visible.

**Why these three and not more.** Both git traps produce an error that names the wrong cause: a
stale-ref push reads as an auth problem, and a missing X11 header reads as a broken preset. Put
in the script, they stop being the run's problem at all.

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

STEP 1 — FIX THE GIT STATE AND THE IDENTITY. DO THIS, DO NOT JUST CHECK IT.
The setup script runs ONCE and is cached afterwards, but the repositories are re-fetched on
every run. So the deps and the docs/ symlink survive, and the git work does NOT. Both repos
arrive on a detached HEAD, and BOTH ARE SHALLOW, the engine one included. Run this every time:
  for r in /home/user/TechEngine /home/user/TechEngine-vault; do
    git -C "$r" config user.name  "Miguel Faria"
    git -C "$r" config user.email "miguel.al.faria@gmail.com"
    git -C "$r" fetch --unshallow origin || git -C "$r" fetch --depth=1000 origin
    git -C "$r" fetch origin master
    git -C "$r" checkout -B master origin/master
    git -C "$r" rev-parse --is-shallow-repository
  done
The identity lines are not optional. The image ships a global git identity of
"Claude <noreply@anthropic.com>", and left alone it puts that name on a commit.
UNSHALLOWING THE ENGINE REPO IS LOAD-BEARING, not tidiness. A shallow clone makes an old but
perfectly valid sha fail `git cat-file`, which is indistinguishable from a sha that a history
rewrite removed. Step 4 sends those two cases to opposite answers, so getting this wrong makes
the run report a false finding.
Then check the mount and the deps, and repair only if they failed:
  ls -ld /home/user/TechEngine/docs   # else: ln -s /home/user/TechEngine-vault <that path>
  which wayland-scanner               # else: apt-get install -y -qq xorg-dev libgl1-mesa-dev \
                                      #         libwayland-bin libwayland-dev libxkbcommon-dev
Finally read docs/00 Dashboard/Dashboard.md. If it cannot be read, STOP, do no other work, and
report that the vault was unreachable. Every rule below assumes docs/ is present.
Any repair is a finding about the environment and always goes in the report.

STEP 2 — DO NOT REPEAT A RUN.
If docs/07 Journal/<today's date> Auto Run.md already exists, this routine has already fired
today. STOP and change nothing. A double fire has been observed.

STEP 3 — READ IN.
Read, in order: CLAUDE.md, CONVENTIONS.md, docs/00 Dashboard/Dashboard.md,
docs/06 Sprints/Sprint Board.md, docs/08 AI/Autonomous Lane — Design.md.
Then read yesterday's report in docs/07 Journal/ if one exists, and if it names a PR whose
CI had not settled, check that PR now and carry the result into today's report.

STEP 4 — PICK ONE CARD.
From the Sprint Board's To Do column, take the highest-priority card tagged "🤖 Auto".
Take exactly one. If none is open, run a vault freshness check instead: read the Dashboard's
"Reconciled against" sha, then `git log --oneline <sha>..origin/master` in the engine repo,
and report any design note that now describes code that has moved on.
FILE WHAT YOU FIND. DO NOT FIX IT. A freshness check that quietly rewrites six artifacts is a
vault diff nobody asked for, and most of what it finds sits in Accepted ADRs that are outside
this lane's eligibility anyway. Each finding is a [[Backlog]] entry with a `#prio` and a
`Trigger:`, or it is noise and is not worth writing down.
If the stamp's sha does not resolve, separate the two causes before reporting either:
`git rev-parse --is-shallow-repository` returning true means step 1's unshallow failed and you
fix that; only a COMPLETE clone that still cannot find the sha proves it was rewritten away,
and that one you report and never fix. Do not advance the stamp under any circumstances.

STEP 5 — DO THE WORK.
Follow CLAUDE.md and CONVENTIONS.md exactly. Rule 0 is match the surrounding file.
If the card turns out to need a decision, a Windows leg, a demo capture, a visual check, or
any change under .github/workflows/, it was mis-scoped: stop, do not improvise, and say so in
the report so it can be re-planned as an attended card.

STEP 6 — IF IT CHANGED CODE, PROVE IT.
  cmake --preset linux-debug && cmake --build --preset linux-debug && ctest --preset linux-debug
Note there is NO preset called plain "linux" on this leg; each config has its own.
A red build or a failing test means NO PR. Report what broke and stop there.
You may build here. This is the carve-out in CLAUDE.md's "Miguel compiles" rule, and it
applies only to this unattended lane and only to the Linux presets.

STEP 7 — OPEN A PR, EARLY, AND NEVER MERGE.
Branch from the freshly fetched origin/master of step 2, named <card ID>/<slug>, for example
S5-P2/ccache-key. That branch name is the only link from a squashed commit back to its board
card, so get it right. Open the PR as soon as the build is green, before writing the report.
Stage explicit paths. NEVER use `git add -A` or `git commit -a`: the docs symlink lives in
the engine working tree and must never be committed.
NEVER merge. NEVER enable auto-merge. NEVER push to master in either repository.
NEVER put "Co-Authored-By: Claude", "Generated with Claude Code", or any other AI attribution
in a commit message or PR body. Write in Miguel's voice: what changed and why.
THE AUTHOR FIELD COUNTS AS ATTRIBUTION TOO. Before committing, confirm with
`git log -1 --format='%an <%ae> / %cn <%ce>'` that both are Miguel Faria. Step 1 sets it; this
is the check that it held.
One PR-producing card per run, maximum.

STEP 8 — CHECK CI LAST.
After the work is done, read the PR's checks. They have been running while you worked.
If they have not settled, say so; the next run picks it up.

STEP 9 — WRITE THE REPORT, UNLESS THERE IS NOTHING TO SAY.
A run that changed nothing, opened no PR and found nothing worth filing writes NO note. Say so
in your final message instead. A journal full of empty files is worse than a gap, because it
buries the days that mattered.
Otherwise create docs/07 Journal/<YYYY-MM-DD> Auto Run.md from
docs/Templates/Autonomous Run Report Template.md. Commit it straight to the vault's master
and push. The vault takes no branch, no PR and no CI. The engine repo is PR-only.
Lead with the "Needs you" section. Miguel reads this after a full work day, so it must be
triageable in two minutes. Say plainly what is unverified. A false "green" is the worst
thing this lane can produce.
```

## Why the prompt is shaped this way

- **Step 1 does the git work every time, and that is deliberate.** It was briefly softened to
  "verify, do not redo", on the assumption the setup script had already run. The 2026-08-30
  end-to-end run showed the script is **cached after its first execution while the repos are
  re-fetched on every run**, so the deps and the symlink persist and the re-anchor does not.
  The mount and the deps are still only checked, because those do persist. A run without the
  vault is grounded in nothing and would still look busy, so stopping is the correct output.
- **Step 2 exists because probe 1 fired twice**, 58 seconds apart. For a read-only probe that
  was harmless. For a lane that opens PRs it would mean two PRs for one card.
- **Step 4 always has work.** A freshness check is free, always useful and needs no PR, so an
  empty Auto lane never wastes a fire.
- **Step 5's escape hatch is the important one.** The gate is applied at planning by a human,
  so the run's job when the gate was wrong is to notice and stop, not to improvise past it.
- **Step 7 repeats four rules the lane is most likely to break**: the branch name, the staging
  ban, the merge ban, and AI attribution. All four have a history in this repo.
