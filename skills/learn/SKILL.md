---
name: learn
description: Turn a correction from Allen, or a repeated mistake, into a rule that holds - a check first, text last. Use for /adf:learn, or when Allen corrects the same thing a second time.
---

# Learn

## 1. State the mistake

Write one sentence: what went wrong, where, and what the correct behavior is. Quote Allen's exact words when there are any.

## 2. Choose the strongest place for the rule

Try each option in order. Stop at the first one that works.

| Order | Option | Example |
|---|---|---|
| 1 | Structure: make the mistake impossible | A type that cannot hold the bad value; one function that every caller must use |
| 2 | A script or analyzer check that fails with a message that names the fix | A gate rule in `scripts/`; a Roslyn analyzer rule |
| 3 | A test | A test that fails on the old mistake |
| 4 | A rule in ADF | A line in a file under `references/` (applies to all projects) |
| 5 | A rule in the project profile | A line under "Project traps" in `.adf/profile.md` |
| 6 | Claude memory | A fact about Allen or the environment that is not code |

## 3. Prove it

For options 1 to 3: show that the check fails on the old mistake and passes on the fix.

## 4. Report

Say where the rule now lives and how it is enforced. If the rule is in ADF, commit it in the ADF repository.
