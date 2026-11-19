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
#let hr-dash = (paint: c-muted, thickness: t-hr, dash: "dashed")

#let arrow(fr, to, lab, stroke: e-stroke, side: auto, pos: none, ..extra) = {
  let opts = (label: lab, label-side: side, label-size: s-cap, stroke: stroke)
  if pos != none { opts.insert("label-pos", pos) }
  edge(fr, to, "-}>", ..opts, ..extra)
}

// ── Треугольник композиции: h = g ∘ f ──
#let composition-triangle = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.6, 0), $B$, name: <b>)
    node((3.2, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$)
    arrow(<b>, <c>, $g$)
    arrow(
      <a>,
      <c>,
      $h = g circle.stroked.tiny f$,
      stroke: hi-stroke,
      pos: 0.5,
      bend: -22deg,
    )
  },
)

// ── Ассоциативность: h ∘ (g ∘ f) = (h ∘ g) ∘ f ──
#let assoc-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((0, -2), $A$, name: <a>)
    node((2.6, -2), $B$, name: <b>)
    node((0, 0), $C$, name: <c>)
    node((2.6, 0), $D$, name: <d>)
    arrow(<a>, <b>, $f$, side: left)
    arrow(<b>, <d>, $h circle.stroked.tiny g$, side: right)
    arrow(<a>, <c>, $g circle.stroked.tiny f$, side: left)
    arrow(<c>, <d>, $h$, side: right)
  },
)

// ── Моноид как категория с одним объектом ──
#let monoid-one-object = canvas({
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
  draw.content("m", text(size: s-node, fill: c-ink)[$tilde(M)$])
  draw.content((-1.7, 0), text(size: s-cap, fill: c-ink)[$a$])
  draw.content((1.7, 0), text(size: s-cap, fill: c-ink)[$a star a$])
  draw.content((0, -1.0), text(size: s-cap, fill: c-muted)[$"id"_tilde(M) = e$])
})

// ── Чум как тонкая категория ──
#let poset-category = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 2.6em,
  {
    node((0, 3), $0$, name: <z>)
    node((0, 1.5), $1$, name: <o>)
    node((0, 0), $2$, name: <t>)
    arrow(<z>, <o>, $<=$, side: left)
    arrow(<o>, <t>, $<=$, side: left)
    arrow(<z>, <t>, $<=$, side: right, stroke: d-stroke, bend: -28deg)
  },
)

// ── Свободная категория графа: морфизмы --- пути ──
// Пунктир --- образующие рёбра графа, сплошная дуга --- новый путь-морфизм.
#let free-category = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.8, 0), $B$, name: <b>)
    node((3.6, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$, stroke: d-stroke)
    arrow(<b>, <c>, $g$, stroke: d-stroke)
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
    arrow(
      <pb>,
      <pa>,
      $f^(-1)$,
      stroke: hot-stroke,
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
    node((1.6, -1.0), $A times B$, name: <ab>)
    node((0, -2.4), $A$, name: <a>)
    node((3.2, -2.4), $B$, name: <b>)
    node((1.6, 0.8), $X$, name: <x>)
    arrow(<ab>, <a>, $pi_1$, side: left)
    arrow(<ab>, <b>, $pi_2$, side: right)
    arrow(<x>, <a>, $f$, stroke: d-stroke, side: left, pos: 0.55)
    arrow(<x>, <b>, $g$, stroke: d-stroke, side: right, pos: 0.55)
    arrow(<x>, <ab>, $chevron.l f, g chevron.r$, stroke: hi-stroke, side: right)
  },
)

// ── Универсальное свойство копроизведения ──
#let coproduct-universal = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((1.6, -1.0), $A + B$, name: <ab>)
    node((0, -2.4), $A$, name: <a>)
    node((3.2, -2.4), $B$, name: <b>)
    node((1.6, 0.8), $X$, name: <x>)
    arrow(<a>, <ab>, $iota_1$, side: left)
    arrow(<b>, <ab>, $iota_2$, side: right)
    arrow(<a>, <x>, $f$, stroke: d-stroke, side: left, pos: 0.55)
    arrow(<b>, <x>, $g$, stroke: d-stroke, side: right, pos: 0.55)
    arrow(<ab>, <x>, $[f, g]$, stroke: hi-stroke, side: left)
  },
)

