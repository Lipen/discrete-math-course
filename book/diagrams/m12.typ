#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let e-stroke = (paint: c-edge, thickness: t-ed)
#let n-stroke = c-bd + t-bd

// ── Решётка подгрупп ZZ_12 ──
// Узел chevron.l g chevron.r --- подгруппа, порождённая элементом g.
#let subgroup-lattice = diagram(
  node-shape: circle,
  node-stroke: n-stroke,
  node-fill: c-fl,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 4.5em,
  node(
    (0, 0),
    text(size: s-node, fill: c-ink)[$chevron.l 1 chevron.r$],
    name: <g1>,
  ),
  node(
    (-1, 1),
    text(size: s-node, fill: c-ink)[$chevron.l 2 chevron.r$],
    name: <g2>,
  ),
  node(
    (1, 1),
    text(size: s-node, fill: c-ink)[$chevron.l 3 chevron.r$],
    name: <g3>,
  ),
  node(
    (-1.5, 2),
    text(size: s-node, fill: c-ink)[$chevron.l 4 chevron.r$],
    name: <g4>,
  ),
  node(
    (0, 2),
    text(size: s-node, fill: c-ink)[$chevron.l 6 chevron.r$],
    name: <g6>,
  ),
  node(
    (-0.9, 3),
    text(size: s-node, fill: c-ink)[$chevron.l 0 chevron.r$],
    name: <g0>,
  ),
  edge(<g1>, <g2>, "-", stroke: e-stroke),
  edge(<g1>, <g3>, "-", stroke: e-stroke),
  edge(<g2>, <g4>, "-", stroke: e-stroke),
  edge(<g2>, <g6>, "-", stroke: e-stroke),
  edge(<g3>, <g6>, "-", stroke: e-stroke),
  edge(<g4>, <g0>, "-", stroke: e-stroke),
  edge(<g6>, <g0>, "-", stroke: e-stroke),
)

// Точка на круге радиуса r под углом a (градусы от положительной оси X).
#let polar(r, a) = (
  calc.cos(a * calc.pi / 180) * r,
  -calc.sin(a * calc.pi / 180) * r,
)

// ── Циклическая группа: образующий в ZZ_8 ──
#let cyclic-generator = {
  let radius = 1.6
  let nname(i) = label("n" + str(i))

  diagram(
    node-stroke: n-stroke,
    node-fill: c-fl,
    edge-stroke: e-stroke,
    {
      for i in range(8) {
        node(polar(radius, 90 - i * 45), $#i$, name: nname(i))
        edge(
          nname(i),
          nname(if i == 7 { 0 } else { i + 1 }),
          "-}>",
          label: [$+1$],
        )
      }
      node((0, 0), $ZZ_8$, fill: none, stroke: none)
    },
  )
}

// ── Коммутативная диаграмма гомоморфизма ──
#let hom-square = diagram(
  node-shape: rect,
  node-stroke: n-stroke,
  node-fill: c-fl,
  node-inset: 8pt,
  node-outset: 2pt,
  node-corner-radius: 4pt,
  spacing: 7em,
  node((0, 0), text(size: s-node, fill: c-ink)[$G$], name: <g>),
  node((1, 0), text(size: s-node, fill: c-ink)[$H$], name: <h>),
  node((0, 1), text(size: s-node, fill: c-ink)[$G / "ker"(phi)$], name: <gk>),
  node((1, 1), text(size: s-node, fill: c-ink)[$"im"(phi)$], name: <im>),
  edge(<g>, <h>, "->", stroke: e-stroke, label: text(
    size: s-cap,
    fill: c-ink,
  )[$phi$]),
  edge(<g>, <gk>, "->", stroke: e-stroke, label: text(
    size: s-cap,
    fill: c-ink,
  )[$pi$]),
  edge(<gk>, <im>, "->", stroke: e-stroke, label: text(
    size: s-cap,
    fill: c-ink,
  )[$tilde(phi)$]),
  edge(<im>, <h>, "->", stroke: e-stroke, label: text(
    size: s-cap,
    fill: c-ink,
  )[$iota$]),
)

// ── Лестница структур ──
#let structure-staircase = diagram(
  node-shape: rect,
  node-stroke: n-stroke,
  node-inset: 6pt,
  node-outset: 2pt,
  node-corner-radius: 4pt,
  spacing: (8em, 1.8em),
  node(
    (0, 0),
    text(size: s-node, fill: c-ink)[полугруппа],
    fill: c-fl,
    name: <b1>,
  ),
  node(
    (1, 1),
    text(size: s-node, fill: c-ink)[моноид],
    fill: c-conn,
    name: <b2>,
  ),
  node(
    (2, 2),
    text(size: s-node, fill: c-ink)[группа],
    fill: c-warn,
    name: <b3>,
  ),
  node((3, 3), text(size: s-node, fill: c-ink)[кольцо], fill: c-fl, name: <b4>),
  node((4, 4), text(size: s-node, fill: c-ink)[поле], fill: c-atom, name: <b5>),
  edge(
    <b1>,
    <b2>,
    "->",
    stroke: e-stroke,
    label: text(size: s-cap, fill: c-ink)[нейтральный],
    label-side: left,
  ),
  edge(
    <b2>,
    <b3>,
    "->",
    stroke: e-stroke,
    label: text(size: s-cap, fill: c-ink)[обратный],
    label-side: left,
  ),
  edge(
    <b3>,
    <b4>,
    "->",
    stroke: e-stroke,
    label: text(size: s-cap, fill: c-ink)[вторая операция],
    label-side: left,
  ),
  edge(
    <b4>,
    <b5>,
    "->",
    stroke: e-stroke,
    label: text(size: s-cap, fill: c-ink)[деление],
    label-side: left,
  ),
)

// ── Обмен ключами Диффи--Хеллмана ──
#let dh-exchange = canvas({
  let box(c, name, body, fill: c-fl) = {
    draw.rect(
      (c.at(0) - 1.55, c.at(1) - 0.55),
      (c.at(0) + 1.55, c.at(1) + 0.55),
      radius: 6pt,
      stroke: n-stroke,
      fill: fill,
      name: name,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let msg-arrow(name, fr, to, dy, label, above) = {
    let a = (fr.at(0), fr.at(1) + dy)
    let b = (to.at(0), to.at(1) + dy)
    draw.line(a, b, stroke: e-stroke, mark: (end: ">"), name: name)
    draw.content(
      name,
      anchor: if above { "south" } else { "north" },
      dy: if above { 0.36 } else { -0.36 },
      text(size: s-cap, fill: c-ink)[#label],
    )
  }

  box((-3.7, 2.0), "alice", [Алиса, знает $a$], fill: c-fl)
  box((3.7, 2.0), "bob", [Боб, знает $b$], fill: c-fl)
  box((0, -2.3), "eve", [Ева], fill: c-warn)

  msg-arrow("a-to-b", (-2.15, 2.0), (2.15, 2.0), 0.15, [$g^a mod p$], true)
  msg-arrow("b-to-a", (2.15, 2.0), (-2.15, 2.0), -0.15, [$g^b mod p$], false)

  draw.line(
    (0, -1.75),
    (0, 1.7),
    stroke: (paint: c-edge, thickness: t-ed, dash: "dashed"),
    mark: none,
  )
  draw.content((0.5, -0.2), anchor: "west", text(
    size: s-cap,
    fill: c-muted,
  )[подслушивает канал])
})
