#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Семантические цвета: две бусины ожерелья и три множества Венна.
#let c-bead-b = oklch(25%, 0.02, 265deg)  // тёмная бусина

#let c-bead-w = oklch(92%, 0.01, 90deg)   // светлая бусина

#let c-venn-a = oklch(58%, 0.22, 22deg)   // множество A

#let c-venn-b = oklch(52%, 0.16, 150deg)  // множество B

#let c-venn-c = oklch(56%, 0.16, 260deg)  // множество C

#let necklace(center, colors, radius: 0.55, name: none) = {
  let n = colors.len()
  let (cx, cy) = center
  draw.circle(
    center,
    radius: radius,
    fill: none,
    stroke: c-edge + t-ed,
    name: name,
  )
  for (i, col) in colors.enumerate() {
    let angle = 90deg - i * (360deg / n)
    let bx = cx + radius * calc.cos(angle)
    let by = cy + radius * calc.sin(angle)
    draw.circle(
      (bx, by),
      radius: 0.12,
      fill: if col == "b" { c-bead-b } else { c-bead-w },
      stroke: c-edge + t-ed,
    )
  }
}

// ── Орбиты ожерелий Бёрнсайда ──
#let burnside-necklaces = canvas({
  let orbit-note(x, y, body, size: s-cap) = {
    draw.content((x, y), text(size: size, fill: c-muted)[#body])
  }
  let orbit-arrow(from, to) = draw.line(
    from,
    to,
    stroke: c-accent + t-ed,
    mark: (
      end: ">",
      fill: c-accent,
    ),
  )

  necklace((-1.5, 1.8), ("b", "b", "b"))
  orbit-note(-1.5, 0.9, [1 элемент])
  orbit-note(-1.5, 0.55, [$"000"$], size: s-tiny)

  necklace((1.5, 1.8), ("w", "w", "w"))
  orbit-note(1.5, 0.9, [1 элемент])
  orbit-note(1.5, 0.55, [$"111"$], size: s-tiny)

  necklace((-3.0, -1.0), ("w", "b", "b"), name: "o3a")
  necklace((-1.5, -1.0), ("b", "w", "b"), name: "o3b")
  necklace((0.0, -1.0), ("b", "b", "w"), name: "o3c")
  orbit-arrow("o3a.east", "o3b.west")
  orbit-arrow("o3b.east", "o3c.west")
  orbit-note(-1.5, -1.7, [3 элемента (повороты)])
  orbit-note(-1.5, -2.1, [$"001", "010", "100"$], size: s-tiny)

  necklace((-3.0, -3.5), ("w", "w", "b"), name: "o4a")
  necklace((-1.5, -3.5), ("b", "w", "w"), name: "o4b")
  necklace((0.0, -3.5), ("w", "b", "w"), name: "o4c")
  orbit-arrow("o4a.east", "o4b.west")
  orbit-arrow("o4b.east", "o4c.west")
  orbit-note(-1.5, -4.2, [3 элемента (повороты)])
  orbit-note(-1.5, -4.6, [$"011", "101", "110"$], size: s-tiny)
})

