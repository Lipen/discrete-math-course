// m28 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let ordinals = canvas({
  let top = 0.3
  let line-y = -0.5
  let mark = 0.8

  draw.line((-3.5, line-y), (4.5, line-y), stroke: 0.6pt + luma(50%))

  // Markers
  let points = (
    (-3, [0]),
    (-2, [1]),
    (-1, [2]),
    (0, [$omega$], oklch(55%, 0.22, 250deg)),
    (1, [$omega+1$], oklch(55%, 0.22, 22deg)),
    (2.5, [$omega dot 2$], oklch(55%, 0.22, 250deg)),
    (4, [$omega^2$], oklch(55%, 0.22, 310deg)),
  )

  for pt in points {
    let (x, label, clr) = if pt.len() == 3 { pt } else {
      (pt.at(0), pt.at(1), luma(40%))
    }
    let use-clr = clr
    draw.line(
      (x, line-y - mark / 2),
      (x, line-y + mark / 2),
      stroke: 0.7pt + use-clr,
    )
    draw.content((x, line-y - 0.6), text(
      size: 0.65em,
      fill: use-clr,
      weight: "bold",
    )[#label])
  }

  // Dots for ...
  draw.content((3.3, line-y), text(size: 0.65em, fill: luma(50%))[$dots$])
  // Arrow at end
  draw.line((4.5, line-y), (4.8, line-y), stroke: 0.6pt + luma(50%), mark: (
    end: ">", fill: luma(50%),
  ))
})
