// Диаграммы Хассе: порядок по делимости, цепь, булеаны, решётка знаков.
#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// Ось y у fletcher направлена вниз: наибольший элемент получает y = 0,
// наименьший --- максимальный y. Рёбра Хассе идут вверх без стрелок.
#let hn(
  pos,
  body,
  tone: cool,
  fill: none,
  size: 0.9em,
  label: 0.8em,
  ..args,
) = node(
  pos,
  text(size: label, fill: ink)[#body],
  fill: if fill == none { tone.lighten(82%) } else { fill },
  stroke: 1.1pt + tone,
  width: size,
  height: size,
  ..args,
)
#let he(from, to) = edge(from, to, "-", stroke: edge-plain)

// Оболочка подмножества S: капсула обхватывает перечисленные вершины, метка S в центре.
#let set-blob(vertices, inset: 0.35em) = node(
  (0, 0),
  text(size: 0.75em, fill: cool)[$S$],
  enclose: vertices,
  inset: inset,
  shape: shapes.pill,
  fill: cool.lighten(93%),
  stroke: 0.9pt + cool,
)

// общие параметры вершин: круг одного размера, как в книге
#let node-opts = (
  node-shape: "circle",
  node-inset: 0pt,
  node-outset: 0pt,
)

// ── Делимость на {1, 2, 3, 4, 6, 12} ──
#let hasse-divisors-12 = diagram(
  ..node-opts,
  spacing: 1.7em,
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
  spacing: 1.8em,
  hn((0, 2), $1$, name: <c1>),
  hn((0, 1), $2$, name: <c2>),
  hn((0, 0), $3$, name: <c3>),
  he(<c1>, <c2>),
  he(<c2>, <c3>),
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
  spacing: 1.8em,
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
  spacing: 1.8em,
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
  spacing: 1.5em,
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
  spacing: 1.8em,
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
  spacing: 2.2em,
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

// ── Полное отношение на {1, 2, 3, 6}: петли, транзитивность, стрелки ──
#let hasse-digraph-full = diagram(
  ..node-opts,
  spacing: 1.45em,
  hn((0, 1.6), $1$, name: <f1>),
  hn((-1.15, 0.8), $2$, name: <f2>),
  hn((1.15, 0.8), $3$, name: <f3>),
  hn((0, 0), $6$, name: <f6>),
  edge(<f1>, <f2>, "-}>", stroke: edge-plain),
  edge(<f1>, <f3>, "-}>", stroke: edge-plain),
  edge(<f2>, <f6>, "-}>", stroke: edge-plain),
  edge(<f3>, <f6>, "-}>", stroke: edge-plain),
  edge(<f1>, <f6>, "-}>", stroke: (
    paint: warm,
    thickness: 0.9pt,
    cap: "round",
  )),
  edge(<f1>, <f1>, "-", stroke: edge-plain, bend: 60deg),
  edge(<f2>, <f2>, "-", stroke: edge-plain, bend: -60deg),
  edge(<f3>, <f3>, "-", stroke: edge-plain, bend: 60deg),
  edge(<f6>, <f6>, "-", stroke: edge-plain, bend: -60deg),
)

// ── Транзитивное сокращение на {1, 2, 3, 6}: только покрытия ──
#let hasse-digraph-cover = diagram(
  ..node-opts,
  spacing: 1.45em,
  hn((0, 1.6), $1$, name: <c1>),
  hn((-1.15, 0.8), $2$, name: <c2>),
  hn((1.15, 0.8), $3$, name: <c3>),
  hn((0, 0), $6$, name: <c6>),
  he(<c1>, <c2>),
  he(<c1>, <c3>),
  he(<c2>, <c6>),
  he(<c3>, <c6>),
)

// ── Экстремумы: максимальный без наибольшего ──
#let extrema-maximal-chain = diagram(
  ..node-opts,
  spacing: 1.15em,
  hn((-0.7, 0), $m$, tone: warm, fill: warm.lighten(85%), name: <mx-m>),
  hn((0.7, 2.4), $x_0$, name: <mx-x0>),
  hn((1.6, 1.6), $x_1$, name: <mx-x1>),
  hn((2.5, 0.8), $x_2$, name: <mx-x2>),
  node((3.2, 0.3), text(size: 0.9em, fill: ink)[$dots$], name: <mx-dots>),
  he(<mx-x0>, <mx-x1>),
  he(<mx-x1>, <mx-x2>),
  edge(<mx-x2>, <mx-dots>, "-", stroke: edge-plain),
)

