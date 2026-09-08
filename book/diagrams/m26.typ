#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

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
          чей язык пуст iff M(w) зацикливается
        ]
      ],
    )
  })
}

// ── m-сведение: $f$ переносит принадлежность ──
#let m-reduction = {
  let dot(pos, member, name) = node(
    pos, [],
    shape: circle,
    radius: 0.1cm,
    inset: 0.1cm,
    outset: 0pt,
    fill: if member { c-ink } else { white },
    stroke: if member { none } else { t-bd + c-ink },
    name: name,
  )
  let tag(pos, body) = node(pos, body, fill: none, stroke: none)
  let region(pos) = node(
    pos, [],
    shape: rect,
    width: 3.2cm,
    height: 5.2cm,
    corner-radius: 12pt,
    fill: c-fl,
    stroke: t-bd + c-bd,
    inset: 0pt,
    outset: 0pt,
    layer: -1,
  )

  let rows = (
    (1.8cm, true, $x_1$, $f(x_1)$),
    (0.9cm, false, $x_2$, $f(x_2)$),
    (0cm, true, $x_3$, $f(x_3)$),
    (-0.9cm, true, $x_4$, $f(x_4)$),
    (-1.8cm, false, $x_5$, $f(x_5)$),
  )

  let els = (
    region((0.7cm, 0cm)),
    region((7.7cm, 0cm)),
    tag((-0.5cm, 2.25cm), text(weight: "bold")[$A$]),
    tag((8.9cm, 2.25cm), text(weight: "bold")[$B$]),
  )
  for (i, (y, member, xl, fl)) in rows.enumerate() {
    els.push(tag((0.85cm, y), xl))
    els.push(tag((7.65cm, y), fl))
    els.push(dot((1.4cm, y), member, label("a" + str(i))))
    els.push(dot((6.9cm, y), member, label("b" + str(i))))
    if i == 2 {
      els.push(edge(
        label("a2"), label("b2"),
        text(fill: c-accent)[$f$], "-}>",
        stroke: c-accent + t-hi,
        label-side: left,
      ))
    } else {
      els.push(edge(
        label("a" + str(i)), label("b" + str(i)), "-}>",
        stroke: c-edge + t-ed,
      ))
    }
  }
  diagram(..els)
}
