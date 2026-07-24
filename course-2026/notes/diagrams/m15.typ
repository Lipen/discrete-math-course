// M15 diagrams — Finite Automata & Complexity Theory.
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

// 1. DFA: strings over {0,1} ending with "01".
#let dfa-example = figure(
  diagram(
    node-stroke: (paint: c-state-str, thickness: 0.8pt),
    node-fill: c-state,
    edge-stroke: (paint: c-edge, thickness: 0.7pt),
    spacing: 3em,
    edge((-1, 0), "-}>"),
    node((0, 0), $q_0$, name: <q0>),
    edge(<q0>, <q0>, "-}>", label: "0", bend: -50deg),
    edge(<q0>, <q1>, "-}>", label: "1"),
    node((1, 0), $q_1$, name: <q1>, fill: c-accept, stroke: (
      paint: c-accept-str,
      thickness: 1.5pt,
    )),
    edge(<q1>, <q2>, "-}>", label: "0"),
    edge(<q1>, <q1>, "-}>", label: "1", bend: -50deg),
    node((2, 0), $q_2$, name: <q2>),
    edge(<q2>, <q2>, "-}>", label: "0", bend: -50deg),
    edge(<q2>, <q1>, "-}>", label: "1", bend: 40deg),
  ),
  caption: [ДКА, распознающий строки, заканчивающиеся на 01.],
)

// 2. NFA: strings ending with "01" (nondeterministic — shows choice at 0).
#let nfa-example = figure(
  diagram(
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
  ),
  caption: [НКА, распознающий строки, заканчивающиеся на 01. Из $q_0$ по символу 0 возможны два перехода: остаться в $q_0$ или перейти в $q_1$ (недетерминированный выбор).],
)

// 3. NFA with epsilon-transitions recognizing a*b*.
#let epsilon-nfa = figure(
  diagram(
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
  ),
  caption: [НКА с $epsilon$-переходами, распознающий язык $a^* b^*$ (любое количество $a$, затем любое количество $b$). $epsilon$-переходы показаны пунктиром.],
)

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
  draw.circle((-0.4, -0.2), radius: (0.55, 0.35), fill: c-p, stroke: c-border)
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
  draw.line((0, y1 + h + 0.1), (3, y1 - gap + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))
  draw.line((0, y1 + h + 0.1), (-3, y1 - gap + 0.05), stroke: c-arrow, mark: (
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
  draw.line((3, y1 - gap - h + 0.1), (3, y2 + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))

  // Legend
  draw.content((0, y2 - 0.9), text(
    size: 0.55em,
    fill: luma(50%),
  )[Каждая стрелка: $<=_p$ (полиномиальное сведение)])
})
