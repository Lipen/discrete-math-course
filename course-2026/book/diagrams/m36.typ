#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let e-stroke = (paint: c-edge, thickness: t-ed)
#let d-stroke = (paint: c-edge, thickness: t-ed, dash: "dashed")
#let hi-stroke = (paint: c-accent, thickness: t-hi)
#let hot-stroke = (paint: c-hot, thickness: t-hi)
#let n-stroke = c-bd + t-bd

#let arrow(fr, to, lab, stroke: e-stroke, side: auto, pos: none, ..extra) = {
  let opts = (label: lab, label-side: side, label-size: s-cap, stroke: stroke)
  if pos != none { opts.insert("label-pos", pos) }
  edge(fr, to, "-}>", ..opts, ..extra)
}

// ── Коммутативный треугольник: композиция ──
#let assoc-triangle = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.6, 0), $B$, name: <b>)
    node((3.2, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$)
    arrow(<b>, <c>, $g$)
    arrow(<a>, <c>, $g circle.stroked.tiny f$, stroke: hi-stroke, pos: 0.5, bend: -22deg)
  },
)

// ── Моноид как категория с одним объектом ──
#let monoid-one-object = canvas({
  // Петли-лассо: окружности, касающиеся объекта, рисуются до него.
  draw.arc((-0.85, 0), start: 30deg, stop: 330deg, radius: 0.85, stroke: e-stroke, mark: (end: ">"))
  draw.arc((0.85, 0), start: 210deg, stop: 510deg, radius: 0.85, stroke: e-stroke, mark: (end: ">"))
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "m")
  draw.content("m", text(size: s-node, fill: c-ink)[$M$])
  draw.content((-1.9, 0), text(size: s-cap, fill: c-ink)[$a$])
  draw.content((1.9, 0), text(size: s-cap, fill: c-ink)[$a star a$])
  draw.content((0, -1.0), text(size: s-cap, fill: c-muted)[$"id"_M = e$])
})

// ── Чум как тонкая категория ──
#let poset-category = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 2.6em,
  {
    node((0, 0), $0$, name: <z>)
    node((0, 1.5), $1$, name: <o>)
    node((0, 3), $2$, name: <t>)
    arrow(<z>, <o>, $<=$)
    arrow(<o>, <t>, $<=$)
    edge(
      <z>,
      <t>,
      "-}>",
      label: [$<=$],
      label-side: left,
      label-size: s-cap,
      stroke: d-stroke,
    )
  },
)

// ── Свободная категория графа: морфизмы --- пути ──
#let free-category = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.6, 0), $B$, name: <b>)
    node((3.2, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$)
    arrow(<b>, <c>, $g$)
    arrow(<a>, <c>, $g circle.stroked.tiny f$, stroke: hi-stroke, pos: 0.5, bend: -22deg)
  },
)

// ── Булеан: образ и прообраз ──
#let image-inverse-image = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((0, 0), $A$, name: <a>)
    node((2, 0), $B$, name: <b>)
    node((0, 2), $cal(P)(A)$, name: <pa>)
    node((2, 2), $cal(P)(B)$, name: <pb>)
    arrow(<a>, <b>, $f$, pos: 0.45)
    arrow(<pa>, <pb>, $"img"_f$, stroke: d-stroke, pos: 0.45, bend: 18deg)
    arrow(<pb>, <pa>, $f^(-1)$, stroke: hot-stroke, pos: 0.45, side: right, bend: 18deg)
  },
)

// ── Квадрат естественности ──
#let nat-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((0, 0), $F(A)$, name: <fc>)
    node((2.2, 0), $F(B)$, name: <fd>)
    node((0, 2), $G(A)$, name: <gc>)
    node((2.2, 2), $G(B)$, name: <gd>)
    arrow(<fc>, <fd>, $F(f)$, pos: 0.4)
    arrow(<gc>, <gd>, $G(f)$, pos: 0.4)
    arrow(<fc>, <gc>, $alpha_A$, side: left)
    arrow(<fd>, <gd>, $alpha_B$, side: right)
  },
)

// ── Универсальное свойство произведения ──
#let product-universal = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((1.4, 0), $A times B$, name: <ab>)
    node((0, 1.8), $A$, name: <a>)
    node((2.8, 1.8), $B$, name: <b>)
    node((-2.2, 0), $X$, name: <x>)
    arrow(<ab>, <a>, $pi_1$, side: left)
    arrow(<ab>, <b>, $pi_2$, side: right)
    arrow(<x>, <a>, $f$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <b>, $g$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <ab>, $chevron.l f, g chevron.r^!$, stroke: hi-stroke, pos: 0.5)
  },
)

