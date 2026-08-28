#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Банах-Тарский ──
#let banach-tarski = canvas({
  let r = 0.65 // единый радиус: результат --- два шара того же радиуса, что и исходный.
  let ball(center, label, tag) = {
    draw.circle(center, radius: r, fill: c-fl, stroke: t-bd + c-bd, name: tag)
    draw.content(center, text(size: s-node, fill: c-ink)[#label])
  }

  ball((0, 0), $B$, "bsrc")
  ball((2.8, 0.28), $B_1$, "b1")
  draw.line(
    "bsrc.east",
    (2.1, 0),
    stroke: t-ed + c-hot,
    mark: (end: ">", fill: c-hot),
    name: "split",
  )
  draw.content(
    "split",
    text(size: s-cap, fill: c-hot)[5 частей],
    fill: white,
    stroke: none,
    padding: 2pt,
  )

  draw.content((0, 1.25), text(size: s-node, fill: c-ink, weight: "bold")[Исходный шар])
  draw.content((3.5, 1.25), text(size: s-node, fill: c-ink, weight: "bold")[Два шара])

  draw.content(
    (2.1, -1.4),
    text(size: s-cap, fill: c-muted)[Разбиение сферы на 5 частей (вращения + AC) $->$ два шара того же радиуса.],
  )
})
