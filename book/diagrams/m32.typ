#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *
#import cetz: canvas, draw
// Светлый акцент: выделенные утверждения (промежуточные, инварианты).
#let c-know = oklch(87%, 0.06, 230deg)

#let a-box(pos, size, body, fill: c-atom, name: none) = {
  let (w, h) = size
  let (x, y) = pos
  draw.rect(
    (x - w / 2, y + h / 2),
    (x + w / 2, y - h / 2),
    fill: fill,
    stroke: t-bd + c-bd,
    radius: 6pt,
    name: name,
  )
  draw.content((x, y), text(size: s-node, weight: "bold", fill: c-ink)[#body])
}

#let flow(from, to, ..args) = draw.line(
  from,
  to,
  stroke: c-edge + t-ed,
  mark: (end: (symbol: ">", fill: c-edge)),
  ..args,
)

#let under(pos, body) = draw.content(pos, text(
  size: s-cap,
  fill: c-muted,
)[#body])

#let decide(pos, radius: 0.62, name: none, body) = {
  let (x, y) = pos
  draw.line(
    (x, y + radius),
    (x + radius, y),
    (x, y - radius),
    (x - radius, y),
    close: true,
    fill: c-fl,
    stroke: t-bd + c-bd,
    name: name,
  )
  draw.content(pos, text(size: s-node, weight: "bold", fill: c-ink)[#body])
}

// ── Тройка Хоара ──
#let hoare-triple = {
  canvas({
    a-box((-2.2, 0), (0.95, 0.9), $ {P} $, name: "p")
    a-box((0, 0), (1.9, 1.15), $S$, fill: c-conn, name: "s")
    a-box((2.2, 0), (0.95, 0.9), $ {Q} $, name: "q")
    flow("p.east", "s.west")
    flow("s.east", "q.west")
    under((-2.2, -0.85), [предусловие])
    under((0, -0.85), [оператор])
    under((2.2, -0.85), [постусловие])
  })
}

// ── Композиция ──
#let composition-rule = {
  canvas({
    a-box((-3.1, 0), (0.95, 0.9), $ {P} $, name: "p")
    a-box((-1.6, 0), (1.2, 1.0), $S_1$, fill: c-conn, name: "s1")
    a-box((0.2, 0), (1.1, 0.85), $ {R} $, fill: c-know, name: "r")
    a-box((2.0, 0), (1.2, 1.0), $S_2$, fill: c-conn, name: "s2")
    a-box((3.5, 0), (0.95, 0.9), $ {Q} $, name: "q")
    flow("p.east", "s1.west")
    flow("s1.east", "r.west")
    flow("r.east", "s2.west")
    flow("s2.east", "q.west")
    under((0.2, -0.8), [промежуточное условие])
  })
}

// ── Правило условного оператора ──
#let if-rule = {
  canvas({
    a-box((0, 3.0), (1.0, 0.9), $ {P} $, name: "p")
    decide((0, 1.6), name: "b", [$B$])
    a-box((-1.8, 0.2), (1.3, 0.95), $S_1$, fill: c-conn, name: "s1")
    a-box((1.8, 0.2), (1.3, 0.95), $S_2$, fill: c-conn, name: "s2")
    a-box((0, -1.55), (1.0, 0.9), $ {Q} $, name: "q")
    flow("p.south", (0, 2.22))
    flow((-0.62, 1.6), "s1.north")
    flow((0.62, 1.6), "s2.north")
    flow("s1.south", "q.west")
    flow("s2.south", "q.east")
    draw.content((-1.35, 1.05), text(size: s-tiny, fill: c-muted)[истина])
    draw.content((1.35, 1.05), text(size: s-tiny, fill: c-muted)[ложь])
    under((-1.8, -0.55), [$P and B$])
    under((1.8, -0.55), [$P and not B$])
  })
}

// ── Правило цикла с инвариантом ──
#let while-invariant = {
  canvas({
    a-box((0, 3.4), (1.0, 0.9), $ {P} $, name: "p")
    a-box((0, 2.35), (1.15, 0.78), $I$, fill: c-know, name: "inv")
    decide((0, 1.15), name: "b", [$B$])
    a-box((1.95, 1.15), (1.25, 0.95), $S$, fill: c-conn, name: "s")
    a-box((0, -0.6), (1.3, 0.82), $I and not B$, fill: c-know, name: "exit")
    a-box((0, -1.8), (1.0, 0.9), $ {Q} $, name: "q")
    flow("p.south", "inv.north")
    flow("inv.south", (0, 1.77))
    flow((0.62, 1.15), "s.west")
    draw.line(
      (1.95, 1.55),
      (1.95, 2.35),
      (0.575, 2.35),
      stroke: c-edge + t-ed,
      mark: (end: (symbol: ">", fill: c-edge)),
    )
    flow((0, 0.53), "exit.north")
    flow("exit.south", "q.north")
    draw.content((1.15, 1.35), text(size: s-tiny, fill: c-muted)[истина])
    draw.content((0.45, 0.42), text(size: s-tiny, fill: c-muted)[ложь])
    under((2.7, 1.7), [тело сохраняет $I$])
    under((-1.2, 2.35), [база])
    under((-1.2, -0.6), [выход])
  })
}

// ── Вариант цикла ──
#let variant-descent = {
  canvas({
    a-box((0, 3.0), (1.15, 0.9), $f = z$, fill: c-conn, name: "top")
    a-box((0, 1.5), (1.15, 0.9), $f'$, fill: c-conn, name: "mid")
    a-box((0, 0), (1.15, 0.9), $f''$, fill: c-conn, name: "bot")
    draw.content((0, -1.1), text(size: s-node, fill: c-muted)[$dots$])
    flow("top.south", "mid.north")
    flow("mid.south", "bot.north")
    under((2.0, 2.2), [строго убывает])
    under((2.0, 0.6), [вполне упорядочено])
  })
}
