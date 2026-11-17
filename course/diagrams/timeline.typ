// Таймлайны семестров: полосы модулей, ось с неделями и датами, ленты месяцев, точки контроля.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Палитра ──
#let c-ink = oklch(25%, 0, 0deg)
#let c-mute = oklch(55%, 0, 0deg)
#let c-kr = oklch(68%, 0.16, 262deg)
#let c-tm = oklch(68%, 0.17, 320deg)
#let c-kr-ink = oklch(45%, 0.13, 262deg)
#let c-tm-ink = oklch(45%, 0.12, 320deg)

// ── Геометрия (в единицах оси: 1 = неделя) ──
#let g = (
  tick: 0.15, // высота деления недели
  num-y: -0.3, // номер недели
  date-y: -0.6, // дни лекций недели
  month-top: -0.8, // лента месяца
  month-bot: -1.2,
  legend-y: -1.5, // строка легенды
  legend-x: 0.5, // первая точка
  legend-tm-x: 3.0, // вторая точка
  legend-r: 0.1, // радиус точки легенды
  mark-r: 0.17, // радиус точки контроля
  mark-date: 0.15, // зазор дата над точкой
  saturday: 0.25, // метка на 75% недели
  mod-bottom: 0.5, // полоса модуля
  mod-top: 0.98,
  mod-inset: 0.04, // зазор между соседними полосами
  mod-label-y: 0.74,
)

// ── Помощники ──

// Деление недели на оси.
#let week-tick(x) = draw.line((x, 0), (x, -g.tick))

// Лента месяца с именем по центру.
#let month-band(i, name, x0, x1) = {
  let id = "month-" + str(i)
  let fill = if calc.even(i) {
    c-mute.transparentize(92%)
  } else {
    c-mute.transparentize(96%)
  }
  draw.rect(
    (x0, g.month-bot),
    (x1, g.month-top),
    fill: fill,
    name: id,
  )
  draw.content(
    id,
    text(size: 6.5pt, weight: "semibold", fill: c-ink)[#name],
  )
}

// Точка контроля: круг для КР, ромб для ТМ; общий размер.
#let mark-point(id, kind, x) = {
  if kind == "kr" {
    draw.circle((x, 0), radius: g.mark-r, fill: c-kr, name: id)
  } else {
    draw.polygon((x, 0), 4, radius: g.mark-r, fill: c-tm, name: id)
  }
}

// Дата субботы над точкой контроля.
#let mark-date(id, date, color) = draw.content(
  id + ".north",
  text(size: 5.5pt, weight: "semibold", fill: color)[#date],
  anchor: "south",
  padding: 0.05,
)

// Легенда: те же фигуры, что на оси, подписи справа.
#let legend-item(x, kind, color, label) = {
  if kind == "kr" {
    draw.circle((x, g.legend-y), radius: g.legend-r, fill: color)
  } else {
    draw.polygon((x, g.legend-y), 4, radius: g.legend-r, fill: color)
  }
  draw.content(
    (x + g.legend-r + 0.1, g.legend-y),
    text(size: 6.5pt, weight: "semibold", fill: c-ink)[#label],
    anchor: "west",
  )
}

#let legend() = {
  legend-item(g.legend-x, "kr", c-kr, [контрольная])
  legend-item(g.legend-tm-x, "tm", c-tm, [теормин])
}

// ── Таймлайн семестра ── modules: ((первая-неделя, последняя-неделя, имя, цвет), ...); marks: ((неделя, "kr"|"tm", номер-в-семестре, дата-субботы), ...); months: ((имя, x-начало, x-конец), ...); dates: дни лекций недели, по одной записи на неделю.
#let semester-timeline(
  weeks,
  modules,
  marks,
  months,
  dates,
  unit: 1cm,
) = canvas(length: unit, {
  draw.set-style(stroke: (paint: c-mute, thickness: 0.5pt))

  for w in range(1, weeks + 1) {
    week-tick(w - 1)
    draw.content(
      (w - 0.5, g.num-y),
      text(size: 8pt, weight: "semibold", fill: c-ink)[#w],
    )
    draw.content(
      (w - 0.5, g.date-y),
      text(size: 5.5pt, fill: c-mute)[#dates.at(w - 1, default: [])],
    )
  }
  week-tick(weeks)

  draw.line(
    (0, 0),
    (weeks, 0),
    stroke: 1.6pt + c-ink,
    cap: "round",
    name: "axis",
  )

  for (i, (name, x0, x1)) in months.enumerate() {
    month-band(i, name, x0, x1)
  }
  legend()

  for (a, b, name, color) in modules {
    let x0 = a - 1 + g.mod-inset
    let x1 = b - g.mod-inset
    draw.rect(
      (x0, g.mod-bottom),
      (x1, g.mod-top),
      fill: color.transparentize(88%),
      stroke: none,
    )
    draw.line(
      (x0, g.mod-top),
      (x1, g.mod-top),
      stroke: 1.5pt + color,
      cap: "round",
    )
    draw.content(
      ((x0 + x1) / 2, g.mod-label-y),
      text(size: 7pt, weight: "semibold", fill: color, hyphenate: false)[#name],
    )
  }

  for (w, kind, n, date) in marks {
    let id = "mark-w" + str(w)
    mark-point(id, kind, w - g.saturday)
    mark-date(id, date, if kind == "kr" { c-kr-ink } else { c-tm-ink })
  }
})
