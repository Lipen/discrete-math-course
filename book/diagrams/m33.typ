#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Доступность (стрелки переходов) выделяется книжным акцентом.
#let acc-stroke = (paint: c-accent, thickness: t-ed)

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let loop-edge(from, angle: 90deg) = edge(
  from,
  from,
  "-}>",
  stroke: acc-stroke,
  bend: 120deg,
  loop-angle: angle,
)

// Узел D --- деонтическая система, лежащая на ребре $K -> T$, вне осей куба.
#let d-fill = c-conn
#let d-str = oklch(60%, 0.10, 60deg) + t-bd

// ── Крипке-модель светофора ──
#let kripke-traffic = diagram(
  node-shape: circle,
  node-stroke: t-bd + c-bd,
  node-fill: c-fl,
  node((0, -1.1), $G$, name: <g>),
  node((1.05, 0.55), $Y$, name: <y>),
  node((-1.05, 0.55), $R$, name: <r>),
  edge(<g>, <y>, "-}>", stroke: acc-stroke),
  edge(<y>, <r>, "-}>", stroke: acc-stroke),
  edge(<r>, <g>, "-}>", stroke: acc-stroke),
  node(
    (0, -1.95),
    text(size: s-cap, fill: c-muted)[$"green"$],
    fill: none,
    stroke: none,
  ),
  node(
    (1.7, 1),
    text(size: s-cap, fill: c-muted)[$"yellow"$],
    fill: none,
    stroke: none,
  ),
  node(
    (-1.7, 1),
    text(size: s-cap, fill: c-muted)[$"red"$],
    fill: none,
    stroke: none,
  ),
)

// ── Куб модальностей ──
#let modal-cube = canvas({
  let r = 0.44
  let w-node(pos, body, name, dim: false) = {
    let label-col = if dim { c-muted } else { c-ink }
    draw.circle(pos, radius: r, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: label-col)[#body])
  }
  let frame(from, to, name: none) = draw.line(
    from,
    to,
    stroke: e-stroke,
    name: name,
  )

  w-node((0, 0), $K$, "k")
  w-node((2.2, 0), $T$, "t")
  w-node((0, 2.2), $K B$, "kb", dim: true)
  w-node((2.2, 2.2), $B$, "b")
  w-node((0.7, 1.3), $K_4$, "k4", dim: true)
  w-node((2.9, 1.3), $S_4$, "s4")
  w-node((0.7, 3.5), $K B_4$, "kb4", dim: true)
  w-node((2.9, 3.5), $S_5$, "s5")

  // Каркас куба под узлами: рёбра читаются по именам вершин, стыки скрыты заливкой.
  draw.on-layer(-1, {
    frame("k", "t")
    frame("k", "kb")
    frame("t", "b")
    frame("kb", "b")
    frame("k4", "s4")
    frame("k4", "kb4")
    frame("s4", "s5")
    frame("kb4", "s5")
    frame("k", "k4")
    frame("t", "s4")
    frame("kb", "kb4")
    frame("b", "s5")
  })

  draw.content((0.9, -0.6), text(size: s-cap, fill: c-muted)[+$T$])
  draw.content((-0.55, 1.1), text(size: s-cap, fill: c-muted)[+$B$])
  draw.content((0.60, 0.52), text(size: s-cap, fill: c-muted)[+$4$])

  draw.circle((1.25, 0), radius: 0.28, fill: d-fill, stroke: d-str, name: "d")
  draw.content("d", text(size: s-node, fill: c-ink)[$D$])
})

