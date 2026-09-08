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
    draw.circle(pos, radius: 0.46, stroke: n-stroke, fill: fill, name: name)
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let hf-edge(fr, to) = {
    draw.line(fr, to, stroke: e-stroke)
  }

  // Узел chevron.l g chevron.r --- подгруппа, порождённая элементом g.
  hf-node((0, 4.2), "g1", $chevron.l 1 chevron.r$)
  hf-node((-1.7, 2.8), "g2", $chevron.l 2 chevron.r$)
  hf-node((1.7, 2.8), "g3", $chevron.l 3 chevron.r$)
  hf-node((-2.5, 1.4), "g4", $chevron.l 4 chevron.r$)
  hf-node((0.0, 1.4), "g6", $chevron.l 6 chevron.r$)
  hf-node((-1.3, 0.0), "g0", $chevron.l 0 chevron.r$)

  hf-edge("g1", "g2")
  hf-edge("g1", "g3")
  hf-edge("g2", "g4")
  hf-edge("g2", "g6")
  hf-edge("g3", "g6")
  hf-edge("g4", "g0")
  hf-edge("g6", "g0")
})

// Точка на круге радиуса r под углом a (градусы от положительной оси X).
// Ось Y в диаграммах fletcher направлена вниз, поэтому Y берём с минусом.
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
  hf-arrow("im", "h", "a-hi", [$iota$])
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

  let msg-arrow(fr, to, dy, label, above) = {
    let a = (fr.at(0), fr.at(1) + dy)
    let b = (to.at(0), to.at(1) + dy)
    draw.line(a, b, stroke: e-stroke, mark: (end: ">"))
    draw.content(
      ((a.at(0) + b.at(0)) / 2, a.at(1) + (if above { 0.36 } else { -0.36 })),
      anchor: if above { "south" } else { "north" },
      text(size: s-cap, fill: c-ink)[#label],
    )
  }

  box((-3.7, 2.0), "alice", [Алиса, знает $a$], fill: c-fl)
  box((3.7, 2.0), "bob", [Боб, знает $b$], fill: c-fl)
  box((0, -2.3), "eve", [Ева], fill: c-warn)

  msg-arrow((-2.15, 2.0), (2.15, 2.0), 0.15, [$g^a mod p$], true)
  msg-arrow((2.15, 2.0), (-2.15, 2.0), -0.15, [$g^b mod p$], false)

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
