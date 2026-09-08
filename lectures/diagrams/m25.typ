// Конфигурация МТ и сведение "HALT" к проблеме пустоты.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-tape = oklch(90%, 0.02, 80deg)
#let c-tape-str = oklch(35%, 0.02, 265deg) + 0.4pt
#let c-head = oklch(88%, 0.05, 250deg)
#let c-head-str = oklch(60%, 0.08, 250deg) + 0.6pt
#let c-label = oklch(35%, 0.02, 265deg)
#let c-brace = luma(55%)

#let tm-configuration = canvas({
  let syms = ("1", "0", "1", "1", $X$)
  let cell = 0.9
  let n = syms.len()
  let head-i = 2

  let tape-cell(i) = {
    let x = (i - n / 2 + 0.5) * cell
    let marked = i == head-i
    draw.rect(
      (x, -0.4),
      (x + cell, 0.4),
      fill: if marked { c-head } else { c-tape },
      stroke: if marked { c-head-str } else { c-tape-str },
      radius: 2pt,
      name: "cell-" + str(i),
    )
    draw.content("cell-" + str(i), text(size: 0.75em, fill: c-label)[#syms.at(
      i,
    )])
  }

  for i in range(n) {
    tape-cell(i)
  }

  draw.content((n / 2 * cell + 0.35, 0), text(
    size: 0.6em,
    fill: c-brace,
  )[$dots$])
  draw.content((-n / 2 * cell - 0.35, 0), text(
    size: 0.6em,
    fill: c-brace,
  )[$dots$])

  let hx = (head-i - n / 2 + 0.5) * cell
  draw.rect(
    (hx - 0.55, 1.0),
    (hx + 0.55, 1.55),
    radius: 4pt,
    fill: c-head,
    stroke: c-head-str,
    name: "state",
  )
  draw.content("state", text(size: 0.75em, fill: c-label)[$q_1$])
  draw.line("state", "cell-" + str(head-i), stroke: c-head-str)

  let brace(from-i, to-i, label) = {
    let x0 = (from-i - n / 2 + 0.5) * cell
    let x1 = (to-i - n / 2 + 0.5) * cell + cell
    draw.line((x0, -0.75), (x1, -0.75), stroke: 0.8pt + c-brace)
    draw.content(((x0 + x1) / 2, -1.1), text(
      size: 0.8em,
      fill: c-label,
    )[#label])
  }

  brace(0, 1, $u$)
  brace(2, 4, $v$)
})

#let reduction-halt-empty = {
  let n-stroke = 0.6pt + luma(70%)
  let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)
  let c-in = oklch(92%, 0.04, 45deg)
  let c-build = oklch(90%, 0.04, 250deg)
  let c-box = oklch(88%, 0.05, 300deg)
  let c-out = oklch(90%, 0.04, 155deg)

  let pn(pos, fill, name, ..args) = node(
    pos,
    fill: fill,
    stroke: n-stroke,
    radius: 4pt,
    inset: 0.7em,
    name: name,
    width: 9em,
    ..args,
  )

  diagram(
    spacing: (2.2em, 4em),
    pn((0, 0), c-in, <in>, text(
      size: 0.62em,
    )[$chevron.l M chevron.r, w$ \ вход: машина и слово]),
    pn((3, 0), c-build, <mp>, text(
      size: 0.62em,
    )[$M'$ \ игнорирует вход $x$, симулирует $M$ на $w$, \ при остановке принимает]),
    pn((6, 0), c-box, <e>, text(
      size: 0.62em,
    )[$E$ \ решатель пустоты \ (чёрный ящик)]),
    pn((9, 0), c-out, <out>, text(
      size: 0.62em,
    )[решатель $"HALT"$ \ ответ $E$ наоборот]),

    edge(
      <in>,
      <mp>,
      "-|>",
      stroke: e-stroke,
      label: $f$,
      label-size: 0.55em,
      label-angle: -30deg,
    ),
    edge(
      <mp>,
      <e>,
      "-|>",
      stroke: e-stroke,
      label: $chevron.l M' chevron.r$,
      label-size: 0.55em,
      label-angle: -30deg,
    ),
    edge(
      <e>,
      <out>,
      "-|>",
      stroke: e-stroke,
      label: "инверсия",
      label-size: 0.55em,
      label-angle: -30deg,
    ),
  )
}

#let c-ctrl = oklch(88%, 0.05, 155deg)
#let c-ctrl-str = oklch(55%, 0.18, 155deg) + 0.7pt

// Схема устройства МТ: лента, головка, конечное управление.
#let turing-machine = canvas({
  let n = 8
  let cell = 0.8
  for i in range(n) {
    let x = (i - n / 2 + 0.5) * cell
    draw.rect((x, -0.4), (x + cell, 0.4), fill: c-tape, stroke: c-tape-str)
    let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
    draw.content((x + cell / 2, 0), text(size: 0.7em, fill: c-label)[#syms.at(
      i,
    )])
  }

  draw.content((-n / 2 * cell - 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])
  draw.content((n / 2 * cell + 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])

  let head-x = 0
  draw.line((head-x, -0.5), (head-x - 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x, -0.5), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x - 0.3, -0.9), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.content((head-x, -0.72), text(size: 0.55em, fill: c-label)[↓])

  let ctrl-w = 2.5
  let ctrl-h = 1.2
  draw.rect(
    (-ctrl-w / 2, -1.6),
    (ctrl-w / 2, -2.8),
    radius: 4pt,
    fill: c-ctrl,
    stroke: c-ctrl-str,
  )
  draw.content((0, -1.95), text(size: 0.7em, fill: c-label)[$q_i$])
  draw.content((0, -2.35), text(size: 0.6em, fill: luma(50%))[конечное])

  draw.line((head-x, -0.9), (head-x, -1.6), stroke: c-head-str)

  draw.content((-n / 2 * cell, 0.7), anchor: "west", text(
    size: 0.72em,
    fill: c-label,
  )[Лента:])
})
