---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 To Do — [[2026-08 Sprint 02 — Base Foundation]] (Jul 25 – Aug 28)

- [ ] **S2-T5** — Assert → Logger integration + flush-on-fail · P2 · 🟠 Moderate
- [ ] **S2-T7** — `FrameContext` + fixed-timestep accumulator (headless) · P1 · 🟢 Deep
- [ ] **S2-T8** — Determinism + clamp tests (injected time source) · P1 · 🟢 Deep
- [ ] **S2-T9** — End-to-end wire-up = sprint demo · P2 · 🟠 Moderate
- [ ] **S2-T11** — Skill `te-module` scaffolder · P3 · 🟡 Light


## 🔨 In Progress

- [ ] **S2-T10** — Root `CONVENTIONS.md` (B4) · P2 · 🟠 Moderate — **runs in parallel**, not
	  late. File opened Jul 25 (B4 migrated in; B4 → pointer + history). **Flag conventions as
	  you review** — they land here live. CLAUDE.md's section **shrunk to a pointer + the 3
	  AI-default corrections (Jul 26)**. Remaining: ratify the *Open* rows — 3 are ⚠️ provisional
	  and need your call, not Claude's reading.


## 👀 Review / Demo

- [ ] **S2-T15** — Reconciliation stamp on [[Dashboard]] (ADR-012 §6) · P2 · 🟡 Light —
	  **Jul 27** → PR #NN. Closes the ADR-012 chain. Stamp seeded at **`2b4bc38e`
	  (2026-07-25)** — the last drift check that *actually* ran, **not** today's HEAD:
	  this session reconciled CLAUDE.md and the Operating Guide but never checked the
	  design notes against the code, and seeding it current would have been exactly the
	  formality §6 forbids. So it ships **already reading "behind"** — PRs #8–#15 land
	  after it, `base` is the exposed area — which is the mechanism working, not a defect.
	  Rule 2 gained the compare step; both ceremonies advance the stamp **only if the
	  drift check ran**. First real advance due at the **Aug 1–2** review.


## ✅ Done — [[2026-08 Sprint 02 — Base Foundation]]

- [x] **S2-T14** — Retire `/task-start` + `/task-wrap` · P2 · 🟡 Light — **Jul 27** → PR #15.
	  Rescoped from "retarget at the nested repo" once checked: they were the **only** two
	  commands that ran git, so nothing was left to retarget (`/sprint-plan`,
	  `/weekly-review`, `/vault-clean` only write files; everything else in `.claude/` is
	  read-only `log`/`grep`/`show`/`ls-tree`). Most of what they enforced was vault-in-repo
	  friction T13 deleted, and their git calls had started failing **silently** against
	  ignored paths. Rule 9 absorbed the two rules that earned their keep — cut from a freshly
	  fetched `origin/master` (the #8–#10 conflict fix) and `<card ID>/<slug>`, now the only
	  commit→card link. Operating Guide's table, flowchart and bracketing bullet updated.
	  ADR-012 §Consequences still says "must retarget" — Accepted, so left unedited; this card
	  is the record that it was resolved by removal.
- [x] **S2-T13** — Vault repo cutover ([[ADR-012 — Vault repository split]]) · P1 · 🟠 Moderate —
	  **Jul 27** → PR #14, and **this card's own move is the first commit that needed no PR**.
	  `docs/` is now `TechEngine-vault`, cloned in place — path unchanged, 17 commits of history
	  preserved via `git subtree split`. `.gitignore` + root `.ignore` landed in the same commit
	  and were **verified both directions**: `git check-ignore` reports `docs/` ignored while a
	  root ripgrep still returns vault hits. **T14/T15 unblocked.** Vault README's "versioned
	  alongside the engine, in lockstep" claim was true until this task and is now corrected.
- [x] **S2-T4** — Assert: four tiers + single handler · P1 · 🟢 Deep — **Jul 27** → PR #13.
	  Four tiers + one hookable handler (ADR-011 §5), `SourceName.hpp` for call-site identity,
	  `thread_local` recursion guard on the assert→log path (§7), `base` keeps the no-break
	  default handler so the DAG stays leaf-clean. `TE_ASSERT_DEV` is **PUBLIC** on purpose —
	  PRIVATE and consumers silently fall back to the header default while the lib compiled the
	  opposite; `AssertTests.cpp` is what catches that split. RelWithDebInfo presets added and
	  run **by hand**, not as a CI leg — the config→knob half can't be proved from inside a
	  Debug binary ([[Assert — Design]]). Cost four compile-fix commits, mostly the Linux leg.
- [x] **S2-T3** — Channels + `LogRecord` + console/file sinks · P1 · 🟢 Deep — **Jul 25** → PR #9.
	  Handles + explicit registration (ADR-011 §2), filtering at max(process, module, channel),
	  sink **array** not slot, console + rotating file behind one spdlog logger, one flatten shared
	  with the stderr fallback. **Sink path is test-reachable** — the criterion T2's
	  green-but-unreached bug earned. Ring sink → T5.
- [x] **S2-T2** — Logger core · P1 · 🟢 Deep — **Jul 25** → PR #8 (`6f054b6b`) merged green.
	  `std::format` seam + spdlog private (ADR-011 §1), per-config compile-time gate (§4), 9 Catch2
	  cases, `.clang-format` = CLion scheme. **`std::format` survived the Linux leg** — ADR-011's
	  fmt-fallback trigger did not fire.
- [x] **S2-T6** — Clock implementation ([[Clock — Design]]) · P1 · 🟠 Moderate — **Jul 26** →
	  PR #10 (`2e16a067`). `now()` / `totalTime()` / `wallClock()` / `frame()` + `advanceFrame()`;
	  **plain `uint64_t` counter** — the atomic already sits on the diagnostics side (`g_frame`),
	  so the cross-thread hop is downstream. **No seam** — injected time source goes in the *loop*
	  at T7/T8. 6 Catch2 cases, lower-bounds-only (no upper bound = no runner-load flake).
	  **Also carried:** T3's stderr-fallback flatten fix + T10's `[[nodiscard]]` ban.
- [x] **S2-T1** — Diagnostics ADR (Logger + Assert) · P1 · 🟢 Deep — **Jul 25** →
	  [[ADR-011 — Diagnostics (Logger & Assert)]] Accepted; **T2–T6 unblocked**. Seam changed
	  under review: `fmt`-in-header was unbuildable → **`std::format`**, spdlog private, no new
	  dep. Frame stamp **pushed by `app`**, not pulled. Partial supersession of ADR-006 §6's
	  assert-tier clause tracked in [[ADR Index]].
- [x] **S2-T12** — Land the accumulated vault + AI-config work through the ruleset · P3 · 🟡 Light
	  — **Jul 26** → PR #11 24 files, **+409/−237, zero code**. Backlog is now a
	  staging area — entries cut at planning, not swept later (350→289 lines); `/task-start` +
	  `/task-wrap` bracket every task off a freshly fetched `origin/master`, which is the fix for
	  the squash-merge branch reuse that conflicted PRs #8–#10; CLAUDE.md conventions reduced to a
	  pointer + the 3 AI-default corrections, and its stale test-target names fixed
	  (`TechEngineBaseTests` / `sdk-smoke` / `TechEngine::sdk`).
	  Card was retitled: the original `feat/improving-vault` branch no longer exists.




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null]}
```
%%