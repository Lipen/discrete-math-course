// Combinatorics: Pascal triangle, inclusion-exclusion.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── Inclusion-exclusion Venn ──
#let venn-inclusion-exclusion = canvas({
  let r = 1.05
  let pa = (-0.65, 0.375)
  let pb = (0.65, 0.375)
  let pc = (0, -0.775)

  draw.circle(
    pa,
    radius: r,
    fill: cool.transparentize(78%),
    stroke: 1.2pt + cool,
    name: "set-a",
  )
  draw.circle(
    pb,
    radius: r,
    fill: green.transparentize(78%),
    stroke: 1.2pt + green,
    name: "set-b",
  )
  draw.circle(
    pc,
    radius: r,
    fill: violet.transparentize(78%),
    stroke: 1.2pt + violet,
    name: "set-c",
  )

  mark((-1.5, 1.3), text(weight: "bold")[$A$], tone: cool)
  mark((1.5, 1.3), text(weight: "bold")[$B$], tone: green)
  mark((0, -1.98), text(weight: "bold")[$C$], tone: violet)

  mark((-1.05, 0.1), $+1$)
  mark((1.05, 0.1), $+1$)
  mark((0, -1.42), $+1$)
  mark((0, 0.66), $-1$)
  mark((-0.52, -0.36), $-1$)
  mark((0.52, -0.36), $-1$)
  // тройное пересечение --- единственная область, поправка для которой положительна
  mark((0, -0.02), text(weight: "bold")[$+1$], tone: warm)
})

// ── Pascal triangle ──
#let pascal-triangle = canvas({
  let s = 0.31
  let h = 0.525
  let rows = (
    (1,),
    (1, 1),
    (1, 2, 1),
    (1, 3, 3, 1),
    (1, 4, 6, 4, 1),
    (1, 5, 10, 10, 5, 1),
    (1, 6, 15, 20, 15, 6, 1),
  )

  // ось симметрии
  draw.line((0, 3.65), (0, -0.45), stroke: edge-soft)

  for (n, row) in rows.enumerate() {
    for (k, val) in row.enumerate() {
      let x = (2 * k - n) * s
      let y = (rows.len() - 1 - n) * h
      let boundary = k == 0 or k == n
      mark((x, y), [#val], tone: if boundary { ink-soft } else { ink })
    }
  }

  // тождество Паскаля: два десятка сверху дают двадцатку снизу
  for pos in ((-s, h), (s, h), (0, 0)) {
    draw.circle(pos, radius: 0.19, fill: cool.lighten(82%), stroke: none)
  }
  mark((-s, h), text(weight: "bold")[10], tone: cool)
  mark((s, h), text(weight: "bold")[10], tone: cool)
  mark((0, 0), text(weight: "bold")[20], tone: cool)
})
