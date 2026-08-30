#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// Доступность (стрелки переходов) выделяется книжным акцентом.
#let acc-stroke = (paint: c-accent, thickness: t-ed)

// Узел D --- деонтическая система, лежащая на ребре K→T, вне осей куба.
#let d-fill = c-conn
#let d-str = oklch(60%, 0.10, 60deg) + t-bd

// ── Крипке-гараж (светофор): три состояния, цикл переходов. ──
#let kripke-traffic = canvas({
  let r = 0.5
  let t-node(pos, body, name) = {
    draw.circle(pos, radius: r, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: c-ink)[#body])
  }
  let acc-edge(from, to) = draw.line(
    from,
    to,
    stroke: acc-stroke,
    mark: (end: "stealth", fill: c-accent),
  )

  t-node((0, 0.95), $G$, "G")
  t-node((0.95, -0.5), $Y$, "Y")
  t-node((-0.95, -0.5), $R$, "R")

  acc-edge("G", "Y")
  acc-edge("Y", "R")
  acc-edge("R", "G")

  draw.content((0, 1.6), anchor: "south", text(size: s-cap, fill: c-muted)[$"green"$])
  draw.content((1.05, -1.05), anchor: "west", text(size: s-cap, fill: c-muted)[$"yellow"$])
  draw.content((-1.05, -1.05), anchor: "east", text(size: s-cap, fill: c-muted)[$"red"$])
})

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
#let mutex-states = canvas({
  let r = 0.52
  let m-node(pos, body, name) = {
    draw.circle(pos, radius: r, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: c-ink)[#body])
  }
  let acc-edge(from, to) = draw.line(
    from,
    to,
    stroke: acc-stroke,
    mark: (end: "stealth", fill: c-accent),
  )

  m-node((0, 0), $(O, O)$, "oo")
  draw.content((0, -0.85), anchor: "north", text(size: s-cap, fill: c-muted)[$nothing$])

  m-node((-1.6, 1.7), $(C, O)$, "co")
  draw.content((-2.35, 1.7), anchor: "east", text(size: s-cap, fill: c-muted)[$"crit"_1$])

  m-node((1.6, 1.7), $(O, C)$, "oc")
  draw.content((2.35, 1.7), anchor: "west", text(size: s-cap, fill: c-muted)[$"crit"_2$])

  draw.circle((0, 3.5), radius: r, fill: none, stroke: (paint: c-hot, thickness: t-bd, dash: "dashed"), name: "cc")
  draw.content((0, 3.5), text(size: s-node, fill: c-ink)[$(C, C)$])
  draw.content((0.65, 3.5), anchor: "west", text(size: s-cap, fill: c-muted)[$"crit"_1, "crit"_2$])

  acc-edge("oo", "co")
  acc-edge("oo", "oc")
  acc-edge("co", "oo")
  acc-edge("oc", "oo")
})
