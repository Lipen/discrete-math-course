// M15 diagrams --- Finite Automata & Complexity Theory.
#import "../requirements.typ": *
#import "../notation.typ": *

#import fletcher: diagram, edge, node
#import cetz: canvas, draw

// ── Automata ──

#let c-state = oklch(88%, 0.03, 250deg)
#let c-state-str = oklch(60%, 0.08, 250deg)
#let c-accept = oklch(88%, 0.05, 155deg)
#let c-accept-str = oklch(55%, 0.18, 155deg)
#let c-edge = oklch(35%, 0.02, 265deg)

// 1. NFA: strings ending with "01" (nondeterministic --- shows choice at 0).
#let nfa-example = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.7pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $q_0$, name: <q0>),
  edge(<q0>, <q0>, "-}>", label: "0,1", bend: -50deg),
  edge(<q0>, <q1>, "-}>", label: "0"),
  node((1, 0), $q_1$, name: <q1>),
  edge(<q1>, <q2>, "-}>", label: "1"),
  node((2, 0), $q_2$, name: <q2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.5pt,
  )),
)

// 2. NFA with epsilon-transitions recognizing a*b*.
#let epsilon-nfa = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.7pt),
  spacing: 3em,
  // Start arrow into q0
  edge((-1, 0), "-}>"),
  // q0 (start)
  node((0, 0), $q_0$, name: <q0>),
  // epsilon: q0 → q1 (spontaneous)
  edge(<q0>, <q1>, "-}>", label: $epsilon$, stroke: (
    paint: c-edge,
    thickness: 0.7pt,
    dash: "dashed",
  )),
  // q1
  node((1, 0), $q_1$, name: <q1>),
  // self-loop: q1 --a--> q1
  edge(<q1>, <q1>, "-}>", label: $"a"$, bend: -50deg),
  // epsilon: q1 → q2 (spontaneous)
  edge(<q1>, <q2>, "-}>", label: $epsilon$, stroke: (
    paint: c-edge,
    thickness: 0.7pt,
    dash: "dashed",
  )),
  // q2 (accept)
  node((2, 0), $q_2$, name: <q2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.5pt,
  )),
  // self-loop: q2 --b--> q2
  edge(<q2>, <q2>, "-}>", label: $"b"$, bend: -50deg),
)

// ── Chomsky hierarchy ──

// Nested language classes: Regular ⊂ Context-Free ⊂ Context-Sensitive ⊂ RE.
// Ovals follow the lecture diagram (formal-methods-course), adapted to the 4 Chomsky levels.
#let chomsky-hierarchy = canvas({
  let c-reg = oklch(88%, 0.05, 155deg)
  let c-cf = oklch(88%, 0.04, 70deg)
  let c-cs = oklch(88%, 0.04, 300deg)
  let c-re = oklch(85%, 0.03, 22deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  // Regular (innermost)
  draw.circle((0, 0), radius: (0.8, 0.4), fill: c-reg, stroke: c-border)
  draw.content((0, 0.3), text(size: 0.6em, fill: c-label)[Regular])

  // Context-Free
  draw.circle((0, 0.4), radius: (1.4, 0.8), fill: c-cf, stroke: c-border)
  draw.content((0, 1.0), text(size: 0.6em, fill: c-label)[Context-Free])

  // Context-Sensitive
  draw.circle((0, 1.2), radius: (2.6, 1.6), fill: c-cs, stroke: c-border)
  draw.content((0, 2.0), text(size: 0.6em, fill: c-label)[Context-Sensitive])

  // Recursively Enumerable (outermost)
  draw.circle((0, 2.4), radius: (4, 2.8), fill: c-re, stroke: c-border)
  draw.content((0, 3.4), text(
    size: 0.6em,
    fill: c-label,
  )[Recursively Enumerable])
})

// ── Complexity Theory ──

#let c-p = oklch(88%, 0.05, 155deg)
#let c-np = oklch(88%, 0.04, 70deg)
#let c-pspace = oklch(88%, 0.04, 300deg)
#let c-exp = oklch(85%, 0.03, 22deg)
#let c-label = oklch(35%, 0.02, 265deg)
#let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

// Complexity class inclusions: P ⊆ NP ⊆ PSPACE ⊆ EXP
// Drawn as nested ovals with known proper inclusions marked.
#let complexity-classes = canvas({
  // EXP (outermost)
  draw.circle((0, -0.2), radius: (2.8, 1.6), fill: c-exp, stroke: c-border)
  draw.content((2.5, -1.8), text(size: 0.65em, fill: c-label)[EXP])

  // PSPACE
  draw.circle((0, -0.2), radius: (2.1, 1.2), fill: c-pspace, stroke: c-border)
  draw.content((0, -0.2), text(size: 0.65em, fill: c-label)[PSPACE])

  // NP
  draw.circle((-0.3, -0.2), radius: (1.1, 0.7), fill: c-np, stroke: c-border)
  draw.content((-0.8, -0.2), text(size: 0.65em, fill: c-label)[NP])

  // coNP
  draw.circle((0.5, -0.2), radius: (0.9, 0.55), fill: c-np, stroke: c-border)
  draw.content((1.0, -0.2), text(size: 0.6em, fill: c-label)[coNP])

  // P
  draw.circle((0.1, -0.2), radius: (0.5, 0.3), fill: c-p, stroke: c-border)
  draw.content((-0.4, -0.2), text(size: 0.65em, fill: c-label)[P])

  // Proper inclusion notes
  draw.content((0, 1.5), text(
    size: 0.6em,
    fill: luma(50%),
  )[$P != "EXP"$ (теорема об иерархии)])
  draw.content((2.0, 0.8), text(size: 0.55em, fill: luma(50%))[$?$])
})

