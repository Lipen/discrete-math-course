// M12 diagrams --- logic programming: SLD tree.
// Скопировано из notes/diagrams/logic-programming.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

#let sld-goal-fill = oklch(97%, 0.02, 240deg)
#let sld-goal-str = 0.7pt + oklch(40%, 0.05, 240deg)
#let sld-sol-fill = oklch(93%, 0.06, 145deg)
#let sld-dead-col = oklch(45%, 0.10, 15deg)

#let sld-tree = canvas({
  let hw = 0.85 // полуширина плашки цели

  let goal(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y + 0.17),
      (x + hw, y - 0.17),
      fill: sld-goal-fill,
      stroke: sld-goal-str,
      radius: 2pt,
      name: name,
    )
    draw.content(pos, text(size: 0.5em, label))
  }
  let solution(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - 0.8, y + 0.15),
      (x + 0.8, y - 0.15),
      fill: sld-sol-fill,
      stroke: 0.7pt + sld-sol-fill,
      radius: 2pt,
      name: name,
    )
    draw.content(pos, text(size: 0.5em, label))
  }
  let edge(a, b) = draw.line(a, b, stroke: sld-goal-str)

  let root = (0, 0)
  let base1 = (-1.7, -0.9)
  let recur1 = (1.7, -0.9)
  let sol1 = (-1.7, -1.8)
  let anc = (1.7, -1.8)
  let base2 = (0.8, -2.7)
  let recur2 = (2.6, -2.7)
  let sol2 = (0.8, -3.6)
  let dead = (2.6, -3.6)

  goal(root, [`ancestor(alice, Y)`], "root")
  goal(base1, [`parent(alice, Y)`], "base1")
  goal(recur1, [`parent(alice, Z)` \ `ancestor(Z, Y)`], "recur1")
  solution(sol1, [$Y = "bob"$], "sol1")
  goal(anc, [`ancestor(bob, Y)`], "anc")
  goal(base2, [`parent(bob, Y)`], "base2")
  goal(recur2, [`parent(bob, Z')` \ `ancestor(Z', Y)`], "recur2")
  solution(sol2, [$Y = "carol"$], "sol2")
  goal(dead, [`ancestor(carol, Y)`], "dead")
  draw.content((dead.at(0), dead.at(1) - 0.425), text(
    size: 0.45em,
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
