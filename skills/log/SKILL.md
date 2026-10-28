---
name: log
description: Append a decision row to the issue's ADF decision log. Use after each decision in the flow, or when Allen says "log this".
---

# Log

Format: `../../references/decision-log.md`.

1. Find the issue number. Without one, ask.
2. Open `.adf/log/<issue>.tsv` in the repository. Create it with the header row if it does not exist:
   `time	stage	decision	why	evidence	result`
3. Append one row. Use the current time (`Get-Date -Format s`). Replace tabs and line breaks in the cell text with spaces.
4. Show the row that you added.

The log file is committed with the work.
