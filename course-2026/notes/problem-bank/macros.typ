// Макросы для банка задач (problems.typ).
// Связи через metadata + query + link(location).
// Визуал: block с толстым левым краем (как теоремы).
#import "../theorems.typ": _aux-stroke, _block-stroke, badge

// ── Счётчик ──

#let pb-counter = counter("problem-bank")

// ── Цвета ──

// fill-цвета --- почти белые
#let pb-basic-fill = oklch(97%, 0.008, 150deg)
#let pb-medium-fill = oklch(97%, 0.010, 65deg)
#let pb-advanced-fill = oklch(97%, 0.008, 15deg)
#let pb-project-fill = oklch(97%, 0.010, 275deg)
// stroke-цвета --- пастельные, но видимые
#let pb-basic = oklch(80%, 0.05, 150deg)
#let pb-medium = oklch(80%, 0.06, 65deg)
#let pb-advanced = oklch(79%, 0.05, 15deg)
#let pb-project = oklch(79%, 0.06, 275deg)

#let pb-diff-label = (
  basic: "БАЗОВЫЙ",
  medium: "СРЕДНИЙ",
  advanced: "ПРОДВИНУТЫЙ",
  project: "ПРОЕКТ",
)

#let pb-diff-color = (
  basic: pb-basic,
  medium: pb-medium,
  advanced: pb-advanced,
  project: pb-project,
)

#let pb-diff-fill = (
  basic: pb-basic-fill,
  medium: pb-medium-fill,
  advanced: pb-advanced-fill,
  project: pb-project-fill,
)

// ── Metadata-поиск ──

#let _find(id, kind) = {
  query(metadata).find(m => {
    let v = m.value
    (
      type(v) == dictionary
        and v.at("pb-id", default: none) == id
        and v.at("kind") == kind
    )
  })
}

#let _has(id, kind) = { _find(id, kind) != none }

#let _number(id) = {
  let m = _find(id, "problem")
  if m != none { pb-counter.at(m.location()).first() }
}

#let _back-to-solution() = {
  text(
    size: 0.8em,
    fill: luma(50%),
  )[$arrow.l.hook$ к условию]
}

// ── Флаеры ──

#let flyer-links(id, hint: true, solution: true) = {
  if not hint and not solution { return }
  context {
    let has-hint = hint and _has(id, "hint")
    let has-sol = solution and _has(id, "solution")
    if not has-hint and not has-sol { return }

    let badge-fill = white.transparentize(50%)
    let badge-str = 0.4pt + luma(80%)

    let fl(pid, icon, kind, title) = {
      link(_find(pid, kind).location())[
        #box(
          fill: badge-fill,
          stroke: badge-str,
          inset: (x: 0.5em, top: 0.2em, bottom: 0.4em),
          radius: 3pt,
        )[
          #set par(first-line-indent: 0pt)
          #text(
            size: 0.8em,
            fill: luma(40%),
          )[#icon #title]
        ]
      ]
    }

    if has-hint {
      fl(id, "💡", "hint", "Подсказка")
    }
    if has-hint and has-sol {
      h(0.5em)
    }
    if has-sol {
      fl(id, "📝", "solution", "Решение")
    }
  }
}

// ── Задача ──

#let problem(
  id: none,
  title: none,
  difficulty: "medium",
  body,
  hint: true,
  solution: true,
  source: none,
  topics: (),
) = {
  assert(id != none, message: "problem: параметр `id` обязателен")
  let dc = pb-diff-color.at(difficulty, default: pb-medium)
  let df = pb-diff-fill.at(difficulty, default: pb-medium-fill)

  pb-counter.step()
  context { metadata((pb-id: id, kind: "problem")) }

  block(
    above: 1em,
    below: 1em,
    fill: df,
    stroke: _block-stroke(dc),
    inset: (x: 0.8em, y: 0.5em),
    radius: 5pt,
    breakable: false,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)

    // Badge, Title, Difficulty
    #grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0.5em,
      align: horizon,
      [
        #badge(dc.darken(30%))[ЗАДАЧА #context pb-counter.display()]
      ],
      [
        #if title != none {
          h(0.5em, weak: true)
          text(weight: "semibold", fill: dc.darken(40%))[#title]
        }
      ],
      [
        #text(
          size: 0.8em,
          tracking: 0.05em,
          fill: dc.darken(20%),
        )[#pb-diff-label.at(difficulty)]
      ],
    )

    #if source != none {
      text(
        size: 0.8em,
        style: "italic",
        fill: luma(50%),
      )[Источник: #source]
    }

    #body

    #flyer-links(id, hint: hint, solution: solution)
  ]
}

