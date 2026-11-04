#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let tape-cell-stroke = t-bd + c-bd

#let head-stroke = (paint: c-accent, thickness: t-hi)

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let start-stroke = (paint: c-accent, thickness: t-hi)

#let turing-machine = canvas({
  let n = 8
  let cell = 0.8
  let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
  let read-idx = 3

  let cell-left(i) = (i - n / 2 + 0.5) * cell

  let tape-cell(x, sym, highlighted: false, name: none) = {
    draw.rect(
      (x, -cell / 2),
      (x + cell, cell / 2),
      fill: if highlighted { c-warn } else { c-fl },
      stroke: tape-cell-stroke,
      name: name,
    )
    draw.content((x + cell / 2, 0), text(size: s-cap, fill: c-ink)[#sym])
  }

  for i in range(n) {
    let x = cell-left(i)
    tape-cell(x, syms.at(i), highlighted: i == read-idx, name: if i
      == read-idx { "read" })
  }

  let tape-left = cell-left(0)
  let tape-right = cell-left(n - 1) + cell
  draw.content((tape-left - 0.4, 0), text(size: s-cap, fill: c-muted)[$dots$])
  draw.content((tape-right + 0.4, 0), text(size: s-cap, fill: c-muted)[$dots$])
  draw.content((tape-left, 0.7), anchor: "west", text(
    size: s-cap,
    fill: c-muted,
  )[Лента:])

  let ctrl-w = 2.5
  draw.rect(
    (-ctrl-w / 2, -1.6),
    (ctrl-w / 2, -2.8),
    radius: 4pt,
    fill: c-fl,
    stroke: tape-cell-stroke,
    name: "ctrl",
  )
  draw.content((0, -1.9), text(size: s-node, fill: c-ink)[$q_i$])
  draw.content((0, -2.4), text(size: s-cap, fill: c-muted)[конечное])

  draw.line("ctrl.north", "read.south", stroke: head-stroke, mark: (
    end: "stealth",
    fill: c-accent,
  ))
})

