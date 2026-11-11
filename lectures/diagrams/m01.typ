#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let pnode(pos, body, tone: ink) = draw.content(
  pos,
  box(
    fill: white,
    outset: 4.5pt,
    radius: 1pt,
  )[#text(size: label-size, fill: tone)[#body]],
)

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

// ── Висячий else: два возможных разбора ──
#let else-node(pos, body, tone: cool, half: 0.78) = {
  draw.rect(
    (pos.at(0) - half, pos.at(1) - 0.3),
    (pos.at(0) + half, pos.at(1) + 0.3),
    radius: 0.08,
    fill: tone.lighten(90%),
    stroke: 1pt + tone,
  )
  draw.content(pos, text(font: "DejaVu Sans Mono", size: 0.8em)[#body])
}

#let else-leaf(pos, body, tone: green) = else-node(
  pos,
  body,
  tone: tone,
  half: 0.38,
)

#let else-mid(a, b) = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)

#let else-edge(
  a,
  b,
  label,
  tone: ink-soft,
  thickness: 0.9pt,
  dx: 0.0,
  dy: 0.02,
  anchor: "west",
) = {
  draw.line(a, b, stroke: (paint: tone, thickness: thickness))
  let m = else-mid(a, b)
  draw.content(
    (m.at(0) + dx, m.at(1) + dy),
    text(size: 0.8em, fill: tone)[#label],
    anchor: anchor,
    padding: 0.3,
  )
}

#let dangling-else-inner = canvas({
  let root = (0.85, 3.35)
  let inner = (0.45, 1.95)
  let x = (0.0, 0.75)
  let y = (0.9, 0.75)
  else-edge(root, inner, [then])
  else-edge(inner, x, [then], anchor: "east")
  else-edge(inner, y, [else], tone: warm, thickness: 2pt)
  else-node(root, [if a])
  else-node(inner, [if b])
  else-leaf(x, [x()], tone: ink-soft)
  else-leaf(y, [y()], tone: warm)
})

#let dangling-else-outer = canvas({
  let root = (0.85, 3.35)
  let inner = (0.1, 1.95)
  let x = (0.1, 0.75)
  let y = (1.8, 1.95)
  else-edge(root, inner, [then], anchor: "east")
  else-edge(root, y, [else], tone: warm, thickness: 2pt, dy: 0.05)
  else-edge(inner, x, [then])
  else-node(root, [if a])
  else-node(inner, [if b])
  else-leaf(x, [x()], tone: ink-soft)
  else-leaf(y, [y()], tone: warm)
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
