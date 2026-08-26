// m26 diagrams: синтаксическое дерево λ-терма, алмаз Чёрча-Россера.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Синтаксическое дерево терма (λx. x x) y ──
#let lambda-syntax-tree = {
  let tn(pos, name, label, fill) = {
    let (x, y) = pos
    draw.rect(
      (x - 0.7, y + 0.3),
      (x + 0.7, y - 0.3),
      name: name,
      fill: fill,
      stroke: c-bd + t-bd,
      radius: 4pt,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#label])
  }

  let te(from, to, name, label) = {
    draw.line(from, to, name: name, stroke: c-edge + t-ed)
    draw.content(
      name,
      text(size: s-cap, fill: c-muted)[#label],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  canvas({
    tn((0, 1.9), "root", $@$, c-conn)
    tn((-1.9, 0.3), "lam", $lambda x$, c-conn)
    tn((1.9, 0.3), "yvar", $y$, c-atom)
    tn((-1.9, -1.3), "app", $@$, c-conn)
    tn((-2.9, -2.9), "x1", $x$, c-atom)
    tn((0.1, -2.9), "x2", $x$, c-atom)

    te("root", "lam", "e-root-lam", [функция])
    te("root", "yvar", "e-root-yvar", [аргумент])
    te("lam", "app", "e-lam-app", [тело])
    te("app", "x1", "e-app-x1", [функция])
    te("app", "x2", "e-app-x2", [аргумент])

    draw.content((0, -3.9), text(size: s-cap, fill: c-muted)[
      Синтаксическое дерево терма $(lambda x . x x) y$
    ])
  })
}

// ── Алмаз Чёрча-Россера: оба порядка редукции сходятся к z ──
#let church-rosser-diamond = {
  let dn(pos, name, label, fill) = {
    let (x, y) = pos
    draw.rect(
      (x - 2.4, y + 0.4),
      (x + 2.4, y - 0.4),
      name: name,
      fill: fill,
      stroke: c-bd + t-bd,
      radius: 4pt,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#label])
  }

  let de(from, to, name, label, size: s-cap) = {
    draw.line(
      from,
      to,
      name: name,
      stroke: c-edge + t-ed,
      mark: (end: "stealth", fill: c-edge),
    )
    draw.content(
      name,
      text(size: size, fill: c-muted)[#label],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  canvas({
    dn((0, 2.8), "M", $M = (lambda x . x) ((lambda y . y) z)$, c-conn)
    dn((-4.0, 0.6), "N1", $N_1 = (lambda y . y) z$, c-fl)
    dn((4.0, 0.6), "N2", $N_2 = (lambda x . x) z$, c-fl)
    dn((0, -1.8), "L", $L = z$, c-atom)

    de("M", "N1", "e1", [внешний редекс])
    de("M", "N2", "e2", [внутренний редекс])
    de("N1", "L", "e3", size: s-tiny, [$arrow.r_beta$])
    de("N2", "L", "e4", size: s-tiny, [$arrow.r_beta$])

    draw.content((0, -3.4), text(size: s-cap, fill: c-muted)[
      Теорема Чёрча--Россера: внешний и внутренний пути редукции сходятся к $z$.
    ])
  })
}
