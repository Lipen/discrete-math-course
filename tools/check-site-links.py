#!/usr/bin/env python3
"""Check that every relative link in a hand-written site page resolves to a real file.

Point it at the pages about to be published, after the artefacts are copied:

    python3 tools/check-site-links.py public/index.html public/tex/index.html

Every relative ``href`` is resolved against the page and reported when the target
file or directory is absent. Pass a directory to check each ``index.html`` inside it.
External URLs, fragment-only links and ``mailto:`` are ignored.

The pages are named explicitly: the deploy publishes exactly two index pages
(the hub and the generated archive index), so the tool is told which they are
rather than guessing by discovery, and a generated tree is added by name when it gains one.
"""

import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

# Attributes whose value is a link target.
LINK_ATTRS = ('href="', "href='")


def links(html: str):
    for attr in LINK_ATTRS:
        quote = attr[-1]
        for chunk in html.split(attr)[1:]:
            yield chunk.split(quote, 1)[0]


def is_external(target: str) -> bool:
    parts = urlsplit(target)
    return target.startswith(("#", "mailto:", "tel:", "data:", "javascript:")) or bool(
        parts.scheme or parts.netloc
    )


def check_page(page: Path) -> list[str]:
    problems = []
    for target in links(page.read_text(encoding="utf-8")):
        target = target.strip()
        if not target or is_external(target):
            continue
        path = unquote(urlsplit(target).path)
        if not path:
            continue
        resolved = page.parent / path.lstrip("/")
        if not resolved.exists():
            problems.append(f"{page}: missing {target}")
    return problems


def pages(argv: list[str]) -> list[Path]:
    found = []
    for arg in argv:
        path = Path(arg)
        if path.is_dir():
            found += sorted(path.rglob("index.html"))
        else:
            found.append(path)
    return found


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: check-site-links.py <page.html|dir>...", file=sys.stderr)
        return 2

    targets = pages(argv[1:])
    problems = []
    missing_pages = [str(page) for page in targets if not page.is_file()]
    for page in targets:
        if page.is_file():
            problems += check_page(page)

    for page in missing_pages:
        print(f"no such page: {page}", file=sys.stderr)
    if problems:
        print("\n".join(problems), file=sys.stderr)
    if problems or missing_pages:
        count = len(problems) + len(missing_pages)
        print(f"\n{count} broken link(s) in {len(targets)} page(s)", file=sys.stderr)
        return 1

    print(f"site links ok in {len(targets)} page(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
