# Comment rules

The default action for a comment is: delete it.

## Comments that stay

Keep a comment only when it is one of these five types:

| # | Type | Example |
|---|---|---|
| 1 | License or copyright header | `// Copyright (c) ...` |
| 2 | Behavior that an external party forces on us, and that the code cannot show | A PLC, vendor library, protocol, or OS quirk |
| 3 | XML doc comment (`///`) on a **public** API | Describes the contract a caller depends on |
| 4 | Link to an issue or a specification, for a limit the code cannot express | `// See #12: the PLC rejects writes during Execute` |
| 5 | Suppression of a rule that is wrong here or that checks only style | `#pragma warning disable IDE0057` with the reason |

For type 2, check that the claim is still true today on a live code path. If it is not true, delete the comment.

## Comments that go

- Narration that repeats what the code does.
- Banners and section separators.
- Code that is commented out.
- `///` on `internal` or `private` members. Treat them as normal comments.
- Explanations of our own surprising code. Delete the comment and mark the symbol **RESHAPE**: rename it, extract it, or change its type so that the code is clear without the comment.
- Suppressions of a rule that finds real defects (`#pragma warning disable`, `[SuppressMessage]`). Delete the suppression and mark the symbol **RESHAPE**.

## Constraint comments

Comments such as "do not remove", "do not change", or "ask X before changing" state a rule. Turn the rule into a check: a type, a test, or an analyzer rule. Then delete the comment. If the owner does not approve the check, delete the comment and report the rule as open.

## Who does what

| Role | Action |
|---|---|
| Comment reviewer (`adf:comment-reviewer`) | Reports deletions and RESHAPE marks. Does not edit code. |
| Implementer | Applies the accepted deletions and reshapes. |
| Owner (main agent) | Accepts or rejects each finding. |

If you are not sure that a comment is one of the five types, delete it.
