// m14 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import circuiteria: circuit, element, wire

#let d-node = oklch(88%, 0.03, 250deg)

#let d-node-str = oklch(60%, 0.08, 250deg) + 0.6pt

#let d-text = oklch(30%, 0.02, 265deg)

#let d-muted = oklch(55%, 0.02, 265deg)

#let d-edge = oklch(35%, 0.02, 265deg) + 0.8pt

#let d-edge-thick = oklch(35%, 0.02, 265deg) + 1.0pt

#let d-neg = oklch(58%, 0.20, 22deg)

#let d-sat = oklch(88%, 0.05, 250deg)

#let d-theory = oklch(88%, 0.05, 155deg)

#let d-merge = oklch(88%, 0.05, 155deg)

#let d-conflict = oklch(58%, 0.20, 22deg)

#let cnode(pos, label, fill: d-node) = {
  draw.circle(pos, radius: 0.42, fill: fill, stroke: d-node-str)
  draw.content(pos, text(size: 0.68em, fill: d-text)[#label])
}

#let dpll-t-architecture = canvas({
  // SAT solver box (top): boolean skeleton + CDCL search.
  draw.rect((-2.7, 0.55), (2.7, 1.65), fill: d-sat, stroke: d-node-str, radius: 3pt)
  draw.content((0, 1.3), text(size: 0.72em, fill: d-text, weight: "bold")[SAT-решатель])
  draw.content((0, 0.95), text(size: 0.58em, fill: d-muted)[DPLL / CDCL])

  // Theory solver box (bottom): checks consistency of theory atoms.
  draw.rect((-2.7, -1.65), (2.7, -0.55), fill: d-theory, stroke: d-node-str, radius: 3pt)
  draw.content((0, -0.95), text(size: 0.72em, fill: d-text, weight: "bold")[Theory-солвер])
  draw.content((0, -1.3), text(size: 0.58em, fill: d-muted)[DL, EUF, LRA, ...])

  // SAT -> theory: candidate model.
  draw.line((1.7, 0.55), (1.7, -0.55), mark: (end: "stealth"), stroke: d-edge)
  draw.content((2.15, 0), anchor: "west", text(size: 0.58em, fill: d-text)[кандидат-модель])

  // Theory -> SAT: conflict clause (T-lemma).
  draw.line((-1.7, -0.55), (-1.7, 0.55), mark: (end: "stealth"), stroke: d-edge)
  draw.content((-2.15, 0), anchor: "east", text(size: 0.58em, fill: d-text)[$T$-лемма])
})

