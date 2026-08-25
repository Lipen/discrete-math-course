// m11 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import "@preview/cetz:0.3.4" as ccetz
#import ccetz: draw
#import circuiteria: circuit, element, wire

#let c-gate = oklch(88%, 0.03, 250deg)

#let c-fg = oklch(35%, 0.02, 265deg)

#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

#let gw = 1

#let gh = 1

#let ir = 0.07

#let lj(x, port) = (horizontal: (x, 0), vertical: port)

#let half-adder = circuit({
  element.gate-xor(
    x: 0,
    y: 1,
    w: gw,
    h: gh,
    id: "xor",
    fill: c-gate,
    stroke: c-str,
  )
  element.gate-and(
    x: 0,
    y: -.5,
    w: gw,
    h: gh,
    id: "and",
    fill: c-gate,
    stroke: c-str,
  )

  // A -> XOR.in0 + AND.in0.
  let aj = lj(-0.5, "xor-port-in0")
  wire.wire("a-in", (lj(-2.0, "xor-port-in0"), aj), color: c-fg)
  wire.wire("a-xor", (aj, "xor-port-in0"), color: c-fg)
  wire.wire(
    "a-and-v",
    (aj, "and-port-in0"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("a-and-v.zig", radius: ir, fill: c-fg)

  // B -> XOR.in1 + AND.in1.
  let bj = lj(-0.9, "and-port-in1")
  wire.wire("b-in", (lj(-2.0, "and-port-in1"), bj), color: c-fg)
  wire.wire("b-and", (bj, "and-port-in1"), color: c-fg)
  wire.wire(
    "b-xor-v",
    (bj, "xor-port-in1"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection(bj, radius: ir, fill: c-fg)

  // Outputs.
  wire.wire("s-out", ("xor-port-out", lj(2.0, "xor-port-out")), color: c-fg)
  wire.wire("c-out", ("and-port-out", lj(2.0, "and-port-out")), color: c-fg)

  // Labels.
  draw.content(lj(-2.1, "xor-port-in0"), anchor: "east", $A$)
  draw.content(lj(-2.1, "and-port-in1"), anchor: "east", $B$)
  draw.content(lj(2.1, "xor-port-out"), anchor: "west", $S$)
  draw.content(lj(2.1, "and-port-out"), anchor: "west", $C$)
})

#let full-adder = circuit({
  // Column 1 --- anchor column.
  element.gate-xor(
    x: 0,
    y: 0.9,
    w: gw,
    h: gh,
    id: "xor1",
    fill: c-gate,
    stroke: c-str,
  )
  element.gate-and(
    x: 0,
    y: -0.9,
    w: gw,
    h: gh,
    id: "and1",
    fill: c-gate,
    stroke: c-str,
  )

  // Column 2 --- relative to col 1.
  element.gate-xor(
    x: (rel: 1.5, to: "xor1.east"),
    y: 0.9,
    w: gw,
    h: gh,
    id: "xor2",
    fill: c-gate,
    stroke: c-str,
  )
  element.gate-and(
    x: (rel: 2.5, to: "and1.east"),
    y: -0.5,
    w: gw,
    h: gh,
    id: "and2",
    fill: c-gate,
    stroke: c-str,
  )

  // Column 3 --- relative to col 2.
  element.gate-or(
    x: (rel: 1.5, to: "and2.east"),
    y: -0.9,
    w: gw,
    h: gh,
    id: "or1",
    fill: c-gate,
    stroke: c-str,
  )

  // ── A -> XOR1.in0 + AND1.in0 ──
  let a1j = lj(-0.5, "xor1-port-in0")
  wire.wire("a-in", (lj(-2.0, "xor1-port-in0"), a1j), color: c-fg)
  wire.wire("a-xor1", (a1j, "xor1-port-in0"), color: c-fg)
  wire.wire(
    "a-and1",
    (a1j, "and1-port-in0"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("a-and1.zig", radius: ir, fill: c-fg)

  // ── B -> XOR1.in1 + AND1.in1 ──
  let b1j = lj(-0.9, "and1-port-in1")
  wire.wire("b-in", (lj(-2.0, "and1-port-in1"), b1j), color: c-fg)
  wire.wire("b-and1", (b1j, "and1-port-in1"), color: c-fg)
  wire.wire(
    "b-xor1",
    (b1j, "xor1-port-in1"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("b-xor1.zig", radius: ir, fill: c-fg)

  // ── XOR1.out -> XOR2.in0 + AND2.in0 ──
  let j1 = lj(2.1, "xor1-port-out")
  wire.wire("x1-out", ("xor1-port-out", j1), color: c-fg)
  wire.wire("x1-xor2", (j1, "xor2-port-in0"), color: c-fg)
  wire.wire(
    "x1-and2",
    (j1, "and2-port-in0"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("x1-and2.zig", radius: ir, fill: c-fg)

  // ── Cin -> XOR2.in1 + AND2.in1 ──
  let j2 = lj(2.1, "and2-port-in1")
  wire.wire("cin-in", ((-2.3, -1.25), (2.1, -1.25)), color: c-fg)
  wire.wire("cin-up", ((2.1, -1.25), j2), color: c-fg)
  wire.wire("cin-and2", (j2, "and2-port-in1"), color: c-fg)
  wire.wire(
    "cin-xor2",
    (j2, "xor2-port-in1"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("cin-xor2.zig", radius: ir, fill: c-fg)

  // ── AND1.out -> OR.in0 ──
  wire.wire(
    "and1-or",
    ("and1-port-out", "or1-port-in0"),
    color: c-fg,
    style: "dodge",
  )

  // ── AND2.out -> OR.in1 ──
  let j3 = lj(5.0, "and2-port-out")
  wire.wire("and2-out", ("and2-port-out", j3), color: c-fg)
  wire.wire(
    "and2-or",
    (j3, "or1-port-in1"),
    color: c-fg,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("and2-or.zig", radius: ir, fill: c-fg)

  // ── Outputs ──
  wire.wire("s-out", ("xor2-port-out", lj(5.3, "xor2-port-out")), color: c-fg)
  wire.wire("cout-out", ("or1-port-out", lj(7.8, "or1-port-out")), color: c-fg)

  // ── Labels ──
  draw.content(lj(-2.1, "xor1-port-in0"), anchor: "east", $A$)
  draw.content(lj(-2.1, "and1-port-in1"), anchor: "east", $B$)
  draw.content((-2.3, -1.25), anchor: "east", $C_"in"$)
  draw.content(lj(5.3, "xor2-port-out"), anchor: "west", $S$)
  draw.content(lj(7.8, "or1-port-out"), anchor: "west", $C_"out"$)
})

#let multiplexer-4to1 = ccetz.canvas({

  let c-body = oklch(90%, 0.03, 250deg)
  let c-str = oklch(35%, 0.02, 265deg) + 0.7pt
  let c-label = oklch(35%, 0.02, 265deg)

  draw.rect((0, 2.8), (5, -2.8), fill: c-body, stroke: none, radius: 2pt)
  // Trapezoid outline
  draw.line((0, 2.8), (5, 1.4), stroke: c-str)
  draw.line((5, 1.4), (5, -1.4), stroke: c-str)
  draw.line((5, -1.4), (0, -2.8), stroke: c-str)
  draw.line((0, -2.8), (0, 2.8), stroke: c-str)

  // Internal label
  draw.content((2.2, 0.2), text(size: 0.7em, fill: c-label)[MUX])
  draw.content((2.2, -0.8), text(size: 0.55em, fill: oklch(45%, 0.02, 265deg))[$4 times 1$])

  // Data inputs D0..D3 on the left
  let dy = (2.1, 0.7, -0.7, -2.1)
  for (i, y) in dy.enumerate() {
    draw.line((-1.2, y), (0, y), stroke: c-str)
    draw.content((-1.3, y), anchor: "east", text(size: 0.7em, fill: c-label)[$D_#i$])
  }

  // Output Y on the right
  draw.line((5, 0), (6.2, 0), stroke: c-str)
  draw.content((6.3, 0), anchor: "west", text(size: 0.7em, fill: c-label)[$Y$])

  // Select lines S0, S1 from top
  draw.line((1.5, 2.8), (1.5, 3.8), stroke: c-str)
  draw.content((1.5, 3.9), anchor: "south", text(size: 0.65em, fill: c-label)[$S_0$])
  draw.line((3.5, 2.8), (3.5, 3.8), stroke: c-str)
  draw.content((3.5, 3.9), anchor: "south", text(size: 0.65em, fill: c-label)[$S_1$])

  // Formula below
  draw.content((2.5, -3.4), text(size: 0.55em, fill: oklch(45%, 0.02, 265deg))[
    $Y = D_((S_1 S_0)_2)$
  ])
})

#let cs-func-fill = oklch(96%, 0.02, 265deg)   // все функции

#let cs-func-str = 0.8pt + oklch(35%, 0.02, 265deg)

#let cs-small-fill = oklch(88%, 0.06, 250deg)  // функции с малой схемой

#let cs-label = oklch(30%, 0.02, 265deg)

#let cs-dim = oklch(58%, 0.02, 265deg)

#let functions-vs-circuits = ccetz.canvas({
  let w = 7.0
  let h = 4.2
  draw.rect(
    (-w / 2, -h / 2),
    (w / 2, h / 2),
    fill: cs-func-fill,
    stroke: cs-func-str,
    name: "all",
  )
  draw.content((0, 1.0), text(size: 0.62em, fill: cs-label)[все функции])
  draw.content((0, 0.25), text(size: 0.72em, fill: cs-label)[$2^(2^n)$])

  let sw = 2.8
  let sh = 1.4
  let sx = w / 2 - sw / 2 - 0.5
  let sy = -h / 2 + sh / 2 + 0.6
  draw.rect(
    (sx - sw / 2, sy - sh / 2),
    (sx + sw / 2, sy + sh / 2),
    fill: cs-small-fill,
    stroke: cs-func-str,
    name: "small",
  )
  draw.content((sx, sy + 0.25), text(size: 0.52em, fill: cs-label)[малые схемы])
  draw.content((sx, sy - 0.3), text(size: 0.62em, fill: cs-label)[$(c s)^s$])
})

#let class-inclusion = ccetz.canvas({
  let all-w = 7.8
  let all-h = 5.0
  draw.rect(
    (-all-w / 2, -all-h / 2),
    (all-w / 2, all-h / 2),
    fill: oklch(97%, 0.01, 265deg),
    stroke: cs-func-str,
    name: "all",
  )
  draw.content((0, all-h / 2 - 0.45), text(
    size: 0.62em,
    fill: cs-dim,
  )[все языки])

  draw.rect(
    (-2.4, -1.8),
    (3.0, 2.0),
    radius: 12pt,
    fill: oklch(92%, 0.05, 250deg),
    stroke: cs-func-str,
    name: "ppoly",
  )
  draw.content((0.3, 1.35), text(size: 0.68em, fill: cs-label)[$"P/poly"$])

  draw.rect(
    (-1.55, -1.05),
    (0.75, 0.65),
    radius: 8pt,
    fill: white,
    stroke: cs-func-str,
    name: "p",
  )
  draw.content((-0.4, -0.2), text(size: 0.68em, fill: cs-label)[$P$])

  draw.content((1.8, 0.15), text(size: 0.5em, fill: cs-label)[неразрешимые])
  draw.content((1.8, -0.3), text(size: 0.5em, fill: cs-label)[языки])
})
