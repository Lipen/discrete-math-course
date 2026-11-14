#!/usr/bin/env python3
"""Write an archive index that lists exactly the PDFs present in a directory.

The deploy copies the built PDFs first and then calls this, so the page cannot
advertise a file that the build did not produce:

    python3 tools/gen-archive-index.py public/typst typst

The index replaces the hand-written snapshots that used to drift from the build.
"""

import sys
from pathlib import Path

PAGE = """<!doctype html>
<meta charset="utf-8">
<title>Archive: {title}</title>
<body style="font-family:system-ui,sans-serif;max-width:46em;margin:2.5em auto;padding:0 1.2em;color:#1a1a2e">
<h1 style="font-size:1.5em">📁 Archive: {title}</h1>
<p style="color:#777">{count} legacy PDF {word}.</p>
<ul style="columns:2;column-gap:2.5em;list-style:none;padding:0;line-height:1.9">
{items}
</ul>
<p style="margin-top:2em;color:#777"><a href="../" style="color:#4f46e5">← На главную курса</a></p>
"""


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(__doc__.strip().splitlines()[3].strip(), file=sys.stderr)
        return 2
    directory, title = Path(argv[1]), argv[2]
    if not directory.is_dir():
        print(f"{directory}: not a directory", file=sys.stderr)
        return 2
    names = sorted(path.name for path in directory.glob("*.pdf"))
    items = "\n".join(f'<li><a href="{name}">{name}</a></li>' for name in names)
    page = PAGE.format(
        title=title,
        count=len(names),
        word="file" if len(names) == 1 else "files",
        items=items,
    )
    (directory / "index.html").write_text(page, encoding="utf-8")
    print(f"archive {directory}: {len(names)} files")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
