#!/usr/bin/env python3
"""Heuristic prose checks for Typst lecture decks.

Flags prose colons, semicolons, two sentences on one line and Unicode dashes.
Code blocks, inline code, math, URLs and code-argument lines are ignored.

Usage:
    python3 tools/check-lecture-prose.py lectures/s1-lec09-propositional.typ
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

CYRILLIC = re.compile(r"[А-Яа-яЁё]")
SENTENCE_BREAK = re.compile(r"[.!?]\s+[А-ЯЁ]")
QUESTION = re.compile(
    r"^=+\s+(Что|Как|Почему|Зачем|Сколько|Где|Когда|Кто|Чем|Какой|Какая|Какие|Можно ли|Верно ли|Правда ли|Стоит ли|Нужно ли|Есть ли)\b"
)
ARG_LINE = re.compile(
    r"^\s*(title|date|authors|module|lecture|week|num|teaser|epigraph|"
    r"epigraph-author|reading|subtitle|ghost|caption)\s*:"
)
SKIP_LINE = re.compile(r"^\s*(#|//|table\.header|\[)")


def strip_inline(line: str) -> str:
    line = re.sub(r"`[^`]*`", "", line)
    line = re.sub(r"\$[^$]*\$", "", line)
    line = re.sub(r"https?://\S+", "", line)
    return line


def check(path: Path) -> list[tuple[int, str, str]]:
    findings: list[tuple[int, str, str]] = []
    in_raw = False
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if line.strip().startswith("```"):
            in_raw = not in_raw
            continue
        if in_raw or not line.strip():
            continue
        if SKIP_LINE.match(line) or ARG_LINE.match(line):
            continue
        text = strip_inline(line)
        if ":" in text and CYRILLIC.search(text):
            findings.append((number, "C", line.strip()))
        if ";" in text and CYRILLIC.search(text):
            findings.append((number, "S", line.strip()))
        if SENTENCE_BREAK.search(text):
            findings.append((number, "L", line.strip()))
        if (
            line.startswith("=")
            and QUESTION.match(line)
            and not line.rstrip().endswith("?")
        ):
            findings.append((number, "Q", line.strip()))
        if "—" in line or "–" in line:
            findings.append((number, "D", line.strip()))
    return findings


def main() -> int:
    paths = [Path(arg) for arg in sys.argv[1:]]
    if not paths:
        print("usage: check-lecture-prose.py FILE...", file=sys.stderr)
        return 2
    total = 0
    for path in paths:
        findings = check(path)
        total += len(findings)
        for number, kind, text in findings:
            print(f"{path}:{number}: {kind}  {text}")
    if total:
        print(
            f"\n{total} finding(s). C colon, S semicolon, L two sentences, D dash, Q question heading."
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
