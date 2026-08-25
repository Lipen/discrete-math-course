// m27 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-judgment = oklch(50%, 0.04, 260deg)

#let c-rule = oklch(55%, 0.14, 260deg)

#let c-line = oklch(35%, 0.02, 265deg)

#let judgment-node(pos, name, w, body) = {
  let (x, y) = pos
  draw.rect(
    (x - w, y + 0.35),
    (x + w, y - 0.35),
    name: name,
    fill: oklch(97%, 0.01, 260deg),
    stroke: 0.7pt + c-judgment,
    radius: 4pt,
  )
  draw.content(name, text(size: 0.65em, fill: c-judgment)[#body])
}

#let rule-label(node-name, body) = {
  draw.content(
    (rel: (0.3em, 0), to: node-name + ".east"),
    anchor: "west",
    text(size: 0.55em, fill: c-rule, weight: "semibold")[#body],
  )
}

#let vert-edge(parent, child) = {
  draw.line(
    (parent + ".south"),
    (child + ".north"),
    stroke: 0.6pt + c-line,
  )
}

#let derivation-id = canvas({
  let nw = 3.3
  let py = 3.0 // premise (var)
  let cy = 1.0 // conclusion (abs)

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

#let derivation-k = canvas({
  let nw = 4.0
  let py = 4.4 // premise (var)
  let my = 2.6 // abs on y
  let cy = 0.8 // abs on x

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
