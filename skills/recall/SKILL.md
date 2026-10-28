---
name: recall
description: Rebuild the current working state of a project before starting or resuming work - open issues, branches, worktrees, decision logs, and memory. Use for "where did I leave off", "catch me up", or at the start of a session.
---

# Recall

Collect these in parallel:

1. `git status`, `git branch --show-current`, `git log --oneline -15`.
2. `git worktree list`. Name each worktree and its branch.
3. `gh issue list --state open`. Mark issues whose work is already merged but still open.
4. The newest files in `.adf/log/`. Read the last rows.
5. Claude memory for this project: the index and the entries that match open work.
6. Processes that can block work: hung `testhost`, background shells, open Word documents.

## Output

1. **Now**: the active issue, its stage (A to J), and the last decision.
2. **Waiting on Allen**: each decision that is open, with what is needed to decide it.
3. **Loose ends**: stale worktrees, merged-but-open issues, hung processes.
4. **Next action**: one command or skill.

Do not report that something was never recorded until you have checked all six sources.
