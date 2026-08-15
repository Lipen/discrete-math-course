// Общие окружения и хелперы лекций.
// Стиль «тёплая книга»: oklch-палитра, плоские прозрачные карточки с левой полосой.
// Math-алиасы НЕ здесь: единый источник --- ../notes/notation.typ.
#import "requirements.typ": *

// --- Палитра ---
#let accent = oklch(52%, 0.15, 245deg) // сине-индиго, основной
#let accent-strong = oklch(42%, 0.14, 250deg) // для заголовков-акцентов
#let amber = oklch(70%, 0.17, 80deg) // янтарный, ключевые выводы
#let warn = oklch(58%, 0.18, 40deg) // оранжевый, предупреждения
#let violet = oklch(55%, 0.15, 300deg) // фиолетовый, теоремы
#let teal = oklch(56%, 0.12, 195deg) // бирюзовый, примечания

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

// Карточка: прозрачная заливка (tint), левая полоса (bar).
#let card(bar, tint) = (
  fill: tint,
  stroke: (
    left: 3pt + bar,
    top: 0.6pt + bar.lighten(55%),
    bottom: 0.6pt + bar.lighten(55%),
    right: 0.6pt + bar.lighten(55%),
  ),
  radius: 4pt,
)

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
  ..card(accent-strong, accent.transparentize(85%)),
  inset: (x: 1em, y: 0.6em),
  padding: (),
  base_level: 0,
  titlefmt: it => text(fill: accent-strong, weight: "bold", it),
)
#let theorem = thmbox(
  "theorem",
  "Теорема",
  ..card(violet.darken(10%), violet.transparentize(84%)),
  inset: (x: 1em, y: 0.6em),
  padding: (),
  base_level: 0,
  titlefmt: it => text(fill: violet.darken(15%), weight: "bold", it),
)
#let corollary = thmbox(
  "corollary",
  "Следствие",
  base: "theorem",
  ..card(violet.darken(10%), violet.transparentize(84%)),
  inset: (x: 1em, y: 0.6em),
  padding: (),
  titlefmt: it => text(fill: violet.darken(15%), weight: "bold", it),
)
#let proof = thmproof(
  "proof",
  "Доказательство",
  fill: accent.transparentize(92%),
  stroke: (
    left: 2.5pt + accent.lighten(40%),
    top: 0.5pt + luma(88%),
    bottom: 0.5pt + luma(88%),
    right: 0.5pt + luma(88%),
  ),
  radius: 4pt,
  inset: (x: 1em, y: 0.5em),
  titlefmt: it => strong(it),
)
#let example = thmplain(
  "example",
  "Пример",
  fill: luma(96%),
  stroke: (
    left: 2.5pt + luma(80%),
    top: 0.5pt + luma(90%),
    bottom: 0.5pt + luma(90%),
    right: 0.5pt + luma(90%),
  ),
  radius: 4pt,
  inset: (x: 1em, y: 0.5em),
  titlefmt: it => text(style: "italic", it),
).with(numbering: none)
#let examples = example.with(title: "Примеры")
#let note = thmplain(
  "note",
  "Замечание",
  ..card(teal.darken(10%), teal.transparentize(85%)),
  inset: (x: 1em, y: 0.6em),
  titlefmt: it => strong(text(fill: teal.darken(20%), it)),
).with(numbering: none)
