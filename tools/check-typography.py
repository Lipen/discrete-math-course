#!/usr/bin/env python3
"""Типографика .typ: Unicode-тире и кавычки в исходнике --- ошибка.

Запускается prek на изменённых .typ файлах (файлы передаются аргументами).
Внутри `$...$` и `` `...` `` символы допустимы и не проверяются.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

MATH_RE = re.compile(r"\$[^$]*\$")
CODE_RE = re.compile(r"`[^`]*`")

HARD: list[tuple[re.Pattern[str], str]] = [
    (re.compile("[—–]"), "Unicode тире --- замени на ---"),
    (
        re.compile("[«»„“”‘’]"),
        'Unicode кавычки --- замени на прямые " (Typst рендерит «» сам)',
    ),
]

SOFT: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"[←-⇿⟰-⟿⤀-⥿⬀-⯿]"), "Unicode стрелка --- используй math-нотацию"),
    (re.compile(r"[∈∅⊆∪∩×→]"), "Unicode мат. символ --- используй Typst-команду"),
    (re.compile(r"…"), "Unicode многоточие --- пиши ..."),
]


def strip_typst(line: str) -> str:
    return MATH_RE.sub("$ $", CODE_RE.sub("` `", line))


def scan(path: Path) -> tuple[list[str], list[str]]:
    hard: list[str] = []
    soft: list[str] = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        return [f"{path}: не читается ({exc})"], []
    name = path.as_posix()
    for num, line in enumerate(lines, start=1):
        cleaned = strip_typst(line)
        for pattern, msg in HARD:
            found = sorted(set(pattern.findall(cleaned)))
            if found:
                chars = " ".join(f"U+{ord(c):04X}" for c in found)
                hard.append(f"{name}:{num}: {msg} (найдено: {chars})")
                hard.append(f"   {line.strip()}")
        for pattern, msg in SOFT:
            found = sorted(set(pattern.findall(cleaned)))
            if found:
                chars = " ".join(f"U+{ord(c):04X}" for c in found)
                soft.append(f"{name}:{num}: {msg} (найдено: {chars})")
    return hard, soft


LIVE_DIRS = ("book", "lectures", "course", "homework")


def main(argv: list[str]) -> int:
    if "--all" in argv:
        root = Path(__file__).resolve().parent.parent
        targets = sorted(
            path
            for folder in LIVE_DIRS
            for path in (root / folder).rglob("*.typ")
            if "_archive" not in path.parts and "archive" not in path.parts
        )
    else:
        targets = [Path(a) for a in argv if a.endswith(".typ") and Path(a).is_file()]
    if not targets:
        return 0
    hard: list[str] = []
    soft: list[str] = []
    for path in targets:
        h, s = scan(path)
        hard.extend(h)
        soft.extend(s)
    for msg in soft:
        print(f"WARN {msg}")
    for msg in hard:
        print(f"FAIL {msg}")
    return 1 if hard else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
