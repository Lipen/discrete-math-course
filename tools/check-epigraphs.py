#!/usr/bin/env python3
"""Check that lecture epigraphs are registered in the private dossier.

The canon (lectures/CLAUDE.md) requires every epigraph used in a deck to have a
matching entry in `.dev/meta/lecture-epigraphs.md`, and the entry text to match the
deck verbatim. This tool extracts `epigraph:`/`epigraph-author:` pairs from the
decks and compares them with the registry entries.

Usage:
    python3 tools/check-epigraphs.py            # decks under lectures/
    python3 tools/check-epigraphs.py --quiet    # only the summary

Exit code is 1 when a deck quote is missing from the registry.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / ".dev" / "meta" / "lecture-epigraphs.md"
QUOTE = re.compile(r"epigraph:\s*\[(.*)\]")
AUTHOR = re.compile(r"epigraph-author:\s*\[(.*)\]")
ENTRY = re.compile(r"^-\s*\[(.*?)\]\s*---\s*(.*)$")


def deck_epigraphs(typ: Path) -> list[tuple[str, str]]:
    """Return [(quote, author)] pairs in source order."""
    pairs: list[tuple[str, str]] = []
    lines = typ.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(lines):
        match = QUOTE.search(line)
        if not match:
            continue
        author = ""
        for following in lines[index + 1 : index + 3]:
            found = AUTHOR.search(following)
            if found:
                author = found.group(1).strip()
                break
        pairs.append((match.group(1).strip(), author))
    return pairs


def registry_entries() -> list[tuple[str, str]]:
    if not REGISTRY.exists():
        return []
    entries = []
    for line in REGISTRY.read_text(encoding="utf-8").splitlines():
        match = ENTRY.match(line.strip())
        if match:
            entries.append((match.group(1).strip(), match.group(2).strip()))
    return entries


def main(argv: list[str]) -> int:
    quiet = "--quiet" in argv
    entries = registry_entries()
    known = {quote for quote, _ in entries}
    missing: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    for typ in sorted((ROOT / "lectures").glob("*.typ")):
        for quote, author in deck_epigraphs(typ):
            seen.add(quote)
            if quote not in known:
                missing.append((typ.name, quote, author))
    if not quiet:
        for name, quote, author in missing:
            print(f"MISSING {name}: [{quote}] --- {author or '???'}")
        orphans = [f"[{q}] --- {a}" for q, a in entries if q not in seen]
        for line in orphans:
            print(f"ORPHAN (в реестре, нет в деках): {line}")
    if "--write" in argv and missing:
        by_deck: dict[str, list[tuple[str, str]]] = {}
        for name, quote, author in missing:
            by_deck.setdefault(name, []).append((quote, author))
        block = [
            "",
            "<!-- Записи ниже добавлены автоматически из деков: текст совпадает с декой дословно,",
            "     источник не сверен --- при первой возможности заменить пометку на ссылку. -->",
            "",
        ]
        for name in sorted(by_deck):
            block.append(f"## {name} (автозапись)")
            block.append("")
            for quote, author in by_deck[name]:
                block.append(
                    f"- [{quote}] --- {author or 'автор не указан'} (источник не сверен)"
                )
            block.append("")
        with REGISTRY.open("a", encoding="utf-8") as handle:
            handle.write("\n".join(block))
        print(f"appended {len(missing)} entries for {len(by_deck)} decks")
    print(
        f"epigraphs in decks: {len(seen)}, registry entries: {len(entries)}, missing: {len(missing)}"
    )
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
