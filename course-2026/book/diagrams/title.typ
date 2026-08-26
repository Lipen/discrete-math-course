// title diagrams: миниатюры-иконки титула и разделов --- множества, отношения,
// функции, порядки, графы, схемы, коды, счёт, автоматы, нечёткость,
// текстовые мотивы, исчисление, типы, счётность, узнаваемые герои.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Единый стиль миниатюр ──
// Один набор на все иконки: одинаковый радиус узлов, толщина штриха и цвета.
// Цвета берутся из токенов (заливка узла c-fl, штрих c-bd), но позволяют
// тему через (f, s): f --- заливка/акцент, s --- цвет штриха.
#let m-r = 0.05
#let m-st = 0.4pt

#let vtx(name, pos, f, s, r: m-r) = draw.circle(
  pos,
  radius: r,
  name: name,
  fill: f,
  stroke: m-st + s,
)

#let lnk(a, b, s, w: m-st) = draw.line(a, b, stroke: w + s)

#let links(body) = draw.on-layer(-1, body)

// ── Язык: множества, отношения, функции, порядок, графы ──

// Пересечение множеств
#let m-venn(f: c-fl, s: c-bd) = canvas({
  draw.circle((0.35, 0.5), radius: 0.35, stroke: m-st + s)
  draw.circle((0.75, 0.5), radius: 0.35, stroke: m-st + s)
})

// Булева матрица
#let m-matrix(f: c-fl, s: c-bd) = canvas({
  let xs = (0.3, 0.55, 0.85)
  let ys = (0.75, 0.5, 0.25)
  let on = ((0, 0), (0, 1), (1, 1), (2, 0), (2, 2))
  for (i, x) in xs.enumerate() {
    for (j, y) in ys.enumerate() {
      if on.contains((i, j)) {
        draw.circle((x, y), radius: m-r, fill: f, stroke: none)
      } else {
        draw.circle((x, y), radius: m-r, stroke: m-st + s)
      }
    }
  }
  for (bx, dir) in ((0.15, 1), (1, -1)) {
    draw.line(
      (bx + dir * 0.05, 0.9),
      (bx, 0.9),
      (bx, 0.1),
      (bx + dir * 0.05, 0.1),
      stroke: m-st + s,
    )
  }
})

// Функция как отображение
#let m-fn(f: c-fl, s: c-bd) = canvas({
  draw.circle((0.2, 0.5), radius: (0.15, 0.4), stroke: m-st + s)
  draw.circle((0.8, 0.5), radius: (0.15, 0.4), stroke: m-st + s)
  for (k, y) in (0.75, 0.5, 0.25).enumerate() {
    vtx("s" + str(k), (0.2, y), f, s)
  }
  for (k, y) in (0.65, 0.35).enumerate() {
    vtx("d" + str(k), (0.8, y), f, s)
  }
  for (a, b) in (("s0", "d0"), ("s1", "d0"), ("s2", "d1")) {
    draw.line(
      a + ".east",
      b + ".west",
      stroke: m-st + s,
      mark: (end: ">", scale: 0.3),
    )
  }
})

// Пентагон N5
#let m-poset(f: c-fl, s: c-bd) = canvas({
  vtx("bot", (0.5, 0.05), f, s)
  vtx("a", (0.15, 0.35), f, s)
  vtx("b", (0.15, 0.65), f, s)
  vtx("c", (0.9, 0.5), f, s)
  vtx("top", (0.5, 0.95), f, s)
  links({
    for (p, q) in (
      ("bot", "a"),
      ("a", "b"),
      ("b", "top"),
      ("bot", "c"),
      ("c", "top"),
    ) { lnk(p, q, s) }
  })
})

// Решётка-diamond
#let m-diamond(f: c-fl, s: c-bd) = canvas({
  vtx("bot", (0.5, 0.1), f, s)
  vtx("l", (0.1, 0.55), f, s)
  vtx("r", (0.9, 0.55), f, s)
  vtx("top", (0.5, 0.9), f, s)
  links({
    for (p, q) in (("bot", "l"), ("bot", "r"), ("l", "top"), ("r", "top")) {
      lnk(p, q, s)
    }
  })
})

