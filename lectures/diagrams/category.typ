// Category theory: loops, paths, functors, universal properties.
// Скопировано из книги и адаптировано под слайды, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-ink = oklch(27%, 0.02, 260deg)
#let c-edge = oklch(40%, 0.02, 265deg)
#let c-bd = oklch(56%, 0.07, 250deg)
#let c-fl = oklch(91%, 0.03, 250deg)
#let c-accent = oklch(55%, 0.16, 230deg)
#let c-hot = oklch(56%, 0.20, 22deg)
#let c-muted = luma(45%)

#let e-stroke = (paint: c-edge, thickness: 0.9pt)
#let d-stroke = (paint: c-edge, thickness: 0.9pt, dash: "dashed")
#let hi-stroke = (paint: c-accent, thickness: 1.4pt)
#let n-stroke = c-bd + 0.9pt

#let arrow(fr, to, lab, stroke: e-stroke, side: auto, pos: none, ..extra) = {
  let opts = (label: lab, label-side: side, label-size: 0.8em, stroke: stroke)
  if pos != none { opts.insert("label-pos", pos) }
  edge(fr, to, "-}>", ..opts, ..extra)
}

// ── Моноид как категория с одним объектом ──
#let monoid-loops = canvas({
  // Петли-лассо: окружности, касающиеся объекта, рисуются до него.
  draw.arc(
    (-0.85, 0),
    start: 30deg,
    stop: 330deg,
    radius: 0.85,
    stroke: e-stroke,
    mark: (end: ">"),
  )
  draw.arc(
    (0.85, 0),
    start: 210deg,
    stop: 510deg,
    radius: 0.85,
    stroke: e-stroke,
    mark: (end: ">"),
  )
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "m")
  draw.content("m", text(size: 1.1em, fill: c-ink)[$M$])
  draw.content((-1.9, 0), text(size: 0.8em, fill: c-ink)[$a$])
  draw.content((1.9, 0), text(size: 0.8em, fill: c-ink)[$a star a$])
  draw.content((0, -1.0), text(size: 0.8em, fill: c-muted)[$"id"_M = e$])
})

// ── Цепочка как тонкая категория ──
#let poset-chain = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, 3.2), $0$, name: <z>)
    node((0, 1.6), $1$, name: <o>)
    node((0, 0), $2$, name: <t>)
    arrow(<z>, <o>, $<=$, side: left)
    arrow(<o>, <t>, $<=$, side: left)
    edge(
      <z>,
      <t>,
      "-}>",
      bend: -28deg,
      label: [$<=$],
      label-side: right,
      label-size: 0.8em,
      stroke: d-stroke,
    )
  },
)

// ── Свободная категория графа ──
#let free-cat-paths = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
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
      stroke: hi-stroke,
      pos: 0.5,
      bend: -22deg,
    )
  },
)

// ── Булеан: образ и прообраз ──
#let powerset-functor = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, 0), $A$, name: <a>)
    node((2, 0), $B$, name: <b>)
    node((0, 2), $cal(P)(A)$, name: <pa>)
    node((2, 2), $cal(P)(B)$, name: <pb>)
    arrow(<a>, <b>, $f$, pos: 0.45)
    arrow(<pa>, <pb>, $"img"_f$, stroke: d-stroke, pos: 0.45, bend: 18deg)
    arrow(
      <pb>,
      <pa>,
      $f^(-1)$,
      stroke: (paint: c-hot, thickness: 1.4pt),
      pos: 0.45,
      side: right,
      bend: 18deg,
    )
  },
)

// ── Квадрат естественности ──
#let nat-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, 0), $F(A)$, name: <fa>)
    node((2.3, 0), $F(B)$, name: <fb>)
    node((0, 2), $G(A)$, name: <ga>)
    node((2.3, 2), $G(B)$, name: <gb>)
    arrow(<fa>, <fb>, $F(f)$, pos: 0.4)
    arrow(<ga>, <gb>, $G(f)$, pos: 0.4)
    arrow(<fa>, <ga>, $alpha_A$, side: left)
    arrow(<fb>, <gb>, $alpha_B$, side: right)
  },
)

// ── Универсальное свойство произведения ──
#let product-universal = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((1.5, 0), $A times B$, name: <ab>)
    node((0, 1.9), $A$, name: <a>)
    node((3, 1.9), $B$, name: <b>)
    node((-2.3, 0), $X$, name: <x>)
    arrow(<ab>, <a>, $pi_1$, side: left)
    arrow(<ab>, <b>, $pi_2$, side: right)
    arrow(<x>, <a>, $f$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <b>, $g$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <ab>, $chevron.l f, g chevron.r^!$, stroke: hi-stroke, pos: 0.5)
  },
)

// ── Конус и предел ──
#let cone-limit = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,
  {
    node((2.7, 0.9), $A$, name: <a>)
    node((4.4, 0.9), $B$, name: <b>)
    node((3.55, -0.6), $C$, name: <c>)
    arrow(<a>, <c>, $u$)
    arrow(<b>, <c>, $v$)
    node((2.7, 3.1), $N$, name: <n>, stroke: (
      paint: c-muted,
      thickness: 0.9pt,
      dash: "dashed",
    ))
    edge(<n>, <a>, "-}>", stroke: d-stroke)
    edge(<n>, <b>, "-}>", stroke: d-stroke)
    edge(<n>, <c>, "-}>", stroke: d-stroke)
    node((0, 3.1), $lim D$, name: <l>, stroke: hi-stroke)
    edge(<l>, <a>, "-}>", stroke: hi-stroke)
    edge(<l>, <b>, "-}>", stroke: hi-stroke)
    edge(<l>, <c>, "-}>", stroke: hi-stroke)
    edge(<n>, <l>, "-|>", label: [$!$], label-size: 0.8em, stroke: (
      paint: c-muted,
      thickness: 0.5pt,
      dash: "dashed",
    ))
  },
)

// ── Сопряжение: биекция стрелок ──
#let adjunction-bijection = diagram(
  node-stroke: n-stroke,
  node-fill: none,
  spacing: 3em,
  {
    node((0, 0), $cal(C)$, name: <cc>, shape: rect, width: 8em, height: 6.5em)
    node((5.2, 0), $cal(D)$, name: <dd>, shape: rect, width: 8em, height: 6.5em)

    // F и G --- рёбра из якорей вершин.
    edge(
      (name: "cc", anchor: "north"),
      (name: "dd", anchor: "north"),
      "-|>",
      label: [$F$],
      label-size: 0.8em,
      stroke: e-stroke,
    )
    edge(
      (name: "dd", anchor: "south"),
      (name: "cc", anchor: "south"),
      "-|>",
      label: [$G$],
      label-size: 0.8em,
      stroke: e-stroke,
    )

    // Два множества стрелок --- безрамные вершины, биекция --- ребро между ними.
    node((2.8, 0.55), $F(X) -> Y$, name: <fy>, stroke: none, fill: none)
    node((2.8, -0.55), $X -> G(Y)$, name: <xg>, stroke: none, fill: none)
    edge(<fy>, <xg>, "-|>-|-|>", label: [биекция], label-size: 0.7em, stroke: (
      paint: c-muted,
      thickness: 0.5pt,
      dash: "dashed",
    ))
  },
)
