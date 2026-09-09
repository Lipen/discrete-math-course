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
