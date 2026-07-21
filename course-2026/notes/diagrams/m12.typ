// M12 diagrams — Transfinite: Cantor diagonal, QQ pairing, ordinals, Banach--Tarski.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let cantor-bg = oklch(97%, 0.005, 260deg)
#let cantor-diag = oklch(60%, 0.22, 22deg)
#let cantor-digit = oklch(30%, 0.02, 265deg)
#let cantor-constr = oklch(50%, 0.18, 250deg)
#let cantor-mismatch = oklch(55%, 0.20, 22deg)

#let cantor-diagonal = canvas({
  let s = 0.72
  let rows = 5
  let cols = 7
  let digits = (
    (3, 5, 2, 7, 1, 4, 8),
    (1, 8, 4, 6, 2, 9, 0),
    (7, 2, 5, 9, 3, 0, 6),
    (0, 3, 1, 8, 6, 2, 7),
    (9, 4, 7, 2, 0, 5, 3),
  )
  let constructed = (4, 4, 4, 4, 4)

  // Matrix background
  draw.rect(
    (-0.7, 0.5),
    (cols * s + 0.2, -(rows + 0.3) * s),
    fill: cantor-bg,
    stroke: none,
    radius: 4pt,
  )

  // Rows
  for i in range(rows) {
    draw.content((-0.4, -(i + 0.5) * s), text(
      size: 0.6em,
      fill: luma(45%),
    )[$r_#(i + 1)$])
    for j in range(cols) {
      let x = j * s + 0.1
      let y = -(i + 0.5) * s
      let is-diag = (i == j)
      if is-diag {
        draw.rect(
          (x - 0.05, y - 0.32),
          (x + s - 0.05, y + 0.32),
          fill: cantor-diag.transparentize(80%),
          stroke: cantor-diag + 0.8pt,
          radius: 2pt,
          name: "d" + str(i),
        )
      }
      draw.content((x + s / 2, y), text(
        size: 0.7em,
        fill: if is-diag { cantor-diag } else { cantor-digit },
        weight: if is-diag { "bold" } else { "regular" },
      )[#digits.at(i).at(j)])
    }
  }

  // Ellipsis
  draw.content((cols * s + 0.5, -(rows / 2) * s), text(
    size: 0.65em,
    fill: luma(50%),
  )[$dots$])

  // Constructed number r (named digit positions — must precede arrows)
  draw.content((-0.4, -(rows + 1.2) * s), text(
    size: 0.65em,
    weight: "bold",
    fill: cantor-constr,
  )[$r = 0.$])
  for j in range(rows) {
    let x = j * s + s / 2 + 0.1
    draw.content((x, -(rows + 1.2) * s), name: "r" + str(j), text(
      size: 0.75em,
      fill: cantor-constr,
      weight: "bold",
    )[#constructed.at(j)])
  }
  draw.content((rows * s + 0.3, -(rows + 1.2) * s), text(
    size: 0.65em,
    fill: oklch(50%, 0.16, 300deg),
  )[$dots not in {r_1, r_2, dots}$])

  // Vertical dashed arrows: diagonal cell → constructed digit
  for i in range(rows) {
    draw.line(
      "d" + str(i) + ".south",
      "r" + str(i) + ".north",
      stroke: (
        paint: cantor-constr.transparentize(50%),
        thickness: 0.4pt,
        dash: "dashed",
      ),
      name: "arr" + str(i),
    )
    draw.content(
      "arr" + str(i) + ".mid",
      text(size: 0.5em, fill: cantor-mismatch)[$≠$],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 0.5pt,
      anchor: "west",
    )
  }
})

// --- QQ diagonal pairing matrix ---
#let qq-pairing = canvas({
  let s = 0.55
  let size = 6
  let bg = oklch(97%, 0.005, 260deg)
  let path-color = oklch(55%, 0.20, 22deg)

  // Column/row labels
  draw.content((0.1, 0.65), text(size: 0.6em, fill: luma(45%))[$1$])
  draw.content((-0.5, -0.3), text(size: 0.6em, fill: luma(45%))[$1$])
  for i in range(2, size + 1) {
    draw.content((i * s - s / 2, 0.65), text(
      size: 0.6em,
      fill: luma(45%),
    )[$#i$])
    draw.content((-0.5, -(i - 0.5) * s), text(
      size: 0.6em,
      fill: luma(45%),
    )[$#i$])
  }

  // Grid with diagonal path
  for i in range(size) {
    for j in range(size) {
      let x = j * s
      let y = -(i + 1) * s + 0.3
      let n = i + j + 1
      // Cell fill based on diagonal
      let clr = oklch(75%, 0.02, 260deg - n * 30deg)
      draw.rect(
        (x, y - 0.3),
        (x + s, y + 0.3),
        fill: clr,
        stroke: 0.3pt + luma(85%),
      )
      draw.content((x + s / 2, y), text(
        size: 0.55em,
        fill: luma(35%),
      )[$(#(i + 1),#(j + 1))$])
    }
  }

  // Diagonal path arrows
  for k in range(0, size * 2 - 1) {
    let start = calc.max(0, k - size + 1)
    let r0 = start
    let c0 = k - start
    if r0 < size and c0 < size {
      let x = c0 * s + s / 2
      let y = -(r0 + 1) * s + 0.3
      draw.content((x, y + 0.15), text(
        size: 0.48em,
        fill: oklch(55%, 0.22, 22deg),
        weight: "bold",
      )[$#(k + 1)$])
    }
  }
})

// --- Ordinal visualization ---
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
    end: ">",
  ))
})

// --- Banach-Tarski sphere decomposition sketch ---
#let banach-tarski = canvas({
  let s = 1.2

  // Three spheres: original → decomposition → two spheres
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
    end: ">",
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
  )[Разбиение сферы на 5 частей (вращения + AC) $→$ два шара того же радиуса.])
})
