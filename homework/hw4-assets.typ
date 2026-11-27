#import "@preview/cetz:0.5.2": canvas, draw

// ── Форматы команд RISC-V ──

#let riscv-formats = {
  let fields = (
    (
      "R",
      ("funct7", 7, "f7"),
      ("rs2", 5, "rs"),
      ("rs1", 5, "rs"),
      ("f3", 3, "f3"),
      ("rd", 5, "rd"),
      ("opcode", 7, "op"),
    ),
    (
      "I",
      ("imm", 12, "imm"),
      ("rs1", 5, "rs"),
      ("f3", 3, "f3"),
      ("rd", 5, "rd"),
      ("opcode", 7, "op"),
    ),
    (
      "S",
      ("imm", 7, "imm"),
      ("rs2", 5, "rs"),
      ("rs1", 5, "rs"),
      ("f3", 3, "f3"),
      ("imm", 5, "imm"),
      ("opcode", 7, "op"),
    ),
    (
      "B",
      ("imm", 7, "imm"),
      ("rs2", 5, "rs"),
      ("rs1", 5, "rs"),
      ("f3", 3, "f3"),
      ("imm", 5, "imm"),
      ("opcode", 7, "op"),
    ),
  )
  let fills = (
    "op": luma(90%),
    "rs": luma(84%),
    "rd": luma(88%),
    "f3": luma(80%),
    "f7": luma(76%),
    "imm": luma(94%),
  )
  let unit = 0.42
  let row-h = 0.5
  let gap = 0.28
  let x0 = 0.6
  let top = 0.5
  canvas({
    for (idx, (fmt, ..parts)) in fields.enumerate() {
      let y = top - idx * (row-h + gap)
      draw.content(
        (x0 - 0.15, y - row-h / 2),
        text(size: 0.8em, weight: "bold")[#fmt],
        anchor: "east",
      )
      let x = x0
      for (label, width, kind) in parts {
        let w = width * unit
        draw.rect(
          (x, y),
          (x + w, y - row-h),
          fill: fills.at(kind),
          stroke: 0.5pt + luma(40%),
        )
        draw.content((x + w / 2, y - row-h / 2), text(size: 0.72em)[#label])
        x += w
      }
    }
    // Номера бит стоят над левыми рёбрами клеток R-формата, правый край --- младший бит 0.
    let (_, ..parts) = fields.at(0)
    let remaining = 31
    let x = x0
    for (i, (label, width, kind)) in parts.enumerate() {
      let anchor = if i == 0 { "south-east" } else { "south" }
      draw.content(
        (x, top + row-h + gap / 2),
        text(size: 0.72em)[#remaining],
        anchor: anchor,
      )
      x += width * unit
      remaining -= width
    }
    draw.content(
      (x, top + row-h + gap / 2),
      text(size: 0.72em)[0],
      anchor: "south-west",
    )
  })
}

// ── Доска сапёра ──

#let minesweeper-board = {
  let cell = 1.0
  let pad = 0.16
  let bevel = 0.06
  let inset = 0.035
  let values = (
    ("?", "?", "?", "?"),
    ("?", "3", "1", "1"),
    ("?", "1", "0", "0"),
    ("?", "1", "0", "0"),
  )
  let letters = ("а", "б", "в", "г")
  let digit-fill = (
    "0": luma(55%),
    "1": rgb("#1d4ed8"),
    "2": rgb("#15803d"),
    "3": rgb("#b91c1c"),
  )
  let n = values.len()
  let m = values.at(0).len()
  let outer-w = m * cell + 2 * pad
  let outer-h = n * cell + 2 * pad

  // Скос клетки: светлое ребро сверху и слева, тёмное снизу и справа.
  let bevel-lines(x0, y0, x1, y1, thick, light, dark) = {
    draw.line(
      (x0 + inset, y0 - inset),
      (x1 - inset, y0 - inset),
      stroke: thick + light,
    )
    draw.line(
      (x0 + inset, y0 - inset),
      (x0 + inset, y1 + inset),
      stroke: thick + light,
    )
    draw.line(
      (x0 + inset, y1 + inset),
      (x1 - inset, y1 + inset),
      stroke: thick + dark,
    )
    draw.line(
      (x1 - inset, y0 - inset),
      (x1 - inset, y1 + inset),
      stroke: thick + dark,
    )
  }

  canvas({
    draw.rect((0, 0), (outer-w, -outer-h), fill: luma(58%), stroke: none)
    draw.rect(
      (bevel, -bevel),
      (outer-w - bevel, -outer-h + bevel),
      fill: luma(82%),
      stroke: none,
    )
    draw.line((0, 0), (outer-w, 0), stroke: 1.5pt + luma(97%))
    draw.line((0, 0), (0, -outer-h), stroke: 1.5pt + luma(97%))
    draw.line((0, -outer-h), (outer-w, -outer-h), stroke: 1.5pt + luma(45%))
    draw.line((outer-w, 0), (outer-w, -outer-h), stroke: 1.5pt + luma(45%))
    for r in range(n) {
      for c in range(m) {
        let v = values.at(r).at(c)
        let x0 = pad + c * cell
        let y0 = -pad - r * cell
        let x1 = x0 + cell
        let y1 = y0 - cell
        let center = ((x0 + x1) / 2, (y0 + y1) / 2)
        if v == "?" {
          draw.rect((x0, y0), (x1, y1), fill: luma(58%), stroke: none)
          draw.rect(
            (x0 + inset, y0 - inset),
            (x1 - inset, y1 + inset),
            fill: luma(80%),
            stroke: none,
          )
          bevel-lines(x0, y0, x1, y1, 1pt, luma(97%), luma(52%))
          draw.content(
            center,
            text(size: 1.4em, weight: "bold", fill: rgb("#1e3a8a"))[?],
          )
        } else {
          draw.rect((x0, y0), (x1, y1), fill: luma(88%), stroke: none)
          bevel-lines(x0, y0, x1, y1, 0.8pt, luma(70%), luma(97%))
          draw.content(
            center,
            text(
              size: if v == "0" { 1.2em } else { 1.4em },
              weight: "bold",
              fill: digit-fill.at(v),
            )[#v],
          )
        }
      }
    }
    for (c, letter) in letters.enumerate() {
      draw.content(
        (pad + c * cell + cell / 2, 0.30),
        text(fill: luma(30%))[#letter],
      )
    }
    for r in range(n) {
      draw.content(
        (-0.30, -pad - r * cell - cell / 2),
        text(fill: luma(30%))[#(r + 1)],
      )
    }
  })
}

// ── Данные кода SECDED ──

// 64-битное слово данных: ровно 8 ASCII-символов.
#let ecc-phrase = "NICE TRY"
#let ecc-check = (1, 2, 4, 8, 16, 32, 64)
#let ecc-total = 72

#let ecc-bytes = ecc-phrase.codepoints().map(str.to-unicode)

#let ecc-hex = {
  let digits = "0123456789ABCDEF"
  let hex-byte(byte) = (
    digits.at(calc.quo(byte, 16)) + digits.at(calc.rem(byte, 16))
  )
  let groups = range(0, ecc-bytes.len(), step: 2).map(i => {
    hex-byte(ecc-bytes.at(i)) + hex-byte(ecc-bytes.at(i + 1))
  })
  "0x" + groups.join("_")
}

#let ecc-encode = {
  let data = range(1, ecc-total).filter(pos => not ecc-check.contains(pos))
  // Порядок бит данных: от младшего к старшему, байты от последнего символа к первому.
  let bytes = ecc-bytes.rev()
  let payload = range(data.len()).map(k => {
    let byte = bytes.at(calc.quo(k, 8))
    calc.rem(calc.quo(byte, calc.pow(2, calc.rem(k, 8))), 2)
  })
  let data-bit(pos) = {
    let index = pos - 1 - ecc-check.filter(p => p < pos).len()
    payload.at(index)
  }
  // Проверочные позиции --- степени двойки, поэтому проверочный бит в чужую область не попадает:
  // у позиции $2^q$ бит $p$ нулевой при $p eq.not q$.
  let parity(p) = data
    .filter(i => calc.rem(calc.quo(i, p), 2) == 1)
    .fold(0, (acc, i) => calc.rem(acc + data-bit(i), 2))
  let bits = range(1, ecc-total).map(pos => {
    if ecc-check.contains(pos) { parity(pos) } else { data-bit(pos) }
  })
  bits.push(bits.fold(0, (acc, bit) => calc.rem(acc + bit, 2)))
  bits
}

#let ecc-flip(bits, positions) = (
  bits
    .enumerate()
    .map(((i, bit)) => {
      if positions.contains(i + 1) { 1 - bit } else { bit }
    })
)

#let ecc-rows(bits) = range(0, 3).map(row => {
  range(0, 3)
    .map(j => {
      range(0, 8).map(k => str(bits.at((row * 3 + j) * 8 + k))).join("")
    })
    .join(" ")
})

#let ecc-single-flip = 20
#let ecc-double-flip = (20, 30)
#let ecc-one-rows = ecc-rows(ecc-flip(ecc-encode, (ecc-single-flip,)))
#let ecc-two-rows = ecc-rows(ecc-flip(ecc-encode, ecc-double-flip))
