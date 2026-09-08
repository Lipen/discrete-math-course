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
  for p in (
    ("ga", "gb"),
    ("gb", "gc"),
    ("gc", "gd"),
    ("gd", "ga"),
    ("gb", "gd"),
    ("gd", "ge"),
  ) {
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
  draw.line("p3", "p4", name: "m4", stroke: ink-stroke(c), mark: (
    end: "stealth",
    fill: c,
  ))
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

// ── Логика высказываний: дерево формулы ──
#let prop-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.95, 2.55), radius: 0.24, name: "root", stroke: st)
  draw.circle((0.75, 1.35), radius: 0.22, name: "and-node", stroke: st)
  draw.circle((3.15, 1.35), radius: 0.22, name: "not-node", stroke: st)
  draw.circle((0.05, 0.2), radius: 0.07, name: "p", stroke: none, fill: c)
  draw.circle((1.45, 0.2), radius: 0.07, name: "q", stroke: none, fill: c)
  draw.circle((3.15, 0.2), radius: 0.07, name: "r", stroke: none, fill: c)
  draw.line("root", "and-node", name: "e-ra", stroke: st)
  draw.line("root", "not-node", name: "e-rn", stroke: st)
  draw.line("and-node", "p", name: "e-ap", stroke: st)
  draw.line("and-node", "q", name: "e-aq", stroke: st)
  draw.line("not-node", "r", name: "e-nr", stroke: st)
})

// ── Таблицы истинности: таблица P и Q, знак равенства, столбец результата ──
#let truthtable-ghost(c) = canvas({
  let st = ink-stroke(c)
  let w = 0.62
  let h = 0.55
  for r in range(4) {
    for col in range(3) {
      draw.rect(
        (col * w, r * h),
        ((col + 1) * w, (r + 1) * h),
        name: "cell-" + str(r) + str(col),
        stroke: st,
      )
    }
    draw.rect(
      (2.86, r * h),
      (2.86 + w, (r + 1) * h),
      name: "cell-s" + str(r),
      stroke: st,
    )
  }
  for m in ((0, 0), (1, 0), (0, 1), (2, 1), (0, 2)) {
    let (r, col) = m
    draw.circle(
      (col * w + w / 2, r * h + h / 2),
      radius: 0.07,
      name: "t" + str(r) + str(col),
      stroke: none,
      fill: c,
    )
  }
  draw.circle((3.17, 0.275), radius: 0.07, name: "ts", stroke: none, fill: c)
  draw.line((2.11, 0.98), (2.61, 0.98), name: "eq-lo", stroke: st)
  draw.line((2.11, 1.22), (2.61, 1.22), name: "eq-hi", stroke: st)
})

// ── Предикаты и кванторы: область на отрезке, обход всех и один выделенный ──
#let quantifier-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.line((0.2, 0.25), (3.1, 0.25), name: "domain", stroke: st)
  for i in range(5) {
    draw.circle(
      (0.45 + i * 0.55, 0.25),
      radius: 0.07,
      name: "d" + str(i),
      stroke: none,
      fill: c,
    )
  }
  draw.circle((1.55, 0.25), radius: 0.18, name: "exist", stroke: st)
  draw.arc(
    (0.25, 0.25),
    start: 180deg,
    stop: 0deg,
    radius: 1.4,
    name: "sweep",
    stroke: st,
    mark: (end: "stealth", fill: c),
  )
})

// ── Методы доказательств: спуск шагами к заключению ──
#let proofchain-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.35, 2.35), radius: 0.22, name: "n1", stroke: st)
  draw.circle((1.85, 1.45), radius: 0.22, name: "n2", stroke: st)
  draw.circle((3.35, 0.55), radius: 0.22, name: "n3", stroke: st)
  draw.circle((3.35, 0.55), radius: 0.34, name: "n3r", stroke: st)
  draw.line("n1", "n2", name: "e1", mark: (end: "stealth", fill: c), stroke: st)
  draw.line("n2", "n3", name: "e2", mark: (end: "stealth", fill: c), stroke: st)
})

// ── Индукция: волна падающих домино, опирающихся друг на друга ──
#let domino-ghost(c) = canvas({
  let st = ink-stroke(c)
  let w = 0.6
  let h = 1.8
  let tiles = ((0.6, 40deg), (1.4, 40deg), (2.577, 25deg), (3.937, 0deg))
  for i in range(4) {
    let (px, th) = tiles.at(i)
    let pivot = (px, 0)
    let bl = (px - w * calc.cos(th), w * calc.sin(th))
    let tl = (
      px - w * calc.cos(th) + h * calc.sin(th),
      w * calc.sin(th) + h * calc.cos(th),
    )
    let tr = (px + h * calc.sin(th), h * calc.cos(th))
    draw.line(
      pivot,
      bl,
      tl,
      tr,
      close: true,
      name: "tile-" + str(i),
      stroke: st,
    )
  }
})

// ── Логика множеств: пересечение, высеченное из двух множеств ──
#let setlogic-ghost(c) = canvas({
  draw.circle(
    (1.1, 1.15),
    radius: 1.05,
    name: "set-a",
    stroke: (paint: c, thickness: 0.8pt, dash: "dashed"),
  )
  draw.circle(
    (2.55, 1.15),
    radius: 1.05,
    name: "set-b",
    stroke: (paint: c, thickness: 0.8pt, dash: "dashed"),
  )
  draw.arc(
    (1.825, 0.3905),
    start: -46.34deg,
    stop: 46.34deg,
    radius: 1.05,
    name: "lens-right",
    stroke: ink-stroke(c),
  )
  draw.arc(
    (1.825, 1.9095),
    start: 133.66deg,
    stop: 226.34deg,
    radius: 1.05,
    name: "lens-left",
    stroke: ink-stroke(c),
  )
})

// ── Бинарные отношения ──
#let relation-ghost(c) = canvas({
  let thin = 0.8pt + c
  draw.rect((0.15, 0.1), (3.15, 2.7), name: "prod", stroke: thin)
  for i in range(3) {
    for j in range(3) {
      draw.circle(
        (0.55 + 1.1 * i, 0.5 + 0.9 * j),
        radius: 0.09,
        name: "p-" + str(i) + str(j),
        stroke: thin,
      )
    }
  }
  for p in ((0, 1), (2, 1), (1, 2)) {
    let pos = (0.55 + 1.1 * p.at(0), 0.5 + 0.9 * p.at(1))
    draw.circle(
      pos,
      radius: 0.17,
      name: "q-" + str(p.at(0)) + str(p.at(1)),
      stroke: ink-stroke(c),
    )
    draw.circle(
      pos,
      radius: 0.05,
      name: "qd-" + str(p.at(0)) + str(p.at(1)),
      stroke: none,
      fill: c,
    )
  }
})

// ── Свойства и замыкания ──
#let closure-ghost(c) = canvas({
  let st = ink-stroke(c)
  let dashed = (paint: c, thickness: 2pt, dash: "dashed")
  draw.circle((0.5, 0.6), radius: 0.16, name: "ra", stroke: st)
  draw.circle((2.05, 2.2), radius: 0.16, name: "rb", stroke: st)
  draw.circle((3.6, 0.7), radius: 0.16, name: "rc", stroke: st)
  draw.line("ra", "rb", name: "e1", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("rb", "rc", name: "e2", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("ra", "rc", name: "e3", stroke: dashed, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.line((1.92, 2.33), (0.37, 0.73), name: "e4", stroke: dashed, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.arc(
    (0.34, 0.927),
    start: -60deg,
    stop: 240deg,
    radius: 0.2,
    name: "loop",
    stroke: dashed,
  )
})

// ── Разбиения и фактор-множество ──
#let quotient-ghost(c) = canvas({
  let st = ink-stroke(c)
  let blobs = (
    (0.9, 2.3, 0.48, ((0.75, 2.42), (1.05, 2.3), (0.78, 2.14))),
    (0.5, 1.3, 0.44, ((0.38, 1.42), (0.6, 1.22))),
    (0.95, 0.45, 0.46, ((0.83, 0.57), (1.08, 0.38))),
  )
  for k in range(3) {
    let (cx, cy, r, dots) = blobs.at(k)
    draw.circle((cx, cy), radius: r, name: "blob-" + str(k), stroke: st)
    for d in range(dots.len()) {
      draw.circle(
        dots.at(d),
        radius: 0.06,
        name: "ed-" + str(k) + str(d),
        stroke: none,
        fill: c,
      )
    }
  }
  for k in range(3) {
    let dy = (2.3, 1.3, 0.45).at(k)
    draw.circle(
      (3.55, dy),
      radius: 0.1,
      name: "cls-" + str(k),
      stroke: none,
      fill: c,
    )
    draw.line(
      "blob-" + str(k),
      "cls-" + str(k),
      name: "qm-" + str(k),
      stroke: st,
      mark: (end: "stealth", fill: c),
    )
  }
})

