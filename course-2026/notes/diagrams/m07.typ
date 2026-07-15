// M07 diagrams — adder circuits.
#import "../requirements.typ": *
#import "../notation.typ": *

#import circuiteria: circuit, wire, element
#import "@preview/cetz:0.3.4" as ccetz
#import ccetz: draw

#let c-gate = oklch(88%, 0.03, 250deg)
#let c-fg = oklch(35%, 0.02, 265deg)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

// Gate dimensions.
#let gw = 1.4
#let gh = 0.85

// ── Half-adder: S = A xor B, C = A and B ──
// XOR at y=0.5 (spans 0.50–1.35), AND at y=-0.55 (spans -0.55–0.30), gap=0.20.
// Ports: XOR.in0=1.14, XOR.in1=0.71, XOR.out=(1.4,0.925)
//        AND.in0=0.09, AND.in1=-0.34, AND.out=(1.4,-0.125)
#let half-adder = circuit({
  element.gate-xor(x: 0, y: 0.5, w: gw, h: gh, id: "xor", fill: c-gate, stroke: c-str)
  element.gate-and(x: 0, y: -0.55, w: gw, h: gh, id: "and", fill: c-gate, stroke: c-str)

  // A → XOR.in0 + AND.in0. Junction at x=-0.55, y=1.14 (XOR.in0 level).
  wire.wire("a-in", ((-2.3, 1.14), (-0.55, 1.14)), color: c-fg)
  wire.wire("a-xor", ((-0.55, 1.14), "xor-port-in0"), color: c-fg)
  wire.wire("a-and-v", ((-0.55, 1.14), (-0.55, 0.09)), color: c-fg)
  wire.wire("a-and-h", ((-0.55, 0.09), "and-port-in0"), color: c-fg)
  wire.intersection((-0.55, 1.14), radius: 0.05, fill: c-fg)

  // B → XOR.in1 + AND.in1. Junction at x=-0.85, y=-0.34 (AND.in1 level).
  wire.wire("b-in", ((-2.3, -0.34), (-0.85, -0.34)), color: c-fg)
  wire.wire("b-and", ((-0.85, -0.34), "and-port-in1"), color: c-fg)
  wire.wire("b-xor-v", ((-0.85, -0.34), (-0.85, 0.71)), color: c-fg)
  wire.wire("b-xor-h", ((-0.85, 0.71), "xor-port-in1"), color: c-fg)
  wire.intersection((-0.85, -0.34), radius: 0.05, fill: c-fg)

  // Outputs.
  wire.wire("s-out", ("xor-port-out", (2.2, 0.93)), color: c-fg)
  wire.wire("c-out", ("and-port-out", (2.2, -0.12)), color: c-fg)

  // Labels.
  draw.content((-2.3, 1.14), anchor: "east", $A$)
  draw.content((-2.3, -0.34), anchor: "east", $B$)
  draw.content((2.2, 0.93), anchor: "west", $S$)
  draw.content((2.2, -0.12), anchor: "west", $C$)
})

