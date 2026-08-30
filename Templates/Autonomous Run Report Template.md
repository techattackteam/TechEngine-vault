# 🤖 Auto Run — YYYY-MM-DD

> Written by an unattended cloud routine ([[Autonomous Lane — Design]]). Filed in
> `docs/07 Journal/` as `<YYYY-MM-DD> Auto Run.md`.
>
> **Keep it triageable in two minutes.** It is read after a full work day. Delete any section
> that has nothing in it rather than writing "none" in five of them.

## ⚠️ Needs you

*The only section that is always read. One line per item, each one an action. Empty is a
perfectly good answer, and say so in one line if it is.*

- PR #NN is red on `<leg>`: `<the actual error>`. Not fixable inside the gate.
- Card `S5-XN` was mis-scoped: it needs `<a decision / Windows / a capture>`. Re-plan it attended.

## What ran

| | |
|---|---|
| **Card** | `S5-XN` — title, or *no Auto card open, ran a freshness check* |
| **Outcome** | shipped a PR · stopped, and why · report only |
| **PR** | #NN, branch `S5-XN/slug`, or *none* |
| **CI** | green · red on `<leg>` · **not settled**, next run picks it up |
| **Local build** | `linux-debug` green, `ctest` N/N · or the failure, verbatim |

## What changed

*One line per file or per decision. Link, do not restate. Nothing here means nothing changed,
and that is a normal result for a research or freshness run.*

## Findings

*Things noticed that are not this card's work. Each one is either a [[Backlog]] entry with a
`#prio` and a `Trigger:`, or it is noise and does not belong here. Say which entries were
added, and add them.*

## Unverified

*Explicit, always. What was assumed, what was not run, what the Linux-only build cannot prove.
Windows and the sanitizer legs are never exercised by this lane.*

## Cost

| | |
|---|---|
| **CI** | ~16.1 billed minutes if a PR was opened, 0 otherwise |
| **Review owed** | ~15 min, on a 🟡 day |