// ── Частичный порядок ──
#let poset-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.7, 0.2), radius: 0.15, name: "pb", stroke: st)
  draw.circle((0.8, 1.3), radius: 0.15, name: "px", stroke: st)
  draw.circle((2.6, 1.3), radius: 0.15, name: "py", stroke: st)
  draw.circle((3.6, 1.15), radius: 0.15, name: "pz", stroke: st)
  draw.circle((1.7, 2.4), radius: 0.15, name: "pt", stroke: st)
  for e in (
    ("pb", "px"),
    ("pb", "py"),
    ("pb", "pz"),
    ("px", "pt"),
    ("py", "pt"),
  ) {
    draw.line(
      e.at(0),
      e.at(1),
      name: e.at(0) + e.at(1),
      stroke: st,
      mark: (end: "stealth", fill: c),
    )
  }
})

// ── Функции и отображения ──
#let function-ghost(c) = canvas({
  let st = ink-stroke(c)
  for k in range(3) {
    let y = 0.45 + 0.95 * k
    draw.circle(
      (0.4, y),
      radius: 0.08,
      name: "l" + str(k),
      stroke: none,
      fill: c,
    )
    draw.circle(
      (3.6, y),
      radius: 0.08,
      name: "r" + str(k),
      stroke: none,
      fill: c,
    )
  }
  for e in (("l2", "r0"), ("l1", "r2"), ("l0", "r1")) {
    draw.line(
      e.at(0),
      e.at(1),
      name: e.at(0) + e.at(1),
      stroke: st,
      mark: (end: "stealth", fill: c),
    )
  }
})

// ── Композиция, образ и прообраз ──
#let composition-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.circle((0.3, 1.95), radius: 0.08, name: "a1", stroke: none, fill: c)
  draw.circle((0.3, 0.65), radius: 0.08, name: "a2", stroke: none, fill: c)
  draw.circle((1.95, 2.5), radius: 0.08, name: "b1", stroke: none, fill: c)
  draw.circle((1.95, 1.3), radius: 0.08, name: "b2", stroke: none, fill: c)
  draw.circle((1.95, 0.2), radius: 0.08, name: "b3", stroke: none, fill: c)
  draw.circle((3.6, 1.95), radius: 0.08, name: "c1", stroke: none, fill: c)
  draw.circle((3.6, 0.65), radius: 0.08, name: "c2", stroke: none, fill: c)
  for e in (
    ("a1", "b1"),
    ("a2", "b2"),
    ("a2", "b3"),
    ("b1", "c1"),
    ("b2", "c2"),
    ("b3", "c2"),
  ) {
    draw.line(e.at(0), e.at(1), name: "t" + e.at(0) + e.at(1), stroke: thin)
  }
  draw.line("a1", "b2", name: "f1", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("b2", "c1", name: "f2", stroke: st, mark: (end: "stealth", fill: c))
})

// ── Равномощность и отель Гильберта ──
#let hotel-ghost(c) = canvas({
  let st = ink-stroke(c)
  for i in range(4) {
    let x0 = i * 0.95
    draw.rect((x0, 0), (x0 + 0.7, 0.7), name: "room-" + str(i), stroke: st)
    if i > 0 {
      draw.circle(
        (x0 + 0.35, 0.35),
        radius: 0.08,
        name: "guest-" + str(i),
        stroke: none,
        fill: c,
      )
    }
  }
  for i in range(3) {
    let x0 = i * 0.95
    draw.bezier(
      (x0 + 0.35, 0.84),
      (x0 + 1.3, 0.84),
      (x0 + 0.35, 1.32),
      (x0 + 1.3, 1.32),
      name: "shift-" + str(i),
      stroke: st,
      mark: (end: "stealth", fill: c),
    )
  }
  draw.circle(
    (-0.55, 0.35),
    radius: 0.08,
    name: "newcomer",
    stroke: none,
    fill: c,
  )
  draw.line(
    (-0.43, 0.35),
    (-0.09, 0.35),
    name: "checkin",
    stroke: st,
    mark: (end: "stealth", fill: c),
  )
})

// ── Теорема Кантора ──
#let cantor-ghost(c) = canvas({
  let thin = 0.8pt + c
  for i in range(5) {
    for j in range(5) {
      let pos = (0.2 + 0.86 * i, 0.2 + 0.86 * j)
      if i == j {
        draw.circle(
          pos,
          radius: 0.14,
          name: "diag-" + str(i),
          stroke: none,
          fill: c,
        )
      } else {
        draw.circle(
          pos,
          radius: 0.1,
          name: "c-" + str(i) + str(j),
          stroke: thin,
        )
      }
    }
  }
})

// ── Семантика и следствие ──
#let consequence-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.55, 2.1), radius: 0.14, name: "cf-root", stroke: st)
  draw.circle((0.25, 1.4), radius: 0.14, name: "cf-l", stroke: st)
  draw.circle((0.85, 1.4), radius: 0.14, name: "cf-r", stroke: st)
  draw.line("cf-root", "cf-l", name: "cf-el", stroke: st)
  draw.line("cf-root", "cf-r", name: "cf-er", stroke: st)
  draw.line((1.45, 1.7), (1.45, 2.5), name: "cf-ta", stroke: st)
  draw.line((1.67, 1.7), (1.67, 2.5), name: "cf-tb", stroke: st)
  draw.circle((2.85, 2.1), radius: 0.5, name: "cf-model", stroke: st)
  draw.circle((2.85, 2.1), radius: 0.62, name: "cf-ring", stroke: st)
  draw.circle((2.72, 2.24), radius: 0.06, name: "cf-md1", stroke: none, fill: c)
  draw.circle((3.02, 1.98), radius: 0.06, name: "cf-md2", stroke: none, fill: c)
  draw.circle((4.15, 0.75), radius: 0.36, name: "cf-world", stroke: 0.8pt + c)
  draw.circle((4.15, 0.75), radius: 0.06, name: "cf-wd", stroke: none, fill: c)
})

