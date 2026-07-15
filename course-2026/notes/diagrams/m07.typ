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
  // Input labels — A aligned with XOR top entry, B with AND bottom entry
  lbl((-3, 1.35), $A$, anchor: "east")
  lbl((-3, -0.75), $B$, anchor: "east")

  // Gates
  gate((-0.5, 1.2), "XOR")
  gate((-0.5, -0.6), "AND")

  // Output labels
  lbl((2, 1.2), $S$, anchor: "west")
  lbl((2, -0.6), $C$, anchor: "west")

  // A splits: straight to XOR top, down to AND top
  joint((-2, 1.35))
  wire((-3, 1.35), (-2, 1.35))
  wire((-2, 1.35), (-1.1, 1.35)) // A → XOR top
  wire((-2, 1.35), (-2, -0.45)) // A → down to AND
  wire((-2, -0.45), (-1.1, -0.45)) // A → AND top

  // B splits: straight to AND bottom, up to XOR bottom
  joint((-2.5, -0.75))
  wire((-3, -0.75), (-2.5, -0.75))
  wire((-2.5, -0.75), (-1.1, -0.75)) // B → AND bottom
  wire((-2.5, -0.75), (-2.5, 1.05)) // B → up to XOR
  wire((-2.5, 1.05), (-1.1, 1.05)) // B → XOR bottom

  // Gate outputs
  wire((0.1, 1.2), (2, 1.2)) // XOR → S
  wire((0.1, -0.6), (2, -0.6)) // AND → C
})

// ── Full-adder: S = A xor B xor Cin, Cout = (A and B) or (Cin and (A xor B)) ──
#let full-adder = canvas({
  // Inputs: A, B on left; Cin below
  lbl((-3.5, 3.5), $A$, anchor: "east")
  lbl((-3.5, 2.8), $B$, anchor: "east")
  lbl((-1, -1.5), $C_"in"$, anchor: "north")

  // Row 1 (y=3.5): XOR1 → XOR2 → S
  gate((-0.5, 3.5), "XOR")
  gate((2.5, 3.5), "XOR")
  lbl((5.5, 3.5), $S$, anchor: "west")

  // Row 2 (y=1.0): AND1, AND2
  gate((-0.5, 1.0), "AND")
  gate((2.5, 1.0), "AND")

  // Row 3 (y=-1.5): OR → Cout
  gate((2.5, -1.5), "OR")
  lbl((5.5, -1.5), $C_"out"$, anchor: "west")

  // ── A routing ──
  wire((-3.5, 3.5), (-1.1, 3.5))            // A → XOR1
  joint((-1.5, 3.5))
  wire((-1.5, 3.5), (-1.5, 1.4))             // A ↓ to AND1 level
  wire((-1.5, 1.4), (-1.1, 1.4))             // A → AND1 top

  // ── B routing ──
  wire((-3.5, 2.8), (-3.5, 2.5))             // B right a bit
  joint((-2.5, 2.5))
  wire((-2.5, 2.5), (-2.5, 3.2))             // B ↑ to XOR1 level
  wire((-2.5, 3.2), (-1.1, 3.2))             // B → XOR1 bottom
  wire((-2.5, 2.5), (-2.5, 0.6))             // B ↓ to AND1 level
  wire((-2.5, 0.6), (-1.1, 0.6))             // B → AND1 bottom

  // ── XOR1 output → XOR2 + tap down to AND2 ──
  wire((0.1, 3.5), (1.9, 3.5))               // XOR1 → XOR2
  joint((1.0, 3.5))
  wire((1.0, 3.5), (1.0, 1.4))               // ↓ to AND2 level
  wire((1.0, 1.4), (1.9, 1.4))               // → AND2 top

  // ── Cin routing: horizontal under gates, then up ──
  wire((-1, -1.5), (1.0, -1.5))              // Cin → under gate column
  joint((1.0, -1.5))
  wire((1.0, -1.5), (1.0, 0.6))              // ↑ to AND2 level
  wire((1.0, 0.6), (1.9, 0.6))               // → AND2 bottom
  wire((1.0, -1.5), (1.9, -1.5))             // → OR bottom

  // ── AND1 output → OR top ──
  wire((0.1, 1.0), (1.9, -1.1))              // diagonal into OR top

  // ── AND2 output → OR ──
  wire((3.1, 1.0), (3.1, -1.1))              // vertical into OR center

  // ── XOR2 output → S ──
  wire((3.1, 3.5), (5.5, 3.5))
})