#let dl-negative-cycle = canvas({
  // Number line: variables are positions on the axis, constraints are offsets.
  let ax-y = 0
  let d-guide = (paint: d-muted, thickness: 0.5pt, dash: "dashed")
  let d-red-guide = (paint: d-neg, thickness: 0.6pt, dash: "dashed")

  // Tick mark + numeric label on the axis.
  let tick(v) = {
    draw.line((v, ax-y), (v, ax-y - 0.14), stroke: d-text + 0.7pt)
    draw.content((v, ax-y - 0.5), text(size: 0.62em, fill: d-muted)[#v])
  }

  // Variable point on the axis: filled = anchored, open = hypothesized.
  let vpoint(pos, label, open: false) = {
    draw.circle(pos, radius: 0.16,
      fill: if open { white } else { d-text },
      stroke: if open { (paint: d-neg, thickness: 0.7pt, dash: "dashed") } else { d-text })
    draw.content((pos.at(0), pos.at(1) + 0.42), anchor: "south",
      text(size: 0.72em, fill: d-text, weight: "bold")[#label])
  }

  // Dashed vertical guide from an axis position up to a given height.
  let guide(px, py, stroke: d-guide) = draw.line((px, ax-y), (px, py), stroke: stroke)

  // Axis with arrowhead; integer ticks 0..5.
  draw.line((-2.0, ax-y), (5.9, ax-y), mark: (end: "stealth"), stroke: d-edge)
  for v in range(6) { tick(v) }

  // x anchored at position 0.
  vpoint((0, ax-y), $x$)

  // z >= x + 3: z must lie at least 3 units right of x; allowed region [3, +oo).
  draw.line((0, 1.0), (3, 1.0), name: "zspan", stroke: d-edge-thick)
  draw.line((3, 0.82), (3, 1.18), stroke: d-edge-thick)             // closed cap at 3
  draw.line((3, 1.0), (5.5, 1.0), mark: (end: "stealth"), stroke: d-edge-thick)
  draw.content((1.5, 1.45), text(size: 0.66em, fill: d-text)[$z >= x + 3$])
  draw.content((4.4, 0.7), anchor: "west", text(size: 0.6em, fill: d-muted)[разрешено $z >= 3$])
  guide(3.5, 1.0)
  vpoint((3.5, ax-y), [z?], open: true)

  // w >= z + 1: w must lie at least 1 unit right of z; sample z = 3.5 forces w >= 4.5.
  draw.line((3.5, 1.9), (4.5, 1.9), name: "wspan", mark: (end: "stealth"), stroke: d-edge-thick)
  draw.content((3.25, 2.25), anchor: "east", text(size: 0.66em, fill: d-text)[$w >= z + 1$])
  guide(4.5, 2.8, stroke: d-red-guide)                                 // w's required position
  vpoint((4.5, ax-y), [w?], open: true)

  // w <= x + 2 (RED): w allowed only in (-oo, 2]; required w >= 4.5 falls outside.
  draw.line((-2.0, 2.8), (2, 2.8), name: "wcap", stroke: d-neg + 1.2pt)
  draw.line((-2.0, 2.8), (-2.9, 2.8), mark: (end: "stealth"), stroke: d-neg + 1.2pt)
  draw.line((2, 2.62), (2, 2.98), stroke: d-neg + 1.2pt)               // closed cap at 2
  draw.content((0.1, 3.2), text(size: 0.66em, fill: d-neg, weight: "bold")[$w <= x + 2$])
  draw.content((0.1, 2.45), anchor: "north", text(size: 0.6em, fill: d-neg)[разрешено $w <= 2$])
  draw.content((3.3, 2.8), text(size: 1.0em, fill: d-neg, weight: "bold")[✗])
  draw.content((3.3, 3.25), anchor: "south", text(size: 0.66em, fill: d-neg, weight: "bold")[противоречие])

  // Summary: the cycle accumulates to a negative value.
  draw.content((1.6, -1.5), text(size: 0.68em, fill: d-neg, weight: "bold")[
    требуется $w >= 4.5$, но разрешено $w <= 2$ ⟹ $-3 - 1 + 2 = -2 < 0$
  ])
})

#let congruence-closure-merge = canvas({
  // Stage 1: two initial equivalence classes sharing b.
  draw.rect((-3.8, 2.6), (-0.2, 3.6), fill: d-node, stroke: d-node-str, radius: 3pt)
  cnode((-2.7, 3.1), $a$)
  cnode((-1.3, 3.1), $b$)
  draw.content((-2.0, 4.05), anchor: "south", text(size: 0.62em, fill: d-text, weight: "bold")[класс ${a, b}$])

  draw.rect((0.2, 2.6), (3.8, 3.6), fill: d-node, stroke: d-node-str, radius: 3pt)
  cnode((1.3, 3.1), $f(a)$)
  cnode((2.7, 3.1), $b$)
  draw.content((2.0, 4.05), anchor: "south", text(size: 0.62em, fill: d-text, weight: "bold")[класс ${f(a), b}$])

  // Merge arrow: the shared element b glues the two classes together.
  draw.line((0, 2.6), (0, 2.2), stroke: d-edge, mark: (end: "stealth"))
  draw.content((0.25, 2.4), anchor: "west", text(size: 0.58em, fill: d-muted)[слияние])

  // Stage 2: merged class {a, b, f(a)}.
  draw.rect((-2.9, 0.8), (2.9, 2.0), fill: d-merge, stroke: d-node-str, radius: 3pt)
  cnode((-1.8, 1.25), $a$)
  cnode((0, 1.25), $b$)
  cnode((1.8, 1.25), $f(a)$)
  draw.content((0, 1.82), text(size: 0.55em, fill: d-text, weight: "bold")[класс ${a, b, f(a)}$])

  // Congruence arrow: a = f(a) inside the class.
  draw.line((0, 0.8), (0, 0.42), stroke: d-edge, mark: (end: "stealth"))
  draw.content((0.25, 0.61), anchor: "west", text(size: 0.58em, fill: d-muted)[конгруэнтность: $a = f(a)$])

  // Stage 3: implied equality contradicts the third literal.
  draw.rect((-2.9, -0.5), (2.9, 0.0), fill: d-node, stroke: d-conflict + 0.9pt, radius: 3pt)
  draw.content((0, -0.25), text(size: 0.7em, fill: d-text, weight: "bold")[$g(a) = g(f(a))$])
  draw.content((0, -1.0), text(size: 0.6em, fill: d-conflict, weight: "bold")[противоречит $not (g(a) = g(f(a)))$])
})
