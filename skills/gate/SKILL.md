---
name: gate
description: ADF stage H. Run the quality gates - unit tests, CRAP and changed-line coverage, mutation testing - then two post-merge reviewers. Use for /adf:gate #<n>, or /adf:gate --release before a release (every target framework).
---

# Gate (stage H)

Rules: `../../references/quality-gates.md`, `../../references/reading-test-results.md`.

The scripts are in `../../scripts/`. They need `.adf/profile.json` in the repository. Install the tools once: `../../scripts/install-tools.ps1`.

## 1. Run the gates

Development:

```powershell
& "<ADF>\scripts\adf-gate.ps1" -Repo <repo> -Base <base-sha>
```

Release:

```powershell
& "<ADF>\scripts\adf-gate.ps1" -Repo <repo> -Release
```

The script stops at the first failing gate. Run it in the background for long suites. Read the summary lines, not only the exit code.

## 2. Act on a failure

| Gate | Failure | Action |
|---|---|---|
| 1 | Failed tests | Dispatch `adf:test-triage` to classify. REGRESSION goes to an implementer. |
| 1 | Total below discovery count | Check for hung processes. Run again. |
| 2 | CRAP > 12, complexity > 12 | Implementer removes branches (table, polymorphism, state machine). |
| 2 | CRAP > 12, complexity ≤ 12 | Implementer adds tests that assert results. |
| 2 | Changed-line coverage < 90% | Implementer adds tests for the uncovered lines. |
| 2 | Type complexity did not go down | The method was split, not simplified. Send back. |
| 3 | Survivor on a changed line | Implementer adds a test that kills it, or marks an equivalent mutant with a reason. |
| 3 | Survivors per file went up (release) | Same, for the listed files. |

Run the gate again after each fix.

## 3. Post-merge review

After all gates pass, dispatch in parallel, in one message:

- `adf:correctness-reviewer`
- `adf:structure-reviewer` (give it the CRAP JSON path from the gate output)

When the two reviewers disagree, open the file on the integration branch and decide. Log the decision.

## Next

Continue with `/adf:integrate #<n>`.
