#!/usr/bin/env python3
"""Find statements duplicated inside a deck (same fact told twice on different slides).

Usage:
    python3 tools/check-duplicates.py lectures/s1-lec05-equivalence.typ [...]
    python3 tools/check-duplicates.py --all          # every lectures deck

A slide deck easily repeats itself after enrichment: the same "extreme case" or the
same worked example lands on two slides. The tool compares sentence-like lines
(>= 6 significant words) after stripping Typst markup and reports lines that occur
more than once, so the duplicate can be dropped or merged.
"""

import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MATH = re.compile(r"\$[^$]*\$")
MARKUP = re.compile(r"[#*_`\\]|^[+\-]\s*")
WORD = re.compile(r"[А-Яа-яЁёA-Za-z]+")
# Structural Typst lines recur by design (table stroke, header plumbing) — not prose.
BOILERPLATE = (
    "stroke",
    "columns",
    "align",
    "let",
    "table header",
    "table cell",
    "showing lines",
    "use",
)
STOP = {
    "и",
    "в",
    "во",
    "не",
    "на",
    "что",
    "с",
    "со",
    "а",
    "то",
    "все",
    "она",
    "так",
    "его",
    "но",
    "да",
    "ты",
    "к",
    "у",
    "же",
    "вы",
    "за",
    "бы",
    "по",
    "только",
    "ее",
    "мне",
    "было",
    "вот",
    "от",
    "меня",
    "еще",
    "нет",
    "о",
    "из",
    "ему",
    "теперь",
    "когда",
    "даже",
    "ну",
    "вдруг",
    "ли",
    "если",
    "уже",
    "или",
    "ни",
    "быть",
    "был",
    "него",
    "до",
    "вас",
    "нибудь",
    "опять",
    "уж",
    "вам",
    "ведь",
    "там",
    "потом",
    "себя",
    "ничего",
    "ей",
    "может",
    "они",
    "тут",
    "где",
    "есть",
    "надо",
    "ней",
    "для",
    "мы",
    "тебя",
    "их",
    "чем",
    "была",
    "сам",
    "чтоб",
    "без",
    "the",
    "of",
    "to",
    "and",
    "is",
}


def significant(line: str) -> str:
    """Reduce a source line to a comparable key, or '' when it is not prose."""
    if line.strip().startswith("#"):
        return ""
    text = MATH.sub(" ", line)
    text = MARKUP.sub(" ", text)
    if line.strip().startswith(("#", "let ", "columns:", "align:", "stroke:")):
        return ""
    words = [w.lower() for w in WORD.findall(text) if w.lower() not in STOP]
    if len(words) < 6:
        return ""
    key = " ".join(words)
    if any(key.startswith(mark) for mark in BOILERPLATE):
        return ""
    return key


def scan(typ: Path) -> list[tuple[str, list[int]]]:
    seen: dict[tuple[str, str], list[int]] = defaultdict(list)
    for number, line in enumerate(typ.read_text(encoding="utf-8").splitlines(), 1):
        key = significant(line)
        if key:
            seen[(key, typ.name)].append(number)
    groups = defaultdict(list)
    for (key, _), numbers in seen.items():
        if len(numbers) > 1:
            groups[key] = numbers
    return sorted(groups.items(), key=lambda item: item[1][0])


def main(argv: list[str]) -> int:
    targets = (
        sorted((ROOT / "lectures").glob("*.typ"))
        if not argv or argv[0] == "--all"
        else [Path(arg).resolve() for arg in argv]
    )
    total = 0
    for typ in targets:
        hits = scan(typ)
        if not hits:
            continue
        print(f"!! {typ.name}")
        for key, numbers in hits:
            print(f"     lines {numbers}: {key[:90]}")
        total += len(hits)
    print(f"\nrepeated statements: {total}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
