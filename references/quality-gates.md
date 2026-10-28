# Quality gates (stage H)

Run the gates in this order. Stop at the first gate that fails.

1. Unit tests
2. CRAP
3. Mutation testing

The script `scripts/adf-gate.ps1` runs all three. Each gate also has its own script.

## Tools

| Tool | Version | Source | Use |
|---|---|---|---|
| coverlet.collector | as in the test project | github.com/coverlet-coverage/coverlet | Coverage in Cobertura format, with cyclomatic complexity per method |
| ReportGenerator (`dotnet-reportgenerator-globaltool`) | 5.5.12 | github.com/danielpalme/ReportGenerator | HTML report and risk hotspots for people |
| Stryker.NET (`dotnet-stryker`) | 4.16.0 (5.0.0 needs the .NET 10 SDK) | github.com/stryker-mutator/stryker-net | Mutation testing |
| FlaUI (`FlaUI.UIA3`) | 5.0.0 | github.com/FlaUI/FlaUI | UI automation for WPF in stage I |

`scripts/install-tools.ps1` installs ReportGenerator and Stryker.NET into `%USERPROFILE%\.adf\tools` (or `$env:ADF_TOOLS`). The folder is outside the plugin, so a plugin update keeps the tools. ADF does not install global tools. A test project needs the `coverlet.collector` package. `/adf:scan` reports the projects that do not have it.

## Gate 1: unit tests

- Read the test total, not only pass or fail. A total below the expected count is a cut-off run. See [reading-test-results.md](reading-test-results.md).
- Run each target framework on its own, one after the other.

## Gate 2: CRAP

CRAP = c² × (1 − cov)³ + c

c is the cyclomatic complexity of a method. cov is the line coverage of the method, from 0 to 1.

**Trigger:** CRAP > 12 on a changed method. When cov = 1, CRAP = c. So the trigger and the complexity split use the same number, 12.

**Action after the trigger:**

| Complexity | Action |
|---|---|
| > 12 | Remove branches: lookup table, polymorphism, or state machine. Splitting the method does not count. The total complexity of the changed type must go down. |
| ≤ 12 | Add tests until CRAP ≤ 12. Each test asserts a result. See [test-baseline.md](test-baseline.md). |

After the fix, run gate 3. The number of surviving mutants must not go up.

**Scope.** In development, the gate checks changed methods only. `/adf:scan` records the whole project as a baseline. `/adf:debt` reduces the baseline one item at a time.

## Gate 3: mutation testing

| Code | Rule |
|---|---|
| New or changed code | Zero surviving mutants. |
| Existing code | The number of surviving mutants per file does not go up, compared with the baseline. |

**Equivalent mutants.** Some mutants do not change behavior. No test can kill them. Mark them with a Stryker disable comment and a reason:

```csharp
// Stryker disable once Equality: the loop bound is equal for < and <= because the last item is a sentinel
```

The comment reviewer accepts this comment under comment type 5.

**Modes.**

| Mode | When | Stryker options |
|---|---|---|
| Development | Stage H of a normal change | `--since:<base>` on the main target framework. Mutates changed files only. |
| Release | `/adf:gate --release` | Full run on each target framework. The script compares the survivors per file with `.adf/baseline/mutation.json`. |

Stryker's `since` and `with-baseline` options cannot be used together. ADF keeps its own baseline file, so it does not use `with-baseline`.

**Unstable results.** A mutant in a static initializer can be Killed in one run and Survived in the next, because the initializer runs once per test process. Stryker marks these mutants `"static": true`. ADF handles this in two ways:

1. The release count leaves static mutants out. `survivors.json` still lists them for review.
2. Every gate 3 failure is checked by a second run on the failing files. Only findings in both runs count.

Measured on Polar300x_WPF (2026-10-28): three runs on the same code gave different static survivors in `Machine.cs` lines 21 to 24.

**Reference values.** Stryker's default thresholds are high 80, low 60, break 0. Google (2018) does not use a score. It shows surviving mutants on changed lines during code review and skips lines with no test value, such as logging. ADF follows the Google idea: zero survivors on changed code, with reasons for equivalent mutants.

## Release

A release runs all three gates on every target framework in the project profile. A release is blocked if one framework fails.

## Reviewers after the merge

Two reviewers read the merged code, one per angle:

- `adf:correctness-reviewer`: defects, breaking changes, security, concurrency.
- `adf:structure-reviewer`: duplicate logic, file size, branch-heavy code, layering.

When the two reviewers disagree, the owner opens the file on the integration branch and decides.
