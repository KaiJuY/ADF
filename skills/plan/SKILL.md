---
name: plan
description: ADF stage B. Split an issue into units of work, find which units are independent, and plan one worktree per unit. Use for /adf:plan #<n> after the issue is written.
---

# Plan (stage B)

Rules: `../../references/flow.md`, `../../references/worktree-and-briefs.md`.

## Method

1. Read the issue and its acceptance criteria.
2. Find the code each criterion touches. Use `/adf:how` for unfamiliar areas.
3. List the units. A unit is the smallest change that ends in a state you can verify (it builds, and its tests pass).
4. For each unit, write its file scope and the units it depends on.
5. Group the units:
   - **Independent units** run in parallel, one implementer and one worktree each.
   - **A chain of dependent units** goes to one implementer, in order. Do not split a chain.
6. Check for shared facts between independent units: a public type that one unit changes and another unit uses or documents. Put those units in one chain, or order their merges.
7. Decide if the work is small enough to do in one unit.

## Output

```
#<n> plan
Units:
  U1 <name> | scope: <files> | depends on: - | AC: 1, 2
  U2 <name> | scope: <files> | depends on: U1 | AC: 3
Parallel groups: [U1 -> U2], [U3]
Worktrees: ../_wt_<name> from <base-sha>
Shared facts: <list, or none>
```

Wait for Allen to approve the split. Then log it and continue with `/adf:propose`.
