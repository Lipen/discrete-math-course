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
#let gw = 1.3
#let gh = 0.85

// ── Half-adder: S = A xor B, C = A and B ──
#let half-adder = circuit({
  // Gates: XOR (top), AND (bottom).
  element.gate-xor(x: 0, y: 0.35, w: gw, h: gh, id: "xor", fill: c-gate, stroke: c-str)
  element.gate-and(x: 0, y: -0.4, w: gw, h: gh, id: "and", fill: c-gate, stroke: c-str)

  // A → XOR.in0 (top) + AND.in0 (top).
  // Port y: XOR.in0≈0.99, AND.in0≈0.24. Junction at x=-0.55.
  wire.wire("a-in", ((-2.3, 0.99), (-0.55, 0.99)), color: c-fg)
  wire.wire("a-xor", ((-0.55, 0.99), "xor-port-in0"), color: c-fg)
  wire.wire("a-and-v", ((-0.55, 0.99), (-0.55, 0.24)), color: c-fg)
  wire.wire("a-and-h", ((-0.55, 0.24), "and-port-in0"), color: c-fg)
  wire.intersection((-0.55, 0.99), radius: 0.05, fill: c-fg)

  // B → XOR.in1 (bottom) + AND.in1 (bottom).
  // Port y: XOR.in1≈0.56, AND.in1≈-0.19. Junction at x=-0.85.
  wire.wire("b-in", ((-2.3, -0.19), (-0.85, -0.19)), color: c-fg)
  wire.wire("b-and", ((-0.85, -0.19), "and-port-in1"), color: c-fg)
  wire.wire("b-xor-v", ((-0.85, -0.19), (-0.85, 0.56)), color: c-fg)
  wire.wire("b-xor-h", ((-0.85, 0.56), "xor-port-in1"), color: c-fg)
  wire.intersection((-0.85, -0.19), radius: 0.05, fill: c-fg)

  // Outputs.
  wire.wire("s-out", ("xor-port-out", (2.1, 0.78)), color: c-fg)
  wire.wire("c-out", ("and-port-out", (2.1, 0.03)), color: c-fg)

  // Labels.
  draw.content((-2.3, 0.99), anchor: "east", $A$)
  draw.content((-2.3, -0.19), anchor: "east", $B$)
  draw.content((2.1, 0.78), anchor: "west", $S$)
  draw.content((2.1, 0.03), anchor: "west", $C$)
})

// ── Full-adder: S = A xor B xor Cin, Cout = (A and B) or (Cin and (A xor B)) ──
#let full-adder = circuit({
  // Column 1: XOR1 (anchor), AND1.
  element.gate-xor(x: 0, y: 0.8, w: gw, h: gh, id: "xor1", fill: c-gate, stroke: c-str)
  element.gate-and(x: 0, y: -0.8, w: gw, h: gh, id: "and1", fill: c-gate, stroke: c-str)

  // Column 2: XOR2, AND2 — relative to column 1.
  element.gate-xor(x: (rel: 1.5, to: "xor1.east"), y: 0.8, w: gw, h: gh, id: "xor2", fill: c-gate, stroke: c-str)
  element.gate-and(x: (rel: 1.5, to: "and1.east"), y: -0.15, w: gw, h: gh, id: "and2", fill: c-gate, stroke: c-str)

  // Column 3: OR — relative to column 2.
  element.gate-or(x: (rel: 1.5, to: "and2.east"), y: -0.8, w: gw, h: gh, id: "or1", fill: c-gate, stroke: c-str)

  // ── A → XOR1.in0 + AND1.in0 ──
  // XOR1.in0.y≈1.44, AND1.in0.y≈-0.16.
  wire.wire("a-in", ((-2.3, 1.44), (-0.55, 1.44)), color: c-fg)
  wire.wire("a-xor1", ((-0.55, 1.44), "xor1-port-in0"), color: c-fg)
  wire.wire("a-and1-v", ((-0.55, 1.44), (-0.55, -0.16)), color: c-fg)
  wire.wire("a-and1-h", ((-0.55, -0.16), "and1-port-in0"), color: c-fg)
  wire.intersection((-0.55, 1.44), radius: 0.05, fill: c-fg)

  // ── B → XOR1.in1 + AND1.in1 ──
  // XOR1.in1.y≈1.01, AND1.in1.y≈-0.59.
  wire.wire("b-in", ((-2.3, -0.59), (-0.85, -0.59)), color: c-fg)
  wire.wire("b-and1", ((-0.85, -0.59), "and1-port-in1"), color: c-fg)
  wire.wire("b-xor1-v", ((-0.85, -0.59), (-0.85, 1.01)), color: c-fg)
  wire.wire("b-xor1-h", ((-0.85, 1.01), "xor1-port-in1"), color: c-fg)
  wire.intersection((-0.85, -0.59), radius: 0.05, fill: c-fg)

  // ── XOR1.out → XOR2.in0 + AND2.in0 ──
  // XOR1.out at ~(1.3, 1.22). Junction between cols 1 and 2.
  let j1 = (1.95, 1.22)
  wire.wire("x1-out", ("xor1-port-out", j1), color: c-fg)
  wire.wire("x1-xor2", (j1, "xor2-port-in0"), color: c-fg)
  wire.wire("x1-and2-v", (j1, (j1.at(0), 0.49)), color: c-fg)
  wire.wire("x1-and2-h", ((j1.at(0), 0.49), "and2-port-in0"), color: c-fg)
  wire.intersection(j1, radius: 0.05, fill: c-fg)

  // ── Cin → XOR2.in1 + AND2.in1 ──
  // XOR2.in1.y≈1.01, AND2.in1.y≈0.06. Cin from below, rises between cols 1-2.
  let j2 = (1.95, 0.06)
  wire.wire("cin-in", ((-2.3, -1.25), (j2.at(0), -1.25)), color: c-fg)
  wire.wire("cin-up", ((j2.at(0), -1.25), j2), color: c-fg)
  wire.wire("cin-and2", (j2, "and2-port-in1"), color: c-fg)
  wire.wire("cin-xor2-v", (j2, (j2.at(0), 1.01)), color: c-fg)
  wire.wire("cin-xor2-h", ((j2.at(0), 1.01), "xor2-port-in1"), color: c-fg)
  wire.intersection(j2, radius: 0.05, fill: c-fg)

  // ── AND1.out → OR.in0 ──
  wire.wire("and1-or", ("and1-port-out", "or1-port-in0"), color: c-fg)

  // ── AND2.out → OR.in1 ──
  // AND2.out at ~(3.95, 0.27). Route: out → right → down → OR.in1.
  let j3 = (4.58, 0.27)
  wire.wire("and2-out", ("and2-port-out", j3), color: c-fg)
  wire.wire("and2-or-v", (j3, (j3.at(0), -0.55)), color: c-fg)
  wire.wire("and2-or-h", ((j3.at(0), -0.55), "or1-port-in1"), color: c-fg)

  // ── Outputs ──
  wire.wire("s-out", ("xor2-port-out", (4.7, 1.22)), color: c-fg)
  wire.wire("cout-out", ("or1-port-out", (7.4, -0.37)), color: c-fg)

  // ── Labels ──
  draw.content((-2.3, 1.44), anchor: "east", $A$)
  draw.content((-2.3, -0.59), anchor: "east", $B$)
  draw.content((-2.3, -1.25), anchor: "east", $C_"in"$)
  draw.content((4.7, 1.22), anchor: "west", $S$)
  draw.content((7.4, -0.37), anchor: "west", $C_"out"$)
})
