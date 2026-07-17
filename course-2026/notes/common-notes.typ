// Автономный A4-стиль для конспекта по дискретной математике.
// Импортируется всеми файлами тем и файлами сборки.
//
// Использование:
//   #import "common-notes.typ": *
//   #show: notes-template.with(theme: oklch(55%, 0.18, 155deg))
//   #set document(title: "...", author: "...")

#import "requirements.typ": *

// --- Библиотека теорем ---
#import "theorems.typ": *

#import "notation.typ": *

// --- Окружения: front-matter / main-matter ---
// Используются как вставки (не show-правила), чтобы не заменять notes-template.

// Римская нумерация страниц для титула и содержания.
#let front-matter = {
  set page(numbering: "i")
}

// Арабская нумерация страниц для основного текста.
#let main-matter = {
  set page(numbering: "1")
  set heading(numbering: "1.1.1")
}

// --- Страница-разделитель (часть/семестр) ---
#let part(title, number: none, theme: oklch(55%, 0.02, 265deg)) = {
  pagebreak(weak: true)
  set page(header: none, footer: none, numbering: none)
  align(center + horizon)[
    #v(2.5cm)
    #if number != none [
      #text(size: 5em, fill: theme, weight: "bold")[#number]
      #v(0.3em)
    ]
    #line(length: 80%, stroke: 1.5pt + theme)
    #v(1.2em)
    #text(size: 2.8em, weight: "bold")[#title]
    #v(0.3em)
    #line(length: 45%, stroke: 1.5pt + theme)
    #v(2.5cm)
  ]
  pagebreak(weak: true)
}

// --- Шаблон: все set/show-правила внутри, чтобы действовали глобально ---
#let notes-template(it, theme: oklch(55%, 0.02, 265deg)) = {
  // Типографика
  set text(
    font: "Libertinus Serif",
    size: 12pt,
    lang: "ru",
  )
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1em,
    justification-limits: (
      spacing: (min: 100% * 2 / 3, max: 150%),
      tracking: (min: -0.01em, max: 0.02em),
    ),
  )

  // Заголовки
  show heading.where(level: 1): set text(size: 22pt, weight: "bold")
  show heading.where(level: 2): set text(size: 18pt, weight: "bold")
  show heading.where(level: 3): set text(size: 14pt, weight: "bold")
  show heading.where(level: 4): set text(size: 12pt, style: "italic")

  // Нумерация заголовков (3 уровня: 1, 1.1, 1.1.1)
  set heading(numbering: "1.1.1")

  // Открытие главы: крупный номер, линия, воздух.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter("definition").update(0)
    counter("theorem").update(0)

    if it.numbering != none {
      v(3em)
      text(size: 3.5em, fill: theme, weight: "bold")[
        #counter(heading).display()
      ]
      v(-0.6em)
      line(length: 22%, stroke: 1.5pt + theme)
      v(1.2em)
    }
    it
    v(1.5em)
    // Мини-содержание главы: разделы уровня 2.
    set text(size: 10pt)
    context {
      let ch_loc = here()
      let ch_pg = counter(page).at(ch_loc).first()
      // Все секции уровня 2 в книге.
      let all_secs = query(heading.where(outlined: true, level: 2))
      let secs = ()
      // Найти страницу следующей главы (если есть).
      let next_chs = query(heading.where(level: 1))
      let bound_pg = none
      for h in next_chs {
        let hp = counter(page).at(h.location()).first()
        if hp > ch_pg {
          bound_pg = hp
          break
        }
      }
      // Отобрать секции между этой главой и следующей.
      for s in all_secs {
        let sp = counter(page).at(s.location()).first()
        if sp >= ch_pg {
          if bound_pg == none or sp < bound_pg {
            secs.push(s)
          }
        }
      }
      if secs.len() > 0 {
        line(length: 100%, stroke: 0.3pt + theme)
        v(0.6em)
        for s in secs {
          link(s.location(), text(fill: luma(40%))[#s.body])
          v(0.3em)
        }
        v(0.3em)
        line(length: 100%, stroke: 0.3pt + theme)
      }
    }
    v(1.5em)
  }

  // Математика
  set math.mat(column-gap: 1em)
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Таблицы
  set table(inset: (x: 10pt, y: 4pt))
  show table.cell.where(y: 0): strong

  // Содержание: dot leaders
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))

  // Рисунки: по центру
  set figure(gap: 8pt)
  show figure: it => align(center, it)

  // Бумажно-безопасные ссылки: URL в сноску при печати
  show link: it => {
    let url = it.dest
    if type(url) == str and it.body != url {
      it
      footnote(url)
    } else {
      it
    }
  }

  // Латинские сокращения
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  // QED-правила размещения
  setup-qed-rules()

  it
}
