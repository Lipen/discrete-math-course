// Diagrams for the Kripke chapter (m32): traffic-light Kripke structure.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let k-node = oklch(88%, 0.03, 250deg)
#let k-node-str = oklch(60%, 0.08, 250deg)
#let k-edge = oklch(35%, 0.02, 265deg) + 0.6pt
#let k-label = oklch(35%, 0.02, 265deg)

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
