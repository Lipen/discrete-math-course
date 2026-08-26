// m28 diagrams: ординалы как продолжение натурального ряда (числовая ось).
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let ordinals = canvas({
  let line-y = -0.5
  let r = 0.22

  draw.line(
    (-3.6, line-y),
    (4.6, line-y),
    stroke: (paint: c-edge, thickness: t-ed),
    mark: (end: ">", fill: c-edge),
  )

  // Предельные ординалы (ω, ω·2, ω²) выделены тёплым акцентом.
  let ord-node(pos, label, limit: false) = {
    let st = if limit {
      (paint: c-hot, thickness: t-bd)
    } else {
      (paint: c-bd, thickness: t-bd)
    }
    draw.circle(
      (pos, line-y),
      radius: r,
      fill: c-fl,
      stroke: st,
    )
    draw.content(
      (pos, line-y - 0.55),
      text(
        size: s-cap,
        fill: if limit { c-hot } else { c-muted },
        weight: if limit { "bold" } else { "regular" },
      )[#label],
    )
  }

  ord-node(-3, [0])
  ord-node(-2, [1])
  ord-node(-1, [2])
  ord-node(0, [$omega$], limit: true)
  ord-node(1, [$omega + 1$])
  ord-node(2.5, [$omega dot 2$], limit: true)
  ord-node(4, [$omega^2$], limit: true)

  draw.content((3.3, line-y), text(size: s-cap, fill: c-muted)[$dots$])
})
