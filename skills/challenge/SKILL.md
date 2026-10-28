---
name: challenge
description: ADF stages D and E. Run 3 to 5 adversarial reviewers on a proposal with cheaper models, then a judge decides if only nits remain, then the owner resolves each finding. Use for /adf:challenge #<n>, or "stress test this proposal".
---

# Challenge (stages D and E)

Rules: `../../references/review-severity.md`.

## D: adversarial review

1. Pick 3 to 5 angles from the stage D angles in the `adf:adversarial-reviewer` definition. Always include **existing-code** and **comprehension**. Add **readiness** when the plan has two or more units. Add **operations** when the change touches hardware, timing, or release.
2. Dispatch one `adf:adversarial-reviewer` per angle, in parallel, in one message. Use `model: "haiku"` for **simplicity**, **tests**, and **comprehension**. Use `model: "sonnet"` for **correctness**, **existing-code**, **readiness**, and **operations**.
3. Each brief contains: the ADF plugin path, the repository path, the proposal file path, and the angle. Add the issue text for every angle except **comprehension**. Do not add your own opinion of the proposal.
4. If a reviewer fails, times out, or returns no report, dispatch it again one time. If it fails again, its status is "not run". A reviewer that did not run did not find zero problems.

## Read the comprehension result

Compare the two paraphrase sections with the issue. Each difference is a finding against the proposal. Add it to the findings for the judge, with the severity major.

## E: judge

1. Dispatch one `adf:proposal-judge` with: the issue, the proposal, all findings, the status of each reviewer, and the settled list from earlier rounds.
2. Read the verdict. Open the evidence of each confirmed blocker and major yourself.

## Resolve the findings

Sort each confirmed finding and each nit with the rules in "Resolving findings" in `review-severity.md`. Write the result to `.adf/proposals/<n>.review.md`: one line per finding, with its result and its evidence.

1. Show Allen each ESCALATE finding first. Allen decides each one.
2. Apply each FIX to the proposal.
3. Log each REBUT and each ESCALATE decision.

## Result

- **READY**: the judge returned READY, and no reviewer has the status "not run". Log it. Continue with `/adf:build`.
- **NOT READY**: apply the fixes. Run the challenge again with the angles that had findings, and with each angle that did not run. Give the judge the settled list.
- **NOT READY a second time**: stop and show Allen the open findings. The decision is Allen's.

## Settled list

A finding is settled when the owner rebutted it with evidence, or when Allen accepted it as a risk. Keep the settled list in `.adf/proposals/<n>.review.md`. The judge rejects a settled finding that a reviewer raises again.

A finding with the result FIX does not go on the settled list. If a reviewer raises the same finding at the same location again, the fix did not work. Open the finding again.

If a new finding is at the location of a fix, and the finding goes away when you undo that fix, the two findings pull in opposite directions. Stop and show Allen both findings.

Show a short table: angle, model, status, findings by severity, judge result.
