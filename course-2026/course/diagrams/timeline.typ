// Таймлайны семестров: ось с неделями и датами, ленты месяцев, точки контроля с датами, фигурные скобки модулей.
#import "@preview/cetz:0.5.2": canvas, draw, decorations

// ── Константы ──
#let c-ink = oklch(45%, 0.02, 265deg)
#let c-mute = oklch(60%, 0.02, 265deg)
#let c-kr = oklch(38%, 0.13, 262deg)
#let c-tm = oklch(38%, 0.13, 320deg)

// Контрольная: круг с номером внутри.
#let kr-point(x, n) = {
  draw.circle((x, 0), radius: 0.19, fill: c-kr, name: none)
  draw.content((x, 0), text(fill: white, size: 6pt)[#n])
}

// Теормин: ромб с номером внутри.
#let tm-point(x, n) = {
  draw.polygon((x, 0), 4, radius: 0.22, fill: c-tm, stroke: none, name: none)
  draw.content((x, 0), text(fill: white, size: 6pt)[#n])
}

// Ось: недели с днями лекций, ленты месяцев по границам недель, точки контроля
// на 75% недели (суббота) с датой, фигурные скобки модулей с именами на кончике.
// modules: ((первая-неделя, последняя-неделя, имя, цвет), ...);
// marks: ((неделя, "kr"|"tm", номер-в-семестре, дата-субботы), ...);
// months: ((имя, x-начало, x-конец), ...);
// dates: дни лекций недели, по одной записи на неделю.
#let semester-timeline(weeks, modules, marks, months, dates) = canvas({
  draw.line((0, 0), (weeks, 0), stroke: 1.6pt + c-ink, cap: "round")
  for w in range(1, weeks + 1) {
    draw.line((w - 1, 0), (w - 1, -0.12), stroke: 0.5pt + c-mute)
    draw.content((w - 0.5, -0.3), text(size: 6pt, fill: c-mute)[#w])
    draw.content((w - 0.5, -0.62), text(size: 5pt, fill: c-mute)[#dates.at(w - 1)])
  }
  draw.line((weeks, 0), (weeks, -0.12), stroke: 0.5pt + c-mute)
  for (i, (name, x0, x1)) in months.enumerate() {
    let band = if calc.even(i) { c-mute.transparentize(88%) } else { c-mute.transparentize(95%) }
    draw.rect((x0, -1.14), (x1, -0.74), fill: band, stroke: 0.5pt + c-mute, name: none)
    draw.content(((x0 + x1) / 2, -0.94), text(size: 6pt, fill: c-mute)[#name])
  }
  draw.circle((0.08, -1.5), radius: 0.11, fill: c-kr, name: none)
  draw.content((0.27, -1.5), text(size: 6pt, fill: c-mute)[контрольная], anchor: "mid-west")
  draw.polygon((1.81, -1.5), 4, radius: (0.16, 0.17), fill: c-tm, stroke: none, name: none)
  draw.content((2.06, -1.5), text(size: 6pt, fill: c-mute)[теормин], anchor: "mid-west")
  for (a, b, name, color) in modules {
    decorations.brace((a - 0.88, 0.58), (b - 0.12, 0.58), fill: color, amplitude: 0.32)
    draw.content(((a + b - 1) / 2, 1.2), text(size: 6pt, fill: color)[#name], anchor: "south")
  }
  for (w, kind, n, date) in marks {
    let x = w - 0.25
    if kind == "kr" { kr-point(x, n) } else { tm-point(x, n) }
    let label-color = if kind == "kr" { c-kr } else { c-tm }
    draw.content((x, 0.34), text(size: 5pt, fill: label-color)[#date])
  }
})
