#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import fletcher: diagram, edge, node

#let map-stroke = c-bd + t-bd

#let map-edge-stroke = (paint: c-edge, thickness: t-ed)

#let map-side-stroke = (paint: c-edge, thickness: t-ed, dash: "dashed")

// ── Карта курса ──
#let course-map = {
  let block-node(pos, title, chapters, name) = node(
    pos,
    align(center)[
      #text(weight: "semibold")[#title] \
      #text(size: 0.85em, fill: c-muted)[#chapters]
    ],
    shape: "rect",
    fill: c-fl,
    stroke: map-stroke,
    inset: 7pt,
    name: name,
  )
  let flow-edge(from, to) = edge(from, to, "->", stroke: map-edge-stroke)
  let off-edge(from, to) = edge(from, to, "->", stroke: map-side-stroke)

  figure(
    diagram(
      spacing: 1.4em,

      block-node((0, 0), [Язык], [m01--m09], <lang>),
      block-node((1, 0), [Алгебра и инженерия], [m10--m17], <algebra>),
      block-node((2, 0), [Счёт и бесконечность], [m18--m22], <counting>),
      block-node((3, 0), [Вычисление], [m23--m35], <computation>),

      node(
        (3.7, 1.4),
        align(center)[Категории \ #text(size: 0.85em, fill: c-muted)[m36]],
        shape: "rect",
        fill: none,
        stroke: map-side-stroke,
        inset: 7pt,
        name: <categories>,
      ),

      flow-edge(<lang>, <algebra>),
      flow-edge(<algebra>, <counting>),
      flow-edge(<counting>, <computation>),
      off-edge(<computation>, <categories>),
    ),
    caption: [Четыре блока курса и замыкающая глава после эпилога.],
    supplement: none,
  )
}
