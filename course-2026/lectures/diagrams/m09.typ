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
#let gate(pos, label, w: 1.7, h: 0.9) = {
  let (x, y) = pos
  draw.rect(
    (x - w / 2, y - h / 2),
    (x + w / 2, y + h / 2),
    fill: c-gate-fill,
    stroke: (paint: c-gate-str, thickness: 0.8pt),
    radius: 3pt,
  )
  draw.content(pos, text(size: 0.6em, fill: c-text, weight: "bold")[#label])
}

// Точка соединения (узел), где провода реально соединяются.
#let jdot(pos) = draw.circle(pos, radius: 0.055, fill: c-edge)

// Провод.
#let wire(a, b) = draw.line(a, b, stroke: c-edge + 0.7pt)

// Подпись.
#let lab(pos, anchor, body) = draw.content(
  pos,
  anchor: anchor,
  text(size: 0.68em, fill: c-text)[#body],
)

// ── Полусумматор: S = A xor B, C = A and B ──
#let half-adder = canvas({
  gate((0, 0.9), "XOR")
  gate((0, -0.9), "AND")

  // A: верхний вход, в верхний порт XOR и верхний порт AND.
  wire((-2.5, 1.15), (-0.85, 1.15))
  jdot((-1.5, 1.15))
  wire((-1.5, 1.15), (-1.5, -0.65))
  wire((-1.5, -0.65), (-0.85, -0.65))

  // B: нижний вход, в нижний порт AND и нижний порт XOR.
  wire((-2.5, -1.15), (-0.85, -1.15))
  jdot((-1.1, -1.15))
  wire((-1.1, -1.15), (-1.1, 0.65))
  wire((-1.1, 0.65), (-0.85, 0.65))

  // Выходы.
  wire((0.85, 0.9), (1.35, 0.9))
  wire((0.85, -0.9), (1.35, -0.9))

  lab((-2.6, 1.15), "east", $A$)
  lab((-2.6, -1.15), "east", $B$)
  lab((1.45, 0.9), "west", $S$)
  lab((1.45, -0.9), "west", $C$)
})

// ── Полный сумматор: S = A xor B xor Cin, Cout = (A and B) or (Cin and (A xor B)) ──
#let full-adder = canvas({
  // Колонка 1: XOR1 (сумма A,B) и AND1 (перенос A,B).
  gate((0, 1.2), "XOR", w: 1.6)
  gate((0, -1.0), "AND", w: 1.6)
  // Колонка 2: XOR2 (сумма с Cin) и AND2 (перенос от Cin и A xor B).
  gate((2.7, 1.2), "XOR", w: 1.6)
  gate((2.7, -0.6), "AND", w: 1.6)
  // Колонка 3: OR (итоговый перенос).
  gate((4.6, -1.0), "OR", w: 1.6)

  // A: в XOR1 (верхний) и AND1 (верхний).
  wire((-2.6, 1.35), (-0.8, 1.35))
  jdot((-1.5, 1.35))
  wire((-1.5, 1.35), (-1.5, -0.85))
  wire((-1.5, -0.85), (-0.8, -0.85))

  // B: в AND1 (нижний) и XOR1 (нижний).
  wire((-2.6, -1.15), (-0.8, -1.15))
  jdot((-1.1, -1.15))
  wire((-1.1, -1.15), (-1.1, 1.05))
  wire((-1.1, 1.05), (-0.8, 1.05))

  // P = A xor B: из XOR1 в XOR2 и в AND2.
  wire((0.8, 1.2), (1.9, 1.2))
  jdot((1.35, 1.2))
  wire((1.35, 1.2), (1.35, -0.75))
  wire((1.35, -0.75), (1.9, -0.75))

  // Cin: входит слева, в AND2 (нижний) и в XOR2 (нижний).
  wire((-2.6, -0.45), (1.9, -0.45))
  jdot((1.0, -0.45))
  wire((1.0, -0.45), (1.0, 1.0))
  wire((1.0, 1.0), (1.9, 1.0))

  // AND1 -> OR (огибает AND2 снизу).
  wire((0.8, -1.0), (0.8, -2.1))
  wire((0.8, -2.1), (3.6, -2.1))
  wire((3.6, -2.1), (3.6, -1.15))
  wire((3.6, -1.15), (3.8, -1.15))

  // AND2 -> OR.
  wire((3.5, -0.6), (3.5, -0.85))
  wire((3.5, -0.85), (3.8, -0.85))

  // Выходы.
  wire((3.5, 1.2), (4.0, 1.2))
  wire((5.4, -1.0), (6.0, -1.0))

  lab((-2.7, 1.35), "east", $A$)
  lab((-2.7, -1.15), "east", $B$)
  lab((-2.7, -0.45), "east", $C_"in"$)
  lab((4.1, 1.2), "west", $S$)
  lab((6.1, -1.0), "west", $C_"out"$)
})

// ── Мультиплексор 4-в-1 ──
#let multiplexer-4to1 = canvas({
  // Корпус-трапеция: широкая левая сторона (входы D0..D3), узкая правая (выход Y).
  draw.rect((0, 2.0), (4.2, -2.0), fill: c-gate-fill, stroke: none, radius: 2pt)
  draw.line((0, 2.0), (4.2, 1.0), stroke: c-gate-str + 0.8pt)
  draw.line((4.2, 1.0), (4.2, -1.0), stroke: c-gate-str + 0.8pt)
  draw.line((4.2, -1.0), (0, -2.0), stroke: c-gate-str + 0.8pt)
  draw.line((0, -2.0), (0, 2.0), stroke: c-gate-str + 0.8pt)

  // Внутренняя подпись.
  draw.content((2.0, 0.2), text(size: 0.6em, fill: c-text, weight: "bold")[MUX])
  draw.content((2.0, -0.7), text(size: 0.52em, fill: oklch(45%, 0.02, 265deg))[$4 times 1$])

  // Входы данных D0..D3 слева.
  let dy = (1.5, 0.5, -0.5, -1.5)
  for (i, y) in dy.enumerate() {
    wire((-1.0, y), (0, y))
    lab((-1.1, y), "east", $D_#i$)
  }

  // Выход Y справа.
  wire((4.2, 0), (5.2, 0))
  lab((5.3, 0), "west", $Y$)

  // Адресные линии S0, S1 сверху.
  wire((1.2, 2.0), (1.2, 2.8))
  lab((1.2, 2.9), "south", $S_0$)
  wire((2.8, 2.0), (2.8, 2.8))
  lab((2.8, 2.9), "south", $S_1$)

  // Формула снизу.
  draw.content((2.1, -2.6), text(size: 0.55em, fill: oklch(45%, 0.02, 265deg))[
    $Y = D_((S_1 S_0)_2)$
  ])
})
