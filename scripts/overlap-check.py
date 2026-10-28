"""Reports text in ADF that repeats a source document word for word.

Usage: python -I overlap-check.py <adf-root> <source-file-or-dir> [...]
A finding is a run of N or more identical words (default 8) shared by an ADF file and a source file.
Use it after a rewrite from third-party material, to prove no source sentence remains.
"""
import os
import re
import sys

RUN = 8


def words(path):
    with open(path, encoding="utf-8", errors="replace") as handle:
        return re.findall(r"[A-Za-z0-9']+", handle.read().lower())


def files(root):
    if os.path.isfile(root):
        yield root
        return
    for folder, _, names in os.walk(root):
        if ".git" in folder or ".tools" in folder:
            continue
        for name in names:
            if name.endswith((".md", ".ps1", ".psm1", ".py", ".sh")):
                yield os.path.join(folder, name)


def shingles(tokens):
    return {" ".join(tokens[i:i + RUN]) for i in range(len(tokens) - RUN + 1)}


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    adf_root, sources = sys.argv[1], sys.argv[2:]
    source_shingles = {}
    for source in sources:
        for path in files(source):
            source_shingles[path] = shingles(words(path))

    findings = 0
    for path in files(adf_root):
        own = shingles(words(path))
        for source, theirs in source_shingles.items():
            shared = own & theirs
            if not shared:
                continue
            findings += len(shared)
            print(f"{os.path.relpath(path, adf_root)} <-> {source}: {len(shared)} shared runs")
            for run in sorted(shared)[:5]:
                print(f"    {run}")
    print(f"Shared runs of {RUN}+ words: {findings}")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
