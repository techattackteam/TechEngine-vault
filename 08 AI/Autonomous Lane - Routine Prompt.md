# 🤖 Autonomous Lane: Routine Prompt

The exact text pasted into a routine's `job_config.ccr.session_context.events[].data.message`.
It is the lane's real interface, so it lives here in version control rather than only in the
API. Model in [[Autonomous Lane - Design]].

**A cloud run starts with zero context**, so this prompt has to be self-contained. It cannot
assume the conversation that designed the lane, and it cannot ask a question, because nobody is
there to answer one.

## Routine configuration

| Field | Value |
|---|---|
| `environment_id` | `env_016JsaV5uNQ9FpqHm9WFaour`: **TechEngineLinux**, the purpose-built environment. Its setup script installs the build deps, re-anchors both repos and mounts the vault, so the prompt only verifies them. Not the `Default` environment. |
| `sources` | both repos, engine first: `TechEngine`, then `TechEngine-vault` |
| `model` | Opus 5.5 (`claude-opus-5-5`), read off the routine on 2026-09-26. The lane's risk is judgment on bug fixes, not throughput. |
| `cron_expression` | `7 8,13 * * 1-5`: **08:07 and 13:07 UTC, weekdays** (09:07 and 14:07 in Lisbon summer time), read off the routine on 2026-09-26. Cut from four fires on **2026-08-31**. Minimum interval is one hour. Minute 7 rather than 0 keeps it off the mark every scheduler in the world piles onto. **Weekdays only, deliberately**: the weekend is Miguel's own dev time and a run pushing to vault `master` mid-session would collide with him. |
| Status | **Paused** since the Sep 4 fires (all triggers paused, seen 2026-09-26). Resume it rather than re-creating it; paste the current prompt first. |
| **Why two and not four** | **Claude's weekly usage limit**, not the CI budget. Four fires a weekday spent enough of the weekly allowance to compete with Miguel's own attended sessions, which are the lane's whole point. See [[Autonomous Lane - Design]] § *Cost model*. |
| **DST** | **Breaks on 2026-10-25**, when Lisbon drops to UTC+0. Cron stays UTC, so every fire shifts an hour earlier in local terms. Re-point the expression then, or accept the shift. |
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

STEP 1: FIX THE GIT STATE AND THE IDENTITY. DO THIS, DO NOT JUST CHECK IT.
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

STEP 2: TODAY'S FIRES SHARE ONE FOLDER, AND EACH FIRE WRITES ITS OWN NOTE.
This routine fires twice a weekday. Reports live in docs/07 Journal/autoruns/<today's date>/,
one note per fire, named <today's date> <HH-MM> Auto Run.md with the fire's Lisbon start time
(for example 2026-09-04/2026-09-04 09-14 Auto Run.md). If today's folder exists, read every
note in it first: they record what today's earlier fires did, and you never redo their work
or re-report their findings.
STOP AND CHANGE NOTHING if the newest note in today's folder is under 30 minutes old. That is
a double fire, which has been observed, and not a new slot.
ONE PR PER DAY, ACROSS BOTH FIRES. If any note in today's folder records a PR already opened, this fire
takes report-only work instead: research, a freshness check, backlog grooming, or reading that
PR's CI. A code card costs 16.1 billed CI minutes against a budget of about 2000 a month, so
two code cards a day would be about 650 a month, a third of it, for one lane.

STEP 3: READ IN.
Read, in order: CLAUDE.md, CONVENTIONS.md, docs/00 Dashboard/Dashboard.md,
docs/06 Sprints/Sprint Board.md, docs/08 AI/Autonomous Lane - Design.md.
Then read the notes in the most recent earlier day's folder under docs/07 Journal/autoruns/,
if there is one. If they name a PR whose CI had not settled, check that PR now and carry the
result into today's report. If they name a PR at all, check whether it has merged. A merged PR closes its
card: move that card to Done, in step 9's format, before picking anything.