// ── Конус над диаграммой и терминальный конус ──
#let cone-diagram = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((2.6, -0.9), $A$, name: <a>)
    node((4.2, -0.9), $B$, name: <b>)
    node((3.4, 0.6), $C$, name: <c>)
    arrow(
      <a>,
      <c>,
      $u$,
      side: right,
      pos: 0.2,
      label-sep: 8pt,
      label-anchor: "center",
      label-angle: 0deg,
    )
    arrow(<b>, <c>, $v$)
    node((2.6, -3), $N$, name: <n>, stroke: (
      paint: c-muted,
      thickness: t-bd,
      dash: "dashed",
    ))
    edge(<n>, <a>, "-}>", stroke: d-stroke)
    edge(<n>, <b>, "-}>", stroke: d-stroke)
    edge(<n>, <c>, "-}>", stroke: d-stroke)
    node((0, -3), $lim D$, name: <l>, stroke: hi-stroke)
    edge(<l>, <a>, "-}>", stroke: hi-stroke)
    edge(<l>, <b>, "-}>", stroke: hi-stroke)
    edge(<l>, <c>, "-}>", stroke: hi-stroke)
    edge(<n>, <l>, "-|>", label: [$!$], label-size: s-cap, stroke: hr-dash)
  },
)

// ── Уравнитель пары стрелок ──
#let equalizer-diagram = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, -2), $E$, name: <e>)
    node((2.8, -2), $A$, name: <a>)
    node((2.8, 0), $B$, name: <b>)
    node((0, 0), $X$, name: <x>, stroke: (
      paint: c-muted,
      thickness: t-bd,
      dash: "dashed",
    ))
    arrow(<e>, <a>, $e$)
    arrow(<a>, <b>, $f$, side: right, bend: 14deg, pos: 0.3)
    arrow(<a>, <b>, $g$, side: left, bend: -14deg, pos: 0.7)
    arrow(<x>, <a>, $h$, pos: 0.5)
    arrow(<x>, <e>, $u$, stroke: d-stroke, pos: 0.5)
  },
)

// ── Расслоенное произведение ──
#let pullback-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, -2), $P$, name: <p>)
    node((2.8, -2), $A$, name: <a>)
    node((0, 0), $B$, name: <b>)
    node((2.8, 0), $C$, name: <c>)
    arrow(<p>, <a>, $p_A$, side: left)
    arrow(<p>, <b>, $p_B$, side: right)
    arrow(<a>, <c>, $f$, side: right)
    arrow(<b>, <c>, $g$, side: left)
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

    edge(
      (name: "cc", anchor: "north"),
      (name: "dd", anchor: "north"),
      "-|>",
      label: [$F$],
      label-size: s-cap,
      label-pos: 0.3,
      stroke: e-stroke,
    )
    edge(
      (name: "dd", anchor: "south"),
      (name: "cc", anchor: "south"),
      "-|>",
      label: [$G$],
      label-size: s-cap,
      label-pos: 0.3,
      stroke: e-stroke,
    )

    node((2.8, 0.3), $F(X) -> Y$, name: <fy>, stroke: none, fill: none)
    node((2.8, -0.3), $X -> G(Y)$, name: <xg>, stroke: none, fill: none)
    edge(
      <fy>,
      <xg>,
      "-|>-|-|>",
      label: [биекция],
      label-size: s-cap,
      stroke: hr-dash,
    )
  },
)