// Бинарное дерево
#let m-tree(f: c-fl, s: c-bd) = canvas({
  vtx("root", (0.5, 0.85), f, s)
  vtx("l", (0.15, 0.5), f, s)
  vtx("r", (0.85, 0.5), f, s)
  for (k, x) in (0, 0.3, 0.7, 1.0).enumerate() {
    vtx("leaf" + str(k), (x, 0.15), f, s)
  }
  links({
    for (p, q) in (
      ("root", "l"),
      ("root", "r"),
      ("l", "leaf0"),
      ("l", "leaf1"),
      ("r", "leaf2"),
      ("r", "leaf3"),
    ) { lnk(p, q, s) }
  })
})

// Двудольный граф K(2,3)
#let m-bipartite(f: c-fl, s: c-bd) = canvas({
  let top = ("t0", "t1")
  let bot = ("b0", "b1", "b2")
  for (k, x) in (0.3, 0.7).enumerate() {
    vtx("t" + str(k), (x, 0.9), f, s)
  }
  for (k, x) in (0.1, 0.5, 0.9).enumerate() {
    vtx("b" + str(k), (x, 0.1), f, s)
  }
  links({
    for p in top { for q in bot { lnk(p, q, s) } }
  })
})

// Полный граф K4
#let m-k4(f: c-fl, s: c-bd) = canvas({
  for (k, pos) in (
    (0.1, 0.25),
    (0.9, 0.25),
    (0.1, 0.75),
    (0.9, 0.75),
  ).enumerate() {
    vtx("v" + str(k), pos, f, s)
  }
  links({
    for (a, b) in ((0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)) {
      lnk("v" + str(a), "v" + str(b), s)
    }
  })
})

// Цикл C5
#let m-c5(f: c-fl, s: c-bd) = canvas({
  let pts = ((0.5, 0.1), (0.9, 0.4), (0.75, 0.9), (0.25, 0.9), (0.1, 0.4))
  for (k, pos) in pts.enumerate() { vtx("v" + str(k), pos, f, s) }
  links({
    for k in range(5) {
      lnk("v" + str(k), "v" + str(calc.rem(k + 1, 5)), s)
    }
  })
})

// ── Алгебра и инженерия: булева алгебра, схемы, коды ──

// Булев куб B3
#let m-cube(f: c-fl, s: c-bd) = canvas({
  let front = ((0.05, 0.05), (0.6, 0.05), (0.6, 0.6), (0.05, 0.6))
  let back = ((0.35, 0.35), (0.9, 0.35), (0.9, 0.9), (0.35, 0.9))
  for (k, pos) in (front + back).enumerate() {
    vtx("v" + str(k), pos, f, s)
  }
  links({
    for (a, b) in (
      (0, 1),
      (1, 2),
      (2, 3),
      (3, 0),
      (4, 5),
      (5, 6),
      (6, 7),
      (7, 4),
      (0, 4),
      (1, 5),
      (2, 6),
      (3, 7),
    ) { lnk("v" + str(a), "v" + str(b), s) }
  })
})

// Логический вентиль
#let m-gate(f: c-fl, s: c-bd) = canvas({
  draw.line((0.15, 0.85), (0.5, 0.85), stroke: m-st + s)
  draw.line((0.15, 0.2), (0.5, 0.2), stroke: m-st + s)
  draw.line((0.15, 0.85), (0.15, 0.2), stroke: m-st + s)
  draw.arc(
    (0.5, 0.85),
    start: 90deg,
    delta: -180deg,
    radius: 0.35,
    stroke: m-st + s,
  )
  draw.line((0, 0.7), (0.15, 0.7), stroke: m-st + s)
  draw.line((0, 0.35), (0.15, 0.35), stroke: m-st + s)
  draw.line((0.85, 0.5), (1.0, 0.5), stroke: m-st + s)
})

