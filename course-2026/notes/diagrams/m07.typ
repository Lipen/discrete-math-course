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
  // Inputs
  lbl((-4, 2.8), $A$, anchor: "east")
  lbl((-4, 2.2), $B$, anchor: "east")
  lbl((-4, -0.5), $C_"in"$, anchor: "east")

  // Gates
  gate((-1, 2.5), "XOR")
  gate((-1, 0.8), "AND")
  gate((2, 2.5), "XOR")
  gate((2, 0.3), "AND")
  gate((4.5, 1.5), "OR")

  // Outputs
  lbl((7.5, 2.5), $S$, anchor: "west")
  lbl((7.5, 1.5), $C_"out"$, anchor: "west")

  // A: to XOR1 top (y=2.8) and AND1 top (y=1.1)
  joint((-2, 2.8))
  wire((-4, 2.8), (-2, 2.8))
  wire((-2, 2.8), (-1.6, 2.8))   // A → XOR1 top
  wire((-2, 2.8), (-2, 1.1))      // A → down
  wire((-2, 1.1), (-1.6, 1.1))    // A → AND1 top

  // B: to XOR1 bottom (y=2.2) and AND1 bottom (y=0.5)
  joint((-2.5, 2.2))
  wire((-4, 2.2), (-2.5, 2.2))
  wire((-2.5, 2.2), (-1.6, 2.2))  // B → XOR1 bottom
  wire((-2.5, 2.2), (-2.5, 0.5))  // B → down
  wire((-2.5, 0.5), (-1.6, 0.5))  // B → AND1 bottom

  // XOR1 output → XOR2
  wire((-0.4, 2.5), (1.4, 2.5))

  // XOR1 output also tapped down to AND2 (top entry, y=0.6)
  joint((0.8, 2.5))
  wire((0.8, 2.5), (0.8, 0.6))
  wire((0.8, 0.6), (1.4, 0.6))

  // Cin: horizontal across, then up to AND2 bottom and XOR2 bottom
  joint((-2, -0.5))
  wire((-4, -0.5), (-2, -0.5))
  wire((-2, -0.5), (1.4, -0.5))   // horizontal run
  wire((1.4, -0.5), (1.4, 0.0))   // up → AND2 bottom
  wire((1.4, -0.5), (1.4, 2.2))   // up → XOR2 bottom

  // XOR2 output → S
  wire((2.6, 2.5), (7.5, 2.5))

  // AND1 output → OR top
  wire((-0.4, 0.8), (3.9, 1.8))

  // AND2 output → OR bottom (up from 0.3)
  joint((2.6, 0.3))
  wire((2.6, 0.3), (2.6, 1.2))
  wire((2.6, 1.2), (3.9, 1.2))

  // OR → Cout
  wire((5.1, 1.5), (7.5, 1.5))
})
