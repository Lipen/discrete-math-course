// m18 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-edge = oklch(35%, 0.02, 265deg)

#let mitm = canvas({
  let c-node = oklch(35%, 0.02, 265deg)
  let c-edge = oklch(45%, 0.09, 250deg)
  let c-eve = oklch(50%, 0.16, 25deg)

  // Actors
  draw.content((-3.1, 0), text(size: 0.95em, fill: c-node)[Алиса], name: "alice")
  draw.content((0, 0), text(size: 0.95em, fill: c-eve)[Ева], name: "eve")
  draw.content((3.1, 0), text(size: 0.95em, fill: c-node)[Боб], name: "bob")

  // Edge helper
  let arrow(a, b) = draw.line(a, b, stroke: c-edge, mark: (end: "stealth", fill: c-edge))

  // Алиса -> Ева: A = g^a; Ева -> Алиса: B' = g^y.
  arrow("alice", "eve")
  draw.content((-1.5, 0.85), text(size: 0.72em, fill: c-node)[$A = g^a$])
  arrow("eve", "alice")
  draw.content((-1.5, -0.85), text(size: 0.72em, fill: c-node)[$B' = g^y$])

  // Боб -> Ева: B = g^b; Ева -> Боб: A' = g^x.
  arrow("bob", "eve")
  draw.content((1.5, 0.85), text(size: 0.72em, fill: c-node)[$B = g^b$])
  arrow("eve", "bob")
  draw.content((1.5, -0.85), text(size: 0.72em, fill: c-node)[$A' = g^x$])

  draw.content((0, -1.75), text(
    size: 0.7em,
    fill: c-eve,
  )[два секрета: с Алисой и с Бобом])
})