// Код Хэмминга (7,4)
#let m-hamming(f: c-fl, s: c-bd) = canvas({
  let R = 0.3
  let d = 0.15
  let rp = 0.2
  let at(rad, ang) = (0.5 + rad * calc.cos(ang), 0.5 + rad * calc.sin(ang))
  for k in range(3) {
    draw.circle(at(d, 90deg + k * 120deg), radius: R, stroke: m-st + s)
  }
  draw.circle((0.5, 0.5), radius: m-r, fill: f, stroke: none)
  for k in range(3) {
    draw.circle(
      at(rp, 270deg + k * 120deg),
      radius: m-r,
      fill: f,
      stroke: none,
    )
  }
})

// ── Счёт и случайность: комбинаторика, вычеты ──

// Треугольник Паскаля
#let m-pascal(f: c-fl, s: c-bd) = canvas({
  for i in range(4) {
    let y = 0.9 - i * 0.25
    for j in range(i + 1) {
      draw.circle(
        (0.5 + (j - i / 2) * 0.25, y),
        radius: m-r,
        fill: f,
        stroke: none,
      )
    }
  }
})

// Арифметика по модулю
#let m-modclock(f: c-fl, s: c-bd) = canvas({
  let R = 0.4
  let at(rad, ang) = (0.5 + rad * calc.cos(ang), 0.5 + rad * calc.sin(ang))
  draw.circle((0.5, 0.5), radius: R, stroke: m-st + s)
  for k in range(6) {
    let a = 90deg - k * 60deg
    draw.line(at(0.85 * R, a), at(R, a), stroke: m-st + s)
  }
  draw.line((0.5, 0.5), at(0.6 * R, 30deg), stroke: m-st + s)
  draw.circle((0.5, 0.5), radius: m-r, fill: f, stroke: none)
})

// Перестановка
#let m-perm(f: c-fl, s: c-bd) = canvas({
  let xs = (0.1, 0.35, 0.65, 0.9)
  for (k, x) in xs.enumerate() {
    vtx("t" + str(k), (x, 0.85), f, s)
    vtx("b" + str(k), (x, 0.15), f, s)
  }
  links({
    for (a, b) in ((0, 2), (1, 0), (2, 3), (3, 1)) {
      lnk("t" + str(a), "b" + str(b), s)
    }
  })
})

// Диаграмма Юнга
#let m-ferrers(f: c-fl, s: c-bd) = canvas({
  let u = 0.25
  for (row, cnt) in ((0, 3), (1, 2), (2, 1)) {
    for j in range(cnt) {
      draw.rect(
        (0.1 + j * u, 0.85 - row * u),
        (0.1 + (j + 1) * u, 0.85 - (row + 1) * u),
        stroke: m-st + s,
      )
    }
  }
})

// ── Вычисление: автоматы, машины, нечёткость ──

// Конечный автомат
#let m-dfa(f: c-fl, s: c-bd) = canvas({
  let r = 0.1
  let hgap = 0.5
  let arrow = (end: ">", scale: 0.5, fill: s)
  draw.circle((0, 0), radius: r, name: "q0", stroke: m-st + s)
  draw.circle((hgap, 0), radius: r, name: "q1", stroke: m-st + s)
  draw.circle((hgap * 2, 0), radius: r + 0.05, name: "q2", stroke: m-st + s)
  draw.circle(
    "q2",
    radius: r,
    fill: f.transparentize(80%),
    stroke: m-st + s,
  )
  draw.line((-0.4, 0), "q0.west", stroke: m-st + s, mark: arrow)
  draw.line("q0.east", "q1.west", stroke: m-st + s, mark: arrow)
  draw.line("q1.east", "q2.west", stroke: m-st + s, mark: arrow)
  draw.bezier(
    "q2.south",
    "q0.south",
    (2 * hgap - 0.1, -0.6),
    (0.1, -0.6),
    stroke: m-st + s,
    mark: arrow,
  )
})

// Лента машины Тьюринга
#let m-tape(f: c-fl, s: c-bd) = canvas({
  let u = 0.2
  for k in range(5) {
    draw.rect(
      (k * u, 0.5),
      ((k + 1) * u, 0.8),
      stroke: m-st + s,
    )
  }
  draw.rect(
    (2 * u, 0.5),
    (3 * u, 0.8),
    fill: f.transparentize(60%),
    stroke: m-st + s,
  )
  let hx = 2.5 * u
  draw.line(
    (hx, 0.2),
    (hx, 0.5),
    stroke: m-st + s,
    mark: (end: ">", fill: s, scale: 0.5),
  )
})

