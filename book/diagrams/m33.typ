#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Доступность (стрелки переходов) выделяется книжным акцентом.
#let acc-stroke = (paint: c-accent, thickness: t-ed)

// Узел D --- деонтическая система, лежащая на ребре K→T, вне осей куба.
#let d-fill = c-conn
#let d-str = oklch(60%, 0.10, 60deg) + t-bd

// ── Крипке-гараж (светофор): три состояния, цикл переходов. ──
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

// ── Куб модальностей: оси +T, +B, +4; D на ребре K→T. ──
#let modal-cube = canvas({
  let r = 0.44
  let frame-stroke = (paint: c-edge, thickness: t-ed)
  let w-node(pos, body, name, dim: false) = {
    let label-col = if dim { c-muted } else { c-ink }
    draw.circle(pos, radius: r, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: label-col)[#body])
  }
  let frame(from, to) = draw.line(from, to, stroke: frame-stroke)

  let pk = (0, 0)
  let pt = (2.2, 0)
  let pkb = (0, 2.2)
  let pb = (2.2, 2.2)
  let pk4 = (0.7, 1.3)
  let ps4 = (2.9, 1.3)
  let pkb4 = (0.7, 3.5)
  let ps5 = (2.9, 3.5)

  frame(pk, pt)
  frame(pk, pkb)
  frame(pt, pb)
  frame(pkb, pb)
  frame(pk4, ps4)
  frame(pk4, pkb4)
  frame(ps4, ps5)
  frame(pkb4, ps5)
  frame(pk, pk4)
  frame(pt, ps4)
  frame(pkb, pkb4)
  frame(pb, ps5)

  draw.content((0.9, -0.6), text(size: s-cap, fill: c-muted)[+$T$])
  draw.content((-0.55, 1.1), text(size: s-cap, fill: c-muted)[+$B$])
  draw.content((0.15, 0.7), text(size: s-cap, fill: c-muted)[+$4$])

  w-node(pk, $K$, "k")
  w-node(pt, $T$, "t")
  w-node(pkb, $K B$, "kb", dim: true)
  w-node(pb, $B$, "b")

  w-node(pk4, $K_4$, "k4", dim: true)
  w-node(ps4, $S_4$, "s4")
  w-node(pkb4, $K B_4$, "kb4", dim: true)
  w-node(ps5, $S_5$, "s5")

  let d-pos = (1.1, 0)
  draw.circle(d-pos, radius: 0.28, fill: d-fill, stroke: d-str, name: "d")
  draw.content(d-pos, text(size: s-node, fill: c-ink)[$D$])
})

// ── Состояния мьютекса: (C,C) запрещено, переходы между остальными. ──
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