// ── Full-adder: S = A xor B xor Cin, Cout = (A and B) or (Cin and (A xor B)) ──
// Gate layout (3 columns):
//   Col 1: XOR1 at (0,0.9), AND1 at (0,-0.9)  — span 0.90-1.75, -0.90 to -0.05, gap 0.95
//   Col 2: XOR2 at x=2.9, y=0.9, AND2 at x=2.9, y=-0.1  — no overlap, gap 0.20
//   Col 3: OR   at x=5.8, y=-0.9
// Port y-values (h=0.85): in0=y+0.64, in1=y+0.21, out=y+0.425
//   XOR1: in0=1.54, in1=1.11, out=(1.4, 1.325)
//   AND1: in0=-0.26, in1=-0.69, out=(1.4, -0.475)
//   XOR2: in0=1.54, in1=1.11, out=(4.3, 1.325)
//   AND2: in0=0.54, in1=0.11, out=(4.3, 0.325)
//   OR:   in0=-0.26, in1=-0.69, out=(7.2, -0.475)
#let full-adder = circuit({
  // Column 1 — anchor column.
  element.gate-xor(x: 0, y: 0.9, w: gw, h: gh, id: "xor1", fill: c-gate, stroke: c-str)
  element.gate-and(x: 0, y: -0.9, w: gw, h: gh, id: "and1", fill: c-gate, stroke: c-str)

  // Column 2 — relative to col 1.
  element.gate-xor(x: (rel: 1.5, to: "xor1.east"), y: 0.9, w: gw, h: gh, id: "xor2", fill: c-gate, stroke: c-str)
  element.gate-and(x: (rel: 1.5, to: "and1.east"), y: -0.1, w: gw, h: gh, id: "and2", fill: c-gate, stroke: c-str)

  // Column 3 — relative to col 2.
  element.gate-or(x: (rel: 1.5, to: "and2.east"), y: -0.9, w: gw, h: gh, id: "or1", fill: c-gate, stroke: c-str)

  // ── A → XOR1.in0 (y=1.54) + AND1.in0 (y=-0.26) ──
  let ay = 1.54
  wire.wire("a-in", ((-2.3, ay), (-0.55, ay)), color: c-fg)
  wire.wire("a-xor1", ((-0.55, ay), "xor1-port-in0"), color: c-fg)
  wire.wire("a-and1-v", ((-0.55, ay), (-0.55, -0.26)), color: c-fg)
  wire.wire("a-and1-h", ((-0.55, -0.26), "and1-port-in0"), color: c-fg)
  wire.intersection((-0.55, ay), radius: 0.05, fill: c-fg)

  // ── B → XOR1.in1 (y=1.11) + AND1.in1 (y=-0.69) ──
  wire.wire("b-in", ((-2.3, -0.69), (-0.85, -0.69)), color: c-fg)
  wire.wire("b-and1", ((-0.85, -0.69), "and1-port-in1"), color: c-fg)
  wire.wire("b-xor1-v", ((-0.85, -0.69), (-0.85, 1.11)), color: c-fg)
  wire.wire("b-xor1-h", ((-0.85, 1.11), "xor1-port-in1"), color: c-fg)
  wire.intersection((-0.85, -0.69), radius: 0.05, fill: c-fg)

  // ── XOR1.out (y=1.325) → XOR2.in0 (y=1.54) + AND2.in0 (y=0.54) ──
  let j1 = (2.1, 1.325)
  wire.wire("x1-out", ("xor1-port-out", j1), color: c-fg)
  wire.wire("x1-xor2", (j1, "xor2-port-in0"), color: c-fg)
  wire.wire("x1-and2-v", (j1, (j1.at(0), 0.54)), color: c-fg)
  wire.wire("x1-and2-h", ((j1.at(0), 0.54), "and2-port-in0"), color: c-fg)
  wire.intersection(j1, radius: 0.05, fill: c-fg)

  // ── Cin → XOR2.in1 (y=1.11) + AND2.in1 (y=0.11) ──
  // Cin from left-below, rises between cols 1 and 2.
  let j2 = (2.1, 0.11)
  wire.wire("cin-in", ((-2.3, -1.25), (j2.at(0), -1.25)), color: c-fg)
  wire.wire("cin-up", ((j2.at(0), -1.25), j2), color: c-fg)
  wire.wire("cin-and2", (j2, "and2-port-in1"), color: c-fg)
  wire.wire("cin-xor2-v", (j2, (j2.at(0), 1.11)), color: c-fg)
  wire.wire("cin-xor2-h", ((j2.at(0), 1.11), "xor2-port-in1"), color: c-fg)
  wire.intersection(j2, radius: 0.05, fill: c-fg)

  // ── AND1.out (y=-0.475) → OR.in0 (y=-0.26) ──
  wire.wire("and1-or", ("and1-port-out", "or1-port-in0"), color: c-fg)

  // ── AND2.out (y=0.325) → OR.in1 (y=-0.69) ──
  let j3 = (5.0, 0.325)
  wire.wire("and2-out", ("and2-port-out", j3), color: c-fg)
  wire.wire("and2-or-v", (j3, (j3.at(0), -0.69)), color: c-fg)
  wire.wire("and2-or-h", ((j3.at(0), -0.69), "or1-port-in1"), color: c-fg)

  // ── Outputs ──
  wire.wire("s-out", ("xor2-port-out", (5.3, 1.325)), color: c-fg)
  wire.wire("cout-out", ("or1-port-out", (7.8, -0.475)), color: c-fg)

  // ── Labels ──
  draw.content((-2.3, 1.54), anchor: "east", $A$)
  draw.content((-2.3, -0.69), anchor: "east", $B$)
  draw.content((-2.3, -1.25), anchor: "east", $C_"in"$)
  draw.content((5.3, 1.325), anchor: "west", $S$)
  draw.content((7.8, -0.475), anchor: "west", $C_"out"$)
})