// Функция принадлежности нечёткого множества
#let m-fuzzy(f: c-fl, s: c-bd) = canvas({
  draw.line((0, 0.15), (1, 0.15), stroke: m-st + s.transparentize(45%))
  draw.line((0.05, 0.15), (0.05, 0.9), stroke: m-st + s.transparentize(45%))
  draw.line(
    (0.05, 0.15),
    (0.35, 0.8),
    (0.65, 0.8),
    (0.95, 0.15),
    fill: f.transparentize(93%),
    stroke: m-st + s,
    close: true,
  )
})

// ── Текстовые мотивы ──

#let m-union(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$A union B$]
#let m-quant(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$forall exists$]
#let m-imply(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$p imply q$]
#let m-subset(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$A subset.eq B$]
#let m-bits(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$0 1 1 0$]
#let m-compose(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$g compose f$]
#let m-logic(f: c-ink, s: c-bd) = text(fill: f, size: s-cap)[$and or not$]
#let m-binom(f: c-ink, s: c-bd) = text(fill: f, size: s-node)[$binom(n, k)$]
// Комбинатор неподвижной точки
#let m-combinator(f: c-ink, s: c-bd) = text(fill: f, size: s-tiny)[$Y f = f (Y f)$]

// ── Исчисление, типы, бесконечность ──

// Лямбда-глиф
#let m-lambda(f: c-ink, s: c-bd) = text(fill: f, size: s-node + 3pt, font: "Libertinus Serif")[#sym.lambda]

// Типовое суждение
#let m-judgement(f: c-ink, s: c-bd) = text(fill: f, size: s-tiny)[$Gamma tack e : tau$]

// Сумма
#let m-sum(f: c-ink, s: c-bd) = text(fill: f, size: s-node + 3pt, font: "Libertinus Serif")[#sym.sum]

// Алеф
#let m-aleph(f: c-ink, s: c-bd) = text(fill: f, size: s-node + 3pt, font: "Libertinus Serif")[#sym.aleph]

// ── Счётность: канторовская диагональ, зигзаг-перечисление ──

// Диагональ Кантора
#let m-diag(f: c-fl, s: c-bd) = canvas({
  let n = 3
  for i in range(n) {
    for j in range(n) {
      let name = "g" + str(i) + str(j)
      draw.circle(
        (0.1 + j * 0.3, 0.1 + i * 0.3),
        radius: m-r,
        stroke: m-st + s,
        fill: none,
        name: name,
      )
    }
  }
  draw.line("g00", "g22", stroke: m-st + f)
  draw.circle("g11", radius: m-r, fill: f, stroke: none)
})

// Зигзаг-перечисление
#let m-pairing(f: c-fl, s: c-bd) = canvas({
  let n = 3
  for i in range(n) {
    for j in range(n) {
      let name = "g" + str(i) + str(j)
      draw.circle(
        (0.1 + j * 0.3, 0.1 + i * 0.3),
        radius: m-r,
        stroke: m-st + s,
        fill: none,
        name: name,
      )
    }
  }
  let ord = ("g00", "g01", "g02", "g12", "g11", "g10", "g20", "g21", "g22")
  for k in range(ord.len() - 1) {
    draw.line(ord.at(k), ord.at(k + 1), stroke: m-st + f)
  }
})

// ── Узнаваемые «герои» книги ──

// Граф Петерсена
#let m-petersen(f: c-fl, s: c-bd) = canvas({
  let at(radius, ang) = (0.5 + radius * calc.cos(ang), 0.5 + radius * calc.sin(ang))
  for k in range(5) {
    vtx("O" + str(k), at(0.4, 90deg + k * 72deg), f, s)
    vtx("I" + str(k), at(0.2, 90deg + k * 72deg + 36deg), f, s)
  }
  links({
    for k in range(5) {
      lnk("O" + str(k), "O" + str(calc.rem(k + 1, 5)), s)
      lnk("I" + str(k), "I" + str(calc.rem(k + 2, 5)), s)
      lnk("O" + str(k), "I" + str(k), s)
    }
  })
})

