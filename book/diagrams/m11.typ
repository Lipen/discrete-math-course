#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import "@preview/cetz:0.3.4" as ccetz
#import ccetz: draw
#import circuiteria: circuit, element, wire

#let gw = 1

#let gh = 1

#let ir = 0.07

#let lj(x, port) = (horizontal: (x, 0), vertical: port)

// Логический вентиль в токенах дизайн-системы.
#let gate(kind, x, y, id, ..args) = kind(
  x: x,
  y: y,
  w: gw,
  h: gh,
  id: id,
  fill: c-conn,
  stroke: c-bd + t-bd,
  ..args,
)

// ── Полусумматор ──
#let half-adder = circuit({
  gate(element.gate-xor, 0, 1, "xor")
  gate(element.gate-and, 0, -0.5, "and")

  let aj = lj(-0.5, "xor-port-in0")
  wire.wire("a-in", (lj(-2.0, "xor-port-in0"), aj), color: c-edge)
  wire.wire("a-xor", (aj, "xor-port-in0"), color: c-edge)
  wire.wire(
    "a-and-v",
    (aj, "and-port-in0"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("a-and-v.zig", radius: ir, fill: c-edge)

  let bj = lj(-0.9, "and-port-in1")
  wire.wire("b-in", (lj(-2.0, "and-port-in1"), bj), color: c-edge)
  wire.wire("b-and", (bj, "and-port-in1"), color: c-edge)
  wire.wire(
    "b-xor-v",
    (bj, "xor-port-in1"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection(bj, radius: ir, fill: c-edge)

  wire.wire("s-out", ("xor-port-out", lj(2.0, "xor-port-out")), color: c-edge)
  wire.wire("c-out", ("and-port-out", lj(2.0, "and-port-out")), color: c-edge)

  draw.content(lj(-2.1, "xor-port-in0"), anchor: "east", text(
    size: s-node,
    fill: c-ink,
  )[$A$])
  draw.content(lj(-2.1, "and-port-in1"), anchor: "east", text(
    size: s-node,
    fill: c-ink,
  )[$B$])
  draw.content(lj(2.1, "xor-port-out"), anchor: "west", text(
    size: s-node,
    fill: c-ink,
  )[$S$])
  draw.content(lj(2.1, "and-port-out"), anchor: "west", text(
    size: s-node,
    fill: c-ink,
  )[$C$])
})

// ── Полный сумматор ──
#let full-adder = circuit({
  gate(element.gate-xor, 0, 0.9, "xor1")
  gate(element.gate-and, 0, -0.9, "and1")

  gate(element.gate-xor, (rel: 1.5, to: "xor1.east"), 0.9, "xor2")
  gate(element.gate-and, (rel: 2.5, to: "and1.east"), -0.5, "and2")
  gate(element.gate-or, (rel: 1.5, to: "and2.east"), -0.9, "or1")

  let a1j = lj(-0.5, "xor1-port-in0")
  wire.wire("a-in", (lj(-2.0, "xor1-port-in0"), a1j), color: c-edge)
  wire.wire("a-xor1", (a1j, "xor1-port-in0"), color: c-edge)
  wire.wire(
    "a-and1",
    (a1j, "and1-port-in0"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("a-and1.zig", radius: ir, fill: c-edge)

  let b1j = lj(-0.9, "and1-port-in1")
  wire.wire("b-in", (lj(-2.0, "and1-port-in1"), b1j), color: c-edge)
  wire.wire("b-and1", (b1j, "and1-port-in1"), color: c-edge)
  wire.wire(
    "b-xor1",
    (b1j, "xor1-port-in1"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("b-xor1.zig", radius: ir, fill: c-edge)

  let j1 = lj(2.1, "xor1-port-out")
  wire.wire("x1-out", ("xor1-port-out", j1), color: c-edge)
  wire.wire("x1-xor2", (j1, "xor2-port-in0"), color: c-edge)
  wire.wire(
    "x1-and2",
    (j1, "and2-port-in0"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("x1-and2.zig", radius: ir, fill: c-edge)

  let j2 = lj(2.1, "and2-port-in1")
  wire.wire("cin-in", ((-2.3, -1.25), (2.1, -1.25)), color: c-edge)
  wire.wire("cin-up", ((2.1, -1.25), j2), color: c-edge)
  wire.wire("cin-and2", (j2, "and2-port-in1"), color: c-edge)
  wire.wire(
    "cin-xor2",
    (j2, "xor2-port-in1"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("cin-xor2.zig", radius: ir, fill: c-edge)

  wire.wire(
    "and1-or",
    ("and1-port-out", "or1-port-in0"),
    color: c-edge,
    style: "dodge",
  )

  let j3 = lj(5.0, "and2-port-out")
  wire.wire("and2-out", ("and2-port-out", j3), color: c-edge)
  wire.wire(
    "and2-or",
    (j3, "or1-port-in1"),
    color: c-edge,
    style: "zigzag",
    zigzag-ratio: 0,
  )
  wire.intersection("and2-or.zig", radius: ir, fill: c-edge)

  wire.wire("s-out", ("xor2-port-out", lj(5.3, "xor2-port-out")), color: c-edge)
  wire.wire(
    "cout-out",
    ("or1-port-out", lj(7.8, "or1-port-out")),
    color: c-edge,
  )

  draw.content(lj(-2.1, "xor1-port-in0"), anchor: "east", text(
    size: s-node,
    fill: c-ink,
  )[$A$])
  draw.content(lj(-2.1, "and1-port-in1"), anchor: "east", text(
    size: s-node,
    fill: c-ink,
  )[$B$])
  draw.content((-2.3, -1.25), anchor: "east", text(
    size: s-node,
    fill: c-ink,
  )[$C_"in"$])
  draw.content(lj(5.3, "xor2-port-out"), anchor: "west", text(
    size: s-node,
    fill: c-ink,
  )[$S$])
  draw.content(lj(7.8, "or1-port-out"), anchor: "west", text(
    size: s-node,
    fill: c-ink,
  )[$C_"out"$])
})

// ── Мультиплексор 4→1 ──
#let multiplexer-4to1 = ccetz.canvas({
  draw.line(
    (0, 2.8),
    (5, 1.4),
    (5, -1.4),
    (0, -2.8),
    close: true,
    fill: c-fl,
    stroke: c-bd + t-bd,
  )

  draw.content((2.5, 0.3), text(size: s-node, fill: c-ink)[MUX])
  draw.content((2.5, -0.7), text(size: s-tiny, fill: c-muted)[$4 times 1$])

  let dy = (2.1, 0.7, -0.7, -2.1)
  for (i, y) in dy.enumerate() {
    draw.line((-1.2, y), (0, y), stroke: c-edge + t-ed)
    draw.content((-1.3, y), anchor: "east", text(
      size: s-cap,
      fill: c-ink,
    )[$D_#i$])
  }

  draw.line((5, 0), (6.2, 0), stroke: c-edge + t-ed)
  draw.content((6.3, 0), anchor: "west", text(size: s-cap, fill: c-ink)[$Y$])

  let top-y(x) = 2.8 - 0.28 * x
  draw.line((1.5, top-y(1.5)), (1.5, 3.4), stroke: c-edge + t-ed)
  draw.content((1.5, 3.45), anchor: "south", text(
    size: s-cap,
    fill: c-ink,
  )[$S_0$])
  draw.line((3.5, top-y(3.5)), (3.5, 3.4), stroke: c-edge + t-ed)
  draw.content((3.5, 3.45), anchor: "south", text(
    size: s-cap,
    fill: c-ink,
  )[$S_1$])

  draw.content((2.5, -3.5), text(size: s-tiny, fill: c-muted)[
    $Y = D_((S_1 S_0)_2)$
  ])
})

// ── Функции vs схемы ──
#let functions-vs-circuits = ccetz.canvas({
  let w = 7.0
  let h = 4.2
  draw.rect(
    (-w / 2, -h / 2),
    (w / 2, h / 2),
    fill: c-fl,
    stroke: c-bd + t-bd,
    name: "all",
  )
  draw.content((0, 1.0), text(size: s-cap, fill: c-ink)[все функции])
  draw.content((0, 0.25), text(size: s-node, fill: c-ink)[$2^(2^n)$])

  let sw = 2.8
  let sh = 1.4
  let sx = w / 2 - sw / 2 - 0.5
  let sy = -h / 2 + sh / 2 + 0.6
  draw.rect(
    (sx - sw / 2, sy - sh / 2),
    (sx + sw / 2, sy + sh / 2),
    fill: c-conn,
    stroke: c-bd + t-bd,
    name: "small",
  )
  draw.content((sx, sy + 0.25), text(size: s-tiny, fill: c-ink)[малые схемы])
  draw.content((sx, sy - 0.3), text(size: s-cap, fill: c-ink)[$(c s)^s$])
})

// ── Включение классов ──
#let class-inclusion = ccetz.canvas({
  let all-w = 7.8
  let all-h = 5.0
  draw.rect(
    (-all-w / 2, -all-h / 2),
    (all-w / 2, all-h / 2),
    fill: c-fl,
    stroke: c-bd + t-bd,
    name: "all",
  )
  draw.content((0, 2.1), text(size: s-cap, fill: c-muted)[все языки])

  draw.rect(
    (-2.4, -1.8),
    (3.0, 1.9),
    radius: 12pt,
    fill: c-conn,
    stroke: c-bd + t-bd,
    name: "ppoly",
  )
  draw.content((0.3, 1.45), text(size: s-cap, fill: c-ink)[$"P/poly"$])

  draw.rect(
    (-1.55, -1.05),
    (0.75, 0.65),
    radius: 8pt,
    fill: white,
    stroke: c-bd + t-bd,
    name: "p",
  )
  draw.content((-0.4, -0.2), text(size: s-cap, fill: c-ink)[$P$])

  draw.content((1.8, 0.15), text(size: s-tiny, fill: c-muted)[неразрешимые])
  draw.content((1.8, -0.3), text(size: s-tiny, fill: c-muted)[языки])
})
