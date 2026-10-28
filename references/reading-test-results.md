# Reading test results

A test result is evidence only after these checks.

## 1. Know the expected count first

Get the count before the run:

```sh
dotnet test <project> -c Debug -f <tfm> --list-tests --nologo | grep -c "^    "
```

A run total is normally equal to or larger than this count, because each `[Theory]` case counts as one test in a run. **A run total below the discovery count means the run was cut off.** A green run with a low total is not a pass.

## 2. Check for processes that block or slow the run

Before a measurement, list the processes that use CPU:

```powershell
Get-Process python,dotnet,testhost -ErrorAction SilentlyContinue | ForEach-Object { '{0} {1} {2:N1} {3}' -f $_.Id,$_.ProcessName,$_.CPU,$_.StartTime }
```

- A `testhost` with an old start time and almost no CPU is hung. It can lock build output (`MSB3027`). Stop it, then run again. Discard the total of the run that was stopped.
- A process with high CPU and an empty output file is stuck in a loop. Stop it.
- Check this after each round of parallel agents.

## 3. Classify a failure

Do not dismiss a failure without one of these checks:

| Check | How | Result |
|---|---|---|
| Control run | `git worktree add --detach ../_wt_base <base-sha>`. Run the same target there. | Same failures on the base: the failure existed before. |
| Two-run overlap | Run the suite two times. | A real defect fails the same test each time. A load-dependent failure changes from run to run. Only the overlap counts. |
| Single rerun | Run the named test alone. | Weakest check. Some tests fail only when run alone. |

The project profile lists known load-dependent tests.

## 4. Report

Report: the command, the target framework, the total, the failed tests by name, and the classification of each failure. The exit code alone is not a result.
