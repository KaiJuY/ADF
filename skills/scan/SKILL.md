---
name: scan
description: Set up ADF in a repository and record its technical debt baseline - project profile, CRAP for every method, surviving mutants per file, test inventory. Use for /adf:scan, the first time ADF runs in a project, or after a release.
---

# Scan

## 1. Profile (first time only)

If `.adf/profile.json` does not exist:

1. Find the solution, the test projects, the source projects, and the target frameworks of each project (`<TargetFramework>` and `<TargetFrameworks>`).
2. Find paths to skip: generated code, decompiled code, third-party code.
3. Copy `../../templates/profile.json` and `../../templates/profile.md` to `.adf/` and fill them in.
   - A test project entry is a path. If the test project does not build for every framework in `mainFramework` and `releaseFrameworks`, write it as `{ "path": "...", "frameworks": ["net8.0-windows"] }`. The main framework run uses the first framework in that list. A run for another framework that is not in the list skips the project.
4. Ask Allen only for decisions: release frameworks, hardware facts, authorized commands. Find everything else yourself.
5. Add `.adf/out/` and `.adf/drafts/` to `.gitignore`.

## 2. Tools

1. Run `../../scripts/install-tools.ps1` (once per machine).
2. Each test project needs the `coverlet.collector` package. The scan lists the projects that do not have it. Adding it changes the project; ask Allen before you add it.

## 3. Baseline

```powershell
& "<ADF>\scripts\scan.ps1" -Repo <repo>            # CRAP and coverage, a few minutes
& "<ADF>\scripts\scan.ps1" -Repo <repo> -Mutation  # adds mutation testing, can take long
```

Run it in the background. It writes:

- `.adf/baseline/crap.json`: every method with complexity, coverage, CRAP, and action.
- `.adf/baseline/mutation.json`: surviving mutants per file (with `-Mutation`).
- `.adf/baseline/inventory.json`: test projects and coverlet status.
- An HTML coverage report in `.adf/out/`.

Commit `.adf/profile.*` and `.adf/baseline/`.

## 4. Report

1. Test totals per project.
2. Methods over CRAP 12: count, split into "remove branches" (complexity > 12) and "add tests".
3. The five highest CRAP methods with `file:line`.
4. Surviving mutants: total and the five files with the most.
5. Next action: `/adf:debt` on the highest item, or a decision Allen must make.
