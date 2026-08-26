// m18 diagrams: meet-in-the-middle атака на обмен ключами Диффи--Хеллмана.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// Локальная семантика: `c-fl` --- обычные участники (Алиса, Боб);
// `c-accent` --- злоумышленник в середине (Ева).
#let mitm = canvas({
  let hw = 1.0
  let hh = 0.45

  let actor(pos, label, fill: c-fl) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y + hh),
      (x + hw, y - hh),
      name: label,
      fill: fill,
      stroke: t-bd + c-bd,
      radius: 4pt,
    )
    let ink = if fill == c-accent { white } else { c-ink }
    draw.content(label, text(size: s-node, fill: ink)[#label])
  }

  let swap(from-name, from, to-name, to, dy, label) = {
    let (fx, fy) = from
    let (tx, ty) = to
    let s = if tx > fx { 1 } else { -1 }
    let e-name = from-name + "-" + to-name
    draw.line(
      (fx + s * hw, fy + dy),
      (tx - s * hw, ty + dy),
      name: e-name,
      stroke: c-edge + t-ed,
      mark: (end: "stealth", fill: c-edge),
    )
    draw.content(
      e-name,
      text(size: s-cap, fill: c-ink)[#label],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  actor((-3.6, 0), "Алиса")
  actor((0, 0), "Ева", fill: c-accent)
  actor((3.6, 0), "Боб")

  swap("Алиса", (-3.6, 0), "Ева", (0, 0), 0.28, [$A = g^a$])
  swap("Ева", (0, 0), "Алиса", (-3.6, 0), -0.28, [$B' = g^y$])
  swap("Боб", (3.6, 0), "Ева", (0, 0), 0.28, [$B = g^b$])
  swap("Ева", (0, 0), "Боб", (3.6, 0), -0.28, [$A' = g^x$])

  draw.content(
    (0, -1.4),
    text(size: s-cap, fill: c-muted)[два секрета: с Алисой и с Бобом],
  )
})
