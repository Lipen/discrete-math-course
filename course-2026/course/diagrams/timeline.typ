// Таймлайны семестров: ось с неделями и датами, ленты месяцев, точки контроля с датами, фигурные скобки модулей.
#import "@preview/cetz:0.5.2": canvas, decorations, draw

// ── Палитра ──
#let c-ink = oklch(45%, 0.02, 265deg)
#let c-mute = oklch(60%, 0.02, 265deg)
#let c-kr = oklch(38%, 0.13, 262deg)
#let c-tm = oklch(38%, 0.13, 320deg)

// ── Геометрия (в единицах оси: 1 = неделя) ──
#let g = (
  tick: 0.15, // высота деления недели
  num-y: -0.3, // номер недели
  date-y: -0.6, // дни лекций недели
  month-top: -0.8, // лента месяца
  month-bot: -1.2,
  legend-y: -1.5, // строка легенды
  legend-x: 0.5,
  legend-kr-r: 0.1, // кружок «контрольная»
  legend-tm-r: 0.15, // ромб «теормин»
  legend-gap: 0.5, // от конца слова до центра ромба
  kr-r: 0.15, // точка контрольной
  tm-r: 0.15, // теормина
  mark-date: 0.15, // зазор дата над точкой
  saturday: 0.25, // метка на 75% недели
  brace-y: 0.4, // скобка модуля
  brace-amp: 0.3, // амплитуда скобок
  brace-inset: 0.1, // отступ кончиков от краёв модуля
)

// ── Помощники ──

// Деление недели на оси.
#let week-tick(x) = draw.line((x, 0), (x, -g.tick))

// Лента месяца с именем по центру.
#let month-band(i, name, x0, x1) = {
  let id = "month-" + str(i)
  let fill = if calc.even(i) {
    c-mute.transparentize(88%)
  } else {
    c-mute.transparentize(95%)
  }
  draw.rect(
    (x0, g.month-bot),
    (x1, g.month-top),
    fill: fill,
    name: id,
  )
  draw.content(
    id,
    text(size: 6pt, fill: c-mute)[#name],
  )
}

// Точка контроля с номером внутри; имя --- для привязки даты.
#let mark-point(id, kind, x) = {
  if kind == "kr" {
    draw.circle(
      (x, 0),
      radius: g.kr-r,
      fill: c-kr,
      name: id,
    )
  } else {
    draw.polygon(
      (x, 0),
      4,
      radius: g.tm-r,
      fill: c-tm,
      name: id,
    )
  }
}

// Дата субботы над точкой контроля.
#let mark-date(id, date, color) = draw.content(
  id + ".north",
  text(size: 5pt, fill: color)[#date],
  anchor: "south",
  padding: 0.05,
)

// Легенда: кружок и ромб, подписи пристёгнуты к фигурам.
#let legend() = {
  draw.circle(
    (g.legend-x, g.legend-y),
    radius: g.legend-kr-r,
    fill: c-kr,
    name: "leg-kr",
  )
  draw.content(
    "leg-kr.east",
    text(size: 6pt, fill: c-mute)[контрольная],
    anchor: "west",
    padding: (left: 0.08),
    name: "leg-kr-lab",
  )
  draw.polygon(
    ("leg-kr-lab.east", g.legend-gap, (12, g.legend-y)),
    4,
    radius: g.legend-tm-r,
    fill: c-tm,
    name: "leg-tm",
  )
  draw.content(
    "leg-tm.east",
    text(size: 6pt, fill: c-mute)[теормин],
    anchor: "west",
    padding: (left: 0.09),
  )
}

// ── Таймлайн семестра ──
// modules: ((первая-неделя, последняя-неделя, имя, цвет), ...);
// marks: ((неделя, "kr"|"tm", номер-в-семестре, дата-субботы), ...);
// months: ((имя, x-начало, x-конец), ...);
// dates: дни лекций недели, по одной записи на неделю.
#let semester-timeline(weeks, modules, marks, months, dates) = canvas({
  draw.set-style(stroke: (paint: c-mute, thickness: 0.5pt))

  for w in range(1, weeks + 1) {
    week-tick(w - 1)
    draw.content(
      (w - 0.5, g.num-y),
      text(size: 8pt, fill: c-mute)[#w],
    )
    draw.content(
      (w - 0.5, g.date-y),
      text(size: 5pt, fill: c-mute)[#dates.at(w - 1)],
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
    let lab = "brace-" + str(a) + "-" + str(b)
    decorations.brace(
      (a - 1 + g.brace-inset, g.brace-y),
      (b - g.brace-inset, g.brace-y),
      fill: color,
      amplitude: g.brace-amp,
      name: lab,
    )
    draw.content(
      lab + ".spike",
      text(size: 8pt, fill: color)[#name],
      anchor: "south",
      padding: 0.05,
    )
  }

  for (w, kind, n, date) in marks {
    let id = "mark-w" + str(w)
    mark-point(id, kind, w - g.saturday)
    mark-date(id, date, if kind == "kr" { c-kr } else { c-tm })
  }
})
