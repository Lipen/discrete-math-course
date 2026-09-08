#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-size = 1.5em
#let n-stroke = t-bd + c-bd
#let e-stroke = (paint: c-edge, thickness: t-ed)

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

  draw.content((1.75, line-y), text(size: s-cap, fill: c-muted)[$dots$])
})

// ── Дерево рождения сюрреальных чисел ──
#let surreal-tree = {
  let num-node(pos, body, name, hot: false) = node(
    pos,
    text(size: s-node, fill: c-ink)[#body],
    name: name,
    fill: c-fl,
    width: n-size,
    height: n-size,
    stroke: if hot { t-bd + c-hot } else { n-stroke },
  )

  let birth-edge(from, to) = edge(from, to, "-", stroke: e-stroke)

  let day(pos, body) = node(
    pos,
    text(size: s-cap, fill: c-muted)[#body],
    fill: none,
    stroke: none,
  )

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    day((-6.6, 0), [день 0]),
    day((-6.6, 2), [день 1]),
    day((-6.6, 4), [день 2]),
    day((-6.6, 5.1), $dots.v$),
    day((-6.6, 6.2), [день $omega$]),

    num-node((0, 0), $0$, <zero>),
    num-node((-2.1, 2), $-1$, <minus-one>),
    num-node((2.1, 2), $1$, <one>),
    num-node((-4.2, 4), $-2$, <minus-two>),
    num-node((-1.95, 4), $-1/2$, <minus-half>),
    num-node((1.95, 4), $1/2$, <half>),
    num-node((4.2, 4), $2$, <two>),
    // $omega$ и $epsilon$ --- рождения дня $omega$: тёплый контур выделяет новый сорт чисел.
    num-node((-0.75, 6.2), $epsilon$, <eps>, hot: true),
    num-node((4.2, 6.2), $omega$, <omega>, hot: true),
    day((5.9, 6.2), $dots$),

    birth-edge(<zero>, <minus-one>),
    birth-edge(<zero>, <one>),
    birth-edge(<zero>, <half>),
    birth-edge(<zero>, <minus-half>),
    birth-edge(<zero>, <eps>),
    birth-edge(<one>, <half>),
    birth-edge(<one>, <two>),
    birth-edge(<one>, <omega>),
    birth-edge(<one>, <eps>),
    birth-edge(<minus-one>, <minus-two>),
    birth-edge(<minus-one>, <minus-half>),
    birth-edge(<two>, <omega>),
    birth-edge(<half>, <eps>),
  )
}
