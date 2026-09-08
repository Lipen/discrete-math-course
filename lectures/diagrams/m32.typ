// Kripke (modal) lecture diagrams: CTL computation tree.
// SMT diagrams (dpll-t-architecture, dl-negative-cycle) вынесены в m15.typ.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Palette ──
#let d-node-fill = oklch(90%, 0.03, 250deg)
#let d-node-border = oklch(55%, 0.10, 250deg)
#let d-text = oklch(30%, 0.02, 265deg)
#let d-edge = oklch(35%, 0.02, 265deg)

#let c-node(pos, label, fill: d-node-fill) = {
  draw.circle(
    pos,
    radius: 0.17,
    fill: fill,
    stroke: (paint: d-node-border, thickness: 0.8pt),
  )
  draw.content(pos, text(size: 0.42em, fill: d-text, weight: "bold")[#label])
}

// ── CTL computation tree ──
#let ctl-tree = canvas({
  // Root s0, branches s1 (p) and s2 (q); s1 branches to s3, s4; s2 branches to s5, s6.
  let s0 = (0, 1.2)
  let s1 = (-0.7, 0.5)
  let s2 = (0.7, 0.5)
  let s3 = (-1.1, -0.2)
  let s4 = (-0.3, -0.2)
  let s5 = (0.3, -0.2)
  let s6 = (1.1, -0.2)

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

  draw.content((-1.1, -0.425), text(size: 0.42em, fill: d-text)[$p$])
  draw.content((-0.3, -0.425), text(size: 0.42em, fill: d-text)[$q$])
  draw.content((1.1, -0.425), text(size: 0.42em, fill: d-text)[$p$])
})
