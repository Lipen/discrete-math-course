// Диаграммы Хассе: порядок по делимости, цепь, булеаны, решётка знаков.
#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes
#import "style.typ": *

// Ось y у fletcher направлена вниз: наибольший элемент получает y = 0,
// наименьший --- максимальный y. Рёбра Хассе идут вверх без стрелок.
#let hn(pos, body, tone: cool, fill: none, ..args) = node(
  pos,
  text(fill: ink)[#body],
  fill: if fill == none { tone.lighten(82%) } else { fill },
  stroke: 1.1pt + tone,
  ..args,
)
#let he(from, to) = edge(from, to, "-", stroke: edge-plain)

// общие параметры вершин: эллипс плотно вокруг имени
#let node-opts = (
  node-shape: shapes.ellipse,
  node-inset: 2.5pt,
  node-outset: 0pt,
)

// ── Делимость на {1, 2, 3, 4, 6, 12} ──
#let hasse-divisors-12 = diagram(
  ..node-opts,
  spacing: 1em,
  hn((0, 3), $1$, name: <d1>),
  hn((-1, 2), $2$, name: <d2>),
  hn((1, 2), $3$, name: <d3>),
  hn((-1, 1), $4$, name: <d4>),
  hn((1, 1), $6$, name: <d6>),
  // само число --- акцент
  hn((0, 0), $12$, tone: warm, fill: warm.lighten(82%), name: <d12>),
  he(<d1>, <d2>),
  he(<d1>, <d3>),
  he(<d2>, <d4>),
  he(<d2>, <d6>),
  he(<d3>, <d6>),
  he(<d4>, <d12>),
  he(<d6>, <d12>),
)

// ── Цепь {1 < 2 < 3} ──
#let hasse-chain-3 = diagram(
  ..node-opts,
  spacing: 1em,
  hn((0, 2), $1$, name: <c1>),
  hn((0, 1), $2$, name: <c2>),
  hn((0, 0), $3$, name: <c3>),
  edge(<c1>, <c2>, "-", stroke: edge-cool),
  edge(<c2>, <c3>, "-", stroke: edge-cool),
)

// ── Булеан {1, 2} по включению (квадрат B₂) ──
#let hasse-powerset-2 = diagram(
  ..node-opts,
  spacing: 1em,
  hn((0, 2), $emptyset$, name: <p0>),
  hn((-1, 1), ${1}$, name: <p1>),
  hn((1, 1), ${2}$, name: <p2>),
  hn((0, 0), ${1,2}$, name: <p12>),
  he(<p0>, <p1>),
  he(<p0>, <p2>),
  he(<p1>, <p12>),
  he(<p2>, <p12>),
)

// ── Решётка знаков ──
#let sign-lattice = diagram(
  ..node-opts,
  spacing: 0.9em,
  // дно точности --- акцент
  hn((0, 2), $bot$, tone: green, fill: green.lighten(82%), name: <bot>),
  hn((-1, 1), $-$, name: <neg>),
  hn((0, 1), $0$, name: <zero>),
  hn((1, 1), $+$, name: <pos>),
  hn((0, 0), $top$, name: <top>),
  he(<bot>, <neg>),
  he(<bot>, <zero>),
  he(<bot>, <pos>),
  he(<neg>, <top>),
  he(<zero>, <top>),
  he(<pos>, <top>),
)

// ── Булеан {1, 2, 3} по включению (куб B₃) ──
#let hasse-powerset-3 = diagram(
  ..node-opts,
  spacing: 0.9em,
  hn((0, 0), ${1,2,3}$, name: <p123>),
  hn((-1.8, 1), ${1,2}$, name: <p12>),
  hn((0, 1), ${1,3}$, name: <p13>),
  hn((1.8, 1), ${2,3}$, name: <p23>),
  hn((-1.8, 2), ${1}$, name: <p1>),
  hn((0, 2), ${2}$, name: <p2>),
  hn((1.8, 2), ${3}$, name: <p3>),
  hn((0, 3), $emptyset$, name: <p0>),
  // покрывающие рёбра: добавление одного элемента
  he(<p0>, <p1>),
  he(<p0>, <p2>),
  he(<p0>, <p3>),
  he(<p1>, <p12>),
  he(<p1>, <p13>),
  he(<p2>, <p12>),
  he(<p2>, <p23>),
  he(<p3>, <p13>),
  he(<p3>, <p23>),
  he(<p12>, <p123>),
  he(<p13>, <p123>),
  he(<p23>, <p123>),
)
