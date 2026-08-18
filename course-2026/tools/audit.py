#!/usr/bin/env -S uv run --script
"""Полный стилевой аудит глав книги.

Считает по каждой главе:
  - слоп-паттерны (check-slop SLOP_PATTERNS, по всему файлу, не diff);
  - стоп-слова BOOK-STYLE;
  - каталожные пробеги блоков без прозы;
  - типографические нарушения (Unicode em-dash, «», , „, '').
"""
import glob
import re

NOTES_DIR = '.'

SLOP_PATTERNS = [
    (r"Стоит отметить,? что", "filler"),
    (r"Важно понимать,? что", "filler"),
    (r"Необходимо подчеркнуть,? что", "filler"),
    (r"Следует отметить,? что", "filler"),
    (r"Хотелось бы отметить,? что", "filler"),
    (r"Нельзя не отметить,? что", "filler"),
    (r"Надо сказать,? что", "filler"),
    (r"Дело в том, что", "filler"),
    (r"Всё дело в том, что", "filler"),
    (r"В контексте (этого|данного|нашего) (обсуждения|разговора|рассмотрения)", "filler"),
    (r"Не секрет, что", "filler"),
    (r"Более того,", "overused"),
    (r"Кроме того,", "overused"),
    (r"В свою очередь,", "overused"),
    (r"Вместе с тем,", "overused"),
    (r"В то же время,", "overused"),
    (r"Тем не менее,", "overused"),
    (r"Иными словами,", "overused"),
    (r"Другими словами,", "overused"),
    (r"Читатель,? (возможно |вероятно |уже |)заметил", "mind-reading"),
    (r"Читатель,? (возможно |вероятно |уже |)догадался", "mind-reading"),
    (r"Читателю (предлагается|стоит|следует|нужно|необходимо)", "mind-reading"),
    (r"Пусть читатель", "mind-reading"),
    (r"Глубокая (красота|истина|связь|мысль|идея)", "pseudo-deep"),
    (r"Поразительная (красота|связь|глубина)", "pseudo-deep"),
    (r"Удивительная (связь|закономерность|структура|красота)", "pseudo-deep"),
    (r"В этом факте —", "pseudo-deep"),
    (r"Так сложилось исторически", "lazy"),
    (r"По историческим причинам", "lazy"),
    (r"Это (очень |весьма |крайне |чрезвычайно )?(важно|интересно|замечательно|прекрасно)", "superlative"),
    (r'^[А-Я][а-яё]{1,10}\.$', "fragment"),
    (r'^[А-Я][а-яё]+ [А-Я][а-яё]+\.$', "fragment"),
    (r'^Ни [а-яё]+\.$', "fragment"),
    (r'^Стоп\.$', "fragment"),
    (r'^Вот как это выглядит\.$', "fragment"),
    (r'^Никаких [а-яё]+\.$', "fragment"),
]

STOP_WORDS = ['очевидно', 'нетрудно видеть', 'разумеется', 'обратите внимание',
              'заметьте', 'поразительно', 'удивительно', 'изящно',
              'фундаментальный', 'ключевой', 'важнейший', 'центральный',
              'с непривычки кажется', 'гора фактов']

BLOCKS = ['#definition', '#theorem', '#lemma', '#corollary', '#proposition', '#proof',
          '#example', '#remark', '#raven', '#note', '#history-note', '#chapter-overview',
          '#algorithm', '#proof-sketch']


def kind_col0(s):
    if s.startswith(('==', '===')):
        return 'header'
    for b in BLOCKS:
        if s.startswith(b + '['):
            return 'block'
    if s == ']':
        return 'close'
    if s.startswith(('//', '#import', '#include', '#set', '#show', '#pagebreak', '#align', '#v(')):
        return 'code'
    return 'prose'


def analyze(fname):
    lines = open(fname, encoding='utf-8').read().splitlines()
    text = '\n'.join(lines)
    slop = {}
    for pat, cat in SLOP_PATTERNS:
        n = len(re.findall(pat, text, flags=re.MULTILINE | re.IGNORECASE))
        if n:
            slop[cat] = slop.get(cat, 0) + n
    stops = {}
    low = text.lower()
    for w in STOP_WORDS:
        c = low.count(w)
        if c:
            stops[w] = c
    # каталоги
    runs = []
    run = 0
    for ln in lines:
        if ln[:1].isspace():
            continue
        s = ln.strip()
        if not s:
            continue
        k = kind_col0(s)
        if k == 'block':
            run += 1
        elif k in ('prose', 'header'):
            if run >= 2:
                runs.append(run)
            run = 0
    if run >= 2:
        runs.append(run)
    # типографика
    typo = []
    if '—' in text:
        typo.append(f'em-dash Unicode {text.count(chr(0x2014))}')
    if '«' in text or '»' in text:
        typo.append(f'«» {text.count(chr(0xAB)) + text.count(chr(0xBB))}')
    if chr(0x201C) in text or chr(0x201D) in text:
        typo.append(f'English quotes {text.count(chr(0x201C)) + text.count(chr(0x201D))}')
    cjk = re.findall(r'[\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff\uac00-\ud7af\uf900-\ufaff]', text)
    if cjk:
        typo.append(f'CJK x{len(cjk)}: ' + ' '.join(sorted(set(cjk))[:5]))
    # пустые секции: заголовок сразу за заголовком (без прозы между)
    empty_sec = []
    prev_heading = False
    for ln in lines:
        if not ln.strip():
            continue
        is_heading = bool(re.match(r'^=+ ', ln))
        if is_heading and prev_heading:
            empty_sec.append(ln.strip())
        prev_heading = is_heading
    return slop, stops, runs, typo, empty_sec


rows = []
for f in sorted(glob.glob('m[0-9][0-9]-*.typ')):
    slop, stops, runs, typo, empty_sec = analyze(f)
    total_slop = sum(slop.values())
    rows.append((f, total_slop, len(stops), len(runs), max(runs) if runs else 0,
                 slop, stops, typo, empty_sec))

rows.sort(key=lambda r: r[1], reverse=True)
print(f"{'file':28} {'slop':>4} {'stopwords':>9} {'cat-runs':>8} {'maxrun':>6}")
for f, ts, nst, nr, mr, slop, stops, typo, empty_sec in rows:
    print(f"{f:28} {ts:>4} {nst:>9} {nr:>8} {mr:>6}")

print("\n=== топ-10 слопа ===")
for f, ts, nst, nr, mr, slop, stops, typo, empty_sec in rows[:10]:
    if ts:
        cats = ', '.join(f"{k}={v}" for k, v in sorted(slop.items()))
        print(f"  {f}: {ts}  [{cats}]")

print("\n=== типографика и CJK ===")
for f, ts, nst, nr, mr, slop, stops, typo, empty_sec in rows:
    if typo:
        print(f"  {f}: {', '.join(typo)}")

print("\n=== пустые секции (заголовок сразу за заголовком) ===")
for f, ts, nst, nr, mr, slop, stops, typo, empty_sec in rows:
    if empty_sec:
        print(f"  {f}: {len(empty_sec)}  ({', '.join(empty_sec[:3])})")
