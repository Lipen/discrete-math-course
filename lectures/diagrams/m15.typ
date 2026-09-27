// Диаграммы лекции SMT: архитектура DPLL(T), отрицательный цикл в разностной логике.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── DPLL(T): SAT-солвер и theory-солвер ──
#let dpll-t-architecture = canvas({
  panel((-1.5, 0.22), (1.5, 1.18), tone: cool)
  panel((-1.5, -1.18), (1.5, -0.22), tone: green, fill: panel-green)
  mark((0, 0.86), text(weight: "bold")[SAT-решатель])
  mark((0, 0.5), [DPLL / CDCL], tone: ink-soft)
  mark((0, -0.5), text(weight: "bold")[Theory-солвер])
  mark((0, -0.86), [DL, EUF, LRA, ...], tone: ink-soft)

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
  mark((1.9, 0), [модель])
  mark((-1.9, 0), [$T$-лемма])
})

// ── Отрицательный цикл: ребро v -> u для u - v <= c ──
#let dl-negative-cycle = canvas({
  let px = (-0.9, 0.55)
  let pz = (0.9, 0.55)
  let pw = (0, -0.7)
  vertex("x", px, size: 0.24)
  vertex("z", pz, size: 0.24)
  vertex("w", pw, size: 0.24)
  mark(px, $x$)
  mark(pz, $z$)
  mark(pw, $w$)

  draw.line("x", "w", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("w", "z", mark: (end: "stealth"), stroke: edge-hot)
  draw.line("z", "x", mark: (end: "stealth"), stroke: edge-hot)
  mark((-0.63, -0.2), $+2$)
  mark((0.63, -0.2), $-1$, tone: warm)
  mark((0, 0.86), $-3$, tone: warm)
})
