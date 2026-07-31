---

kanban-plugin: board

---

## 📥 Backlog

- [ ] Full backlog → [[Backlog]]


## 📋 To Do — [[2026-08 Sprint 02 — Base Foundation]] (Jul 25 – Aug 28)

- [ ] **S2-P2** — Roadmap rewrite · P3 · 🟡 Light — strip v1-era Q4/Q1 renderer features, make future quarters honest (planned at sprint boundaries), fix Sprint 03 direction to continued foundation *(was V1)*
- [ ] **S2-P3** — Q3 note + Dashboard update · P3 · 🟡 Light — align Sprint 03 row and Dashboard's "Next milestone" with the new direction *(was V4)*


## 🔨 In Progress



## 👀 Review / Demo



## ✅ Done — [[2026-08 Sprint 02 — Base Foundation]]

- [x] **S2-P1** — Planning flow update · P2 · 🟡 Light — **Jul 31** *(was V3)*. **Plans now come
	  from design notes**, not ADRs and not the [[Backlog]]: sourced from the *Decided*-rows-vs-code
	  delta (Dev cards) and from open questions **only when they block** it (Design cards). The
	  argument that settled it wasn't preference — an Accepted ADR can hold a partially-superseded
	  clause ([[ADR Index]] tracks two), so the note's *Decided* rows are the reconciled view and the
	  ADR body isn't. ADR fallback **kept** for systems with no note, and that gap is now a
	  named finding: the **design-note coverage check** (systems only — process/meta ADRs never
	  fire it). Today it fires on ADR-007: ECS and replication have no note.
	  **Four task kinds, carried in the card ID** — `T` Dev · `D` Design · `B` Bug · `P` Process.
	  Replaces the `🔧 Vault & process` column, which was doing the kind's job on the wrong axis.
	  Design is critical-path, Process is the first thing cut, and the split is what makes "this
	  sprint was a third Process" checkable instead of assumed.
	  **Defect home answered** → [[Known Issues]], `D<n>`, seeded with D1. Bar: latent **and**
	  fails silently. A defect that misbehaves *now* is a **Bug card**, not an entry —
	  which reclassified the diagnostics-init one into **S2-B1**.
	  Touched: [[Planning Workflow — Artifact Gate]] (new *Where plans come from*, kinds,
	  Bug-vs-Known-Issue) · [[ADR Index]] gloss · [[Backlog]] (tombstones dropped) ·
	  `/sprint-plan`, `/vault-clean`, `/feature-breakdown` · `CONVENTIONS.md` + `CLAUDE.md`
	  (`TODO(D<n>)` — card IDs go stale, `TODO(S2-T9)` already does; defect IDs don't).
	  **Two holes found while wiring it:** `/sprint-plan` step 8 emptied In Progress and rebuilt
	  To Do from the new sprint note only, so an **unfixed `B` card evaporated at every boundary**
	  — now every unfinished card is re-planned or dropped out loud, and a `B` is never droppable
	  (re-plan, or demote to `D<n>`). And `/feature-breakdown` still listed three kinds.
	  **Not done:** these three `S2-P*` cards are unplanned Process work on a sprint whose goal was
	  already met, and there is still no mid-sprint scope-change note recording that.
- [x] **V2** — Backlog compression · 🟡 Light — **Jul 31**. 382 → 103 lines, flat bullets +
	  `Trigger:`, module headings only (the `utilities`/`systems` split went — it bought
	  nothing once entries were one line). Cut as covered: Profiler · job-system's "owes three
	  things" · loop timestep · ownership policy · ratify-Open-rows — all live in a design note,
	  ADR-010, or `CONVENTIONS.md`. **Cut with no trace, by decision:** Math / Allocators /
	  Containers / SDK-boundary-MIDDLE (rationale existed nowhere else — re-derive it in the
	  ADR) and the six `Infra/process` **defects** (coverage-in-CI, `TE_LOG_ACTIVE_LEVEL` fails
	  open, `initLogging` file sink untested, `SYSTEM` includes, diagnostics-init-in-exe,
	  docs-only CI burn — the last survives as an idea). **The vault has no home for defects**;
	  four of them survive only as a line on S2-T2's card. That gap is V3's to answer or not.
- [x] **V0** — Apply Opus 5 prompting patterns · 🟡 Light — review the [Opus 5 prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5) and update CLAUDE.md + vault-writing rules to counter verbosity, scope creep, and over-verification. **Gated the rest** — the patterns informed how the vault rewrite was done *(V0/V2 keep their old IDs; renaming closed cards buys nothing. Live ones renumbered `S2-P*` when the sprint-independent column was removed — kind now lives in the ID, [[Planning Workflow — Artifact Gate]] → Task attributes.)*
- [x] **S2-T8** — Determinism + clamp tests · P1 · 🟢 Deep — **Jul 30** → PR #19
	  (`486fff6b`). `engine/app/tests/FrameLoopTests.cpp`, 12 cases. **No injected time
	  source** — the card was written expecting one, and T7 deleted the need by making
	  `advance()` pure. *(card title trimmed to match; outcome notes still yours to add)*
- [x] **S2-T11** — Skill `te-module` scaffolder · P3 · 🟡 Light — **cut Jul 30**, not relevant
	  enough to warrant a standalone task; module scaffolding happens alongside dev work.
- [x] **S2-T10** — Root `CONVENTIONS.md` (B4) · P2 · 🟠 Moderate — **Jul 30**. File opened
	  Jul 25 (B4 migrated in; B4 → pointer + history). CLAUDE.md shrunk to a pointer + 3
	  AI-default corrections. Three ⚠️ provisional rows **ratified**: `PascalCase` enum values,
	  `TechEngine::detail`, `g_camelCase`. Remaining *Open* rows decide when they first bite —
	  conventions evolve alongside dev work, not as dedicated tasks.
- [x] **S2-T9** — End-to-end wire-up = sprint demo · P2 · 🟠 Moderate — **done Jul 30**,
	  descoped. The sprint is horizontal utilities, not a vertical wire-up — the throwaway
	  `main.cpp` test runs *are* the demo; a separate wiring task had nothing to wire.
- [x] **S2-T5** — Assert → Logger integration + flush-on-fail · P2 · 🟠 Moderate — **Jul 30** → PR #17.
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
- [x] **S2-T15** — Reconciliation stamp on [[Dashboard]] (ADR-012 §6) · P2 · 🟡 Light —
	  **Jul 27** → PR #16. Closes the ADR-012 chain. Stamp seeded at **`2b4bc38e`
	  (2026-07-25)** — the last drift check that *actually* ran, **not** today's HEAD:
	  this session reconciled CLAUDE.md and the Operating Guide but never checked the
	  design notes against the code, and seeding it current would have been exactly the
	  formality §6 forbids. So it ships **already reading "behind"** — PRs #8–#15 land
	  after it, `base` is the exposed area — which is the mechanism working, not a defect.
	  Rule 2 gained the compare step; both ceremonies advance the stamp **only if the
	  drift check ran**. First real advance due at the **Aug 1–2** review.
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
- [x] **S2-T7** — `FrameContext` + fixed-timestep accumulator (headless) · P1 · 🟢 Deep —
	  **Jul 30** → PR #18. `FrameContext` lands in
	  **`core`** (ADR-006 §4; ADR-007 §6's `update(Scene&, const FrameContext&)` forces it) minus
	  the `const EngineContext&` member — no services exist to reference yet. `FrameLoop` in
	  `app`: clamp → accumulate → **`while`** drain → publish, `double` accumulator, `float` on
	  the context. **`FrameLoop` never sees the `Clock`** — sampling + the ADR-011 §9 stamp push
	  live in `App::run`, so [[Clock — Design]]'s seam question is answered by the seam not
	  existing (T8 feeds `advance()` a synthetic sequence; no fake clock, no virtual).
	  New calls: `Role { Client, ListenServer, DedicatedServer }` (no prior artifact — names off
	  ADR-006 §1's exe table) · `MAX_FRAME_DELTA_TIME = 0.25` (≤15 catch-up ticks) ·
	  `CONVENTIONS.md` → **spelled-out names** (`dt` was the trigger; read the ADRs' `dt` as
	  `deltaTime`). Rode along: `.clang-format` ColumnLimit 380→280 + no arg bin-packing,
	  reflowing `Assert.cpp`/`Log.cpp`.
	  **Measured:** naive `sleep_for` pacing is unusable on Windows — the 15.6 ms timer tick
	  rounds sub-tick sleeps **up**, so 120 frames sleeping 16.67 ms ran **221** ticks and
	  8.33 ms ran **111**, not 120/60. Now a spin-to-deadline stand-in, `TODO(S2-T9)` —
	  which outlived its card (T9 descoped), so real pacing is now an open question on
	  [[Game Loop — Frame Flow]]. Tests followed in T8 (PR #19).
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