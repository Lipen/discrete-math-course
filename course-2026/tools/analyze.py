#!/usr/bin/env -S uv run --script
"""Проза vs блоки по главам книги.

Правило: проза и заголовки/блоки живут в столбце 0; тела блоков с отступом.
Робастно к `[` `]` в math (не считаем скобки вообще).
"""
import glob

BLOCKS = ['#definition', '#theorem', '#lemma', '#corollary', '#proposition', '#proof',
          '#example', '#remark', '#raven', '#note', '#history-note', '#chapter-overview',
          '#algorithm', '#proof-sketch']


def kind_col0(s):
    """Класс строки в столбце 0."""
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


rows = []
for f in sorted(glob.glob('m[0-9][0-9]-*.typ')):
    lines = open(f, encoding='utf-8').read().splitlines()
    blocks = 0
    prose = 0
    h2 = 0
    types = {}
    runs = []          # пробеги подряд идущих блоков без прозы (в столбце 0)
    run = 0
    cur = None         # ('h2', title) | ('sec', blocks, prose) для секционного профиля
    sections = []
    for ln in lines:
        if ln[:1].isspace():
            continue          # тело блока/всё с отступом игнорируем
        s = ln.strip()
        if not s:
            continue
        k = kind_col0(s)
        if k == 'header':
            if run >= 2:
                runs.append(run)
            run = 0
            if s.startswith('=='):
                h2 += 1
                if cur:
                    sections.append(cur)
                cur = {'title': s.lstrip('=').strip()[:48], 'blocks': 0, 'prose': 0}
        elif k == 'block':
            run += 1
            blocks += 1
            name = s.split('[', 1)[0][1:]
            types[name] = types.get(name, 0) + 1
            if cur:
                cur['blocks'] += 1
        elif k == 'prose':
            if run >= 2:
                runs.append(run)
            run = 0
            prose += 1
            if cur:
                cur['prose'] += 1
        else:
            # close/code: не разрывают пробег блоков
            pass
    if run >= 2:
        runs.append(run)
    if cur:
        sections.append(cur)
    rows.append((f, blocks, prose, h2, runs, types, sections))

rows.sort(key=lambda r: r[2] / max(r[1], 1))
print(f"{'file':28} {'blocks':>6} {'prose':>5} {'h2':>3} {'runs>=2':>7} {'maxrun':>6}  (проза — строки вне блоков в столбце 0)")
for f, blocks, prose, h2, runs, types, sections in rows:
    mr = max(runs) if runs else 0
    print(f"{f:28} {blocks:>6} {prose:>5} {h2:>3} {len(runs):>7} {mr:>6}")

print("\n=== Секции (==) с блоками, но почти без прозы (<=3 строк) ===")
for f, blocks, prose, h2, runs, types, sections in rows:
    for sec in sections:
        if sec['blocks'] >= 2 and sec['prose'] <= 3:
            print(f"  {f} :: {sec['title']:48} blocks={sec['blocks']} prose={sec['prose']}")
