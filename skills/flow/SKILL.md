---
name: flow
description: Run the whole ADF flow (stages A to J) for one issue, stopping at each decision that belongs to Allen. Use for /adf:flow #<n>, or when Allen asks to take an issue from start to finish.
---

# Flow

You are the owner. Read `../../references/flow.md` first. It defines the stages, exit conditions, and who decides.

## Start

1. Find the issue. With `#<n>`, read it: `gh issue view <n>`. Without an issue, run `/adf:grill` first.
2. Read the project profile `.adf/profile.md`. If it does not exist, run `/adf:scan` first.
3. Run `/adf:status #<n>` to find the current stage. Continue from there.

## Run the stages in order

| Stage | Skill | Stop for Allen |
|---|---|---|
| A | `/adf:grill` | Each round of questions. Issue draft. |
| B | `/adf:plan` | Approve the split. |
| C | `/adf:propose` | No |
| D+E | `/adf:challenge` | Only if the judge returns NOT READY twice. |
| F | `/adf:build` | No |
| G | `/adf:clean` | Approve deletions of public API. |
| H | `/adf:gate` | No, unless a failure is classified UNKNOWN. |
| I | `/adf:integrate` | Before each hardware command that the profile does not authorize. |
| J | `/adf:close` | Approve the merge to the main branch. |

## After each stage

1. Check the exit condition in `flow.md`. If it is not met, stay in the stage.
2. Write a decision log row (`/adf:log`).
3. Show the position: "Stage <x> done: <result>. Next: <stage>."

## Skipping stages

For a small change (one file, obvious test), skip B, C, and D+E. Write the reason in the log.
