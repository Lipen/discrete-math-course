// Круги Эйлера и квадрат оппозиций для силлогистики Аристотеля.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-fill = oklch(88%, 0.03, 250deg)
#let c-fill-warm = oklch(90%, 0.05, 90deg)
#let c-str = 0.8pt + oklch(50%, 0.08, 250deg)
#let c-label = oklch(30%, 0.02, 265deg)
#let c-dot = oklch(50%, 0.2, 25deg)

#let tag(pos, body) = draw.content(pos, text(size: 0.8em, fill: c-label)[#body])

// ── Четыре типа суждений: A, E, I, O ──
#let judgment-circles = canvas({
  let pair-a(x) = {
    draw.circle((x, 0), radius: 1, stroke: c-str, fill: c-fill, name: "A-P")
    draw.circle(
      (x, 0.32),
      radius: 0.42,
      stroke: c-str,
      fill: c-fill-warm,
      name: "A-S",
    )
    tag((x, 0.32), $S$)
    tag((x - 0.45, -0.62), $P$)
    tag((x, -1.5), [*$A$*])
  }
  let pair-e(x) = {
    draw.circle(
      (x - 0.52, 0),
      radius: 0.55,
      stroke: c-str,
      fill: c-fill-warm,
      name: "E-S",
    )
    draw.circle(
      (x + 0.72, 0),
      radius: 0.55,
      stroke: c-str,
      fill: c-fill,
      name: "E-P",
    )
    tag((x - 0.52, 0), $S$)
    tag((x + 0.72, 0), $P$)
    tag((x, -1.5), [*$E$*])
  }
  let pair-i(x) = {
    draw.circle(
      (x - 0.4, 0),
      radius: 0.65,
      stroke: c-str,
      fill: c-fill-warm,
      name: "I-S",
    )
    draw.circle(
      (x + 0.5, 0),
      radius: 0.65,
      stroke: c-str,
      fill: c-fill,
      name: "I-P",
    )
    draw.content((x + 0.05, 0), circle(
      radius: 2.2pt,
      fill: c-dot,
      stroke: none,
    ))
    tag((x - 0.55, 0.35), $S$)
    tag((x + 0.7, 0.35), $P$)
    tag((x, -1.5), [*$I$*])
  }
  let pair-o(x) = {
    draw.circle(
      (x - 0.3, 0),
      radius: 0.65,
      stroke: c-str,
      fill: c-fill-warm,
      name: "O-S",
    )
    draw.circle(
      (x + 0.6, -0.28),
      radius: 0.65,
      stroke: c-str,
      fill: c-fill,
      name: "O-P",
    )
    draw.content((x - 0.55, 0.38), circle(
      radius: 2.2pt,
      fill: c-dot,
      stroke: none,
    ))
    tag((x - 0.45, -0.15), $S$)
    tag((x + 0.85, -0.6), $P$)
    tag((x, -1.5), [*$O$*])
  }

  pair-a(0)
  pair-e(3.1)
  pair-i(6.2)
  pair-o(9.3)
})

// ── Barbara: все M суть P, все S суть M --- все S суть P ──
#let euler-barbara = canvas({
  draw.circle((0, 0), radius: 1.6, stroke: c-str, fill: c-fill, name: "P")
  draw.circle(
    (0.2, -0.35),
    radius: 0.95,
    stroke: c-str,
    fill: c-fill-warm,
    name: "M",
  )
  draw.circle((0.38, -0.6), radius: 0.42, stroke: c-str, fill: white, name: "S")
  tag((0.38, -0.6), $S$)
  tag((1.05, -0.35), $M$)
  tag((0.75, 1.05), $P$)
})

// ── Celarent: ни одно M не есть P, все S суть M --- ни одно S не есть P ──
#let euler-celarent = canvas({
  draw.circle(
    (-1.05, 0),
    radius: 1.15,
    stroke: c-str,
    fill: c-fill-warm,
    name: "M",
  )
  draw.circle((1.35, 0), radius: 1.15, stroke: c-str, fill: c-fill, name: "P")
  draw.circle(
    (-1.05, -0.35),
    radius: 0.42,
    stroke: c-str,
    fill: white,
    name: "S",
  )
  tag((-1.05, -0.35), $S$)
  tag((-1.05, 0.72), $M$)
  tag((1.35, 0), $P$)
})

// ── Darii: все M суть P, некоторые S суть M --- некоторые S суть P ──
#let euler-darii = canvas({
  draw.circle((0.35, 0), radius: 1.5, stroke: c-str, fill: c-fill, name: "P")
  draw.circle(
    (0.5, -0.2),
    radius: 0.9,
    stroke: c-str,
    fill: c-fill-warm,
    name: "M",
  )
  draw.circle(
    (-0.85, -0.5),
    radius: 0.85,
    stroke: c-str,
    fill: white,
    name: "S",
  )
  draw.content((0.0, -0.45), circle(radius: 2.4pt, fill: c-dot, stroke: none))
  tag((-0.85, 0.42), $S$)
  tag((1.0, -0.2), $M$)
  tag((1.0, 1.0), $P$)
})

// ── Квадрат оппозиций: A, E, I, O и отношения между суждениями ──
#let square-of-opposition = {
  let xh = 2.7
  let yh = 1.35
  let box = 0.5
  let c-line = oklch(45%, 0.02, 265deg)

  let corner(pos, label-text) = {
    let (x, y) = pos
    draw.rect(
      (x - box, y + box),
      (x + box, y - box),
      name: label-text,
      fill: c-fill,
      stroke: c-str,
      radius: 4pt,
    )
    draw.content(label-text, text(size: 1em, fill: c-label)[#label-text])
  }

  let sq-edge(from, to, label: none, dashed: false, arrow: false, at: none) = {
    let st = if dashed {
      (paint: c-line, thickness: 0.4pt, dash: "dashed")
    } else {
      (paint: c-line, thickness: 0.8pt)
    }
    let mark = if arrow { (end: "stealth", fill: c-line) } else { none }
    draw.line(from, to, name: from + "-" + to, stroke: st, mark: mark)
    if label != none {
      draw.content(
        if at == none { from + "-" + to } else { at },
        text(size: 0.7em, fill: c-label)[#label],
        fill: white,
        padding: 2pt,
      )
    }
  }

  canvas({
    corner((-xh, yh), "A")
    corner((xh, yh), "E")
    corner((-xh, -yh), "I")
    corner((xh, -yh), "O")

    sq-edge("A", "E", label: [контрарность])
    sq-edge("I", "O", label: [субконтрарность])
    sq-edge("A", "I", label: [подчинение], arrow: true, at: (-xh, 0))
    sq-edge("E", "O", label: [подчинение], arrow: true, at: (xh, 0))

    sq-edge("A", "O", dashed: true)
    sq-edge("I", "E", dashed: true)
    draw.content(
      (0, 0),
      text(size: 0.7em, fill: c-label)[противоречие],
      fill: white,
      padding: 2pt,
    )
  })
}
