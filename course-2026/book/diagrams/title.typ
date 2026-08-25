// Микро-тайлы для титульной страницы: каждая функция рисует один мотив.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let ink-muted = oklch(46%, 0.05, 70deg)

// ── Общие helper'ы узловых мотивов ──

// Вершина под именем name в точке pos; f -- заливка, s -- обводка, r -- радиус.
// Рёбра ссылаются на имя, а направленные -- на якорь ("q0.east").
#let vtx(name, pos, f, s, r: 0.05) = draw.circle(
  pos,
  radius: r,
  name: name,
  fill: f,
  stroke: 0.3pt + s,
)

#let lnk(a, b, s, w: 0.4pt) = draw.line(a, b, stroke: w + s)

// Рёбра уходят под вершины, чтобы кружки перекрывали их концы.
#let links(body) = draw.on-layer(-1, body)

// ── Мини-мотивы ──
// Каждый мотив -- функция (f, s): f -- цвет заливки/акцента, s -- цвет обводки.
// Холст мотива: квадрат [0,1]x[0,1].

// ── Язык: множества, отношения, функции, порядок, графы ──

// Пересечение множеств
#let m-venn(f, s) = canvas({
  draw.circle((0.35, 0.5), radius: 0.35, stroke: 0.5pt + s)
  draw.circle((0.75, 0.5), radius: 0.35, stroke: 0.5pt + s)
})

// Булева матрица отношения 3x3 со скобками
#let m-matrix(f, s) = canvas({
  let xs = (0.3, 0.55, 0.85)
  let ys = (0.75, 0.5, 0.25)
  let on = ((0, 0), (0, 1), (1, 1), (2, 0), (2, 2))
  for (i, x) in xs.enumerate() {
    for (j, y) in ys.enumerate() {
      if on.contains((i, j)) {
        draw.circle((x, y), radius: 0.05, fill: f, stroke: none)
      } else {
        draw.circle((x, y), radius: 0.05, stroke: 0.3pt + s)
      }
    }
  }
  for (bx, dir) in ((0.15, 1), (1, -1)) {
    draw.line(
      (bx + dir * 0.05, 0.9),
      (bx, 0.9),
      (bx, 0.1),
      (bx + dir * 0.05, 0.1),
      stroke: 0.45pt + s,
    )
  }
})

// Функция как отображение между двумя множествами
#let m-fn(f, s) = canvas({
  draw.circle((0.2, 0.5), radius: (0.15, 0.4), stroke: 0.4pt + s)
  draw.circle((0.8, 0.5), radius: (0.15, 0.4), stroke: 0.4pt + s)
  for (k, y) in (0.75, 0.5, 0.25).enumerate() {
    vtx("s" + str(k), (0.2, y), f, s, r: 0.05)
  }
  for (k, y) in (0.65, 0.35).enumerate() {
    vtx("d" + str(k), (0.8, y), f, s, r: 0.05)
  }
  for (a, b) in (("s0", "d0"), ("s1", "d0"), ("s2", "d1")) {
    draw.line(
      a + ".east",
      b + ".west",
      stroke: 0.35pt + s,
      mark: (end: ">", scale: 0.3),
    )
  }
})

// Пентагон N5, недистрибутивная решётка
#let m-poset(f, s) = canvas({
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

// Решётка-diamond (join и meet)
#let m-diamond(f, s) = canvas({
  vtx("bot", (0.5, 0.1), f, s, r: 0.05)
  vtx("l", (0.1, 0.55), f, s, r: 0.05)
  vtx("r", (0.9, 0.55), f, s, r: 0.05)
  vtx("top", (0.5, 0.9), f, s, r: 0.05)
  links({
    for (p, q) in (("bot", "l"), ("bot", "r"), ("l", "top"), ("r", "top")) {
      lnk(p, q, s)
    }
  })
})

// Бинарное дерево
#let m-tree(f, s) = canvas({
  vtx("root", (0.5, 0.85), f, s, r: 0.05)
  vtx("l", (0.15, 0.5), f, s, r: 0.05)
  vtx("r", (0.85, 0.5), f, s, r: 0.05)
  for (k, x) in (0, 0.3, 0.7, 1.0).enumerate() {
    vtx("leaf" + str(k), (x, 0.15), f, s, r: 0.05)
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
#let m-bipartite(f, s) = canvas({
  let top = ("t0", "t1")
  let bot = ("b0", "b1", "b2")
  for (k, x) in (0.3, 0.7).enumerate() {
    vtx("t" + str(k), (x, 0.9), f, s, r: 0.05)
  }
  for (k, x) in (0.1, 0.5, 0.9).enumerate() {
    vtx("b" + str(k), (x, 0.1), f, s, r: 0.05)
  }
  links({
    for p in top { for q in bot { lnk(p, q, s, w: 0.3pt) } }
  })
})

