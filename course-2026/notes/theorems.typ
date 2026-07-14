// Custom theorem environments — pure Typst block + counter.
// Numbering resets at each = Heading chapter.
// API:
//   #definition[body]                 #definition[Subtitle][body]
//   #theorem[body]                    #theorem[Name][body]
//   #lemma[body]                      #lemma[Name][body]
//   #corollary[body]                  #corollary[Name][body]
//   #proposition[body]                #proposition[Name][body]
//   #proof[body]                      #proof-sketch[body]
//   #example[body]                    #example[Title][body]
//   #note[body]                       #note[Title][body]
//   #remark[body]                     #remark[Title][body]
//   #chapter-overview[body]
//   #hrule

#let def-ctr = counter("definition")
#let thm-ctr = counter("theorem")

// --- Display chapter-prefixed number: "2.14" ---
#let _ch-num(ctr) = context {
  let h = counter(heading).at(here())
  let ch = if h != none { h.first() }
  let n = ctr.at(here()).first()
  if ch != none and n != none { [#ch.#n] } else if n != none { [#n] }
}

#let _numbered(label, ctr, bar-color, body) = {
  ctr.step()
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.8em, bottom: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#label #_ch-num(ctr)]
    #v(0.25em)
    #body
  ]
}

#let _numbered-sub(label, subtitle, ctr, bar-color, body) = {
  ctr.step()
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.8em, bottom: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#label #_ch-num(ctr) (#subtitle)]
    #v(0.25em)
    #body
  ]
}

#let _dispatch(label, ctr, bar-color, ..args) = {
  let pos = args.pos()
  if pos.len() >= 2 {
    _numbered-sub(label, pos.at(0), ctr, bar-color, pos.at(1))
  } else {
    _numbered(label, ctr, bar-color, pos.at(0))
  }
}

#let definition(..args) = _dispatch(
  "Definition",
  def-ctr,
  oklch(55%, 0.18, 155deg),
  ..args,
)
#let theorem(..args) = _dispatch(
  "Theorem",
  thm-ctr,
  oklch(55%, 0.15, 250deg),
  ..args,
)
#let lemma(..args) = _dispatch(
  "Lemma",
  thm-ctr,
  oklch(55%, 0.14, 300deg),
  ..args,
)
#let corollary(..args) = _dispatch(
  "Corollary",
  thm-ctr,
  oklch(55%, 0.18, 22deg),
  ..args,
)
#let proposition(..args) = _dispatch(
  "Proposition",
  thm-ctr,
  oklch(55%, 0.16, 195deg),
  ..args,
)

// --- QED placement ---
// Use #qed manually inside a proof body to place the QED symbol.
// Show rules handle proper placement inside lists, block equations, and plain text.
#let qed = metadata("qed-here")

#let _has-qed(x) = {
  if x == "qed-here" { return true }
  if type(x) == content {
    for (_, c) in x.fields() {
      if _has-qed(c) { return true }
    }
  }
  if type(x) == array {
    for c in x {
      if _has-qed(c) { return true }
    }
  }
  false
}

// Call once from common-notes.typ after all imports.
#let setup-qed-rules() = {
  show metadata.where(value: "qed-here"): it => {
    h(1fr)
    $square$
  }

  show math.equation.where(block: true): eq => {
    if _has-qed(eq.body) {
      grid(
        columns: (1fr, auto, 1fr),
        [], eq, align(right + horizon)[$square$],
      )
    } else {
      eq
    }
  }

  show enum.item: it => {
    show metadata.where(value: "qed-here"): it => {
      h(1fr)
      $square$
    }
    it
  }

  show list.item: it => {
    show metadata.where(value: "qed-here"): it => {
      h(1fr)
      $square$
    }
    it
  }
}

#let proof(body) = {
  block(
    fill: luma(97%),
    stroke: (left: 2pt + luma(78%), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[Proof.]
    #body
  ]
}

#let proof-sketch(body) = {
  block(
    fill: luma(97%),
    stroke: (left: 2pt + luma(78%), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[Proof sketch.]
    #body
  ]
}

#let example(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    (none, pos.at(0))
  }
  block(
    fill: luma(97%),
    stroke: (left: 2pt + luma(82%), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #text(style: "italic")[Example#if title != none { [ (#title)] }: ]
    #v(0.2em)
    #body
  ]
}

#let note(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    ([Note: #(pos.at(0))], pos.at(1))
  } else {
    ([Note], pos.at(0))
  }
  block(
    fill: oklch(97%, 0.006, 155deg),
    stroke: (left: 3pt + oklch(55%, 0.15, 155deg), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#title.] #body
  ]
}

#let remark(..args) = {
  let pos = args.pos()
  let (title, body) = if pos.len() >= 2 {
    ([Remark: #(pos.at(0))], pos.at(1))
  } else {
    ([Remark], pos.at(0))
  }
  block(
    fill: oklch(97%, 0.006, 70deg),
    stroke: (
      left: 3pt + oklch(55%, 0.16, 75deg),
      top: 0.5pt + luma(84%),
      bottom: 0.5pt + luma(84%),
      right: 0.5pt + luma(84%),
    ),
    inset: (x: 1em, y: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #strong[#title.] #body
  ]
}

#let chapter-overview(body) = {
  block(
    fill: luma(95%),
    inset: 1em,
    radius: 4pt,
    width: 100%,
  )[
    #body
  ]
}

#let hrule = line(length: 100%)