// NP-completeness reduction graph: canonical chain of reductions.
// SAT → 3-SAT → Vertex Cover → Hamiltonian Cycle → Subset Sum
#let np-reduction-tree = canvas({
  let c-box = oklch(88%, 0.03, 250deg)
  let c-box-str = oklch(60%, 0.08, 250deg) + 0.5pt
  let c-box-npc = oklch(88%, 0.06, 22deg)
  let c-box-npc-str = oklch(55%, 0.18, 22deg) + 0.6pt
  let c-arrow = oklch(35%, 0.02, 265deg) + 0.5pt

  let w = 2.2
  let h = 0.55
  let gap = 0.75

  // Level 0: SAT (root)
  draw.rect(
    (-w / 2, 0),
    (w / 2, h),
    radius: 3pt,
    fill: c-box-npc,
    stroke: c-box-npc-str,
  )
  draw.content((0, h / 2), text(size: 0.65em, fill: c-label)[SAT])

  // Level 1: 3-SAT, Clique, Vertex Cover
  let y1 = -gap - h
  draw.rect(
    (-w / 2, y1),
    (w / 2, y1 + h),
    radius: 3pt,
    fill: c-box,
    stroke: c-box-str,
  )
  draw.content((0, y1 + h / 2), text(size: 0.65em, fill: c-label)[3-SAT])

  draw.rect(
    (-w / 2 + 3, y1 - gap - h),
    (w / 2 + 3, y1 - gap),
    radius: 3pt,
    fill: c-box,
    stroke: c-box-str,
  )
  draw.content((3, y1 - gap - h / 2), text(size: 0.65em, fill: c-label)[Clique])

  draw.rect(
    (-w / 2 - 3, y1 - gap - h),
    (w / 2 - 3, y1 - gap),
    radius: 3pt,
    fill: c-box,
    stroke: c-box-str,
  )
  draw.content((-3, y1 - gap - h / 2), text(
    size: 0.65em,
    fill: c-label,
  )[Vertex Cover])

  // Arrows from SAT
  draw.line((0, y1 + h + 0.1), (0, y1 + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))

  // Level 2: Hamiltonian Cycle, Subset Sum
  let y2 = y1 - 2 * gap - 2 * h
  draw.rect(
    (-w / 2 - 3, y2),
    (w / 2 - 3, y2 + h),
    radius: 3pt,
    fill: c-box,
    stroke: c-box-str,
  )
  draw.content((-3, y2 + h / 2), text(size: 0.6em, fill: c-label)[Ham. Cycle])

  draw.rect(
    (-w / 2 + 3, y2),
    (w / 2 + 3, y2 + h),
    radius: 3pt,
    fill: c-box,
    stroke: c-box-str,
  )
  draw.content((3, y2 + h / 2), text(size: 0.65em, fill: c-label)[Subset Sum])

  // Arrows from level 1
  draw.line((-3, y1 - gap - h + 0.1), (-3, y2 + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))
  // 3-SAT → Subset Sum (canonical chain)
  draw.line((0, y1 + 0.1), (3, y2 + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))
  // Vertex Cover → Clique (canonical chain)
  draw.line((-1.9, y1 - gap + h / 2), (1.9, y1 - gap + h / 2), stroke: c-arrow, mark: (
    end: ">",
  ))

  // Legend
  draw.content((0, y2 - 0.9), text(
    size: 0.55em,
    fill: luma(50%),
  )[Каждая стрелка: $<=_p$ (полиномиальное сведение)])
})

// ── ZPP = RP ∩ coRP: Euler diagram with the known inclusions ──
#let zpp-venn = canvas({
  let c-rp = oklch(92%, 0.05, 155deg)
  let c-corp = oklch(92%, 0.05, 22deg)
  let c-bpp = oklch(90%, 0.03, 250deg)
  let c-zpp = oklch(94%, 0.06, 90deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  // BPP (outer).
  draw.circle((0, 0), radius: (2.6, 1.7), fill: c-bpp, stroke: c-border)
  draw.content((2.2, 1.3), text(size: 0.65em, fill: c-label)[BPP])

  // RP (left lobe).
  draw.circle((-0.7, 0.1), radius: (1.4, 1.0), fill: c-rp, stroke: c-border)
  draw.content((-1.6, 0.1), text(size: 0.65em, fill: c-label)[RP])

  // coRP (right lobe).
  draw.circle((0.7, 0.1), radius: (1.4, 1.0), fill: c-corp, stroke: c-border)
  draw.content((1.6, 0.1), text(size: 0.65em, fill: c-label)[coRP])

  // ZPP (intersection).
  draw.circle((0, 0.1), radius: (0.55, 0.4), fill: c-zpp, stroke: c-border)
  draw.content((0, 0.1), text(size: 0.6em, fill: c-label)[ZPP])

  // P inside ZPP.
  draw.circle((0, 0.1), radius: (0.2, 0.15), fill: white, stroke: c-border)
  draw.content((0, 0.1), text(size: 0.5em, fill: c-label)[P])

  draw.content((0, -1.5), text(
    size: 0.55em,
    fill: luma(50%),
  )[$P subset.eq "ZPP" = "RP" inter "coRP" subset.eq "BPP"$])
})
