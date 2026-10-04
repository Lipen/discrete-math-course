#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Доступность (стрелки переходов) выделяется книжным акцентом.
#let acc-stroke = (paint: c-accent, thickness: t-ed)

#let e-stroke = (paint: c-edge, thickness: t-ed)

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
    frame("k", "t", name: "kt")
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
  draw.content((0.15, 0.7), text(size: s-cap, fill: c-muted)[+$4$])

  draw.circle("kt", radius: 0.28, fill: d-fill, stroke: d-str, name: "d")
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
