---
name: close
description: ADF stage J. Merge the integration branch to the main branch, close the GitHub issue with the merge commit, remove worktrees, and finish the decision log. Use for /adf:close #<n> after stage I passes.
---

# Close (stage J)

Rules: `../../references/writing-standard.md` for the commit message and the issue comment.

## Steps

1. Show Allen: the issue, the stages that passed, the gate summary, and the merge plan. Wait for approval.
2. Check out the main branch. Run `git branch --show-current` to confirm.
3. `git merge --no-ff int/<n>` with a message: first line `合併 #<n>：<what changed>`. Body: how it was verified (gate result, integration result).
4. Check that the build passes on the main branch after the merge.
5. Close the issue: `gh issue close <n> --comment "<merge SHA>: <one-line summary>"`.
6. Remove the worktrees and branches of the issue: `git worktree remove ../_wt_<n>-<unit>` and `git branch -d impl/<n>-<unit>`. Keep `int/<n>` until Allen says to delete it.
7. Add the last log row. Commit `.adf/log/<n>.tsv` if it changed.
8. If the change affects a release, update the CRAP and mutation baselines: `/adf:scan`.

Do not push unless Allen asks.

## Report

```
#<n> closed. Merge: <sha>. Gates: 1 ✅ 2 ✅ 3 ✅. Integration: <n of n> scenarios.
Removed: <worktrees>. Kept: int/<n>.
```
