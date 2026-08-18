// SMT + Kripke diagrams: DPLL(T) architecture, difference-logic negative cycle, CTL tree.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Palette ──
#let d-node-fill = oklch(90%, 0.03, 250deg)
#let d-node-border = oklch(55%, 0.10, 250deg)
#let d-text = oklch(30%, 0.02, 265deg)
#let d-muted = oklch(55%, 0.02, 265deg)
#let d-edge = oklch(35%, 0.02, 265deg)
#let d-neg = oklch(58%, 0.20, 22deg)    // negative-cycle highlight
#let d-pos = oklch(55%, 0.15, 150deg)   // positive edge
#let d-sat = oklch(88%, 0.05, 250deg)   // SAT solver box
#let d-theory = oklch(88%, 0.05, 155deg) // theory solver box

#let c-node(pos, label, fill: d-node-fill) = {
  draw.circle(
    pos,
    radius: 0.34,
    fill: fill,
    stroke: (paint: d-node-border, thickness: 0.8pt),
  )
  draw.content(pos, text(size: 0.62em, fill: d-text, weight: "bold")[#label])
}

// ── DPLL(T) architecture ──
#let dpll-t-architecture = canvas({
  let sat-top = (0, 1.6)
  let sat-bot = (0, 0.6)
  let th-top = (0, -0.6)
  let th-bot = (0, -1.6)

  draw.rect(
    (-2.6, sat-bot.at(1)),
    (2.6, sat-top.at(1)),
    fill: d-sat,
    stroke: (paint: d-node-border, thickness: 0.8pt),
    radius: 3pt,
  )
  draw.content((0, 1.1), text(size: 0.7em, fill: d-text, weight: "bold")[SAT-решатель])
  draw.content((0, 0.8), text(size: 0.55em, fill: d-muted)[DPLL / CDCL])

  draw.rect(
    (-2.6, th-bot.at(1)),
    (2.6, th-top.at(1)),
    fill: d-theory,
    stroke: (paint: d-node-border, thickness: 0.8pt),
    radius: 3pt,
  )
  draw.content((0, -1.1), text(size: 0.7em, fill: d-text, weight: "bold")[Theory-солвер])
  draw.content((0, -1.4), text(size: 0.55em, fill: d-muted)[DL, EUF, LRA, ...])

  // SAT -> theory: proposes a model
  draw.line(
    (1.7, 0.6),
    (1.7, -0.6),
    mark: (end: "stealth"),
    stroke: d-edge + 0.8pt,
  )
  draw.content((2.15, 0), anchor: "west", text(size: 0.55em, fill: d-text)[модель])

  // theory -> SAT: returns T-lemma on conflict
  draw.line(
    (-1.7, -0.6),
    (-1.7, 0.6),
    mark: (end: "stealth"),
    stroke: d-edge + 0.8pt,
  )
  draw.content((-2.15, 0), anchor: "east", text(size: 0.55em, fill: d-text)[$T$-лемма])
})

// ── Difference-logic negative cycle ──
#let dl-negative-cycle = canvas({
  // Triangle x -> z (-3), z -> w (-1), w -> x (+2).
  let x = (-1.6, 1.2)
  let z = (1.6, 1.2)
  let w = (0, -1.6)

  c-node(x, $x$)
  c-node(z, $z$)
  c-node(w, $w$)

  // x -> z, weight -3
  draw.line(x, z, mark: (end: "stealth"), stroke: d-neg + 1pt)
  draw.content((0, 1.7), text(size: 0.6em, fill: d-neg, weight: "bold")[$-3$])
  // z -> w, weight -1
  draw.line(z, w, mark: (end: "stealth"), stroke: d-neg + 1pt)
  draw.content((1.05, -0.35), text(size: 0.6em, fill: d-neg, weight: "bold")[$-1$])
  // w -> x, weight +2
  draw.line(w, x, mark: (end: "stealth"), stroke: d-pos + 1pt)
  draw.content((-0.9, -0.35), text(size: 0.6em, fill: d-pos, weight: "bold")[$+2$])

  draw.content((0, -2.5), text(size: 0.6em, fill: d-neg)[$-3 - 1 + 2 = -2 < 0$])
})

// ── CTL computation tree ──
#let ctl-tree = canvas({
  // Root s0, branches s1 (p) and s2 (q); s1 branches to s3, s4; s2 branches to s5, s6.
  let s0 = (0, 2.4)
  let s1 = (-1.4, 1.0)
  let s2 = (1.4, 1.0)
  let s3 = (-2.2, -0.4)
  let s4 = (-0.6, -0.4)
  let s5 = (0.6, -0.4)
  let s6 = (2.2, -0.4)

  c-node(s0, $s_0$)
  c-node(s1, $s_1$)
  c-node(s2, $s_2$)
  c-node(s3, $s_3$)
  c-node(s4, $s_4$)
  c-node(s5, $s_5$)
  c-node(s6, $s_6$)

  draw.line(s0, s1, mark: (end: "stealth"), stroke: d-edge + 0.8pt)
  draw.line(s0, s2, mark: (end: "stealth"), stroke: d-edge + 0.8pt)
  draw.line(s1, s3, mark: (end: "stealth"), stroke: d-edge + 0.8pt)
  draw.line(s1, s4, mark: (end: "stealth"), stroke: d-edge + 0.8pt)
  draw.line(s2, s5, mark: (end: "stealth"), stroke: d-edge + 0.8pt)
  draw.line(s2, s6, mark: (end: "stealth"), stroke: d-edge + 0.8pt)

  draw.content((-2.2, -0.85), text(size: 0.55em, fill: d-text)[$p$])
  draw.content((-0.6, -0.85), text(size: 0.55em, fill: d-text)[$q$])
  draw.content((2.2, -0.85), text(size: 0.55em, fill: d-text)[$p$])
})