// Полный граф K4
#let m-k4(f, s) = canvas({
  for (k, pos) in (
    (0.1, 0.25),
    (0.9, 0.25),
    (0.1, 0.75),
    (0.9, 0.75),
  ).enumerate() {
    vtx("v" + str(k), pos, f, s, r: 0.05)
  }
  links({
    for (a, b) in ((0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)) {
      lnk("v" + str(a), "v" + str(b), s)
    }
  })
})

// Цикл C5
#let m-c5(f, s) = canvas({
  let pts = ((0.5, 0.1), (0.9, 0.4), (0.75, 0.9), (0.25, 0.9), (0.1, 0.4))
  for (k, pos) in pts.enumerate() { vtx("v" + str(k), pos, f, s, r: 0.05) }
  links({
    for k in range(5) {
      lnk("v" + str(k), "v" + str(calc.rem(k + 1, 5)), s)
    }
  })
})

// ── Алгебра и инженерия: булева алгебра, схемы, коды ──

// Булев куб B3: две грани со смещением по диагонали
#let m-cube(f, s) = canvas({
  let front = ((0.05, 0.05), (0.6, 0.05), (0.6, 0.6), (0.05, 0.6))
  let back = ((0.35, 0.35), (0.9, 0.35), (0.9, 0.9), (0.35, 0.9))
  for (k, pos) in (front + back).enumerate() {
    vtx("v" + str(k), pos, f, s, r: 0.05)
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
    ) { lnk("v" + str(a), "v" + str(b), s, w: 0.3pt) }
  })
})

// Логический вентиль: два входа, щит, выход
#let m-gate(f, s) = canvas({
  draw.line((0.15, 0.85), (0.5, 0.85), stroke: 0.45pt + s)
  draw.line((0.15, 0.2), (0.5, 0.2), stroke: 0.45pt + s)
  draw.line((0.15, 0.85), (0.15, 0.2), stroke: 0.45pt + s)
  draw.arc(
    (0.5, 0.85),
    start: 90deg,
    delta: -180deg,
    radius: 0.35,
    stroke: 0.45pt + s,
  )
  draw.line((0, 0.7), (0.15, 0.7), stroke: 0.4pt + s)
  draw.line((0, 0.35), (0.15, 0.35), stroke: 0.4pt + s)
  draw.line((0.85, 0.5), (1.0, 0.5), stroke: 0.4pt + s)
})

// Код Хэмминга (7,4): три круга чётности, информационные биты в пересечениях.
// at -- точка полярных координат от центра холста.
#let m-hamming(f, s) = canvas({
  let R = 0.3 // радиус круга чётности
  let d = 0.15 // расстояние центра круга до центра холста
  let rp = 0.2 // расстояние парного бита до центра холста
  let at(rad, ang) = (0.5 + rad * calc.cos(ang), 0.5 + rad * calc.sin(ang))
  for k in range(3) {
    draw.circle(at(d, 90deg + k * 120deg), radius: R, stroke: 0.4pt + s)
  }
  // Четыре информационных бита: тройное пересечение плюс три парных.
  draw.circle((0.5, 0.5), radius: 0.05, fill: f, stroke: none)
  for k in range(3) {
    draw.circle(
      at(rp, 270deg + k * 120deg),
      radius: 0.05,
      fill: f,
      stroke: none,
    )
  }
})

// ── Счёт и случайность: комбинаторика, вычеты ──

// Треугольник Паскаля
#let m-pascal(f, s) = canvas({
  for i in range(4) {
    let y = 0.9 - i * 0.25
    for j in range(i + 1) {
      draw.circle(
        (0.5 + (j - i / 2) * 0.25, y),
        radius: 0.05,
        fill: f,
        stroke: none,
      )
    }
  }
})

