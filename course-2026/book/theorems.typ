// Окружения книги: цветные блоки с полосой слева.
// Бейдж-метка --- у формальных утверждений и сигналов; текстовая метка без
// бейджа --- у доказательств, примеров и комментариев; обзор главы ---
// отдельная вёрстка.
// Все бейджевые блоки собираются каркасом `_block`.
// Нумерация сбрасывается на каждой главе (`= Heading`).
//
// API:
//   #definition[тело]           #definition[Название][тело]
//   #theorem[тело]              #theorem[Название][тело]
//   #lemma[тело]                #lemma[Название][тело]
//   #corollary[тело]            #corollary[Название][тело]
//   #proposition[тело]          #proposition[Название][тело]
//   #proof[тело]                #proof[Название][тело]
//   #proof-sketch[тело]         #proof-sketch[Название][тело]
//   #example[тело]              #example[Название][тело]
//   #note[тело]                 #note[Название][тело]
//   #remark[тело]               #remark[Название][тело]
//   #warning[тело]              #warning[Название][тело]
//   #history-note[тело]         #history-note[Название][тело]
//   #trap[тело]                 #trap[Название][тело]
//   #check[тело]                #check[Название][тело]
//   #algorithm[тело]            #algorithm[Название][тело]
//   #project[тело]              #project[Название][тело]
//   #project-stage[Ключ][тело]  #project-outcome[тело]
//   #raven[тело]                #raven[Название][тело]

// --- Палитра: приглушённый oklch-ряд (низкая хрома, светлота согласована) ---
#let def-color = oklch(60%, 0.12, 145deg)   // определение: зелёный
#let thm-color = oklch(60%, 0.12, 240deg)   // теорема: синий
#let lem-color = oklch(60%, 0.12, 290deg)   // лемма: фиолетовый (самый насыщенный)
#let cor-color = oklch(60%, 0.12, 25deg)    // следствие: тёплый красный
#let prop-color = oklch(60%, 0.12, 200deg)  // утверждение: циан
#let prf-color = oklch(60%, 0.00, 0deg)     // доказательство: серый
#let psk-color = oklch(60%, 0.00, 0deg)     // набросок: светло-серый
#let ex-color = oklch(60%, 0.12, 345deg)    // пример: маджента
#let note-color = oklch(60%, 0.12, 70deg)   // примечание: тёплый серый
#let remark-color = oklch(60%, 0.06, 65deg) // замечание: медный
#let warn-color = oklch(60%, 0.07, 82deg)   // предупреждение: янтарный
#let hist-color = oklch(60%, 0.06, 55deg)   // история: коричневый
#let trap-color = oklch(60%, 0.09, 12deg)   // ловушка: кримзон
#let check-color = oklch(60%, 0.06, 190deg) // проверка: бирюзовый
#let algo-color = oklch(60%, 0.06, 230deg)  // алгоритм: стальной синий
#let project-color = oklch(60%, 0.12, 300deg) // проект: индиго
#let overview-color = oklch(60%, 0.03, 240deg) // обзор главы: серо-синий

// --- Метки: словарь для лёгкой смены языка ---
#let thm-labels = (
  definition: "ОПРЕДЕЛЕНИЕ",
  theorem: "ТЕОРЕМА",
  lemma: "ЛЕММА",
  corollary: "СЛЕДСТВИЕ",
  proposition: "УТВЕРЖДЕНИЕ",
  proof: "Доказательство",
  proof-sketch: "Набросок доказательства",
  example: "Пример",
  note: "Примечание",
  warning: "ПРЕДУПРЕЖДЕНИЕ",
  remark: "Замечание",
  raven: "Замечание",
  overview: "ОБЗОР ГЛАВЫ",
  algorithm: "АЛГОРИТМ",
  history: "ИСТОРИЯ",
  trap: "ЛОВУШКА",
  check: "Проверка",
  project: "ПРОЕКТ",
)

// Флаг липких заголовков; управляется из notes-template.
#let sticky-state = state("block-headers-sticky", true)

