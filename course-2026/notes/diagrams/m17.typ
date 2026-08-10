// M17 diagrams --- Lambda calculus: syntax trees and reduction graphs.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ── Shared constants ──

#let c-app = oklch(92%, 0.04, 45deg)
#let c-abs = oklch(90%, 0.04, 260deg)
#let c-var = oklch(93%, 0.02, 155deg)
#let c-node-str = oklch(50%, 0.08, 260deg) + 0.6pt
#let c-edge = oklch(35%, 0.02, 265deg) + 0.6pt
#let c-label = oklch(30%, 0.02, 265deg)
#let c-beta = oklch(55%, 0.18, 22deg) + 0.6pt

// ── 1. Syntax tree of (λx. x x) y ──
// Grid: y-step = 1.5, level 0 at y=1.8, level 1 at y=0.3, level 2 at y=-1.2, level 3 at y=-2.7.
// x: root=0, λx=-1.2, y=1.2, inner-app=-1.2, x1=-2.0, x2=-0.4.
#let lambda-syntax-tree = {
  let tree-node(pos, name, label, fill) = {
    let (x, y) = pos
    draw.rect(
      (x - 0.55, y + 0.28),
      (x + 0.55, y - 0.28),
      name: name,
      fill: fill,
      stroke: c-node-str,
      radius: 4pt,
    )
    draw.content(name, text(size: 0.75em, fill: c-label)[#label])
  }

  let tree-edge(parent, child) = {
    draw.line(parent, child, stroke: c-edge)
  }

  canvas({

    // Level 0 --- root application
    tree-node((0, 1.8), "root", $@$, c-app)

    // Level 1 --- children of root
    tree-node((-1.2, 0.3), "lam", $lambda x$, c-abs)
    tree-node((1.2, 0.3), "y-var", $y$, c-var)

    // Level 2 --- body of λx
    tree-node((-1.2, -1.2), "inner-app", $@$, c-app)

    // Level 3 --- the two x's
    tree-node((-2.0, -2.7), "x1", $x$, c-var)
    tree-node((-0.4, -2.7), "x2", $x$, c-var)

    // Edges
    tree-edge("root", "lam")
    tree-edge("root", "y-var")
    tree-edge("lam", "inner-app")
    tree-edge("inner-app", "x1")
    tree-edge("inner-app", "x2")

    // Edge labels (midpoint + offset)
    let el(size: 0.6em, body) = text(size: size, fill: luma(45%))[#body]

    // root → lam: midpoint (-0.6, 1.05), label left
    draw.content((-1.1, 1.05), el[функция])
    // root → y: midpoint (0.6, 1.05), label right
    draw.content((1.1, 1.05), el[аргумент])
    // lam → inner-app: midpoint (-1.2, -0.45), label left
    draw.content((-1.9, -0.45), el[тело])
    // inner-app → x1: midpoint (-1.6, -1.95), label left
    draw.content((-2.0, -1.95), el[функция])
    // inner-app → x2: midpoint (-0.8, -1.95), label right
    draw.content((-0.4, -1.95), el[аргумент])

    // Caption
    draw.content((0, -3.5), text(
      size: 0.55em,
      fill: luma(45%),
    )[Синтаксическое дерево терма $(lambda x . x x) y$])
  })
}

// ── 2. Church-Rosser confluence: concrete example ──
// M = (λx. x) ((λy. y) z)
// Path 1 (outer first): M → (λy. y) z → z
// Path 2 (inner first): M → (λx. x) z → z
// Both paths converge to z.

#let church-rosser-diamond = {
  let cr-node(pos, name, label, style: "normal") = {
    let (x, y) = pos
    let f = if style == "start" {
      oklch(93%, 0.03, 45deg)
    } else if style == "end" {
      oklch(93%, 0.04, 155deg)
    } else {
      oklch(95%, 0.01, 265deg)
    }
    let str = if style == "start" or style == "end" {
      c-node-str
    } else {
      oklch(45%, 0.02, 265deg) + 0.5pt
    }
    draw.rect(
      (x - 1.3, y + 0.35),
      (x + 1.3, y - 0.35),
      name: name,
      fill: f,
      stroke: str,
      radius: 4pt,
    )
    draw.content(name, text(size: 0.6em, fill: c-label)[#label])
  }

  canvas({

    // M --- top
    cr-node(
      (0, 2.8),
      "M",
      $M = (lambda x . x) ((lambda y . y) z)$,
      style: "start",
    )

    // N1 --- left
    cr-node((-3.2, 0.6), "N1", $N_1 = (lambda y . y) z$, style: "normal")

    // N2 --- right
    cr-node((3.2, 0.6), "N2", $N_2 = (lambda x . x) z$, style: "normal")

    // L --- bottom
    cr-node((0, -1.7), "L", $L = z$, style: "end")

    // Edges
    draw.line("M", "N1", stroke: c-beta, name: "e1")
    draw.content("e1", text(
      size: 0.55em,
      fill: oklch(45%, 0.18, 22deg),
    )[внешний редекс])

    draw.line("M", "N2", stroke: c-beta, name: "e2")
    draw.content("e2", text(
      size: 0.55em,
      fill: oklch(45%, 0.18, 22deg),
    )[внутренний редекс])

    draw.line("N1", "L", stroke: c-beta, name: "e3")
    draw.content("e3", text(size: 0.55em, fill: oklch(
      45%,
      0.18,
      22deg,
    ))[$arrow.r_beta$])

    draw.line("N2", "L", stroke: c-beta, name: "e4")
    draw.content("e4", text(size: 0.55em, fill: oklch(
      45%,
      0.18,
      22deg,
    ))[$arrow.r_beta$])

    // Caption
    draw.content((0, -3.2), text(
      size: 0.55em,
      fill: luma(45%),
    )[Теорема Чёрча--Россера: внешний и внутренний пути редукции сходятся к $z$.])
  })
}
