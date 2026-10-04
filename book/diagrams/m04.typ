// M04 diagrams: диаграммы Венна и пороговый граф.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let r = 0.85

#let v-stroke = (paint: c-edge, thickness: t-ed)

#let venn-label(pos, body) = draw.content(pos, text(
  size: s-node,
  fill: c-ink,
)[#body])

// ── Объединение ──
#let venn-union = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: v-stroke)
  draw.circle((0.35, 0), radius: r, fill: c-conn, stroke: v-stroke)
  venn-label((-r - 0.1, 0), $A$)
  venn-label((r + 0.1, 0), $B$)
  venn-label((0, r + 0.5), $A union B$)
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
  venn-label((-r - 0.1, 0), $A$)
  venn-label((r + 0.1, 0), $B$)
  venn-label((0, r + 0.5), $A inter B$)
})

// ── Разность ──
#let venn-difference = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: none)
  draw.circle((0.35, 0), radius: r, fill: c-white, stroke: v-stroke)
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: v-stroke)
  venn-label((-r - 0.1, 0), $A$)
  venn-label((r + 0.1, 0), $B$)
  venn-label((0, r + 0.5), $A setminus B$)
})

// ── Подмножество ──
#let venn-subset = canvas({
  draw.circle((0, 0), radius: (1.2, r + 0.05), fill: c-conn, stroke: v-stroke)
  venn-label((0.8, 0), $B$)
  draw.circle((-0.35, 0), radius: 0.6, fill: c-fl, stroke: v-stroke)
  venn-label((-0.35, 0), $A$)
  venn-label((0, r + 0.5), $A subset B$)
})

// ── Пороговый граф ──
#let threshold-graph = canvas({
  let th-node(pos, name, body) = {
    draw.circle(pos, radius: 0.4, name: name, fill: c-fl, stroke: v-stroke)
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let th-edge(a, b) = draw.line(a, b, stroke: v-stroke)

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

// ── Дополнение и симметрическая разность ──
#let ca = oklch(72%, 0.1, 250deg).transparentize(55%)
#let cb = oklch(72%, 0.1, 25deg).transparentize(55%)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt
#let venn-r = 0.85
#let label-venn(pos, body) = draw.content(pos, text(size: 0.85em)[#body])

// Дополнение: U \ A, закрашено всё вне круга A.
#let venn-complement = canvas({
  draw.rect((-1.3, -1.15), (1.3, 1.15), fill: ca, stroke: c-str)
  draw.circle((0, 0), radius: venn-r, fill: white, stroke: c-str)
  label-venn((-1.05, 0.9), $U$)
  label-venn((0, 0), $A$)
  label-venn((0, venn-r + 0.5), $overline(A)$)
})

// Симметрическая разность: (A \ B) union (B \ A).
#let venn-symdiff = canvas({
  draw.circle((-0.35, 0), radius: venn-r, fill: ca, stroke: none)
  draw.circle((0.35, 0), radius: venn-r, fill: cb, stroke: none)
  // пересечение вырезается белым
  let ym = calc.sqrt(venn-r * venn-r - 0.35 * 0.35)
  let a-top = calc.atan2(0.35, ym)
  let a-bot = calc.atan2(0.35, -ym)
  let b-top = calc.atan2(-0.35, ym)
  let b-bot = calc.atan2(-0.35, -ym) + 360deg
  draw.arc(
    (0, ym),
    start: a-top,
    stop: a-bot,
    radius: venn-r,
    mode: "CLOSE",
    fill: white,
    stroke: none,
  )
  draw.arc(
    (0, -ym),
    start: b-bot,
    stop: b-top,
    radius: venn-r,
    mode: "CLOSE",
    fill: white,
    stroke: none,
  )
  draw.circle((-0.35, 0), radius: venn-r, fill: none, stroke: c-str)
  draw.circle((0.35, 0), radius: venn-r, fill: none, stroke: c-str)
  label-venn((-venn-r - 0.1, 0), $A$)
  label-venn((venn-r + 0.1, 0), $B$)
  label-venn((0, venn-r + 0.5), $A symdiff B$)
})
