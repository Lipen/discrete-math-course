#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Локальная семантика: `c-fl` --- обычные участники (Алиса, Боб);
// `c-accent` --- злоумышленник в середине (Ева).
#let mitm = {
  let actor(pos, name, body, fill: c-fl, ink: c-ink) = node(
    pos,
    text(size: s-node, fill: ink)[#body],
    name: name,
    shape: rect,
    width: 2cm,
    height: 0.9cm,
    corner-radius: 4pt,
    fill: fill,
    stroke: t-bd + c-bd,
    inset: 0pt,
  )

  let msg(from, to, sh, label) = edge(
    from,
    to,
    "-}>",
    label: label,
    label-size: s-cap,
    stroke: c-edge + t-ed,
    shift: sh,
  )

  diagram(
    actor((0, 0), <alice>, [Алиса]),
    actor((3.2, 0), <eve>, [Ева], fill: c-accent, ink: white),
    actor((6.4, 0), <bob>, [Боб]),
    msg(<alice>, <eve>, 0.28cm, [$A = g^a$]),
    msg(<eve>, <alice>, 0.28cm, [$B' = g^y$]),
    msg(<bob>, <eve>, -0.28cm, [$B = g^b$]),
    msg(<eve>, <bob>, -0.28cm, [$A' = g^x$]),
    node(
      (3.2, 1.4),
      text(size: s-cap, fill: c-muted)[два секрета: с Алисой и с Бобом],
      fill: none,
      stroke: none,
    ),
  )
}

// ── Решётка делителей D_12 со значениями функции Мёбиуса ──
#let mobius-divisors = {
  let mu-node(pos, name, d, v) = node(
    pos,
    align(center, stack(spacing: 0.45em, d, text(
      size: s-cap,
      fill: c-muted,
    )[$mu(1, #d) = #v$])),
    name: name,
    shape: rect,
    inset: 6pt,
    corner-radius: 4pt,
  )

  diagram(
    node-stroke: c-bd + t-bd,
    node-fill: c-fl,
    edge-stroke: c-edge + t-ed,
    mu-node((0, 2.9), <one>, [$1$], [$1$]),
    mu-node((-1.6, 1.95), <two>, [$2$], [$-1$]),
    mu-node((1.6, 1.95), <three>, [$3$], [$-1$]),
    mu-node((-3.2, 1), <four>, [$4$], [$0$]),
    mu-node((0, 1), <six>, [$6$], [$1$]),
    mu-node((0, 0), <twelve>, [$12$], [$0$]),
    edge(<one>, <two>),
    edge(<one>, <three>),
    edge(<two>, <four>),
    edge(<two>, <six>),
    edge(<three>, <six>),
    edge(<four>, <twelve>),
    edge(<six>, <twelve>),
  )
}

// Точка на круге радиуса r под углом a в градусах.
// Ось Y в диаграммах fletcher направлена вниз, поэтому Y берём с минусом.
#let polar(r, a) = (
  calc.cos(a * calc.pi / 180) * r,
  -calc.sin(a * calc.pi / 180) * r,
)

// ── Цикл степеней тройки по модулю 7 ──
#let gen-cycle = {
  let n-stroke = c-bd + t-bd
  let e-stroke = (paint: c-edge, thickness: t-ed)
  let radius = 1.5
  let nname(i) = label("n" + str(i))
  let values = ($3$, $2$, $6$, $4$, $5$, $1$)

  diagram(
    node-stroke: n-stroke,
    node-fill: c-fl,
    edge-stroke: e-stroke,
    {
      for i in range(6) {
        node(polar(radius, 90 - i * 60), values.at(i), name: nname(i))
        edge(
          nname(i),
          nname(if i == 5 { 0 } else { i + 1 }),
          "-}>",
          label: [$times 3$],
        )
      }
      node((0, 0), $ZZ_7^*$, fill: none, stroke: none)
    },
  )
}
