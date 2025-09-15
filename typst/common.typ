#import "requirements.typ": *

#let template(dark: false, doc) = {
  // Dark mode
  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  // Fix emptyset symbol
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Setup theorems
  show: ctheorems.thmrules.with(qed-symbol: $square$)

  doc
}

// Horizontal rule
#let hrule = line(length: 100%)

// Blob for fletcher diagrams
#let blob(
  pos,
  label,
  tint: white,
  shape: fletcher.shapes.rect,
  ..args,
) = fletcher.node(
  pos,
  align(center, label),
  fill: if (tint != none) { tint.lighten(80%) },
  stroke: if (tint != none) { tint.darken(20%) },
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

// Aliases
#let neg = sym.not
#let imply = sym.arrow.r
#let implies = imply
#let iff = sym.arrow.l.r
#let to = sym.arrow.r
#let maps = sym.arrow.bar
#let neq = sym.eq.not
#let leq = sym.lt.eq
#let geq = sym.gt.eq
#let models = sym.tack.double
#let entails = sym.tack.r
#let notin = sym.in.not
#let setminus = sym.without
#let intersect = sym.inter
#let symdiff = sym.triangle
#let sim = sym.tilde

#import ctheorems: *

#let definition = thmbox(
  "definition",
  "Definition",
  fill: rgb("#e8f8e8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("e8e8f8"),
  inset: 0.8em,
  padding: (),
  base_level: 0,
)
#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",
  fill: rgb("f8e8e8"),
  inset: 0.8em,
  padding: (),
)
#let proof = thmproof(
  "proof",
  "Proof",
  inset: (x: 0em, y: 0em),
  titlefmt: it => strong(it),
)
#let example = thmplain(
  "example",
  "Example",
  inset: (x: 0em, y: 0em),
  titlefmt: it => text(style: "italic", it),
).with(numbering: none)
#let examples = example.with(title: "Examples")
#let note = thmplain(
  "note",
  "Note",
  inset: (x: 0em, y: 0em),
  titlefmt: it => strong(it),
).with(numbering: none)
