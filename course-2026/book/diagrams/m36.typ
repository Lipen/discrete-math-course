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
    arrow(<a>, <c>, $g circle.stroked.tiny f$, stroke: hi-stroke, pos: 0.5)
  },
)

// ── Моноид как категория с одним объектом ──
#let monoid-one-object = canvas({
  // Две концентрические петли над единственным объектом.
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "m")
  draw.content("m", text(size: s-node, fill: c-ink)[$M$])
  draw.arc(
    "m",
    start: 25deg,
    stop: 155deg,
    radius: 0.8,
    stroke: e-stroke,
    mark: (end: ">"),
    name: "loop-a",
  )
  draw.content((0, 1.35), text(size: s-cap, fill: c-ink)[$a$])
  draw.arc(
    "m",
    start: 35deg,
    stop: 145deg,
    radius: 1.6,
    stroke: e-stroke,
    mark: (end: ">"),
    name: "loop-aa",
  )
  draw.content((0, 2.15), text(size: s-cap, fill: c-ink)[$a star a$])
  draw.content((0, -0.85), text(size: s-cap, fill: c-muted)[$"id"_M = e$])
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
    arrow(<a>, <c>, $g circle.stroked.tiny f$, stroke: hi-stroke, pos: 0.5)
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
#let adjunction-bijection = canvas({
  let box(x, y, w, h, name, body) = {
    draw.rect(
      (x - w / 2, y - h / 2),
      (x + w / 2, y + h / 2),
      name: name,
      radius: 5pt,
      stroke: c-bd + t-bd,
      fill: none,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  // Категория C слева, D справа; F туда, G обратно.
  box(0, 1.2, 1.6, 2.6, "cc", $cal(C)$)
  box(5.6, 1.2, 1.6, 2.6, "dd", $cal(D)$)

  draw.line(
    (0.05, 3.1),
    (5.55, 3.1),
    stroke: e-stroke,
    mark: (end: ">"),
    name: "farr",
  )
  draw.content("farr", text(size: s-cap, fill: c-ink)[$F$], anchor: "south")
  draw.line(
    (5.55, -0.7),
    (0.05, -0.7),
    stroke: e-stroke,
    mark: (end: ">"),
    name: "garr",
  )
  draw.content("garr", text(size: s-cap, fill: c-ink)[$G$], anchor: "north")

  // Два множества стрелок --- по строке на каждый элемент.
  draw.content(
    (3.3, 2.0),
    text(size: s-cap, fill: c-hot)[$F(X) -> Y$],
    anchor: "south",
    name: "top1",
  )
  draw.content(
    (3.3, 0.4),
    text(size: s-cap, fill: c-hot)[$X -> G(Y)$],
    anchor: "south",
    name: "top2",
  )

  // Биекция --- вертикальное пунктирное соответствие.
  draw.line(
    (3.3, 0.62),
    (3.3, 1.86),
    stroke: (paint: c-muted, thickness: t-hr, dash: "dashed"),
    mark: (end: ">", begin: ">"),
    name: "bij",
  )
  draw.content(
    "bij",
    text(size: s-tiny, fill: c-muted)[биекция],
    anchor: "west",
  )
})

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
  let wire(fr, to, lab: none) = {
    draw.line(fr, to, stroke: e-stroke, name: if lab != none {
      fr + "-" + to
    } else { none })
  }

  // m : A ⊗ B -> C, затем n : C ⊗ D -> E. Провода идут снизу вверх.
  op(1.4, 0, "m", $m$)
  op(1.4, 2.4, "n", $n$)
  wire((-0.2, -1), (0.85, -0.28))
  wire((1.4, -1), (1.95, -0.28))
  wire((1.4, 0.28), (0.85, 2.12))
  wire((3.0, -1), (1.95, 2.12))
  wire((1.4, 2.68), (1.4, 3.6))

  draw.content((-0.2, -1.35), text(size: s-cap, fill: c-muted)[$A$])
  draw.content((1.4, -1.35), text(size: s-cap, fill: c-muted)[$B$])
  draw.content((3.0, -1.35), text(size: s-cap, fill: c-muted)[$D$])
  draw.content((1.4, 3.9), text(size: s-cap, fill: c-muted)[$E$])
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
