#!/usr/bin/env python3
"""Slide QC for lectures: continuation pages, density, thin slides.

Usage:
    python3 tools/check-slides.py lectures/s1-lec07-functions.typ [...]
    python3 tools/check-slides.py --all          # every lectures/s[12]-lec*.typ

For each deck the tool compiles it with typst, measures the rendered pages and
reports:
  * pages            --- total rendered pages;
  * continuations    --- pages whose heading repeats as "Title [N]", i.e. a slide
                        spilled onto the next page (defect: split the slide or trim);
  * blocks/slide     --- formal blocks (#definition, #theorem, #example, ...) per h2 slide;
  * thin slides      --- h2 slides with no blocks and little content.

Exit code is 1 when a continuation or a thin slide is found.
"""

import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BLOCKS = re.compile(
    r"^#(definition|theorem|lemma|corollary|proposition|proof|proof-sketch|example"
    r"|note|remark|important|trap|check|table|algorithm|tasklist|project)\b"
)
CONTINUATION = re.compile(r"^(.*?)\s*\[(\d+)\]$")
DIAGRAM = re.compile(r"^#(align\(center\)\[|figure\(|canvas\()")


def slide_layout(typ: Path) -> tuple[int, list[tuple[str, int, int]]]:
    """Return (slide count, [(title, block count, content lines)]) from the source."""
    text = typ.read_text(encoding="utf-8")
    slides = []
    for chunk in re.split(r"^== ", text, flags=re.MULTILINE)[1:]:
        lines = [line for line in chunk.splitlines() if line.strip()]
        if not lines:
            continue
        title = lines[0].strip()
        blocks = sum(1 for line in lines if BLOCKS.match(line))
        slides.append((title, blocks, len(lines)))
    return len(slides), slides


def rendered_pages(typ: Path) -> tuple[int, list[tuple[int, str]]]:
    """Compile the deck and return (page count, [(page, spilled title)])."""
    with tempfile.TemporaryDirectory() as tmp:
        pdf = Path(tmp) / (typ.stem + ".pdf")
        proc = subprocess.run(
            ["typst", "compile", "--root", "..", str(typ), str(pdf)],
            cwd=typ.parent,
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode != 0:
            print(proc.stderr.strip()[:400])
            raise SystemExit(f"{typ}: compile failed")
        txt = Path(tmp) / "text.txt"
        subprocess.run(["pdftotext", str(pdf), str(txt)], check=True)
        pages = txt.read_text(encoding="utf-8").split("\f")
    spills = []
    for number, page in enumerate(pages, 1):
        body = [line.strip() for line in page.splitlines() if line.strip()]
        if not body:
            continue
        match = CONTINUATION.match(body[0])
        if match:
            keep = [line for line in body[1:] if not re.match(r"^\d+ / \d+$", line)]
            spills.append((number, match.group(1)[:44], len(keep)))
    return len(pages), spills


def main(argv: list[str]) -> int:
    if not argv or argv[0] == "--all":
        targets = sorted((ROOT / "lectures").glob("s[12]-lec*.typ"))
    else:
        targets = [Path(arg).resolve() for arg in argv]
    problems = 0
    rows = []
    for typ in targets:
        count, slides = slide_layout(typ)
        blocks = sum(b for _, b, _ in slides)
        pages, spills = rendered_pages(typ)

        def has_diagram(chunk: str) -> bool:
            return any(DIAGRAM.match(line.strip()) for line in chunk.splitlines())

        chunks = re.split(r"^== ", typ.read_text(encoding="utf-8"), flags=re.MULTILINE)[
            1:
        ]
        thin = [
            (t, n)
            for (t, b, n), chunk in zip(slides, chunks)
            if b == 0 and n < 5 and not has_diagram(chunk)
        ]
        rows.append((count, blocks, typ.name, pages, len(spills), len(thin)))
        mark = "OK " if not spills and not thin else "!! "
        print(
            f"{mark}{typ.name}: {pages} pages, slides {count}, blocks/slide {blocks / max(count, 1):.2f}, "
            f"continuations {len(spills)}, thin {len(thin)}"
        )
        for number, title, keep in spills:
            print(f"     continuation p{number} «{title}» (+{keep} lines)")
        for title, lines in thin:
            print(f"     thin slide «{title}» ({lines} lines)")
        problems += len(spills) + len(thin)
    rows.sort(key=lambda r: r[1] / max(r[0], 1))
    print("\nlowest density first:")
    for count, blocks, name, pages, spills, thin in rows:
        print(
            f"  {blocks / max(count, 1):.2f}  {name}  ({pages} pages, {spills} cont, {thin} thin)"
        )
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
