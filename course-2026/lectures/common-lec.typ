// Note: this file should NOT contain `show` rules!
// Алиасы True/False/Green/Red/iff живут в ../notes/notation.typ (единый источник).
#import "../notes/notation.typ": Green, Red

#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $chevron.l #a, #b chevron.r$

#let Blue(x) = text(blue.darken(20%), x)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#let Block(
  color: blue,
  body,
  ..args,
) = block(
  body,
  fill: color.lighten(90%),
  stroke: 1pt + color.darken(20%),
  radius: 5pt,
  inset: 1em,
  ..args.named(),
)