// ── Конус над диаграммой и терминальный конус ──
#let cone-diagram = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 2.8em,
  {
    node((2.6, 0.9), $A$, name: <a>)
    node((4.2, 0.9), $B$, name: <b>)
    node((3.4, -0.6), $C$, name: <c>)
    arrow(<a>, <c>, $u$)
    arrow(<b>, <c>, $v$)
    node((2.6, 3), $N$, name: <n>, stroke: (
      paint: c-muted,
      thickness: t-bd,
      dash: "dashed",
    ))
    edge(<n>, <a>, "-}>", stroke: d-stroke)
    edge(<n>, <b>, "-}>", stroke: d-stroke)
    edge(<n>, <c>, "-}>", stroke: d-stroke)
    node((0, 3), $lim D$, name: <l>, stroke: (paint: c-accent, thickness: t-hi))
    edge(<l>, <a>, "-}>", stroke: hi-stroke)
    edge(<l>, <b>, "-}>", stroke: hi-stroke)
    edge(<l>, <c>, "-}>", stroke: hi-stroke)
    edge(<n>, <l>, "-|>", label: [$!$], label-size: s-cap, stroke: (
      paint: c-muted,
      thickness: t-hr,
      dash: "dashed",
    ))
  },
)

// ── Сопряжение: биекция множеств стрелок ──
#let adjunction-bijection = diagram(
  node-stroke: n-stroke,
  node-fill: none,
  spacing: 3em,
  {
    node((0, 0), $cal(C)$, name: <cc>, shape: rect, width: 8em, height: 6.5em)
    node((5.2, 0), $cal(D)$, name: <dd>, shape: rect, width: 8em, height: 6.5em)

    // F и G --- рёбра из якорей вершин.
    edge((name: "cc", anchor: "north"), (name: "dd", anchor: "north"), "-|>", label: [$F$], label-size: s-cap, stroke: e-stroke)
    edge((name: "dd", anchor: "south"), (name: "cc", anchor: "south"), "-|>", label: [$G$], label-size: s-cap, stroke: e-stroke)

    // Два множества стрелок --- безрамные вершины, биекция --- ребро между ними.
    node((2.8, 0.55), $F(X) -> Y$, name: <fy>, stroke: none, fill: none)
    node((2.8, -0.55), $X -> G(Y)$, name: <xg>, stroke: none, fill: none)
    edge(<fy>, <xg>, "-|>-|-|>", label: [биекция], label-size: s-cap, stroke: (paint: c-muted, thickness: t-hr, dash: "dashed"))
  },
)

// ── Монада из сопряжения ──
#let monad-from-adjunction = canvas({
  // Эндофунктор T рисуется петлёй над категорией.
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "cc")
  draw.content("cc", text(size: s-node, fill: c-ink)[$cal(C)$])
  draw.arc(
    "cc", start: 30deg, stop: 150deg, radius: 1.1,
    stroke: e-stroke, mark: (end: ">"), name: "loop-t",
  )
  draw.content((0, 1.75), text(size: s-cap, fill: c-ink)[$T = G circle.stroked.tiny F$])
})

// ── Стринг-диаграмма: композиция проводков ──
#let string-diagram = canvas({
  let op(x, y, name, lab) = {
    draw.rect(
      (x - 0.55, y - 0.28),
      (x + 0.55, y + 0.28),
      name: name,
      radius: 3pt,
      stroke: c-bd + t-bd,
      fill: c-fl,
    )
    draw.content(name, text(size: s-cap, fill: c-ink)[#lab])
  }
  let wire(fr, to) = draw.line(fr, to, stroke: e-stroke)

  // m : A ⊗ B -> C, затем n : C ⊗ D -> E. Провода идут снизу вверх.
  op(1.4, 0, "m", $m$)
  op(1.4, 2.4, "n", $n$)

  // Свободные концы --- именованные точки, провода идут из якорей.
  draw.content((-0.2, -1.35), text(size: s-cap, fill: c-ink)[$A$], name: "wA")
  draw.content((1.4, -1.35), text(size: s-cap, fill: c-ink)[$B$], name: "wB")
  draw.content((3.0, -1.35), text(size: s-cap, fill: c-ink)[$D$], name: "wD")
  draw.content((1.4, 3.9), text(size: s-cap, fill: c-ink)[$E$], name: "wE")

  wire("wA.north", "m.south-west")
  wire("wB.north", "m.south-east")
  wire("m.north-west", "n.south-west")
  wire("wD.north", "n.south-east")
  wire("n.north", "wE.south")
  draw.content((0.72, 1.2), text(size: s-cap, fill: c-muted)[$C$])
})

// ── Начальная алгебра списка и катаморфизм ──
#let initial-algebra = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((-1.7, 0), $1 + A times "List"_A$, name: <fl>, fill: none)
    node((1.9, 0), $1 + A times X$, name: <fx>, fill: none)
    node((-1.7, 1.9), $"List"_A$, name: <lst>)
    node((1.9, 1.9), $X$, name: <x>)
    arrow(<fl>, <fx>, $F ("fold")$, pos: 0.5)
    arrow(<fl>, <lst>, $alpha$, side: left)
    arrow(<fx>, <x>, $beta$, side: right)
    arrow(<lst>, <x>, $"fold"$, stroke: hi-stroke, pos: 0.5)
  },
)
