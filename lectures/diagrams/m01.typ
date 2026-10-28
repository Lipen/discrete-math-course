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

// ── Одна строка, два разбора: $p and q or r$ без соглашений о приоритетах ──
#let ambiguous-trees = canvas({
  let left-tree(x) = {
    plink((x, 2.45), (x - 0.95, 1.85))
    plink((x, 2.45), (x + 0.95, 1.85))
    plink((x - 0.95, 1.5), (x - 1.55, 0.95))
    plink((x - 0.95, 1.5), (x - 0.35, 0.95))
    pnode((x, 2.6), $or$, tone: warm)
    pnode((x - 0.95, 1.65), $and$, tone: warm)
    pnode((x + 0.95, 1.65), $r$, tone: cool)
    pnode((x - 1.55, 0.75), $p$, tone: cool)
    pnode((x - 0.35, 0.75), $q$, tone: cool)
    mark((x, -0.1), $(p and q) or r$)
  }
  let right-tree(x) = {
    plink((x, 2.45), (x - 0.95, 1.85))
    plink((x, 2.45), (x + 0.95, 1.85))
    plink((x + 0.95, 1.5), (x + 0.35, 0.95))
    plink((x + 0.95, 1.5), (x + 1.55, 0.95))
    pnode((x, 2.6), $and$, tone: warm)
    pnode((x - 0.95, 1.65), $p$, tone: cool)
    pnode((x + 0.95, 1.65), $or$, tone: warm)
    pnode((x + 0.35, 0.75), $q$, tone: cool)
    pnode((x + 1.55, 0.75), $r$, tone: cool)
    mark((x, -0.1), $p and (q or r)$)
  }

  left-tree(0)
  right-tree(4.6)
})
