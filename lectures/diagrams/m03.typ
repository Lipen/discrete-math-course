// Круги Эйлера и квадрат оппозиций для силлогистики Аристотеля.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// Терминам силлогистики -- свои токены: S тёплый, M зелёный, P холодный.
#let euler-set(name, pos, r, tone, fill) = draw.circle(
  pos,
  radius: r,
  fill: fill,
  stroke: 1.1pt + tone,
  name: name,
)

// Свидетель exists-суждения: тёплая точка с белой обводкой.
#let witness(pos) = draw.circle(
  pos,
  radius: 0.075,
  fill: warm,
  stroke: 0.8pt + white,
)

// ── Четыре типа суждений: A, E, I, O ──
#let judgment-circles = canvas({
  let pair-a(x) = {
    panel((x - 1.25, -1.85), (x + 1.25, 1.2), tone: cool)
    euler-set("A-P", (x, 0), 1, cool, panel-cool)
    euler-set("A-S", (x, 0.32), 0.42, warm, panel-warm)
    mark((x, 0.32), $S$)
    mark((x - 0.45, -0.62), $P$)
    mark((x, -1.55), [*$A$*])
  }
  let pair-e(x) = {
    panel((x - 1.25, -1.85), (x + 1.25, 1.2), tone: cool)
    euler-set("E-S", (x - 0.65, 0), 0.55, warm, panel-warm)
    euler-set("E-P", (x + 0.65, 0), 0.55, cool, panel-cool)
    mark((x - 0.65, 0), $S$)
    mark((x + 0.65, 0), $P$)
    mark((x, -1.55), [*$E$*])
  }
  let pair-i(x) = {
    panel((x - 1.25, -1.85), (x + 1.25, 1.2), tone: cool)
    euler-set("I-S", (x - 0.4, 0), 0.65, warm, panel-warm)
    euler-set("I-P", (x + 0.5, 0), 0.65, cool, panel-cool)
    witness((x + 0.05, 0))
    mark((x - 0.55, 0.35), $S$)
    mark((x + 0.7, 0.35), $P$)
    mark((x, -1.55), [*$I$*])
  }
  let pair-o(x) = {
    panel((x - 1.25, -1.85), (x + 1.25, 1.2), tone: cool)
    euler-set("O-S", (x - 0.3, 0), 0.65, warm, panel-warm)
    euler-set("O-P", (x + 0.55, -0.28), 0.65, cool, panel-cool)
    witness((x - 0.55, 0.38))
    mark((x - 0.45, -0.15), $S$)
    mark((x + 0.85, -0.6), $P$)
    mark((x, -1.55), [*$O$*])
  }

  pair-a(0)
  pair-e(3.1)
  pair-i(6.2)
  pair-o(9.3)
})

// ── Barbara: все M суть P, все S суть M --- все S суть P ──
#let euler-barbara = canvas({
  euler-set("P", (0, 0), 1.6, cool, panel-cool)
  euler-set("M", (0.2, -0.35), 0.95, green, panel-green)
  euler-set("S", (0.38, -0.6), 0.42, warm, panel-warm)
  mark((0.38, -0.6), $S$)
  mark((1.05, -0.35), $M$)
  mark((0.75, 1.05), $P$)
})

// ── Celarent: ни одно M не есть P, все S суть M --- ни одно S не есть P ──
#let euler-celarent = canvas({
  euler-set("M", (-1.05, 0), 1.15, green, panel-green)
  euler-set("P", (1.35, 0), 1.15, cool, panel-cool)
  euler-set("S", (-1.05, -0.35), 0.42, warm, panel-warm)
  mark((-1.05, -0.35), $S$)
  mark((-1.05, 0.72), $M$)
  mark((1.35, 0), $P$)
})

// ── Darii: все M суть P, некоторые S суть M --- некоторые S суть P ──
#let euler-darii = canvas({
  euler-set("P", (0.35, 0), 1.5, cool, panel-cool)
  euler-set("M", (0.5, -0.2), 0.9, green, panel-green)
  euler-set("S", (-0.85, -0.5), 0.85, warm, panel-warm)
  witness((-0.25, -0.42))
  mark((-1.3, -0.2), $S$)
  mark((1.0, -0.2), $M$)
  mark((1.0, 1.0), $P$)
})

// ── Квадрат оппозиций: A, E, I, O и отношения между суждениями ──
#let square-of-opposition = {
  let xh = 2.7
  let yh = 1.35
  let box = 0.5

  // Универсальные суждения холодные, частные тёплые.
  let corner(pos, name, tone) = {
    let (x, y) = pos
    draw.rect(
      (x - box, y + box),
      (x + box, y - box),
      name: name,
      fill: white,
      stroke: 1.2pt + tone,
      radius: 4pt,
    )
    mark(pos, [*#name*])
  }

  let link(from, to, label: none, dashed: false, arrow: false, at: none) = {
    let st = if dashed {
      edge-soft
    } else {
      (paint: ink, thickness: 0.8pt, cap: "round")
    }
    let mk = if arrow { (end: (symbol: "stealth", fill: ink)) } else { none }
    draw.line(from, to, name: from + "-" + to, stroke: st, mark: mk)
    if label != none {
      let anchor = if at == none { from + "-" + to } else { at }
      draw.content(
        anchor,
        text(size: 0.42em, fill: ink)[#label],
        fill: white,
        padding: 2pt,
      )
    }
  }

  canvas({
    corner((-xh, yh), "A", cool)
    corner((xh, yh), "E", cool)
    corner((-xh, -yh), "I", warm)
    corner((xh, -yh), "O", warm)

    link("A", "E", label: [контрарность])
    link("I", "O", label: [субконтрарность])
    link("A", "I", label: [подчинение], arrow: true, at: (-xh, 0))
    link("E", "O", label: [подчинение], arrow: true, at: (xh, 0))

    link("A", "O", dashed: true)
    link("I", "E", dashed: true)
    draw.content(
      (0, 0),
      text(size: 0.42em, fill: ink)[противоречие],
      fill: white,
      padding: 2pt,
    )
  })
}
