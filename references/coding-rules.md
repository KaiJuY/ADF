# Coding rules

These rules apply to every implementation in ADF. The project profile can add rules. It cannot remove these rules.

## 1. Early return

Check failure and edge cases first, and return or throw at once. Keep the main path at the lowest indent level.

```csharp
// Do this
public Result Load(string path)
{
    if (string.IsNullOrEmpty(path))
        return Result.Fail("path is empty");
    if (!File.Exists(path))
        return Result.Fail("file not found");

    var text = File.ReadAllText(path);
    return Parse(text);
}

// Not this
public Result Load(string path)
{
    if (!string.IsNullOrEmpty(path))
    {
        if (File.Exists(path))
        {
            var text = File.ReadAllText(path);
            return Parse(text);
        }
        return Result.Fail("file not found");
    }
    return Result.Fail("path is empty");
}
```

In loops, use `continue` to skip an item. Do not wrap the loop body in an `if`.

Early return makes code easier to read. It does not lower cyclomatic complexity. Do not use it to meet the CRAP limit. See [quality-gates.md](quality-gates.md).

## 2. Complexity limit

A method with cyclomatic complexity above 12 must lose branches. Use a lookup table, polymorphism, or a state machine. Splitting the method into smaller methods does not count. The gate checks that the total complexity of the changed type goes down.

## 3. Comments

Follow [comment-rules.md](comment-rules.md).

## 4. Match the code around you

Use the naming, idioms, and structure of the surrounding code. Do not add an abstraction that has one caller.

## 5. File encoding

Keep each file's line endings and BOM as they are. Do not normalize them.

- Edit an existing file with the Edit tool.
- Do not use `sed` or `awk` on source files. Git Bash `sed` removes CR characters.
- For a bulk rename, use a byte-level script (`open(path, 'rb')`). After it runs, check: no lone LF in a CRLF file, BOM unchanged.
- After any scripted edit, run `git diff --check` and read `git diff --stat`. A small change that shows hundreds of changed lines means the line endings or the BOM changed.

## 6. Public surface

When you make a public type or member smaller (internal, removed, renamed), search the documents for text that describes it. Build and tests do not read documents.

## 7. Fix the cause

Find the first place where the state went wrong, and fix it there. Add a guard only when the state it handles is a legal state.
