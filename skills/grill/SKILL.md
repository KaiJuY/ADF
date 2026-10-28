---
name: grill
description: ADF stage A intake. Use when the user writes #issue, #bug, or #feature, or asks to be grilled on a plan. Interviews the user in rounds until every decision is settled, tests the result with a fresh reviewer, then creates or updates the GitHub issue.
---

# Grill (stage A)

Rules: `../../references/issue-format.md`, `../../references/writing-standard.md`.

## 1. Map the decisions

Write down the decisions this request needs, as a tree. A decision can depend on other decisions.

Start the tree from these six questions. Drop a question only when the request already answers it.

1. **Problem**: What fails or is missing today? Who sees it?
2. **Current way**: How does the user work around it now? Why is that not enough?
3. **Consumer**: Which person, program, or machine uses the result?
4. **Hard limits**: Which constraints cannot change? Examples: target framework, offline operation, cycle time, a file format.
5. **Edges**: Which inputs and states are at the boundary? Which are out of scope?
6. **Success**: Which observable result shows that the work is done?

Then add the decisions of the solution: public API shape, which projects change, and how to verify.

## 2. Find facts yourself

A fact comes from the environment: code, git history, open issues, documents, the project profile. Find facts yourself. Use a subagent (`Explore`) for a wide search. Do not ask Allen for a fact you can look up.

Search for code that already does part of the work. Write each match as a fact, with `file:line`.

A decision belongs to Allen. Ask about decisions only.

## 3. Ask in rounds

A round contains every open decision whose prerequisites are settled. Do not ask a question that depends on another question in the same round. If a fact search is still running, ask the questions that do not depend on it.

Format each question:

```
❓ **Q<n> - <title>**: <question, with the choices if there are choices>

➡️ <your recommended answer>
```

Put `---` between questions. Write each question so that "yes" accepts your recommendation.

When Allen rejects a choice, record the choice and the reason. The issue keeps them in the section 考慮過的做法.

## 4. Repeat

After Allen answers, add the new decisions that the answers open. Ask the next round. Stop when no decision is open.

## 5. State the working summary

Write the result in three sentences or fewer: the problem, the chosen behavior, and the success result. Show it to Allen. If Allen corrects it, go back to step 3.

## 6. Concept check (feature and tech-debt only)

Skip this step for a bug with clear reproduction steps. Skip it when Allen says so. Write the reason in the decision log.

1. Write the issue draft to `.adf/drafts/<slug>.md`.
2. Dispatch two `adf:adversarial-reviewer` agents in parallel, in one message. Use the stage A angles: **need** (`model: "sonnet"`) and **fit** (`model: "haiku"`).
3. Give each reviewer: the ADF plugin path, the repository path, the draft path, and the angle. Do not give the chat history. Do not give your opinion of the draft.
4. Read the findings. A finding is a decision or a fact:
   - A fact: check it in the code. Correct the draft.
   - A decision: ask it in a new round (step 3).
5. Do not run the concept check a second time. Its job is to find gaps, not to approve the draft.

## 7. Confirm, then write the issue

1. Show the issue draft (title, label, body per `issue-format.md`).
2. Wait for Allen to confirm.
3. Write the body to a file in the scratchpad.
4. Create the issue: `gh issue create --title ... --label ... --body-file ...`. For an existing issue, use `gh issue edit <n> --body-file ...`.
5. Delete `.adf/drafts/<slug>.md`.
6. Report the issue number and URL.

Next stage: `/adf:plan #<n>`.