// Арифметика по модулю: циферблат Z6
#let m-modclock(f, s) = canvas({
  let R = 0.4
  let at(rad, ang) = (0.5 + rad * calc.cos(ang), 0.5 + rad * calc.sin(ang))
  draw.circle((0.5, 0.5), radius: R, stroke: 0.45pt + s)
  for k in range(6) {
    let a = 90deg - k * 60deg
    draw.line(at(0.85 * R, a), at(R, a), stroke: 0.35pt + s)
  }
  draw.line((0.5, 0.5), at(0.6 * R, 30deg), stroke: 0.5pt + s)
  draw.circle((0.5, 0.5), radius: 0.05, fill: f, stroke: none)
})

// Перестановка: два ряда с пересечениями
#let m-perm(f, s) = canvas({
  let xs = (0.1, 0.35, 0.65, 0.9)
  for (k, x) in xs.enumerate() {
    vtx("t" + str(k), (x, 0.85), f, s, r: 0.05)
    vtx("b" + str(k), (x, 0.15), f, s, r: 0.05)
  }
  links({
    for (a, b) in ((0, 2), (1, 0), (2, 3), (3, 1)) {
      lnk("t" + str(a), "b" + str(b), s, w: 0.35pt)
    }
  })
})

// Диаграмма Юнга: разбиение 3+2+1
#let m-ferrers(f, s) = canvas({
  let u = 0.25
  for (row, cnt) in ((0, 3), (1, 2), (2, 1)) {
    for j in range(cnt) {
      draw.rect(
        (0.1 + j * u, 0.85 - row * u),
        (0.1 + (j + 1) * u, 0.85 - (row + 1) * u),
        stroke: 0.4pt + s,
      )
    }
  }
})

// ── Вычисление: автоматы, машины, нечёткость ──

// Конечный автомат: три состояния в ряд плюс возвратная дуга снизу
#let m-dfa(f, s) = canvas({
  let r = 0.1
  let hgap = 0.5
  let arrow = (end: ">", scale: 0.5, fill: s)
  draw.circle(
    (0, 0),
    radius: r,
    name: "q0",
    stroke: 0.5pt + s,
  )
  draw.circle(
    (hgap, 0),
    radius: r,
    name: "q1",
    stroke: 0.5pt + s,
  )
  draw.circle(
    (hgap * 2, 0),
    radius: r + 0.05,
    name: "q2",
    stroke: 0.5pt + s,
  )
  draw.circle(
    "q2",
    radius: r,
    fill: f.transparentize(80%),
    stroke: 0.5pt + s,
  )
  draw.line(
    (-0.4, 0),
    "q0.west",
    stroke: 0.45pt + s,
    mark: arrow,
  )
  draw.line(
    "q0.east",
    "q1.west",
    stroke: 0.45pt + s,
    mark: arrow,
  )
  draw.line(
    "q1.east",
    "q2.west",
    stroke: 0.45pt + s,
    mark: arrow,
  )
  // Возвратная дуга: из принимающего состояния обратно в начальное
  draw.bezier(
    "q2.south",
    "q0.south",
    (2 * hgap - 0.1, -0.6),
    (0.1, -0.6),
    stroke: 0.5pt + s,
    mark: arrow,
  )
})

// Лента машины Тьюринга с головкой
#let m-tape(f, s) = canvas({
  let u = 0.2
  for k in range(5) {
    draw.rect(
      (k * u, 0.5),
      ((k + 1) * u, 0.8),
      stroke: 0.35pt + s,
    )
  }
  draw.rect(
    (2 * u, 0.5),
    (3 * u, 0.8),
    fill: f.transparentize(60%),
    stroke: 0.35pt + s,
  )
  let hx = 2.5 * u
  draw.line(
    (hx, 0.2),
    (hx, 0.5),
    stroke: 0.8pt + s,
    mark: (end: ">", fill: s, scale: 0.5),
  )
})

// Функция принадлежности нечёткого множества
#let m-fuzzy(f, s) = canvas({
  draw.line((0, 0.15), (1, 0.15), stroke: 0.3pt + s.transparentize(45%))
  draw.line((0.05, 0.15), (0.05, 0.9), stroke: 0.3pt + s.transparentize(45%))
  draw.line(
    (0.05, 0.15),
    (0.35, 0.8),
    (0.65, 0.8),
    (0.95, 0.15),
    fill: f.transparentize(93%),
    stroke: 0.45pt + s,
    close: true,
  )
})

