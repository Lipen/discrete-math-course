// Диаграммы Хассе: порядок по делимости, цепь, булеаны, решётка знаков.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

// Ось y у fletcher направлена вниз: наибольший элемент получает y = 0,
// наименьший --- максимальный y. Рёбра Хассе идут вверх без стрелок.
#let hn(pos, body, tone: cool, fill: none, size: 0.9em, label: 0.8em, ..args) = node(
  pos,
  text(size: label, fill: ink)[#body],
  fill: if fill == none { tone.lighten(82%) } else { fill },
  stroke: 1.1pt + tone,
  width: size,
  height: size,
  ..args,
)
#let he(from, to) = edge(from, to, "-", stroke: edge-plain)

// общие параметры вершин: круг одного размера, как в книге
#let node-opts = (
  node-shape: "circle",
  node-inset: 0pt,
  node-outset: 0pt,
)

// ── Делимость на {1, 2, 3, 4, 6, 12} ──
#let hasse-divisors-12 = diagram(
  ..node-opts,
  spacing: 1.25em,
  hn((0, 3), $1$, name: <d1>),
  hn((-1, 2), $2$, name: <d2>),
  hn((1, 2), $3$, name: <d3>),
  hn((-1, 1), $4$, name: <d4>),
  hn((1, 1), $6$, name: <d6>),
  hn((0, 0), $12$, name: <d12>),
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
  spacing: 1.05em,
  hn((0, 2), $1$, name: <c1>),
  hn((0, 1), $2$, name: <c2>),
  hn((0, 0), $3$, name: <c3>),
  edge(<c1>, <c2>, "-", stroke: edge-cool),
  edge(<c2>, <c3>, "-", stroke: edge-cool),
)

// ── Булеан {1, 2} по включению (квадрат B₂) ──
#let hasse-powerset-2 = diagram(
  ..node-opts,
  spacing: 1.45em,
  hn((0, 2), $emptyset$, size: 1.2em, name: <p0>),
  hn((-1, 1), ${1}$, size: 1.2em, name: <p1>),
  hn((1, 1), ${2}$, size: 1.2em, name: <p2>),
  hn((0, 0), ${1,2}$, size: 1.2em, name: <p12>),
  he(<p0>, <p1>),
  he(<p0>, <p2>),
  he(<p1>, <p12>),
  he(<p2>, <p12>),
)

// ── Ромб M₃: попарно несравнимая середина ──
#let lattice-m3 = diagram(
  ..node-opts,
  spacing: 1.25em,
  hn((0, 2), $bot$, name: <m3-bot>),
  hn((-1, 1), $a$, name: <m3-a>),
  hn((0, 1), $b$, name: <m3-b>),
  hn((1, 1), $c$, name: <m3-c>),
  hn((0, 0), $top$, name: <m3-top>),
  he(<m3-bot>, <m3-a>),
  he(<m3-bot>, <m3-b>),
  he(<m3-bot>, <m3-c>),
  he(<m3-a>, <m3-top>),
  he(<m3-b>, <m3-top>),
  he(<m3-c>, <m3-top>),
)

// ── Пентагон N₅: немодулярная решётка ──
#let lattice-n5 = diagram(
  ..node-opts,
  spacing: 1.25em,
  hn((0, 3), $bot$, name: <n5-bot>),
  hn((-1, 2), $a$, name: <n5-a>),
  hn((-1, 1), $b$, name: <n5-b>),
  hn((1, 1), $c$, name: <n5-c>),
  hn((0, 0), $top$, name: <n5-top>),
  he(<n5-bot>, <n5-a>),
  he(<n5-bot>, <n5-c>),
  he(<n5-a>, <n5-b>),
  he(<n5-b>, <n5-top>),
  he(<n5-c>, <n5-top>),
)

// ── Решётка знаков ──
#let sign-lattice = diagram(
  ..node-opts,
  spacing: 1.05em,
  hn((0, 2), $bot$, name: <bot>),
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
  spacing: 1.3em,
  hn((0, 0), ${1,2,3}$, size: 1.2em, name: <p123>),
  hn((-1.8, 1), ${1,2}$, size: 1.2em, name: <p12>),
  hn((0, 1), ${1,3}$, size: 1.2em, name: <p13>),
  hn((1.8, 1), ${2,3}$, size: 1.2em, name: <p23>),
  hn((-1.8, 2), ${1}$, size: 1.2em, name: <p1>),
  hn((0, 2), ${2}$, size: 1.2em, name: <p2>),
  hn((1.8, 2), ${3}$, size: 1.2em, name: <p3>),
  hn((0, 3), $emptyset$, size: 1.2em, name: <p0>),
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

// ── Крупный куб B₃ для сольного слайда ──
#let hasse-powerset-3-large = diagram(
  ..node-opts,
  spacing: 1.65em,
  hn((0, 0), ${1,2,3}$, size: 1.5em, label: 0.9em, name: <p123>),
  hn((-1.8, 1), ${1,2}$, size: 1.5em, label: 0.9em, name: <p12>),
  hn((0, 1), ${1,3}$, size: 1.5em, label: 0.9em, name: <p13>),
  hn((1.8, 1), ${2,3}$, size: 1.5em, label: 0.9em, name: <p23>),
  hn((-1.8, 2), ${1}$, size: 1.5em, label: 0.9em, name: <p1>),
  hn((0, 2), ${2}$, size: 1.5em, label: 0.9em, name: <p2>),
  hn((1.8, 2), ${3}$, size: 1.5em, label: 0.9em, name: <p3>),
  hn((0, 3), $emptyset$, size: 1.5em, label: 0.9em, name: <p0>),
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
