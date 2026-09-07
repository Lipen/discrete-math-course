// ghosts.typ --- силуэты-призраки для focus-slide: функция получает цвет призрака.
#import "@preview/cetz:0.5.2": canvas, draw

// Штрих силуэта: жирный токен шкалы, без подписей и заливок.
#let ink-stroke(c) = 2pt + c

// ── Конечный автомат ──
#let dfa-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.4, 1.0), radius: 0.38, name: "q0", stroke: st)
  draw.circle((2.3, 1.0), radius: 0.38, name: "q1", stroke: st)
  draw.circle((4.2, 1.0), radius: 0.38, name: "q2", stroke: st)
  draw.circle((4.2, 1.0), radius: 0.5, name: "q2r", stroke: st)
  draw.line((-0.5, 1.0), "q0", mark: (end: "stealth", fill: c), stroke: st)
  draw.line("q0", "q1", mark: (end: "stealth", fill: c), stroke: st)
  draw.line("q1", "q2", mark: (end: "stealth", fill: c), stroke: st)
  draw.bezier(
    (0.72, 1.34),
    (0.08, 1.34),
    (1.1, 2.7),
    (-0.3, 2.7),
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
})

// ── Лента машины Тьюринга ──
#let tape-ghost(c) = canvas({
  let w = 0.85
  for i in range(5) {
    draw.rect(
      (i * w, 0),
      ((i + 1) * w, w),
      name: "cell-" + str(i),
      stroke: ink-stroke(c),
    )
  }
  draw.circle(
    (2.5 * w, w * 0.5),
    radius: 0.07,
    name: "mark",
    stroke: none,
    fill: c,
  )
  draw.line(
    (2.5 * w, w + 0.9),
    (2.5 * w, w + 0.12),
    name: "head",
    stroke: ink-stroke(c),
  )
  draw.line(
    (2.5 * w - 0.14, w + 0.34),
    (2.5 * w + 0.14, w + 0.34),
    (2.5 * w, w + 0.08),
    close: true,
    fill: c,
    stroke: none,
  )
})

// ── Дерево ──
#let tree-ghost(c) = canvas({
  draw.circle((2, 3), radius: 0.16, name: "root", stroke: ink-stroke(c))
  draw.circle((1, 2), radius: 0.16, name: "l", stroke: ink-stroke(c))
  draw.circle((3, 2), radius: 0.16, name: "r", stroke: ink-stroke(c))
  draw.circle((0.5, 1), radius: 0.16, name: "ll", stroke: ink-stroke(c))
  draw.circle((1.5, 1), radius: 0.16, name: "lr", stroke: ink-stroke(c))
  draw.circle((2.5, 1), radius: 0.16, name: "rl", stroke: ink-stroke(c))
  draw.circle((3.5, 1), radius: 0.16, name: "rr", stroke: ink-stroke(c))
  for p in (
    ("root", "l"),
    ("root", "r"),
    ("l", "ll"),
    ("l", "lr"),
    ("r", "rl"),
    ("r", "rr"),
  ) {
    draw.line(p.at(0), p.at(1), name: p.at(0) + p.at(1), stroke: ink-stroke(c))
  }
})

// ── Произвольный граф: цикл, диагональ, хвост ──
#let graph-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.3, 1.0), radius: 0.16, name: "ga", stroke: st)
  draw.circle((1.5, 2.2), radius: 0.16, name: "gb", stroke: st)
  draw.circle((2.9, 1.6), radius: 0.16, name: "gc", stroke: st)
  draw.circle((2.5, 0.3), radius: 0.16, name: "gd", stroke: st)
  draw.circle((1.2, 0.0), radius: 0.16, name: "ge", stroke: st)
  for p in (("ga", "gb"), ("gb", "gc"), ("gc", "gd"), ("gd", "ga"), ("gb", "gd"), ("gd", "ge")) {
    draw.line(p.at(0), p.at(1), name: "g" + p.at(0) + p.at(1), stroke: st)
  }
})

// ── Путь в графе: маршрут выделен жирным ──
#let path-ghost(c) = canvas({
  draw.circle((0.25, 1.5), radius: 0.16, name: "ps", stroke: ink-stroke(c))
  draw.circle((0.25, 1.5), radius: 0.27, name: "psr", stroke: ink-stroke(c))
  draw.circle((1.2, 2.3), radius: 0.16, name: "p1", stroke: ink-stroke(c))
  draw.circle((2.3, 1.8), radius: 0.16, name: "p2", stroke: ink-stroke(c))
  draw.circle((3.2, 2.5), radius: 0.16, name: "p3", stroke: ink-stroke(c))
  draw.circle((4.1, 1.6), radius: 0.16, name: "p4", stroke: ink-stroke(c))
  draw.circle((1.0, 0.6), radius: 0.14, name: "f1", stroke: 0.8pt + c)
  draw.circle((2.1, 0.3), radius: 0.14, name: "f2", stroke: 0.8pt + c)
  draw.circle((3.4, 0.8), radius: 0.14, name: "f3", stroke: 0.8pt + c)
  draw.line("ps", "f1", name: "b1", stroke: 0.8pt + c)
  draw.line("f1", "f2", name: "b2", stroke: 0.8pt + c)
  draw.line("f2", "f3", name: "b3", stroke: 0.8pt + c)
  draw.line("f3", "p4", name: "b4", stroke: 0.8pt + c)
  draw.line("f1", "p1", name: "b5", stroke: 0.8pt + c)
  draw.line("f2", "p2", name: "b6", stroke: 0.8pt + c)
  draw.line("f3", "p3", name: "b7", stroke: 0.8pt + c)
  draw.line("ps", "p1", name: "m1", stroke: ink-stroke(c))
  draw.line("p1", "p2", name: "m2", stroke: ink-stroke(c))
  draw.line("p2", "p3", name: "m3", stroke: ink-stroke(c))
  draw.line("p3", "p4", name: "m4", stroke: ink-stroke(c), mark: (end: "stealth", fill: c))
})

