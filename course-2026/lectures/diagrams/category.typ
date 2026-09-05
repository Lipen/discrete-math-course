// Category theory: loops, paths, functors, universal properties.
// Скопировано из книги и адаптировано под слайды, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-ink = oklch(27%, 0.02, 260deg)
#let c-edge = oklch(40%, 0.02, 265deg)
#let c-bd = oklch(56%, 0.07, 250deg)
#let c-fl = oklch(91%, 0.03, 250deg)
#let c-accent = oklch(55%, 0.16, 230deg)
#let c-hot = oklch(56%, 0.20, 22deg)
#let c-muted = luma(45%)

#let e-stroke = (paint: c-edge, thickness: 0.9pt)
#let d-stroke = (paint: c-edge, thickness: 0.9pt, dash: "dashed")
#let hi-stroke = (paint: c-accent, thickness: 1.4pt)
#let n-stroke = c-bd + 0.9pt

#let arrow(fr, to, lab, stroke: e-stroke, side: auto, pos: none, ..extra) = {
  let opts = (label: lab, label-side: side, label-size: 0.8em, stroke: stroke)
  if pos != none { opts.insert("label-pos", pos) }
  edge(fr, to, "-}>", ..opts, ..extra)
}

// ── Моноид как категория с одним объектом ──
#let monoid-loops = canvas({
  // Петли-лассо: окружности, касающиеся объекта, рисуются до него.
  draw.arc((-0.85, 0), start: 30deg, stop: 330deg, radius: 0.85, stroke: e-stroke, mark: (end: ">"))
  draw.arc((0.85, 0), start: 210deg, stop: 510deg, radius: 0.85, stroke: e-stroke, mark: (end: ">"))
  draw.circle((0, 0), radius: 0.42, stroke: n-stroke, fill: c-fl, name: "m")
  draw.content("m", text(size: 1.1em, fill: c-ink)[$M$])
  draw.content((-1.9, 0), text(size: 0.8em, fill: c-ink)[$a$])
  draw.content((1.9, 0), text(size: 0.8em, fill: c-ink)[$a star a$])
  draw.content((0, -1.0), text(size: 0.8em, fill: c-muted)[$"id"_M = e$])
})

// ── Цепочка как тонкая категория ──
#let poset-chain = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.2em,
  {
    node((0, 0), $0$, name: <z>)
    node((0, 1.6), $1$, name: <o>)
    node((0, 3.2), $2$, name: <t>)
    arrow(<z>, <o>, $<=$)
    arrow(<o>, <t>, $<=$)
    edge(<z>, <t>, "-}>", label: [$<=$], label-side: left, label-size: 0.8em, stroke: d-stroke)
  },
)

// ── Свободная категория графа ──
#let free-cat-paths = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, 0), $A$, name: <a>)
    node((1.7, 0), $B$, name: <b>)
    node((3.4, 0), $C$, name: <c>)
    arrow(<a>, <b>, $f$)
    arrow(<b>, <c>, $g$)
    arrow(<a>, <c>, $g circle.stroked.tiny f$, stroke: hi-stroke, pos: 0.5)
  },
)

// ── Булеан: образ и прообраз ──
#let powerset-functor = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, 0), $A$, name: <a>)
    node((2, 0), $B$, name: <b>)
    node((0, 2), $cal(P)(A)$, name: <pa>)
    node((2, 2), $cal(P)(B)$, name: <pb>)
    arrow(<a>, <b>, $f$, pos: 0.45)
    arrow(<pa>, <pb>, $"img"_f$, stroke: d-stroke, pos: 0.45, bend: 18deg)
    arrow(<pb>, <pa>, $f^(-1)$, stroke: (paint: c-hot, thickness: 1.4pt), pos: 0.45, side: right, bend: 18deg)
  },
)

