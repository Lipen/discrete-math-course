// Диаграмма лекций по модальной логике и верификации: дерево вычислений CTL.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── CTL: дерево вычислений; цветом выделен один путь --- ветвь квантора E ──
#let ctl-tree = canvas({
  let states = (
    ("s0", (0, 1.92), $s_0$, cool),
    ("s1", (-1.2, 0.72), $s_1$, cool),
    ("s2", (1.2, 0.72), $s_2$, ink-soft),
    ("s3", (-1.84, -0.48), $s_3$, cool),
    ("s4", (-0.56, -0.48), $s_4$, ink-soft),
    ("s5", (0.56, -0.48), $s_5$, ink-soft),
    ("s6", (1.84, -0.48), $s_6$, ink-soft),
  )
  for (nm, p, lab, tn) in states {
    vertex(nm, p, tone: tn, size: 0.4)
    mark(p, lab)
  }

  draw.line("s0", "s1", mark: (end: "stealth"), stroke: edge-cool)
  draw.line("s1", "s3", mark: (end: "stealth"), stroke: edge-cool)
  draw.line("s0", "s2", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s1", "s4", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s2", "s5", mark: (end: "stealth"), stroke: edge-plain)
  draw.line("s2", "s6", mark: (end: "stealth"), stroke: edge-plain)

  mark((-1.84, -1.3), $p$)
  mark((-0.56, -1.3), $q$)
  mark((1.84, -1.3), $p$)
})
