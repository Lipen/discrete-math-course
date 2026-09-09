#!/usr/bin/env python3
"""Валидатор меток упражнений книги (book/chapters/*.typ + book/hints.typ).

Контракт: каждый размеченный exercise несёт стабильный уникальный id
`ns:slug` (namespace совпадает с ключом счётчика #tasklist). Позиция
в списке в id не кодируется --- порядок можно менять свободно.

Проверяет:
1. Все id уникальны в документе. #ex-ref ищет метку через query().find(),
   который возвращает ПЕРВОЕ совпадение: дубликат id делает ссылки второй
   задачи молчаливыми указателями на первую (без красного ??).
2. Каждая #ex-ref в hints.typ разрешается в существующую метку.


Таблица глава -> namespace (по темам банка private/problems/bank; банк внутри
одной темы может вести несколько префиксов --- делим по гранулярности глав):
  m01 lang    m02 ded     m03 lang    m04 set     m05 rel     m06 fun
  m07 card    m08 ord     m09 graphs  m10 bool    m11 circ    m12 alg
  m13 code    m14 sat     m15 smt     m16 lp      m17 mat     m18 comb
  m19 nt      m20 prob    m21 gf      m22 con     m23 aut     m24 cfg
  m25 turing  m26 turing  m27 lam     m28 ty      m29 nonstd  m30 comp
  m31 ai      m32 verif   m33 mod     m34 int     m35 fuzzy   m36 cat
Особые случаи: m03 -> lang (тема language покрывает m01, m03-m06); m25/m26
делят turing; m36 -> cat --- в банке темы categories нет, префикс введён
нами. Задача, дословно совпадающая с банковской, несёт её id без изменений.

Запуск: python3 tools/check-ex-ids.py  (из корня репозитория)
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "book"
TASK_ID = re.compile(r'#task-id\("([^"]+)"\)')
EX_REF = re.compile(r'#ex-ref\("([^"]+)"\)')

errs = []
ids = {}

for f in sorted(BOOK.glob("chapters/m*.typ")):
    src = f.read_text(encoding="utf-8")
    for mid in TASK_ID.findall(src):
        if mid in ids:
            errs.append(f"{f.name}: дубликат метки {mid} (уже в {ids[mid]})")
        else:
            ids[mid] = f.name

hints = (BOOK / "hints.typ").read_text(encoding="utf-8")
for ref in EX_REF.findall(hints):
    if ref not in ids:
        errs.append(f"hints.typ: ex-ref({ref!r}) --- метки не существует")

print(f"меток: {len(ids)}  глав с метками: {len(set(ids.values()))}")
if errs:
    print(f"ОШИБКИ ({len(errs)}):")
    for e in errs[:30]:
        print("  -", e)
    sys.exit(1)
print("Метки и ссылки согласованы.")