// Липкий заголовок: держится с первой строкой тела при разрыве страницы.
#let _sticky(body) = context {
  block(sticky: sticky-state.get())[#body]
}

// Счётчики: определения отдельно, теоремы (и леммы, следствия, утверждения) общие.
#let def-ctr = counter("definition")
#let thm-ctr = counter("theorem")

// Номер с префиксом главы: "2.14".
#let _ch-num(ctr) = context {
  let h = counter(heading).at(here())
  let ch = if h != none { h.first() }
  let n = ctr.at(here()).first()
  if ch != none and n != none { [#ch.#n] } else if n != none { [#n] }
}

// Разбор ..args в (заголовок, тело).
#let _args(pos) = {
  if pos.len() >= 2 {
    (pos.at(0), pos.at(1))
  } else {
    (none, pos.at(0))
  }
}

// Бейдж: цветная плашка с белым текстом.
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

// Рамка: толстая полоса слева + тонкие остальные стороны.
#let _stroke(accent) = (
  left: 2.5pt + accent,
  top: 0.6pt + accent,
  bottom: 0.6pt + accent,
  right: 0.6pt + accent,
)

// Вспомогательный блок: только левая полоса, без рамки и фона.
#let _aux-stroke(accent) = (left: 1.8pt + accent)

// Общий каркас блока: бейдж или текстовая метка, необязательный заголовок, тело.
// fill и тон заголовка выводятся из цвета-акцента по единой формуле.
#let _block(
  label,
  accent,
  body,
  title: none,
  ctr: none,
  badged: true,
  label-italic: false,
  above: auto,
  below: auto,
) = {
  if ctr != none { ctr.step() }
  block(
    above: above,
    below: below,
    width: 100%,
    fill: if badged { accent.transparentize(90%) } else { none },
    stroke: if badged { _stroke(accent) } else { _aux-stroke(accent) },
    inset: (x: 0.8em, top: if badged { 0.7em } else { 0.6em }, bottom: 0.8em),
    radius: 3pt,
  )[
    #set par(first-line-indent: 0pt)
    #_sticky[
      #if badged [
        #badge(accent)[#label #if ctr != none [#_ch-num(ctr)]]
      ] else [
        #text(
          size: 0.9em,
          weight: "semibold",
          style: if label-italic { "italic" } else { "normal" },
          fill: accent.darken(30%),
        )[#label]
      ]
      #if title != none [
        #h(0.6em, weak: true)
        #text(weight: "semibold", fill: accent.darken(20%))[#title]
      ]
    ]
    #v(0.9em, weak: true)
    #body
  ]
}

// Нумерованный блок.
#let _numbered(label, accent, ctr, ..args) = {
  let (title, body) = _args(args.pos())
  _block(label, accent, body, title: title, ctr: ctr)
}

// Ненумерованный блок.
#let _plain(label, accent, badged: true, label-italic: false, ..args) = {
  let (title, body) = _args(args.pos())
  _block(
    label,
    accent,
    body,
    title: title,
    badged: badged,
    label-italic: label-italic,
  )
}

// --- Публичные блоки ---

#let definition(..args) = _numbered(
  thm-labels.definition,
  def-color,
  def-ctr,
  ..args,
)
#let theorem(..args) = _numbered(thm-labels.theorem, thm-color, thm-ctr, ..args)
#let lemma(..args) = _numbered(thm-labels.lemma, lem-color, thm-ctr, ..args)
#let corollary(..args) = _numbered(
  thm-labels.corollary,
  cor-color,
  thm-ctr,
  ..args,
)
#let proposition(..args) = _numbered(
  thm-labels.proposition,
  prop-color,
  thm-ctr,
  ..args,
)

