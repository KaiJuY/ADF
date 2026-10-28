---
name: integrate
description: ADF stage I. Drive the application the way a user does and check that behavior matches the issue - console harness, UI automation, or real hardware per the project profile. Use for /adf:integrate #<n>, or to build a project's integration driver.
---

# Integrate (stage I)

Rules: `../../references/live-hardware.md`. Read the "Integration" section of `.adf/profile.md`.

## 1. Pick the driver

| Application type | Driver |
|---|---|
| Console application | A harness that starts the process with a real console and sends keys. Do not pipe keys into stdin unless the profile says it works. |
| WPF application | FlaUI (`FlaUI.UIA3`) test project that starts the app, finds controls by `AutomationId`, and reads results from the UI. |
| Library with a protocol (ADS, TCP) | A client program that connects and runs the scenario. |
| Real machine | The owner runs it. Subagents never do. |

If the project has no driver yet, build one first (see section 4).

## 2. Write the scenario

For each acceptance criterion, write the steps a user takes and the result the user sees. Save it as `.adf/scenarios/<n>.md`.

## 3. Run

1. Run each scenario. Record the actual result next to the expected result.
2. For real hardware: read the resting state first. Prefer commands that the state refuses. Report each command.
3. Close every process and connection at the end. Check that no process from the run is still alive.

Stage I passes when every scenario matches. A mismatch goes back to stage F as a new unit.

## 4. Build a driver (once per project)

1. Find how a user starts and uses the application: README, launch settings, menus, windows.
2. Choose the driver from the table above.
3. Write the smallest driver that can run one scenario end to end. Put it in the project repository (for example `tests/<Name>.Integration/`).
4. Prove it: run one scenario, then break the behavior on purpose and show that the driver reports the failure.
5. Write the start command and the limits into the "Integration" section of `.adf/profile.md`.
