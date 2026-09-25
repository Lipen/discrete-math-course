#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import fletcher: diagram, edge, node

#let sld-tree = {
  let goal(pos, name, label) = node(
    pos,
    text(size: s-node, fill: c-ink)[#label],
    name: name,
    fill: c-fl,
    stroke: t-bd + c-bd,
    inset: 6pt,
    corner-radius: 3pt,
  )
  let solution(pos, name, label) = node(
    pos,
    text(size: s-node, fill: c-ink)[#label],
    name: name,
    fill: c-atom,
    stroke: t-bd + c-bd,
    inset: 6pt,
    corner-radius: 3pt,
  )
  let tree-edge(fr, to) = edge(fr, to, "-", stroke: t-ed + c-edge)
  let sld-note(pos, body) = node(
    pos,
    body,
    fill: none,
    stroke: none,
    shape: rect,
    inset: 0pt,
  )

  diagram(
    spacing: (3.4cm, 1.8cm),
    goal((0, 0), <root>, [`ancestor(alice, Y)`]),
    goal((-1, 1), <base1>, [`parent(alice, Y)`]),
    goal((1, 1), <recur1>, [`parent(alice, Z)` \ `ancestor(Z, Y)`]),
    solution((-1, 2), <sol1>, [$Y = "bob"$]),
    goal((1, 2), <anc>, [`ancestor(bob, Y)`]),
    goal((0.47, 3), <base2>, [`parent(bob, Y)`]),
    goal((1.53, 3), <recur2>, [`parent(bob, Z')` \ `ancestor(Z', Y)`]),
    solution((0.47, 4), <sol2>, [$Y = "carol"$]),
    goal((1.53, 4), <dead>, [`ancestor(carol, Y)`]),

    // Ветвь, не давшая ответа, --- откат (failure); помечаем цветом противоречия.
    sld-note((1.53, 4.47), text(
      size: s-cap,
      fill: c-hot,
      weight: "bold",
    )[тупик]),

    tree-edge(<root>, <base1>),
    tree-edge(<root>, <recur1>),
    tree-edge(<base1>, <sol1>),
    tree-edge(<recur1>, <anc>),
    tree-edge(<anc>, <base2>),
    tree-edge(<anc>, <recur2>),
    tree-edge(<base2>, <sol2>),
    tree-edge(<recur2>, <dead>),
  )
}
