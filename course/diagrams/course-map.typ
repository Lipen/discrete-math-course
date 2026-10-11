// Карта курса: два ряда модулей, семестр 1 над семестром 2.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Палитра модулей (зеркало syllabus) ──
#let m-blue = oklch(45%, 0.12, 262deg)
#let m-cyan = oklch(45%, 0.11, 205deg)
#let m-purple = oklch(45%, 0.12, 320deg)
#let m-green = oklch(45%, 0.12, 150deg)
#let m-amber = oklch(48%, 0.12, 70deg)
#let m-spring = oklch(45%, 0.12, 175deg)
#let m-soft = oklch(45%, 0.02, 265deg)

// ── Геометрия ──
#let node-w = 3.4
#let node-h = 1.15
#let gap = 0.45
#let row-1 = 0
#let row-2 = 3.2

// Узел модуля: прямоугольник с заливкой, заголовок и лекции.
#let mod-node(x, y, title, lec, color) = {
  draw.rect(
    (x, y - node-h / 2),
    (x + node-w, y + node-h / 2),
    fill: color.transparentize(88%),
    stroke: 0.7pt + color,
    radius: 3pt,
  )
  draw.content(
    (x + node-w / 2, y),
    align(center)[
      #text(size: 6.5pt, weight: "semibold", fill: color)[#title] \
      #text(size: 5.5pt, fill: m-soft)[#lec]
    ],
  )
}

#let sem-label(x, y, body, color) = draw.content(
  (x, y),
  align(right)[#text(size: 7pt, weight: "bold", fill: color)[#body]],
)

// ── Карта курса ──
#let course-map = figure(
  canvas(length: 1cm, {
    // Ряд 1: семестр 1.
    sem-label(-0.3, row-1, [Семестр 1], m-blue)
    let xs1 = (0, 3.85, 7.7, 11.55)
    mod-node(xs1.at(0), row-1, [Множества и отношения], [лекции 1--8], m-blue)
    mod-node(xs1.at(1), row-1, [Формальная логика], [лекции 9--11], m-purple)
    mod-node(xs1.at(2), row-1, [Булева алгебра и схемы], [лекции 12--14], m-green)
    mod-node(xs1.at(3), row-1, [Коды], [лекции 15--16], m-amber)

    // Связь между рядами.
    draw.line(
      ((xs1.at(0) + node-w + xs1.at(3) + node-w) / 2, row-1 - node-h / 2),
      ((xs1.at(0) + node-w + xs1.at(3) + node-w) / 2, row-2 + node-h / 2),
      stroke: (paint: m-soft, thickness: 0.6pt, dash: "dashed"),
    )

    // Ряд 2: семестр 2.
    sem-label(-0.3, row-2, [Семестр 2], m-spring)
    let xs2 = (0, 3.85, 7.7, 11.55)
    mod-node(xs2.at(0), row-2, [Графы], [лекции 1--4], m-spring)
    mod-node(xs2.at(1), row-2, [Конечные автоматы], [лекции 5--8], m-cyan)
    mod-node(xs2.at(2), row-2, [Машина Тьюринга и разрешимость], [лекции 9--12], m-purple)
    mod-node(xs2.at(3), row-2, [Комбинаторика], [лекции 13--16], m-green)
  }),
  caption: [Два семестра: от языка описания к вычислениям.],
)
