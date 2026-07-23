// Русские theorem-окружения в стиле theme-5: pill-бейджи, цветные полосы.
// Нумерация сбрасывается на каждом = Heading (глава).
// API (обратно-совместимый):
//   #definition[тело]                #definition[Заголовок][тело]
//   #theorem[тело]                   #theorem[Название][тело]
//   #lemma[тело]                     #lemma[Название][тело]
//   #corollary[тело]                 #corollary[Название][тело]
//   #proposition[тело]               #proposition[Название][тело]
//   #proof[тело]                     #proof-sketch[тело]
//   #example[тело]                   #example[Заголовок][тело]
//   #note[тело]                      #note[Заголовок][тело]
//   #remark[тело]                    #remark[Заголовок][тело]
//   #warning[тело]                   #warning[Заголовок][тело]
//   #history-note[тело]              #history-note[Заголовок][тело]
//   #digression[тело]                #digression[Заголовок][тело]
//   #algorithm[тело]                 #algorithm[Название][тело]
//   #raven[тело]                     #raven[Заголовок][тело]
//   #chapter-overview[тело]
//   #hrule

// --- Палитра (из theme-5) ---
#let def-color = rgb("1a7a4a")  // green
#let thm-color = rgb("1a3d6e")  // rich blue
#let lem-color = oklch(55%, 0.14, 300deg)  // violet (lemma)
#let cor-color = oklch(55%, 0.18, 22deg)   // warm red (corollary)
#let prop-color = oklch(52%, 0.06, 195deg)   // muted cyan (proposition)
#let ex-color = rgb("5b2d8e")  // purple (example)
#let note-color = rgb("7a828d")  // gray (note)
#let remark-color = rgb("b87333")  // copper (remark)
#let warn-color = oklch(65%, 0.18, 75deg)   // amber (warning)
#let hist-color = rgb("8b6f47")  // warm brown (history)
#let digr-color = oklch(55%, 0.12, 290deg)  // violet (digression)
#let algo-color = oklch(55%, 0.12, 230deg)  // steel blue (algorithm)

// --- Метки (словарь для лёгкой смены языка) ---
#let thm-labels = (
  definition: "ОПРЕДЕЛЕНИЕ",
  theorem: "ТЕОРЕМА",
  lemma: "ЛЕММА",
  corollary: "СЛЕДСТВИЕ",
  proposition: "УТВЕРЖДЕНИЕ",
  proof: "Доказательство",
  proof-sketch: "Набросок доказательства",
  example: "ПРИМЕР",
  note: "Примечание",
  warning: "Предупреждение",
  remark: "Замечание",
  raven: "Замечание",
  overview: "Обзор главы",
  algorithm: "АЛГОРИТМ",
  digression: "ОТСТУПЛЕНИЕ",
)

// State for sticky-headers flag (controlled from notes-template)
#let sticky-state = state("block-headers-sticky", true)

// Context-aware sticky block — header stays with first line of body
#let _sticky(body) = context {
  block(sticky: sticky-state.get())[#body]
}

#let def-ctr = counter("definition")
#let thm-ctr = counter("theorem")

// --- Номер с префиксом главы: "2.14" ---
#let _ch-num(ctr) = context {
  let h = counter(heading).at(here())
  let ch = if h != none { h.first() }
  let n = ctr.at(here()).first()
  if ch != none and n != none { [#ch.#n] } else if n != none { [#n] }
}

// Разбор ..args в (подзаголовок, тело).
#let _args(pos) = {
  if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    (none, pos.at(0))
  }
}

// Pill badge — цветная плашка с белым текстом
#let badge(color, body) = {
  box(
    fill: color,
    inset: (x: 0.62em, y: 0.28em),
    radius: 2pt,
    outset: (y: 0.12em),
  )[#text(size: 0.82em, weight: "bold", fill: white, tracking: 0.08em)[#body]]
}

// Full border: thick left + thin on other sides
#let _block-stroke(color) = (
  left: 2.5pt + color,
  top: 0.6pt + color,
  bottom: 0.6pt + color,
  right: 0.6pt + color,
)

