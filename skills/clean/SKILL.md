---
name: clean
description: ADF stage G. Merge the finished worktrees into the integration branch, then remove dead code, duplicate logic, and comments that break the ADF comment rules. Use for /adf:clean #<n>, or to clean comments in any diff.
---

# Clean (stage G)

Rules: `../../references/comment-rules.md`, `../../references/coding-rules.md`.

## 1. Merge

1. Create or check out the integration branch `int/<n>`. Run `git branch --show-current` to confirm.
2. For each unit branch: check the base (`git merge-base --is-ancestor`), then `git merge --no-ff impl/<n>-<unit>`.
3. On a conflict: stop, read both sides, and resolve it yourself. Log the resolution.
4. Build the solution after all merges.

## 2. Review

Dispatch in parallel, in one message:

- `adf:cleanup-reviewer` on `git diff <base>...int/<n>`.
- `adf:comment-reviewer` on the same diff.

## 3. Decide

For each finding:

- Read the evidence. Accept or reject it. Log each decision.
- A deletion of public API needs Allen's approval.
- A deletion proposal starts with its effect if not done. If the effect is "nothing changes in behavior", say so to Allen in that form.

## 4. Apply

Dispatch one `adf:implementer` on the integration branch with the accepted list. It applies the deletions, reshapes, and encodings. Run the unit tests after it returns.

## Without an issue

`/adf:clean` on a plain diff runs steps 2 to 4 only.

## Next

Continue with `/adf:gate #<n>`.