// ── Нормальные формы ──
#let normal-forms-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.9, 2.6), radius: 0.15, name: "nf-cr", stroke: st)
  draw.circle((0.3, 1.75), radius: 0.12, name: "nf-cm1", stroke: st)
  draw.circle((0.9, 1.75), radius: 0.12, name: "nf-cm2", stroke: st)
  draw.circle((1.5, 1.75), radius: 0.12, name: "nf-cm3", stroke: st)
  let cnf-leaves = (
    (0.15, 0.95),
    (0.45, 0.95),
    (0.75, 0.95),
    (1.05, 0.95),
    (1.35, 0.95),
    (1.65, 0.95),
  )
  let cnf-mids = ("nf-cm1", "nf-cm2", "nf-cm3")
  for i in range(3) {
    draw.line("nf-cr", cnf-mids.at(i), name: "nf-ce" + str(i), stroke: st)
    for j in range(2) {
      let pos = cnf-leaves.at(2 * i + j)
      draw.circle(
        pos,
        radius: 0.07,
        name: "nf-cl" + str(i) + str(j),
        stroke: none,
        fill: c,
      )
      draw.line(
        cnf-mids.at(i),
        "nf-cl" + str(i) + str(j),
        name: "nf-cf" + str(i) + str(j),
        stroke: st,
      )
    }
  }
  draw.line((1.95, 1.78), (2.9, 1.78), name: "nf-ar", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.line((2.9, 1.58), (1.95, 1.58), name: "nf-al", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.circle((3.8, 2.6), radius: 0.15, name: "nf-dr", stroke: st)
  draw.circle((3.35, 1.7), radius: 0.12, name: "nf-dm1", stroke: st)
  draw.circle((4.25, 1.7), radius: 0.12, name: "nf-dm2", stroke: st)
  let dnf-mids = ("nf-dm1", "nf-dm2")
  let dnf-leaves = (((3.1, 0.8), (3.6, 0.8)), ((4.0, 0.8), (4.5, 0.8)))
  for i in range(2) {
    draw.line("nf-dr", dnf-mids.at(i), name: "nf-de" + str(i), stroke: st)
    for j in range(2) {
      draw.circle(
        dnf-leaves.at(i).at(j),
        radius: 0.07,
        name: "nf-dl" + str(i) + str(j),
        stroke: none,
        fill: c,
      )
      draw.line(
        dnf-mids.at(i),
        "nf-dl" + str(i) + str(j),
        name: "nf-df" + str(i) + str(j),
        stroke: st,
      )
    }
  }
})

// ── Правила вывода ──
#let inference-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.45, 2.35), radius: 0.09, name: "ir-p1", stroke: none, fill: c)
  draw.circle((1.25, 2.35), radius: 0.09, name: "ir-p2", stroke: none, fill: c)
  draw.line((0.15, 1.85), (1.55, 1.85), name: "ir-l1", stroke: st)
  draw.circle((0.85, 1.35), radius: 0.09, name: "ir-c1", stroke: none, fill: c)
  draw.line((1.85, 1.85), (2.55, 1.85), name: "ir-ar", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.circle((3.0, 2.35), radius: 0.09, name: "ir-p3", stroke: none, fill: c)
  draw.circle((3.8, 2.35), radius: 0.09, name: "ir-p4", stroke: none, fill: c)
  draw.line((2.7, 1.85), (4.1, 1.85), name: "ir-l2", stroke: st)
  draw.circle((3.4, 1.35), radius: 0.09, name: "ir-c2", stroke: none, fill: c)
})

// ── Корректность и полнота ──
#let adequacy-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.line((0.45, 0.85), (0.45, 2.4), name: "ad-bar", stroke: st)
  draw.line((0.45, 1.6), (1.3, 1.6), name: "ad-arm", stroke: st)
  draw.circle((1.65, 1.6), radius: 0.16, name: "ad-thm", stroke: st)
  draw.line((2.15, 2.25), (3.4, 2.25), name: "ad-sound", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.line((3.4, 0.95), (2.15, 0.95), name: "ad-complete", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.circle((4.05, 1.6), radius: 0.55, name: "ad-world", stroke: st)
  draw.circle((3.9, 1.78), radius: 0.06, name: "ad-m1", stroke: none, fill: c)
  draw.circle((4.22, 1.5), radius: 0.06, name: "ad-m2", stroke: none, fill: c)
})

// ── Синтаксис и семантика ──
#let syntax-semantics-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.line((2.15, 0.2), (2.15, 3.05), name: "ss-divide", stroke: (
    paint: c,
    thickness: 0.8pt,
    dash: "dashed",
  ))
  draw.circle((0.7, 2.5), radius: 0.14, name: "ss-root", stroke: st)
  draw.circle((0.4, 1.8), radius: 0.12, name: "ss-l", stroke: st)
  draw.circle((1.0, 1.8), radius: 0.12, name: "ss-r", stroke: st)
  draw.line("ss-root", "ss-l", name: "ss-el", stroke: st)
  draw.line("ss-root", "ss-r", name: "ss-er", stroke: st)
  let leaves = ((0.25, 1.1), (0.55, 1.1), (0.85, 1.1), (1.15, 1.1))
  let parents = ("ss-l", "ss-l", "ss-r", "ss-r")
  for i in range(4) {
    draw.circle(
      leaves.at(i),
      radius: 0.07,
      name: "ss-t" + str(i),
      stroke: none,
      fill: c,
    )
    draw.line(
      parents.at(i),
      "ss-t" + str(i),
      name: "ss-te" + str(i),
      stroke: st,
    )
  }
  draw.line((1.5, 1.75), (2.7, 1.75), name: "ss-map1", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.line((1.5, 1.45), (2.7, 1.45), name: "ss-map2", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.circle((3.55, 1.6), radius: 0.8, name: "ss-world", stroke: st)
  draw.circle((3.3, 1.9), radius: 0.06, name: "ss-d1", stroke: none, fill: c)
  draw.circle((3.8, 1.95), radius: 0.06, name: "ss-d2", stroke: none, fill: c)
  draw.circle((3.35, 1.25), radius: 0.06, name: "ss-d3", stroke: none, fill: c)
  draw.circle((3.85, 1.3), radius: 0.06, name: "ss-d4", stroke: none, fill: c)
})

// ── Силлогизмы Аристотеля ──
#let syllogism-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((2.4, 1.7), radius: 1.7, name: "sy-p", stroke: st)
  draw.circle((2.4, 1.45), radius: 1.15, name: "sy-m", stroke: st)
  draw.circle((2.4, 1.25), radius: 0.65, name: "sy-s", stroke: st)
  draw.circle((2.15, 1.4), radius: 0.07, name: "sy-d1", stroke: none, fill: c)
  draw.circle((2.6, 1.28), radius: 0.07, name: "sy-d2", stroke: none, fill: c)
  draw.circle((2.35, 0.95), radius: 0.07, name: "sy-d3", stroke: none, fill: c)
})

// ── Булевы функции ──
#let boolfun-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.rect((0, 0), (2.7, 2.4), name: "bf-table", stroke: st)
  draw.line((0.9, 0), (0.9, 2.4), name: "bf-v1", stroke: st)
  draw.line((1.8, 0), (1.8, 2.4), name: "bf-v2", stroke: st)
  draw.line((0, 0.6), (2.7, 0.6), name: "bf-h1", stroke: st)
  draw.line((0, 1.2), (2.7, 1.2), name: "bf-h2", stroke: st)
  draw.line((0, 1.8), (2.7, 1.8), name: "bf-h3", stroke: st)
  let dots = ((0.45, 1.5), (0.45, 2.1), (1.35, 0.9), (1.35, 2.1), (2.25, 2.1))
  for i in range(5) {
    draw.circle(
      dots.at(i),
      radius: 0.09,
      name: "bf-d" + str(i),
      stroke: none,
      fill: c,
    )
  }
  draw.line((2.9, 1.2), (3.6, 1.2), name: "bf-arrow", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  draw.circle((3.95, 1.2), radius: 0.32, name: "bf-fn", stroke: st)
  draw.line((4.27, 1.2), (4.6, 1.2), name: "bf-out", stroke: st)
})

// ── Задача SAT ──
#let sat-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.3, 2.25), radius: 0.12, name: "sa-l1", stroke: none, fill: c)
  draw.circle((0.85, 2.25), radius: 0.12, name: "sa-l2", stroke: st)
  draw.circle((1.4, 2.25), radius: 0.12, name: "sa-l3", stroke: none, fill: c)
  draw.line(
    (0.1, 2.13),
    (0.1, 1.95),
    (1.6, 1.95),
    (1.6, 2.13),
    name: "sa-br1",
    stroke: st,
  )
  draw.line(
    (0.63, 1.56),
    (0.85, 1.28),
    (1.07, 1.56),
    name: "sa-and",
    stroke: st,
  )
  draw.circle((0.3, 0.85), radius: 0.12, name: "sa-l4", stroke: st)
  draw.circle((0.85, 0.85), radius: 0.12, name: "sa-l5", stroke: none, fill: c)
  draw.circle((1.4, 0.85), radius: 0.12, name: "sa-l6", stroke: st)
  draw.line(
    (0.1, 0.73),
    (0.1, 0.55),
    (1.6, 0.55),
    (1.6, 0.73),
    name: "sa-br2",
    stroke: st,
  )
  draw.line(
    (2.35, 1.6),
    (2.8, 0.95),
    (3.65, 2.25),
    name: "sa-check",
    stroke: st,
  )
})

