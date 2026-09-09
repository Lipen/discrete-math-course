#!/usr/bin/env python3
"""Generate static archive index pages (.github/archive/{typst,tex}.html).

Sources of truth:
- typst/: the legacy files compiled by the `build-typst` CI job — parsed from
  `typst compile typst/<stem>.typ` lines in .github/workflows/ci.yml
- tex/: every tex/*.tex (the `build-tex` job compiles all of them)

Run from repo root:  python3 tools/gen-archive-index.py
Commit the result.
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CI = ROOT / ".github/workflows/ci.yml"
TEX = ROOT / "tex"
OUT = ROOT / ".github/archive"

PAGE = """<!doctype html>
<meta charset="utf-8">
<title>Archive: {name}</title>
<body style="font-family:system-ui,sans-serif;max-width:46em;margin:2.5em auto;padding:0 1.2em;color:#1a1a2e">
<h1 style="font-size:1.5em">📁 Archive: {name}</h1>
<p style="color:#777">{count} legacy PDF files.</p>
<ul style="columns:2;column-gap:2.5em;list-style:none;padding:0;line-height:1.9">
{items}
</ul>
"""

def typst_stems() -> list[str]:
    text = CI.read_text(encoding="utf-8")
    return sorted(set(re.findall(r"^\s*- run: typst compile typst/([a-z0-9-]+)\.typ$", text, re.M)))


def tex_stems() -> list[str]:
    return sorted(p.stem for p in TEX.glob("*.tex"))


def write_page(name: str, stems: list[str]) -> None:
    items = "\n".join(f'<li><a href="{s}.pdf">{s}.pdf</a></li>' for s in stems)
    page = PAGE.format(name=name, count=len(stems), items=items)
    path = OUT / f"{name}.html"
    path.write_text(page, encoding="utf-8")
    print(f"{path.relative_to(ROOT)}: {len(stems)} files")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    write_page("typst", typst_stems())
    write_page("tex", tex_stems())


if __name__ == "__main__":
    main()
