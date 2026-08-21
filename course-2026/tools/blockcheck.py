#!/usr/bin/env python3
"""Check book blocks for wall-of-text: prose runs without paragraph breaks.

Rule (BOOK-STYLE.md): content blocks (#example, #project, #definition,
#remark, #proof, ...) MUST break prose into paragraphs (blank line between
thoughts), use lists (- / +), display math and tables where appropriate.

This checker flags a block when N (default 8) consecutive non-empty prose
lines appear with no blank line between them. Display math, lists, tables,
code fences and headings reset the run.

Usage:
  python3 tools/blockcheck.py [book/mNN.typ ...]   # default: book/m*.typ
Exit code 1 when violations found.
"""
import re
import sys
import glob

BLOCK_RE = re.compile(
    r'^#(example|project|definition|remark|check|whats-next|theorem|lemma|'
    r'proof|project-stage|project-outcome|chapter-overview|history-note|'
    r'outro|solution|problem|checkpoint)\b'
)
PROSE_RE = re.compile(r'^[_*]?[\w«"$]')
THRESHOLD = 8


def scan(path, threshold=THRESHOLD):
    lines = open(path, encoding='utf-8').read().split('\n')
    inblock = False
    depth = 0
    run = 0
    maxrun = 0
    blocks = []
    incode = False
    indisp = False
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('```'):
            incode = not incode
            continue
        if incode:
            continue
        if not inblock:
            m = BLOCK_RE.match(s)
            if m and '[' in l:
                inblock = True
                depth = 1
                run = 0
                blocks.append([m.group(1), i + 1, 0, 0])
            continue
        if s.startswith('$'):
            # display math line (bare $ or $...$ or $... multiline opener)
            indisp = s != '$' and not s.endswith('$') or s == '$'
            run = 0
            depth += s.count('[') - s.count(']')
            if depth <= 0:
                inblock = False
                blocks[-1][2] = i + 1
                blocks[-1][3] = maxrun
                maxrun = 0
            continue
        if indisp:
            if s.endswith('$') and s != '$':
                indisp = False
            run = 0
            depth += s.count('[') - s.count(']')
            if depth <= 0:
                inblock = False
                blocks[-1][2] = i + 1
                blocks[-1][3] = maxrun
                maxrun = 0
            continue
        seg = re.sub(r'\$[^$\n]*\$', '', l)
        depth += seg.count('[') - seg.count(']')
        if depth <= 0:
            inblock = False
            blocks[-1][2] = i + 1
            blocks[-1][3] = maxrun
            maxrun = 0
            continue
        if (s == ''
                or s.startswith('+ ')
                or s.startswith('- ')
                or s.startswith('#table')
                or s.startswith('==')
                or s.startswith('#')):
            run = 0
        elif PROSE_RE.match(s):
            run += 1
            if run > maxrun:
                maxrun = run
        else:
            run = 0
    return blocks


def main(argv):
    paths = argv[1:] or sorted(glob.glob('book/m*.typ'))
    total = 0
    for p in paths:
        blocks = scan(p)
        for name, start, end, mrun in blocks:
            if mrun > THRESHOLD:
                total += 1
                print(f'{p}:{start} [{name}] wall-of-text: {mrun} prose lines '
                      f'without blank line (threshold {THRESHOLD})')
    print(f'== blockcheck: {total} violation(s) in {len(paths)} file(s)')
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
