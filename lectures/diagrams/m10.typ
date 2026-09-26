// Карта Карно и ROBDD для XOR.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-km-line = oklch(35%, 0.02, 265deg) + 0.5pt
#let c-km-fill = oklch(88%, 0.03, 155deg)
#let c-km-num = oklch(35%, 0.02, 265deg)

// Example: Karnaugh map for f(x,y,z) = xy + xz + yz (majority function).
// Filled cells show where f = 1.
#let karnaugh-3var-majority = canvas({
  let s = 0.6
  let rows = 4
  let cols = 2

  // Grid
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: c-km-line)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: c-km-line)
  }

  // Filled cells: minterms where majority(x,y,z)=1
  let ones = ((1, 1), (2, 0), (2, 1), (3, 1))
  for (row, col) in ones {
    draw.rect(
      (col * s, -row * s),
      ((col + 1) * s, -(row + 1) * s),
      fill: c-km-fill,
      stroke: none,
    )
  }

  // Cell labels
  for (row, col) in ones {
    draw.content(((col + 0.5) * s, -(row + 0.5) * s), text(
      size: 0.45em,
      fill: c-km-num,
    )[1])
  }

  // Row labels (yz)
  let yz = ("00", "01", "11", "10")
  for (i, label) in yz.enumerate() {
    draw.content((-0.2, -(i + 0.5) * s), anchor: "east", text(
      size: 0.42em,
      fill: c-km-num,
    )[#label])
  }

  // Column labels
  draw.content((0.5 * s, 0.18), anchor: "south", text(
    size: 0.42em,
    fill: c-km-num,
  )[$x$])
  for j in range(cols) {
    draw.content(((j + 0.5) * s, 0.13), anchor: "south", text(
      size: 0.4em,
      fill: c-km-num,
    )[#j])
  }

  draw.content((-0.5, -2 * s), anchor: "east", text(
    size: 0.42em,
    fill: c-km-num,
  )[$y z$])
})

// ── BDD для XOR ──
#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.8pt + oklch(60%, 0.08, 250deg)
#let c-leaf-fill = oklch(91%, 0.025, 155deg)

#let bdd-xor = {
  let vnode(pos, name, body) = node(
    pos,
    text(size: 0.8em, fill: c-km-num)[#body],
    name: name,
    shape: circle,
    fill: n-fill,
    stroke: n-str,
    width: 1.3em,
    height: 1.3em,
    inset: 0pt,
  )
  let tnode(pos, name, val) = node(
    pos,
    text(size: 0.8em, fill: c-km-num)[#val],
    name: name,
    fill: c-leaf-fill,
    stroke: n-str,
    inset: 4pt,
  )
  let bedge(from, to, bit) = edge(
    from,
    to,
    "-",
    stroke: if bit == 0 {
      (paint: c-km-num, thickness: 0.7pt, dash: "dashed")
    } else {
      (paint: c-km-num, thickness: 0.7pt)
    },
    label: text(size: 0.55em, fill: c-km-num)[$#bit$],
    label-pos: 30%,
    label-side: center,
    label-fill: white,
  )

  diagram(
    spacing: 2.6em,
    vnode((0, 0), <x>, $x$),
    vnode((-1.5, 1), <y-lo>, $y$),
    vnode((1.5, 1), <y-hi>, $y$),
    tnode((-1.2, 2), <t0>, 0),
    tnode((1.2, 2), <t1>, 1),
    bedge(<x>, <y-lo>, 0),
    bedge(<x>, <y-hi>, 1),
    bedge(<y-lo>, <t0>, 0),
    bedge(<y-lo>, <t1>, 1),
    bedge(<y-hi>, <t1>, 0),
    bedge(<y-hi>, <t0>, 1),
  )
}
