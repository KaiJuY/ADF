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

## Resolving findings

After the judge, the owner gives each confirmed finding and each nit one result.

| Result | When | Action |
|---|---|---|
| **FIX** | The finding is correct. | Change the proposal. Write the change. |
| **REBUT** | The finding is false, and a file that the reviewer can read shows it. | Write the `file:line` or the proposal section. Add the finding to the settled list. |
| **ESCALATE** | The finding is false, but the proof is outside the repository: a decision of Allen, a fact about a machine, a customer agreement. | Do not change the proposal. Show the finding to Allen. Allen decides. |
| **SKIP** | The finding is a nit, and the change is not worth it. | Write it in the review file. Do not change the proposal. |

The owner wrote the proposal, so the owner wants to keep it. That wish proves nothing. Apply these rules:

1. A REBUT needs evidence that the reviewer can open. "This is intentional" is not evidence. Without that evidence, use FIX or ESCALATE.
2. Do not REBUT a comprehension finding. If a reader without the chat cannot follow the proposal, the proposal has a gap.
3. Add text to the proposal only when a human reader needs it. If only a reviewer without context needs it, use ESCALATE.
4. Do not change a severity. If you think the severity is wrong, use REBUT and give the reason.

## Finding format

```
[severity] <short title>
Where: <file:line or proposal section>
Claim: <what is wrong>
Evidence: <quoted line, command output, or "not verified">
Fix: <smallest change that removes the problem>
```