// ── Текстовые мотивы ──
#let msize = 10pt
#let m-union(f, s) = text(fill: f, size: msize)[$A union B$]
#let m-quant(f, s) = text(fill: f, size: msize)[$forall exists$]
#let m-imply(f, s) = text(fill: f, size: msize)[$p imply q$]
#let m-subset(f, s) = text(fill: f, size: msize)[$A subset.eq B$]
#let m-bits(f, s) = text(fill: f, size: msize)[$0 1 1 0$]
#let m-compose(f, s) = text(fill: f, size: msize)[$g compose f$]
#let m-logic(f, s) = text(fill: f, size: msize + 2.5pt)[$and or not$]
#let m-binom(f, s) = text(fill: f, size: msize + 3pt)[$binom(n, k)$]
// Комбинатор неподвижной точки: Y f = f (Y f)
#let m-combinator(f, s) = text(fill: f, size: msize - 1.5pt)[$Y f = f (Y f)$]

// ── Новые мотивы: исчисление, типы, бесконечность, счётность ──

// Лямбда-глиф (исчисление)
#let m-lambda(f, s) = text(fill: f, size: 15pt, font: "Libertinus Serif")[#sym.lambda]

// Типовое суждение Γ ⊢ e : τ
#let m-judgement(f, s) = text(fill: f, size: 9pt)[$Gamma tack e : tau$]

// Сумма / производящая функция: Σ
#let m-sum(f, s) = text(fill: f, size: 15pt, font: "Libertinus Serif")[#sym.sum]

// Алеф: мощность/кардинальность
#let m-aleph(f, s) = text(fill: f, size: 15pt, font: "Libertinus Serif")[#sym.aleph]

// Диагональ Кантора: сетка точечных нод + главная диагональ по нодам.
#let m-diag(f, s) = canvas({
  let n = 3
  for i in range(n) {
    for j in range(n) {
      let name = "g" + str(i) + str(j)
      draw.circle((0.1 + j * 0.3, 0.1 + i * 0.3), radius: 0.05, stroke: 0.3pt + s, fill: none, name: name)
    }
  }
  draw.line("g00", "g22", stroke: 0.4pt + f)
  draw.circle("g11", radius: 0.05, fill: f, stroke: none)
})

// Зигзаг-перечисление (счётность): обход сетки «змейкой» по нодам.
#let m-pairing(f, s) = canvas({
  let n = 3
  for i in range(n) {
    for j in range(n) {
      let name = "g" + str(i) + str(j)
      draw.circle((0.1 + j * 0.3, 0.1 + i * 0.3), radius: 0.05, stroke: 0.25pt + s, fill: none, name: name)
    }
  }
  let ord = ("g00", "g01", "g02", "g12", "g11", "g10", "g20", "g21", "g22")
  for k in range(ord.len() - 1) {
    draw.line(ord.at(k), ord.at(k + 1), stroke: 0.3pt + f)
  }
})

// ── Узнаваемые «герои» книги: отличительные диаграммы ──

// Граф Петерсена: внешний пятиугольник + внутренняя звезда + спицы.
#let m-petersen(f, s) = canvas({
  let at(radius, ang) = (0.5 + radius * calc.cos(ang), 0.5 + radius * calc.sin(ang))
  for k in range(5) {
    vtx("O" + str(k), at(0.4, 90deg + k * 72deg), f, s, r: 0.05)
    vtx("I" + str(k), at(0.2, 90deg + k * 72deg + 36deg), f, s, r: 0.05)
  }
  links({
    for k in range(5) {
      lnk("O" + str(k), "O" + str(calc.rem(k + 1, 5)), s, w: 0.25pt)
      lnk("I" + str(k), "I" + str(calc.rem(k + 2, 5)), s, w: 0.25pt)
      lnk("O" + str(k), "I" + str(k), s, w: 0.3pt)
    }
  })
})

