// m21 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let banach-tarski = canvas({
  let s = 1.2

  // Labels
  draw.content((0, 1.5), text(weight: "bold", size: 0.9em)[Исходный шар])
  draw.content((s * 3, 1.5), text(weight: "bold", size: 0.9em)[Два шара])

  // Left: single sphere
  draw.circle(
    (0, 0),
    radius: 1.0,
    fill: oklch(65%, 0.14, 250deg).transparentize(80%),
    stroke: 0.5pt + oklch(55%, 0.14, 250deg),
  )
  draw.content((0, 0), text(weight: "bold", size: 0.85em, fill: oklch(
    55%,
    0.14,
    250deg,
  ))[$B$])

  // Arrow
  draw.line((1.0, 0), (s * 2 - 1.0, 0), stroke: 0.5pt + luma(50%), mark: (
    end: ">", fill: luma(50%),
  ))
  draw.content((s * 1.5, 0.4), text(size: 0.55em, fill: luma(40%))[5 частей])

  // Right: two spheres
  draw.circle(
    (s * 3 - 0.45, 0.15),
    radius: 0.65,
    fill: oklch(65%, 0.12, 22deg).transparentize(80%),
    stroke: 0.5pt + oklch(55%, 0.12, 22deg),
  )
  draw.content((s * 3 - 0.45, 0.15), text(size: 0.7em, fill: oklch(
    55%,
    0.12,
    22deg,
  ))[$B_1$])
  draw.circle(
    (s * 3 + 0.45, -0.15),
    radius: 0.65,
    fill: oklch(65%, 0.12, 310deg).transparentize(80%),
    stroke: 0.5pt + oklch(55%, 0.12, 310deg),
  )
  draw.content((s * 3 + 0.45, -0.15), text(size: 0.7em, fill: oklch(
    55%,
    0.12,
    310deg,
  ))[$B_2$])

  // Caption below
  draw.content((s * 1.5, -1.6), text(
    size: 0.55em,
    fill: luma(45%),
  )[Разбиение сферы на 5 частей (вращения + AC) $->$ два шара того же радиуса.])
})