// ── Раскраска K6 и форсированный одноцветный треугольник ──
#let ramsey-k6 = canvas({
  let R = 2.2
  let vr = 0.32
  let center = (0, 0)
  let hot-verts = (2, 3, 4)

  let hot-line = c-hot + t-ed
  let accent-line = c-accent + t-ed
  let hot-hi = c-hot + t-hi
  let dim-line = c-muted + t-hr

  draw.circle(
    center,
    radius: vr + 0.05,
    fill: c-warn,
    stroke: c-hot + t-bd,
    name: "c",
  )
  draw.content(center, text(size: s-node, weight: "bold", fill: c-ink)[1])

  for i in range(2, 7) {
    let p = (
      R * calc.cos(90deg - (i - 2) * 72deg),
      R * calc.sin(90deg - (i - 2) * 72deg),
    )
    let hot = hot-verts.contains(i)
    draw.circle(
      p,
      radius: vr,
      fill: if hot { c-warn } else { c-fl },
      stroke: if hot { c-hot + t-bd } else { c-bd + t-bd },
      name: "v" + str(i),
    )
    draw.content(p, text(size: s-node, fill: c-ink)[#i])
  }

  for (a, b) in (
    ("v2", "v5"),
    ("v2", "v6"),
    ("v3", "v5"),
    ("v3", "v6"),
    ("v4", "v5"),
    ("v4", "v6"),
    ("v5", "v6"),
  ) {
    draw.line(a, b, stroke: dim-line)
  }

  draw.line("c", "v5", stroke: accent-line)
  draw.line("c", "v6", stroke: accent-line)
  draw.line("v3", "v4", stroke: accent-line)
  draw.line("v2", "v4", stroke: accent-line)

  draw.line("c", "v4", stroke: hot-line)

  draw.line("c", "v2", stroke: hot-hi)
  draw.line("c", "v3", stroke: hot-hi)
  draw.line("v2", "v3", stroke: hot-hi)

  draw.line((3.3, 2.0), (3.9, 2.0), stroke: c-hot + t-hi)
  draw.content(
    (4.1, 2.0),
    text(size: s-cap, fill: c-muted)[красное],
    anchor: "west",
  )
  draw.line((3.3, 1.4), (3.9, 1.4), stroke: c-accent + t-hi)
  draw.content(
    (4.1, 1.4),
    text(size: s-cap, fill: c-muted)[синее],
    anchor: "west",
  )

  let note-x = -2.2
  let note-y = -2.55
  for (k, line) in (
    [Из 5 рёбер от вершины 1 минимум 3 одного цвета.],
    [Среди их концов найдётся ребро того же цвета],
    [либо все три ребра --- другого цвета.],
  ).enumerate() {
    draw.content(
      (note-x, note-y - k * 0.5),
      text(size: s-cap, fill: c-muted)[#line],
      anchor: "west",
    )
  }
})

// ── Цикл C5 --- свидетель R(3, 3) > 5 ──
#let ramsey-c5 = canvas({
  let R = 2.2
  let vr = 0.32
  let know-line = c-accent + t-hi
  let stranger-line = c-hot + t-hi

  for i in range(1, 6) {
    let p = (
      R * calc.cos(90deg - (i - 1) * 72deg),
      R * calc.sin(90deg - (i - 1) * 72deg),
    )
    draw.circle(p, radius: vr, fill: c-fl, stroke: c-bd + t-bd, name: "v" + str(i))
    draw.content(p, text(size: s-node, fill: c-ink)[#i])
  }

  for (a, b) in (("v1", "v3"), ("v1", "v4"), ("v2", "v4"), ("v2", "v5"), ("v3", "v5")) {
    draw.line(a, b, stroke: stranger-line)
  }
  for (a, b) in (("v1", "v2"), ("v2", "v3"), ("v3", "v4"), ("v4", "v5"), ("v5", "v1")) {
    draw.line(a, b, stroke: know-line)
  }

  draw.line((3.3, 2.0), (3.9, 2.0), stroke: c-hot + t-hi)
  draw.content((4.1, 2.0), text(size: s-cap, fill: c-muted)[незнакомы], anchor: "west")
  draw.line((3.3, 1.4), (3.9, 1.4), stroke: c-accent + t-hi)
  draw.content((4.1, 1.4), text(size: s-cap, fill: c-muted)[знакомы], anchor: "west")

  let note-x = -2.2
  let note-y = -2.55
  for (k, line) in (
    [Каждые три вершины содержат пару соседей по циклу],
    [и пару несоседей: ни синего треугольника, ни красного.],
    [Пять вершин недостаточно: $R(3, 3) > 5$.],
  ).enumerate() {
    draw.content(
      (note-x, note-y - k * 0.5),
      text(size: s-cap, fill: c-muted)[#line],
      anchor: "west",
    )
  }
})

// ── Дерево решений: перестановки {A,B,C} ──
#let decision-tree = {
  let tnode(pos, name, label) = {
    node(
      pos,
      name: name,
      shape: circle,
      width: 0.42cm,
      height: 0.42cm,
      fill: c-fl,
      stroke: c-bd + t-bd,
      inset: 0pt,
    )
    node(
      (pos.at(0), pos.at(1) + 0.22),
      label,
      fill: none,
      stroke: none,
      shape: rect,
      inset: 0pt,
    )
  }
  let leaf-label(body) = text(
    size: s-cap,
    weight: "bold",
    fill: c-accent,
  )[#body]
  let ledge(fr, to, label) = edge(
    fr,
    to,
    "-",
    stroke: c-edge + t-ed,
    label: text(size: s-cap, fill: c-ink)[#label],
    label-side: center,
    label-fill: c-white,
  )

  diagram(
    spacing: (4cm, 1.7cm),
    tnode((0, 0), <start>, text(size: s-cap, fill: c-ink)[старт]),
    tnode((-1, 1), <a>, text(size: s-cap, fill: c-ink)[A]),
    tnode((0, 1), <b>, text(size: s-cap, fill: c-ink)[B]),
    tnode((1, 1), <c>, text(size: s-cap, fill: c-ink)[C]),
    tnode((-1.25, 2), <ab>, text(size: s-cap, fill: c-ink)[AB]),
    tnode((-0.75, 2), <ac>, text(size: s-cap, fill: c-ink)[AC]),
    tnode((-0.25, 2), <ba>, text(size: s-cap, fill: c-ink)[BA]),
    tnode((0.25, 2), <bc>, text(size: s-cap, fill: c-ink)[BC]),
    tnode((0.75, 2), <ca>, text(size: s-cap, fill: c-ink)[CA]),
    tnode((1.25, 2), <cb>, text(size: s-cap, fill: c-ink)[CB]),
    tnode((-1.25, 3), <abc>, leaf-label[ABC]),
    tnode((-0.75, 3), <acb>, leaf-label[ACB]),
    tnode((-0.25, 3), <bac>, leaf-label[BAC]),
    tnode((0.25, 3), <bca>, leaf-label[BCA]),
    tnode((0.75, 3), <cab>, leaf-label[CAB]),
    tnode((1.25, 3), <cba>, leaf-label[CBA]),

    ledge(<start>, <a>, [A]),
    ledge(<start>, <b>, [B]),
    ledge(<start>, <c>, [C]),
    ledge(<a>, <ab>, [B]),
    ledge(<a>, <ac>, [C]),
    ledge(<b>, <ba>, [A]),
    ledge(<b>, <bc>, [C]),
    ledge(<c>, <ca>, [A]),
    ledge(<c>, <cb>, [B]),
    ledge(<ab>, <abc>, [C]),
    ledge(<ac>, <acb>, [B]),
    ledge(<ba>, <bac>, [C]),
    ledge(<bc>, <bca>, [A]),
    ledge(<ca>, <cab>, [B]),
    ledge(<cb>, <cba>, [A]),
  )
}

// ── Включения-исключения: знаки вклада областей трёх множеств ──
#let venn-inclusion-exclusion = canvas({
  let r = 2.1
  let pa = (-1.3, 0.75)
  let pb = (1.3, 0.75)
  let pc = (0, -1.55)
  let vstroke(color) = (paint: color, thickness: t-bd)

  draw.circle(
    pa,
    radius: r,
    fill: c-venn-a.transparentize(60%),
    stroke: vstroke(c-venn-a),
    name: "A",
  )
  draw.circle(
    pb,
    radius: r,
    fill: c-venn-b.transparentize(60%),
    stroke: vstroke(c-venn-b),
    name: "B",
  )
  draw.circle(
    pc,
    radius: r,
    fill: c-venn-c.transparentize(60%),
    stroke: vstroke(c-venn-c),
    name: "C",
  )

  draw.content((-2.8, 2.5), text(
    size: s-node,
    weight: "bold",
    fill: c-venn-a,
  )[$A$])
  draw.content((2.8, 2.5), text(
    size: s-node,
    weight: "bold",
    fill: c-venn-b,
  )[$B$])
  draw.content((0, -3.5), text(
    size: s-node,
    weight: "bold",
    fill: c-venn-c,
  )[$C$])

  let sign(x, y, body) = draw.content((x, y), text(
    size: s-cap,
    fill: c-ink,
  )[#body])
  sign(-2.1, 0.2, $+1$)
  sign(2.1, 0.2, $+1$)
  sign(0, -2.8, $+1$)
  sign(0, 1.3, [$-1$])
  sign(-1.0, -0.7, [$-1$])
  sign(1.0, -0.7, [$-1$])
  draw.content((0, -0.05), text(size: s-cap, weight: "bold", fill: c-ink)[$+1$])

  let ly = -4.2
  draw.rect(
    (-3.2, ly - 0.2),
    (-2.6, ly + 0.2),
    fill: c-venn-a.transparentize(30%),
    stroke: c-venn-a + t-bd,
    radius: 2pt,
  )
  draw.content((-1.8, ly), text(
    size: s-cap,
    fill: c-muted,
  )[$|A|+|B|+|C|$ --- одиночные])

  draw.rect(
    (0.5, ly - 0.2),
    (1.1, ly + 0.2),
    fill: c-venn-a.transparentize(40%),
    stroke: c-venn-a + t-bd,
    radius: 2pt,
  )
  draw.line((1.1, ly), (1.7, ly - 0.2), stroke: c-venn-b + t-bd)
  draw.line((1.1, ly), (1.7, ly + 0.2), stroke: c-venn-c + t-bd)
  draw.content((2.4, ly), text(
    size: s-cap,
    fill: c-muted,
  )[$-|A inter B|-|A inter C|-|B inter C|$])
  draw.circle(
    (-2.93, ly - 0.75),
    radius: 0.12,
    fill: c-venn-a.transparentize(40%),
    stroke: c-venn-a + t-bd,
  )
  draw.circle(
    (-2.8, ly - 0.75),
    radius: 0.12,
    fill: c-venn-b.transparentize(40%),
    stroke: c-venn-b + t-bd,
  )
  draw.circle(
    (-2.67, ly - 0.75),
    radius: 0.12,
    fill: c-venn-c.transparentize(40%),
    stroke: c-venn-c + t-bd,
  )
  draw.content((-1.8, ly - 0.75), text(
    size: s-cap,
    fill: c-muted,
  )[$+|A inter B inter C|$ --- тройное])
})

// ── Комбинаторные числа ──
#let combinatorial-numbers = table(
  columns: 6,
  align: center + horizon,
  stroke: (x, y) => if y == 0 { (bottom: c-accent + t-bd) },
  table.header(
    text(fill: c-accent)[$n$],
    text(fill: c-accent)[$n!$],
    text(fill: c-accent)[$binom(n, 2)$],
    text(fill: c-accent)[$C_n$ (Catalan)],
    text(fill: c-accent)[$S(n,3)$ (Stirling)],
    text(fill: c-accent)[$B_n$ (Bell)],
  ),
  [1], [1], [0], [1], [0], [1],
  [2], [2], [1], [2], [0], [2],
  [3], [6], [3], [5], [1], [5],
  [4], [24], [6], [14], [6], [15],
  [5], [120], [10], [42], [25], [52],
)

// ── Треугольник Паскаля ──
#let pascal-triangle = canvas({
  let s = 0.62
  let h = 1.05
  let rows = (
    (1,),
    (1, 1),
    (1, 2, 1),
    (1, 3, 3, 1),
    (1, 4, 6, 4, 1),
    (1, 5, 10, 10, 5, 1),
    (1, 6, 15, 20, 15, 6, 1),
  )

  draw.line((0, 7.05), (0, 0.45), stroke: (
    paint: c-muted,
    thickness: t-hr,
    dash: "dashed",
  ))
  for (n, row) in rows.enumerate() {
    for (k, val) in row.enumerate() {
      let x = (2 * k - n) * s
      let y = (rows.len() - 1 - n) * h
      draw.content(
        (x, y),
        text(size: s-tiny, fill: c-ink)[#val],
        fill: if x == 0 { c-white } else { none },
        stroke: none,
        padding: 1pt,
      )
    }
  }

  let p1 = (-s, h)
  let p2 = (s, h)
  let c20 = (0, 0)
  draw.line(p1, c20, stroke: c-accent + t-ed)
  draw.line(p2, c20, stroke: c-accent + t-ed)
  draw.content(p1, text(size: s-tiny, weight: "bold", fill: c-accent)[10])
  draw.content(p2, text(size: s-tiny, weight: "bold", fill: c-accent)[10])
  draw.content(c20, text(size: s-tiny, weight: "bold", fill: c-accent)[20])
  draw.content((0, -0.6), text(size: s-cap, fill: c-muted)[$20 = 10 + 10$])
})
