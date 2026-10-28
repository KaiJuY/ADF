---
name: challenge
description: ADF stages D and E. Run 2 to 4 adversarial reviewers on a proposal with cheaper models, then a judge decides if only nits remain. Use for /adf:challenge #<n>, or "stress test this proposal".
---

# Challenge (stages D and E)

Rules: `../../references/review-severity.md`.

## D: adversarial review

1. Pick 2 to 4 angles from the `adf:adversarial-reviewer` definition. Always include **existing-code**. Add **operations** when the change touches hardware, timing, or release.
2. Dispatch one `adf:adversarial-reviewer` per angle, in parallel, in one message. Use `model: "haiku"` for **simplicity** and **tests**. Use `model: "sonnet"` for **correctness**, **existing-code**, and **operations**.
3. Each brief contains: the ADF plugin path, the repository path, the issue text, the proposal file path, and the angle. Do not add your own opinion of the proposal.

## E: judge

1. Dispatch one `adf:proposal-judge` with the proposal and all findings.
2. Read the verdict. Open the evidence of each confirmed blocker and major yourself.

## Result

- **READY**: log it. Continue with `/adf:build`.
- **NOT READY**: change the proposal for each confirmed finding. Run the challenge again with the angles that had findings.
- **NOT READY a second time**: stop and show Allen the open findings. The decision is Allen's.

Show a short table: angle, model, findings by severity, judge result.
