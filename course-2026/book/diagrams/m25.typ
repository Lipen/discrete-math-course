// m25 diagrams: сводимость HALT→EMPTY.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let reduction-halt-empty = {
  let machine(name, content, pos) = {
    let (x, y) = pos
    draw.rect(
      (x - 2.4, y + 0.6),
      (x + 2.4, y - 0.6),
      name: name,
      fill: c-fl,
      stroke: t-bd + c-bd,
      radius: 6pt,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#content])
  }

  canvas({
    machine("input", [$chevron.l M chevron.r w$], (-3, 0))
    machine("transformed", [$chevron.l M' chevron.r$], (4.2, 0))

    draw.line(
      (-0.3, 0),
      (1.7, 0),
      name: "f-arrow",
      stroke: c-accent + t-hi,
      mark: (end: "stealth", fill: c-accent),
    )
    draw.content(
      "f-arrow",
      text(size: s-cap, fill: c-accent)[$f$],
      fill: white,
      stroke: none,
      padding: 2pt,
    )

    draw.line(
      (6.9, 0),
      (8.3, 0),
      name: "res-arrow",
      stroke: c-edge + t-ed,
      mark: (end: "stealth", fill: c-edge),
    )

    draw.content(
      (9.0, 0),
      anchor: "west",
      text(size: s-cap, fill: c-muted)[
        #align(left)[
          описание МТ,\
          чей язык пуст iff M(w) останавливается
        ]
      ],
    )
  })
}