// ── Экстремумы: два минимальных, наименьшего нет ──
#let extrema-two-minimals = diagram(
  ..node-opts,
  spacing: 1.1em,
  hn((0, 0), $12$, name: <tm-12>),
  hn((-1.2, 1), $4$, name: <tm-4>),
  hn((1.2, 1), $6$, name: <tm-6>),
  hn((-1.2, 2), $2$, tone: warm, fill: warm.lighten(85%), name: <tm-2>),
  hn((1.2, 2), $3$, tone: warm, fill: warm.lighten(85%), name: <tm-3>),
  he(<tm-2>, <tm-4>),
  he(<tm-2>, <tm-6>),
  he(<tm-3>, <tm-6>),
  he(<tm-4>, <tm-12>),
  he(<tm-6>, <tm-12>),
)

// ── Грани пары S = {2, 3} в D₁₂: верхние тёплые, нижняя зелёная ──
#let bounds-d12 = diagram(
  ..node-opts,
  spacing: 1em,
  hn((0, 0), $12$, tone: warm, fill: warm.lighten(88%), name: <bd-12>),
  hn((-1.3, 1.55), $4$, name: <bd-4>),
  hn((1.3, 1.55), $6$, tone: warm, fill: warm.lighten(88%), name: <bd-6>),
  hn((-1.3, 3.1), $2$, name: <bd-2>),
  hn((1.3, 3.1), $3$, name: <bd-3>),
  set-blob((<bd-2>, <bd-3>)),
  hn((0, 4.65), $1$, tone: green, fill: green.lighten(88%), name: <bd-1>),
  he(<bd-2>, <bd-4>),
  he(<bd-2>, <bd-6>),
  he(<bd-3>, <bd-6>),
  he(<bd-4>, <bd-12>),
  he(<bd-6>, <bd-12>),
  he(<bd-1>, <bd-2>),
  he(<bd-1>, <bd-3>),
)

// ── Супремум и инфимум в D₁₂: sup {2,3} = 6, inf {4,6} = 2 ──
#let sup-inf-d12 = grid(
  columns: 2,
  column-gutter: 4.5em,
  align(center)[
    #diagram(
      ..node-opts,
      spacing: 1.2em,
      hn((0, 0), $12$, size: 0.8em, label: 0.72em, name: <su-12>),
      hn((-1.3, 1.4), $4$, size: 0.8em, label: 0.72em, name: <su-4>),
      hn(
        (1.3, 1.4),
        $6$,
        size: 0.8em,
        label: 0.72em,
        tone: warm,
        stroke: 2pt + warm,
        fill: warm.lighten(82%),
        name: <su-6>,
      ),
      hn((-1.3, 2.8), $2$, size: 0.8em, label: 0.72em, name: <su-2>),
      hn((1.3, 2.8), $3$, size: 0.8em, label: 0.72em, name: <su-3>),
      set-blob((<su-2>, <su-3>), inset: 0.3em),
      hn((0, 4.2), $1$, size: 0.8em, label: 0.72em, name: <su-1>),
      he(<su-2>, <su-4>),
      he(<su-2>, <su-6>),
      he(<su-3>, <su-6>),
      he(<su-4>, <su-12>),
      he(<su-6>, <su-12>),
      he(<su-1>, <su-2>),
      he(<su-1>, <su-3>),
    )
  ],
  align(center)[
    #diagram(
      ..node-opts,
      spacing: 1.2em,
      hn((0, 0), $12$, size: 0.8em, label: 0.72em, name: <in-12>),
      hn((-1.3, 1.4), $4$, size: 0.8em, label: 0.72em, name: <in-4>),
      hn((1.3, 1.4), $6$, size: 0.8em, label: 0.72em, name: <in-6>),
      set-blob((<in-4>, <in-6>), inset: 0.3em),
      hn(
        (-1.3, 2.8),
        $2$,
        size: 0.8em,
        label: 0.72em,
        tone: green,
        stroke: 2pt + green,
        fill: green.lighten(82%),
        name: <in-2>,
      ),
      hn((1.3, 2.8), $3$, size: 0.8em, label: 0.72em, name: <in-3>),
      hn((0, 4.2), $1$, size: 0.8em, label: 0.72em, name: <in-1>),
      he(<in-2>, <in-4>),
      he(<in-2>, <in-6>),
      he(<in-3>, <in-6>),
      he(<in-4>, <in-12>),
      he(<in-6>, <in-12>),
      he(<in-1>, <in-2>),
      he(<in-1>, <in-3>),
    )
  ],
)

