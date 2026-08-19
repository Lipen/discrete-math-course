// Diagrams for the Kripke chapter (m32): traffic-light Kripke structure
// and the modal cube of normal modal systems.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let k-node = oklch(88%, 0.03, 250deg)
#let k-node-str = oklch(60%, 0.08, 250deg)
#let k-edge = oklch(35%, 0.02, 265deg) + 0.6pt
#let k-label = oklch(35%, 0.02, 265deg)
#let k-forbidden = (paint: oklch(55%, 0.19, 25deg), thickness: 0.8pt, dash: "dashed")

// Traffic light: states G (green), Y (yellow), R (red) on a 3-cycle.
#let kripke-traffic = canvas({
  let r = 0.45
  draw.circle((0, 0.9), radius: r, fill: k-node, stroke: k-node-str, name: "G")
  draw.content((0, 0.9), text(size: 0.72em, fill: k-label)[$G$])

  draw.circle((0.95, -0.55), radius: r, fill: k-node, stroke: k-node-str, name: "Y")
  draw.content((0.95, -0.55), text(size: 0.72em, fill: k-label)[$Y$])

  draw.circle((-0.95, -0.55), radius: r, fill: k-node, stroke: k-node-str, name: "R")
  draw.content((-0.95, -0.55), text(size: 0.72em, fill: k-label)[$R$])

  draw.line("G", "Y", stroke: k-edge, mark: (end: ">"))
  draw.line("Y", "R", stroke: k-edge, mark: (end: ">"))
  draw.line("R", "G", stroke: k-edge, mark: (end: ">"))

  // Atom labels: which atomic proposition is true in each state.
  draw.content((0, 1.5), anchor: "south", text(size: 0.62em, fill: k-label)[${"green"}$])
  draw.content((1.05, -1.15), anchor: "west", text(size: 0.62em, fill: k-label)[${"yellow"}$])
  draw.content((-1.05, -1.15), anchor: "east", text(size: 0.62em, fill: k-label)[${"red"}$])
})

// ── Modal cube: inclusions among the six main normal modal systems ──
// Hasse-style: K at the bottom, S5 at the top; an edge means the lower
// system is included in the upper one (K ⊂ D ⊂ T ⊂ S4 ⊂ S5, T ⊂ B ⊂ S5).
#let mc-n-size = 1.3em
#let mc-n-fill = oklch(88%, 0.03, 250deg)
#let mc-n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let mc-e-str = 0.6pt + oklch(35%, 0.02, 265deg)

#let mc-node(pos, body, ..args) = node(
  pos,
  body,
  fill: mc-n-fill,
  width: mc-n-size,
  height: mc-n-size,
  ..args,
)
#let mc-edge(from, to) = edge(from, to, "-", stroke: mc-e-str)

// Fletcher y-axis points downward: S5 is the top element (y = 0).
#let modal-cube = diagram(
  node-shape: "circle",
  node-stroke: mc-n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2em,
  mc-node((0, 0), $S_5$, name: <mc-s5>),
  mc-node((-1.2, 1), $S_4$, name: <mc-s4>),
  mc-node((1.2, 1), $B$, name: <mc-b>),
  mc-node((0, 2), $T$, name: <mc-t>),
  mc-node((-1.2, 3), $D$, name: <mc-d>),
  mc-node((0, 4), $K$, name: <mc-k>),
  mc-edge(<mc-k>, <mc-d>),
  mc-edge(<mc-k>, <mc-t>),
  mc-edge(<mc-d>, <mc-t>),
  mc-edge(<mc-t>, <mc-s4>),
  mc-edge(<mc-t>, <mc-b>),
  mc-edge(<mc-s4>, <mc-s5>),
  mc-edge(<mc-b>, <mc-s5>),
)

// ── Mutual exclusion: state space of two processes competing for a ──
// critical section. State (C,C) would violate crit_1 ∧ crit_2; the
// red dashed border marks it as forbidden (unreachable in a correct model).
#let mutex-states = canvas({
  let r = 0.42
  draw.circle((0, 0), radius: r, fill: k-node, stroke: k-node-str, name: "oo")
  draw.content((0, 0), text(size: 0.62em, fill: k-label)[${(O, O)}$])
  draw.content((0, -0.75), anchor: "north", text(size: 0.55em, fill: k-label)[$nothing$])

  draw.circle((-1.4, 1.4), radius: r, fill: k-node, stroke: k-node-str, name: "co")
  draw.content((-1.4, 1.4), text(size: 0.62em, fill: k-label)[${(C, O)}$])
  draw.content((-1.95, 1.4), anchor: "east", text(size: 0.55em, fill: k-label)[${"crit"_1}$])

  draw.circle((1.4, 1.4), radius: r, fill: k-node, stroke: k-node-str, name: "oc")
  draw.content((1.4, 1.4), text(size: 0.62em, fill: k-label)[${(O, C)}$])
  draw.content((1.95, 1.4), anchor: "west", text(size: 0.55em, fill: k-label)[${"crit"_2}$])

  draw.circle((0, 2.9), radius: r, fill: none, stroke: k-forbidden, name: "cc")
  draw.content((0, 2.9), text(size: 0.62em, fill: k-label)[${(C, C)}$])
  draw.content((0.55, 2.9), anchor: "west", text(size: 0.55em, fill: k-label)[${"crit"_1, "crit"_2}$])

  draw.line("oo", "co", stroke: k-edge, mark: (end: ">"))
  draw.line("oo", "oc", stroke: k-edge, mark: (end: ">"))
  draw.line("co", "oo", stroke: k-edge, mark: (end: ">"))
  draw.line("oc", "oo", stroke: k-edge, mark: (end: ">"))
})
