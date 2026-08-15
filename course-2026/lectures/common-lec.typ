// Note: this file should NOT contain `show` rules!
// Алиасы True/False/Green/Red/iff живут в ../notes/notation.typ (единый источник).
#import "../notes/notation.typ": Green, Red
#import "common.typ": accent, accent-strong, amber, teal, violet, warn

#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $chevron.l #a, #b chevron.r$

#let Blue(x) = text(fill: accent-strong, x)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

// Карточка: левая полоса, лёгкий градиент, скругление.
// color --- акцент блока (accent для применений, amber для выводов, warn для предупреждений).
#let Block(
  color: accent,
  body,
  ..args,
) = block(
  body,
  fill: gradient.linear(angle: 0deg, color.lighten(86%), color.lighten(96%)),
  stroke: (
    left: 3pt + color.darken(10%),
    top: 0.6pt + color.lighten(55%),
    bottom: 0.6pt + color.lighten(55%),
    right: 0.6pt + color.lighten(55%),
  ),
  radius: 4pt,
  inset: (x: 0.85em, y: 0.45em),
  ..args.named(),
)
