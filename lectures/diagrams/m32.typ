// Диаграмма лекций по модальной логике и верификации: дерево вычислений CTL.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── CTL: дерево вычислений; цветом выделен один путь --- ветвь квантора E ──
#let ctl-tree = canvas({
  let states = (
    ("s0", (0, 1.2), $s_0$),
    ("s1", (-0.75, 0.45), $s_1$),
    ("s2", (0.75, 0.45), $s_2$),
    ("s3", (-1.15, -0.3), $s_3$),
    ("s4", (-0.35, -0.3), $s_4$),
    ("s5", (0.35, -0.3), $s_5$),
    ("s6", (1.15, -0.3), $s_6$),
  )
  for (nm, p, lab) in states {
    vertex(nm, p, size: 0.24)
    mark(p, lab, size: 0.45em)
  }

  draw.line("s0", "s1", mark: (end: "stealth"), stroke: edge-cool)
  draw.line("s1", "s3", mark: (end: "stealth"), stroke: edge-cool)
  draw.line("s0", "s2", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s1", "s4", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s2", "s5", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s2", "s6", mark: (end: "stealth"), stroke: edge-plain)

  mark((-1.15, -0.62), $p$, size: 0.45em)
  mark((-0.35, -0.62), $q$, size: 0.45em)
  mark((1.15, -0.62), $p$, size: 0.45em)
})
