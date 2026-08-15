// Note: this file should NOT contain `show` rules!
// Алиасы True/False/Green/Red/iff живут в ../notes/notation.typ (единый источник).
#import "../notes/notation.typ": Green, Red
#import "common.typ": colors

#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $chevron.l #a, #b chevron.r$

#let Blue(x) = text(fill: colors.accent-strong, x)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

// Карточка: плоская прозрачная заливка, левая полоса, скругление.
// color --- акцент блока (colors.accent для применений, colors.amber для выводов, colors.warn для предупреждений).
#let Block(
  color: colors.accent,
  body,
  ..args,
) = block(
  body,
  fill: color.transparentize(90%),
  stroke: (
    left: 3pt + color.darken(10%),
    top: 0.5pt + color.lighten(50%),
    bottom: 0.5pt + color.lighten(50%),
    right: 0.5pt + color.lighten(50%),
  ),
  radius: 4pt,
  inset: (x: 1em, y: 0.5em),
  ..args.named(),
)
