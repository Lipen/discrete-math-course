#!/usr/bin/env python3
"""Build the course hub: materials, the lecture list and chapter links.

Everything on the page comes from `site/course.yml`: the lectures, their short notes,
the slides file and the book chapters. Nothing is parsed out of the decks or the
syllabus, and no course data is copied here. Chapter page numbers come from the book's
own PDF outline, so a plate points at the page where the chapter starts.
"""

import html
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


def book_outline() -> dict[int, tuple[int, str]]:
    """Chapter number to (page, title), taken from the book's own PDF outline."""
    book = ROOT / "book" / "book.pdf"
    if not book.is_file():
        return {}
    try:
        dump = subprocess.run(
            ["pdftk", str(book), "dump_data"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return {}

    outline, title = {}, None
    for line in dump.splitlines():
        if line.startswith("BookmarkTitle:"):
            title = html.unescape(line.split(": ", 1)[1])
        elif line.startswith("BookmarkPageNumber:") and title:
            chapter = re.match(r"^(\d+) (.+)$", title)
            if chapter:
                outline[int(chapter.group(1))] = (
                    int(line.split(": ")[1]),
                    chapter.group(2),
                )
            title = None
    return outline


def block_of(chapter: str) -> str:
    for low, high, name in BLOCKS:
        if low <= chapter <= high:
            return name
    return "b1"


def chapter_chip(chapter: str, outline: dict[int, tuple[int, str]]) -> str:
    number = int(chapter[1:])
    page = outline.get(number)
    if not page:
        return f'<span class="chip {block_of(chapter)}">{chapter}</span>'
    return (
        f'<a class="chip {block_of(chapter)}" href="book.pdf#page={page[0]}"'
        f' target="_blank" rel="noopener"'
        f' title="Глава {number}. {escape(page[1])}">{chapter}</a>'
    )


def tight(dates: str) -> str:
    """No break between a number and its month."""
    return re.sub(r"(\d+)\s+(" + "|".join(MONTHS) + r")", "\\1\u00a0\\2", dates)


def week_start(dates: str, year: int) -> date | None:
    day = re.match(r"(\d+)", dates)
    month = re.search("|".join(MONTHS), dates)
    if not day or not month:
        return None
    return date(year, MONTHS[month.group(0)], int(day.group(1)))


def topic_row(
    number: int,
    topic: dict,
    outline: dict[int, tuple[int, str]],
    today: date,
    year: int,
) -> str:
    chips = [chapter_chip(chapter, outline) for chapter in topic.get("chapters") or []]
    slides = ROOT / "lectures" / f"{topic['slides']}.pdf"
    if slides.is_file():
        chips.append(
            f'<a class="chip" href="{slides.name}" target="_blank" rel="noopener">слайды</a>'
        )
    classes = ["topic"]
    start = week_start(topic["dates"], year)
    if start and start <= today < date.fromordinal(start.toordinal() + 7):
        classes.append("now")
    note = f'<p class="teaser">{escape(topic["note"])}</p>' if topic.get("note") else ""
    control = topic.get("control")
    plate = ""
    if control:
        label = {"kr": "КР", "tm": "ТМ"}[control["kind"]]
        plate = f'<div class="ctrl ctrl-{control["kind"]}">{label} {control["n"]}</div>'
    return (
        f'<li class="{" ".join(classes)}">'
        f'<div class="when"><div class="num"><span class="cap">лекция</span> {number:02d}</div>'
        f'<div class="wk">нед.\u00a0{topic["week"]}</div>'
        f'<div class="dates">{escape(tight(topic["dates"]))}</div>'
        f"{plate}</div>"
        f'<div class="what"><h3>{escape(topic["title"])}</h3>{note}'
        f'<p class="chips">{" ".join(chips)}</p></div>'
        f"</li>"
    )


def materials(content: dict) -> str:
    cubes = []
    for item in content["materials"]:
        href = item["href"]
        title = escape(item["title"])
        note = escape(item["note"])
        if href.startswith("#"):
            cubes.append(
                f'<a class="cube" href="{href}">'
                f'<span class="cube-head"><span class="cube-t">{title}</span>'
                f'<span class="cube-fmt">к списку</span></span>'
                f'<span class="cube-d">{note}</span></a>'
            )
        elif (ROOT / "book" / href).is_file() or (ROOT / "course" / href).is_file():
            cubes.append(
                f'<a class="cube" href="{href}" target="_blank" rel="noopener">'
                f'<span class="cube-head"><span class="cube-t">{title}</span>'
                f'<span class="cube-fmt">PDF</span></span>'
                f'<span class="cube-d">{note}</span></a>'
            )
    return f'<div class="cubes">{"".join(cubes)}</div>'


def card(href: str, label: str, title: str) -> str:
    return (
        f'<a class="mini" href="{href}" target="_blank" rel="noopener">'
        f'<span class="mini-n">{label}</span>'
        f'<span class="mini-t">{escape(title)}</span></a>'
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
            and (ROOT / "homework" / f"hw{work['number']}.pdf").is_file()
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
    cards = [
        card(f"tex/{sheet['file']}", f"Шпаргалка\u00a0{index}", sheet["title"])
        for index, sheet in enumerate(content.get("cheatsheets") or [], start=1)
        if (ROOT / "tex" / sheet["file"]).is_file()
    ]
    return (
        '<section class="sem" id="cheatsheets">\n  <h2>Шпаргалки</h2>\n  '
        f'<div class="mini-grid cheats">{"".join(cards)}</div>\n</section>'
    )


def page(title: str, body: str) -> str:
    return f"""<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<title>{escape(title)}</title>
<script>{THEME_INIT}</script>
<link rel="stylesheet" href="theme.css">
</head>
<body>
<a class="skip" href="#main">К содержанию</a>
<header class="top">
  <a class="brand" href="index.html">{escape(title)}</a>
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
  <p>{escape(title)} · Университет ИТМО · 2026/27</p>
  <p><a href="https://github.com/Lipen/discrete-math-course">Исходники курса</a></p>
</footer>
<script src="ui.js"></script>
</body>
</html>
"""


def main() -> int:
    content = yaml.safe_load((SITE / "course.yml").read_text(encoding="utf-8"))
    outline = book_outline()
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
    sources += sorted((ROOT / "lectures").glob("s*-lec*.pdf"))
    sources += sorted((ROOT / "homework").glob("hw*.pdf"))
    sheets = sorted((ROOT / "tex").glob("cheat*.pdf"))
    for path in sources:
        if path.is_file():
            shutil.copy2(path, ASSETS / path.name)
    if sheets:
        (DIST / "tex").mkdir(parents=True, exist_ok=True)
        for path in sheets:
            shutil.copy2(path, DIST / "tex" / path.name)
    for name in ("theme.css", "ui.js"):
        shutil.copy2(SITE / name, DIST / name)

    tabs, sections = [], []
    for number, semester in enumerate(content["semesters"], start=1):
        rows = "\n".join(
            topic_row(index, topic, outline, today, semester["year"])
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
</main>"""
    (DIST / "index.html").write_text(page(content["title"], body), encoding="utf-8")
    topics = sum(len(s["topics"]) for s in content["semesters"])
    print(
        f"site: {topics} topics, {len(outline)} chapter pages, {len(list(ASSETS.iterdir()))} entries"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
