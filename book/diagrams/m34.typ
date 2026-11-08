#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let k-radius = 0.55

#let k-cap-gap = 1.0

#let k-edge = t-ed + c-edge

// k-forced-str: зелёная обводка принуждающего мира.
#let k-forced-str = oklch(50%, 0.16, 155deg)

#let kripke-world(
  pos,
  name,
  lbl,
  caption,
  fill: c-fl,
  stroke: t-bd + c-bd,
  cap-dy: k-cap-gap,
) = {
  let (x, y) = pos
  draw.circle(pos, radius: k-radius, fill: fill, stroke: stroke, name: name)
  draw.content(name, text(size: s-node, fill: c-ink)[#lbl])
  draw.content((x, y - cap-dy), text(size: s-cap, fill: c-muted)[#caption])
}

// ── Два мира: p принуждается только в v ──
#let kripke-two-worlds = canvas({
  kripke-world((-1.5, 0), "u", $u$, [$p$ не принуждается])
  kripke-world(
    (1.5, 0),
    "v",
    $v$,
    [$p$ принуждается],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
  )

  draw.line(
    "u.east",
    "v.west",
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
    name: "uv",
  )
  draw.content((0, 0.32), text(size: s-tiny, fill: c-muted)[$u <= v$])

  draw.content((0, -1.7), text(
    size: s-cap,
    fill: c-muted,
  )[оценка: $V(p) = {v}$])
})

// ── Зонтик: монотонность истинности при движении вверх ──
#let kripke-umbrella = canvas({
  kripke-world((-1.8, 0), "w0", $w_0$, [ни $p$, ни $q$ не принуждаются])
  kripke-world(
    (0.0, 2),
    "w1",
    $w_1$,
    [$p$ и $q$ принуждаются],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: 1.2,
  )
  kripke-world(
    (3.2, 2),
    "w1'",
    $w_1'$,
    [$p$ принуждается, $q$ --- нет],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: 1.2,
  )

  draw.line(
    "w0",
    (-1.8, 1.3),
    (-0.70, 1.3),
    (-0.389, 1.611),
    stroke: k-edge,
    mark: (end: (symbol: ">", fill: c-edge)),
    name: "e1",
  )
  draw.line(
    "w0",
    (-1.8, 1.3),
    (2.50, 1.3),
    (2.811, 1.611),
    stroke: k-edge,
    mark: (end: (symbol: ">", fill: c-edge)),
    name: "e2",
  )

  draw.content((0.7, -1.75), text(
    size: s-cap,
    fill: c-muted,
  )[оценка: $V(p) = {w_1, w_1'}$, $V(q) = {w_1}$])
})

// ── Из посета в алгебру Хейтинга: идеалы цепи из двух элементов ──
#let heyting-downsets = canvas({
  let p-node(pos, name, lbl) = {
    draw.circle(pos, radius: 0.36, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(name, text(size: s-node, fill: c-ink)[#lbl])
  }

  p-node((-3.9, 0), "pa", $a$)
  p-node((-3.9, 1.6), "pb", $b$)
  draw.line("pa", "pb", stroke: k-edge)
  draw.content((-3.9, -0.8), text(size: s-cap, fill: c-muted)[посет $a < b$])

  draw.line(
    (-2.9, 0.8),
    (-1.9, 0.8),
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
  )
  draw.content((-2.4, 1.2), text(size: s-cap, fill: c-muted)[идеалы])

  let d-node(pos, name, lbl) = {
    draw.circle(pos, radius: 0.4, fill: c-atom, stroke: t-bd + c-bd, name: name)
    draw.content(name, text(size: s-cap, fill: c-ink)[#lbl])
  }

  d-node((-0.9, 0), "d0", $emptyset$)
  d-node((-0.9, 1.15), "d1", ${a}$)
  d-node((-0.9, 2.3), "d2", ${a, b}$)
  draw.line("d0", "d1", stroke: k-edge)
  draw.line("d1", "d2", stroke: k-edge)

  draw.content((0.45, 0), text(size: s-cap, fill: c-muted)[$0$])
  draw.content((0.45, 1.15), text(size: s-cap, fill: c-muted)[$1\/2$])
  draw.content((0.45, 2.3), text(size: s-cap, fill: c-muted)[$1$])
})

// ── Ветвление: $not (p and q)$ принуждается, $not p$ и $not q$ --- нет ──
#let kripke-branching = canvas({
  let (dx, dy) = (0.707, 0.707)
  let (rx, ry) = (0.6, 0.6)
  let (tx, ty) = (1.25, 1.25)

  draw.line(
    (dx * rx, dy * rx),
    (-dx * tx, dy * tx),
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
  )
  draw.line(
    (dx * rx, dy * rx),
    (dx * tx, dy * tx),
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
  )

  kripke-world((0, 0), "br", $r$, [ни $p$, ни $q$])
  kripke-world(
    (-1.75, 1.75),
    "bw1",
    $w_1$,
    [$p$ принуждается],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: -0.85,
  )
  kripke-world(
    (1.75, 1.75),
    "bw2",
    $w_2$,
    [$q$ принуждается],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: -0.85,
  )
})

// ── Решётка промежуточных логик: цепь и весь остальной континуум ──
#let intermediate-logics = canvas({
  let logic-node(y, name, lbl, fill: c-fl) = {
    draw.rect(
      (-1.05, y + 0.3),
      (1.05, y - 0.3),
      fill: fill,
      stroke: t-bd + c-bd,
      radius: 4pt,
      name: name,
    )
    draw.content(name, text(size: s-node, fill: c-ink)[#lbl])
  }

  let step(y, from, to) = draw.line(
    (0, y + 0.3),
    (0, y + 1.2),
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
  )

  logic-node(0, "l-ipc", $"IPC"$, fill: c-atom)
  logic-node(1.5, "l-kc", $"KC"$)
  logic-node(3.0, "l-lc", $"LC"$)
  logic-node(4.5, "l-cpc", $"CPC"$, fill: c-atom)

  step(0, "l-ipc", "l-kc")
  step(1.5, "l-kc", "l-lc")
  step(3.0, "l-lc", "l-cpc")

  draw.content((1.9, 0.75), text(
    size: s-cap,
    fill: c-muted,
  )[$+ not p or not not p$])
  draw.content((1.9, 2.25), text(
    size: s-cap,
    fill: c-muted,
  )[$+ (p -> q) or (q -> p)$])

  draw.rect(
    (3.4, 4.3),
    (6.2, 0.2),
    stroke: (paint: c-edge, thickness: t-ed, dash: "dashed"),
    radius: 6pt,
  )
  draw.content(
    (4.8, 2.25),
    text(size: s-cap, fill: c-muted)[остальные \ промежуточные \ логики],
  )
  draw.content((4.8, -0.35), text(size: s-tiny, fill: c-muted)[их континуум])
})

// ── Четыре связки линейной логики: умножение и сложение ресурсов ──
#let linear-connectives = canvas({
  let cell(x, y, name, head, body) = {
    draw.rect(
      (x - 1.15, y + 0.6),
      (x + 1.15, y - 0.6),
      fill: c-fl,
      stroke: t-bd + c-bd,
      radius: 4pt,
      name: name,
    )
    draw.content(name, text(
      size: s-node,
      fill: c-ink,
    )[#head #linebreak() #body])
  }

  let row-label(y, body) = draw.content(
    (-1.75, y),
    box(width: 3.6cm, align(right, text(size: s-cap, fill: c-muted)[#body])),
  )

  draw.content((1.35, 5.0), text(size: s-cap, fill: c-muted)[конъюнкция])
  draw.content((4.35, 5.0), text(size: s-cap, fill: c-muted)[дизъюнкция])

  row-label(3.5, [мультипликативные])
  cell(1.35, 3.5, "lc-tensor", $A times.o B$, [оба ресурса \ каждый один раз])
  cell(4.35, 3.5, "lc-par", $A #[⅋] B$, [двойственна тензору])

  row-label(1.5, [аддитивные])
  cell(1.35, 1.5, "lc-with", $A amp B$, [выбирает \ потребитель])
  cell(4.35, 1.5, "lc-plus", $A plus.o B$, [выбирает \ поставщик])
})
