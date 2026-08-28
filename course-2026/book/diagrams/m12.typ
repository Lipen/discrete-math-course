#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let e-stroke = (paint: c-edge, thickness: t-ed)
#let n-stroke = c-bd + t-bd

// ── Решётка подгрупп ZZ_12 ──
#let subgroup-lattice = canvas({
  let hf-node(pos, name, body, fill: c-fl) = {
    draw.circle(pos, radius: 0.42, stroke: n-stroke, fill: fill, name: name)
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let hf-edge(fr, to) = {
    draw.line(fr, to, stroke: e-stroke)
  }

  hf-node((0, 4.2), "n12", $12$)
  hf-node((-2.0, 2.8), "n6", $6$)
  hf-node((0.0, 2.8), "n4", $4$)
  hf-node((2.0, 2.8), "n3", $3$)
  hf-node((-1.0, 1.4), "n2", $2$)
  hf-node((1.0, 1.4), "n1", $1$)

  hf-edge("n12", "n6")
  hf-edge("n12", "n4")
  hf-edge("n12", "n3")
  hf-edge("n6", "n2")
  hf-edge("n4", "n2")
  hf-edge("n3", "n1")
  hf-edge("n2", "n1")

  draw.content((-3.6, 4.2), anchor: "west", text(size: s-cap, fill: c-muted)[$ZZ_12$])
  draw.content((-3.6, 2.8), anchor: "west", text(size: s-cap, fill: c-muted)[порядки])
  draw.content((-3.8, 1.4), anchor: "west", text(size: s-cap, fill: c-muted)[делители 12])
})

// Точка на круге радиуса r под углом a (градусы от положительной оси X).
// Ось Y в диаграммах fletcher направлена вниз, поэтому Y берём с минусом.
#let polar(r, a) = (calc.cos(a * calc.pi / 180) * r, -calc.sin(a * calc.pi / 180) * r)

// ── Циклическая группа: образующий в ZZ_8 ──
#let cyclic-generator = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  edge-stroke: e-stroke,
  node(polar(1.6, 90), $0$, name: <b0>),
  node(polar(1.6, 45), $1$, name: <b1>),
  node(polar(1.6, 0), $2$, name: <b2>),
  node(polar(1.6, -45), $3$, name: <b3>),
  node(polar(1.6, -90), $4$, name: <b4>),
  node(polar(1.6, -135), $5$, name: <b5>),
  node(polar(1.6, 180), $6$, name: <b6>),
  node(polar(1.6, 135), $7$, name: <b7>),
  node((0, 0), $ZZ_8$, fill: none, stroke: none, name: <center>),
  edge(<b0>, <b1>, "-}>", label: [$+1$]),
  edge(<b1>, <b2>, "-}>", label: [$+1$]),
  edge(<b2>, <b3>, "-}>", label: [$+1$]),
  edge(<b3>, <b4>, "-}>", label: [$+1$]),
  edge(<b4>, <b5>, "-}>", label: [$+1$]),
  edge(<b5>, <b6>, "-}>", label: [$+1$]),
  edge(<b6>, <b7>, "-}>", label: [$+1$]),
  edge(<b7>, <b0>, "-}>", label: [$+1$]),
)

// ── Коммутативная диаграмма гомоморфизма ──
#let hom-square = canvas({
  let hf-node(pos, name, body) = {
    draw.rect(
      (pos.at(0) - 1.1, pos.at(1) - 0.5),
      (pos.at(0) + 1.1, pos.at(1) + 0.5),
      radius: 4pt,
      stroke: n-stroke,
      fill: c-fl,
      name: name,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let hf-arrow(fr, to, name, label) = {
    draw.line(fr, to, stroke: e-stroke, name: name, mark: (end: ">"))
    draw.content(name, text(size: s-cap, fill: c-ink)[#label])
  }

  hf-node((0, 2.2), "g", $G$)
  hf-node((3.4, 2.2), "h", $H$)
  hf-node((0, -2.2), "gk", $G / "ker"(phi)$)
  hf-node((3.4, -2.2), "im", $"im"(phi)$)

  hf-arrow("g", "h", "a-gh", [$phi$])
  hf-arrow("g", "gk", "a-gk", [$pi$])
  hf-arrow("gk", "im", "a-ki", [$tilde(phi)$])
  hf-arrow("h", "im", "a-hi", [$"in"$])
})

// ── Лестница структур ──
#let structure-staircase = canvas({
  let hf-node(pos, name, body, fill: c-fl) = {
    draw.rect(
      (pos.at(0) - 1.2, pos.at(1) - 0.32),
      (pos.at(0) + 1.2, pos.at(1) + 0.32),
      radius: 4pt,
      stroke: n-stroke,
      fill: fill,
      name: name,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let hf-step(fr, to, name, label) = {
    draw.line(fr, to, stroke: e-stroke, name: name, mark: (end: ">"))
    draw.content(name, text(size: s-cap, fill: c-ink)[#label], dy: 0.9em)
  }

  hf-node((0, 3.2), "b1", [полугруппа], fill: c-fl)
  hf-node((3.6, 2.4), "b2", [моноид], fill: c-conn)
  hf-node((7.2, 1.6), "b3", [группа], fill: c-warn)
  hf-node((10.8, 0.8), "b4", [кольцо], fill: c-fl)
  hf-node((14.4, 0.0), "b5", [поле], fill: c-atom)

  hf-step("b1", "b2", "s12", [нейтральный])
  hf-step("b2", "b3", "s23", [обратный])
  hf-step("b3", "b4", "s34", [вторая операция])
  hf-step("b4", "b5", "s45", [деление])
})
