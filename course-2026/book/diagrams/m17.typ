// m17 diagrams: орбиты ожерелий Бёрнсайда, раскраска K6, дерево решений перестановок,
// включения-исключения, комбинаторные числа, треугольник Паскаля.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

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
  let orbit-label(x, y, body) = {
    draw.content((x, y), text(size: s-cap, fill: c-muted)[#body])
  }
  let orbit-strings(x, y, body) = {
    draw.content((x, y), text(size: s-tiny, fill: c-muted)[#body])
  }

  necklace((-1.5, 1.8), ("b", "b", "b"))
  orbit-label(-1.5, 0.9, [1 элемент])
  orbit-strings(-1.5, 0.55, [$"000"$])

  necklace((1.5, 1.8), ("w", "w", "w"))
  orbit-label(1.5, 0.9, [1 элемент])
  orbit-strings(1.5, 0.55, [$"111"$])

  necklace((-3.0, -1.0), ("w", "b", "b"), name: "o3a")
  necklace((-1.5, -1.0), ("b", "w", "b"), name: "o3b")
  necklace((0.0, -1.0), ("b", "b", "w"), name: "o3c")
  draw.line("o3a.east", "o3b.west", stroke: c-accent + t-ed, mark: (end: ">", fill: c-accent))
  draw.line("o3b.east", "o3c.west", stroke: c-accent + t-ed, mark: (end: ">", fill: c-accent))
  orbit-label(-1.5, -1.7, [3 элемента (повороты)])
  orbit-strings(-1.5, -2.1, [$"001", "010", "100"$])

  necklace((-3.0, -3.5), ("w", "w", "b"), name: "o4a")
  necklace((-1.5, -3.5), ("b", "w", "w"), name: "o4b")
  necklace((0.0, -3.5), ("w", "b", "w"), name: "o4c")
  draw.line("o4a.east", "o4b.west", stroke: c-accent + t-ed, mark: (end: ">", fill: c-accent))
  draw.line("o4b.east", "o4c.west", stroke: c-accent + t-ed, mark: (end: ">", fill: c-accent))
  orbit-label(-1.5, -4.2, [3 элемента (повороты)])
  orbit-strings(-1.5, -4.6, [$"011", "101", "110"$])
})

// ── Раскраска K6 и форсированный одноцветный треугольник ──
#let ramsey-k6 = canvas({
  let R = 2.2
  let vr = 0.32
  let center = (0, 0)
  let v2 = (0, 2.2)
  let v3 = (2.092, 0.68)
  let v4 = (1.293, -1.78)
  let v5 = (-1.293, -1.78)
  let v6 = (-2.092, 0.68)

  let red = c-hot + t-ed
  let blue = c-accent + t-ed
  let hi = c-hot + t-hi
  let dim = c-muted + t-hr

  draw.circle(center, radius: vr + 0.05, fill: c-warn, stroke: c-hot + t-bd, name: "c")
  draw.content(center, text(size: s-node, weight: "bold", fill: c-ink)[1])

  for (p, lab, is-red) in (
    (v2, "2", true),
    (v3, "3", true),
    (v4, "4", true),
    (v5, "5", false),
    (v6, "6", false),
  ) {
    draw.circle(
      p,
      radius: vr,
      fill: if is-red { c-warn } else { c-fl },
      stroke: if is-red { c-hot + t-bd } else { c-bd + t-bd },
      name: "v" + lab,
    )
    draw.content(p, text(size: s-node, fill: c-ink)[#lab])
  }

  for (a, b) in (("v2", "v5"), ("v2", "v6"), ("v3", "v5"), ("v3", "v6"), ("v4", "v5"), ("v4", "v6"), ("v5", "v6")) {
    draw.line(a, b, stroke: dim)
  }

  draw.line("c", "v5", stroke: blue)
  draw.line("c", "v6", stroke: blue)
  draw.line("v3", "v4", stroke: blue)
  draw.line("v2", "v4", stroke: blue)

  draw.line("c", "v4", stroke: red)

  draw.line("c", "v2", stroke: hi)
  draw.line("c", "v3", stroke: hi)
  draw.line("v2", "v3", stroke: hi)

  draw.line((3.3, 2.0), (3.9, 2.0), stroke: c-hot + t-hi)
  draw.content((4.1, 2.0), text(size: s-cap, fill: c-muted)[красное], anchor: "west")
  draw.line((3.3, 1.4), (3.9, 1.4), stroke: c-accent + t-hi)
  draw.content((4.1, 1.4), text(size: s-cap, fill: c-muted)[синее], anchor: "west")

  let note-x = -2.2
  let note-y = -2.55
  for (k, line) in (
    [Из 5 рёбер от вершины 1 минимум 3 одного цвета.],
    [Среди их концов найдётся ребро того же цвета],
    [либо все три ребра --- другого цвета.],
  ).enumerate() {
    draw.content((note-x, note-y - k * 0.5), text(size: s-cap, fill: c-muted)[#line], anchor: "west")
  }
})

// ── Дерево решений: перестановки {A,B,C} ──
#let decision-tree = canvas({
  let tnode(pos, name) = {
    draw.circle(pos, radius: 0.2, fill: c-fl, stroke: c-bd + t-bd, name: name)
  }

  let ledge(from, to, label) = {
    let edgename = from + "-" + to
    draw.line(from, to, name: edgename, stroke: c-edge + t-ed)
    draw.content(
      edgename,
      text(size: s-cap, fill: c-ink)[#label],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  let start = (0.0, 5.2)
  let a = (-4.0, 3.5)
  let b = (0.0, 3.5)
  let c = (4.0, 3.5)
  let ab = (-5.0, 1.8)
  let ac = (-3.0, 1.8)
  let ba = (-1.0, 1.8)
  let bc = (1.0, 1.8)
  let ca = (3.0, 1.8)
  let cb = (5.0, 1.8)
  let abc = (-5.0, 0.3)
  let acb = (-3.0, 0.3)
  let bac = (-1.0, 0.3)
  let bca = (1.0, 0.3)
  let cab = (3.0, 0.3)
  let cba = (5.0, 0.3)

  tnode(start, "start")
  draw.content((start.at(0), start.at(1) + 0.35), text(size: s-cap, fill: c-ink)[старт])

  tnode(a, "a")
  draw.content((a.at(0), a.at(1) - 0.35), text(size: s-cap, fill: c-ink)[A])
  tnode(b, "b")
  draw.content((b.at(0), b.at(1) - 0.35), text(size: s-cap, fill: c-ink)[B])
  tnode(c, "c")
  draw.content((c.at(0), c.at(1) - 0.35), text(size: s-cap, fill: c-ink)[C])

  tnode(ab, "ab")
  draw.content((ab.at(0), ab.at(1) - 0.35), text(size: s-cap, fill: c-ink)[AB])
  tnode(ac, "ac")
  draw.content((ac.at(0), ac.at(1) - 0.35), text(size: s-cap, fill: c-ink)[AC])
  tnode(ba, "ba")
  draw.content((ba.at(0), ba.at(1) - 0.35), text(size: s-cap, fill: c-ink)[BA])
  tnode(bc, "bc")
  draw.content((bc.at(0), bc.at(1) - 0.35), text(size: s-cap, fill: c-ink)[BC])
  tnode(ca, "ca")
  draw.content((ca.at(0), ca.at(1) - 0.35), text(size: s-cap, fill: c-ink)[CA])
  tnode(cb, "cb")
  draw.content((cb.at(0), cb.at(1) - 0.35), text(size: s-cap, fill: c-ink)[CB])

  tnode(abc, "abc")
  draw.content((abc.at(0), abc.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[ABC])
  tnode(acb, "acb")
  draw.content((acb.at(0), acb.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[ACB])
  tnode(bac, "bac")
  draw.content((bac.at(0), bac.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[BAC])
  tnode(bca, "bca")
  draw.content((bca.at(0), bca.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[BCA])
  tnode(cab, "cab")
  draw.content((cab.at(0), cab.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[CAB])
  tnode(cba, "cba")
  draw.content((cba.at(0), cba.at(1) - 0.4), text(size: s-cap, weight: "bold", fill: c-accent)[CBA])

  ledge("start", "a", [A])
  ledge("start", "b", [B])
  ledge("start", "c", [C])
  ledge("a", "ab", [B])
  ledge("a", "ac", [C])
  ledge("b", "ba", [A])
  ledge("b", "bc", [C])
  ledge("c", "ca", [A])
  ledge("c", "cb", [B])
  ledge("ab", "abc", [C])
  ledge("ac", "acb", [B])
  ledge("ba", "bac", [C])
  ledge("bc", "bca", [A])
  ledge("ca", "cab", [B])
  ledge("cb", "cba", [A])
})

// ── Включения-исключения: знаки вклада областей трёх множеств ──
#let venn-inclusion-exclusion = canvas({
  let r = 2.1
  let pa = (-1.3, 0.75)
  let pb = (1.3, 0.75)
  let pc = (0, -1.55)
  let vstroke(color) = (paint: color, thickness: t-bd)

  draw.circle(pa, radius: r, fill: c-venn-a.transparentize(60%), stroke: vstroke(c-venn-a), name: "A")
  draw.circle(pb, radius: r, fill: c-venn-b.transparentize(60%), stroke: vstroke(c-venn-b), name: "B")
  draw.circle(pc, radius: r, fill: c-venn-c.transparentize(60%), stroke: vstroke(c-venn-c), name: "C")

  draw.content((-2.8, 2.5), text(size: s-node, weight: "bold", fill: c-venn-a)[$A$])
  draw.content((2.8, 2.5), text(size: s-node, weight: "bold", fill: c-venn-b)[$B$])
  draw.content((0, -3.5), text(size: s-node, weight: "bold", fill: c-venn-c)[$C$])

  let sign(x, y, body) = draw.content((x, y), text(size: s-cap, fill: c-ink)[#body])
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
  draw.content((-1.8, ly), text(size: s-cap, fill: c-muted)[$|A|+|B|+|C|$ --- одиночные])

  draw.rect(
    (0.5, ly - 0.2),
    (1.1, ly + 0.2),
    fill: c-venn-a.transparentize(40%),
    stroke: c-venn-a + t-bd,
    radius: 2pt,
  )
  draw.line((1.1, ly), (1.7, ly - 0.2), stroke: c-venn-b + t-bd)
  draw.line((1.1, ly), (1.7, ly + 0.2), stroke: c-venn-c + t-bd)
  draw.content((2.4, ly), text(size: s-cap, fill: c-muted)[$-|A inter B|-|A inter C|-|B inter C|$])
})

// ── Комбинаторные числа ──
#let combinatorial-numbers = table(
  columns: 5,
  align: center + horizon,
  stroke: (x, y) => if y == 0 { (bottom: c-accent + t-bd) },
  table.header(
    text(fill: c-accent)[$n$],
    text(fill: c-accent)[$n!$],
    text(fill: c-accent)[$C_n$ (Catalan)],
    text(fill: c-accent)[$S(n,3)$ (Stirling)],
    text(fill: c-accent)[$B_n$ (Bell)]
  ),
  [1], [1], [1], [0], [1],
  [2], [2], [2], [0], [2],
  [3], [6], [5], [1], [5],
  [4], [24], [14], [6], [15],
  [5], [120], [42], [25], [52],
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

  draw.line((0, 7.05), (0, 0.45), stroke: (paint: c-muted, thickness: t-hr, dash: "dashed"))
  for (n, row) in rows.enumerate() {
    for (k, val) in row.enumerate() {
      let x = (2 * k - n) * s
      let y = (rows.len() - 1 - n) * h
      draw.content(
        (x, y),
        text(size: s-tiny, fill: c-ink)[#val],
        fill: if x == 0 { white } else { none },
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