// ── Минимизация и полином Жегалкина ──
#let zhegalkin-ghost(c) = canvas({
  let st = ink-stroke(c)
  let xor-node(x, y, nm) = {
    draw.circle((x, y), radius: 0.24, name: nm, stroke: st)
    draw.line((x - 0.13, y), (x + 0.13, y), name: nm + "h", stroke: st)
    draw.line((x, y - 0.13), (x, y + 0.13), name: nm + "v", stroke: st)
  }
  let top = (0.3, 1.2, 2.1, 3.0)
  for i in range(4) {
    xor-node(top.at(i), 2.15, "zg-t" + str(i))
  }
  draw.line((0.54, 2.15), (0.96, 2.15), name: "zg-c1", stroke: st)
  draw.line((1.44, 2.15), (1.86, 2.15), name: "zg-c2", stroke: st)
  draw.line((2.34, 2.15), (2.76, 2.15), name: "zg-c3", stroke: st)
  draw.line((1.65, 1.72), (1.65, 1.18), name: "zg-arrow", stroke: st, mark: (
    end: "stealth",
    fill: c,
  ))
  xor-node(1.2, 0.75, "zg-b0")
  xor-node(2.1, 0.75, "zg-b1")
  draw.line((1.44, 0.75), (1.86, 0.75), name: "zg-c4", stroke: st)
})

// ── Логические схемы ──
#let circuit-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.1, 2.05), radius: 0.09, name: "ci-a", stroke: none, fill: c)
  draw.line((0.17, 2.05), (1.6, 2.05), name: "ci-wa", stroke: st)
  draw.circle((0.1, 0.5), radius: 0.09, name: "ci-b", stroke: none, fill: c)
  draw.line((0.17, 0.5), (0.55, 0.5), name: "ci-wb", stroke: st)
  draw.line(
    (0.55, 0.2),
    (0.55, 0.8),
    (1.15, 0.5),
    close: true,
    name: "ci-not",
    stroke: st,
  )
  draw.circle((1.25, 0.5), radius: 0.08, name: "ci-bub1", stroke: st)
  draw.line((1.33, 0.5), (1.45, 0.5), name: "ci-w1", stroke: st)
  draw.line((1.45, 0.5), (1.45, 1.5), name: "ci-w2", stroke: st)
  draw.line((1.45, 1.5), (1.6, 1.5), name: "ci-w3", stroke: st)
  draw.line((1.6, 1.5), (1.6, 2.05), name: "ci-gleft", stroke: st)
  draw.line((1.6, 2.05), (2.05, 2.05), name: "ci-gtop", stroke: st)
  draw.line((1.6, 1.5), (2.05, 1.5), name: "ci-gbot", stroke: st)
  draw.arc(
    (2.05, 1.5),
    start: -90deg,
    stop: 90deg,
    radius: 0.275,
    name: "ci-garc",
    stroke: st,
  )
  draw.circle((2.41, 1.775), radius: 0.08, name: "ci-bub2", stroke: st)
  draw.line((2.49, 1.775), (3.3, 1.775), name: "ci-out", stroke: st)
  draw.circle((3.37, 1.775), radius: 0.09, name: "ci-f", stroke: none, fill: c)
})

// ── Верификация через SAT ──
#let miter-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.line((-0.1, 2.1), (0.3, 2.1), name: "mt-sa1", stroke: st)
  draw.line((-0.1, 2.3), (0.3, 2.3), name: "mt-sa2", stroke: st)
  draw.line((0.3, 1.95), (0.3, 2.45), name: "mt-aleft", stroke: st)
  draw.line((0.3, 2.45), (0.7, 2.45), name: "mt-atop", stroke: st)
  draw.line((0.3, 1.95), (0.7, 1.95), name: "mt-abot", stroke: st)
  draw.arc(
    (0.7, 1.95),
    start: -90deg,
    stop: 90deg,
    radius: 0.25,
    name: "mt-aarc",
    stroke: st,
  )
  draw.line((-0.1, 0.7), (0.3, 0.7), name: "mt-sb1", stroke: st)
  draw.line((-0.1, 0.9), (0.3, 0.9), name: "mt-sb2", stroke: st)
  draw.line((0.3, 0.55), (0.3, 1.05), name: "mt-bleft", stroke: st)
  draw.line((0.3, 1.05), (0.7, 1.05), name: "mt-btop", stroke: st)
  draw.line((0.3, 0.55), (0.7, 0.55), name: "mt-bbot", stroke: st)
  draw.arc(
    (0.7, 0.55),
    start: -90deg,
    stop: 90deg,
    radius: 0.25,
    name: "mt-barc",
    stroke: st,
  )
  draw.line((0.95, 2.2), (2.13, 1.61), name: "mt-wa", stroke: st)
  draw.line((0.95, 0.8), (2.13, 1.39), name: "mt-wb", stroke: st)
  draw.circle((2.35, 1.5), radius: 0.25, name: "mt-xor", stroke: st)
  draw.line((2.22, 1.5), (2.48, 1.5), name: "mt-xh", stroke: st)
  draw.line((2.35, 1.37), (2.35, 1.63), name: "mt-xv", stroke: st)
  draw.line((2.6, 1.5), (3.15, 1.5), name: "mt-out", stroke: st)
  draw.line((3.2, 1.2), (3.65, 1.8), name: "mt-x1", stroke: st)
  draw.line((3.2, 1.8), (3.65, 1.2), name: "mt-x2", stroke: st)
})

// ── Шары Хэмминга ──
#let hamming-balls-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.9, 1.1), radius: 0.95, name: "hb-ball0", stroke: st)
  draw.circle((3.2, 1.35), radius: 0.95, name: "hb-ball1", stroke: st)
  draw.circle((3.5, 1.9), radius: 0.09, name: "hb-rx", stroke: 0.8pt + c)
  draw.line(
    (3.44, 1.8),
    (3.28, 1.52),
    name: "hb-decode",
    stroke: 0.8pt + c,
    mark: (end: "stealth", fill: c),
  )
  draw.circle((0.9, 1.1), radius: 0.07, name: "hb-cw0", stroke: none, fill: c)
  draw.circle((3.2, 1.35), radius: 0.07, name: "hb-cw1", stroke: none, fill: c)
})

// ── Дерево Хаффмана ──
#let huffman-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.9, 2.6), radius: 0.16, name: "hf-root", stroke: st)
  draw.circle((3.0, 1.7), radius: 0.15, name: "hf-i1", stroke: st)
  draw.circle((3.8, 0.85), radius: 0.15, name: "hf-i2", stroke: st)
  let leaves = ((0.8, 1.7), (2.3, 0.85), (3.45, 0.0), (4.35, 0.0))
  for k in range(4) {
    draw.circle(
      leaves.at(k),
      radius: 0.07,
      name: "hf-l" + str(k),
      stroke: none,
      fill: c,
    )
  }
  for p in (
    ("hf-root", "hf-l0"),
    ("hf-root", "hf-i1"),
    ("hf-i1", "hf-l1"),
    ("hf-i1", "hf-i2"),
    ("hf-i2", "hf-l2"),
    ("hf-i2", "hf-l3"),
  ) {
    draw.line(p.at(0), p.at(1), name: "hf-" + p.at(0) + p.at(1), stroke: st)
  }
})

