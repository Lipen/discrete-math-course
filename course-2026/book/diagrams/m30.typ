#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Классы сложности ──
// Вложенные эллипсы: больший класс содержит меньший; P лежит в NP ∩ coNP.
#let complexity-classes = {
  let ellipse(pos, rx, ry, fill, name) = {
    let (x, y) = pos
    draw.circle(
      (x, y),
      radius: (rx, ry),
      name: name,
      fill: fill,
      stroke: t-bd + c-bd,
    )
  }
  let lb(pos, body) = {
    draw.content(pos, text(size: s-node, fill: c-ink)[#body])
  }

  canvas({
    ellipse((0, 0), 3.0, 1.9, c-fl, "exp")
    ellipse((0, 0), 2.2, 1.35, c-fl, "pspace")
    ellipse((-0.4, 0), 1.05, 0.72, c-conn, "np")
    ellipse((0.4, 0), 1.05, 0.72, c-conn, "conp")
    ellipse((0, 0), 0.55, 0.34, c-atom, "p")

    lb((2.35, 0.75), [EXP])
    lb((1.7, -0.6), [PSPACE])
    lb((-1.2, 0), [NP])
    lb((1.2, 0), [coNP])
    lb((0, 0), [P])

    // Открытый вопрос: равно ли NP coNP.
    draw.content(
      (0.85, 1.0),
      text(size: s-cap, fill: c-muted)[$?$],
    )

    // Теорема об иерархии: P строго внутри EXP.
    draw.content(
      (0, 2.35),
      text(size: s-cap, fill: c-muted)[$P != "EXP"$ (теорема об иерархии)],
    )
  })
}

// ── NP-дерево сведения ──
// Набор известных полиномиальных сведений; стрелка = ≤_p.
#let np-reduction-tree = {
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
  let red(from, to) = {
    draw.line(
      from,
      to,
      stroke: c-edge + t-ed,
      mark: (end: "stealth", fill: c-edge),
    )
  }

  canvas({
    rbox("sat", 0, 0, [SAT], c-conn)
    rbox("3sat", -1.3, -1.8, [3-SAT], c-fl)
    rbox("vc", 1.7, -1.8, [Vertex Cover], c-fl, width: 3.3)
    rbox("subset", -2.9, -3.6, [Subset Sum], c-fl)
    rbox("clique", 0.2, -3.6, [Clique], c-fl)
    rbox("ham", 3.3, -3.6, [Ham. Cycle], c-fl, width: 2.6)

    red("sat.south", "3sat.north")
    red("3sat.south", "subset.north")
    red("vc.south", "clique.north")
    red("vc.south", "ham.north")

    draw.content(
      (0, -4.7),
      text(size: s-cap, fill: c-muted)[
        Каждая стрелка: $<=_p$ (полиномиальное сведение)
      ],
    )
  })
}

// ── Венн для ZPP ──
// BPP ⊇ RP и coRP; ZPP = RP ∩ coRP; P внутри ZPP.
#let zpp-venn = {
  let ellipse(pos, rx, ry, fill, name) = {
    let (x, y) = pos
    draw.circle(
      (x, y),
      radius: (rx, ry),
      name: name,
      fill: fill,
      stroke: t-bd + c-bd,
    )
  }
  let lb(pos, body, size: s-node, fill: c-ink) = {
    draw.content(pos, text(size: size, fill: fill)[#body])
  }

  canvas({
    ellipse((0, 0), 2.6, 1.7, c-fl, "bpp")
    ellipse((0.7, 0.1), 1.4, 1.0, c-conn, "corp")
    ellipse((-0.7, 0.1), 1.4, 1.0, c-atom, "rp")
    ellipse((0, 0.1), 0.62, 0.5, c-atom, "zpp")
    ellipse((0, 0.1), 0.22, 0.16, white, "p")

    lb((2.25, 0.7), [BPP])
    lb((-1.75, 0.1), [RP])
    lb((1.75, 0.1), [coRP])
    lb((0, -0.29), [ZPP])
    lb((0, 0.1), [P])

    lb(
      (0, -2.1),
      [$P subset.eq "ZPP" = "RP" inter "coRP" subset.eq "BPP"$],
      size: s-cap,
      fill: c-muted,
    )
  })
}
