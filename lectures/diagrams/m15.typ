// Диаграммы лекции SMT: архитектура DPLL(T), отрицательный цикл в разностной логике.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── DPLL(T): SAT-солвер и theory-солвер ──
#let dpll-t-architecture = canvas({
  panel((-1.5, 0.22), (1.5, 1.18), tone: cool)
  panel((-1.5, -1.18), (1.5, -0.22), tone: green, fill: panel-green)
  mark((0, 0.86), text(weight: "bold")[SAT-решатель], size: 0.5em)
  mark((0, 0.5), [DPLL / CDCL], tone: ink-soft, size: 0.45em)
  mark((0, -0.5), text(weight: "bold")[Theory-солвер], size: 0.5em)
  mark((0, -0.86), [DL, EUF, LRA, ...], tone: ink-soft, size: 0.45em)

  draw.line(
    (0.85, 0.22),
    (0.85, -0.22),
    mark: (end: "stealth"),
    stroke: edge-plain,
  )
  draw.line(
    (-0.85, -0.22),
    (-0.85, 0.22),
    mark: (end: "stealth"),
    stroke: edge-plain,
  )
  mark((1.9, 0), [модель], size: 0.45em)
  mark((-1.9, 0), [$T$-лемма], size: 0.45em)
})

// ── Отрицательный цикл: ребро v -> u для u - v <= c ──
#let dl-negative-cycle = canvas({
  let px = (-0.9, 0.55)
  let pz = (0.9, 0.55)
  let pw = (0, -0.7)
  vertex("x", px, size: 0.24)
  vertex("z", pz, size: 0.24)
  vertex("w", pw, size: 0.24)
  mark(px, $x$, size: 0.45em)
  mark(pz, $z$, size: 0.45em)
  mark(pw, $w$, size: 0.45em)

  draw.line("x", "w", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("w", "z", mark: (end: "stealth"), stroke: edge-hot)
  draw.line("z", "x", mark: (end: "stealth"), stroke: edge-hot)
  mark((-0.63, -0.2), $+2$, size: 0.45em)
  mark((0.63, -0.2), $-1$, size: 0.45em, tone: warm)
  mark((0, 0.86), $-3$, size: 0.45em, tone: warm)
})