STEP 4: PICK ONE CARD.
From the Sprint Board's To Do column, take the highest-priority card tagged "🤖 Auto".
Take exactly one. Only To Do counts. A card in Review / Demo is waiting on Miguel and this lane
never re-enters it; a card in In Progress is attended work.
If no Auto card is open, the fallback depends on which fire you are.
THE MORNING FIRE (it starts before 12:00 UTC) runs a vault freshness check: read the Dashboard's
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
THEN THE MORNING FIRE SCREENS UP TO FIVE PAPERS.
The board is docs/05 Research/Research.md, an Obsidian kanban: keep its frontmatter and its
settings block exactly as they are. Take cards from the top of the "TO VALIDATE 📋🤔" column,
skipping any that today's earlier fires already screened. For each one:
  - Find the paper's real title and a stable link to the paper itself (the PDF, or an arXiv
    abstract page). Never take a title from a URL slug. If the link is an index, a
    bibliography, a project page with no identifiable paper, or unreachable, do not guess.
  - Read the abstract, and enough of the paper to judge how it fits TechEngine's Roadmap and
    design notes.
  - Move the card to "TO VALIDATE - MIGUEL REVIEW", in the format already used there:
      - [ ] <stable link> - **<title>** | <venue> <year> (<topic>)
      	<one sentence: what the paper is, and how it fits TechEngine>
    Keep the card's topic tag, and keep any note its author wrote on it.
  - A paper clearly off the roadmap still goes to MIGUEL REVIEW, with its sentence starting
    "Recommend reject:" and the reason. A link you could not resolve goes there too, with its
    sentence starting "Could not resolve:" and what you tried.
NEVER approve, and NEVER reject. Do not touch Paper.md, the topic columns or REJECTED, and
never tick a checkbox. Approval is Miguel's, through /paper-validate, and a card's column never
grants it. List every card you screened in the report.
THE AFTERNOON FIRE (12:00 UTC or later) SWEEPS ONE MODULE FOR CODE THAT DOES NOT NEED TO EXIST.
Rotate through engine/base, engine/platform, engine/core, engine/client, engine/app, apps/.
Take the module after the one the most recent sweep report in docs/07 Journal/autoruns/ names,
or engine/base if there is none. Read the whole module, source and tests.
First record its size: the line count of its .hpp, .cpp and .inl files, source and tests
separately, next to the previous sweep's count for the same module if there is one.
Look for: the same logic written in two or more places; dead code (a function, type, branch or
include that nothing uses); speculative generality (an abstraction with one implementation, a
parameter no caller varies, a wrapper that only forwards); and code much longer than its job.
Style and formatting are not findings: .clang-format, .clang-tidy and /te-review own those.
A symbol is NOT dead if a design note, an open card or a TODO(<card ID>) names it: that is a
seam built ahead of its consumer. Read docs/06 Sprints/Backlog.md first and never file twice.
FIX ONLY THE OBVIOUS FINDINGS. A finding is obvious only when ALL of these hold:
  - It is dead code with no reference anywhere in engine/, apps/, sdk/, tests/ or projects/,
    tests included (tested code is not dead, and deleting it is a decision); or it is an exact
    duplicate inside one module, fixed by reusing an existing function or by adding a `static`
    function in the same .cpp.
  - The fix adds no header and no public API, and removes nothing under sdk/ or under any
    module's public include/ directory.
  - The tests pass unedited, and the whole diff stays under about 100 lines.
  - Step 5's check of Miguel's files passes.
Bundle the obvious fixes into ONE PR titled "Code sweep: <module>", on a branch named
sweep/<module>-<today's date> (for example sweep/base-2026-10-01). A sweep has no board card,
and this is the one branch name without a card ID. Follow steps 6 to 8, and skip step 9. If
today's notes already record a PR, file the fixes instead of making them.
Every other finding becomes a Backlog entry under the module's heading: `#prio/low`, or
`#prio/medium` when it would remove more than about 50 lines; "Found by the code sweep on
<date>"; the file:line; the simpler shape; and roughly how many lines it would remove.

STEP 5: DO THE WORK.
Follow CLAUDE.md and CONVENTIONS.md exactly. Rule 0 is match the surrounding file.
BEFORE TOUCHING CODE, CHECK MIGUEL'S FILES. List the files changed by every open PR in the
engine repo, and by the branch of every card in the Sprint Board's In Progress column. If your
change would touch any of them, stop before editing and report it: two branches editing one
file is a merge conflict that lands on Miguel's evening.
A REFACTOR MUST PASS THE TESTS AS THEY STAND. If you have to edit a test to make a refactor
pass, the behaviour changed: undo it and report the card as mis-scoped. If no test covers the
code you refactor, say so plainly in the PR body.
A code change is in scope only when the card's done-condition fully specifies the behaviour.
If you find yourself choosing how something should behave, that is a decision, and it is
Miguel's.
If the card turns out to need a decision, a Windows leg, a demo capture, a visual check, or
any change under .github/workflows/, it was mis-scoped: stop, do not improvise, and say so in
the report so it can be re-planned as an attended card.

STEP 6: IF IT CHANGED CODE, PROVE IT.
  cmake --preset linux-debug && cmake --build --preset linux-debug && ctest --preset linux-debug
