// Коды и сжатие: дерево Хаффмана, шары Хэмминга, группы проверок Хэмминга.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── Дерево Хаффмана: путь от корня к листу даёт кодовое слово ──
#let huffman-tree = canvas({
  let inner(pos, name, weight) = {
    draw.circle(
      pos,
      radius: 0.24,
      fill: white,
      stroke: (paint: cool, thickness: 1.1pt),
      name: name,
    )
    mark(pos, weight, size: 0.45em)
  }
  let leaf(pos, name, letter, weight, tone: cool) = {
    cell(name, pos, tone: tone, size: 0.3, radius: 0.12)
    mark(pos, text(weight: "bold")[#letter], size: 0.5em)
    mark((pos.at(0), pos.at(1) - 0.52), weight, size: 0.42em)
  }
  let branch(a, b, stroke: edge-plain) = draw.line(a, b, stroke: stroke)
  let bit(a, b, value, side) = draw.content(
    (a, 55%, b),
    offset: (side * 0.18, 0.07),
    text(size: 0.5em, fill: ink)[$#value$],
  )

  inner((0, 0), "root", $1.0$)
  leaf((-1.75, -0.9), "A", [$A$], $0.40$, tone: warm)
  inner((0.75, -0.9), "R", $0.60$)
  leaf((-0.25, -1.8), "B", [$B$], $0.25$)
  inner((1.25, -1.8), "R2", $0.35$)
  leaf((0.5, -2.7), "C", [$C$], $0.20$)
  inner((1.75, -2.7), "R3", $0.15$)
  leaf((1.25, -3.6), "D", [$D$], $0.10$)
  leaf((2.25, -3.6), "E", [$E$], $0.05$)

  branch("root", "A", stroke: edge-hot)
  branch("root", "R")
  branch("R", "B")
  branch("R", "R2")
  branch("R2", "C")
  branch("R2", "R3")
  branch("R3", "D")
  branch("R3", "E")

  bit("root", "A", 0, -1)
  bit("root", "R", 1, 1)
  bit("R", "B", 0, -1)
  bit("R", "R2", 1, 1)
  bit("R2", "C", 0, -1)
  bit("R2", "R3", 1, 1)
  bit("R3", "D", 0, -1)
  bit("R3", "E", 1, 1)
})

// ── Шары Хэмминга: радиус t, расстояние d между словами ──
#let hamming-spheres = canvas({
  let r = 0.62
  let cw1 = (0.9, 1.5)
  let cw2 = (3.1, 1.5)
  let cw3 = (2.0, -0.15)

  let ball(center, noise) = {
    draw.circle(center, radius: r, fill: panel-cool, stroke: (
      paint: cool.lighten(40%),
      thickness: 0.7pt,
    ))
    for p in noise {
      draw.circle(
        (center.at(0) + p.at(0), center.at(1) + p.at(1)),
        radius: 0.04,
        fill: ink-soft,
      )
    }
    draw.circle(center, radius: 0.09, fill: warm)
  }

  ball(cw1, (
    (0.14, 0.26),
    (-0.26, -0.18),
    (0.05, -0.34),
    (0.31, -0.1),
    (-0.21, 0.21),
    (-0.11, -0.36),
    (-0.3, 0.04),
    (0.36, -0.22),
  ))
  ball(cw2, (
    (-0.08, 0.28),
    (0.23, 0.13),
    (-0.23, -0.11),
    (-0.03, -0.23),
    (0.13, -0.21),
    (-0.18, 0.11),
    (0.31, 0.03),
    (-0.26, -0.26),
  ))
  ball(cw3, (
    (0.18, 0.18),
    (-0.13, 0.23),
    (0.03, -0.16),
    (-0.23, -0.13),
    (0.31, 0.0),
    (-0.06, -0.26),
    (-0.21, 0.13),
  ))

  // Радиус и расстояние --- чистая геометрия.
  draw.line((cw1.at(0) - 0.11, cw1.at(1)), (cw1.at(0) - r, cw1.at(1)), stroke: (
    paint: ink,
    thickness: 0.6pt,
  ))
  draw.line(
    (cw1.at(0) - r, cw1.at(1) - 0.06),
    (cw1.at(0) - r, cw1.at(1) + 0.06),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  mark((cw1.at(0) - (r + 0.11) / 2, cw1.at(1) + 0.14), $t$, size: 0.45em)

  draw.line(cw1, cw2, stroke: (paint: ink, thickness: 0.6pt))
  draw.line(
    (cw1.at(0), cw1.at(1) - 0.06),
    (cw1.at(0), cw1.at(1) + 0.06),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  draw.line(
    (cw2.at(0), cw2.at(1) - 0.06),
    (cw2.at(0), cw2.at(1) + 0.06),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  mark((2.0, 1.66), $d$, size: 0.45em)
})

// ── Проверки чётности Хэмминга: p_i контролируют свои позиции ──
#let hamming-groups = canvas({
  let xs = (0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0)
  let cy = 3.2
  let rows = (2.4, 1.95, 1.5, 1.05)
  let row-names = ($d_1$, $d_2$, $d_3$, $d_4$)

  for (i, y) in rows.enumerate() {
    draw.line((-0.35, y), (3.35, y), stroke: edge-thin)
    mark((-0.72, y), row-names.at(i), size: 0.45em)
  }

  let parity(name, x, label, num, tone, covers) = {
    vertex(name, (x, cy), tone: tone, size: 0.26)
    mark((x, cy), label, size: 0.45em)
    mark((x, cy + 0.45), num, size: 0.42em)
    draw.line((x, cy - 0.26), (x, rows.at(covers.last())), stroke: (
      paint: tone,
      thickness: 1.1pt,
    ))
    for j in covers {
      draw.circle((x, rows.at(j)), radius: 0.075, fill: tone)
    }
  }
  let databit(name, x, label, num, row) = {
    cell(name, (x, cy), tone: ink, size: 0.23, radius: 0.08)
    mark((x, cy), label, size: 0.42em)
    mark((x, cy + 0.45), num, size: 0.42em)
    draw.line((x, cy - 0.23), (x, rows.at(row)), stroke: edge-thin)
    draw.circle((x, rows.at(row)), radius: 0.06, fill: ink-soft)
  }

  parity("p1", xs.at(0), $p_1$, [1], cool, (0, 1, 3))
  parity("p2", xs.at(1), $p_2$, [2], green, (0, 2, 3))
  databit("d1", xs.at(2), $d_1$, [3], 0)
  parity("p4", xs.at(3), $p_4$, [4], violet, (1, 2, 3))
  databit("d2", xs.at(4), $d_2$, [5], 1)
  databit("d3", xs.at(5), $d_3$, [6], 2)
  databit("d4", xs.at(6), $d_4$, [7], 3)
})
