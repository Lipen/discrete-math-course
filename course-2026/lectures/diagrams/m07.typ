// M05 diagrams --- Cantor diagonal, QQ pairing, line-to-square.
// Скопировано из book/diagrams/m12.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

#let cantor-diagonal = canvas({
  let cantor-bg = oklch(97%, 0.005, 260deg)
  let cantor-diag = oklch(60%, 0.22, 22deg)
  let cantor-digit = oklch(30%, 0.02, 265deg)
  let cantor-constr = oklch(50%, 0.18, 250deg)
  let cantor-mismatch = oklch(55%, 0.20, 22deg)

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

  // Constructed number r (named digit positions --- must precede arrows)
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
#let qq-pairing = canvas(y: -1, {
  let size = 5

  // Column/row labels
  for i in range(1, size + 1) {
    draw.content((i + 0.5, 1), anchor: "south", padding: 0.3, text(
      size: 0.8em,
      fill: luma(45%),
    )[$#i$])
    draw.content((1, i + 0.5), anchor: "east", padding: 0.3, text(
      size: 0.8em,
      fill: luma(45%),
    )[$#i$])
  }

  // Diagonal path arrows
  let cells = ()
  for s in range(2, size * size) {
    // s = i + j
    for i in range(calc.max(1, s - size), calc.min(size, s - 1) + 1) {
      let j = s - i
      cells.push((i, j))
    }
  }
  let color = oklch(55%, 0.20, 22deg)
  let path-color = color.transparentize(50%)
  for idx in range(1, cells.len()) {
    let (i_prev, j_prev) = cells.at(idx - 1)
    let (i_curr, j_curr) = cells.at(idx)
    let x = j_prev
    let y = i_prev
    let start = (j_prev + 0.5, i_prev + 0.5)
    let end = (j_curr + 0.5, i_curr + 0.5)
    draw.line(
      start,
      end,
      stroke: 0.5pt + path-color,
      mark: (end: "stealth", fill: path-color),
    )
    draw.content(
      (x + 0.5, y),
      anchor: "north",
      padding: 0.1,
      text(
        size: 0.5em,
        fill: color,
        weight: "bold",
      )[#idx],
    )
  }

  // Grid
  for i in range(1, size + 1) {
    for j in range(1, size + 1) {
      let x = j
      let y = i
      let n = i + j + 1
      // Cell fill based on diagonal
      let clr = oklch(75%, 0.1, 260deg - n * 30deg).transparentize(80%)
      draw.rect(
        (x, y),
        (x + 1, y + 1),
        fill: clr,
        stroke: 0.3pt + luma(85%),
      )
      draw.content(
        (x + 0.5, y + 1),
        anchor: "south",
        padding: 0.1,
        text(
          size: 0.8em,
          fill: luma(35%),
        )[$(#i, #j)$],
      )
    }
  }
})

// --- Line to square: |L| = |S| ---
#let cantor-line-square = canvas({
  let w = 2
  let gap = 1.5

  // Unit segment L
  draw.line((0, 0), (w, 0), mark: (symbol: "|"))
  draw.content((w / 2, w / 2))[$L = [0,1]$]

  // Unit square S
  draw.rect((w + gap, 0), (w + gap + w, w), fill: luma(95%))
  draw.content((w + gap + w / 2, w / 2))[$S = [0,1]^2$]

  // ≈ between them
  draw.content((w + gap / 2, w / 2))[$approx$]
})

// --- Aleph and Beth hierarchies ---
#let aleph-beth = canvas({
  let gap = 2.4
  let y = 1.5

  let c-aleph-fill = oklch(90%, 0.06, 22deg)
  let c-aleph-str = oklch(55%, 0.12, 22deg)
  let c-beth-fill = oklch(90%, 0.06, 155deg)
  let c-beth-str = oklch(50%, 0.10, 155deg)
  let c-qmark = oklch(50%, 0.02, 265deg)

  let node(pos, label, name, fill, str) = {
    let (x, yy) = pos
    draw.rect(
      (x - 1.2, yy + 0.42),
      (x + 1.2, yy - 0.42),
      name: name,
      fill: fill,
      stroke: 0.9pt + str,
      radius: 5pt,
    )
    draw.content((x, yy), text(size: 0.68em, fill: luma(25%))[#label])
  }

  // ── Shared start: aleph_0 = beth_0 = |NN| ──
  node((0, y), $aleph_0 = beth_0 = abs(NN)$, "start", luma(92%), oklch(55%, 0.02, 265deg))

  // ── Aleph chain (top) ──
  node((gap, 2 * y), $aleph_1$, "a1", c-aleph-fill, c-aleph-str)
  node((2 * gap, 2 * y), $aleph_2$, "a2", c-aleph-fill, c-aleph-str)
  node((3 * gap, 2 * y), $aleph_3$, "a3", c-aleph-fill, c-aleph-str)

  // ── Beth chain (bottom) ──
  node((gap, 0), $beth_1 = 2^(aleph_0)$, "b1", c-beth-fill, c-beth-str)
  node((2 * gap, 0), $beth_2 = 2^(beth_1)$, "b2", c-beth-fill, c-beth-str)
  node((3 * gap, 0), $beth_3 = 2^(beth_2)$, "b3", c-beth-fill, c-beth-str)

  // ── Start → aleph_1 (successor) ──
  draw.line("start", "a1", stroke: 0.7pt + c-aleph-str, mark: (end: "stealth", fill: c-aleph-str))
  // ── Start → beth_1 (powerset) ──
  draw.line("start", "b1", stroke: 0.7pt + c-beth-str, mark: (end: "stealth", fill: c-beth-str))

  // ── Aleph chain edges ──
  draw.line("a1", "a2", stroke: 0.7pt + c-aleph-str, mark: (end: "stealth", fill: c-aleph-str))
  draw.line("a2", "a3", stroke: 0.7pt + c-aleph-str, mark: (end: "stealth", fill: c-aleph-str))

  // ── Beth chain edges ──
  draw.line("b1", "b2", stroke: 0.7pt + c-beth-str, mark: (end: "stealth", fill: c-beth-str))
  draw.line("b2", "b3", stroke: 0.7pt + c-beth-str, mark: (end: "stealth", fill: c-beth-str))

  // ── CH question mark between aleph_1 and beth_1 ──
  draw.line(
    "a1",
    "b1",
    stroke: (paint: c-qmark, thickness: 1.4pt, dash: "dashed"),
    mark: none,
  )
  draw.content((gap, y + 0.25), text(size: 1.1em, fill: c-qmark)[$?$])

  // ── Labels: successor vs powerset ──
  draw.content((gap / 2, 2 * y + 0.6), text(size: 0.6em, fill: c-aleph-str)["следующий"])
  draw.content((gap / 2, -0.6), text(size: 0.6em, fill: c-beth-str)["булеан"])
})
