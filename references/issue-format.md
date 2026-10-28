# Issue format

## Labels

Use one of these labels on each issue. `/adf:grill` creates a missing label.

| Label | Trigger in chat | Meaning |
|---|---|---|
| `bug` | `#bug` | Behavior differs from the documented or expected behavior. |
| `feature` | `#feature` | New behavior. |
| `tech-debt` | `#issue`, or `/adf:debt` | Structure, tests, or quality. No behavior change. |

When the trigger is `#issue`, ask whether it is a bug, a feature, or tech debt.

## Body

Write the body in Traditional Chinese. Follow [writing-standard.md](writing-standard.md).

```markdown
## 背景
<why this is needed, 1 to 3 sentences>

## 驗收條件
1. <observable result>
2. <observable result>

## 範圍
- <in scope>

## 不做的事
- <out of scope>

## 決策紀錄
- <decision from the grill session, one line each>
```

For a bug, add before 驗收條件:

```markdown
## 重現步驟
1. <step>

## 實際結果 / 預期結果
- 實際：<what happens>
- 預期：<what should happen>
```

## Commands

```sh
gh issue create --title "<title>" --label <label> --body-file <file>
gh issue edit <n> --body-file <file>
gh issue comment <n> --body-file <file>
gh issue close <n> --comment "<merge commit and summary>"
```

Write the body to a file in the scratchpad first. Pass the file with `--body-file`. This keeps line breaks and Chinese text intact.
