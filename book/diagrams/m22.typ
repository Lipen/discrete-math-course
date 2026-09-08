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

  draw.content((0, 1.25), text(
    size: s-node,
    fill: c-ink,
    weight: "bold",
  )[Исходный шар])
  draw.content((3.5, 1.25), text(
    size: s-node,
    fill: c-ink,
    weight: "bold",
  )[Два шара])

  draw.content(
    (2.1, -1.4),
    text(
      size: s-cap,
      fill: c-muted,
    )[Разбиение сферы на 5 частей (вращения + AC) $->$ два шара того же радиуса.],
  )
})

// ── Ординалы фон Неймана ──
#let von-neumann-nesting = canvas({
  let nesting-box(min, max, tag, label) = {
    draw.rect(min, max, name: tag, stroke: t-bd + c-bd)
    draw.content(
      (min.at(0) + 0.18, max.at(1) - 0.17),
      text(size: s-node, fill: c-ink)[#label],
    )
  }

  nesting-box((-0.4, -0.3), (0.4, 0.3), "vn-0", $0$)
  nesting-box((-0.9, -0.62), (0.9, 0.62), "vn-1", $1$)
  nesting-box((-1.45, -1.0), (1.45, 1.0), "vn-2", $2$)
  nesting-box((-2.0, -1.42), (2.0, 1.42), "vn-3", $3$)

  // Пунктир: omega --- предельный ординал, его нельзя получить шагом n -> n + 1.
  let omega-stroke = (paint: c-edge, thickness: t-bd, dash: "dashed")
  draw.rect(
    (-2.85, -1.95),
    (2.85, 1.95),
    name: "vn-omega",
    stroke: omega-stroke,
  )
  draw.content((3.15, 1.95), text(size: s-node, fill: c-ink)[$omega$])
  draw.content((0, -1.68), text(size: s-cap, fill: c-muted)[$dots.c$])
})
