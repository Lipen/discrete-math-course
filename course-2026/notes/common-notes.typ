// Self-contained A4 style for Discrete Math lecture notes.
// No dependency on the slide infrastructure (typst/common.typ, requirements.typ).
// Imported by all topic files and book assembly files.

// --- Package imports ---
#import "@preview/cetz:0.5.2"

// --- Our theorem library ---
#import "theorems.typ": *

// --- Page geometry (A4 book) ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm),
  header: [
    #set text(9pt, fill: luma(40%))
    Discrete Math --- Lecture Notes
    #h(1fr)
    2026/27 ],
)

// --- Typography ---
#set text(font: "Libertinus Serif", size: 12pt, lang: "en")
#set par(justify: true, leading: 0.65em)

// --- Headings ---
#show heading.where(level: 1): set text(size: 24pt, weight: "bold")
#show heading.where(level: 2): set text(size: 18pt, weight: "bold")
#show heading.where(level: 3): set text(size: 14pt, weight: "bold")
#show heading.where(level: 4): set text(size: 12pt, style: "italic")

// --- Number headings (3 levels: 1, 1.1, 1.1.1) ---
#set heading(numbering: "1.1.1")
#show heading.where(level: 1): it => {
  pagebreak()
  counter("definition").update(0)
  counter("theorem").update(0)
  set heading(numbering: it.numbering)
  it
}

// --- Mathematics ---
#set math.mat(column-gap: 1em)
#show sym.emptyset: set text(font: "Libertinus Sans")

// --- Tables ---
#set table(inset: (x: 10pt, y: 4pt))
#show table.cell.where(y: 0): strong

// --- Figures: centered by default ---
#set figure(gap: 8pt)
#show figure: it => align(center, it)

// --- Show i.e., e.g., etc. in italic ---
#show "i.e.": set text(style: "italic")
#show "e.g.": set text(style: "italic")
#show "etc.": set text(style: "italic")
