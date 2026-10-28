---
name: why
description: Find the reason behind a design, a value, or a behavior - from git history, issues, plans, reports, and memory. Use for "why does X work this way", "why did we pick Y", regressions, and postmortems.
---

# Why

This is an explain request. Use the full explanation mode of the response style.

## Sources, in order

1. `git log -S'<symbol>'` and `git log -L` on the lines: the commit that introduced it, and its message.
2. `git blame` on the current lines, then the commits that changed them.
3. GitHub issues and PRs: `gh issue list --search`, `gh pr list --search --state all`.
4. Project documents: plans, design notes, reports, contracts (the profile names their folders).
5. Decision logs: `.adf/log/*.tsv`.
6. Claude memory for this project.

Search the sources in parallel when they do not depend on each other.

## Output

1. **Answer** in one or two sentences.
2. **Evidence**: each reason with its source (commit SHA, issue number, document path and section).
3. **Status**: does the reason still hold today? Check the current code.
4. **Gaps**: what no source explains. Say "no record found". Do not guess a reason.
