---
name: write
description: Write or review a document, issue, commit message, or PR description to the ADF writing standard (ASD-STE100 ideas). Use for /adf:write, "review this doc", or any project document.
---

# Write

Rules: `../../references/writing-standard.md`. Use the project's controlled terms from `.adf/profile.md`.

## Writing a new document

1. Choose one document type: tutorial, how-to, reference, or explanation.
2. Write the outline as headings. Each heading is one task or one topic.
3. Write each section. One sentence, one item. Active voice. Commands for instructions.
4. Put conditions and warnings before the step.
5. Check every term against the controlled term list.

## Reviewing a document

Report each problem as:

```
<location> | <rule number> | <current text> -> <proposed text>
```

Group the report: terms, sentence rules, structure. Show at most five items per group first, then the count of the rest.

## Checks you can run

- Terms: search the document for each "Do not use" term in the profile.
- Long sentences (English): split on `. ` and count words; flag procedure sentences over 20 words and description sentences over 25 words.
- Chinese text: check for characters from simplified Chinese or Japanese forms when the document is in Traditional Chinese.
