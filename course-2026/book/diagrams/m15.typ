// m15 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let sld-goal-fill = oklch(97%, 0.02, 240deg)

#let sld-goal-str = 0.7pt + oklch(40%, 0.05, 240deg)

#let sld-sol-fill = oklch(93%, 0.06, 145deg)

#let sld-dead-col = oklch(45%, 0.10, 15deg)

#let sld-tree = canvas({
  let hw = 1.7 // полуширина плашки цели

  // Узел-цель: скруглённая плашка с подписью.
  let goal(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y + 0.34),
      (x + hw, y - 0.34),
      fill: sld-goal-fill,
      stroke: sld-goal-str,
      radius: 3pt,
      name: name,
    )
    draw.content(pos, label)
  }
  // Ответ: зелёная плашка.
  let solution(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - 1.6, y + 0.3),
      (x + 1.6, y - 0.3),
      fill: sld-sol-fill,
      stroke: 0.7pt + sld-sol-fill,
      radius: 3pt,
      name: name,
    )
    draw.content(pos, label)
  }
  // Ребро.
  let edge(a, b) = draw.line(a, b, stroke: sld-goal-str)

  let root = (0, 0)
  let base1 = (-3.4, -1.8)
  let recur1 = (3.4, -1.8)
  let sol1 = (-3.4, -3.6)
  let anc = (3.4, -3.6)
  let base2 = (1.6, -5.4)
  let recur2 = (5.2, -5.4)
  let sol2 = (1.6, -7.2)
  let dead = (5.2, -7.2)

  goal(root, [`ancestor(alice, Y)`], "root")
  goal(base1, [`parent(alice, Y)`], "base1")
  goal(recur1, [`parent(alice, Z)` \ `ancestor(Z, Y)`], "recur1")
  solution(sol1, [$Y = "bob"$], "sol1")
  goal(anc, [`ancestor(bob, Y)`], "anc")
  goal(base2, [`parent(bob, Y)`], "base2")
  goal(recur2, [`parent(bob, Z')` \ `ancestor(Z', Y)`], "recur2")
  solution(sol2, [$Y = "carol"$], "sol2")
  goal(dead, [`ancestor(carol, Y)`], "dead")
  draw.content((dead.at(0), dead.at(1) - 0.85), text(
    fill: sld-dead-col,
    weight: "bold",
  )[тупик])

  edge("root", "base1")
  edge("root", "recur1")
  edge("base1", "sol1")
  edge("recur1", "anc")
  edge("anc", "base2")
  edge("anc", "recur2")
  edge("base2", "sol2")
  edge("recur2", "dead")
})
