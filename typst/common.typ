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
) = {
  fletcher.diagram(
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
}

// Fitch-style proofs
#let fitch(..args) = derive-it.ded-nat(arr: args.pos(), ..args.named())
#let fitch-boxed(..args) = derive-it.ded-nat-boxed(arr: args.pos(), ..args.named())

// Link with icon
#let href(..args) = link(..args, super(fontawesome.fa-external-link()))

// Aliases
#let neg = sym.not
#let imply = sym.arrow.r
#let implies = imply
#let iff = sym.arrow.l.r
#let to = sym.arrow.long.r
#let maps = sym.arrow.bar
#let neq = sym.eq.not
#let leq = sym.lt.eq
#let geq = sym.gt.eq
#let models = sym.tack.double
#let entails = sym.tack.r
#let notin = sym.in.not
#let setminus = sym.backslash
#let intersect = sym.inter
#let dom = math.op("dom")
