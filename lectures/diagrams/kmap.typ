// Карты Карно: единый сеточный примитив и готовые примеры для лекции 13.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let k-grid = (paint: ink-soft, thickness: 0.5pt)

#let kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  values: (),
  cell-labels: (),
  groups: (),
  legend: (),
  row-name: [],
  col-name: [],
  s: 0.82,
  value-size: 1em,
  cell-label-size: 0.52em,
) = canvas({
  let nr = rows.len()
  let nc = cols.len()

  let value(i, j) = {
    let row = if i < values.len() { values.at(i) } else { () }
    if j < row.len() { row.at(j) } else { "" }
  }
  let cell-label(i, j) = {
    let row = if i < cell-labels.len() { cell-labels.at(i) } else { () }
    if j < row.len() { row.at(j) } else { "" }
  }

  for i in range(nr) {
    for j in range(nc) {
      let val = value(i, j)
      let tone = if val == "1" {
        green
      } else if val == "×" or val == "X" {
        amber
      } else {
        none
      }
      if tone != none {
        draw.rect(
          (j * s, -i * s),
          ((j + 1) * s, -(i + 1) * s),
          fill: tone.lighten(88%),
          stroke: none,
        )
      }
    }
  }

  for group in groups {
    for r in group.rects {
      let (r1, c1, r2, c2) = r
      draw.rect(
        (c1 * s + 0.07, -r1 * s - 0.07),
        ((c2 + 1) * s - 0.07, -(r2 + 1) * s + 0.07),
        radius: 0.12,
        stroke: (paint: group.tone, thickness: 1.8pt),
      )
    }
  }

  for i in range(nr + 1) {
    draw.line((0, -i * s), (nc * s, -i * s), stroke: k-grid)
  }
  for j in range(nc + 1) {
    draw.line((j * s, 0), (j * s, -nr * s), stroke: k-grid)
  }
  draw.line((0, 0), (nc * s, 0), stroke: 1pt + ink-soft)
  draw.line((0, 0), (0, -nr * s), stroke: 1pt + ink-soft)

  for i in range(nr) {
    for j in range(nc) {
      let pos = (j * s + s / 2, -(i + 0.5) * s)
      let val = value(i, j)
      if val != "" {
        draw.content(
          pos,
          text(
            size: value-size,
            weight: if val == "1" { "bold" } else { "regular" },
            fill: ink,
          )[#val],
        )
      }
      let lab = cell-label(i, j)
      if lab != "" {
        draw.content(
          (j * s + 0.06, -i * s - 0.06),
          anchor: "north-west",
          text(size: cell-label-size, fill: ink-soft)[#lab],
        )
      }
    }
  }

  for (i, lab) in rows.enumerate() {
    draw.content(
      (-0.22, -(i + 0.5) * s),
      anchor: "east",
      text(size: 0.7em, fill: ink)[#lab],
    )
  }
  for (j, lab) in cols.enumerate() {
    draw.content(
      (j * s + s / 2, 0.18),
      anchor: "south",
      text(size: 0.7em, fill: ink)[#lab],
    )
  }

  if col-name != [] {
    draw.content((nc * s / 2, 0.62), text(size: 0.8em, fill: ink)[#col-name])
  }
  if row-name != [] {
    draw.content((-0.95, -nr * s / 2), text(size: 0.8em, fill: ink)[#row-name])
  }

  for (k, entry) in legend.enumerate() {
    let x = nc * s + 0.55
    let y = -0.55 - k * 0.62
    draw.line((x, y), (x + 0.24, y), stroke: (
      paint: entry.at(1),
      thickness: 2.2pt,
    ))
    draw.content(
      (x + 0.32, y),
      anchor: "west",
      text(size: 0.78em, fill: ink)[#entry.at(0)],
    )
  }
})

// Пустая карта трёх переменных: в клетках — битовые строки.
#let kmap-3var-empty = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  cell-labels: (
    ("000", "100"),
    ("001", "101"),
    ("011", "111"),
    ("010", "110"),
  ),
  row-name: $y z$,
  col-name: $x$,
  s: 0.9,
  cell-label-size: 0.58em,
)

// Пустая карта четырёх переменных: в клетках — номера минтермов.
#let kmap-4var-empty = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("00", "01", "11", "10"),
  cell-labels: (
    ("0", "4", "12", "8"),
    ("1", "5", "13", "9"),
    ("3", "7", "15", "11"),
    ("2", "6", "14", "10"),
  ),
  row-name: $y z$,
  col-name: $w x$,
  s: 0.9,
  cell-label-size: 0.62em,
)

// Группа через край: единицы на левом и правом краях, две верхние строки.
#let kmap-4var-wrap = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("00", "01", "11", "10"),
  values: (
    ("1", "0", "0", "1"),
    ("1", "0", "0", "1"),
    ("0", "0", "0", "0"),
    ("0", "0", "0", "0"),
  ),
  groups: ((rects: ((0, 0, 1, 0), (0, 3, 1, 3)), tone: cool),),
  legend: (($overline(x) overline(y)$, cool),),
  row-name: $y z$,
  col-name: $w x$,
  s: 0.82,
  value-size: 1.1em,
)

// f = x: вся правая колонка.
#let kmap-3var-x = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  values: (("0", "1"), ("0", "1"), ("0", "1"), ("0", "1")),
  groups: ((rects: ((0, 1, 3, 1),), tone: green),),
  legend: (($x$, green),),
  row-name: $y z$,
  col-name: $x$,
  s: 1.0,
  value-size: 1.1em,
)

// Функция большинства: три пересекающиеся пары.
#let kmap-3var-majority = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  values: (("0", "0"), ("0", "1"), ("1", "1"), ("0", "1")),
  groups: (
    (rects: ((1, 1, 2, 1),), tone: cool),
    (rects: ((2, 0, 2, 1),), tone: green),
    (rects: ((2, 1, 3, 1),), tone: warm),
  ),
  legend: (($x z$, cool), ($y z$, green), ($x y$, warm)),
  row-name: $y z$,
  col-name: $x$,
  s: 1.0,
  value-size: 1.1em,
)

// Частичная функция: 1 в 001, безразличие в 011.
#let kmap-3var-dontcare = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  values: (("0", "0"), ("1", "0"), ("×", "0"), ("0", "0")),
  groups: ((rects: ((1, 0, 2, 0),), tone: cool),),
  legend: (($overline(x) z$, cool),),
  row-name: $y z$,
  col-name: $x$,
  s: 0.9,
  value-size: 1.1em,
)

// f = x y or overline(x) z: две обязательные пары и консенсус y z.
#let kmap-3var-consensus = kmap(
  rows: ("00", "01", "11", "10"),
  cols: ("0", "1"),
  values: (("0", "0"), ("1", "0"), ("1", "1"), ("0", "1")),
  groups: (
    (rects: ((2, 1, 3, 1),), tone: cool),
    (rects: ((1, 0, 2, 0),), tone: green),
    (rects: ((2, 0, 2, 1),), tone: warm),
  ),
  legend: (($x y$, cool), ($overline(x) z$, green), ($y z$, warm)),
  row-name: $y z$,
  col-name: $x$,
  s: 1.0,
  value-size: 1.1em,
)
