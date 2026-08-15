// Общие окружения и хелперы лекций.
// Math-алиасы НЕ здесь: единый источник --- ../notes/notation.typ.
#import "requirements.typ": *

#let template(dark: false, doc) = {
  // Dark mode
  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  // Fix emptyset symbol
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Setup theorems
  show: ctheorems.thmrules.with(qed-symbol: $square$)

  // Show i.e. in italic:
  show "i.e.": set text(style: "italic")
  // Show e.g. in italic:
  show "e.g.": set text(style: "italic")
  // Show etc. in italic:
  show "etc.": set text(style: "italic")

  // Matrix setup
  set math.mat(column-gap: 1em)

  doc
}

// Horizontal rule
#let hrule = line(length: 100%)

// Blob for fletcher diagrams
#let blob(
  pos,
  label,
  tint: none,
  shape: auto,
  ..args,
) = fletcher.node(
  pos,
  align(center, label),
  fill: if (tint != none) { tint.lighten(80%) } else { auto },
  stroke: if (tint != none) { tint.darken(20%) } else { auto },
  shape: shape,
  ..args,
)

// Colored box around a content
#let fancy-box(
  tint: green,
  diagram-style: (:),
  blob-style: (:),
  content,
) = fletcher.diagram(
  node-corner-radius: 2pt,
  node-stroke: .8pt,
  ..diagram-style,
  blob(
    (0, 0),
    content,
    tint: tint,
    ..blob-style,
  ),
)

// Link with icon
#let href(..args) = link(..args, super(fontawesome.fa-external-link()))

#import ctheorems: *

#let definition = thmbox(
  "definition",
  "Определение",
  fill: rgb("#e8f8e8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let theorem = thmbox(
  "theorem",
  "Теорема",
  fill: rgb("e8e8f8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let corollary = thmbox(
  "corollary",
  "Следствие",
  base: "theorem",
  fill: rgb("f8e8e8"),
  inset: 0.8em,
  padding: (),
)
#let proof = thmproof(
  "proof",
  "Доказательство",
  inset: (x: 0em, y: 0em),
  titlefmt: it => strong(it),
)
#let example = thmplain(
  "example",
  "Пример",
  inset: (x: 0em, y: 0em),
  titlefmt: it => text(style: "italic", it),
).with(numbering: none)
#let examples = example.with(title: "Примеры")
#let note = thmplain(
  "note",
  "Замечание",
  inset: (x: 0em, y: 0em),
  titlefmt: it => strong(it),
).with(numbering: none)
