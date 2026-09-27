// Коды и сжатие: дерево Хаффмана, шары Хэмминга, группы проверок Хэмминга.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── Дерево Хаффмана: путь от корня к листу даёт кодовое слово ──
#let huffman-tree = canvas({
  let inner(pos, name, weight) = {
    draw.circle(
      pos,
      radius: 0.33,
      fill: cool.lighten(82%),
      stroke: (paint: cool, thickness: 1.1pt),
      name: name,
    )
    mark(pos, weight)
  }
  let leaf(pos, name, letter, weight, tone: cool) = {
    cell(name, pos, tone: tone, size: 0.34, radius: 0.12)
    mark(pos, text(weight: "bold")[#letter])
    mark((pos.at(0), pos.at(1) - 0.6), weight)
  }
  let branch(a, b, stroke: edge-plain) = draw.line(a, b, stroke: stroke)
  let bit(a, b, value, side) = draw.content(
    (a, 55%, b),
    offset: (side * 0.22, 0.09),
    text(fill: ink)[$#value$],
  )

  inner((0, 0), "root", $1.0$)
  leaf((-2.15, -1.1), "A", [$A$], $0.40$, tone: warm)
  inner((0.9, -1.1), "R", $0.60$)
  leaf((-0.35, -2.2), "B", [$B$], $0.25$)
  inner((1.5, -2.2), "R2", $0.35$)
  leaf((0.6, -3.3), "C", [$C$], $0.20$)
  inner((2.1, -3.3), "R3", $0.15$)
  leaf((1.5, -4.4), "D", [$D$], $0.10$)
  leaf((2.7, -4.4), "E", [$E$], $0.05$)

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
  let r = 0.8
  let cw1 = (0.95, 1.9)
  let cw2 = (3.65, 1.9)
  let cw3 = (2.3, -0.2)

  let ball(center, noise) = {
    draw.circle(center, radius: r, fill: panel-cool, stroke: (
      paint: cool.lighten(40%),
      thickness: 0.7pt,
    ))
    for p in noise {
      draw.circle(
        (center.at(0) + p.at(0), center.at(1) + p.at(1)),
        radius: 0.045,
        fill: ink-soft,
      )
    }
    draw.circle(center, radius: 0.1, fill: warm)
  }

  ball(cw1, (
    (0.17, 0.33),
    (-0.32, -0.22),
    (0.06, -0.42),
    (0.38, -0.12),
    (-0.26, 0.26),
    (-0.14, -0.45),
    (-0.37, 0.05),
    (0.44, -0.27),
  ))
  ball(cw2, (
    (-0.1, 0.34),
    (0.28, 0.16),
    (-0.28, -0.14),
    (-0.04, -0.29),
    (0.16, -0.26),
    (-0.22, 0.14),
    (0.38, 0.04),
    (-0.32, -0.32),
  ))
  ball(cw3, (
    (0.22, 0.22),
    (-0.16, 0.28),
    (0.04, -0.2),
    (-0.28, -0.16),
    (0.38, 0.0),
    (-0.08, -0.32),
    (-0.26, 0.16),
  ))

  // Радиус и расстояние --- чистая геометрия.
  draw.line((cw1.at(0) - 0.14, cw1.at(1)), (cw1.at(0) - r, cw1.at(1)), stroke: (
    paint: ink,
    thickness: 0.6pt,
  ))
  draw.line(
    (cw1.at(0) - r, cw1.at(1) - 0.07),
    (cw1.at(0) - r, cw1.at(1) + 0.07),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  mark((cw1.at(0) - r - 0.24, cw1.at(1)), $t$)

  draw.line(cw1, cw2, stroke: (paint: ink, thickness: 0.6pt))
  draw.line(
    (cw1.at(0), cw1.at(1) - 0.07),
    (cw1.at(0), cw1.at(1) + 0.07),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  draw.line(
    (cw2.at(0), cw2.at(1) - 0.07),
    (cw2.at(0), cw2.at(1) + 0.07),
    stroke: (paint: ink, thickness: 0.5pt),
  )
  mark((2.3, 2.14), $d$)
})

// ── Проверки чётности Хэмминга: p_i контролируют свои позиции ──
#let hamming-groups = canvas({
  let xs = (0.0, 0.68, 1.36, 2.04, 2.72, 3.4, 4.08)
  let cy = 3.8
  let rows = (2.95, 2.38, 1.81, 1.24)
  let row-names = ($d_1$, $d_2$, $d_3$, $d_4$)

  for (i, y) in rows.enumerate() {
    draw.line((-0.45, y), (4.5, y), stroke: edge-thin)
    mark((-0.85, y), row-names.at(i))
  }

  let parity(name, x, label, num, tone, covers) = {
    vertex(name, (x, cy), tone: tone, size: 0.32)
    mark((x, cy), label)
    mark((x, cy + 0.58), num)
    draw.line((x, cy - 0.32), (x, rows.at(covers.last())), stroke: (
      paint: tone,
      thickness: 1.1pt,
    ))
    for j in covers {
      draw.circle((x, rows.at(j)), radius: 0.09, fill: tone)
    }
  }
  let databit(name, x, label, num, row) = {
    cell(name, (x, cy), tone: ink, size: 0.28, radius: 0.08)
    mark((x, cy), label)
    mark((x, cy + 0.58), num)
    draw.line((x, cy - 0.28), (x, rows.at(row)), stroke: edge-thin)
    draw.circle((x, rows.at(row)), radius: 0.075, fill: ink-soft)
  }

  parity("p1", xs.at(0), $p_1$, [1], cool, (0, 1, 3))
  parity("p2", xs.at(1), $p_2$, [2], green, (0, 2, 3))
  databit("d1", xs.at(2), $d_1$, [3], 0)
  parity("p4", xs.at(3), $p_4$, [4], violet, (1, 2, 3))
  databit("d2", xs.at(4), $d_2$, [5], 1)
  databit("d3", xs.at(5), $d_3$, [6], 2)
  databit("d4", xs.at(6), $d_4$, [7], 3)
})
