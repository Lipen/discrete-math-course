// Таймлайны семестров: ось с неделями и месяцами, нумерованные точки контроля, цветные кронштейны модулей.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Константы ──
#let c-ink = oklch(45%, 0.02, 265deg)
#let c-mute = oklch(60%, 0.02, 265deg)
#let c-kr = oklch(38%, 0.13, 262deg)
#let c-tm = oklch(38%, 0.13, 320deg)

// Кронштейн-полускоба над промежутком [x0, x1].
#let span-bracket(x0, x1, y, color) = {
  draw.line((x0, y + 0.3), (x0, y), (x1, y), (x1, y + 0.3), stroke: 1pt + color, join: "round")
}

// Контрольная: круг с номером внутри.
#let kr-point(x, n) = {
  draw.circle((x, 0), radius: 0.17, fill: c-kr, name: none)
  draw.content((x, 0), text(fill: white, size: 6pt)[#n])
}

// Теормин: ромб с номером внутри.
#let tm-point(x, n) = {
  draw.polygon((x, 0), 4, radius: 0.2, fill: c-tm, stroke: none, name: none)
  draw.content((x, 0), text(fill: white, size: 6pt)[#n])
}

// Ось с тиками по неделям, месяцами, точками контроля и кронштейнами модулей.
// modules: ((первая-неделя, последняя-неделя, имя, цвет), ...);
// marks: ((неделя, "kr"|"tm", номер-в-семестре), ...);
// months: ((имя, x-начало, x-конец), ...).
#let semester-timeline(weeks, modules, marks, months) = canvas({
  // Ось, тики и номера недель.
  draw.line((0, 0), (weeks, 0), stroke: 0.9pt + c-ink)
  for w in range(1, weeks + 1) {
    draw.line((w - 1, 0), (w - 1, -0.1), stroke: 0.5pt + c-mute)
    draw.content((w - 0.5, -0.34), text(size: 6.5pt, fill: c-mute)[#w])
  }
  draw.line((weeks, 0), (weeks, -0.1), stroke: 0.5pt + c-mute)
  // Месяцы под номерами недель.
  for (name, x0, x1) in months {
    draw.content(((x0 + x1) / 2, -0.66), text(size: 6pt, fill: c-mute)[#name])
  }
  // Легенда точек: фигуры как на оси, подписи справа от фигур.
  draw.circle((0.08, -1.18), radius: 0.11, fill: c-kr, name: none)
  draw.content((0.26, -1.18), text(size: 6.5pt, fill: c-mute)[контрольная], anchor: "text")
  draw.polygon((1.81, -1.18), 4, radius: (0.16, 0.17), fill: c-tm, stroke: none, name: none)
  draw.content((2.12, -1.18), text(size: 6.5pt, fill: c-mute)[теормин], anchor: "text")
  // Модули: цветной кронштейн над диапазоном недель, имя над ним.
  for (a, b, name, color) in modules {
    span-bracket(a - 0.88, b - 0.12, 0.52, color)
    draw.content(((a - 1 + b) / 2, 1.05), text(size: 6.5pt, fill: color)[#name], anchor: "base")
  }
  // Точки контроля на оси.
  for (w, kind, n) in marks {
    if kind == "kr" { kr-point(w - 0.5, n) } else { tm-point(w - 0.5, n) }
  }
})