// ── Квадрат естественности леммы Йонеды ──
#let yoneda-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 4.2em,
  {
    node((0, -2), $cal(C)(A, B)$, name: <cb>)
    node((4.2, -2), $F (B)$, name: <fb>)
    node((0, 0), $cal(C)(A, C)$, name: <cc>)
    node((4.2, 0), $F (C)$, name: <fc>)
    arrow(<cb>, <fb>, $alpha_B$, side: left)
    arrow(<cc>, <fc>, $alpha_C$, side: left)
    arrow(<cb>, <cc>, $cal(C)(A, f)$, side: left)
    arrow(<fb>, <fc>, $F (f)$, side: right)
  },
)

// ── Треугольные тождества сопряжения ──
#let adjunction-triangles = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,
  {
    node((0, -2), $F$, name: <f1>)
    node((2.6, -3.1), $F G F$, name: <fgf>)
    node((2.6, -0.9), $F$, name: <f2>)
    arrow(<f1>, <fgf>, $F eta$, side: left)
    arrow(<fgf>, <f2>, $epsilon F$, side: right)
    arrow(<f1>, <f2>, $"id"_F$, stroke: d-stroke, bend: -24deg, pos: 0.5)

    node((5.6, -2), $G$, name: <g1>)
    node((8.2, -3.1), $G F G$, name: <gfg>)
    node((8.2, -0.9), $G$, name: <g2>)
    arrow(<g1>, <gfg>, $eta G$, side: left)
    arrow(<gfg>, <g2>, $G epsilon$, side: right)
    arrow(<g1>, <g2>, $"id"_G$, stroke: d-stroke, bend: -24deg, pos: 0.5)
  },
)

// ── Ассоциативность умножения монады ──
#let monad-assoc = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, -2), $T^3$, name: <t3>)
    node((2.8, -2), $T^2$, name: <t2a>)
    node((0, 0), $T^2$, name: <t2b>)
    node((2.8, 0), $T$, name: <t>)
    arrow(<t3>, <t2a>, $T mu$, side: left)
    arrow(<t3>, <t2b>, $mu T$, side: left)
    arrow(<t2a>, <t>, $mu$, side: right)
    arrow(<t2b>, <t>, $mu$, side: right)
  },
)

// ── Монада из сопряжения ──
#let monad-from-adjunction = canvas({
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "cc")
  draw.content("cc", text(size: s-node, fill: c-ink)[$cal(C)$])
  let loop-radius = 0.85
  let loop-angle = 22deg
  draw.arc(
    (
      loop-radius * calc.cos(loop-angle),
      loop-radius * calc.sin(loop-angle),
    ),
    start: loop-angle,
    stop: 180deg - loop-angle,
    radius: loop-radius,
    stroke: e-stroke,
    mark: (end: ">"),
    name: "loop-t",
  )
  draw.content((0, 1.75), text(
    size: s-cap,
    fill: c-ink,
  )[$T = G circle.stroked.tiny F$])
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
  let wire(fr, to, name: none) = draw.line(fr, to, stroke: e-stroke, name: name)

  // m : A ⊗ B -> C, затем n : C ⊗ D -> E.
  op(1.4, 0, "m", $m$)
  op(1.4, 2.4, "n", $n$)

  draw.content((-0.2, -1.35), padding: 4pt, name: "wA", text(
    size: s-cap,
    fill: c-ink,
  )[$A$])
  draw.content((1.4, -1.35), padding: 4pt, name: "wB", text(
    size: s-cap,
    fill: c-ink,
  )[$B$])
  draw.content((3.0, -1.35), padding: 4pt, name: "wD", text(
    size: s-cap,
    fill: c-ink,
  )[$D$])
  draw.content((1.4, 3.9), padding: 4pt, name: "wE", text(
    size: s-cap,
    fill: c-ink,
  )[$E$])

  wire("wA.north", "m.south-west")
  wire("wB.north", "m.south-east")
  wire("m.north-west", "n.south-west", name: "mn")
  wire("wD.north", "n.south-east")
  wire("n.north", "wE.south")
  draw.content("mn", anchor: "east", padding: 2pt, text(
    size: s-cap,
    fill: c-muted,
  )[$C$])
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
