# Unit test baseline

The implementer writes these tests during stage F, together with the code. They are the entry ticket for stage H. CRAP and mutation testing in stage H are acceptance checks. They do not replace this baseline.

## Four rules for each changed method

| # | Rule | How to measure |
|---|---|---|
| 1 | Each acceptance criterion in the issue has at least one test. | Put the criterion number in the test: `[Trait("AC", "3")]`. The code reviewer compares `git grep 'Trait("AC"'` with the issue's list. |
| 2 | The number of tests for a method is at least its cyclomatic complexity. | A method with complexity N has N independent paths (McCabe basis paths). Each path needs a test. The limit is 12, so a method needs 12 tests at most. |
| 3 | Each numeric or collection input has boundary tests: empty, one item, minimum, maximum, out of range. | The code reviewer checks this. |
| 4 | A bug fix starts with a test that fails. Then the fix makes it pass. | The report includes the failing output from before the fix. |

## Changed-line coverage

At least 90% of the changed lines must run during the tests. The script `scripts/crap.ps1` (gate 2) measures this from the coverage report and `git diff`.

Reference: the Google Testing Blog (2020) calls 60% acceptable, 75% commendable, and 90% exemplary. ADF applies 90% to changed lines only, not to the whole project.

## Each test asserts a result

A test must assert a result that a caller can see: a return value, a state change, an event, or an exception. A test that only runs code without an assertion does not count. A test that asserts internal details (private fields, call order of private methods) is not allowed.

Test names describe the behavior. Example: `Load_returns_failure_when_file_is_missing`.