#let proof(..args) = _plain(
  thm-labels.proof,
  prf-color,
  badged: false,
  ..args,
)
#let proof-sketch(..args) = _plain(
  thm-labels.proof-sketch,
  psk-color,
  badged: false,
  ..args,
)
#let example(..args) = _plain(
  thm-labels.example,
  ex-color,
  badged: false,
  ..args,
)
#let note(..args) = _plain(
  thm-labels.note,
  note-color,
  badged: false,
  label-italic: true,
  ..args,
)
#let remark(..args) = _plain(
  thm-labels.remark,
  remark-color,
  badged: false,
  label-italic: true,
  ..args,
)
#let warning(..args) = _plain(thm-labels.warning, warn-color, ..args)
#let history-note(..args) = _plain(
  thm-labels.history,
  hist-color,
  badged: false,
  label-italic: true,
  ..args,
)
#let trap(..args) = _plain(thm-labels.trap, trap-color, ..args)
#let check(..args) = _plain(
  thm-labels.check,
  check-color,
  badged: false,
  ..args,
)
#let algorithm(..args) = _plain(thm-labels.algorithm, algo-color, ..args)

// Цитата: вставленная литературная цитата.
#let quote-accent = oklch(55%, 0.12, 230deg)
#let blockquote(body, attribution) = {
  block(
    above: 1.4em,
    below: 1.4em,
    width: 100%,
    stroke: (left: 2pt + quote-accent),
    inset: (left: 0.9em, right: 0.9em, top: 0.4em, bottom: 0.5em),
    radius: 3pt,
  )[
    #set par(first-line-indent: 0pt)
    #set text(fill: luma(50%))
    #body
    #v(0.6em, weak: true)
    #align(right)[
      #set text(style: "normal", size: 0.9em, fill: luma(55%))
      #attribution
    ]
  ]
}

// --- Этапы и итог проекта ---
// Нумерованные подблоки внутри #project: кружок с номером, ключ-заголовок,
// тело этапа. Счётчик сбрасывается в начале каждого #project.
#let project-stage-num = counter("project-stage")
#let project-stage(title, body) = {
  project-stage-num.step()
  context {
    let n = project-stage-num.get().first()
    block(above: 0.6em, below: 0.55em)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.6em,
        // Номер в кольце: центрируется по строке заголовка, поэтому цифра
        // стоит на бейзлайне заголовка.
        box(
          stroke: 0.8pt + project-color,
          radius: 50%,
          inset: (x: 0.32em, y: 0.15em),
        )[#text(size: 0.85em, weight: "bold", fill: project-color.darken(20%))[#n]],
        text(style: "italic", weight: "semibold", fill: project-color.darken(20%))[#title],
        // Тело во второй колонке: висячий отступ по заголовку, как
        // продолжение элемента списка по началу его текста.
        [],
        body,
      )
    ]
  }
}
#let project-outcome(body) = {
  block(
    above: 0.5em,
    stroke: (top: 0.6pt + project-color),
    inset: (top: 0.5em),
  )[
    #text(weight: "bold", fill: project-color.darken(20%))[Итог:]#h(0.3em)#body
  ]
}
#let project(..args) = {
  project-stage-num.update(0)
  _plain(thm-labels.project, project-color, ..args)
}

// Обзор главы: отдельная вёрстка --- центрированная метка с линейкой.
#let chapter-overview(body) = {
  block(
    above: 2.5em,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #block(
      below: 1.5em,
      sticky: true,
      width: 100%,
    )[
      #align(center)[
        #text(
          size: 1.1em,
          weight: "semibold",
          fill: overview-color,
          tracking: 0.1em,
        )[#thm-labels.overview]
        #line(length: 40%, stroke: 0.8pt + overview-color)
      ]
    ]
    #body
  ]
}

// Ворон: блок с левой полосой, внутри --- картинка слева и текст справа.
#let raven-accent = oklch(35%, 0.05, 260deg)
#let raven-fill = oklch(97%, 0.01, 260deg)
#let raven-hairline = oklch(88%, 0.02, 260deg)

#let raven(..args) = {
  let (title, body) = _args(args.pos())
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
        #if title != none {
          text(weight: "semibold", fill: raven-accent)[#title]
          v(0.5em, weak: true)
        }
        #body
      ],
    )
  ]
}
