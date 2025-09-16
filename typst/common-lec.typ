// Note: this file should NOT contain `show` rules!

#let iff = symbol(math.arrow.double.l.r.long, ("not", math.arrow.double.l.r.not))
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let matrel(x) = $bracket.double.l #x bracket.double.r$
#let eqclass(x, R) = $bracket.l #x bracket.r_#R$
#let quotient(M, R) = $M slash_(#R)$
#let Dom = math.op("Dom")
#let Cod = math.op("Cod")
#let Range = math.op("Range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let Join = math.or
#let Meet = math.and
#let nand = $overline(and)$
#let nor = $overline(or)$

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

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

#let CourseOverviewPage() = page(margin: 0pt)[
  #let panel(
    color: white,
    title,
    body,
  ) = block(
    height: 100%,
    width: 100%,
    // fill: color.lighten(85%),
    fill: gradient.linear(
      dir: ttb,
      color.lighten(80%),
      color.lighten(95%),
    ),
  )[
    #stack(
      // Top part:
      box(
        width: 100%,
        height: 50%,
        inset: 1em,
        // stroke: .1pt,
      )[
        #set align(bottom + center)
        #set text(size: 1.4em)
        #box(
          outset: .5em,
          stroke: (bottom: 1pt + color.darken(20%).transparentize(50%)),
        )[
          *#title*
        ]
      ],
      // Bottom part:
      box(
        width: 100%,
        inset: (right: .5em, rest: 1em),
        // stroke: .1pt,
      )[
        #body
      ],
    )
  ]

  #grid(
    columns: 4,
    panel(color: blue)[Set \ Theory][
      - Basic operations
      - Venn diagrams
      - Power sets
      - Cardinality
      - Russell's paradox
      - ZFC axioms
    ],
    panel(color: green)[Binary \ Relations][
      - Relation properties
      - Equivalence classes
      - Partial orders
      - Functions
      - Composition
      - Lattices
    ],
    panel(color: purple)[Boolean \ Algebra][
      - Truth tables
      - Logic circuits
      - Normal forms
      - Karnaugh maps
      - Binary decision diagrams (BDDs)
    ],
    panel(color: orange)[Formal \ Logic][
      - Propositional logic
      - Natural deduction
      - Predicate logic
      - Categorical logic
      - Gödel's theorems
      - Automated reasoning
    ],
  )
]
