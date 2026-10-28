# ADF project profile: <project name>

This file holds the facts that apply only to this project. ADF rules apply first. This file can add rules. It cannot remove ADF rules.

The scripts read `.adf/profile.json`. Keep both files in step.

## Build and test

| Item | Value |
|---|---|
| Solution | `<Name>.sln` |
| Target frameworks | <list> |
| Main framework (development gates) | <tfm> |
| Release frameworks | <list> |
| Expected test count | <number> on <date>, per framework |
| Full suite time | <minutes> per framework |

## Known load-dependent tests

<List tests that fail under load and pass on a quiet machine. Name each test and how to recognize it.>

## Controlled terms

| Use | Do not use |
|---|---|
| <term> | <synonyms> |

## Integration (stage I)

| Item | Value |
|---|---|
| Driver | <console harness, FlaUI, ADS client, or other> |
| Real hardware | <yes or no> |
| Address and port | <value> |
| Resting state | <value> |
| What Allen authorized | <commands that are allowed without asking> |

## Paths to skip

<Generated code, decompiled code, third-party code.>

## Project traps

<Facts that cost work before. One line each, with the date.>