Note there is NO preset called plain "linux" on this leg; each config has its own.
A red build or a failing test means NO PR. Report what broke and stop there.
You may build here. This is the carve-out in CLAUDE.md's "Miguel compiles" rule, and it
applies only to this unattended lane and only to the Linux presets.

STEP 7: OPEN A PR, EARLY, AND NEVER MERGE.
Branch from the freshly fetched origin/master of step 1, named <card ID>/<slug>, for example
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
ONE PR-PRODUCING CARD PER DAY, not per fire. Step 2 is where you check that.

STEP 8: CHECK CI LAST.
After the work is done, read the PR's checks. They have been running while you worked.
If they have not settled, say so; the next run picks it up.

STEP 9: MOVE THE CARD ON THE BOARD. THE BOARD IS THE ONLY STATE THE NEXT FIRE READS.
The Sprint Board's columns are this lane's state. A card left in To Do after a fire worked on
it is a card the next fire either redoes or refuses, and both have happened. So before the
report, put the card where the next fire needs to find it:
  - Every `done:` clause met and no PR owed (a vault-only card): move it to ✅ Done. Write the
    entry the way the ones already there are written: `- [x]`, the card line, then
    `**<Mon D>**` and two or three sentences on what closed and what was left out. The
    `done:` block does not come along; the sentences replace it.
  - A PR opened: move it to 👀 Review / Demo, with the PR number and branch on the line. It is
    Miguel's to merge. The fire that later finds the PR merged (step 3) moves the card to Done,
    with the merge sha and the PR number.
  - Anything left needs Miguel (a judgement call, a clause outside the gate, a card step 5
    stopped): move it to 👀 Review / Demo, and say on the line exactly what he must decide.
  - A card no fire touched stays in To Do, untouched.
Move the entry, never copy it. Only the board line is yours. Closing a card also touches other
notes (a design note's status line, a Known Issues row, the sprint note): that is Miguel's
`/card-close`, so list what it owes under "Needs you" instead of doing it.

STEP 10: WRITE THE REPORT, UNLESS THERE IS NOTHING TO SAY.
A fire that changed nothing, opened no PR and found nothing worth filing writes NOTHING: no
note, and no empty day folder. Say so in your final message instead. A journal padded with
"nothing to report" buries the days that mattered.
Otherwise create your own note in today's folder (step 2's name) from
docs/Templates/Autonomous Run Report Template.md, creating the folder if yours is the day's
first note. Never edit an earlier fire's note.
Commit straight to the vault's master and push. Pull first: an earlier fire may have pushed
since your checkout. The vault takes no branch, no PR and no CI. The engine repo is PR-only.
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
  empty Auto lane never wastes a fire. Paper screening was added on 2026-09-26 for the same
  reason: once the freshness check has nothing new to cover, the *TO VALIDATE* column still
  does. The cap of five papers per fire keeps one fire's usage bounded.
- **Step 4's screening never approves or rejects.** The Research board's column is the only
  record of Miguel's judgement on a paper, so an unattended move to a topic column or to
  *REJECTED* would forge that judgement.
- **The afternoon code sweep exists to keep the codebase from growing waste** (2026-09-27):
  duplication, dead code and speculative abstractions. It fixes only what needs no design
  call. Dead code with a test, or a duplicate that needs a new shared function, is a decision
  about the engine's shape, so it is filed for Miguel. The per-module line count makes growth
  visible from one sweep to the next.
- **Sweep PRs have no card, on purpose** (2026-09-27). The `sweep/` branch prefix and the
  "Code sweep" title identify them, and the run report is their record. They are the one
  exception to CLAUDE.md rule 9's `<card ID>/<slug>` branch names.
- **Step 5's file check exists because refactors are now in scope** (2026-09-26). A sweep or a
  bug fix rarely touches the file Miguel is working in; a refactor often does.
- **Step 5's escape hatch is the important one.** The gate is applied at planning by a human,
  so the run's job when the gate was wrong is to notice and stop, not to improvise past it.
- **Step 7 repeats four rules the lane is most likely to break**: the branch name, the staging
  ban, the merge ban, and AI attribution. All four have a history in this repo.
- **Step 9 exists because the board was read and never written.** Through 2026-09-04 every
  fire read the To Do column as its input and left it as it found it. S5-P2 sat in To Do a day
  after its PR merged, S5-P3 sat there needing a call, and four fires in a row reported an
  empty lane while refusing both. The columns are now the lane's state, and Review / Demo is
  the honest home for "this needs Miguel".