// ── Дерево решений ──
#let counting-tree-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.15, 1.5), radius: 0.16, name: "cntr-root", stroke: st)
  let branches = (2.35, 1.5, 0.65)
  for k in range(3) {
    let y = branches.at(k)
    draw.circle((1.7, y), radius: 0.14, name: "cntr-b" + str(k), stroke: st)
    for d in range(2) {
      let ly = y + if d == 0 { 0.28 } else { -0.28 }
      draw.circle(
        (3.45, ly),
        radius: 0.07,
        name: "cntr-l" + str(k) + str(d),
        stroke: none,
        fill: c,
      )
    }
  }
  for k in range(3) {
    draw.line(
      "cntr-root",
      "cntr-b" + str(k),
      name: "cntr-e" + str(k),
      stroke: st,
    )
    for d in range(2) {
      draw.line(
        "cntr-b" + str(k),
        "cntr-l" + str(k) + str(d),
        name: "cntr-ee" + str(k) + str(d),
        stroke: st,
      )
    }
  }
})

// ── Принцип Дирихле ──
#let pigeonhole-ghost(c) = canvas({
  let st = ink-stroke(c)
  for k in range(3) {
    draw.rect(
      (k * 1.35, 0),
      (k * 1.35 + 1.1, 1.15),
      name: "ph-b" + str(k),
      stroke: st,
    )
  }
  let birds = ((0.38, 0.55), (0.72, 0.55), (1.9, 0.55), (3.25, 0.55))
  for k in range(4) {
    draw.circle(
      birds.at(k),
      radius: 0.07,
      name: "ph-d" + str(k),
      stroke: none,
      fill: c,
    )
  }
})

// ── Выбор k из n ──
#let choose-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.85, 1.2), radius: 1.45, name: "ch-ring", stroke: st)
  let xs = (0.15, 1.0, 1.85, 2.7, 3.55)
  for k in range(5) {
    draw.circle(
      (xs.at(k), 1.2),
      radius: 0.07,
      name: "ch-n" + str(k),
      stroke: none,
      fill: c,
    )
  }
})

// ── Три множества ──
#let venn3-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.35, 1.0), radius: 1.2, name: "vn-a", stroke: st)
  draw.circle((2.55, 1.0), radius: 1.2, name: "vn-b", stroke: st)
  draw.circle((1.95, 2.04), radius: 1.2, name: "vn-c", stroke: st)
})

// ── Цепочка рекурренты ──
#let recurrence-ghost(c) = canvas({
  let st = ink-stroke(c)
  let xs = (0.25, 1.4, 2.55, 3.7)
  for k in range(3) {
    draw.line(
      (xs.at(k + 1) - 0.15, 0.9),
      (xs.at(k) + 0.15, 0.9),
      name: "rc-e" + str(k),
      stroke: st,
      mark: (end: "stealth", fill: c),
    )
  }
  draw.bezier(
    (3.7, 1.05),
    (1.4, 1.05),
    (3.35, 2.1),
    (1.75, 2.1),
    name: "rc-skip",
    stroke: st,
    mark: (end: "stealth", fill: c),
  )
  for k in range(4) {
    draw.circle(
      (xs.at(k), 0.9),
      radius: 0.07,
      name: "rc-n" + str(k),
      stroke: none,
      fill: c,
    )
  }
})

// ── Тропинка Каталана ──
#let catalan-ghost(c) = canvas({
  let st = ink-stroke(c)
  let s = 1.15
  draw.line((0, 0), (3 * s, 3 * s), name: "dy-diag", stroke: 0.8pt + c)
  let pts = (
    (0, 0),
    (0, s),
    (0, 2 * s),
    (s, 2 * s),
    (s, 3 * s),
    (2 * s, 3 * s),
    (3 * s, 3 * s),
  )
  draw.line(..pts, name: "dy-path", stroke: st)
  draw.circle((0, 0), radius: 0.07, name: "dy-a", stroke: none, fill: c)
  draw.circle((3 * s, 3 * s), radius: 0.07, name: "dy-b", stroke: none, fill: c)
})

// ── Ряд коэффициентов ──
#let ogf-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.line((0.15, 0.2), (3.55, 0.2), name: "ogf-axis", stroke: st)
  let xs = (0.5, 1.06, 1.62, 2.18, 2.74, 3.3)
  let hs = (0.34, 0.34, 0.68, 1.02, 1.7, 2.72)
  for k in range(6) {
    draw.line(
      (xs.at(k), 0.2),
      (xs.at(k), 0.2 + hs.at(k)),
      name: "ogf-s" + str(k),
      stroke: st,
    )
    draw.circle(
      (xs.at(k), 0.2 + hs.at(k)),
      radius: 0.07,
      name: "ogf-d" + str(k),
      stroke: none,
      fill: c,
    )
  }
})

// ── Извлечение коэффициента ──
#let coeff-extract-ghost(c) = canvas({
  let thin = 0.8pt + c
  draw.line((0.15, 0.2), (3.75, 0.2), name: "ce-axis", stroke: thin)
  let xs = (0.55, 1.2, 1.85, 2.5, 3.15)
  let hs = (0.45, 0.7, 0.55, 0.85, 0.6)
  for k in range(5) {
    draw.line(
      (xs.at(k), 0.2),
      (xs.at(k), 0.2 + hs.at(k)),
      name: "ce-s" + str(k),
      stroke: thin,
    )
    draw.circle(
      (xs.at(k), 0.2 + hs.at(k)),
      radius: 0.07,
      name: "ce-d" + str(k),
      stroke: thin,
    )
  }
  draw.line(
    (1.85, 0.85),
    (1.85, 2.0),
    name: "ce-pull",
    stroke: ink-stroke(c),
    mark: (end: "stealth", fill: c),
  )
  draw.circle((1.85, 2.18), radius: 0.07, name: "ce-out", stroke: none, fill: c)
})

// ── Ожерелья и поворот ──
#let necklace-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((1.0, 1.35), radius: 0.85, name: "nk-r0", stroke: st)
  draw.circle((3.3, 1.35), radius: 0.85, name: "nk-r1", stroke: 0.8pt + c)
  for k in range(6) {
    let a = k * 60deg
    draw.circle(
      (1.0 + 0.85 * calc.cos(a), 1.35 + 0.85 * calc.sin(a)),
      radius: 0.1,
      name: "nk-a" + str(k),
      stroke: none,
      fill: c,
    )
    let b = k * 60deg + 30deg
    draw.circle(
      (3.3 + 0.85 * calc.cos(b), 1.35 + 0.85 * calc.sin(b)),
      radius: 0.08,
      name: "nk-b" + str(k),
      stroke: none,
      fill: c,
    )
  }
  draw.line(
    (1.95, 1.7),
    (2.5, 1.7),
    name: "nk-rot",
    stroke: st,
    mark: (end: "stealth", fill: c),
  )
})

// ── Треугольник Рамсея ──
#let ramsey-ghost(c) = canvas({
  let st = ink-stroke(c)
  let (cx, cy, r) = (2.05, 1.7, 1.6)
  for k in range(6) {
    let a = k * 60deg
    draw.circle(
      (cx + r * calc.cos(a), cy + r * calc.sin(a)),
      radius: 0.13,
      name: "rm-v" + str(k),
      stroke: st,
    )
  }
  for i in range(6) {
    for j in range(i + 1, 6) {
      draw.line(
        "rm-v" + str(i),
        "rm-v" + str(j),
        name: "rm-e" + str(i) + str(j),
        stroke: 0.8pt + c,
      )
    }
  }
  for p in (("rm-v0", "rm-v2"), ("rm-v2", "rm-v4"), ("rm-v4", "rm-v0")) {
    draw.line(p.at(0), p.at(1), name: "rm-tri" + p.at(0) + p.at(1), stroke: st)
  }
})

