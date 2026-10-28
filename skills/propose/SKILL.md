---
name: propose
description: ADF stage C. Write the change proposal - types, signatures, module structure, file list, and the test list - verify every claim it makes about existing code, and check it against the issue. Use for /adf:propose #<n>, or before implementing a non-trivial change.
---

# Propose (stage C)

Write the shape of the change before any code. Save the proposal as `.adf/proposals/<n>.md` in the repository.

## Proposal sections

1. **Goal**: the issue number and one sentence.
2. **Shape**: new and changed types, public signatures, and the module or layer of each. Use code blocks with signatures only, no bodies.
3. **Data and state**: what state exists, who owns it, who changes it, and which threads touch it.
4. **Behavior**: for each acceptance criterion, the path through the new shape.
5. **Files**: each file that the change creates, modifies, or deletes. One line per file: the mark (Create, Modify, or Delete), the path, and the reason.
6. **Tests**: the test list per acceptance criterion, with the boundary cases. Follow `../../references/test-baseline.md`.
7. **Claims about existing code**: every statement the proposal depends on, such as "X already handles Y" or "nothing else calls Z".
8. **Alternatives**: each choice that was rejected, and why. Copy the choices from the issue section 考慮過的做法. Add the choices that you rejected while you wrote the proposal.
9. **Out of scope**: what the change does not do.
10. **Risks**: what could break outside the diff.

Write the proposal for a reader who did not see the chat. Define each term that is specific to the project, or link the file that defines it. A reviewer in stage D reads the proposal with no other context.

## Leave no design choice to the implementer

Read sections 2 to 6 as the implementer. Find each place where the implementer must choose: a signature, an error behavior, a data shape, a dependency, an edge case. Decide each one in the proposal.

If a choice has one correct answer, decide it yourself.

If a choice has two or more answers that each work, ask Allen. Give two or three options. For each option, give how it works, its cost, and when it fails. Put your recommendation first. Write Allen's answer in the proposal and in the decision log.

## Verify the claims

For each claim in section 7, prove it now:

- Run real code when you can: a test, a small script, or a build.
- Otherwise, quote the lines (`file:line`) that prove it.
- Search for every caller of a changed signature (`git grep`), including reflection, XAML bindings, and documents.

Mark each claim VERIFIED (with evidence) or FALSE. A FALSE claim changes the proposal before review.

## Check the proposal against the issue

Only the owner can do this check. The stage D reviewers do not read the chat, and the comprehension reviewer does not read the issue.

Read the issue again. Compare it with the proposal:

- **Conflict**: the issue settled a decision, and the proposal decides it in a different way.
- **New decision**: the proposal makes a decision that the issue did not raise. Report it only if it changes a public interface, the architecture, or a dependency.

List each conflict on one line: the issue text, then the proposal text. Ask Allen to decide each conflict. Do not change the proposal to match the issue without Allen: the proposal can be right, because you read code that the grill session did not read. If Allen changes a decision of the issue, update the issue.

If there is no conflict and no new decision, say so in one line.

## Next

Continue with `/adf:challenge #<n>`.
