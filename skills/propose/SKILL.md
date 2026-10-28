---
name: propose
description: ADF stage C. Write the change proposal - types, signatures, module structure, and the test list - and verify every claim it makes about existing code. Use for /adf:propose #<n>, or before implementing a non-trivial change.
---

# Propose (stage C)

Write the shape of the change before any code. Save the proposal as `.adf/proposals/<n>.md` in the repository.

## Proposal sections

1. **Goal**: the issue number and one sentence.
2. **Shape**: new and changed types, public signatures, and the module or layer of each. Use code blocks with signatures only, no bodies.
3. **Data and state**: what state exists, who owns it, who changes it, and which threads touch it.
4. **Behavior**: for each acceptance criterion, the path through the new shape.
5. **Tests**: the test list per acceptance criterion, with the boundary cases. Follow `../../references/test-baseline.md`.
6. **Claims about existing code**: every statement the proposal depends on, such as "X already handles Y" or "nothing else calls Z".
7. **Out of scope**: what the change does not do.
8. **Risks**: what could break outside the diff.

## Verify the claims

For each claim in section 6, prove it now:

- Run real code when you can: a test, a small script, or a build.
- Otherwise, quote the lines (`file:line`) that prove it.
- Search for every caller of a changed signature (`git grep`), including reflection, XAML bindings, and documents.

Mark each claim VERIFIED (with evidence) or FALSE. A FALSE claim changes the proposal before review.

## Next

Continue with `/adf:challenge #<n>`.