// ── Кёнигсберг: мультиграф семи мостов ──
#let konigsberg-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.35, 2.15), radius: 0.19, name: "bank-n", stroke: st)
  draw.circle((0.35, 0.15), radius: 0.19, name: "bank-s", stroke: st)
  draw.circle((2.1, 1.15), radius: 0.19, name: "island-k", stroke: st)
  draw.circle((4.05, 1.15), radius: 0.19, name: "island-l", stroke: st)
  draw.line("bank-n", "island-l", name: "b-nl", stroke: st)
  draw.line("bank-s", "island-l", name: "b-sl", stroke: st)
  draw.line("island-k", "island-l", name: "b-kl", stroke: st)
  draw.bezier(
    (0.444, 2.315),
    (2.192, 0.984),
    (0.75, 2.85),
    (1.55, 2.15),
    name: "b-nk1",
    stroke: st,
  )
  draw.bezier(
    (0.46, 1.995),
    (2.285, 1.193),
    (0.6, 1.8),
    (1.45, 1.0),
    name: "b-nk2",
    stroke: st,
  )
  draw.bezier(
    (0.475, 0.293),
    (2.273, 1.23),
    (0.7, 0.55),
    (1.45, 0.85),
    name: "b-sk1",
    stroke: st,
  )
  draw.bezier(
    (0.427, -0.024),
    (2.21, 1.305),
    (0.55, -0.3),
    (1.5, 0.3),
    name: "b-sk2",
    stroke: st,
  )
})

// ── Гамильтонов цикл: пентаграмма через все вершины ──
#let hamiltonian-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((2.3, 3.1), radius: 0.17, name: "p0", stroke: st)
  draw.circle((0.87, 2.06), radius: 0.17, name: "p1", stroke: st)
  draw.circle((1.42, 0.39), radius: 0.17, name: "p2", stroke: st)
  draw.circle((3.18, 0.39), radius: 0.17, name: "p3", stroke: st)
  draw.circle((3.73, 2.06), radius: 0.17, name: "p4", stroke: st)
  for e in (
    ("p0", "p1"),
    ("p1", "p2"),
    ("p2", "p3"),
    ("p3", "p4"),
    ("p4", "p0"),
  ) {
    draw.line(
      e.at(0),
      e.at(1),
      name: "h" + e.at(0) + e.at(1),
      stroke: 0.8pt + c,
    )
  }
  for e in (
    ("p0", "p2"),
    ("p2", "p4"),
    ("p4", "p1"),
    ("p1", "p3"),
    ("p3", "p0"),
  ) {
    draw.line(e.at(0), e.at(1), name: "c" + e.at(0) + e.at(1), stroke: st)
  }
})

// ── Двудольность и паросочетание: доли и выделенное паросочетание ──
#let matching-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.4, 2.3), radius: 0.18, name: "l0", stroke: st)
  draw.circle((0.4, 1.3), radius: 0.18, name: "l1", stroke: st)
  draw.circle((0.4, 0.3), radius: 0.18, name: "l2", stroke: st)
  draw.rect((3.5, 2.1), (3.9, 2.5), name: "r0", stroke: st)
  draw.rect((3.5, 1.1), (3.9, 1.5), name: "r1", stroke: st)
  draw.rect((3.5, 0.1), (3.9, 0.5), name: "r2", stroke: st)
  for e in (
    ("l0", "r1"),
    ("l0", "r2"),
    ("l1", "r0"),
    ("l1", "r2"),
    ("l2", "r0"),
    ("l2", "r1"),
  ) {
    draw.line(
      e.at(0),
      e.at(1),
      name: "m" + e.at(0) + e.at(1),
      stroke: 0.8pt + c,
    )
  }
  draw.line("l0", "r0", name: "mm0", stroke: st)
  draw.line("l1", "r1", name: "mm1", stroke: st)
  draw.line("l2", "r2", name: "mm2", stroke: st)
})

// ── Кратчайший путь: веса черточками, маршрут Дейкстры жирным ──
#let dijkstra-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.circle((0.35, 1.3), radius: 0.18, name: "s", stroke: st)
  draw.circle((0.35, 1.3), radius: 0.28, name: "sr", stroke: st)
  draw.circle((4.15, 1.3), radius: 0.18, name: "t", stroke: st)
  draw.circle((4.15, 1.3), radius: 0.28, name: "tr", stroke: st)
  draw.circle((1.45, 2.45), radius: 0.18, name: "a", stroke: st)
  draw.circle((2.95, 2.35), radius: 0.18, name: "b", stroke: st)
  draw.circle((1.35, 0.25), radius: 0.18, name: "d", stroke: st)
  draw.circle((2.85, 0.15), radius: 0.18, name: "e", stroke: st)
  draw.line("s", "d", name: "w-sd", stroke: thin)
  draw.line("d", "e", name: "w-de", stroke: thin)
  draw.line("e", "t", name: "w-et", stroke: thin)
  draw.line("d", "b", name: "w-db", stroke: thin)
  draw.line("s", "a", name: "p-sa", stroke: st)
  draw.line("a", "b", name: "p-ab", stroke: st)
  draw.line("b", "t", name: "p-bt", stroke: st, mark: (end: "stealth", fill: c))
  let tick(pair, n) = {
    let u = pair.at(0)
    let v = pair.at(1)
    let dx = v.at(0) - u.at(0)
    let dy = v.at(1) - u.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    let px = -dy / len * 0.12
    let py = dx / len * 0.12
    for i in range(n) {
      let f = (i + 1) / (n + 1)
      let mx = u.at(0) + dx * f
      let my = u.at(1) + dy * f
      draw.line((mx - px, my - py), (mx + px, my + py), stroke: thin)
    }
  }
  tick(((0.35, 1.3), (1.45, 2.45)), 1)
  tick(((1.45, 2.45), (2.95, 2.35)), 1)
  tick(((2.95, 2.35), (4.15, 1.3)), 1)
  tick(((0.35, 1.3), (1.35, 0.25)), 2)
  tick(((1.35, 0.25), (2.85, 0.15)), 2)
  tick(((2.85, 0.15), (4.15, 1.3)), 2)
  tick(((1.35, 0.25), (2.95, 2.35)), 3)
})

// ── Раскраска: карта из четырёх территорий с разными узорами ──
#let map-coloring-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.rect((0, 0), (4.2, 2.6), name: "map", stroke: st)
  draw.bezier(
    (2.1, 0),
    (2.1, 2.6),
    (1.85, 0.9),
    (2.35, 1.75),
    name: "div-v",
    stroke: st,
  )
  draw.bezier(
    (0, 1.3),
    (2.1, 1.32),
    (0.7, 1.45),
    (1.4, 1.15),
    name: "div-l",
    stroke: st,
  )
  draw.bezier(
    (2.15, 1.71),
    (4.2, 1.6),
    (2.8, 1.85),
    (3.5, 1.45),
    name: "div-r",
    stroke: st,
  )
  draw.line((0.35, 1.55), (0.95, 2.15), stroke: thin)
  draw.line((0.75, 1.5), (1.55, 2.3), stroke: thin)
  draw.line((1.25, 1.5), (1.9, 2.15), stroke: thin)
  for p in ((2.6, 2.25), (3.2, 2.4), (3.8, 2.25), (3.5, 1.95)) {
    draw.circle(p, radius: 0.06, stroke: none, fill: c)
  }
  draw.line((2.5, 1.15), (3.1, 0.55), stroke: thin)
  draw.line((3.0, 1.25), (3.8, 0.45), stroke: thin)
  draw.line((3.55, 1.3), (3.95, 0.9), stroke: thin)
  draw.line((0.35, 0.95), (1.05, 0.95), stroke: thin)
  draw.line((1.25, 0.6), (1.95, 0.6), stroke: thin)
  draw.line((0.4, 0.35), (1.0, 0.35), stroke: thin)
})