// ── Супремума нет: над парой нет вершины ──
#let sup-bowtie = diagram(
  ..node-opts,
  spacing: 1em,
  hn((-0.7, 0), $b$, name: <bt-b>),
  hn((0.7, 0), $c$, name: <bt-c>),
  set-blob((<bt-b>, <bt-c>)),
  hn((0, 1.55), $a$, name: <bt-a>),
  he(<bt-a>, <bt-b>),
  he(<bt-a>, <bt-c>),
)

// ── Супремума нет: две минимальные верхние грани над парой ──
#let sup-two-bounds = diagram(
  ..node-opts,
  spacing: 1em,
  hn((-0.8, 0), $u$, tone: warm, fill: warm.lighten(85%), name: <ub-u>),
  hn((0.8, 0), $v$, tone: warm, fill: warm.lighten(85%), name: <ub-v>),
  hn((-0.8, 1.4), $b$, name: <ub-b>),
  hn((0.8, 1.4), $c$, name: <ub-c>),
  set-blob((<ub-b>, <ub-c>)),
  he(<ub-b>, <ub-u>),
  he(<ub-c>, <ub-v>),
  edge(<ub-b>, <ub-v>, "-", stroke: edge-plain, bend: 32deg),
  edge(<ub-c>, <ub-u>, "-", stroke: edge-plain, bend: 32deg),
)

// ── 1/n на числовой прямой: сгущение к нулю, инфимум вне множества ──
#let inf-number-line = canvas({
  // ось со стрелкой
  draw.line((-0.6, 0), (12.8, 0), stroke: 0.9pt + ink, mark: (end: "stealth"))
  // точки 1/n: промежутки убывают, сгусток урезает к нулю
  for k in range(1, 13) {
    draw.circle((12 / k, 0), radius: 0.09, fill: ink, stroke: none)
  }
  let labels = ((1, $1$), (2, $1/2$), (3, $1/3$), (4, $1/4$))
  for (k, lab) in labels {
    draw.content((12 / k, -0.45), text(size: 0.8em, fill: ink)[#lab])
  }
  // инфимум: ноль вне множества
  draw.circle((0, 0), radius: 0.14, fill: none, stroke: 1.4pt + green)
  draw.content((0, -0.45), text(size: 0.8em, fill: green)[$0$])
})

// ── Права доступа Unix: булеан {r, w, x} ──
#let hasse-permissions = diagram(
  ..node-opts,
  spacing: 1.5em,
  hn((0, 0), [rwx], size: 1.3em, label: 0.75em, name: <perm-rwx>),
  hn((-1.8, 1), [rw], size: 1.3em, label: 0.75em, name: <perm-rw>),
  hn((0, 1), [rx], size: 1.3em, label: 0.75em, name: <perm-rx>),
  hn((1.8, 1), [wx], size: 1.3em, label: 0.75em, name: <perm-wx>),
  hn((-1.8, 2), [r], size: 1.3em, label: 0.75em, name: <perm-r>),
  hn((0, 2), [w], size: 1.3em, label: 0.75em, name: <perm-w>),
  hn((1.8, 2), [x], size: 1.3em, label: 0.75em, name: <perm-x>),
  hn((0, 3), $emptyset$, size: 1.3em, label: 0.75em, name: <perm-none>),
  he(<perm-none>, <perm-r>),
  he(<perm-none>, <perm-w>),
  he(<perm-none>, <perm-x>),
  he(<perm-r>, <perm-rw>),
  he(<perm-r>, <perm-rx>),
  he(<perm-w>, <perm-rw>),
  he(<perm-w>, <perm-wx>),
  he(<perm-x>, <perm-rx>),
  he(<perm-x>, <perm-wx>),
  he(<perm-rw>, <perm-rwx>),
  he(<perm-rx>, <perm-rwx>),
  he(<perm-wx>, <perm-rwx>),
)

// ── Решётка разбиений Π₃ трёхэлементного множества ──
#let partition-lattice-3 = diagram(
  ..node-opts,
  spacing: 1.6em,
  hn((0, 2), [1|2|3], size: 1.4em, label: 0.75em, name: <pi-bot>),
  hn((-1, 1), [12|3], size: 1.4em, label: 0.75em, name: <pi-12>),
  hn((0, 1), [13|2], size: 1.4em, label: 0.75em, name: <pi-13>),
  hn((1, 1), [23|1], size: 1.4em, label: 0.75em, name: <pi-23>),
  hn((0, 0), [123], size: 1.4em, label: 0.75em, name: <pi-top>),
  he(<pi-bot>, <pi-12>),
  he(<pi-bot>, <pi-13>),
  he(<pi-bot>, <pi-23>),
  he(<pi-12>, <pi-top>),
  he(<pi-13>, <pi-top>),
  he(<pi-23>, <pi-top>),
)
