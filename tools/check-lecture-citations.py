#!/usr/bin/env python3
"""Check book-section citations in lecture reading tables.

A reading row cites a chapter and a section title, for example

    [m01, разделы "Синтаксис формул" и "Структурная индукция"]

Section titles drift.  This script compares every quoted title after an
``mNN`` mention against the actual headings of ``book/chapters/mNN-*.typ``.

Usage:
    python3 tools/check-lecture-citations.py

Exit code 1 means at least one citation names a section that does not exist.
"""

from __future__ import annotations

import difflib
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CHAPTERS = ROOT / "book" / "chapters"
LECTURES = ROOT / "lectures"

MATH = re.compile(r"\$[^$]*\$")
QUOTE = re.compile(r'"([^"]*)"')
HEADING = re.compile(r"^=+\s+(.*?)\s*(<[^>]*>)?\s*$")


def normalize(title: str) -> str:
    title = re.sub(r"^\\\*\s*", "", title)
    title = title.replace("---", "-").replace("--", "-")
    title = title.replace("—", "-").replace("–", "-")
    return re.sub(r"\s+", " ", title).strip()


def chapter_headings() -> dict[str, list[str]]:
    result: dict[str, list[str]] = {}
    for path in sorted(CHAPTERS.glob("m*.typ")):
        match = re.match(r"(m\d\d)", path.name)
        if not match:
            continue
        titles = []
        for line in path.read_text(encoding="utf-8").splitlines():
            heading = HEADING.match(line)
            if heading:
                titles.append(normalize(heading.group(1)))
        result[match.group(1)] = titles
    return result


def quoted_titles(segment: str) -> list[str]:
    """Quoted titles after ``mNN``, with math spans kept intact."""
    math_spans: list[str] = []

    def stash(match: re.Match[str]) -> str:
        math_spans.append(match.group(0))
        return f"\x00{len(math_spans) - 1}\x00"

    masked = MATH.sub(stash, segment)
    titles = []
    for raw in QUOTE.findall(masked):
        restored = re.sub(
            r"\x00(\d+)\x00",
            lambda match: math_spans[int(match.group(1))],
            raw,
        )
        if re.search(r"[А-Яа-яЁё]", restored):
            titles.append(restored)
    return titles


def main() -> int:
    headings = chapter_headings()
    findings: list[tuple[str, int, str, str]] = []

    for path in sorted(LECTURES.glob("*.typ")):
        if path.name == "theme.typ":
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            for match in re.finditer(r"\bm(\d\d)\b", line):
                code = "m" + match.group(1)
                tail = line[match.end() :]
                if "раздел" not in tail:
                    continue
                known = headings.get(code, [])
                for title in quoted_titles(tail):
                    normalized = normalize(title)
                    if normalized not in known:
                        findings.append((path.name, number, code, title))

    for filename, number, code, title in findings:
        known = headings.get(code, [])
        close = difflib.get_close_matches(normalize(title), known, n=1)
        hint = f" (did you mean {close[0]!r}?)" if close else ""
        print(f"{filename}:{number}: {code} has no section {title!r}{hint}")

    if findings:
        print(f"\n{len(findings)} missing section citation(s).")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