// Дерево вывода грамматики: S → NP, VP; NP → Det, N; VP → V (несбалансированное).
#let m-derive(f, s) = canvas({
  vtx("s", (0.5, 0.8), f, s, r: 0.05)
  vtx("np", (0.25, 0.5), f, s, r: 0.05)
  vtx("vp", (0.75, 0.5), f, s, r: 0.05)
  // Терминалы: Det, N под NP; V под VP. Левый бок тяжелее --- дерево небалансно.
  for (name, x) in (("Det", 0.15), ("N", 0.4), ("V", 0.75)) {
    draw.rect((x - 0.1, 0.05), (x + 0.1, 0.25), name: name, stroke: 0.25pt + s.transparentize(20%))
  }
  links({
    lnk("s", "np", s)
    lnk("s", "vp", s)
    lnk("np", "Det", s, w: 0.3pt)
    lnk("np", "N", s, w: 0.3pt)
    lnk("vp", "V", s, w: 0.3pt)
  })
})

// Kripke-фрейм (интуиционизм): миры с рефлексивными петельками, доступность.
#let m-kripke(f, s) = canvas({
  vtx("w0", (0.2, 0.2), f, s, r: 0.05)
  vtx("w1", (0.8, 0.2), f, s, r: 0.05)
  vtx("w2", (0.5, 0.75), f, s, r: 0.05)
  draw.arc((0.2, 0.2), radius: 0.05, start: 20deg, delta: 320deg, stroke: 0.25pt + s)
  draw.arc((0.8, 0.2), radius: 0.05, start: 160deg, delta: 320deg, stroke: 0.25pt + s)
  draw.arc((0.5, 0.75), radius: 0.05, start: 90deg, delta: 320deg, stroke: 0.25pt + s)
  draw.line("w2.south-west", "w0.north-east", stroke: 0.25pt + s, mark: (end: ">", scale: 0.25))
  draw.line("w2.south-east", "w1.north-west", stroke: 0.25pt + s, mark: (end: ">", scale: 0.25))
})

// Истинность (SAT/логика): таблица с подсвеченной выполняющей строкой.
#let m-truth(f, s) = canvas({
  let xs = (0.1, 0.3, 0.5, 0.7)
  let rows = (0.55, 0.3, 0.1)
  for (k, x) in xs.enumerate() {
    draw.rect((x, rows.at(0)), (x + 0.15, rows.at(0) + 0.15), stroke: 0.25pt + s.transparentize(30%))
  }
  for (ri, ry) in rows.enumerate() {
    for (k, x) in xs.enumerate() {
      let fill = none
      if ri == 1 { fill = f.transparentize(65%) }
      draw.rect((x, ry), (x + 0.15, ry + 0.15), stroke: 0.25pt + s, fill: fill)
    }
  }
})

// XOR-вентиль (сумма полусумматора): двойная входная кривая + щит, всё в [0,1].
#let m-adder(f, s) = canvas({
  let yt = 0.8
  let yb = 0.2
  let yc = 0.5
  draw.line((0, yt), (0.1, yt), stroke: 0.3pt + s) // a
  draw.line((0, yb), (0.1, yb), stroke: 0.3pt + s) // b
  // двойная входная кривая XOR (внешняя + внутренняя дуги)
  draw.arc((0.1, yc), start: 90deg, delta: -180deg, radius: 0.3, stroke: 0.2pt + s)
  draw.arc((0.15, yc), start: 90deg, delta: -180deg, radius: 0.3, stroke: 0.35pt + s)
  // крылья щита к точке выхода
  draw.line((0.15, yt), (0.7, yc), stroke: 0.3pt + s)
  draw.line((0.15, yb), (0.7, yc), stroke: 0.3pt + s)
  draw.line((0.7, yc), (0.85, yc), stroke: 0.3pt + s) // выход sum
})

// Дерево применения λ-терма: @ → (λx, переменная); λx → тело.
#let m-app(f, s) = canvas({
  vtx("ap", (0.5, 0.85), f, s, r: 0.05)
  vtx("lam", (0.15, 0.5), f, s, r: 0.05)
  vtx("var", (0.85, 0.5), f, s, r: 0.05)
  vtx("body", (0.15, 0.1), f, s, r: 0.05)
  links({
    lnk("ap", "lam", s)
    lnk("ap", "var", s)
    lnk("lam", "body", s)
  })
})

// Три пересекающихся множества (3-мерный Венн).
#let m-3venn(f, s) = canvas({
  draw.circle((0.35, 0.6), radius: 0.35, stroke: 0.4pt + s)
  draw.circle((0.65, 0.6), radius: 0.35, stroke: 0.4pt + s)
  draw.circle((0.5, 0.35), radius: 0.35, stroke: 0.4pt + s)
})
