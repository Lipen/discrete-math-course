// Диаграммы лекции по теории категорий: петли, пути, функторы, универсальные свойства.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

#let obj-stroke = (paint: cool, thickness: 1.1pt)
#let derived-stroke = (paint: ink-soft, thickness: 0.9pt, dash: "dashed")

#let arrow(fr, to, lab, stroke: edge-plain, side: auto, pos: none, ..extra) = {
  let opts = (label: lab, label-side: side, label-size: 0.8em, stroke: stroke)
  if pos != none { opts.insert("label-pos", pos) }
  edge(fr, to, "->", ..opts, ..extra)
}

// ── Моноид как категория с одним объектом: элементы --- петли ──
#let monoid-loops = canvas({
  draw.arc(
    (-0.9, 0),
    start: 30deg,
    stop: 330deg,
    radius: 0.9,
    stroke: edge-hot,
    mark: (end: "stealth"),
  )
  draw.arc(
    (0.9, 0),
    start: 210deg,
    stop: 510deg,
    radius: 0.9,
    stroke: edge-hot,
    mark: (end: "stealth"),
  )
  draw.circle((0, 0), radius: 0.42, stroke: obj-stroke, fill: white, name: "m")
  mark((0, 0), $M$, size: 1em)
  mark((-1.95, 0), $a$, size: 0.8em)
  mark((1.95, 0), $a star a$, size: 0.8em)
  mark((0, -1.1), $"id"_M = e$, tone: ink-soft, size: 0.8em)
})

// ── Цепочка как тонкая категория: композиция даёт пунктирную стрелку ──
#let poset-chain = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3.2em,
  {
    node((0, 3.2), $0$, name: <z>)
    node((0, 1.6), $1$, name: <o>)
    node((0, 0), $2$, name: <t>)
    arrow(<z>, <o>, $<=$, stroke: edge-cool, side: left)
    arrow(<o>, <t>, $<=$, stroke: edge-cool, side: left)
    edge(
      <z>,
      <t>,
      "->",
      bend: -28deg,
      label: [$<=$],
      label-side: right,
      label-size: 0.8em,
      stroke: derived-stroke,
    )
  },
)

// ── Свободная категория графа: композиция рождает новый морфизм ──
#let free-cat-paths = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3.6em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.7, 0), $B$, name: <b>)
    node((3.4, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$)
    arrow(<b>, <c>, $g$)
    arrow(
      <a>,
      <c>,
      $g circle.stroked.tiny f$,
      stroke: edge-cool,
      pos: 0.5,
      bend: -22deg,
    )
  },
)

// ── Булеан: основы --- круги, множества подмножеств --- прямоугольники ──
#let powerset-functor = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3.6em,
  {
    node((0, 0), $A$, name: <a>, shape: circle, width: 1.5em, height: 1.5em)
    node((2, 0), $B$, name: <b>, shape: circle, width: 1.5em, height: 1.5em)
    node((0, 2), $cal(P)(A)$, name: <pa>)
    node((2, 2), $cal(P)(B)$, name: <pb>)
    arrow(<a>, <b>, $f$, pos: 0.45)
    arrow(<pa>, <pb>, $"img"_f$, stroke: derived-stroke, pos: 0.45, bend: 18deg)
    arrow(
      <pb>,
      <pa>,
      $f^(-1)$,
      stroke: edge-hot,
      pos: 0.45,
      side: right,
      bend: 18deg,
    )
  },
)

// ── Квадрат естественности: альфа --- семейство стрелок ──
#let nat-square = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3.6em,
  {
    node((0, 0), $F(A)$, name: <fa>)
    node((2.3, 0), $F(B)$, name: <fb>)
    node((0, 2), $G(A)$, name: <ga>)
    node((2.3, 2), $G(B)$, name: <gb>)
    arrow(<fa>, <fb>, $F(f)$, pos: 0.4)
    arrow(<ga>, <gb>, $G(f)$, pos: 0.4)
    arrow(<fa>, <ga>, $alpha_A$, stroke: edge-cool, side: left)
    arrow(<fb>, <gb>, $alpha_B$, stroke: edge-cool, side: right)
  },
)

// ── Универсальное свойство произведения: единственная стрелка через пару ──
#let product-universal = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3.4em,
  {
    node((1.5, 0), $A times B$, name: <ab>)
    node((0, 1.9), $A$, name: <a>)
    node((3, 1.9), $B$, name: <b>)
    node((-2.3, 0), $X$, name: <x>)
    arrow(<ab>, <a>, $pi_1$, side: left)
    arrow(<ab>, <b>, $pi_2$, side: right)
    arrow(<x>, <a>, $f$, stroke: derived-stroke, pos: 0.5)
    arrow(<x>, <b>, $g$, stroke: derived-stroke, pos: 0.5)
    arrow(<x>, <ab>, $chevron.l f, g chevron.r^!$, stroke: edge-cool, pos: 0.5)
  },
)

// ── Конус и предел: зелёный предел пропускает любой конус ──
#let cone-limit = diagram(
  node-stroke: obj-stroke,
  node-fill: white,
  spacing: 3em,
  {
    node((2.7, 0.9), $A$, name: <a>)
    node((4.4, 0.9), $B$, name: <b>)
    node((3.55, -0.6), $C$, name: <c>)
    arrow(<a>, <c>, $u$)
    arrow(<b>, <c>, $v$)
    node((2.7, 3.1), $N$, name: <n>, stroke: derived-stroke)
    edge(<n>, <a>, "->", stroke: derived-stroke)
    edge(<n>, <b>, "->", stroke: derived-stroke)
    edge(<n>, <c>, "->", stroke: derived-stroke)
    node((0, 3.1), $lim D$, name: <l>, stroke: (paint: green, thickness: 1.4pt))
    edge(<l>, <a>, "->", stroke: edge-green)
    edge(<l>, <b>, "->", stroke: edge-green)
    edge(<l>, <c>, "->", stroke: edge-green)
    edge(
      <n>,
      <l>,
      "-|>",
      label: [$!$],
      label-size: 0.8em,
      stroke: derived-stroke,
    )
  },
)

// ── Сопряжение: биекция гомов-множеств между двумя категориями ──
#let adjunction-bijection = diagram(
  spacing: 3em,
  {
    node(
      (0, 0),
      $cal(C)$,
      name: <cc>,
      shape: rect,
      width: 8em,
      height: 6.5em,
      fill: panel-cool,
      stroke: (paint: cool.lighten(30%), thickness: 0.7pt),
    )
    node(
      (5.2, 0),
      $cal(D)$,
      name: <dd>,
      shape: rect,
      width: 8em,
      height: 6.5em,
      fill: panel-green,
      stroke: (paint: green.lighten(30%), thickness: 0.7pt),
    )

    edge(
      (name: "cc", anchor: "north"),
      (name: "dd", anchor: "north"),
      "->",
      label: [$F$],
      label-size: 0.8em,
      stroke: edge-plain,
    )
    edge(
      (name: "dd", anchor: "south"),
      (name: "cc", anchor: "south"),
      "->",
      label: [$G$],
      label-size: 0.8em,
      stroke: edge-plain,
    )

    node((2.8, 0.55), $F(X) -> Y$, name: <fy>, stroke: none, fill: none)
    node((2.8, -0.55), $X -> G(Y)$, name: <xg>, stroke: none, fill: none)
    edge(
      <fy>,
      <xg>,
      "<->",
      label: [биекция],
      label-size: 0.7em,
      stroke: edge-hot,
    )
  },
)
