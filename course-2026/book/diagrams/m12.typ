// M12 diagrams --- Transfinite: Cantor diagonal, QQ pairing, ordinals, Banach--Tarski; Probability: Markov chain, probability tree, Bayesian network.
#import "../requirements.typ": *
#import cetz: canvas, draw

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

// ── 2-state Markov chain: weather model (Sunny / Rainy) ──
#let c-mc-state = oklch(88%, 0.03, 250deg)
#let c-mc-str = oklch(60%, 0.08, 250deg)
#let c-mc-edge = oklch(35%, 0.02, 265deg)
#let c-mc-label = oklch(30%, 0.02, 265deg)

#let markov-chain = canvas({

  // State node helper --- labeled circle
  let state(pos, label, name) = {
    let (x, y) = pos
    draw.circle(
      (x, y),
      radius: 0.5,
      name: name,
      fill: c-mc-state,
      stroke: 0.8pt + c-mc-str,
    )
    draw.content(
      (x, y),
      text(size: 0.9em, fill: c-mc-label, weight: "bold")[#label],
    )
  }

  // Edge label helper --- white-boxed text at midpoint of a named edge
  let elabel(edge-name, label-text, anchor: "south") = {
    draw.content(
      edge-name + ".mid",
      text(size: 0.7em, fill: c-mc-label)[#label-text],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
      anchor: anchor,
    )
  }

  // ── States ──
  state((0, 0), [$S$], "S")
  state((5, 0), [$R$], "R")

  // ── Transitions ──

  // S → R (forward, upper path)
  draw.line(
    "S.north-east",
    "R.north-west",
    name: "s-r",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("s-r", [$0.2$])

  // R → S (backward, lower path)
  draw.line(
    "R.south-west",
    "S.south-east",
    name: "r-s",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("r-s", [$0.4$])

  // S → S (self-loop, curved upward)
  draw.bezier(
    "S.north-west",
    "S.north-east",
    (-1.2, 1.5),
    (1.2, 1.5),
    name: "s-s",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("s-s", [$0.8$])

  // R → R (self-loop, curved upward)
  draw.bezier(
    "R.north-west",
    "R.north-east",
    (3.8, 1.5),
    (6.2, 1.5),
    name: "r-r",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("r-r", [$0.6$])
})

// ── Probability tree: biased coin, two tosses ──
#let c-pt-node = oklch(55%, 0.13, 250deg)
#let c-pt-leaf = oklch(55%, 0.12, 160deg)
#let c-pt-edge = oklch(35%, 0.02, 265deg)
#let c-pt-label = oklch(35%, 0.02, 265deg)
#let c-pt-prob = oklch(55%, 0.12, 22deg)

#let probability-tree = canvas({
  // Edge with probability label at midpoint (white-boxed for readability)
  let prob-edge(from, to, prob) = {
    let name = "e-" + from + "-" + to
    draw.line(from, to, stroke: 0.6pt + c-pt-edge, name: name)
    draw.content(
      name,
      text(size: 0.75em, fill: c-pt-label)[$#prob$],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
    )
  }

  // Leaf label: outcome below, probability above
  let leaf-label(name, outcome, prob) = {
    draw.content(
      name,
      anchor: "south",
      text(size: 0.7em, fill: c-pt-label)[#outcome],
      padding: 0.08,
    )
    draw.content(
      name,
      anchor: "north",
      text(size: 0.65em, fill: c-pt-prob)[$#prob$],
      padding: 0.06,
    )
  }

  // ── Nodes ──
  draw.circle((0, 3.5), radius: 0.15, fill: c-pt-node, name: "root")
  draw.circle((2, 1.8), radius: 0.14, fill: c-pt-node, name: "H")
  draw.circle((-2, 1.8), radius: 0.14, fill: c-pt-node, name: "T")
  draw.circle((3, 0), radius: 0.12, fill: c-pt-leaf, name: "HH")
  draw.circle((1, 0), radius: 0.12, fill: c-pt-leaf, name: "HT")
  draw.circle((-1, 0), radius: 0.12, fill: c-pt-leaf, name: "TH")
  draw.circle((-3, 0), radius: 0.12, fill: c-pt-leaf, name: "TT")

  // ── Edges with labels ──
  prob-edge("root", "H", 0.6)
  prob-edge("root", "T", 0.4)
  prob-edge("H", "HH", 0.6)
  prob-edge("H", "HT", 0.4)
  prob-edge("T", "TH", 0.6)
  prob-edge("T", "TT", 0.4)

  // ── Node labels (level 1) ──
  draw.content(
    "H",
    anchor: "west",
    text(size: 0.8em, fill: c-pt-node, weight: "bold")[$H$],
    padding: 0.15,
  )
  draw.content(
    "T",
    anchor: "east",
    text(size: 0.8em, fill: c-pt-node, weight: "bold")[$T$],
    padding: 0.15,
  )

  // ── Leaf labels ──
  leaf-label("HH", [$H H$], 0.36)
  leaf-label("HT", [$H T$], 0.24)
  leaf-label("TH", [$T H$], 0.24)
  leaf-label("TT", [$T T$], 0.16)
})

// ── Bayesian network: Flu → Cough, Flu → Fever ──
#let bayes-net = canvas({
  let c-bn-fill = oklch(92%, 0.04, 250deg)
  let c-bn-stroke = oklch(55%, 0.08, 250deg)
  let c-bn-label = oklch(30%, 0.02, 265deg)
  let c-bn-edge = oklch(35%, 0.02, 265deg)

  // Rounded rectangle node
  let node(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - 1.2, y + 0.45),
      (x + 1.2, y - 0.45),
      name: name,
      fill: c-bn-fill,
      stroke: 0.8pt + c-bn-stroke,
      radius: 8pt,
    )
    draw.content(
      (x, y),
      text(size: 0.9em, fill: c-bn-label, weight: "bold")[#label],
    )
  }

  // Directed edge
  let dir-edge(from-anchor, to-anchor) = {
    draw.line(
      from-anchor,
      to-anchor,
      stroke: 0.7pt + c-bn-edge,
      mark: (end: ">"),
    )
  }

  // ── Nodes ──
  node((0, 2.2), [Грипп], "flu")
  node((-2.5, -0.3), [Кашель], "cough")
  node((2.5, -0.3), [Температура], "fever")

  // ── Edges ──
  dir-edge("flu.south-west", "cough.north")
  dir-edge("flu.south-east", "fever.north")

  // ── CPT: Flu ──
  draw.content(
    "flu.east",
    text(size: 0.65em, fill: c-bn-label)[$P("Flu") = 0.05$],
    anchor: "west",
    padding: 0.3,
  )

  // ── CPT: Cough ──
  draw.content(
    "cough.east",
    anchor: "west",
    padding: 0.25,
    text(size: 0.6em, fill: c-bn-label)[
      $P("Cough" | "Flu") = 0.8$\
      $P("Cough" | not "Flu") = 0.1$
    ],
  )

  // ── CPT: Fever ──
  draw.content(
    "fever.east",
    anchor: "west",
    padding: 0.25,
    text(size: 0.6em, fill: c-bn-label)[
      $P("Fever" | "Flu") = 0.9$\
      $P("Fever" | not "Flu") = 0.05$
    ],
  )
})

// ── Hasse diagram of P({a,b,c}) ordered by inclusion ──
#let power-set-hasse = canvas({
  let xgap = 2
  let ygap = 1.5
  let w = 1.2
  let h = 0.6

  let c-powerset-fill = oklch(92%, 0.04, 155deg)
  let c-powerset-str = oklch(55%, 0.08, 250deg)
  let c-powerset-edge = oklch(40%, 0.02, 265deg)

  // Node helper: rounded rectangle with label
  let node(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - w / 2, y + h / 2),
      (x + w / 2, y - h / 2),
      name: name,
      fill: c-powerset-fill,
      stroke: 0.8pt + c-powerset-str,
      radius: 4pt,
    )
    draw.content((x, y), text(size: 0.7em, fill: luma(30%))[#label])
  }

  // Subset edge: from subset to superset
  let subset-edge(from-name, to-name) = {
    draw.line(
      from-name,
      to-name,
      stroke: 0.5pt + c-powerset-edge,
      mark: (end: "stealth", fill: c-powerset-edge),
    )
  }

  // ── Level 3: {a,b,c} ──
  node((0, ygap * 3), ${a, b, c}$, "abc")

  // ── Level 2: pairs ──
  node((-xgap, ygap * 2), ${a, b}$, "ab")
  node((0, ygap * 2), ${a, c}$, "ac")
  node((xgap, ygap * 2), ${b, c}$, "bc")

  // ── Level 1: singletons ──
  node((-xgap, ygap), ${a}$, "a")
  node((0, ygap), ${b}$, "b")
  node((xgap, ygap), ${c}$, "c")

  // ── Level 0: empty set ──
  node((0, 0), $emptyset$, "e")

  // ── Edges: ∅ → singletons ──
  subset-edge("e", "a")
  subset-edge("e", "b")
  subset-edge("e", "c")

  // ── Edges: singletons → pairs ──
  subset-edge("a", "ab")
  subset-edge("a", "ac")
  subset-edge("b", "ab")
  subset-edge("b", "bc")
  subset-edge("c", "ac")
  subset-edge("c", "bc")

  // ── Edges: pairs → {a,b,c} ──
  subset-edge("ab", "abc")
  subset-edge("ac", "abc")
  subset-edge("bc", "abc")
})

// Cantor: Line and Square are equinumerous
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
