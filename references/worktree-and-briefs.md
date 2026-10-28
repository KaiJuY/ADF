# Worktrees and briefs

## Create worktrees yourself

Do not use the Agent tool's `isolation: "worktree"` option. It has created worktrees from an old commit, and it deletes a worktree that has no changes.

The owner creates each worktree:

```sh
git worktree add -b impl/<name> "../_wt_<name>" <base-sha>
git -C "../_wt_<name>" rev-parse HEAD
```

The worktree is a sibling of the repository (`../_wt_*`).

## Step 0 of every brief

Every implementer brief starts with these lines:

1. "You do not work in the default directory. Your worktree is `<absolute path>`. Use this path in every shell call, because the shell does not keep the directory between calls."
2. "Run `git merge-base --is-ancestor <base-sha> HEAD`. If it fails, stop and report BASE_STALE."
3. "Confirm that `<file that exists only on the correct base>` exists."

## Before each merge, the owner checks

1. `git merge-base --is-ancestor <base> <agent-branch>` for each branch.
2. `git branch --show-current` in the worktree that receives the merge.
3. The test count of the agent's run against the known count. A different count can mean a wrong base.

## Follow-up rounds

- Rebase a follow-up round onto the current tip of the integration branch. Do not use the merge of its own last round. Write the tip SHA in the brief.
- Name the other units that merged since the unit's base, and the directories they changed. The agent cannot know which files it can no longer trust.
- Units with separate files can still share facts. Before you merge a unit that makes public surface smaller, search the documents for text that describes that surface.

## Writing a brief

1. **Open every source before you cite it.** Each `file:line`, each number, and each quoted sentence in a brief must come from a file you opened while writing the brief. Do not copy a number from another agent's report.
2. **Quote. Do not paraphrase.** Paste the exact line from the source.
3. **Label relayed content.** If you pass on something you did not verify, write "UNVERIFIED, check this".
4. **Ask for corrections.** Add: "Report every error in this brief. Do not soften it."
5. **An audit finds locations well and sizes badly.** Keep the audit's pointers. Measure its numbers again.
6. **Settle disagreements with the file.** When an agent and the owner disagree, open the file on the integration branch. Seniority does not decide.

## What a brief contains

- Step 0 (above).
- Goal, in one sentence, with the issue number.
- Scope: the files the unit owns. Files outside the scope are read-only.
- Inputs: quoted lines and verified numbers.
- Rules: [coding-rules.md](coding-rules.md), [test-baseline.md](test-baseline.md), and the project profile.
- Limits: no hardware, no edits to the plan's progress table.
- Report format: VERIFIED, INFERRED, UNKNOWN, the test command, and the test total.
