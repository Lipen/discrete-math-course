// Машина Тьюринга: конфигурация, устройство, сведение "HALT" к пустоте.
#import "style.typ": *
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes

// Лента --- тёплые квадраты, головка и управление --- cool, решатель --- чёрный ящик.
#let tape-tint = warm
#let machine-tint = cool
#let tape-stroke = 0.7pt + warm

// ── Конфигурация: лента, состояние над читаемой ячейкой, скобки u q v ──
#let tm-configuration = canvas({
  let syms = ("1", "0", "1", "1", $X$)
  let n = syms.len()
  let cw = 0.9
  let head-i = 2
  let cx(i) = (i - n / 2 + 0.5) * cw

  for i in range(n) {
    let under-head = i == head-i
    cell(
      "cell-" + str(i),
      (cx(i), 0),
      tone: if under-head { machine-tint } else { tape-tint },
      size: 0.45,
      radius: 0.07,
    )
    mark((cx(i), 0), syms.at(i), size: 0.8em)
  }

  mark((-(n / 2) * cw - 0.4, 0), $dots$, tone: ink-soft, size: 0.7em)
  mark(((n / 2) * cw + 0.4, 0), $dots$, tone: ink-soft, size: 0.7em)

  let hx = cx(head-i)
  draw.line(
    (hx, 0.5),
    (hx - 0.26, 0.92),
    (hx + 0.26, 0.92),
    close: true,
    fill: fill-soft,
    stroke: 0.9pt + machine-tint,
  )
  draw.rect(
    (hx - 0.55, 1.0),
    (hx + 0.55, 1.62),
    radius: 4pt,
    fill: white,
    stroke: 1.4pt + machine-tint,
    name: "state",
  )
  mark("state", $q_1$, size: 0.85em)

  let brace(from-i, to-i, label) = {
    let x0 = cx(from-i) - cw / 2
    let x1 = cx(to-i) + cw / 2
    draw.line((x0, -0.8), (x1, -0.8), stroke: edge-thin)
    mark(((x0 + x1) / 2, -1.2), label, size: 0.85em)
  }

  brace(0, 1, $u$)
  brace(2, 4, $v$)
})

// ── Сведение "HALT" к пустоте: построение f, чёрный ящик E, инверсия ответа ──
#let reduction-halt-empty = {
  let box-stroke = (paint: ink-soft, thickness: 0.9pt)
  diagram(
    spacing: (4.5em, 3em),
    node(
      (0, 0),
      $chevron.l M, w chevron.r$,
      name: <in>,
      fill: white,
      stroke: box-stroke,
      corner-radius: 4pt,
      inset: 0.55em,
    ),
    node(
      (2, 0),
      $chevron.l M' chevron.r$,
      name: <mp>,
      fill: white,
      stroke: box-stroke,
      corner-radius: 4pt,
      inset: 0.55em,
    ),
    node(
      (4, 0),
      text(fill: white)[$E$],
      name: <e>,
      fill: ink,
      stroke: none,
      corner-radius: 4pt,
      inset: 0.55em,
    ),
    node(
      (6, 0),
      $"HALT"$,
      name: <out>,
      fill: white,
      stroke: box-stroke,
      corner-radius: 4pt,
      inset: 0.55em,
    ),
    edge(<in>, <mp>, "-|>", stroke: edge-plain, label: text(size: 0.8em)[$f$]),
    edge(<mp>, <e>, "-|>", stroke: edge-plain, label: text(
      size: 0.8em,
    )[$chevron.l M' chevron.r$]),
    edge(<e>, <out>, "-|>", stroke: edge-plain, label: text(
      size: 0.8em,
    )[инверсия]),
  )
}

// ── Устройство МТ: лента, головка-указатель, конечное управление ──
#let turing-machine = canvas({
  let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
  let n = syms.len()
  let cw = 0.8
  let head-i = 3
  let cx(i) = (i - n / 2 + 0.5) * cw
  let hx = cx(head-i)

  for i in range(n) {
    let under-head = i == head-i
    cell(
      "tape-" + str(i),
      (cx(i), 0),
      tone: if under-head { machine-tint } else { tape-tint },
      size: 0.4,
      radius: 0.06,
    )
    mark((cx(i), 0), syms.at(i), size: 0.8em)
  }

  mark((-(n / 2) * cw - 0.4, 0), $dots$, tone: ink-soft, size: 0.7em)
  mark(((n / 2) * cw + 0.4, 0), $dots$, tone: ink-soft, size: 0.7em)

  draw.line(
    (hx, -0.46),
    (hx - 0.24, -0.9),
    (hx + 0.24, -0.9),
    close: true,
    fill: fill-soft,
    stroke: 0.9pt + machine-tint,
  )
  draw.line((hx, -0.9), (hx, -1.12), stroke: edge-thin)
  draw.rect(
    (hx - 0.85, -1.12),
    (hx + 0.85, -1.98),
    radius: 4pt,
    fill: white,
    stroke: 1.4pt + machine-tint,
  )
  mark((hx, -1.55), $q_i$, size: 0.85em)
})
