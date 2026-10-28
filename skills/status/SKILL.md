---
name: status
description: Show where the current issue is in the ADF flow (stages A to J), what passed, and what is next. Use for /adf:status or "where are we".
---

# Status

1. Find the active issue: the argument, or the issue in the current branch name, or the newest `.adf/log/*.tsv`.
2. Read its decision log.
3. Check the live state: branches and worktrees for the issue, the last gate output in `.adf/out/`, and the issue state on GitHub.

## Output

```
#<n> <title>
A ✅  B ✅  C ✅  D+E ✅  F 🔄 (2 of 3 units merged)  G ⬜  H ⬜  I ⬜  J ⬜
Last decision: <row from the log>
Next: <one action>
```

Use ✅ done, 🔄 in progress, ⬜ not started, ⏭ skipped (with the reason from the log), ❌ failed.
