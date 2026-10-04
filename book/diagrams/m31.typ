#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Решётка знаков ──
#let sign-lattice = canvas({
  let snode(pos, name, label) = {
    draw.circle(pos, radius: 0.42, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(name, text(size: s-node, fill: c-ink, weight: "bold")[#label])
  }
  let e(from, to) = draw.line(from, to, stroke: (
    paint: c-edge,
    thickness: t-ed,
  ))

  snode((0, 2.4), "top", $top$)
  snode((-1.7, 0), "neg", $minus$)
  snode((0, 0), "zero", $0$)
  snode((1.7, 0), "pos", $plus$)
  snode((0, -2.4), "bot", $bot$)

  // Рёбра по именам узлов, слоем ниже: стыки линий скрыты заливкой.
  draw.on-layer(-1, {
    e("top", "neg")
    e("top", "zero")
    e("top", "pos")
    e("neg", "bot")
    e("zero", "bot")
    e("pos", "bot")
  })
})

// ── Widening для интервалов ──
#let widening = canvas({
  draw.line(
    (-0.6, -0.6),
    (11.6, -0.6),
    stroke: (paint: c-edge, thickness: t-hr),
  )
  draw.content(
    (0, -1.5),
    anchor: "center",
    fill: c-white,
    stroke: none,
    padding: 2pt,
  )[
    #text(size: s-cap, fill: c-muted)[$0$]
  ]
  draw.content((12, -1.5), anchor: "center")[
    #text(size: s-cap, fill: c-muted)[значение]
  ]

  for k in range(4) {
    if k == 0 {
      draw.circle((0, 0), radius: 0.06, fill: c-edge, stroke: none)
    } else {
      draw.line((0, k), (k, k), stroke: (paint: c-edge, thickness: t-ed))
    }
    draw.content(
      (-0.4, k),
      anchor: "east",
      fill: c-white,
      stroke: none,
      padding: 2pt,
    )[#text(size: s-cap, fill: c-muted)[$[0, #k]$]]
  }

  draw.content(
    (3.6, 3),
    anchor: "west",
    fill: c-white,
    stroke: none,
    padding: 2pt,
  )[
    #text(size: s-cap, fill: c-muted)[$dots$]
  ]

  draw.line((0, 5), (11.2, 5), stroke: (paint: c-hot, thickness: t-hi))
  draw.content(
    (11.5, 5),
    anchor: "west",
    fill: c-white,
    stroke: none,
    padding: 2pt,
  )[
    #text(size: s-node, fill: c-hot)[$[0, +oo]$]
  ]

  draw.line(
    (2.9, 3.2),
    (1.3, 4.55),
    stroke: (paint: c-hot, thickness: t-hi),
    mark: (end: "stealth", fill: c-hot),
  )
  draw.content(
    (2.6, 4.1),
    anchor: "west",
    fill: c-white,
    stroke: none,
    padding: 2pt,
  )[
    #text(size: s-node, fill: c-hot)[$nabla$]
  ]
})
