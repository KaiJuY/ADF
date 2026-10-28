# Decision log

Each issue has one log file: `.adf/log/<issue>.tsv` in the project repository. Write one row per decision. Commit the log with the work.

## Columns

| Column | Content |
|---|---|
| time | ISO date and time |
| stage | A to J |
| decision | What was decided, in one sentence |
| why | The reason, in one sentence |
| evidence | Command output, file:line, or test total |
| result | What happened after the decision |

Separate columns with a tab. Do not put a tab or a line break inside a cell.

## What to log

- Each split, merge, and skipped stage.
- Each judge result in D+E.
- Each reviewer conflict and its resolution.
- Each failure classification.
- Each deletion that the owner accepted or rejected.
- Each hardware command.
