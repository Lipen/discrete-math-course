#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Build the course hub: materials, the lecture list and chapter links.

Everything on the page comes from `site/course.yml`: the lectures, their short notes,
the slides file and the book chapters. Nothing is parsed out of the decks or the
syllabus, and no course data is copied here. Chapter page numbers come from the book's
own layout: the book exports chapter pages as metadata, and a plate links to
`book.pdf#page=N`.
"""

import html
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import yaml

SITE = Path(__file__).resolve().parent
ROOT = SITE.parent
DIST = SITE / "dist"
ASSETS = DIST

BLOCKS = (
    ("m01", "m09", "b1"),
    ("m10", "m17", "b2"),
    ("m18", "m22", "b3"),
    ("m23", "m36", "b4"),
)
MONTHS = {
    "января": 1,
    "февраля": 2,
    "марта": 3,
    "апреля": 4,
    "мая": 5,
    "июня": 6,
    "июля": 7,
    "августа": 8,
    "сентября": 9,
    "октября": 10,
    "ноября": 11,
    "декабря": 12,
}

BOOK_ICON = """<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M12 6.6C10.4 5 8.3 4.2 5.8 4.2H3.5v13.4h2.3c2.5 0 4.6.8 6.2 2.4 1.6-1.6 3.7-2.4 6.2-2.4h2.3V4.2h-2.3c-2.5 0-4.6.8-6.2 2.4z"/><path d="M12 6.6V20"/></svg>"""
RULES_ICON = """<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="4.6" width="14" height="16.2" rx="2.4"/><path d="M9.2 2.6h5.6v3.8H9.2z"/><path d="M8.7 13.4l2.1 2.1 4.5-4.5"/></svg>"""
LAB_ICON = """<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M9 3h6"/><path d="M10 3v6.2L5.2 18a1.8 1.8 0 0 0 1.6 2.6h10.4a1.8 1.8 0 0 0 1.6-2.6L14 9.2V3"/><path d="M7.3 15h9.4"/></svg>"""
HOME_ICON = """<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 11l8-7 8 7"/><path d="M6 10v9h12v-9"/></svg>"""

ICONS = """
<svg class="i-auto" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" stroke-width="1.7"/><path d="M12 3.5a8.5 8.5 0 0 0 0 17z" fill="currentColor"/></svg>
<svg class="i-light" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4.2" fill="none" stroke="currentColor" stroke-width="1.8"/><g stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M12 2.6v2.2M12 19.2v2.2M2.6 12h2.2M19.2 12h2.2M5.4 5.4l1.6 1.6M17 17l1.6 1.6M18.6 5.4L17 7M7 17l-1.6 1.6"/></g></svg>
<svg class="i-dark" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 14.5A8.6 8.6 0 0 1 9.5 4a8.6 8.6 0 1 0 10.5 10.5z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
"""

THEME_INIT = """
(function () {
  var key = "dm-theme";
  var pref = localStorage.getItem(key) || "auto";
  var media = window.matchMedia("(prefers-color-scheme: dark)");
  function apply() {
    var dark = pref === "dark" || (pref === "auto" && media.matches);
    document.documentElement.dataset.theme = dark ? "dark" : "light";
    document.documentElement.dataset.pref = pref;
  }
  apply();
  media.addEventListener("change", function () { if (pref === "auto") apply(); });
  window.__theme = {
    get: function () { return pref; },
    set: function (next) { pref = next; localStorage.setItem(key, next); apply(); }
  };
})();
"""


def escape(text: str) -> str:
    return html.escape(text, quote=False)


