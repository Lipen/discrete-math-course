// Русские theorem-окружения : чистый Typst: block + counter.
// Нумерация сбрасывается на каждом = Heading (глава).
// API:
//   #definition[тело]                #definition[Подзаголовок][тело]
//   #theorem[тело]                   #theorem[Название][тело]
//   #lemma[тело]                     #lemma[Название][тело]
//   #corollary[тело]                 #corollary[Название][тело]
//   #proposition[тело]               #proposition[Название][тело]
//   #proof[тело]                     #proof-sketch[тело]
//   #example[тело]                   #example[Заголовок][тело]
//   #note[тело]                      #note[Заголовок][тело]
//   #remark[тело]                    #remark(inline: true)[тело]
//   #remark[Заголовок][тело]         #note(inline: true)[тело]
//   #raven[тело]                     #raven[Заголовок][тело]
//   #chapter-overview[тело]
//   #hrule

// --- Метки теорем (словарь для лёгкой смены языка) ---
#let thm-labels = (
  definition: "Определение",
  theorem: "Теорема",
  lemma: "Лемма",
  corollary: "Следствие",
  proposition: "Утверждение",
  proof: "Доказательство",
  proof-sketch: "Набросок доказательства",
  example: "Пример",
  note: "Примечание",
  warning: "Предупреждение",
  remark: "Замечание",
  raven: "Nevermore.",
  overview: "Обзор главы",
  algorithm: "Алгоритм",
)

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

// Общий хелпер: цветной блок с заголовком и телом.
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

#let _numbered(label, ctr, bar-color, fill, inline: false, body) = {
  ctr.step()
  let header = strong[#label #_ch-num(ctr)]
  block(
    fill: fill,
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

#let _numbered-sub(
  label,
  subtitle,
  ctr,
  bar-color,
  fill,
  inline: false,
  body,
) = {
  ctr.step()
  let header = strong[#label #_ch-num(ctr)#h(0.4em);(#subtitle)]
  block(
    fill: fill,
    stroke: (left: 3pt + bar-color, rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.8em, bottom: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #if inline {
      [#strong[#label #_ch-num(ctr)#h(0.4em);(#subtitle).] #body]
    } else {
      [#block(sticky: true)[#header #v(0.25em)] #body]
    }
  ]
}

#let _dispatch(label, ctr, bar-color, fill, inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  if sub != none {
    _numbered-sub(label, sub, ctr, bar-color, fill, inline: inline, body)
  } else {
    _numbered(label, ctr, bar-color, fill, inline: inline, body)
  }
}

#let definition(inline: false, ..args) = _dispatch(
  thm-labels.definition,
  def-ctr,
  oklch(55%, 0.18, 155deg),
  oklch(97%, 0.02, 155deg),
  inline: inline,
  ..args,
)
#let theorem(inline: false, ..args) = _dispatch(
  thm-labels.theorem,
  thm-ctr,
  oklch(55%, 0.15, 250deg),
  oklch(97%, 0.02, 250deg),
  inline: inline,
  ..args,
)
#let lemma(inline: false, ..args) = _dispatch(
  thm-labels.lemma,
  thm-ctr,
  oklch(55%, 0.14, 300deg),
  oklch(97%, 0.02, 300deg),
  inline: inline,
  ..args,
)
#let corollary(inline: false, ..args) = _dispatch(
  thm-labels.corollary,
  thm-ctr,
  oklch(55%, 0.18, 22deg),
  oklch(97%, 0.02, 22deg),
  inline: inline,
  ..args,
)
#let proposition(inline: false, ..args) = _dispatch(
  thm-labels.proposition,
  thm-ctr,
  oklch(55%, 0.16, 195deg),
  oklch(97%, 0.02, 195deg),
  inline: inline,
  ..args,
)

// --- Размещение QED ---
// Используй #qed вручную внутри доказательства для размещения символа QED.
// Show-правила корректно размещают его внутри списков, выключных уравнений и текста.
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

// Вызови один раз из common-notes.typ после всех импортов.
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

// --- Ненумерованные блоки ---

#let proof(body) = _block(
  title: strong[#thm-labels.proof:] + v(0.2em),
  fill: luma(94%),
  stroke: (left: 2pt + luma(78%), rest: none),
  inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
  it: body,
)

#let proof-sketch(body) = _block(
  title: strong[#thm-labels.proof-sketch:] + v(0.2em),
  fill: luma(94%),
  stroke: (left: 2pt + luma(78%), rest: none),
  inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
  it: body,
)

