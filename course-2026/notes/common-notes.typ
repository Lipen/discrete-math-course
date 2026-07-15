// Автономный A4-стиль для конспекта по дискретной математике (русская версия).
// Не зависит от слайдовой инфраструктуры (typst/common.typ, requirements.typ).
// Импортируется всеми файлами тем и файлами сборки.
//
// Использование:
//   #import "common-notes.typ": *
//   #show: notes-template
//   #set document(title: "...", author: "...")

// --- Импорты пакетов ---
#import "@preview/cetz:0.5.2"

// --- Наша библиотека теорем (русская) ---
#import "theorems.typ": *

// --- Шаблон: все set/show-правила внутри, чтобы действовали глобально ---
#let notes-template(it) = {
  // Типографика
  set text(font: "Libertinus Serif", size: 12pt, lang: "ru")
  set par(justify: true, leading: 0.65em)

  // Заголовки
  show heading.where(level: 1): set text(size: 24pt, weight: "bold")
  show heading.where(level: 2): set text(size: 18pt, weight: "bold")
  show heading.where(level: 3): set text(size: 14pt, weight: "bold")
  show heading.where(level: 4): set text(size: 12pt, style: "italic")

  // Нумерация заголовков (3 уровня: 1, 1.1, 1.1.1)
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    pagebreak()
    counter("definition").update(0)
    counter("theorem").update(0)
    it
  }

  // Математика
  set math.mat(column-gap: 1em)
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Таблицы
  set table(inset: (x: 10pt, y: 4pt))
  show table.cell.where(y: 0): strong

  // Рисунки: по центру
  set figure(gap: 8pt)
  show figure: it => align(center, it)

  // Латинские сокращения
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  // QED-правила размещения
  setup-qed-rules()

  it
}
