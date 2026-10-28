# Writing standard

ADF writing follows the ideas of ASD-STE100 (Simplified Technical English). ADF uses the ideas, not the full specification.

Apply this standard to: skill files, project documents, issues, commit messages, and PR descriptions.

## Rules for all languages

1. **One sentence, one item.** A sentence gives one instruction or one fact.
2. **Active voice.** Name who does the action. "The gate reads the report." Not "The report is read."
3. **Commands for instructions.** Start an instruction with the verb. "Run the gate."
4. **One word, one meaning.** Each project keeps a controlled term list (see the project profile). Use only the listed term for a concept. Do not use synonyms for variety.
5. **Condition before action.** Put the warning or the condition before the step it applies to. "If the PLC is in Execute, stop the Service first."
6. **Literal words.** Do not use idioms or figures of speech.
7. **Specific statements.** Write "a column rename breaks the build". Do not write "changes can cause issues".
8. **No slashes between words.** Write "a, b, or both".

## English only

- Procedure sentences: 20 words or fewer.
- Description sentences: 25 words or fewer.
- Use articles ("the", "a") where English needs them.

## Chinese

Apply rules 1 to 8. Do not count characters. Keep sentences short.

## Document types

Keep each document to one type. Do not mix types in one document.

| Type | Purpose | Content |
|---|---|---|
| Tutorial | Teach by doing | Steps with a visible result after each step |
| How-to | Reach one goal | Steps only, no background |
| Reference | Look up facts | Tables and exact values, no argument |
| Explanation | Understand why | Trade-offs and a stated position |

## Commit messages and PR descriptions

- First line: what changed, in the project's language (Traditional Chinese for Allen's projects).
- Body: why, and how it was verified. A reviewer reads it in one minute.
- Link logs and tables. Do not paste them.
- Add `#<issue>` when the work closes an issue.
