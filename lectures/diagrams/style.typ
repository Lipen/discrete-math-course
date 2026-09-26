// Единые токены и примитивы для лекционных диаграмм.
#import "@preview/cetz:0.5.2": draw

#let ink = oklch(32%, 0.02, 265deg)
#let ink-soft = oklch(72%, 0.02, 265deg)

#let cool = oklch(52%, 0.11, 250deg)
#let warm = oklch(55%, 0.12, 25deg)
#let green = oklch(50%, 0.10, 155deg)
#let amber = oklch(62%, 0.13, 70deg)
#let violet = oklch(50%, 0.11, 300deg)

#let fill-soft = oklch(88%, 0.03, 250deg)
#let panel-cool = oklch(96%, 0.015, 250deg)
#let panel-warm = oklch(96%, 0.02, 25deg)
#let panel-green = oklch(96%, 0.02, 155deg)

#let edge-plain = (paint: oklch(45%, 0.03, 265deg), thickness: 0.9pt, cap: "round")
#let edge-thin = (paint: oklch(45%, 0.03, 265deg), thickness: 0.5pt, cap: "round")
#let edge-soft = (paint: ink-soft, thickness: 0.5pt, dash: "dashed", cap: "round")
#let edge-hot = (paint: oklch(55%, 0.17, 25deg), thickness: 2.4pt, cap: "round")
#let edge-cool = (paint: cool, thickness: 2pt, cap: "round")
#let edge-green = (paint: green, thickness: 2pt, cap: "round")

#let panel(from, to, tone: cool, fill: panel-cool, radius: 0.26) = draw.rect(
  from,
  to,
  radius: radius,
  fill: fill,
  stroke: 0.7pt + tone.lighten(45%),
)

#let vertex(name, pos, tone: cool, size: 0.31) = draw.circle(
  pos,
  radius: size,
  fill: white,
  stroke: 1.4pt + tone,
  name: name,
)

#let cell(name, pos, tone: cool, size: 0.29, radius: 0.1) = draw.rect(
  (pos.at(0) - size, pos.at(1) - size),
  (pos.at(0) + size, pos.at(1) + size),
  radius: radius,
  fill: white,
  stroke: 1.4pt + tone,
  name: name,
)

#let tie(a, b, ctrl, style: edge-plain, from: "east", to: "west") = draw.bezier(
  a + "." + from,
  b + "." + to,
  ctrl,
  stroke: style,
)

#let mark(pos, body, tone: ink, size: 0.42em) = draw.content(
  pos,
  text(size: size, fill: tone)[#body],
)
