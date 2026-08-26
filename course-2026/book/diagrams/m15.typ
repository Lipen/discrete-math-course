#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let sld-tree = canvas({
  let hw = 1.7
  let sol-hw = 1.6
  let sol-hh = 0.3

  let goal-str = t-bd + c-bd
  let e-str = t-ed + c-edge

  let goal(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y + 0.34),
      (x + hw, y - 0.34),
      fill: c-fl,
      stroke: goal-str,
      radius: 3pt,
      name: name,
    )
    draw.content(pos, text(size: s-node, fill: c-ink)[#label])
  }
  let solution(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - sol-hw, y + sol-hh),
      (x + sol-hw, y - sol-hh),
      fill: c-atom,
      stroke: goal-str,
      radius: 3pt,
      name: name,
    )
    draw.content(pos, text(size: s-node, fill: c-ink)[#label])
  }
  let tree-edge(a, b) = draw.line(a, b, stroke: e-str, name: a + "-" + b)

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

  // Ветвь, не давшая ответа, --- откат (failure); помечаем цветом противоречия.
  draw.content(
    (dead.at(0), dead.at(1) - 0.85),
    text(size: s-cap, fill: c-hot, weight: "bold")[тупик],
  )

  tree-edge("root", "base1")
  tree-edge("root", "recur1")
  tree-edge("base1", "sol1")
  tree-edge("recur1", "anc")
  tree-edge("anc", "base2")
  tree-edge("anc", "recur2")
  tree-edge("base2", "sol2")
  tree-edge("recur2", "dead")
})
