// Деревья разбора пропозициональных формул.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let pnode(pos, body, tone: ink) = mark(pos, body, tone: tone)

#let plink(from, to) = draw.line(from, to, stroke: edge-plain)

// ── Дерево разбора $((not p) and q) -> r$ ──
// Связки тёплые, атомы холодные: структура читается по уровням сверху вниз.
#let parse-tree-prop = canvas({
  plink((0.45, 3.05), (-1.25, 2.45))
  plink((0.45, 3.05), (2.15, 2.45))
  plink((-1.25, 2.1), (-2.2, 1.55))
  plink((-1.25, 2.1), (-0.3, 1.55))
  plink((-2.2, 1.2), (-2.2, 0.65))

  pnode((0.45, 3.2), $->$, tone: warm)
  pnode((-1.25, 2.25), $and$, tone: warm)
  pnode((2.15, 2.25), $r$, tone: cool)
  pnode((-2.2, 1.35), $not$, tone: warm)
  pnode((-0.3, 1.35), $q$, tone: cool)
  pnode((-2.2, 0.45), $p$, tone: cool)
})
