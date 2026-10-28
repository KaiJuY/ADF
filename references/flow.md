# ADF flow (stages A to J)

The **owner** is the main agent that talks with Allen. The owner holds the whole picture. Every point where results meet goes back through the owner: merge, reviewer conflict, test failure triage, and code deletion. Subagents do the work. They do not make the decisions.

| Stage | Skill | Work | Exit condition | Who decides |
|---|---|---|---|---|
| A. Intake | `/adf:grill` | Clarify the request. Two fresh reviewers test the issue draft. Create or update the GitHub issue. | The issue has numbered acceptance criteria and the section 考慮過的做法. | Allen |
| B. Split | `/adf:plan` | Split the issue into units. Find which units are independent. Plan the worktrees. | Each unit has a file scope and a list of dependencies. | Owner, Allen approves |
| C. Proposal | `/adf:propose` | Write the proposal: types, signatures, modules, files, tests. Verify each claim about existing code. Compare the proposal with the issue. | Every claim about existing code has evidence. No design choice is left to the implementer. Each conflict with the issue has Allen's decision. | Owner. Allen decides a choice with two or more working answers. |
| D+E. Challenge | `/adf:challenge` | 3 to 5 reviewers attack the proposal. One reviewer reads the proposal without the issue. A judge sorts the findings. The owner resolves each finding. | Zero blocker and zero major findings. Every reviewer ran. | Judge, owner confirms. Allen decides each ESCALATE finding. |
| F. Build | `/adf:build` | Implementers work in their own worktrees. Light code review. Unit tests. | Unit tests pass and the test baseline is met. | Owner |
| G. Clean | `/adf:clean` | Remove dead code, duplicate logic, and comments that break the rules. Merge the worktrees. | The owner accepted each deletion. The merge has no conflict. | Owner |
| H. Gate | `/adf:gate` | Unit tests, then CRAP, then mutation testing. Two reviewers read the merged code. A drift reviewer compares the proposal with the merged code. | All three gates pass. Reviewer conflicts are resolved. Each drift difference has a decision. | Owner. Allen decides a public change that the proposal did not plan. |
| I. Integrate | `/adf:integrate` | Drive the application like a user. Use real hardware when the profile says so. | Behavior matches the expected behavior. | Owner |
| J. Close | `/adf:close` | Merge to the main branch. Close the issue. Write the decision log summary. | The issue is closed with a link to the merge commit. | Allen |

For a release, run `/adf:gate --release`. It runs every target framework.

## Rules that apply to every stage

1. **Independent units run in parallel. Dependent units run in one subagent, in order.** Do not split a chain of dependent steps.
2. **Every implementation runs in its own worktree.** See [worktree-and-briefs.md](worktree-and-briefs.md).
3. **Subagents do not touch real hardware.** They do not connect to a PLC, run a demo against a machine, or send commands. See [live-hardware.md](live-hardware.md).
4. **Subagents report in three groups:** VERIFIED, INFERRED, UNKNOWN.
5. **Subagents can use cheaper models** (sonnet, haiku). The owner chooses per task.
6. **Record each decision** in the decision log. See [decision-log.md](decision-log.md).
7. **A deletion proposal starts with its effect.** First say what happens if the deletion is not done (often: nothing changes in behavior). Then give the plan.

## Small changes

A change to one file with an obvious test can skip B, C, and D+E. It still goes through F, H, and J. The owner says in the decision log why the stages were skipped.
