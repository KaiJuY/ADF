---
name: debt
description: Reduce one technical debt item from the ADF baseline - a method over CRAP 12 or a file with surviving mutants - using the CRAP rules. Use for /adf:debt, or "fix the worst CRAP method".
---

# Debt

Rules: `../../references/quality-gates.md`, `../../references/coding-rules.md`, `../../references/test-baseline.md`.

## 1. Pick the item

Without an argument, read `.adf/baseline/crap.json` and pick the method with the highest CRAP. Show the top five and recommend one. With an argument, use that method or file.

## 2. Open a tech-debt issue

Create an issue with the label `tech-debt` (`../../references/issue-format.md`). Acceptance criteria:

- Complexity > 12: "Complexity of `<method>` is 12 or less, and the total complexity of `<type>` goes down. Behavior does not change."
- Complexity ≤ 12: "CRAP of `<method>` is 12 or less. Each new test asserts a result."
- Both: "Surviving mutants in `<file>` do not go up."

## 3. Protect the behavior first

Before any change to the method, add characterization tests: tests that record what the method does today, through its public callers. Run them. They must pass before and after.

## 4. Change

- Complexity > 12: remove branches with a lookup table, polymorphism, or a state machine. Do not only split the method.
- Complexity ≤ 12: add tests that assert results.

Use the flow from stage F: one implementer in a worktree. A debt item is usually small; skip B, C, and D+E unless the shape changes.

## 5. Verify

Run `/adf:gate`. Then update the baseline with `/adf:scan`, so the item leaves the list.
