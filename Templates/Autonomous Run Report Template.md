# Auto Run — YYYY-MM-DD

<!-- File in docs/07 Journal/ as YYYY-MM-DD Auto Run.md.
Follow [[Autonomous Lane — Design]]. If nothing changed, no PR opened, and no useful
finding emerged, write no note. Keep the report readable after a working day. -->

## Needs you

State the action Miguel needs to take and why, or say no action is needed.
Link the PR or card. Include the relevant error when a run is blocked.

## What ran

- **Card:** <card ID and title, or the fallback check performed>
- **Outcome:** <PR opened, report only, or stopped with a reason>
- **PR:** <link and branch, if one exists>
- **CI:** <observed result, or still pending>
- **Local verification:** <preset, test result, or exact failure>

## What changed

Describe the useful outcome and link the affected artifact.
Omit this section when nothing changed. Do not list every file touched.

## Findings

Link relevant [[Backlog]] entries created during the run, with their priority and
trigger. Omit this section when there were no findings outside the card's work.

## Unverified

State what was not run or remains uncertain. Keep this section explicit.
Local execution in this lane does not verify Windows or the sanitizer legs;
report any observed CI evidence separately.

## Cost

State observed CI cost and estimated review time when available.
Label estimates and use [[Autonomous Lane — Design]] for the current cost model.
