#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let n-stroke = t-bd + c-bd
#let e-stroke = (paint: c-edge, thickness: t-ed)
#let hi-stroke = (paint: c-edge, thickness: t-hi)
#let hot-stroke = (paint: c-hot, thickness: t-hi)

// ── Архитектура DPLL(T) ──
// SAT-решатель отдаёт кандидата-модель theory-солверу, тот возвращает T-лемму.
#let dpll-t-architecture = canvas({
  let module(cy, title, subtitle, fill) = {
    draw.rect((-2.7, cy - 0.55), (2.7, cy + 0.55), fill: fill, stroke: n-stroke, radius: 3pt)
    draw.content((0, cy + 0.2), text(size: s-node, fill: c-ink, weight: "bold")[#title])
    draw.content((0, cy - 0.2), text(size: s-cap, fill: c-muted)[#subtitle])
  }

  module(1.1, [SAT-решатель], [DPLL / CDCL], c-fl)
  module(-1.1, [Theory-солвер], [DL, EUF, LRA, ...], c-atom)

  draw.line((1.7, 0.55), (1.7, -0.55), stroke: e-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((2.2, 0), anchor: "west", text(size: s-cap, fill: c-muted)[кандидат-модель])

  draw.line((-1.7, -0.55), (-1.7, 0.55), stroke: e-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((-2.2, 0), anchor: "east", text(size: s-cap, fill: c-muted)[$T$-лемма])
})

// ── Отрицательный цикл разности ──
// x=0 фиксировано; z>=x+3, w>=z+1, w<=x+2 образуют цикл с суммой -2:
// при пробном z=3.5 требуется w>=4.5, а красная граница допускает только w<=2.
#let dl-negative-cycle = canvas({
  let ax-y = 0
  let guide-stroke = (paint: c-muted, thickness: 0.5pt, dash: "dashed")
  let hot-guide = (paint: c-hot, thickness: 0.6pt, dash: "dashed")

  let tick(v) = {
    draw.line((v, ax-y), (v, ax-y - 0.14), stroke: c-muted + 0.6pt)
    draw.content((v, ax-y - 0.5), text(size: s-tiny, fill: c-muted)[#v])
  }

  let vpoint(pos, label, open: false) = {
    draw.circle(pos, radius: 0.16,
      fill: if open { white } else { c-ink },
      stroke: if open { (paint: c-hot, thickness: 0.7pt, dash: "dashed") } else { c-ink + 0.7pt })
    draw.content((pos.at(0) - if open { 0.3 } else { 0 }, pos.at(1) + 0.42), anchor: "south",
      text(size: s-node, fill: c-ink, weight: "bold")[#label])
  }

  let guide(px, py, stroke: guide-stroke) = draw.line((px, ax-y), (px, py), stroke: stroke)

  draw.line((-2.0, ax-y), (5.9, ax-y), stroke: e-stroke, mark: (end: "stealth", fill: c-edge))
  for v in range(6) { tick(v) }
  vpoint((0, ax-y), $x$)

  draw.line((0, 1.0), (3, 1.0), stroke: hi-stroke)
  draw.line((3, 0.82), (3, 1.18), stroke: hi-stroke)
  draw.line((3, 1.0), (5.6, 1.0), stroke: hi-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((1.5, 1.42), text(size: s-cap, fill: c-ink)[$z >= x + 3$])
  draw.content((2.95, 1.42), anchor: "west", text(size: s-tiny, fill: c-muted)[разрешено $z >= 3$])
  guide(3.5, 1.0)
  vpoint((3.5, ax-y), $z?$, open: true)

  draw.line((3.5, 2.0), (4.5, 2.0), stroke: hi-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((3.3, 2.35), anchor: "east", text(size: s-cap, fill: c-ink)[$w >= z + 1$])
  guide(4.5, 3.0, stroke: hot-guide)
  vpoint((4.5, ax-y), $w?$, open: true)

  draw.line((-2.0, 3.0), (2, 3.0), stroke: hot-stroke)
  draw.line((2, 2.82), (2, 3.18), stroke: hot-stroke)
  draw.line((-2.0, 3.0), (-2.9, 3.0), stroke: hot-stroke, mark: (end: "stealth", fill: c-hot))
  draw.content((0.1, 3.42), text(size: s-cap, fill: c-hot, weight: "bold")[$w <= x + 2$])
  draw.content((0.1, 2.62), anchor: "north", text(size: s-tiny, fill: c-hot)[разрешено $w <= 2$])
  draw.content((3.3, 3.0), text(size: 1.0em, fill: c-hot, weight: "bold")[✗])
  draw.content((3.3, 3.45), anchor: "south", text(size: s-cap, fill: c-hot, weight: "bold")[противоречие])

  draw.content((1.6, -1.5), text(size: s-cap, fill: c-hot, weight: "bold")[
    требуется $w >= 4.5$, но разрешено $w <= 2$ ⟹ $-3 - 1 + 2 = -2 < 0$
  ])
})

// ── Замыкание конгруэнтности ──
// Два класса делят b, сливаются в {a, b, f(a)}; конгруэнтность даёт g(a)=g(f(a)),
// что противоречит третьему литералу.
#let congruence-closure-merge = canvas({
  let cnode(pos, label, fill: c-fl) = {
    draw.circle(pos, radius: 0.42, fill: fill, stroke: n-stroke)
    draw.content(pos, text(size: s-node, fill: c-ink)[#label])
  }

  draw.rect((-3.8, 2.7), (-0.2, 3.7), fill: c-fl, stroke: n-stroke, radius: 3pt)
  cnode((-2.7, 3.2), $a$)
  cnode((-1.3, 3.2), $b$)
  draw.content((-2.0, 4.15), anchor: "south", text(size: s-cap, fill: c-ink, weight: "bold")[класс ${a, b}$])

  draw.rect((0.2, 2.7), (3.8, 3.7), fill: c-fl, stroke: n-stroke, radius: 3pt)
  cnode((1.3, 3.2), $f(a)$)
  cnode((2.7, 3.2), $b$)
  draw.content((2.0, 4.15), anchor: "south", text(size: s-cap, fill: c-ink, weight: "bold")[класс ${f(a), b}$])

  draw.line((0, 2.7), (0, 2.2), stroke: e-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((0.22, 2.45), anchor: "west", text(size: s-tiny, fill: c-muted)[слияние])

  draw.rect((-2.9, 0.7), (2.9, 2.2), fill: c-atom, stroke: n-stroke, radius: 3pt)
  cnode((-1.8, 1.25), $a$)
  cnode((0, 1.25), $b$)
  cnode((1.8, 1.25), $f(a)$)
  draw.content((0, 1.92), text(size: s-cap, fill: c-ink, weight: "bold")[класс ${a, b, f(a)}$])

  draw.line((0, 0.7), (0, 0.05), stroke: e-stroke, mark: (end: "stealth", fill: c-edge))
  draw.content((0.22, 0.38), anchor: "west", text(size: s-tiny, fill: c-muted)[конгруэнтность: $a = f(a)$])

  draw.rect((-2.9, -0.6), (2.9, 0.0), fill: c-fl, stroke: hot-stroke, radius: 3pt)
  draw.content((0, -0.3), text(size: s-node, fill: c-ink, weight: "bold")[$g(a) = g(f(a))$])
  draw.content((0, -1.0), text(size: s-cap, fill: c-hot, weight: "bold")[противоречит $not (g(a) = g(f(a)))$])
})
