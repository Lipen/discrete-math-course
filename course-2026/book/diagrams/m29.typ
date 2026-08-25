// m29 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-p = oklch(88%, 0.05, 155deg)

#let c-np = oklch(88%, 0.04, 70deg)

#let c-pspace = oklch(88%, 0.04, 300deg)

#let c-exp = oklch(85%, 0.03, 22deg)

#let c-label = oklch(35%, 0.02, 265deg)

#let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

#let complexity-classes = canvas({
  // EXP
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
  // 3-SAT -> Subset Sum
  draw.line((0, y1 + 0.1), (3, y2 + 0.05), stroke: c-arrow, mark: (
    end: ">",
  ))
  // Vertex Cover -> Clique
  draw.line((-1.9, y1 - gap + h / 2), (1.9, y1 - gap + h / 2), stroke: c-arrow, mark: (
    end: ">",
  ))

  // Legend
  draw.content((0, y2 - 0.9), text(
    size: 0.55em,
    fill: luma(50%),
  )[Каждая стрелка: $<=_p$ (полиномиальное сведение)])
})

#let zpp-venn = canvas({
  let c-rp = oklch(92%, 0.05, 155deg)
  let c-corp = oklch(92%, 0.05, 22deg)
  let c-bpp = oklch(90%, 0.03, 250deg)
  let c-zpp = oklch(94%, 0.06, 90deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  // BPP
  draw.circle((0, 0), radius: (2.6, 1.7), fill: c-bpp, stroke: c-border)
  draw.content((2.2, 1.3), text(size: 0.65em, fill: c-label)[BPP])

  // RP
  draw.circle((-0.7, 0.1), radius: (1.4, 1.0), fill: c-rp, stroke: c-border)
  draw.content((-1.6, 0.1), text(size: 0.65em, fill: c-label)[RP])

  // coRP
  draw.circle((0.7, 0.1), radius: (1.4, 1.0), fill: c-corp, stroke: c-border)
  draw.content((1.6, 0.1), text(size: 0.65em, fill: c-label)[coRP])

  // ZPP
  draw.circle((0, 0.1), radius: (0.55, 0.4), fill: c-zpp, stroke: c-border)
  draw.content((0, 0.1), text(size: 0.6em, fill: c-label)[ZPP])

  // P
  draw.circle((0, 0.1), radius: (0.2, 0.15), fill: white, stroke: c-border)
  draw.content((0, 0.1), text(size: 0.5em, fill: c-label)[P])

  draw.content((0, -1.5), text(
    size: 0.55em,
    fill: luma(50%),
  )[$P subset.eq "ZPP" = "RP" inter "coRP" subset.eq "BPP"$])
})