def chapter_pages() -> dict[int, int]:
    """Chapter number to the physical page of its heading, taken from Typst.

    The artifact from CI wins. Locally the last answer is reused while the built
    book.pdf is not newer: the numbers exist to point into that very PDF, so a
    re-run after editing a chapter without rebuilding the book would only make
    them disagree with the file the site links to.
    """
    artifact = ROOT / "pages" / "chapter-pages.json"
    if artifact.is_file():
        return _pages(artifact.read_text(encoding="utf-8"))
    cache = ROOT / "chapter-pages.json"
    pdf = ROOT / "book" / "book.pdf"
    if (
        cache.is_file()
        and pdf.is_file()
        and cache.stat().st_mtime > pdf.stat().st_mtime
    ):
        return _pages(cache.read_text(encoding="utf-8"))
    result = subprocess.run(
        ["typst", "eval", "query(metadata)", "--in", "book.typ"],
        cwd=ROOT / "book",
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return {}
    pages = _pages(result.stdout)
    if pages:
        cache.write_text(result.stdout, encoding="utf-8")
    return pages


def _pages(raw: str) -> dict[int, int]:
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return {}
    for entry in data if isinstance(data, list) else []:
        value = entry.get("value") if isinstance(entry, dict) else None
        if isinstance(value, dict) and "chapter-pages" in value:
            return {row["n"]: row["page"] for row in value["chapter-pages"]}
    return {}


def block_of(chapter: str) -> str:
    for low, high, name in BLOCKS:
        if low <= chapter <= high:
            return name
    return "b1"


def chapter_chip(chapter: str, pages: dict[int, int]) -> str:
    number = int(chapter[1:])
    page = pages.get(number)
    if not page:
        return f'<span class="chip {block_of(chapter)}">{chapter}</span>'
    return (
        f'<a class="chip {block_of(chapter)}" href="book.pdf#page={page}"'
        f' target="_blank" rel="noopener"'
        f' title="Глава {number}">{chapter}</a>'
    )


def schedule_rows() -> dict[tuple[int, int], dict]:
    """(semester, week) to the row from the shared course/schedule.yml."""
    path = ROOT / "course" / "schedule.yml"
    if not path.is_file():
        return {}
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    rows = {}
    for index, semester in enumerate(data["semesters"], start=1):
        for week in semester["weeks"]:
            rows[(index, week["week"])] = week
    return rows


def week_dates(row: dict | None) -> str:
    if not row or not row.get("start"):
        return ""
    start = date.fromisoformat(str(row["start"]))
    end = date.fromordinal(start.toordinal() + 6)
    months = (
        "января",
        "февраля",
        "марта",
        "апреля",
        "мая",
        "июня",
        "июля",
        "августа",
        "сентября",
        "октября",
        "ноября",
        "декабря",
    )
    tail = months[end.month - 1]
    if start.month == end.month:
        return f"{start.day}\u2013{end.day} {tail}"
    return f"{start.day} {months[start.month - 1]} \u2013 {end.day} {tail}"


def tight(dates: str) -> str:
    """No break between a number and its month."""
    return re.sub(r"(\d+)\s+(" + "|".join(MONTHS) + r")", "\\1\u00a0\\2", dates)


def topic_row(
    number: int,
    topic: dict,
    dates: str,
    row: dict | None,
    pages: dict[int, int],
    today: date,
    year: int,
) -> str:
    chips = [chapter_chip(chapter, pages) for chapter in topic.get("chapters") or []]
    chips.append(
        f'<a class="chip" href="{topic["slides"]}.pdf" target="_blank" rel="noopener">слайды</a>'
    )
    classes = ["topic"]
    start = date.fromisoformat(str(row["start"])) if row and row.get("start") else None
    if start and start <= today < date.fromordinal(start.toordinal() + 7):
        classes.append("now")
    note = f'<p class="teaser">{escape(topic["note"])}</p>' if topic.get("note") else ""
    control = (row or {}).get("control")
    plate = ""
    if control:
        label = {"kr": "КР", "tm": "ТМ"}[control["kind"]]
        plate = f'<div class="ctrl ctrl-{control["kind"]}">{label} {control["n"]}</div>'
    return (
        f'<li class="{" ".join(classes)}">'
        f'<div class="when"><div class="num">{number:02d}</div>'
        f'<div class="wk">нед.\u00a0{topic["week"]}</div>'
        f'<div class="dates">{escape(tight(dates))}</div>'
        f"{plate}</div>"
        f'<div class="what"><h3>{escape(topic["title"])}</h3>{note}'
        f'<p class="chips">{" ".join(chips)}</p></div>'
        f"</li>"
    )


def materials(content: dict) -> str:
    icons = {"book": BOOK_ICON, "rules": RULES_ICON, "lab": LAB_ICON}
    cubes = []
    for item in content["materials"]:
        cubes.append(
            f'<a class="cube" href="{escape(item["href"])}" target="_blank" rel="noopener">'
            f'<span class="cube-icon">{icons.get(item.get("icon"), "")}</span>'
            f'<span class="cube-body"><span class="cube-t">{escape(item["title"])}</span>'
            f'<span class="cube-fmt">{escape(item.get("fmt", "PDF"))}</span></span></a>'
        )
    return f'<div class="cubes">{"".join(cubes)}</div>'


def card(href: str, label: str, title: str) -> str:
    return (
        f'<a class="mini" href="{href}" target="_blank" rel="noopener">'
        f'<span class="mini-n">{label}</span>'
        f'<span class="mini-t">{escape(title)}</span>'
        f'<span class="pill-fmt">PDF</span></a>'
    )


def homework_section(content: dict) -> str:
    groups = []
    labels = {
        index: semester["tab"]
        for index, semester in enumerate(content["semesters"], start=1)
    }
    for semester in (1, 2):
        cards = [
            card(
                f"hw{work['number']}.pdf",
                f"ДЗ\u00a0{work['number']}",
                work["title"],
            )
            for work in content["homework"]
            if work["semester"] == semester
        ]
        if cards:
            groups.append(
                f'<div class="mini-group"><h3>{escape(labels[semester])}</h3>'
                f'<div class="mini-grid">{"".join(cards)}</div></div>'
            )
    return (
        '<section class="sem" id="homework">\n  <h2>Домашние задания</h2>\n  '
        f"{''.join(groups)}\n</section>"
    )


def cheatsheets_section(content: dict) -> str:
    rows = "".join(
        '<li><a class="sheet" href="tex/{file}" target="_blank" rel="noopener">'
        '<span class="sheet-n">{number:02d}</span>'
        '<span class="sheet-t">{title}</span>'
        '<span class="pill-fmt">PDF</span>'
        "</a></li>".format(
            file=escape(sheet["file"]),
            number=index,
            title=escape(sheet["title"]),
        )
        for index, sheet in enumerate(content.get("cheatsheets") or [], start=1)
    )
    return (
        '<section class="sem" id="cheatsheets">\n  <h2>Шпаргалки</h2>\n  '
        f'<ol class="sheets">{rows}</ol>\n</section>'
    )


def legacy_section(content: dict) -> str:
    rows = "".join(
        '<li><a class="sheet" href="typst/{file}" target="_blank" rel="noopener">'
        '<span class="sheet-t">{title}</span>'
        '<span class="pill-fmt">PDF</span>'
        "</a></li>".format(file=escape(doc["file"]), title=escape(doc["title"]))
        for index, doc in enumerate(content.get("legacy") or [], start=1)
    )
    if not rows:
        return ""
    return (
        '<section class="sem" id="legacy">\n  <h2>Старые лекции</h2>\n  '
        f'<ol class="sheets">{rows}</ol>\n</section>'
    )


CAVE_SCENE = """<svg class="cave-scene" viewBox="0 0 600 600" aria-hidden="true">
  <defs>
    <linearGradient id="beam" x1="150" y1="360" x2="600" y2="360" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#ffce8a" stop-opacity=".8"/>
      <stop offset=".45" stop-color="#f0b45a" stop-opacity=".32"/>
      <stop offset="1" stop-color="#f0b45a" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="core" x1="150" y1="360" x2="600" y2="360" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#fff0c0" stop-opacity=".9"/>
      <stop offset=".5" stop-color="#ffd28a" stop-opacity=".28"/>
      <stop offset="1" stop-color="#ffd28a" stop-opacity="0"/>
    </linearGradient>
    <radialGradient id="glow" cx="150" cy="360" r="90" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#ffd28a" stop-opacity=".75"/>
      <stop offset="1" stop-color="#ffd28a" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="vig" cx="300" cy="300" r="380" gradientUnits="userSpaceOnUse">
      <stop offset=".45" stop-color="#000" stop-opacity="0"/>
      <stop offset="1" stop-color="#000" stop-opacity=".55"/>
    </radialGradient>
    <filter id="soft" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="9"/></filter>
    <filter id="softcore" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="3"/></filter>
  </defs>
  <rect width="600" height="600" fill="#0e1116"/>
  <polygon points="150,360 600,60 600,580" fill="url(#beam)" filter="url(#soft)" class="lamp-beam"/>
  <polygon points="150,360 600,270 600,450" fill="url(#core)" filter="url(#softcore)" class="lamp-core"/>
  <g fill="#ffd28a">
    <circle class="mote" cx="250" cy="340" r="2" opacity=".35"/>
    <circle class="mote" cx="292" cy="382" r="1.5" opacity=".3"/>
    <circle class="mote" cx="332" cy="320" r="2" opacity=".4"/>
    <circle class="mote" cx="382" cy="362" r="1.6" opacity=".32"/>
    <circle class="mote" cx="432" cy="330" r="2.2" opacity=".38"/>
    <circle class="mote" cx="482" cy="390" r="1.4" opacity=".3"/>
    <circle class="mote" cx="522" cy="342" r="1.8" opacity=".35"/>
  </g>
  <text x="450" y="365" class="relic" text-anchor="middle" font-family="Iowan Old Style, Palatino Linotype, Book Antiqua, Georgia, serif" font-size="96" font-weight="400" letter-spacing="-1" fill="#f0b45a">404</text>
  <line x1="402" y1="386" x2="498" y2="386" stroke="#f0b45a" stroke-opacity=".35" stroke-width="1.2"/>
  <text x="450" y="410" text-anchor="middle" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif" font-size="12" font-weight="600" letter-spacing="2.6" fill="#f0b45a" opacity=".68">СТРАНИЦА НЕ НАЙДЕНА</text>
  <circle cx="150" cy="360" r="90" fill="url(#glow)" class="lamp-glow"/>
  <path d="M80 230 C80 170 220 170 220 230" fill="none" stroke="#f0b45a" stroke-opacity=".55" stroke-width="4" stroke-linecap="round"/>
  <path d="M60 230 H240 L225 260 H75 Z" fill="#1a1e26" stroke="#f0b45a" stroke-opacity=".8" stroke-width="2.5" stroke-linejoin="round"/>
  <path d="M95 260 H205 L225 470 H75 Z" fill="#ffce8a" fill-opacity=".05" stroke="#f0b45a" stroke-opacity=".8" stroke-width="2.5" stroke-linejoin="round"/>
  <path d="M120 260 L105 470 M180 260 L195 470" stroke="#f0b45a" stroke-opacity=".35" stroke-width="1.5"/>
  <path d="M108 270 L95 455" stroke="#fff0c0" stroke-opacity=".18" stroke-width="3"/>
  <path d="M55 470 H245 L260 510 H40 Z" fill="#1a1e26" stroke="#f0b45a" stroke-opacity=".8" stroke-width="2.5" stroke-linejoin="round"/>
  <path d="M150 310 C168 336 168 366 150 382 C132 366 132 336 150 310 Z" fill="#ffd28a" class="lamp-flame"/>
  <path d="M150 330 C158 344 158 362 150 372 C142 362 142 344 150 330 Z" fill="#fff0c0" class="lamp-flame-core"/>
  <path d="M0 520 H600" stroke="#eef1f6" stroke-opacity=".05" stroke-width="1"/>
  <rect width="600" height="600" fill="url(#vig)"/>
</svg>"""


def not_found() -> str:
    # GitHub Pages serves 404.html at the missing URL's depth, so assets need the site base.
    body = f"""<div class="torch" aria-hidden="true"><span class="torch-lamp"></span></div>
<main id="main" class="di d1">
  <section class="scene">
    <div class="inner grid">
      <div class="art">
        <div class="cave" aria-hidden="true">{CAVE_SCENE}</div>
      </div>
      <div class="copy">
        <h1>Диоген искал <em>человека</em></h1>
        <p class="sub">Мы искали страницу. Ни человека, ни страницы.</p>
        <div class="actions">
          <a class="btn primary" href="index.html">{HOME_ICON} На главную</a>
          <a class="btn" href="book.pdf">{BOOK_ICON} Открыть книгу</a>
        </div>
      </div>
    </div>
  </section>
</main>"""
    return page(
        "Страница не найдена",
        body,
        brand="Дискретная математика",
        base="/discrete-math-course/",
        head='<link rel="stylesheet" href="404.css"><script src="404.js" defer></script>',
    )


def page(
    title: str,
    body: str,
    *,
    brand: str | None = None,
    base: str | None = None,
    head: str = "",
) -> str:
    brand = brand or title
    base_tag = f'<base href="{escape(base)}">\n' if base else ""
    return f"""<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
{base_tag}<meta name="color-scheme" content="light dark">
<title>{escape(title)}</title>
<script>{THEME_INIT}</script>
<link rel="icon" href="icon.svg" type="image/svg+xml">
<link rel="stylesheet" href="theme.css">
{head}
</head>
<body>
<a class="skip" href="#main">К содержанию</a>
<header class="top">
  <a class="brand" href="index.html">
    <svg class="brand-mark" viewBox="0 0 100 100" aria-hidden="true" fill="none"><path d="M50 7 L93 29.5 V70.5 L68 87 H32 L7 70.5 V29.5 Z" stroke="currentColor" stroke-width="6" stroke-linejoin="round"/><path d="M23 71 L36.5 31 L50 71 Z M31.9 62 L36.5 50.6 L41.1 62 Z" fill="currentColor" fill-rule="evenodd"/><path d="M52 71 V31 L63.5 49 L75 31 V71 H68.5 V53 L63.5 60.5 L58.5 53 V71 Z" fill="currentColor"/></svg>
    {escape(brand)}
  </a>
  <div class="top-actions">
    <a class="gh" href="https://github.com/Lipen/discrete-math-course" target="_blank" rel="noopener"
       aria-label="Исходники на GitHub" title="Исходники на GitHub">
      <svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 .5C5.73.5.99 5.24.99 11.5c0 4.85 3.15 8.96 7.5 10.42.55.1.75-.24.75-.53v-1.9c-3.05.66-3.7-1.3-3.7-1.3-.5-1.27-1.22-1.6-1.22-1.6-1-.68.07-.67.07-.67 1.1.08 1.68 1.13 1.68 1.13.98 1.68 2.57 1.2 3.2.92.1-.71.38-1.2.7-1.48-2.44-.28-5-1.22-5-5.42 0-1.2.43-2.18 1.13-2.95-.11-.28-.49-1.4.11-2.9 0 0 .92-.3 3.01 1.12.87-.24 1.8-.36 2.73-.36.93 0 1.86.12 2.73.36 2.09-1.42 3.01-1.12 3.01-1.12.6 1.5.22 2.62.11 2.9.7.77 1.13 1.75 1.13 2.95 0 4.21-2.57 5.13-5.02 5.41.39.34.74 1.01.74 2.04v3.02c0 .3.2.64.76.53 4.35-1.46 7.49-5.57 7.49-10.42C23.01 5.24 18.27.5 12 .5z"/></svg>
    </a>
    <button class="theme" id="theme" type="button" aria-label="Тема оформления" title="Тема: авто">
{ICONS}
    </button>
  </div>
</header>
{body}
<footer class="foot">
  <p>Университет ИТМО · 2026/27</p>
  <p><a href="https://github.com/Lipen/discrete-math-course">Исходники курса</a></p>
</footer>
<script src="ui.js"></script>
</body>
</html>
"""


def main() -> int:
    content = yaml.safe_load((SITE / "course.yml").read_text(encoding="utf-8"))
    pages = chapter_pages()
    weeks = schedule_rows()
    today = datetime.now(ZoneInfo("Europe/Moscow")).date()

    if DIST.exists():
        shutil.rmtree(DIST)
    DIST.mkdir(parents=True)
    sources = [
        ROOT / "book" / "book.pdf",
        ROOT / "course" / "syllabus.pdf",
        ROOT / "course" / "program.pdf",
        ROOT / "course" / "mentors.pdf",
        ROOT / "lectures" / "course-intro.pdf",
    ]
    preview = "--preview" in sys.argv[1:]
    sources += sorted((ROOT / "lectures").glob("s*-lec*.pdf"))
    sources += sorted((ROOT / "homework").glob("hw*.pdf"))
    sheets = sorted((ROOT / "tex").glob("cheat*.pdf"))
    linked = 0
    for path in sources if preview else []:
        if path.is_file():
            os.symlink(path, ASSETS / path.name)
            linked += 1
    if sheets and preview:
        (DIST / "tex").mkdir(parents=True, exist_ok=True)
        for path in sheets:
            os.symlink(path, DIST / "tex" / path.name)
            linked += 1
    legacy = sorted((ROOT / "typst").glob("*.pdf"))
    if legacy and preview:
        (DIST / "typst").mkdir(parents=True, exist_ok=True)
        for path in legacy:
            os.symlink(path, DIST / "typst" / path.name)
            linked += 1
    for name in ("theme.css", "ui.js", "icon.svg", "404.css", "404.js"):
        shutil.copy2(SITE / name, DIST / name)
    lab_source = ROOT / "lab"
    if lab_source.is_dir():
        shutil.copytree(lab_source, DIST / "lab", dirs_exist_ok=True)

    tabs, sections = [], []
    for number, semester in enumerate(content["semesters"], start=1):
        rows = "\n".join(
            topic_row(
                index,
                topic,
                week_dates(weeks.get((number, topic["week"]))),
                weeks.get((number, topic["week"])),
                pages,
                today,
                semester["year"],
            )
            for index, topic in enumerate(semester["topics"], start=1)
        )
        tabs.append(f'<a href="#sem{number}">{escape(semester["tab"])}</a>')
        sections.append(
            f"""<section class="sem" id="sem{number}">
  <h2>{escape(semester["name"])}</h2>
  <ol class="weeks">
{rows}
  </ol>
</section>"""
        )
    tabs.append('<a href="#homework">ДЗ</a>')
    tabs.append('<a href="#cheatsheets">Шпаргалки</a>')
    if content.get("legacy"):
        tabs.append('<a href="#legacy">Старые лекции</a>')

    body = f"""<main id="main">
<header class="hero">
  <p class="kicker">{escape(content["university"])} · {escape(content["year"])}</p>
  <h1>{escape(content["title"])}</h1>
  {materials(content)}
</header>
<nav class="tabs" aria-label="Разделы">
  <button class="up" id="up" type="button" aria-label="Наверх" title="Наверх">
    <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 19V5M5 12l7-7 7 7" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
  </button>
  {" ".join(tabs)}
</nav>
{chr(10).join(sections)}
{homework_section(content)}
{cheatsheets_section(content)}
{legacy_section(content)}
</main>"""
    (DIST / "index.html").write_text(page(content["title"], body), encoding="utf-8")
    (DIST / "404.html").write_text(not_found(), encoding="utf-8")
    topics = sum(len(s["topics"]) for s in content["semesters"])
    note = f", {linked} links for preview" if preview else ""
    print(f"site: {topics} topics, {len(pages)} chapter pages{note}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
