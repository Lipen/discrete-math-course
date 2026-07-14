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
//   #remark[body]                     #remark(inline: true)[body]
//   #remark[Title][body]              #note(inline: true)[body]
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

// Parse ..args sink into (subtitle, body) pair.
#let _args(pos) = {
  if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    (none, pos.at(0))
  }
}

// Shared helper: colored block with title and body.
#let _block(
  title: none,
  fill: none,
  stroke: none,
  inset: none,
  inline: false,
  it: none,
) = {
  block(
    ..if fill != none { (fill: fill) } else { () },
    stroke: stroke,
    inset: inset,
    radius: 3pt,
    width: 100%,
  )[
    #if inline {
      [#title #it]
    } else {
      [#block(sticky: true)[#title] #it]
    }
  ]
}

#let _numbered(label, ctr, bar-color, inline: false, body) = {
  ctr.step()
  let header = strong[#label #_ch-num(ctr)]
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.8em, bottom: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #if inline {
      [#strong[#label #_ch-num(ctr).] #body]
    } else {
      [#block(sticky: true)[#header #v(0.25em)] #body]
    }
  ]
}

#let _numbered-sub(label, subtitle, ctr, bar-color, inline: false, body) = {
  ctr.step()
  let header = strong[#label #_ch-num(ctr) (#subtitle)]
  block(
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.8em, bottom: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #if inline {
      [#strong[#label #_ch-num(ctr) (#subtitle).] #body]
    } else {
      [#block(sticky: true)[#header #v(0.25em)] #body]
    }
  ]
}

#let _dispatch(label, ctr, bar-color, inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  if sub != none {
    _numbered-sub(label, sub, ctr, bar-color, inline: inline, body)
  } else {
    _numbered(label, ctr, bar-color, inline: inline, body)
  }
}

#let definition(inline: false, ..args) = _dispatch(
  "Definition",
  def-ctr,
  oklch(55%, 0.18, 155deg),
  inline: inline,
  ..args,
)
#let theorem(inline: false, ..args) = _dispatch(
  "Theorem",
  thm-ctr,
  oklch(55%, 0.15, 250deg),
  inline: inline,
  ..args,
)
#let lemma(inline: false, ..args) = _dispatch(
  "Lemma",
  thm-ctr,
  oklch(55%, 0.14, 300deg),
  inline: inline,
  ..args,
)
#let corollary(inline: false, ..args) = _dispatch(
  "Corollary",
  thm-ctr,
  oklch(55%, 0.18, 22deg),
  inline: inline,
  ..args,
)
#let proposition(inline: false, ..args) = _dispatch(
  "Proposition",
  thm-ctr,
  oklch(55%, 0.16, 195deg),
  inline: inline,
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

// --- Unnumbered block environments ---

#let proof(body) = _block(
  title: strong[Proof:] + v(0.2em),
  fill: luma(97%),
  stroke: (left: 2pt + luma(78%), rest: none),
  inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
  it: body,
)

#let proof-sketch(body) = _block(
  title: strong[Proof sketch:] + v(0.2em),
  fill: luma(97%),
  stroke: (left: 2pt + luma(78%), rest: none),
  inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
  it: body,
)

#let example(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    if inline { emph[Example (#sub):] } else { emph[Example (#sub)] }
  } else if inline {
    emph[Example:]
  } else {
    emph[Example]
  }
  _block(
    title: title,
    fill: luma(97%),
    stroke: (left: 2pt + luma(82%), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    inline: inline,
    it: body,
  )
}

#let note(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[Note: #sub]
  } else if inline {
    strong[Note:]
  } else {
    strong[Note]
  }
  _block(
    title: title,
    fill: oklch(97%, 0.006, 155deg),
    stroke: (left: 3pt + oklch(55%, 0.15, 155deg), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    inline: inline,
    it: body,
  )
}

#let remark(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[Remark: #sub]
  } else if inline {
    strong[Remark:]
  } else {
    strong[Remark]
  }
  _block(
    title: title,
    fill: oklch(96%, 0.02, 70deg),
    stroke: (
      left: 3pt + oklch(60%, 0.16, 65deg),
      top: 0.5pt + oklch(90%, 0.02, 70deg),
      bottom: 0.5pt + oklch(90%, 0.02, 70deg),
      right: 0.5pt + oklch(90%, 0.02, 70deg),
    ),
    inset: (x: 1em, y: 0.8em),
    inline: inline,
    it: body,
  )
}

#let chapter-overview(body) = _block(
  title: strong[Chapter overview] + v(0.2em),
  fill: luma(95%),
  stroke: none,
  inset: 1em,
  it: body,
)

#let hrule = line(length: 100%)
