// Декоративная титульная страница: палитра, раскладка полос и орнаменты.
// Микро-тайлы (m-*) живут в diagrams/title.typ.
#import "common.typ": *
#import "diagrams/title.typ": *

#import cetz: canvas, draw

// ── Палитра ──
// Пергамент + золото + тёмно-коричневые чернила.
#let parchment = oklch(94%, 0.01, 80deg)
#let gold = oklch(58%, 0.1, 76deg)
#let gold-soft = oklch(71%, 0.1, 78deg)
#let ink = oklch(31%, 0.05, 70deg)
#let ink-muted = oklch(46%, 0.05, 70deg)

// ── Раскладка полос ──
// Единый зазор между тайлами: один на весь титульник (полосы и углы).
#let tile-gap = 0.45cm

// Ширина плитки фиксирована -- интервалы не гуляют вслед за шириной мотива.
#let tile(body, height: 1.05cm) = box(
  height: height,
  align(center + horizon)[#body],
)

#let band(f, s, motifs, gutter: tile-gap, height: 1.05cm) = grid(
  columns: (auto,) * motifs.len(),
  column-gutter: gutter,
  ..motifs.map(m => tile(m(f: f, s: s), height: height)),
)

// ── Орнаменты ──

// Разделитель: тонкие плечи, центральный ромб, точки-спутники, концевые пипки.
#let orn-rule(width: 5.4, weight: 0.6pt, color: gold) = canvas({
  let half = width / 2
  draw.line((-half, 0), (-0.52, 0), stroke: weight + color)
  draw.line((0.52, 0), (half, 0), stroke: weight + color)
  draw.line(
    (0, 0.105),
    (0.2, 0),
    (0, -0.105),
    (-0.2, 0),
    close: true,
    fill: color,
    stroke: none,
  )
  for x in (-0.35, 0.35) {
    draw.circle((x, 0), radius: 0.035, fill: color, stroke: none)
  }
  for x in (-half, half) {
    draw.circle((x, 0), radius: 0.04, fill: color, stroke: none)
  }
})

// Угловой уголок страницы: (sx, sy) задают, в какую сторону смотрят плечи.
#let corner-orn(sx, sy, color: gold) = canvas({
  let L = 0.85
  draw.line(
    (0, sy * L),
    (0, 0),
    (sx * L, 0),
    stroke: 0.55pt + color.transparentize(15%),
  )
  draw.line(
    (sx * 0.15, sy * 0.15),
    (sx * 0.15, sy * 0.5),
    stroke: 0.35pt + color.transparentize(45%),
  )
  draw.line(
    (sx * 0.15, sy * 0.15),
    (sx * 0.5, sy * 0.15),
    stroke: 0.35pt + color.transparentize(45%),
  )
  draw.line(
    (0, 0.1),
    (0.1, 0),
    (0, -0.1),
    (-0.1, 0),
    close: true,
    fill: color,
    stroke: none,
  )
})

// ── Титульная страница ──
#let title-page() = {
  // Своя страница: пергамент + золото + узкие поля (только для титульника).
  set page(
    paper: "a4",
    margin: (left: 2.2cm, right: 2.2cm, top: 2.0cm, bottom: 2.0cm),
    header: none,
    footer: none,
    background: rect(fill: parchment, width: 100%, height: 100%),
  )

  align(center + horizon)[
    #block(
      stroke: 0.35pt + gold.transparentize(20%),
      inset: (x: 1.2em, y: 0.35em),
      width: auto,
    )[
      #block(
        stroke: (
          top: 1pt + gold,
          bottom: 1pt + gold,
          left: 0.5pt + gold.transparentize(40%),
          right: 0.5pt + gold.transparentize(40%),
        ),
        inset: (x: 2em, y: 1.1em),
        width: 15.4cm,
        height: 20cm,
      )[
        #align(center)[
          // Первый ряд сверху.
          #band(gold-soft, gold-soft, (
            m-venn, m-logic, m-truth, m-k4, m-binom, m-3venn, m-tree, m-matrix, m-poset,
          ))
          #v(0.5em)

          // Второй ряд сверху: угловые герои.
          #block(width: 100%)[
            #box[#band(gold-soft, gold-soft, (m-derive, m-ferrers, m-modclock))]
            #h(1fr)
            #box[#band(gold-soft, gold-soft, (m-petersen, m-fn))]
          ]
          #v(1fr)

          #text(
            size: 9.5pt,
            weight: "semibold",
            fill: ink-muted,
            tracking: 0.24em,
          )[#upper[Университет ИТМО]]
          #v(0.9em)

          // Греческое герой-заглавие.
          #text(
            size: 27pt,
            weight: "bold",
            fill: ink,
            font: "Libertinus Serif",
            tracking: 0.09em,
          )[ΔΙΑΚΡΙΤΑ]
          #v(0.1em)
          #text(
            size: 28pt,
            weight: "bold",
            fill: ink,
            font: "Libertinus Serif",
            tracking: 0.09em,
          )[ΜΑΘΗΜΑΤΙΚΑ]

          #v(1.5em, weak: true)
          #orn-rule(width: 6.0, weight: 0.75pt, color: gold)
          #v(1.5em, weak: true)

          #text(
            size: 18pt,
            weight: "medium",
            fill: ink,
            font: "Libertinus Serif",
          )[Дискретная математика]
          #v(0.3em)
          #text(
            fill: ink-muted,
            tracking: 0.06em,
          )[конспект лекций]
          #v(1fr)

          #orn-rule(width: 3.6, weight: 0.5pt, color: gold.transparentize(15%))
          #v(1fr)

          #text(
            size: 14pt,
            weight: "semibold",
            fill: ink,
          )[Константин Чухарев]
          #v(0.35em, weak: true)
          #text(size: 10pt, fill: ink-muted)[Университет ИТМО]
          #v(1.5em, weak: true)
          #text(size: 10pt, fill: ink-muted)[MMXXVI--MMXXVII]
          #v(1fr)

          // Второй ряд снизу: угловые герои.
          #block(width: 100%)[
            #box[#band(gold-soft, gold-soft, (m-diag, m-bipartite))]
            #h(1fr)
            #box[#band(gold-soft, gold-soft, (m-compose, m-fuzzy))]
          ]
          #v(0.5em)

          // Первый ряд снизу.
          #band(gold-soft, gold-soft, (
            m-cube, m-gate, m-judgement, m-dfa, m-pascal, m-hamming, m-tape, m-combinator, m-pairing,
          ))
        ]
      ]
    ]
  ]

  // Угловые уголки страницы.
  place(top + left, dx: -0.75cm, dy: -0.75cm, corner-orn(1, -1))
  place(top + right, dx: 0.75cm, dy: -0.75cm, corner-orn(-1, -1))
  place(bottom + left, dx: -0.75cm, dy: 0.75cm, corner-orn(1, 1))
  place(bottom + right, dx: 0.75cm, dy: 0.75cm, corner-orn(-1, 1))
}
