// Custom theorem environments for Discrete Math lecture notes.
// Zero third-party dependencies — pure Typst block + counter.
//
// API:
//   #definition[body]                — numbered, no subtitle
//   #definition[Subtitle][body]      — numbered with subtitle
//   #theorem[body] / #theorem[Name][body]
//   #lemma[body] / #lemma[Name][body]
//   #corollary[body] / #corollary[Name][body]
//   #proposition[body] / #proposition[Name][body]
//   #proof[body]                     — with QED square
//   #proof-sketch[body]              — light, no QED
//   #example[body]                   — italic title, unnumbered
//   #note[body]                      — bold title, unnumbered
//   #remark[body]                    — boxed, bold title, unnumbered

// --- Counters ---
#let def-ctr = counter("definition")
#let thm-ctr = counter("theorem")

// --- Internal: numbered block with left color bar ---
#let _numbered(label, ctr, bar-color, body) = {
  ctr.step()
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#label #context ctr.display()]
    #v(0.25em)
    #body
  ]
}

// --- Internal: numbered block with subtitle ---
#let _numbered-sub(label, subtitle, ctr, bar-color, body) = {
  ctr.step()
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#label #context ctr.display() (#subtitle)]
    #v(0.25em)
    #body
  ]
}

// --- Helper: sink-based dispatch for 1 or 2 content blocks ---
// #env[body]              → pos.len() = 1, pos.at(0) = body
// #env[Subtitle][body]    → pos.len() ≥ 2, pos.at(0) = subtitle, pos.at(1) = body
#let _dispatch(label, ctr, bar-color, ..args) = {
  let pos = args.pos()
  if pos.len() >= 2 {
    _numbered-sub(label, pos.at(0), ctr, bar-color, pos.at(1))
  } else {
    _numbered(label, ctr, bar-color, pos.at(0))
  }
}

// --- Numbered environments ---
// Left-bar colors: saturated, distinct, readable against light backgrounds.
#let definition(..args) = _dispatch(
  "Definition",
  def-ctr,
  oklch(55%, 0.18, 155deg), // green
  ..args,
)
#let theorem(..args) = _dispatch(
  "Theorem",
  thm-ctr,
  oklch(55%, 0.15, 250deg), // blue
  ..args,
)
#let lemma(..args) = _dispatch(
  "Lemma",
  thm-ctr,
  oklch(55%, 0.14, 300deg), // purple
  ..args,
)
#let corollary(..args) = _dispatch(
  "Corollary",
  thm-ctr,
  oklch(55%, 0.18, 22deg), // red
  ..args,
)
#let proposition(..args) = _dispatch(
  "Proposition",
  thm-ctr,
  oklch(60%, 0.16, 80deg), // amber
  ..args,
)

// --- Proof environments ---
#let proof(body) = {
  block(inset: (x: 0em, y: 0em), width: 100%)[
    #strong[Proof.]
    #body
    #align(right, $square$)
  ]
}

#let proof-sketch(body) = {
  block(inset: (x: 0em, y: 0em), width: 100%)[
    #strong[Proof sketch.]
    #body
  ]
}

// --- Unnumbered environments (support 1 or 2 content blocks) ---
#let example(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    ([Example], pos.at(0))
  }
  block(inset: (x: 0em, y: 0.4em), width: 100%)[
    #text(style: "italic")[#title]
    #body
  ]
}

#let note(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    ([Note], pos.at(0))
  }
  block(inset: (x: 0em, y: 0.4em), width: 100%)[
    #strong[#title]
    #body
  ]
}

#let remark(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    ([Remark], pos.at(0))
  }
  block(
    fill: rgb("#fafafa"),
    stroke: 0.5pt + luma(80%),
    inset: (x: 1em, y: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#title]
    #body
  ]
}

// --- Chapter overview ---
#let chapter-overview(body) = {
  block(
    fill: luma(95%),
    inset: 1em,
    radius: 4pt,
    width: 100%,
  )[
    #set text(size: 11pt)
    #body
  ]
}

// --- Horizontal rule ---
#let hrule = line(length: 100%)