// ── K_(3,3): силуэт непланарности ──

#let k33-ghost(c) = canvas({
  for i in range(3) {
    draw.circle((0, i), radius: 0.16, name: "a" + str(i), stroke: ink-stroke(c))
    draw.circle(
      (2.2, i),
      radius: 0.16,
      name: "b" + str(i),
      stroke: ink-stroke(c),
    )
  }
  for i in range(3) {
    for j in range(3) {
      draw.line(
        "a" + str(i),
        "b" + str(j),
        name: "e" + str(i) + str(j),
        stroke: ink-stroke(c),
      )
    }
  }
})

// ── Ромб решётки ──
#let diamond-ghost(c) = canvas({
  draw.circle((1.5, 0), radius: 0.16, name: "bot", stroke: ink-stroke(c))
  draw.circle((0.5, 1.2), radius: 0.16, name: "x", stroke: ink-stroke(c))
  draw.circle((2.5, 1.2), radius: 0.16, name: "y", stroke: ink-stroke(c))
  draw.circle((1.5, 2.4), radius: 0.16, name: "top", stroke: ink-stroke(c))
  for p in (("bot", "x"), ("bot", "y"), ("x", "top"), ("y", "top")) {
    draw.line(p.at(0), p.at(1), name: p.at(0) + p.at(1), stroke: ink-stroke(c))
  }
})

// ── Волна обхода: фронты BFS вокруг источника ──
#let bfs-ghost(c) = canvas({
  let st = ink-stroke(c)
  let (cx, cy) = (0.3, 1.7)
  draw.circle((cx, cy), radius: 0.16, name: "src", stroke: st)
  draw.circle((cx, cy), radius: 0.27, name: "srcr", stroke: st)
  // ceTZ-arc: position --- точка старта дуги, центр волны = position - r*(cos start, sin start)
  for wave in (
    (1.2, -58deg, 58deg, "w1"),
    (2.2, -45deg, 45deg, "w2"),
    (3.2, -32deg, 32deg, "w3"),
  ) {
    let (r, a0, a1, nm) = wave
    draw.arc(
      (cx + r * calc.cos(a0), cy + r * calc.sin(a0)),
      start: a0,
      stop: a1,
      radius: r,
      name: nm,
      stroke: st,
    )
  }
  let ring = (
    (
      (1.36, 2.26),
      (1.5, 1.7),
      (1.36, 1.14),
    ),
    (
      (2.37, 2.45),
      (2.5, 1.7),
      (2.37, 0.95),
    ),
    ((3.5, 1.7),),
  )
  for i in range(3) {
    for j in range(ring.at(i).len()) {
      draw.circle(
        ring.at(i).at(j),
        radius: 0.14,
        name: "n" + str(i) + str(j),
        stroke: st,
      )
    }
  }
  draw.line("src", "n00", name: "e-a", stroke: st)
  draw.line("src", "n02", name: "e-b", stroke: st)
  draw.line("n00", "n10", name: "e-c", stroke: st)
  draw.line("n02", "n12", name: "e-d", stroke: st)
  draw.line("n01", "n11", name: "e-e", stroke: st)
  draw.line("n11", "n20", name: "e-f", stroke: st)
})

// ── Венн: два круга ──
#let venn-ghost(c) = canvas({
  draw.circle((1.1, 1.1), radius: 1.05, name: "a", stroke: ink-stroke(c))
  draw.circle((2.5, 1.1), radius: 1.05, name: "b", stroke: ink-stroke(c))
})

// ── Разбиение: универсум и классы эквивалентности ──
#let partition-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.rect((0, 0), (4, 2.4), name: "univ", stroke: st)
  let classes = (
    (0.8, 1.2, (0.55, 0.8, 1.05)),
    (2.0, 1.5, (1.75, 2.0, 2.25)),
    (3.2, 1.0, (2.95, 3.2, 3.45)),
  )
  for k in range(3) {
    let (cx, cy, dots) = classes.at(k)
    draw.circle((cx, cy), radius: 0.5, name: "cls-" + str(k), stroke: st)
    for d in range(3) {
      let dx = dots.at(d)
      let dy = 0.3 * calc.rem(d, 2) + 0.15
      draw.circle(
        (dx, cy + dy - 0.3),
        radius: 0.06,
        name: "dot-" + str(k) + str(d),
        stroke: none,
        fill: c,
      )
    }
  }
})