#let tm-computation = canvas({
  let cell = 0.75
  let n = 6

  let config-row(y, cells, head-idx, state-label, state-color: c-ink) = {
    for (i, sym) in cells.enumerate() {
      let x = (i - n / 2 + 0.5) * cell
      draw.rect(
        (x, y - 0.35),
        (x + cell, y + 0.35),
        fill: if i == head-idx { c-warn } else { c-fl },
        stroke: tape-cell-stroke,
      )
      draw.content((x + cell / 2, y), text(size: s-cap, fill: c-ink)[#sym])
    }
    draw.content(
      (-n / 2 * cell - 0.35, y),
      anchor: "east",
      text(size: s-cap, fill: state-color, weight: "bold")[#state-label],
    )
    let hx = (head-idx - n / 2 + 0.5) * cell + cell / 2
    draw.content((hx, y - 0.6), text(size: s-cap, fill: c-accent)[$arrow.b$])
  }

  let transition-arrow(y, body) = {
    draw.content((-n / 2 * cell - 0.35, y), text(
      size: s-cap,
      fill: c-muted,
    )[$arrow.b$])
    draw.content((-0.2, y), text(size: s-cap, fill: c-muted)[#body])
  }

  config-row(3.6, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 0, $q_0$)
  transition-arrow(2.65, [читает 1, пишет 1, $R$])
  config-row(1.8, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 1, $q_1$)
  transition-arrow(0.85, [читает 1, пишет 1, $R$])
  config-row(0.0, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 2, $q_0$)
  transition-arrow(-0.95, [читает ␣, принимает])
  config-row(
    -1.8,
    ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$),
    2,
    qAccept,
    state-color: c-accent,
  )
})

// ── Укладка нескольких лент в одну ленту с дорожками ──
#let multitape-layout = canvas({
  let cell = 0.78
  let x0 = 1.1
  let n = 6
  let tops = (3.3, 2.4, 1.5)
  let tape-labels = ("лента 1", "лента 2", "лента 3")
  let symbols = (
    ($1$, $0$, $1$, $1$, $Blank$, $Blank$),
    ($Blank$, $X$, $X$, $Blank$, $Blank$, $Blank$),
    ($a$, $a$, $b$, $Blank$, $Blank$, $Blank$),
  )
  let heads = (2, 2, 1)

  let tape-row(y, id, label, syms, head) = {
    draw.content(
      (0.95, y),
      anchor: "east",
      text(size: s-cap, fill: c-muted)[#label],
    )
    for (i, sym) in syms.enumerate() {
      let x = x0 + i * cell
      draw.rect(
        (x, y - cell / 2),
        (x + cell, y + cell / 2),
        fill: if i == head { c-warn } else { c-fl },
        stroke: tape-cell-stroke,
        name: "row-" + id + "-" + str(i),
      )
      draw.content((x + cell / 2, y), text(size: s-cap, fill: c-ink)[#sym])
    }
    draw.line(
      "row-" + id + "-" + str(head) + ".south",
      (rel: (0, -0.24)),
      stroke: head-stroke,
      mark: (start: "stealth", fill: c-accent),
    )
  }

  for (j, y) in tops.enumerate() {
    tape-row(y, str(j), tape-labels.at(j), symbols.at(j), heads.at(j))
  }

  let cx = x0 + n * cell / 2
  draw.content((cx, 0.82), text(size: s-cap, fill: c-muted)[укладка])
  draw.line(
    (cx, 0.62),
    (cx, 0.28),
    stroke: (paint: c-muted, thickness: t-ed),
    mark: (end: "stealth", fill: c-muted),
  )

  for i in range(n) {
    let x = x0 + i * cell
    for j in range(3) {
      let ytop = 0.1 - j * 0.3
      let sym = symbols.at(j).at(i)
      draw.rect(
        (x, ytop - 0.3),
        (x + cell, ytop),
        fill: if heads.at(j) == i { c-warn } else { c-fl },
        stroke: tape-cell-stroke,
        name: "enc-" + str(j) + "-" + str(i),
      )
      draw.content(
        (x + cell / 2, ytop - 0.15),
        text(size: s-tiny, fill: c-ink)[#sym],
      )
    }
  }

  for j in range(3) {
    draw.content(
      (x0 + n * cell + 0.12, -0.05 - j * 0.3 + 0.15),
      anchor: "west",
      text(size: s-tiny, fill: c-muted)[дор. #str(j + 1)],
    )
  }
  draw.content(
    (cx, -1.05),
    text(size: s-cap, fill: c-muted)[одна лента],
  )
})

// ── Дерево вычислений недетерминированной машины ──
#let ntm-tree = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  node-corner-radius: 4pt,
  spacing: 2.4em,

  node((0, 0), text(size: s-cap)[$q_0 01$], name: <root>, width: 3.4em),
  node((-2.9, 1.5), text(size: s-cap)[$0 q_1 1$], name: <left>, width: 3.4em),
  node((0, 1.5), text(size: s-cap)[$1 q_0 1$], name: <mid>, width: 3.4em),
  node((2.9, 1.5), text(size: s-cap)[$0 q_2 1$], name: <right>, width: 3.4em),

  node(
    (-2.9, 3),
    text(size: s-cap)[$01 q_"accept" Blank$],
    name: <acc>,
    fill: c-atom,
    width: 5.2em,
    extrude: (0, 2pt),
  ),
  node(
    (0, 3),
    text(size: s-cap)[$11 q_"reject" Blank$],
    name: <rej>,
    width: 5.2em,
  ),
  node((2.9, 3), text(size: s-cap)[$dots$], name: <inf>, fill: none, stroke: none),

  edge(<root>, <left>, "-}>", stroke: e-stroke),
  edge(<root>, <mid>, "-}>", stroke: e-stroke),
  edge(<root>, <right>, "-}>", stroke: e-stroke),
  edge(<left>, <acc>, "-}>", stroke: e-stroke),
  edge(<mid>, <rej>, "-}>", stroke: e-stroke),
  edge(
    <right>,
    <inf>,
    "-}>",
    stroke: (paint: c-muted, thickness: t-ed, dash: "dashed"),
  ),
)

// ── Цикл универсальной машины ──
#let universal-loop = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  node-shape: rect,
  node-corner-radius: 4pt,
  spacing: 3em,

  node(
    (0, 0),
    text(size: s-cap)[прочитать состояние и символ],
    name: <read>,
    width: 9em,
    height: 2.4em,
  ),
  node(
    (3.6, 0),
    text(size: s-cap)[найти пятёрку в таблице],
    name: <find>,
    width: 9em,
    height: 2.4em,
  ),
  node(
    (3.6, 1.7),
    text(size: s-cap)[записать символ, сдвинуть головку],
    name: <write>,
    width: 9em,
    height: 2.4em,
  ),
  node(
    (0, 1.7),
    text(size: s-cap)[сменить состояние],
    name: <update>,
    width: 9em,
    height: 2.4em,
  ),

  edge(<read>, <find>, "-}>", stroke: e-stroke),
  edge(<find>, <write>, "-}>", stroke: e-stroke),
  edge(<write>, <update>, "-}>", stroke: e-stroke),
  edge(<update>, <read>, "-}>", stroke: e-stroke),
  edge((-1, 0), <read>, "-}>", stroke: start-stroke),
)
