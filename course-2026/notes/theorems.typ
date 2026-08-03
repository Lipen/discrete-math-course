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
//   #trap[тело]                      #trap[Заголовок][тело]
//   #self-check[тело]                #self-check[Заголовок][тело]
//   #algorithm[тело]                 #algorithm[Название][тело]
//   #raven[тело]                     #raven[Заголовок][тело]
//   #chapter-overview[тело]
//   #hrule

// --- Палитра ---
#let def-color = rgb("1e7d48")  // green
#let thm-color = rgb("25558b")  // blue
#let lem-color = oklch(60%, 0.12, 300deg)  // violet (lemma)
#let cor-color = oklch(58%, 0.14, 22deg)   // warm red (corollary)
#let prop-color = oklch(62%, 0.04, 210deg)   // faint cyan (proposition)
#let ex-color = rgb("7345a8")  // purple (example)
#let note-color = rgb("8e97a3")  // gray (note)
#let remark-color = rgb("cd8a4a")  // copper (remark)
#let warn-color = oklch(70%, 0.15, 75deg)   // amber (warning)
#let hist-color = rgb("a08055")  // warm brown (history)
#let algo-color = oklch(60%, 0.10, 230deg)  // steel blue (algorithm)
#let trap-color = oklch(52%, 0.16, 25deg)  // red (trap)
#let self-color = rgb("2a7f8a")  // teal (self-check)

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
  history: "ИСТОРИЯ",
  trap: "ЛОВУШКА",
  self-check: "ПРОВЕРЬТЕ СЕБЯ",
)

// State for sticky-headers flag (controlled from notes-template)
#let sticky-state = state("block-headers-sticky", true)

// Context-aware sticky block --- header stays with first line of body
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

// Pill badge --- цветная плашка с белым текстом
#let badge(color, body) = {
  box(
    fill: color,
    radius: 2pt,
    inset: (x: 0.5em),
    outset: (y: 0.5em),
  )[#text(
    size: 0.8em,
    weight: "bold",
    fill: white,
    tracking: 0.08em,
  )[#body]]
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

// Block with header and title
#let _block(
  header,
  title,
  body,
  fill: none,
  stroke: none,
  inset: (x: 0.8em, top: 0.8em, bottom: 0.8em),
  radius: 4pt,
) = {
  block(
    fill: fill,
    stroke: stroke,
    inset: inset,
    radius: radius,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #if header != none {
        header
      }
      #if header != none and title != none {
        h(0.5em, weak: true)
      }
      #if title != none {
        title
      }
    ]
    #v(1em, weak: true)
    #body
  ]
}

// --- Нумерованные блоки ---

#let _numbered(label, ctr, bar-color, fill, body, title: none) = {
  ctr.step()
  let header = badge(bar-color)[
    #label #_ch-num(ctr)
  ]
  let title = text(
    weight: "semibold",
    fill: bar-color,
  )[#title]
  _block(
    header,
    title,
    body,
    fill: fill,
    stroke: _block-stroke(bar-color),
  )
}

// Inline numbered --- компактный блок: бейдж + тело на одной строке
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
  let c = luma(50%)
  let title = text(
    weight: "semibold",
    fill: c,
  )[#thm-labels.proof]
  _block(
    none,
    title,
    body,
    fill: c.lighten(40%),
    stroke: _block-stroke(c),
  )
}

#let proof-sketch(body) = {
  let c = luma(40%)
  let title = text(
    style: "italic",
    fill: c,
  )[#thm-labels.proof-sketch]
  _block(
    none,
    title,
    body,
    fill: c.lighten(90%),
    stroke: _aux-stroke(c),
  )
}

#let example(..args) = {
  let (sub, body) = _args(args.pos())
  let header = badge(ex-color)[#thm-labels.example]
  if sub != none {
    sub = text(
      style: "italic",
      fill: ex-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: ex-color.lighten(95%),
    stroke: _block-stroke(ex-color),
  )
}

#let note(..args) = {
  let (sub, body) = _args(args.pos())
  let header = text(
    weight: "semibold",
    fill: note-color.darken(20%),
  )[#thm-labels.note]
  if sub != none {
    sub = text(
      style: "italic",
      fill: note-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: note-color.lighten(80%),
    stroke: _aux-stroke(note-color),
  )
}

#let remark(..args) = {
  let (sub, body) = _args(args.pos())
  let header = text(
    style: "italic",
    weight: "semibold",
    fill: remark-color.darken(20%),
  )[#thm-labels.remark]
  if sub != none {
    sub = text(
      weight: "semibold",
      fill: remark-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: remark-color.lighten(80%),
    stroke: _block-stroke(remark-color),
  )
}

#let warning(..args) = {
  let (sub, body) = _args(args.pos())
  let header = text(
    weight: "semibold",
    fill: warn-color.darken(20%),
  )[⚠  #thm-labels.warning]
  if sub != none {
    sub = text(
      style: "italic",
      fill: warn-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: oklch(95%, 0.05, 85deg),
    stroke: _block-stroke(warn-color),
  )
}

#let history-note(..args) = {
  let (sub, body) = _args(args.pos())
  let header = badge(hist-color)[#thm-labels.history]
  sub = text(
    weight: "semibold",
    fill: hist-color.darken(20%),
  )[#sub]
  _block(
    header,
    sub,
    body,
    fill: hist-color.lighten(90%),
    stroke: _block-stroke(hist-color),
  )
}

#let trap(..args) = {
  let (sub, body) = _args(args.pos())
  let header = badge(trap-color)[#thm-labels.trap]
  if sub != none {
    sub = text(
      weight: "semibold",
      fill: trap-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: trap-color.lighten(88%),
    stroke: _block-stroke(trap-color),
  )
}

#let self-check(..args) = {
  let (sub, body) = _args(args.pos())
  let header = badge(self-color)[#thm-labels.self-check]
  if sub != none {
    sub = text(
      weight: "semibold",
      fill: self-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: self-color.lighten(90%),
    stroke: _block-stroke(self-color),
  )
}

#let algorithm(..args) = {
  let (sub, body) = _args(args.pos())
  let header = badge(algo-color)[#thm-labels.algorithm]
  if sub != none {
    sub = text(
      weight: "semibold",
      fill: algo-color.darken(20%),
    )[#sub]
  }
  _block(
    header,
    sub,
    body,
    fill: algo-color.lighten(95%),
    stroke: _block-stroke(algo-color),
  )
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

// Ворон: блок с левой полосой, внутри --- картинка ворона слева и текст справа (grid).
#let raven-accent = oklch(35%, 0.03, 255deg)
#let raven-fill = oklch(97%, 0.005, 260deg)
#let raven-hairline = oklch(88%, 0.01, 260deg)

#let raven(..args) = {
  let (sub, body) = _args(args.pos())
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
      [#image("assets/raven.png", width: 40pt)],
      [
        #if sub != none {
          text(weight: "semibold", fill: raven-accent)[#sub]
          v(0.5em, weak: true)
        }
        #body
      ],
    )
  ]
}

#let hrule = line(length: 100%, stroke: 0.3pt + luma(85%))
