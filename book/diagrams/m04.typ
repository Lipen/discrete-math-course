#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let r = 0.85

#let v-stroke = (paint: c-edge, thickness: t-ed)

#let label(pos, body) = draw.content(pos, text(
  size: s-node,
  fill: c-ink,
)[#body])

// ── Объединение ──
#let venn-union = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: v-stroke)
  draw.circle((0.35, 0), radius: r, fill: c-conn, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A union B$)
})

// ── Пересечение ──
#let venn-intersection = canvas({
  let ym = calc.sqrt(r * r - 0.35 * 0.35)
  let a-top = calc.atan2(0.35, ym)
  let a-bot = calc.atan2(0.35, -ym)
  let b-top = calc.atan2(-0.35, ym)
  let b-bot = calc.atan2(-0.35, -ym) + 360deg

  draw.arc(
    (0, ym),
    start: a-top,
    stop: a-bot,
    radius: r,
    mode: "CLOSE",
    fill: c-fl,
    stroke: none,
  )
  draw.arc(
    (0, -ym),
    start: b-bot,
    stop: b-top,
    radius: r,
    mode: "CLOSE",
    fill: c-fl,
    stroke: none,
  )
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: v-stroke)
  draw.circle((0.35, 0), radius: r, fill: none, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

// ── Разность ──
#let venn-difference = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: none)
  draw.circle((0.35, 0), radius: r, fill: c-white, stroke: v-stroke)
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

// ── Подмножество ──
#let venn-subset = canvas({
  draw.circle((0, 0), radius: (1.2, r + 0.05), fill: c-conn, stroke: v-stroke)
  label((0.8, 0), $B$)
  draw.circle((-0.35, 0), radius: 0.6, fill: c-fl, stroke: v-stroke)
  label((-0.35, 0), $A$)
  label((0, r + 0.5), $A subset B$)
})

// ── Пороговый граф ──
#let th-node(pos, name, body) = {
  draw.circle(pos, radius: 0.4, name: name, fill: c-fl, stroke: v-stroke)
  draw.content(name, text(size: s-node, fill: c-ink)[#body])
}

#let th-edge(a, b) = draw.line(a, b, stroke: (paint: c-edge, thickness: t-ed))

#let threshold-graph = canvas({
  let pos = ((0, 2.1), (-1.9, 0.65), (1.9, 0.65), (-1.2, -1.7), (1.2, -1.7))
  let names = ("A", "B", "C", "D", "E")
  let labels = ($A_5$, $B_4$, $C_3$, $D_2$, $E_1$)
  for i in range(5) {
    th-node(pos.at(i), names.at(i), labels.at(i))
  }
  for (a, b) in (
    ("A", "B"),
    ("A", "C"),
    ("A", "D"),
    ("A", "E"),
    ("B", "C"),
    ("B", "D"),
  ) {
    th-edge(a, b)
  }
})
