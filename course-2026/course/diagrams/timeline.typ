// Таймлайны семестров: ось с недельными тиками, точки контроля, кронштейны модулей.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Константы ──
#let c-ink = oklch(45%, 0.02, 265deg)
#let c-mute = oklch(60%, 0.02, 265deg)
#let c-kr = oklch(38%, 0.13, 262deg)
#let c-tm = oklch(38%, 0.13, 320deg)
#let c-span = oklch(45%, 0.13, 262deg)

// Кронштейн-полускоба над промежутком [x0, x1].
#let span-bracket(x0, x1, y, h: 0.3) = {
  draw.line((x0, y + h), (x0, y), (x1, y), (x1, y + h), stroke: 0.75pt + c-span, join: "round")
}

// Ось с тиками по неделям, точками контроля и кронштейнами модулей.
// modules: ((первая-неделя, последняя-неделя, имя), ...); marks: ((неделя, "kr"|"tm", метка), ...).
#let semester-timeline(weeks, modules, marks) = canvas({
  // Ось и тики с номерами недель.
  draw.line((0, 0), (weeks, 0), stroke: 0.9pt + c-ink)
  for w in range(1, weeks + 1) {
    draw.line((w - 1, 0), (w - 1, -0.1), stroke: 0.5pt + c-mute)
    draw.content((w - 0.5, -0.34), [#w], size: 6.5pt, fill: c-mute)
  }
  draw.line((weeks, 0), (weeks, -0.1), stroke: 0.5pt + c-mute)
  // Модули: кронштейн над диапазоном недель, имя над ним.
  for (a, b, name) in modules {
    span-bracket(a - 1, b, 0.62)
    draw.content(((a - 1 + b) / 2, 1.1), name, size: 7.5pt, fill: c-ink)
  }
  // Точки контроля на оси, метка над точкой.
  for (w, kind, label) in marks {
    let color = if kind == "kr" { c-kr } else { c-tm }
    draw.circle((w - 0.5, 0), radius: 0.1, fill: color, name: none)
    draw.content((w - 0.5, 0.3), label, size: 7pt, weight: "bold", fill: color)
  }
})
