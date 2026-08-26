#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// Узлы суждений, боковые подписи правил и вертикальные рёбра вывода.
#let judgment-node(pos, name, w, body) = {
  let (x, y) = pos
  draw.rect(
    (x - w, y + 0.35),
    (x + w, y - 0.35),
    name: name,
    fill: c-fl,
    stroke: t-bd + c-bd,
    radius: 4pt,
  )
  draw.content(name, text(size: s-node, fill: c-ink)[#body])
}

#let rule-label(node-name, body) = {
  draw.content(
    (rel: (0.3em, 0), to: node-name + ".east"),
    anchor: "west",
    text(size: s-cap, fill: c-accent, weight: "semibold")[#body],
  )
}

#let vert-edge(parent, child) = {
  draw.line(
    (parent + ".south"),
    (child + ".north"),
    stroke: t-ed + c-edge,
  )
}

// ── id ──
#let derivation-id = canvas({
  let nw = 3.3
  let py = 3.0
  let cy = 1.0

  judgment-node((3.0, py), "prem", nw, {
    $x : "Nat" tack.r x : "Nat"$
  })
  rule-label("prem", [(var)])

  judgment-node((3.0, cy), "conc", nw, {
    $tack.r lambda x : "Nat" . x : "Nat" -> "Nat"$
  })
  rule-label("conc", [(abs)])

  vert-edge("prem", "conc")
})

// ── K ──
#let derivation-k = canvas({
  let nw = 4.0
  let py = 4.4
  let my = 2.6
  let cy = 0.8

  judgment-node((3.5, py), "k-prem", nw, {
    $x : "Nat", y : "Bool" tack.r x : "Nat"$
  })
  rule-label("k-prem", [(var)])

  judgment-node((3.5, my), "k-mid", nw, {
    $x : "Nat" tack.r lambda y : "Bool" . x : "Bool" -> "Nat"$
  })
  rule-label("k-mid", [(abs)])

  judgment-node((3.5, cy), "k-top", nw, {
    $tack.r lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
  })
  rule-label("k-top", [(abs)])

  vert-edge("k-prem", "k-mid")
  vert-edge("k-mid", "k-top")
})
