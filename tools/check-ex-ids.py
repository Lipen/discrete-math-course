#!/usr/bin/env python3
"""Валидатор меток упражнений книги (book/m*.typ + book/hints.typ).

Проверяет:
1. Каждая метка #task-id("mNN:tK") стоит на пункте с порядковым номером K
   (сквозная нумерация верхнеуровневых `+ ` внутри #tasklist).
2. Префикс mNN совпадает с файлом.
3. Каждый #ex-ref("mNN:tK") в hints.typ указывает на существующую метку.

Запуск: python3 tools/check-ex-ids.py  (из корня репозитория)
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK = ROOT / "book"
TASK_ID = re.compile(r'#task-id\("([^"]+)"\)')
EX_REF = re.compile(r'#ex-ref\("([^"]+)"\)')
ITEM = re.compile(r"^  \+ ")

errs = []
ids = {}

for f in sorted(BOOK.glob("chapters/m*.typ")):
    chap = f.name[:3]
    lines = f.read_text(encoding="utf-8").split("\n")
    src = "".join(lines)
    start = next((i for i, ln in enumerate(lines) if "#tasklist(" in ln), None)
    if start is None:
        if TASK_ID.search(src):
            errs.append(f"{f.name}: метки вне #tasklist")
        continue
    n = 0
    for ln in lines[start:]:
        if re.match(r"^\]$", ln.strip()) and ln.startswith("]"):
            break
        if not ITEM.match(ln):
            continue
        n += 1
        for mid in TASK_ID.findall(ln):
            ids[mid] = f.name
            nn, _, k = mid.partition(":t")
            if nn != chap:
                errs.append(f"{f.name}: метка {mid} с чужим префиксом ({chap})")
            if not k.isdigit() or int(k) != n:
                errs.append(f"{f.name}: метка {mid} на пункте #{n}")

hints = (BOOK / "hints.typ").read_text(encoding="utf-8")
for ref in EX_REF.findall(hints):
    if ref not in ids:
        errs.append(f"hints.typ: ex-ref({ref!r}) --- метки не существует")

print(f"меток: {len(ids)}  глав с метками: {len({v[:3] for v in ids.values()})}")
if errs:
    print(f"ОШИБКИ ({len(errs)}):")
    for e in errs[:30]:
        print("  -", e)
    sys.exit(1)
print("Метки и ссылки согласованы.")
