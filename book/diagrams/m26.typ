#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let reduction-halt-empty = {
  let machine(pos, name, body) = node(
    pos,
    body,
    name: name,
    shape: rect,
    width: 4.8cm,
    height: 1.2cm,
    corner-radius: 6pt,
    fill: c-fl,
    stroke: t-bd + c-bd,
    inset: 0pt,
  )

  diagram(
    machine((0, 0), <in>, text(
      size: s-node,
      fill: c-ink,
    )[$chevron.l M chevron.r w$]),
    machine((7.2, 0), <out>, text(
      size: s-node,
      fill: c-ink,
    )[$chevron.l M' chevron.r$]),
    edge(
      <in>,
      <out>,
      "-}>",
      label: text(size: s-cap, fill: c-accent)[$f$],
      stroke: c-accent + t-hi,
    ),
    node(
      (11.4, 0),
      text(size: s-cap, fill: c-muted)[
        #align(left)[
          описание МТ,\
          чей язык пуст iff M(w) зацикливается
        ]
      ],
      name: <note>,
      fill: none,
      stroke: none,
    ),
    edge(<out>, <note>, "-}>", stroke: c-edge + t-ed),
  )
}

// ── m-сведение: $f$ переносит принадлежность ──
#let m-reduction = {
  let dot(pos, member, name) = node(
    pos,
    [],
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
    pos,
    [],
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
        label("a2"),
        label("b2"),
        text(fill: c-accent)[$f$],
        "-}>",
        stroke: c-accent + t-hi,
        label-side: left,
      ))
    } else {
      els.push(edge(
        label("a" + str(i)),
        label("b" + str(i)),
        "-}>",
        stroke: c-edge + t-ed,
      ))
    }
  }
  diagram(..els)
}

// ── Карта RE / co-RE: разрешимые в линзе пересечения, экземпляры задач по регионам ──
#let re-co-re-map = canvas({
  let dot(pos, name) = draw.circle(
    pos,
    radius: 0.055,
    fill: c-ink,
    stroke: none,
    name: name,
  )
  let tag(pos, body) = draw.content(pos, text(size: s-cap, fill: c-ink)[#body])

  draw.rect((-3.6, -2.5), (3.6, 2.5), stroke: (paint: c-edge, thickness: t-hr))
  draw.content((-2.5, 2.18), text(size: s-cap, fill: c-muted)[все языки])

  draw.circle(
    (-0.8, 0),
    radius: 1.6,
    fill: c-fl.transparentize(30%),
    stroke: t-bd + c-bd,
    name: "re",
  )
  draw.circle(
    (0.8, 0),
    radius: 1.6,
    fill: c-conn.transparentize(30%),
    stroke: t-bd + c-bd,
    name: "co-re",
  )
  draw.content((-1.4, 1.22), text(size: s-node, fill: c-ink)[$"RE"$])
  draw.content((-1.35, 0.92), text(size: s-tiny, fill: c-muted)[распознаваемые])
  draw.content((1.4, 1.22), text(size: s-node, fill: c-ink)[$"co-RE"$])
  draw.content((1.35, 0.92), text(
    size: s-tiny,
    fill: c-muted,
  )[ко-распознаваемые])

  draw.line((0, -1.42), (0, -1.62), stroke: (paint: c-muted, thickness: t-hr))
  draw.content((0, -1.92), text(size: s-cap, fill: c-ink)[разрешимые])

  dot((0, 0.55), "dec")
  tag((0, 0.25), ${0^n 1^n}$)
  dot((-1.8, 0.5), "halt")
  tag((-1.8, 0.2), $"HALT"$)
  dot((1.8, 0.5), "cohalt")
  tag((1.8, 0.2), $overline("HALT")$)
  dot((2.65, 1.7), "eq")
  tag((2.65, 1.38), $"EQ"_"TM"$)
})
