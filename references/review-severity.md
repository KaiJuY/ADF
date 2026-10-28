# Review severity

Every reviewer finding gets one severity.

| Severity | Meaning | Effect |
|---|---|---|
| **blocker** | The proposal or code is wrong. It breaks behavior, loses data, breaks a public contract, or cannot meet an acceptance criterion. | Stops the stage. |
| **major** | A gap that will cause rework: a missing case, a wrong layer, a test that cannot fail, a claim about existing code that is false. | Stops the stage. |
| **nit** | Naming, style, wording, or a preference with no effect on behavior. | Does not stop the stage. The owner can apply it. |

## Rules for the judge

1. Open the file for each blocker and each major finding. A reviewer is often right about where a problem is, and often wrong about how large it is.
2. Change the severity when the evidence shows a different size. Write the reason.
3. Reject a finding that is false. Write the evidence.
4. The stage passes when zero blocker and zero major findings remain.
5. If all findings are nits, the proposal is complete. Say so.

## Finding format

```
[severity] <short title>
Where: <file:line or proposal section>
Claim: <what is wrong>
Evidence: <quoted line, command output, or "not verified">
Fix: <smallest change that removes the problem>
```
