// M07 diagrams — adder circuits.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-gate = oklch(88%, 0.03, 250deg)
#let c-fg = oklch(35%, 0.02, 265deg)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

#let gate(pos, label, width: 1.2, height: 0.8) = {
  let (x, y) = pos
  let hw = width / 2
  let hh = height / 2
  draw.rect((x - hw, y - hh), (x + hw, y + hh), fill: c-gate, stroke: c-str)
  draw.content((x, y), text(size: 0.7em, weight: "bold")[#label])
}

#let wire(from, to) = draw.line(from, to, stroke: c-str)
#let joint(at) = draw.circle(at, radius: 0.04, fill: c-fg)

#let lbl(pos, body, ..args) = draw.content(pos, text(size: 0.8em, body), ..args)

// ── Half-adder: S = A xor B, C = A and B ──
#let half-adder = canvas({
  // Input labels
  lbl((-3, 1.2), $A$, anchor: "east")
  lbl((-3, -0.6), $B$, anchor: "east")

  // Gates
  gate((-0.5, 1.2), "XOR")
  gate((-0.5, -0.6), "AND")

  // Output labels
  lbl((2, 1.2), $S$, anchor: "west")
  lbl((2, -0.6), $C$, anchor: "west")

  // A splits independently to XOR (upper entry) and AND (upper entry)
  joint((-2, 1.2))
  wire((-3, 1.2), (-2, 1.2))
  wire((-2, 1.2), (-1.1, 1.35)) // A → XOR top
  wire((-2, 1.2), (-2, -0.45)) // A → down to AND
  wire((-2, -0.45), (-1.1, -0.45)) // A → AND top

  // B splits independently to XOR (lower entry) and AND (lower entry)
  joint((-2.5, -0.6))
  wire((-3, -0.6), (-2.5, -0.6))
  wire((-2.5, -0.6), (-2.5, 1.05)) // B → up to XOR
  wire((-2.5, 1.05), (-1.1, 1.05)) // B → XOR bottom
  wire((-2.5, -0.6), (-1.1, -0.75)) // B → AND bottom

  // Gate outputs
  wire((0.1, 1.2), (2, 1.2)) // XOR → S
  wire((0.1, -0.6), (2, -0.6)) // AND → C
})

// ── Full-adder ──
#let full-adder = canvas({
  // Inputs
  lbl((-4, 2.5), $A$, anchor: "east")
  lbl((-4, 1), $B$, anchor: "east")
  lbl((-4, -0.5), $C_"in"$, anchor: "east")

  // Gates — row 1: first XOR and first AND
  gate((-1, 2.5), "XOR")
  gate((-1, 1), "AND")

  // Gates — row 2: second XOR, second AND, OR
  gate((1.5, 2.5), "XOR")
  gate((1.5, 0.2), "AND")
  gate((4, 1), "OR")

  // Outputs
  lbl((6.5, 2.5), $S$, anchor: "west")
  lbl((6.5, 1), $C_"out"$, anchor: "west")

  // Input splitting: A and B go to XOR1 and AND1
  joint((-2, 2.5))
  wire((-4, 2.5), (-2, 2.5))
  wire((-2, 2.5), (-1.6, 2.5)) // A → XOR1
  wire((-2, 2.5), (-2, 1)) // A → down to AND1 branch
  wire((-2, 1), (-1.6, 1)) // A → AND1

  joint((-2.5, 1))
  wire((-4, 1), (-2.5, 1))
  wire((-2.5, 1), (-2.5, 2.5)) // B → XOR1
  wire((-2.5, 2.5), (-1.6, 2.5)) // B → XOR1
  wire((-2.5, 1), (-1.6, 1)) // B → AND1

  // XOR1 output → XOR2 (straight line, same y-level)
  wire((-0.4, 2.5), (0.9, 2.5))

  // XOR1 output also taps down to AND2
  joint((0.5, 2.5))
  wire((0.5, 2.5), (0.5, 0.2)) // down to AND2 level
  wire((0.5, 0.2), (0.9, 0.2)) // into AND2

  // Cin enters from left, routes horizontally, then splits up
  joint((-2, -0.5))
  wire((-4, -0.5), (-2, -0.5))
  wire((-2, -0.5), (0.9, -0.5)) // horizontal run
  wire((0.9, -0.5), (0.9, 0.2)) // up → AND2
  wire((0.9, -0.5), (0.9, 2.5)) // up → XOR2

  // XOR2 output → S
  wire((2.1, 2.5), (6.5, 2.5))

  // AND1 → OR (level 1)
  wire((-0.4, 1), (3.4, 1))
  // AND2 → OR (up from 0.2 to 1)
  joint((2.1, 0.2))
  wire((2.1, 0.2), (2.1, 1))
  wire((2.1, 1), (3.4, 1))
  // OR → Cout
  wire((4.6, 1), (6.5, 1))
})