// Дерево вывода грамматики
#let m-derive(f: c-fl, s: c-bd) = canvas({
  vtx("s", (0.5, 0.8), f, s)
  vtx("np", (0.25, 0.5), f, s)
  vtx("vp", (0.75, 0.5), f, s)
  for (name, x) in (("Det", 0.15), ("N", 0.4), ("V", 0.75)) {
    draw.rect(
      (x - 0.1, 0.05),
      (x + 0.1, 0.25),
      name: name,
      stroke: m-st + s.transparentize(20%),
    )
  }
  links({
    lnk("s", "np", s)
    lnk("s", "vp", s)
    lnk("np", "Det", s)
    lnk("np", "N", s)
    lnk("vp", "V", s)
  })
})

// Kripke-фрейм
#let m-kripke(f: c-fl, s: c-bd) = canvas({
  vtx("w0", (0.2, 0.2), f, s)
  vtx("w1", (0.8, 0.2), f, s)
  vtx("w2", (0.5, 0.75), f, s)
  draw.arc((0.2, 0.2), radius: m-r, start: 20deg, delta: 320deg, stroke: m-st + s)
  draw.arc((0.8, 0.2), radius: m-r, start: 160deg, delta: 320deg, stroke: m-st + s)
  draw.arc((0.5, 0.75), radius: m-r, start: 90deg, delta: 320deg, stroke: m-st + s)
  draw.line("w2.south-west", "w0.north-east", stroke: m-st + s, mark: (end: ">", scale: 0.25))
  draw.line("w2.south-east", "w1.north-west", stroke: m-st + s, mark: (end: ">", scale: 0.25))
})

// Истинность
#let m-truth(f: c-fl, s: c-bd) = canvas({
  let xs = (0.1, 0.3, 0.5, 0.7)
  let rows = (0.55, 0.3, 0.1)
  for (k, x) in xs.enumerate() {
    draw.rect((x, rows.at(0)), (x + 0.15, rows.at(0) + 0.15), stroke: m-st + s.transparentize(30%))
  }
  for (ri, ry) in rows.enumerate() {
    for (k, x) in xs.enumerate() {
      let fill = none
      if ri == 1 { fill = f.transparentize(65%) }
      draw.rect((x, ry), (x + 0.15, ry + 0.15), stroke: m-st + s, fill: fill)
    }
  }
})

// XOR-вентиль
#let m-adder(f: c-fl, s: c-bd) = canvas({
  let yt = 0.8
  let yb = 0.2
  let yc = 0.5
  draw.line((0, yt), (0.1, yt), stroke: m-st + s)
  draw.line((0, yb), (0.1, yb), stroke: m-st + s)
  draw.arc((0.1, yc), start: 90deg, delta: -180deg, radius: 0.3, stroke: m-st + s)
  draw.arc((0.15, yc), start: 90deg, delta: -180deg, radius: 0.3, stroke: m-st + s)
  draw.line((0.15, yt), (0.7, yc), stroke: m-st + s)
  draw.line((0.15, yb), (0.7, yc), stroke: m-st + s)
  draw.line((0.7, yc), (0.85, yc), stroke: m-st + s)
})

// Дерево применения
#let m-app(f: c-fl, s: c-bd) = canvas({
  vtx("ap", (0.5, 0.85), f, s)
  vtx("lam", (0.15, 0.5), f, s)
  vtx("var", (0.85, 0.5), f, s)
  vtx("body", (0.15, 0.1), f, s)
  links({
    lnk("ap", "lam", s)
    lnk("ap", "var", s)
    lnk("lam", "body", s)
  })
})

// Три пересекающихся множества
#let m-3venn(f: c-fl, s: c-bd) = canvas({
  draw.circle((0.35, 0.6), radius: 0.35, stroke: m-st + s)
  draw.circle((0.65, 0.6), radius: 0.35, stroke: m-st + s)
  draw.circle((0.5, 0.35), radius: 0.35, stroke: m-st + s)
})