#let example(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    if inline { emph[#thm-labels.example (#sub):] } else {
      emph[#thm-labels.example (#sub)]
    }
  } else if inline {
    emph[#thm-labels.example:]
  } else {
    emph[#thm-labels.example]
  }
  _block(
    title: title,
    fill: luma(94%),
    stroke: (left: 2pt + luma(82%), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    inline: inline,
    it: body,
  )
}

#let note(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[#thm-labels.note: #sub]
  } else if inline {
    strong[#thm-labels.note:]
  } else {
    strong[#thm-labels.note]
  }
  _block(
    title: title,
    fill: oklch(94%, 0.006, 155deg),
    stroke: (left: 3pt + oklch(55%, 0.15, 155deg), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    inline: inline,
    it: body,
  )
}

#let remark(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[#thm-labels.remark: #sub]
  } else if inline {
    strong[#thm-labels.remark:]
  } else {
    strong[#thm-labels.remark]
  }
  _block(
    title: title,
    fill: oklch(93%, 0.02, 70deg),
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

// Предупреждение: жёлтая полоса, предостерегающий оттенок.
// API: #warning[тело]  или  #warning[Заголовок][тело]
#let warning(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[⚠  #sub]
  } else if inline {
    strong[⚠  #thm-labels.warning]
  } else {
    strong[⚠  #thm-labels.warning]
  }
  _block(
    title: title,
    fill: oklch(95%, 0.05, 85deg),
    stroke: (
      left: 3pt + oklch(65%, 0.18, 75deg),
      top: 0.5pt + oklch(92%, 0.05, 85deg),
      bottom: 0.5pt + oklch(92%, 0.05, 85deg),
      right: 0.5pt + oklch(92%, 0.05, 85deg),
    ),
    inset: (x: 1em, y: 0.8em),
    inline: inline,
    it: body,
  )
}

// Историческая справка: тёплая охра, тонкая рамка, иконка песочных часов.
// API: #history-note[тело]  или  #history-note[Заголовок][тело]
#let history-note(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[#sym.hourglass  #sub]
  } else {
    strong[#sym.hourglass  ИСТОРИЧЕСКАЯ СПРАВКА]
  }
  _block(
    title: title,
    fill: oklch(97%, 0.015, 70deg),
    stroke: (
      left: 3pt + oklch(55%, 0.14, 70deg),
      rest: 0.4pt + oklch(85%, 0.02, 70deg),
    ),
    inset: (x: 1em, y: 0.8em),
    inline: inline,
    it: body,
  )
}

// Прикладное отступление: фиолетовый, для развёрнутых CS-применений.
// API: #digression[тело]  или  #digression[Заголовок][тело]
#let digression(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[#sym.dot.c  #sub]
  } else {
    strong[#sym.dot.c  ОТСТУПЛЕНИЕ]
  }
  _block(
    title: title,
    fill: oklch(96%, 0.012, 290deg),
    stroke: (
      left: 3pt + oklch(55%, 0.12, 290deg),
      rest: 0.4pt + oklch(85%, 0.01, 290deg),
    ),
    inset: (x: 1em, y: 0.8em),
    inline: inline,
    it: body,
  )
}

#let chapter-overview(body) = _block(
  title: strong[#thm-labels.overview] + v(0.2em),
  fill: luma(92%),
  stroke: none,
  inset: 1em,
  it: body,
)

// Алгоритм: стилевой блок для пошаговых процедур.
// Содержимое --- обычный +-список (Typst сам нумерует).
// API: #algorithm[тело]  или  #algorithm[Название][тело]
#let algorithm(inline: false, ..args) = {
  let (sub, body) = _args(args.pos())
  let title = if sub != none {
    strong[#thm-labels.algorithm (#sub)]
  } else {
    strong[#thm-labels.algorithm]
  }
  _block(
    title: title,
    fill: oklch(97%, 0.01, 230deg),
    stroke: (left: 2pt + oklch(55%, 0.12, 230deg), rest: none),
    inset: (left: 0.9em, right: 0.6em, top: 0.5em, bottom: 0.5em),
    inline: inline,
    it: body,
  )
}

// Ворон: блок с левой полосой, внутри — картинка ворона слева и текст справа (grid).
// API: #raven[тело]
#let raven-accent = oklch(35%, 0.03, 255deg)
#let raven-fill = oklch(97%, 0.005, 260deg)
#let raven-hairline = oklch(88%, 0.01, 260deg)
#let raven-img-width = 40pt
#let raven-img-gap = 0.6em

#let raven(body) = {
  block(
    fill: raven-fill,
    stroke: (
      left: 3pt + raven-accent,
      top: 0.5pt + raven-hairline,
      bottom: 0.5pt + raven-hairline,
      right: 0.5pt + raven-hairline,
    ),
    inset: (left: 0.5em, right: 1em, y: 0.8em),
    radius: 3pt,
    width: 100%,
  )[
    #set par(justify: true, justification-limits: (
      spacing: (min: 100% * 2 / 3, max: 200%),
      tracking: (min: -0.01em, max: 0.04em),
    ))
    #grid(
      columns: (auto, 1fr),
      column-gutter: raven-img-gap,
      [#image("assets/raven.png", width: raven-img-width)], [#body],
    )
  ]
}

#let hrule = line(length: 100%)