// ── Состояния мьютекса ──
#let mutex-states = diagram(
  node-shape: circle,
  node-stroke: t-bd + c-bd,
  node-fill: c-fl,
  node((0, 1.7), $(O, O)$, name: <oo>),
  node((-1.7, 0), $(C, O)$, name: <co>),
  node((1.7, 0), $(O, C)$, name: <oc>),
  node(
    (0, -1.9),
    $(C, C)$,
    name: <cc>,
    fill: none,
    stroke: (paint: c-hot, thickness: t-bd, dash: "dashed"),
  ),
  edge(<oo>, <co>, "-}>", stroke: acc-stroke),
  edge(<co>, <oo>, "-}>", stroke: acc-stroke),
  edge(<oo>, <oc>, "-}>", stroke: acc-stroke),
  edge(<oc>, <oo>, "-}>", stroke: acc-stroke),
  node(
    (-2.75, 0),
    text(size: s-cap, fill: c-muted)[$"crit"_1$],
    fill: none,
    stroke: none,
  ),
  node(
    (2.75, 0),
    text(size: s-cap, fill: c-muted)[$"crit"_2$],
    fill: none,
    stroke: none,
  ),
  node(
    (1.45, -1.9),
    text(size: s-cap, fill: c-muted)[$"crit"_1, "crit"_2$],
    fill: none,
    stroke: none,
  ),
)

// ── Модель Крипке: истинность вложенной модальности ──
#let kripke-forcing = diagram(
  node-shape: circle,
  node-stroke: t-bd + c-bd,
  node-fill: c-fl,
  node((-1.1, -0.7), $w_0$, name: <w0>),
  node((0.5, 0.8), $w_1$, name: <w1>),
  node((1.5, -0.7), $w_2$, name: <w2>),
  edge(<w0>, <w1>, "-}>", stroke: acc-stroke),
  edge(<w0>, <w2>, "-}>", stroke: acc-stroke),
  edge(<w1>, <w2>, "-}>", stroke: acc-stroke),
  edge(<w2>, <w2>, "-}>", stroke: acc-stroke, bend: 120deg, loop-angle: 0deg),
  node(
    (-1.1, -1.55),
    text(size: s-cap, fill: c-muted)[$square (p -> q)$],
    fill: none,
    stroke: none,
  ),
  node(
    (0.95, 1.35),
    text(size: s-cap, fill: c-muted)[$q$],
    fill: none,
    stroke: none,
  ),
  node(
    (1.9, -1.55),
    text(size: s-cap, fill: c-muted)[$p, q$],
    fill: none,
    stroke: none,
  ),
)

// ── Классы фреймов: рефлексивность, предпорядок, эквивалентность ──
#let frame-classes = diagram(
  node-shape: circle,
  node-stroke: t-bd + c-bd,
  node-fill: c-fl,
  node((-0.6, 0), $w$, name: <tw>),
  node((0.6, 0), $v$, name: <tv>),
  loop-edge(<tw>),
  loop-edge(<tv>),
  edge(<tw>, <tv>, "-}>", stroke: acc-stroke),

  node((2.6, 0), $w$, name: <sw>),
  node((3.6, 0.75), $v$, name: <sv>),
  node((4.6, 0), $u$, name: <su>),
  loop-edge(<sw>),
  loop-edge(<sv>),
  loop-edge(<su>),
  edge(<sw>, <sv>, "-}>", stroke: acc-stroke),
  edge(<sv>, <su>, "-}>", stroke: acc-stroke),
  edge(<sw>, <su>, "-}>", stroke: acc-stroke, bend: -25deg),

  node((6.4, 0), $w$, name: <ew>),
  node((7.4, 0.75), $v$, name: <ev>),
  node((8.4, 0), $u$, name: <eu>),
  loop-edge(<ew>),
  loop-edge(<ev>),
  loop-edge(<eu>),
  edge(<ew>, <ev>, "-}>", stroke: acc-stroke),
  edge(<ev>, <ew>, "-}>", stroke: acc-stroke),
  edge(<ev>, <eu>, "-}>", stroke: acc-stroke),
  edge(<eu>, <ev>, "-}>", stroke: acc-stroke),
  edge(<ew>, <eu>, "-}>", stroke: acc-stroke),
  edge(<eu>, <ew>, "-}>", stroke: acc-stroke),

  node(
    (-0.6, -1.05),
    text(size: s-cap, fill: c-muted)[$T$: рефлексивность],
    fill: none,
    stroke: none,
  ),
  node(
    (3.6, -1.05),
    text(size: s-cap, fill: c-muted)[$S_4$: предпорядок],
    fill: none,
    stroke: none,
  ),
  node(
    (7.4, -1.05),
    text(size: s-cap, fill: c-muted)[$S_5$: эквивалентность],
    fill: none,
    stroke: none,
  ),
)