// Subtle border for auxiliary blocks (proof, note)
#let _aux-stroke(color) = (
  left: 1.8pt + color,
  top: 0.6pt + color,
  bottom: 0.6pt + color,
  right: 0.6pt + color,
)

// --- Нумерованные блоки ---

#let _numbered(label, ctr, bar-color, fill, body, title: none) = {
  ctr.step()
  let header = badge(bar-color)[#label #_ch-num(ctr)]
  block(
    fill: fill,
    stroke: _block-stroke(bar-color),
    inset: (left: 0.7em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #header
      #if title != none [#h(0.4em)#text(
          weight: "semibold",
          fill: bar-color,
        )[#title]]
    ]
    #parbreak()
    #body
  ]
}

// Inline numbered — компактный блок: бейдж + тело на одной строке
#let _numbered-inline(label, ctr, bar-color, fill, body, title: none) = {
  ctr.step()
  block(
    above: 0.4em,
    below: 0.4em,
    fill: fill,
    stroke: (
      left: 1.5pt + bar-color,
      top: 0.6pt + bar-color,
      bottom: 0.6pt + bar-color,
      right: 0.6pt + bar-color,
    ),
    inset: (left: 0.25em, right: 0.5em, y: 0.3em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #badge(bar-color)[#label #_ch-num(ctr)]
      #if title != none [#h(0.3em)#text(
          weight: "semibold",
          fill: bar-color,
        )[(#title)]]
    ]
    #h(0.35em)
    #body
  ]
}

#let _dispatch(label, ctr, bar-color, fill, inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  if inline {
    _numbered-inline(label, ctr, bar-color, fill, body, title: sub)
  } else {
    _numbered(label, ctr, bar-color, fill, body, title: sub)
  }
}

#let definition(inline: false, ..args) = _dispatch(
  thm-labels.definition,
  def-ctr,
  def-color,
  def-color.lighten(94%),
  inline: inline,
  ..args,
)
#let theorem(inline: false, ..args) = _dispatch(
  thm-labels.theorem,
  thm-ctr,
  thm-color,
  thm-color.lighten(93%),
  inline: inline,
  ..args,
)
#let lemma(inline: false, ..args) = _dispatch(
  thm-labels.lemma,
  thm-ctr,
  lem-color,
  lem-color.lighten(93%),
  inline: inline,
  ..args,
)
#let corollary(inline: false, ..args) = _dispatch(
  thm-labels.corollary,
  thm-ctr,
  cor-color,
  cor-color.lighten(93%),
  inline: inline,
  ..args,
)
#let proposition(inline: false, ..args) = _dispatch(
  thm-labels.proposition,
  thm-ctr,
  prop-color,
  prop-color.lighten(93%),
  inline: inline,
  ..args,
)

// --- QED ---
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

#let setup-qed-rules() = {
  show metadata.where(value: "qed-here"): it => {
    h(1fr)
    $square.stroked$
  }
  show math.equation.where(block: true): eq => {
    if _has-qed(eq.body) {
      grid(
        columns: (1fr, auto, 1fr),
        [], eq, align(right + horizon)[$square.stroked$],
      )
    } else { eq }
  }
  show enum.item: it => {
    show metadata.where(value: "qed-here"): it => {
      h(1fr)
      $square.stroked$
    }
    it
  }
  show list.item: it => {
    show metadata.where(value: "qed-here"): it => {
      h(1fr)
      $square.stroked$
    }
    it
  }
}

// --- Ненумерованные блоки ---

#let proof(body) = {
  block(
    above: 0.4em,
    below: 0.5em,
    fill: luma(97%),
    stroke: _aux-stroke(luma(65%)),
    inset: (left: 0.8em, right: 0.5em, top: 0.3em, bottom: 0.3em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #text(weight: "semibold", fill: luma(40%))[#thm-labels.proof]
    ]
    #parbreak()
    #body
  ]
}

#let proof-sketch(body) = {
  block(
    above: 0.4em,
    below: 0.5em,
    fill: luma(97%),
    stroke: _aux-stroke(luma(65%)),
    inset: (left: 0.8em, right: 0.5em, top: 0.3em, bottom: 0.3em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #text(
        size: 0.92em,
        style: "italic",
        fill: luma(45%),
      )[#thm-labels.proof-sketch]
    ]
    #parbreak()
    #body
  ]
}