// ── Квадрат естественности ──
#let nat-square = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.6em,
  {
    node((0, 0), $F(A)$, name: <fa>)
    node((2.3, 0), $F(B)$, name: <fb>)
    node((0, 2), $G(A)$, name: <ga>)
    node((2.3, 2), $G(B)$, name: <gb>)
    arrow(<fa>, <fb>, $F(f)$, pos: 0.4)
    arrow(<ga>, <gb>, $G(f)$, pos: 0.4)
    arrow(<fa>, <ga>, $alpha_A$, side: left)
    arrow(<fb>, <gb>, $alpha_B$, side: right)
  },
)

// ── Универсальное свойство произведения ──
#let product-universal = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3.4em,
  {
    node((1.5, 0), $A times B$, name: <ab>)
    node((0, 1.9), $A$, name: <a>)
    node((3, 1.9), $B$, name: <b>)
    node((-2.3, 0), $X$, name: <x>)
    arrow(<ab>, <a>, $pi_1$, side: left)
    arrow(<ab>, <b>, $pi_2$, side: right)
    arrow(<x>, <a>, $f$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <b>, $g$, stroke: d-stroke, pos: 0.5)
    arrow(<x>, <ab>, $chevron.l f, g chevron.r^!$, stroke: hi-stroke, pos: 0.5)
  },
)

// ── Конус и предел ──
#let cone-limit = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,
  {
    node((2.7, 0.9), $A$, name: <a>)
    node((4.4, 0.9), $B$, name: <b>)
    node((3.55, -0.6), $C$, name: <c>)
    arrow(<a>, <c>, $u$)
    arrow(<b>, <c>, $v$)
    node((2.7, 3.1), $N$, name: <n>, stroke: (paint: c-muted, thickness: 0.9pt, dash: "dashed"))
    edge(<n>, <a>, "-}>", stroke: d-stroke)
    edge(<n>, <b>, "-}>", stroke: d-stroke)
    edge(<n>, <c>, "-}>", stroke: d-stroke)
    node((0, 3.1), $lim D$, name: <l>, stroke: hi-stroke)
    edge(<l>, <a>, "-}>", stroke: hi-stroke)
    edge(<l>, <b>, "-}>", stroke: hi-stroke)
    edge(<l>, <c>, "-}>", stroke: hi-stroke)
    edge(<n>, <l>, "-|>", label: [$!$], label-size: 0.8em, stroke: (paint: c-muted, thickness: 0.5pt, dash: "dashed"))
  },
)

// ── Сопряжение: биекция стрелок ──
#let adjunction-bijection = canvas({
  let box(x, y, w, h, name, body) = {
    draw.rect((x - w / 2, y - h / 2), (x + w / 2, y + h / 2), name: name, radius: 5pt, stroke: n-stroke, fill: none)
    draw.content(name, text(size: 1.1em, fill: c-ink)[#body])
  }

  box(0, 1.2, 1.7, 2.7, "cc", $cal(C)$)
  box(5.7, 1.2, 1.7, 2.7, "dd", $cal(D)$)

  draw.line((0.05, 3.15), (5.65, 3.15), stroke: e-stroke, mark: (end: ">"), name: "farr")
  draw.content("farr", text(size: 0.8em, fill: c-ink)[$F$], anchor: "south")
  draw.line((5.65, -0.75), (0.05, -0.75), stroke: e-stroke, mark: (end: ">"), name: "garr")
  draw.content("garr", text(size: 0.8em, fill: c-ink)[$G$], anchor: "north")

  draw.content((3.35, 2.05), text(size: 0.8em, fill: c-hot)[$F(X) -> Y$], anchor: "south", name: "top1")
  draw.content((3.35, 0.4), text(size: 0.8em, fill: c-hot)[$X -> G(Y)$], anchor: "south", name: "top2")

  draw.line((3.35, 0.62), (3.35, 1.9), stroke: (paint: c-muted, thickness: 0.5pt, dash: "dashed"), mark: (end: ">", begin: ">"), name: "bij")
  draw.content("bij", text(size: 0.7em, fill: c-muted)[биекция], anchor: "west")
})
