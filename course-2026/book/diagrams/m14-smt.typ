// Diagrams for the SMT chapter (m14-smt): DPLL(T) architecture loop, difference-logic negative cycle, congruence closure.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let d-node = oklch(88%, 0.03, 250deg)
#let d-node-str = oklch(60%, 0.08, 250deg) + 0.6pt
#let d-text = oklch(30%, 0.02, 265deg)
#let d-muted = oklch(55%, 0.02, 265deg)
#let d-edge = oklch(35%, 0.02, 265deg) + 0.8pt
#let d-neg = oklch(58%, 0.20, 22deg)
#let d-pos = oklch(55%, 0.15, 150deg)
#let d-sat = oklch(88%, 0.05, 250deg)
#let d-theory = oklch(88%, 0.05, 155deg)
#let d-merge = oklch(88%, 0.05, 155deg)
#let d-conflict = oklch(58%, 0.20, 22deg)

// Small named term node (circle with a label).
#let cnode(pos, label, fill: d-node) = {
  draw.circle(pos, radius: 0.42, fill: fill, stroke: d-node-str)
  draw.content(pos, text(size: 0.68em, fill: d-text)[#label])
}

// ── DPLL(T) architecture loop ──
#let dpll-t-architecture = canvas({
  // SAT solver box (top): boolean skeleton + CDCL search.
  draw.rect((-2.7, 0.55), (2.7, 1.65), fill: d-sat, stroke: d-node-str, radius: 3pt)
  draw.content((0, 1.3), text(size: 0.72em, fill: d-text, weight: "bold")[SAT-решатель])
  draw.content((0, 0.95), text(size: 0.58em, fill: d-muted)[DPLL / CDCL])

  // Theory solver box (bottom): checks consistency of theory atoms.
  draw.rect((-2.7, -1.65), (2.7, -0.55), fill: d-theory, stroke: d-node-str, radius: 3pt)
  draw.content((0, -0.95), text(size: 0.72em, fill: d-text, weight: "bold")[Theory-солвер])
  draw.content((0, -1.3), text(size: 0.58em, fill: d-muted)[DL, EUF, LRA, ...])

  // SAT → theory: candidate model.
  draw.line((1.7, 0.55), (1.7, -0.55), mark: (end: "stealth"), stroke: d-edge)
  draw.content((2.15, 0), anchor: "west", text(size: 0.58em, fill: d-text)[модель])

  // Theory → SAT: conflict clause (T-lemma).
  draw.line((-1.7, -0.55), (-1.7, 0.55), mark: (end: "stealth"), stroke: d-edge)
  draw.content((-2.15, 0), anchor: "east", text(size: 0.58em, fill: d-text)[$T$-лемма])
})

// ── Difference-logic negative cycle ──
#let dl-negative-cycle = canvas({
  // Triangle x -> z (-3), z -> w (-1), w -> x (+2).
  let x = (-1.6, 1.2)
  let z = (1.6, 1.2)
  let w = (0, -1.6)

  cnode(x, $x$)
  cnode(z, $z$)
  cnode(w, $w$)

  // x -> z, weight -3
  draw.line(x, z, mark: (end: "stealth"), stroke: d-neg + 1.2pt)
  draw.content((0, 1.75), text(size: 0.62em, fill: d-neg, weight: "bold")[$-3$])
  // z -> w, weight -1
  draw.line(z, w, mark: (end: "stealth"), stroke: d-neg + 1.2pt)
  draw.content((1.2, -0.35), text(size: 0.62em, fill: d-neg, weight: "bold")[$-1$])
  // w -> x, weight +2
  draw.line(w, x, mark: (end: "stealth"), stroke: d-pos + 1.2pt)
  draw.content((-0.95, -0.35), text(size: 0.62em, fill: d-pos, weight: "bold")[$+2$])

  draw.content((0, -2.5), text(size: 0.62em, fill: d-neg)[$-3 - 1 + 2 = -2 < 0$])
})

// ── Congruence closure: class merging and the congruence step ──
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
