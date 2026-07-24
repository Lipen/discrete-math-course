// M17 diagrams — Lambda calculus: syntax trees and reduction graphs.
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
// Shows the tree structure: root is application, left is λx.(x x), right is y.
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

  canvas(length: 9cm, {
    import draw: *

    // Root: application
    tree-node((0, 2.2), "root", $@$, c-app)

    // λx node (left child of root)
    tree-node((-2.5, 1.0), "lam", $lambda x$, c-abs)

    // y node (right child of root)
    tree-node((2.5, 1.0), "y-var", $y$, c-var)

    // Inner application node (child of λx)
    tree-node((-2.5, -0.3), "inner-app", $@$, c-app)

    // x nodes (children of inner app)
    tree-node((-3.8, -1.5), "x1", $x$, c-var)
    tree-node((-1.2, -1.5), "x2", $x$, c-var)

    // Edges
    tree-edge("root", "lam")
    tree-edge("root", "y-var")
    tree-edge("lam", "inner-app")
    tree-edge("inner-app", "x1")
    tree-edge("inner-app", "x2")

    // Labels on edges
    draw.content(
      ((-2.5 + 0) / 2 - 0.25, (1.0 + 2.2) / 2),
      text(size: 0.6em, fill: luma(45%))[аппликация],
    )
    draw.content(
      ((2.5 + 0) / 2 + 0.25, (1.0 + 2.2) / 2),
      text(size: 0.6em, fill: luma(45%))[аргумент],
    )
    draw.content(
      ((-2.5 + -2.5) / 2 - 1.05, (-0.3 + 1.0) / 2),
      text(size: 0.6em, fill: luma(45%))[тело],
    )

    // Legend
    draw.content((2.5, -2.5), text(
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
      (x - 1.8, y + 0.35),
      (x + 1.8, y - 0.35),
      name: name,
      fill: f,
      stroke: str,
      radius: 4pt,
    )
    draw.content(name, text(size: 0.6em, fill: c-label)[#label])
  }

  canvas(length: 12cm, {
    import draw: *

    // M — top
    cr-node(
      (0, 2.5),
      "M",
      $M = (lambda x . x) ((lambda y . y) z)$,
      style: "start",
    )

    // N1 — left
    cr-node((-3, 0.5), "N1", $N_1 = (lambda y . y) z$, style: "normal")

    // N2 — right
    cr-node((3, 0.5), "N2", $N_2 = (lambda x . x) z$, style: "normal")

    // L — bottom
    cr-node((0, -1.5), "L", $L = z$, style: "end")

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
    draw.content((0, -2.8), text(
      size: 0.55em,
      fill: luma(45%),
    )[Конфлюэнтность: два пути редукции --- один результат.])
  })
}
