// M09 diagrams --- Логические схемы: полусумматор, полный сумматор, мультиплексор.
// Стиль лекционных диаграмм: cetz 0.5.2, oklch-палитра (синее семейство 250deg).
#import "@preview/cetz:0.5.2": canvas, draw

// ── Palette ──
#let c-gate-fill = oklch(88%, 0.03, 250deg)   // вентиль: светлая заливка
#let c-gate-str = oklch(55%, 0.10, 250deg)    // вентиль: граница
#let c-text = oklch(30%, 0.02, 265deg)        // подписи
#let c-edge = oklch(35%, 0.02, 265deg)        // провода

// ── Helpers ──
// Вентиль: скруглённый прямоугольник с именем по центру.
#let gate(pos, label, w: 0.85, h: 0.45) = {
  let (x, y) = pos
  draw.rect(
    (x - w / 2, y - h / 2),
    (x + w / 2, y + h / 2),
    fill: c-gate-fill,
    stroke: (paint: c-gate-str, thickness: 0.8pt),
    radius: 2pt,
  )
  draw.content(pos, text(size: 0.42em, fill: c-text, weight: "bold")[#label])
}

// Точка соединения (узел), где провода реально соединяются.
#let jdot(pos) = draw.circle(pos, radius: 0.03, fill: c-edge)

// Провод.
#let wire(a, b) = draw.line(a, b, stroke: c-edge + 0.7pt)

// Подпись.
#let lab(pos, anchor, body) = draw.content(
  pos,
  anchor: anchor,
  text(size: 0.45em, fill: c-text)[#body],
)

// ── Полусумматор: S = A xor B, C = A and B ──
#let half-adder = canvas({
  gate((0, 0.45), "XOR")
  gate((0, -0.45), "AND")

  // A: верхний вход, в верхний порт XOR и верхний порт AND.
  wire((-1.25, 0.575), (-0.425, 0.575))
  jdot((-0.75, 0.575))
  wire((-0.75, 0.575), (-0.75, -0.325))
  wire((-0.75, -0.325), (-0.425, -0.325))

  // B: нижний вход, в нижний порт AND и нижний порт XOR.
  wire((-1.25, -0.575), (-0.425, -0.575))
  jdot((-0.55, -0.575))
  wire((-0.55, -0.575), (-0.55, 0.325))
  wire((-0.55, 0.325), (-0.425, 0.325))

  // Выходы.
  wire((0.425, 0.45), (0.675, 0.45))
  wire((0.425, -0.45), (0.675, -0.45))

  lab((-1.3, 0.575), "east", $A$)
  lab((-1.3, -0.575), "east", $B$)
  lab((0.725, 0.45), "west", $S$)
  lab((0.725, -0.45), "west", $C$)
})

// ── Полный сумматор: S = A xor B xor Cin, Cout = (A and B) or (Cin and (A xor B)) ──
#let full-adder = canvas({
  // Колонка 1: XOR1 (сумма A,B) и AND1 (перенос A,B).
  gate((0, 0.6), "XOR", w: 0.8)
  gate((0, -0.5), "AND", w: 0.8)
  // Колонка 2: XOR2 (сумма с Cin) и AND2 (перенос от Cin и A xor B).
  gate((1.35, 0.6), "XOR", w: 0.8)
  gate((1.35, -0.3), "AND", w: 0.8)
  // Колонка 3: OR (итоговый перенос).
  gate((2.3, -0.5), "OR", w: 0.8)

  // A: в XOR1 (верхний) и AND1 (верхний).
  wire((-1.3, 0.675), (-0.4, 0.675))
  jdot((-0.75, 0.675))
  wire((-0.75, 0.675), (-0.75, -0.425))
  wire((-0.75, -0.425), (-0.4, -0.425))

  // B: в AND1 (нижний) и XOR1 (нижний).
  wire((-1.3, -0.575), (-0.4, -0.575))
  jdot((-0.55, -0.575))
  wire((-0.55, -0.575), (-0.55, 0.525))
  wire((-0.55, 0.525), (-0.4, 0.525))

  // P = A xor B: из XOR1 в XOR2 и в AND2.
  wire((0.4, 0.6), (0.95, 0.6))
  jdot((0.675, 0.6))
  wire((0.675, 0.6), (0.675, -0.375))
  wire((0.675, -0.375), (0.95, -0.375))

  // Cin: входит слева, в AND2 (нижний) и в XOR2 (нижний).
  wire((-1.3, -0.225), (0.95, -0.225))
  jdot((0.5, -0.225))
  wire((0.5, -0.225), (0.5, 0.5))
  wire((0.5, 0.5), (0.95, 0.5))

  // AND1 -> OR (огибает AND2 снизу).
  wire((0.4, -0.5), (0.4, -1.05))
  wire((0.4, -1.05), (1.8, -1.05))
  wire((1.8, -1.05), (1.8, -0.575))
  wire((1.8, -0.575), (1.9, -0.575))

  // AND2 -> OR.
  wire((1.75, -0.3), (1.75, -0.425))
  wire((1.75, -0.425), (1.9, -0.425))

  // Выходы.
  wire((1.75, 0.6), (2.0, 0.6))
  wire((2.7, -0.5), (3.0, -0.5))

  lab((-1.35, 0.675), "east", $A$)
  lab((-1.35, -0.575), "east", $B$)
  lab((-1.35, -0.225), "east", $C_"in"$)
  lab((2.05, 0.6), "west", $S$)
  lab((3.05, -0.5), "west", $C_"out"$)
})

// ── Мультиплексор 4-в-1 ──
#let multiplexer-4to1 = canvas({
  // Корпус-трапеция: широкая левая сторона (входы D0..D3), узкая правая (выход Y).
  draw.rect((0, 1.0), (2.1, -1.0), fill: c-gate-fill, stroke: none, radius: 2pt)
  draw.line((0, 1.0), (2.1, 0.5), stroke: c-gate-str + 0.8pt)
  draw.line((2.1, 0.5), (2.1, -0.5), stroke: c-gate-str + 0.8pt)
  draw.line((2.1, -0.5), (0, -1.0), stroke: c-gate-str + 0.8pt)
  draw.line((0, -1.0), (0, 1.0), stroke: c-gate-str + 0.8pt)

  // Внутренняя подпись.
  draw.content((1.0, 0.1), text(size: 0.42em, fill: c-text, weight: "bold")[MUX])
  draw.content((1.0, -0.35), text(size: 0.4em, fill: oklch(45%, 0.02, 265deg))[$4 times 1$])

  // Входы данных D0..D3 слева.
  let dy = (0.75, 0.25, -0.25, -0.75)
  for (i, y) in dy.enumerate() {
    wire((-0.5, y), (0, y))
    lab((-0.55, y), "east", $D_#i$)
  }

  // Выход Y справа.
  wire((2.1, 0), (2.6, 0))
  lab((2.65, 0), "west", $Y$)

  // Адресные линии S0, S1 сверху.
  wire((0.6, 1.0), (0.6, 1.4))
  lab((0.6, 1.45), "south", $S_0$)
  wire((1.4, 1.0), (1.4, 1.4))
  lab((1.4, 1.45), "south", $S_1$)

  // Формула снизу.
  draw.content((1.05, -1.3), text(size: 0.4em, fill: oklch(45%, 0.02, 265deg))[
    $Y = D_((S_1 S_0)_2)$
  ])
})
