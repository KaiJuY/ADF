---
name: grill
description: ADF stage A intake. Use when the user writes #issue, #bug, or #feature, or asks to be grilled on a plan. Interviews the user in rounds until every decision is settled, then creates or updates the GitHub issue.
---

# Grill (stage A)

Rules: `../../references/issue-format.md`, `../../references/writing-standard.md`.

## 1. Map the decisions

Write down the decisions this request needs, as a tree: a decision can depend on other decisions. Examples: scope, behavior at the edges, public API shape, which projects change, how to verify.

## 2. Find facts yourself

A fact comes from the environment: code, git history, open issues, documents, the project profile. Find facts yourself. Use a subagent (`Explore`) for a wide search. Do not ask Allen for a fact you can look up.

A decision belongs to Allen. Ask about decisions only.

## 3. Ask in rounds

A round contains every open decision whose prerequisites are settled. Do not ask a question that depends on another question in the same round. If a fact search is still running, ask the questions that do not depend on it.

Format each question:

```
❓ **Q<n> - <title>**: <question, with the choices if there are choices>

➡️ <your recommended answer>
```

Put `---` between questions. Write each question so that "yes" accepts your recommendation.

## 4. Repeat

After Allen answers, add the new decisions that the answers open. Ask the next round. Stop when no decision is open.

## 5. Confirm, then write the issue

1. Show the issue draft (title, label, body per `issue-format.md`).
2. Wait for Allen to confirm.
3. Write the body to a file in the scratchpad.
4. Create the issue: `gh issue create --title ... --label ... --body-file ...`. For an existing issue, use `gh issue edit <n> --body-file ...`.
5. Report the issue number and URL.

Next stage: `/adf:plan #<n>`.