// ── Подсказка ──

#let pb-hint(id, body) = {
  assert(id != none, message: "pb-hint: параметр `id` обязателен")
  context { metadata((pb-id: id, kind: "hint")) }

  let c = pb-medium
  block(
    above: 1em,
    below: 1em,
    fill: pb-medium-fill,
    stroke: _aux-stroke(c),
    inset: (x: 0.8em, y: 0.6em),
    radius: 5pt,
    // breakable: false,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)

    #block(sticky: true)[
      #context {
        let n = _number(id)
        text(
          weight: "semibold",
          fill: c.darken(40%),
        )[Подсказка к задаче #n]
      }
      #context {
        let m = _find(id, "problem")
        if m != none {
          h(1fr)
          link(m.location())[
            #text(
              size: 0.8em,
              fill: luma(50%),
            )[$arrow.l.hook$ к условию]
          ]
        }
      }
    ]

    #body
  ]
}

// ── Решение ──

#let pb-solution(id, body) = {
  assert(id != none, message: "pb-solution: параметр `id` обязателен")
  context { metadata((pb-id: id, kind: "solution")) }

  let c = pb-advanced
  block(
    above: 1em,
    below: 1em,
    fill: pb-advanced-fill,
    stroke: _block-stroke(c),
    inset: (x: 0.8em, y: 0.5em),
    radius: 5pt,
    // breakable: false,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)

    #block(sticky: true)[
      #context {
        let n = _number(id)
        text(
          weight: "semibold",
          fill: c.darken(40%),
        )[Решение задачи #n]
      }
      #context {
        let m = _find(id, "problem")
        if m != none {
          h(1fr)
          link(m.location(), _back-to-solution())
        }
      }
    ]

    #body
  ]
}

// ── Мета-секция ──

#let topic-header(title, chapters, description) = {
  pagebreak(weak: true)
  [== #title]
  text(
    size: 0.9em,
    fill: luma(50%),
  )[*Главы: #chapters.* #description]
  v(0.5em)
}

// ── Проект ──

#let project(
  id: none,
  title: none,
  brief,
  deliverables: none,
  criteria: none,
  hint-body: none,
  topics: (),
  chapter-refs: (),
  source: none,
) = {
  assert(id != none, message: "project: параметр `id` обязателен")
  let dc = pb-project

  pb-counter.step()
  context { metadata((pb-id: id, kind: "project")) }

  block(
    above: 1em,
    below: 0.8em,
    fill: pb-project-fill,
    stroke: _block-stroke(dc),
    inset: (left: 0.8em, right: 0.7em, top: 0.5em, bottom: 0.55em),
    radius: 2pt,
    width: 100%,
  )[
    #set par(first-line-indent: 0pt)
    #grid(columns: (1fr, auto), column-gutter: 0.5em)[
      #badge(dc.darken(30%))[ПРОЕКТ #context pb-counter.display()]
      #if title != none {
        h(0.35em)
        text(weight: "semibold", fill: dc.darken(40%))[#title]
      }
    ][
      #text(
        size: 0.8em,
        tracking: 0.05em,
        fill: dc.darken(18%),
      )[#pb-diff-label.at("project")]
    ]

    #parbreak()
    #brief

    #if deliverables != none {
      v(0.4em)
      text(weight: "semibold", fill: dc.darken(15%))[Что нужно сдать:]
      parbreak()
      deliverables
    }
    #if criteria != none {
      v(0.4em)
      text(weight: "semibold", fill: dc.darken(15%))[Критерии оценки:]
      parbreak()
      criteria
    }
    #if chapter-refs.len() > 0 {
      v(0.4em)
      text(
        size: 0.88em,
        fill: luma(50%),
      )[Связанные главы: #chapter-refs.map(c => "[глава " + c + "]").join(", ")]
    }
    #if hint-body != none {
      v(0.5em)
      flyer-links(id, hint: true, solution: false)
    }
  ]
}
