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
  draw.line((x, 0.2), (x + 0.2, 0), (x, -0.2), (x - 0.2, 0), (x, 0.2), close: true, fill: c-tm, name: none)
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
    draw.content((w - 0.5, -0.34), [#w], size: 6.5pt, fill: c-mute)
  }
  draw.line((weeks, 0), (weeks, -0.1), stroke: 0.5pt + c-mute)
  // Месяцы под номерами недель.
  for (name, x0, x1) in months {
    draw.content(((x0 + x1) / 2, -0.66), name, size: 6pt, fill: c-mute)
  }
  // Легенда точек.
  draw.content(
    (0, -1.02),
    [
      #text(fill: c-kr, size: 7pt)[#sym.circle.filled] --- контрольная #h(0.6em) #text(fill: c-tm, size: 7pt)[#sym.diamond.filled] --- теормин
    ],
    size: 6.5pt,
    fill: c-mute,
  )
  // Модули: цветной кронштейн над диапазоном недель, имя в два уровня.
  for (i, m) in modules.enumerate() {
    let (a, b, name, color) = m
    span-bracket(a - 0.88, b - 0.12, 0.52, color)
    let y = if calc.even(i) { 1.08 } else { 1.42 }
    draw.content(((a - 1 + b) / 2, y), name, size: 7pt, fill: color)
  }
  // Точки контроля на оси.
  for (w, kind, n) in marks {
    if kind == "kr" { kr-point(w - 0.5, n) } else { tm-point(w - 0.5, n) }
  }
})
