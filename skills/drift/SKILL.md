---
name: drift
description: Compare proposals with the code and list the differences. For one issue, it compares the proposal with the merged diff (stage H). Without an issue, it checks every proposal in .adf/proposals/ against the current code. Use for /adf:drift, /adf:drift #<n>, or "does the code still match the proposals".
---

# Drift

A proposal in `.adf/proposals/` is a project document. It must describe the code that was merged. Later readers trust it.

## One issue (`/adf:drift #<n>`)

Stage H runs this step. You can also run it alone.

1. Find the base SHA and the integration branch `int/<n>` in the decision log.
2. Dispatch one `adf:drift-reviewer` in issue mode. Give it: `.adf/proposals/<n>.md`, the repository path, the ADF plugin path, the base SHA, and `int/<n>`.
3. Open the evidence of each difference yourself.
4. Decide each difference:
   - The code is wrong: send it to an implementer, the same as a gate failure. Run `/adf:gate` again after the fix.
   - The proposal is out of date, and the code is right: update the proposal. Write the reason in the decision log.
   - The change is not planned and changes a public member: show it to Allen. Allen decides if it stays.
5. The step passes when each difference has a decision.

## All proposals (`/adf:drift`)

Run this after a release, or when Allen asks.

1. List the files in `.adf/proposals/` that do not end in `.review.md`.
2. Dispatch one `adf:drift-reviewer` in current mode for each proposal. Dispatch at most four at the same time.
3. Write the results to `.adf/out/drift-<YYYY-MM-DD>.md`: one section per proposal, differences only.
4. Do not change code or proposals in this step. Report to Allen:
   - The number of proposals that you checked, and the number with drift.
   - The five proposals with the most differences.
   - For each one, a proposed action: update the proposal, open a bug issue, or mark the proposal as replaced.

A proposal that a later issue replaced gets one line at the top: `Replaced by #<m>.` The reviewer skips a replaced proposal.
