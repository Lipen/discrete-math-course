#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let tape-cell-stroke = t-bd + c-bd

#let head-stroke = (paint: c-accent, thickness: t-hi)

#let turing-machine = canvas({
  let n = 8
  let cell = 0.8
  let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
  let read-idx = 3

  let tape-cell(x, sym, highlighted: false) = {
    draw.rect(
      (x, -cell / 2),
      (x + cell, cell / 2),
      fill: if highlighted { c-warn } else { c-fl },
      stroke: tape-cell-stroke,
    )
    draw.content((x + cell / 2, 0), text(size: s-cap, fill: c-ink)[#sym])
  }

  for i in range(n) {
    let x = (i - n / 2 + 0.5) * cell
    tape-cell(x, syms.at(i), highlighted: i == read-idx)
  }

  let tape-left = -n / 2 * cell
  let tape-right = n / 2 * cell
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
  )
  draw.content((0, -1.9), text(size: s-node, fill: c-ink)[$q_i$])
  draw.content((0, -2.4), text(size: s-cap, fill: c-muted)[конечное])

  draw.line((0, -1.6), (0, -0.72), stroke: head-stroke, mark: (
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
    draw.content((hx, y - 0.6), text(size: s-cap, fill: c-accent)[↓])
  }

  let transition-arrow(y, body) = {
    draw.content((-n / 2 * cell - 0.35, y), text(size: s-cap, fill: c-muted)[↓])
    draw.content((-0.2, y), text(size: s-cap, fill: c-muted)[#body])
  }

  config-row(3.0, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 0, $q_0$)
  transition-arrow(2.35, [читает 1, пишет 1, $R$])
  config-row(1.6, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 1, $q_1$)
  transition-arrow(0.95, [читает 1, пишет 1, $R$])
  config-row(0.2, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 2, $q_0$)
  transition-arrow(-0.45, [читает ␣, принимает])
  config-row(
    -1.2,
    ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$),
    2,
    qAccept,
    state-color: c-accent,
  )
})
