---
name: how
description: Explain how a part of the code works - runtime flow, architecture, data path, or where new code should live. Use for "how does X work", "walk me through X", "where should this go", or before changing an unfamiliar area.
---

# How

This is an explain request. Use the full explanation mode of the response style.

## Method

1. Find the entry points for X: public API, UI handler, timer, or message.
2. Follow the path from the entry point to the effect: calls, state changes, threads, external I/O. For a wide search, use the `Explore` subagent and keep only its conclusions.
3. Find who owns each piece of state, and who changes it.
4. Check one claim by running code or reading a test, when the claim is not obvious from the code.

## Output

1. **One-paragraph summary**: what X does and the main path.
2. **Flow**: numbered steps, each with `file:line`.
3. **State and ownership**: a table of state, owner, and writers.
4. **Edges**: errors, cancellation, threading, and hardware interaction.
5. **Placement** (when asked where code should go): the layer, the type, and the reason, with one rejected option.

Mark each statement as fact (with a `file:line`) or inference.

For "why is it built this way", use `/adf:why`.
