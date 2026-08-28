#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let k-radius = 0.55

#let k-cap-gap = 1.0

#let k-edge = t-ed + c-edge

// k-forced-str: зелёная обводка принуждающего мира.
#let k-forced-str = oklch(50%, 0.16, 155deg)

#let kripke-world(pos, name, lbl, caption, fill: c-fl, stroke: t-bd + c-bd) = {
  let (x, y) = pos
  draw.circle(pos, radius: k-radius, fill: fill, stroke: stroke, name: name)
  draw.content(name, text(size: s-node, fill: c-ink)[#lbl])
  draw.content((x, y - k-cap-gap), text(size: s-cap, fill: c-muted)[#caption])
}

// ── Два мира: p принуждается только в v ──
#let kripke-two-worlds = canvas({
  kripke-world((-1.5, 0), "u", $u$, [$p$ не принуждается])
  kripke-world((1.5, 0), "v", $v$, [$p$ принуждается], fill: c-atom, stroke: t-bd + k-forced-str)

  draw.line("u", "v", stroke: k-edge, mark: (end: ">", fill: c-edge), name: "uv")
  draw.content("uv", text(size: s-tiny, fill: c-muted)[$u <= v$], fill: white, stroke: none, padding: 2pt)

  draw.content((0, -1.7), text(size: s-cap, fill: c-muted)[оценка: $V(p) = {v}$])
})

// ── Зонтик: монотонность истинности при движении вверх ──
#let kripke-umbrella = canvas({
  kripke-world((-1.8, 0), "w0", $w_0$, [ни $p$, ни $q$ не принуждаются])
  kripke-world((0.0, 2), "w1", $w_1$, [$p$ и $q$ принуждаются], fill: c-atom, stroke: t-bd + k-forced-str)
  kripke-world((3.2, 2), "w1'", $w_1'$, [$p$ принуждается, $q$ --- нет], fill: c-atom, stroke: t-bd + k-forced-str)

  draw.line("w0", (-1.8, 1.5), (0.0, 1.5), "w1", stroke: k-edge, mark: (end: ">", fill: c-edge), name: "e1")
  draw.line("w0", (-1.8, 1.5), (3.2, 1.5), "w1'", stroke: k-edge, mark: (end: ">", fill: c-edge), name: "e2")

  draw.content((0.7, -1.75), text(size: s-cap, fill: c-muted)[оценка: $V(p) = {w_1, w_1'}$, $V(q) = {w_1}$])
})
