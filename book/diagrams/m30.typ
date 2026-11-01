#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Общие хелперы ──
#let ellipse(pos, rx, ry, fill, name) = {
  let (x, y) = pos
  draw.circle(
    (x, y),
    radius: (rx, ry),
    name: name,
    fill: fill,
    stroke: t-bd + c-bd,
  )
}

#let lb(pos, body, size: s-node, fill: c-ink) = {
  draw.content(pos, text(size: size, fill: fill)[#body])
}

// ── Классы сложности ──
// Вложенные эллипсы: больший класс содержит меньший; P лежит в NP inter coNP.
#let complexity-classes = canvas({
  ellipse((0, 0), 3.1, 1.95, c-fl, "exp")
  ellipse((0, 0), 2.1, 1.3, c-fl, "pspace")
  ellipse((-0.55, 0), 1.2, 0.72, c-conn, "np")
  ellipse((0.55, 0), 1.2, 0.72, c-conn, "conp")
  ellipse((0, 0), 0.55, 0.34, c-atom, "p")

  lb((2.6, 0), [EXP])
  lb((0, -1.0), [PSPACE])
  lb((-1.2, 0), [NP])
  lb((1.2, 0), [coNP])
  lb((0, 0), [P])

  // Открытый вопрос: равно ли NP coNP.
  draw.content(
    (0, 0.92),
    text(size: s-cap, fill: c-muted)[$?$],
  )

  // Теорема об иерархии: P строго внутри EXP.
  draw.content(
    (0, 2.35),
    text(size: s-cap, fill: c-muted)[$P != "EXP"$ (теорема об иерархии)],
  )
})

// ── NP-дерево сведения ──
// Набор известных полиномиальных сведений; стрелка = ≤_p.
#let np-reduction-tree = canvas({
  let box-h = 0.6

  let rbox(name, x, y, body, fill, width: 2.4) = {
    draw.rect(
      (x - width / 2, y - box-h / 2),
      (x + width / 2, y + box-h / 2),
      name: name,
      fill: fill,
      stroke: t-bd + c-bd,
      radius: 3pt,
    )
    draw.content((x, y), text(size: s-node, fill: c-ink)[#body])
  }
  let red-edge(from, to) = {
    draw.line(
      from,
      to,
      stroke: c-edge + t-ed,
      mark: (end: "stealth", fill: c-edge),
    )
  }

  rbox("sat", 0, 0, [SAT], c-conn)
  rbox("3sat", -1.3, -1.8, [3-SAT], c-fl)
  rbox("vc", 1.8, -1.8, [Vertex Cover], c-fl, width: 3.1)
  rbox("subset", -2.9, -3.6, [Subset Sum], c-fl)
  rbox("clique", 0.2, -3.6, [Clique], c-fl)
  rbox("ham", 3.3, -3.6, [Ham. Cycle], c-fl, width: 2.6)

  red-edge("sat.south", "3sat.north")
  red-edge("3sat.south", "subset.north")
  red-edge("3sat.east", "vc.west")
  red-edge("vc.south", "clique.north")
  red-edge("vc.south", "ham.north")

  draw.content(
    (0, -4.7),
    text(size: s-cap, fill: c-muted)[
      Каждая стрелка: $<=_p$ (полиномиальное сведение)
    ],
  )
})

// ── Венн для ZPP ──
// BPP ⊇ RP и coRP; ZPP = RP inter coRP; P внутри ZPP.
#let zpp-venn = canvas({
  ellipse((0, 0), 2.6, 1.7, c-fl, "bpp")
  ellipse((0.6, 0.05), 1.45, 1.05, c-conn, "corp")
  ellipse((-0.6, 0.05), 1.45, 1.05, c-atom, "rp")
  ellipse((0, 0.05), 0.72, 0.6, c-atom, "zpp")
  ellipse((0, 0.37), 0.26, 0.19, c-white, "p")

  lb((0, 1.38), [BPP])
  lb((-1.58, 0.05), [RP])
  lb((1.43, 0.05), [coRP])
  lb((0, -0.19), [ZPP])
  lb((0, 0.37), [P])

  lb(
    (0, -2.1),
    [$P subset.eq "ZPP" = "RP" inter "coRP" subset.eq "BPP"$],
    size: s-cap,
    fill: c-muted,
  )
})