// ── Сетевой поток: исток-сток, пропускные способности, направленные дуги ──
#let flow-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  let mk = (end: "stealth", fill: c)
  draw.rect((0.1, 1.05), (0.5, 1.45), name: "s", stroke: st)
  draw.rect((4.0, 1.05), (4.4, 1.45), name: "t", stroke: st)
  draw.circle((1.55, 2.4), radius: 0.17, name: "u", stroke: st)
  draw.circle((3.05, 2.3), radius: 0.17, name: "w", stroke: st)
  draw.circle((1.55, 0.25), radius: 0.17, name: "v", stroke: st)
  draw.circle((3.05, 0.35), radius: 0.17, name: "x", stroke: st)
  draw.line("s", "v", name: "f-sv", stroke: thin, mark: mk)
  draw.line("v", "x", name: "f-vx", stroke: thin, mark: mk)
  draw.line("x", "t", name: "f-xt", stroke: thin, mark: mk)
  draw.line("v", "w", name: "f-vw", stroke: thin, mark: mk)
  draw.line("s", "u", name: "f-su", stroke: st, mark: mk)
  draw.line("u", "w", name: "f-uw", stroke: st, mark: mk)
  draw.line("w", "t", name: "f-wt", stroke: st, mark: mk)
})

// ── Языки и слова: слово из бусин под звездой Клини ──
#let words-ghost(c) = canvas({
  let st = ink-stroke(c)
  let (cx, cy) = (2.25, 2.3)
  for (i, a) in ((90deg, 30deg, 150deg).enumerate()) {
    draw.line(
      (cx + 0.8 * calc.cos(a), cy + 0.8 * calc.sin(a)),
      (cx - 0.8 * calc.cos(a), cy - 0.8 * calc.sin(a)),
      name: "ray-" + str(i),
      stroke: st,
    )
  }
  for (i, x) in ((0.45, 1.05, 1.95, 2.55, 3.45, 4.05).enumerate()) {
    draw.circle(
      (x, 0.55),
      radius: 0.11,
      name: "w" + str(i),
      stroke: none,
      fill: c,
    )
  }
})

// ── Недетерминизм: ветвление путей и эпсилон-ход ──
#let nfa-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.35, 1.05), radius: 0.3, name: "q0", stroke: st)
  draw.circle((2.0, 2.05), radius: 0.3, name: "qa", stroke: st)
  draw.circle((2.0, 0.05), radius: 0.3, name: "qb", stroke: st)
  draw.circle((3.65, 1.05), radius: 0.3, name: "qf", stroke: st)
  draw.circle((3.65, 1.05), radius: 0.42, name: "qfr", stroke: st)
  draw.line("q0", "qa", name: "e1", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("q0", "qb", name: "e2", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("qa", "qf", name: "e3", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("qb", "qf", name: "e4", stroke: st, mark: (end: "stealth", fill: c))
  draw.line(
    "q0",
    "qf",
    name: "eps",
    stroke: (paint: c, thickness: 2pt, dash: "dashed"),
    mark: (end: "stealth", fill: c),
  )
})

// ── Конструкция подмножеств: состояние ДКА --- множество состояний НКА ──
#let subset-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.95, 1.1), radius: 0.85, name: "sa", stroke: st)
  draw.circle((3.35, 1.1), radius: 0.85, name: "sb", stroke: st)
  draw.line("sa", "sb", name: "t", stroke: st, mark: (end: "stealth", fill: c))
  for (i, p) in (((0.62, 1.42), (1.18, 1.3), (0.82, 0.82)).enumerate()) {
    draw.circle(p, radius: 0.09, name: "da" + str(i), stroke: none, fill: c)
  }
  for (i, p) in (((3.12, 1.35), (3.56, 0.9)).enumerate()) {
    draw.circle(p, radius: 0.09, name: "db" + str(i), stroke: none, fill: c)
  }
})

// ── Регулярные выражения: дерево выражения со звездой в корне ──
#let regex-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((2.05, 2.35), radius: 0.2, name: "root", stroke: st)
  for i in range(6) {
    let a = i * 60deg
    draw.line(
      (2.05 + 0.3 * calc.cos(a), 2.35 + 0.3 * calc.sin(a)),
      (2.05 + 0.52 * calc.cos(a), 2.35 + 0.52 * calc.sin(a)),
      name: "ray" + str(i),
      stroke: st,
    )
  }
  draw.circle((1.0, 1.25), radius: 0.2, name: "op1", stroke: st)
  draw.circle((3.1, 1.25), radius: 0.2, name: "op2", stroke: st)
  for (i, x) in ((0.4, 1.6, 2.5, 3.7).enumerate()) {
    draw.circle(
      (x, 0.3),
      radius: 0.1,
      name: "at" + str(i),
      stroke: none,
      fill: c,
    )
  }
  draw.line("root", "op1", name: "r1", stroke: st)
  draw.line("root", "op2", name: "r2", stroke: st)
  draw.line("op1", "at0", name: "r3", stroke: st)
  draw.line("op1", "at1", name: "r4", stroke: st)
  draw.line("op2", "at2", name: "r5", stroke: st)
  draw.line("op2", "at3", name: "r6", stroke: st)
})

// ── Нерегулярные языки: слово с накачиваемой серединой ──
#let pumping-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.35, 0.7), radius: 0.11, name: "px0", stroke: st)
  draw.circle((0.95, 0.7), radius: 0.11, name: "px1", stroke: st)
  draw.circle((1.85, 0.7), radius: 0.11, name: "py0", stroke: none, fill: c)
  draw.circle((2.45, 0.7), radius: 0.11, name: "py1", stroke: none, fill: c)
  draw.circle((3.35, 0.7), radius: 0.11, name: "pz0", stroke: st)
  draw.circle((3.95, 0.7), radius: 0.11, name: "pz1", stroke: st)
  draw.arc(
    (2.15 + 0.72 * calc.cos(25deg), 0.7 + 0.72 * calc.sin(25deg)),
    start: 25deg,
    stop: 155deg,
    radius: 0.72,
    name: "pump",
    stroke: st,
    mark: (end: "stealth", fill: c),
  )
})

// ── Различимость состояний: одно слово разводит состояния по судьбам ──
#let distinguish-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.55, 1.75), radius: 0.3, name: "p", stroke: st)
  draw.circle((0.55, 0.45), radius: 0.3, name: "q", stroke: st)
  draw.circle((3.55, 1.75), radius: 0.3, name: "f", stroke: st)
  draw.circle((3.55, 1.75), radius: 0.42, name: "fr", stroke: st)
  draw.circle((3.55, 0.45), radius: 0.3, name: "r", stroke: st)
  draw.line("p", "f", name: "wp", stroke: st, mark: (end: "stealth", fill: c))
  draw.line("q", "r", name: "wq", stroke: st, mark: (end: "stealth", fill: c))
  for (xi, x) in ((1.45, 2.05, 2.65).enumerate()) {
    for (y, s) in ((1.75, "a"), (0.45, "b")) {
      draw.circle(
        (x, y),
        radius: 0.06,
        name: "sym" + s + str(xi),
        stroke: none,
        fill: c,
      )
    }
  }
})

// ── Минимизация: пара эквивалентных состояний сливается в одно ──
#let minimize-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.5, 1.85), radius: 0.32, name: "mp", stroke: st)
  draw.circle((0.5, 0.45), radius: 0.32, name: "mq", stroke: st)
  draw.circle((3.25, 1.15), radius: 0.5, name: "mm", stroke: st)
  draw.bezier(
    (0.88, 1.92),
    (2.83, 1.44),
    (1.8, 1.95),
    (2.4, 1.75),
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.bezier(
    (0.88, 0.38),
    (2.83, 0.86),
    (1.8, 0.35),
    (2.4, 0.55),
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
})