#let example(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.8em,
    below: 0.8em,
    fill: ex-color.lighten(95%),
    stroke: _block-stroke(ex-color),
    inset: (left: 0.7em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #badge(ex-color)[#thm-labels.example]
      #if sub != none [#h(0.4em)#text(weight: "semibold", fill: ex-color)[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let note(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.6em,
    below: 0.6em,
    inset: (left: 1em, right: 0.7em, top: 0.35em, bottom: 0.35em),
    stroke: _aux-stroke(note-color.lighten(20%)),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #text(
        size: 0.92em,
        weight: "semibold",
        fill: note-color,
      )[#thm-labels.note]
      #if sub != none [#h(0.3em)#text(
          size: 0.92em,
          style: "italic",
          fill: note-color,
        )[#sub]]
    ]
    #parbreak()
    #text(size: 0.92em, fill: luma(35%))[#body]
  ]
}

#let remark(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.6em,
    below: 0.6em,
    fill: rgb("fdf8f2"),
    stroke: 0.4pt + remark-color.lighten(40%),
    inset: (left: 0.9em, right: 0.7em, top: 0.4em, bottom: 0.4em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #text(style: "italic", fill: remark-color)[#thm-labels.remark]
      #if sub != none [#h(0.4em)#text(
          weight: "semibold",
          fill: remark-color.darken(10%),
        )[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let warning(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.6em,
    below: 0.6em,
    fill: oklch(95%, 0.05, 85deg),
    stroke: _block-stroke(warn-color),
    inset: (left: 0.8em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #text(
        weight: "semibold",
        fill: warn-color.darken(20%),
      )[⚠  #thm-labels.warning]
      #if sub != none [#h(0.3em)#text(
          style: "italic",
          fill: warn-color.darken(20%),
        )[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let history-note(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.8em,
    below: 0.8em,
    fill: rgb("fdf5f0"),
    stroke: _block-stroke(hist-color),
    inset: (left: 0.7em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #badge(hist-color)[ИСТОРИЯ]
      #if sub != none [#h(0.4em)#text(
          weight: "semibold",
          fill: hist-color,
        )[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let digression(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.8em,
    below: 0.8em,
    fill: digr-color.lighten(95%),
    stroke: _block-stroke(digr-color),
    inset: (left: 0.7em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #badge(digr-color)[#thm-labels.digression]
      #if sub != none [#h(0.4em)#text(
          weight: "semibold",
          fill: digr-color,
        )[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let algorithm(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  block(
    above: 0.8em,
    below: 0.8em,
    fill: algo-color.lighten(95%),
    stroke: _block-stroke(algo-color),
    inset: (left: 0.7em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #badge(algo-color)[#thm-labels.algorithm]
      #if sub != none [#h(0.4em)#text(
          weight: "semibold",
          fill: algo-color,
        )[#sub]]
    ]
    #parbreak()
    #body
  ]
}

#let chapter-overview(body) = {
  block(
    above: 0.8em,
    below: 1.2em,
    sticky: true,
    fill: luma(93%),
    stroke: 0.4pt + luma(80%),
    inset: 1.2em,
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #text(weight: "semibold", fill: luma(35%))[#thm-labels.overview]
    #v(0.3em)
    #body
  ]
}

// Ворон: блок с левой полосой, внутри — картинка ворона слева и текст справа (grid).
#let raven-accent = oklch(35%, 0.03, 255deg)
#let raven-fill = oklch(97%, 0.005, 260deg)
#let raven-hairline = oklch(88%, 0.01, 260deg)

#let raven(body) = {
  block(
    fill: raven-fill,
    stroke: (left: 3pt + raven-accent, rest: 0.5pt + raven-hairline),
    inset: (left: 0.5em, right: 1em, y: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #grid(
      columns: (auto, 1fr),
      column-gutter: 0.6em,
      [#image("assets/raven.png", width: 40pt)], [#body],
    )
  ]
}

#let hrule = line(length: 100%, stroke: 0.3pt + luma(85%))
