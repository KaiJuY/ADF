---
name: build
description: ADF stage F. Create one worktree per unit, dispatch implementers in parallel, run a light code review and unit tests per worktree. Use for /adf:build #<n> after the proposal is READY.
---

# Build (stage F)

Rules: `../../references/worktree-and-briefs.md`, `../../references/test-baseline.md`.

## 1. Create the worktrees

For each parallel group from the plan:

```sh
git worktree add -b impl/<n>-<unit> "../_wt_<n>-<unit>" <base-sha>
git -C "../_wt_<n>-<unit>" rev-parse HEAD
```

Do not use the Agent tool's `isolation` option.

## 2. Write the briefs

Follow "Writing a brief" in `worktree-and-briefs.md`. Open every file you cite while you write the brief. Include:

- Step 0 (worktree path, base check, marker file).
- The ADF plugin path, so the implementer can read the rules.
- The unit's part of the proposal, quoted from `.adf/proposals/<n>.md`.
- The test command and the expected test count.

## 3. Dispatch

Dispatch one `adf:implementer` per group, in parallel, in one message. Do not pass `isolation`.

## 4. Check each result

When an implementer returns:

1. Read its "Brief errors" section. Correct the plan if a brief was wrong.
2. Check the base yourself: `git merge-base --is-ancestor <base-sha> impl/<n>-<unit>`.
3. Dispatch `adf:code-reviewer` on the worktree.
4. Run the unit tests in the worktree for the main framework. Check the total.
5. Check for hung `testhost` processes after each round.

A unit is done when the reviewer says `MERGE: yes` and the tests pass with the expected total.

## Next

Continue with `/adf:clean #<n>`.