// ── Классы неразличимости: состояния автомата разбиты на классы ──
#let nerode-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.55, 0.8), radius: 0.15, name: "s0", stroke: st)
  draw.circle((1.45, 1.5), radius: 0.15, name: "s1", stroke: st)
  draw.circle((2.35, 0.8), radius: 0.15, name: "s2", stroke: st)
  draw.circle((3.25, 1.5), radius: 0.15, name: "s3", stroke: st)
  draw.circle((4.15, 0.8), radius: 0.15, name: "s4", stroke: st)
  draw.line("s0", "s1", name: "t0", stroke: st)
  draw.line("s1", "s2", name: "t1", stroke: st)
  draw.line("s2", "s3", name: "t2", stroke: st)
  draw.line("s3", "s4", name: "t3", stroke: st)
  let cls = (
    (1.0, 1.15, 0.86, "c0"),
    (2.35, 0.8, 0.42, "c1"),
    (3.7, 1.15, 0.86, "c2"),
  )
  for (x, y, r, nm) in cls {
    draw.circle(
      (x, y),
      radius: r,
      name: nm,
      stroke: (paint: c, thickness: 0.8pt, dash: "dashed"),
    )
  }
})

// ── Многоленточная машина ──
#let multitape-ghost(c) = canvas({
  let st = ink-stroke(c)
  let w = 0.6
  let rows = ((0, "t1"), (0.95, "t2"), (1.9, "t3"))
  for (y0, nm) in rows {
    for i in range(5) {
      draw.rect(
        (0.5 + i * w, y0),
        (0.5 + (i + 1) * w, y0 + w),
        name: nm + "-c" + str(i),
        stroke: st,
      )
    }
  }
  let heads = ((1.4, 0.6), (2.6, 1.55), (2.0, 2.5))
  for (hx, ytop) in heads {
    draw.line(
      (hx - 0.13, ytop + 0.26),
      (hx + 0.13, ytop + 0.26),
      (hx, ytop),
      close: true,
      fill: c,
      stroke: none,
    )
  }
})

// ── Тезис Чёрча--Тьюринга ──
#let churchturing-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.circle((0.55, 2.45), radius: 0.28, name: "lambda", stroke: st)
  draw.rect((1.66, 2.17), (2.22, 2.73), name: "recfn", stroke: st)
  draw.polygon((3.35, 2.45), 6, radius: 0.3, name: "formalism", stroke: st)
  for i in range(4) {
    draw.rect(
      (0.89 + i * 0.525, 0),
      (0.89 + (i + 1) * 0.525, 0.525),
      name: "tape-c" + str(i),
      stroke: st,
    )
  }
  draw.line(
    "lambda",
    (1.2, 0.525),
    name: "a1",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.line(
    "recfn",
    (1.94, 0.525),
    name: "a2",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.line(
    "formalism",
    (2.68, 0.525),
    name: "a3",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
})

// ── Универсальная машина ──
#let universal-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.rect((0.7, 0.7), (2.7, 2.7), name: "U", stroke: st)
  for i in range(3) {
    draw.rect(
      (1.07 + i * 0.42, 1.49),
      (1.07 + (i + 1) * 0.42, 1.91),
      name: "pgm-c" + str(i),
      stroke: st,
    )
  }
  draw.circle((1.28, 1.7), radius: 0.07, name: "bit0", stroke: none, fill: c)
  draw.circle((2.12, 1.7), radius: 0.07, name: "bit2", stroke: none, fill: c)
  draw.line(
    (-0.4, 1.7),
    (0.7, 1.7),
    name: "in",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.line(
    (2.7, 1.7),
    (3.8, 1.7),
    name: "out",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
})

// ── Диагональный аргумент ──
#let diagonalization-ghost(c) = canvas({
  let thin = 0.8pt + c
  for i in range(5) {
    draw.line((i * 0.8, 0), (i * 0.8, 3.2), name: "v" + str(i), stroke: thin)
    draw.line((0, i * 0.8), (3.2, i * 0.8), name: "h" + str(i), stroke: thin)
  }
  let pts = ((0.4, 2.8), (1.2, 2.0), (2.0, 1.2), (2.8, 0.4))
  draw.line(..pts, name: "diag", stroke: ink-stroke(c))
  for i in range(4) {
    draw.circle(
      pts.at(i),
      radius: 0.08,
      name: "d" + str(i),
      stroke: none,
      fill: c,
    )
  }
})

// ── Проблема остановки ──
#let halting-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.arc(
    (0.7, 2.0),
    start: 180deg,
    stop: 480deg,
    radius: 1.7,
    name: "loop1",
    stroke: st,
  )
  draw.arc(
    (1.55, 3.472),
    start: 120deg,
    stop: 410deg,
    radius: 1.25,
    name: "loop2",
    stroke: st,
  )
  draw.arc(
    (2.978, 3.347),
    start: 50deg,
    stop: 340deg,
    radius: 0.82,
    name: "loop3",
    stroke: st,
  )
  draw.line(
    (3.28, 2.598),
    (3.316, 2.404),
    (3.128, 2.473),
    close: true,
    fill: c,
    stroke: none,
  )
})

// ── Сведение ──
#let reduction-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.circle((0.55, 1.55), radius: 0.3, name: "src", stroke: st)
  draw.rect((2.9, 1.25), (3.5, 1.85), name: "dst", stroke: st)
  draw.line((0.55, 1.85), (0.55, 2.5), (1.68, 2.5), name: "fwd-l", stroke: st)
  draw.polygon((1.875, 2.5), 4, radius: 0.19, name: "map", stroke: st)
  draw.line(
    (2.07, 2.5),
    (3.2, 2.5),
    (3.2, 1.85),
    name: "fwd-r",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.line(
    (3.2, 1.25),
    (3.2, 0.55),
    (0.55, 0.55),
    (0.55, 1.25),
    name: "back",
    mark: (end: "stealth", fill: c),
    stroke: thin,
  )
  draw.line(
    (-0.45, 1.55),
    "src",
    name: "in",
    mark: (end: "stealth", fill: c),
    stroke: thin,
  )
})

// ── Перечислимость ──
#let enumerator-ghost(c) = canvas({
  let st = ink-stroke(c)
  draw.rect((0.3, 1.05), (1.35, 2.1), name: "enum", stroke: st)
  draw.line(
    (1.35, 1.575),
    (2.25, 1.575),
    name: "emit",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  let dots = (
    (2.6, 0.075),
    (2.95, 0.065),
    (3.3, 0.055),
    (3.6, 0.048),
    (3.87, 0.042),
  )
  for (i, d) in dots.enumerate() {
    draw.circle(
      (d.at(0), 1.575),
      radius: d.at(1),
      name: "w" + str(i),
      stroke: none,
      fill: c,
    )
  }
})

// ── Теорема Райса ──
#let rice-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.rect((0.6, 1.0), (2.8, 3.2), name: "decider", stroke: st)
  draw.line((0.78, 3.02), (2.62, 1.18), name: "no1", stroke: st)
  draw.line((2.62, 3.02), (0.78, 1.18), name: "no2", stroke: st)
  for i in range(4) {
    draw.rect(
      (0.6 + i * 0.55, 0.45),
      (0.6 + (i + 1) * 0.55, 1.0),
      name: "tc" + str(i),
      stroke: st,
    )
  }
  draw.line(
    (-0.5, 2.1),
    (0.6, 2.1),
    name: "ask",
    mark: (end: "stealth", fill: c),
    stroke: thin,
  )
})

// ── Оракул ──
#let oracle-ghost(c) = canvas({
  let st = ink-stroke(c)
  let thin = 0.8pt + c
  draw.circle((0.6, 0.7), radius: 0.36, name: "machine", stroke: st)
  draw.polygon((3.2, 2.7), 4, radius: 0.45, name: "oracle", stroke: st)
  draw.line(
    (0.948, 0.968),
    (2.781, 2.377),
    name: "ask",
    mark: (end: "stealth", fill: c),
    stroke: st,
  )
  draw.line(
    (2.678, 2.512),
    (0.845, 1.103),
    name: "answer",
    mark: (end: "stealth", fill: c),
    stroke: thin,
  )
})
