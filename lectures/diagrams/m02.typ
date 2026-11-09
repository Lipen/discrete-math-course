// Деревья вывода и поиск: curryst для правил, Fletcher для дерева целей.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "@preview/curryst:0.6.0": prooftree, rule
#import "style.typ": *

#let imply = sym.arrow.r

#let rname(body) = text(size: 0.8em, fill: ink)[#body]
#let bar = 0.8pt + ink

// ── Цепочка двух MP: C выводится из A -> B, A и B -> C ──
#let mp-chain = prooftree(
  rule(
    name: rname[$"MP"$],
    rule(
      name: rname[$"MP"$],
      $A imply B$,
      $A$,
      $B$,
    ),
    $B imply C$,
    $C$,
  ),
  stroke: bar,
)

// ── Проекция: (A and B) -> A ──
#let nd-projection = prooftree(
  rule(
    name: rname[$imply I thin 1$],
    rule(
      name: rname[$and E$],
      $[A and B]^1$,
      $A$,
    ),
    $(A and B) imply A$,
  ),
  stroke: bar,
)

// ── Коммутативность: (A and B) -> (B and A) ──
#let nd-comm = prooftree(
  rule(
    name: rname[$imply I thin 1$],
    rule(
      name: rname[$and I$],
      rule(
        name: rname[$and E$],
        $[A and B]^1$,
        $B$,
      ),
      rule(
        name: rname[$and E$],
        $[A and B]^1$,
        $A$,
      ),
      $B and A$,
    ),
    $(A and B) imply (B and A)$,
  ),
  stroke: bar,
)

// ── Связка tonk: пример нарушения гармонии ──
#let nd-rule-tonk-i = prooftree(
  rule(
    name: rname[$"tonk" I$],
    $A$,
    $A "tonk" B$,
  ),
  stroke: bar,
)

#let nd-rule-tonk-e = prooftree(
  rule(
    name: rname[$"tonk" E$],
    $A "tonk" B$,
    $B$,
  ),
  stroke: bar,
)

// ── Схемы правил натуральной дедукции ──
#let nd-rule-iie = prooftree(
  rule(
    name: rname[$imply E$],
    $A imply B$,
    $A$,
    $B$,
  ),
  stroke: bar,
)

#let nd-rule-iii = prooftree(
  rule(
    name: rname[$imply I$],
    rule(
      $[A]^1$,
      $dots.v$,
      $B$,
    ),
    $A imply B$,
  ),
  stroke: bar,
)

#let nd-rule-andi = prooftree(
  rule(
    name: rname[$and I$],
    $A$,
    $B$,
    $A and B$,
  ),
  stroke: bar,
)

#let nd-rule-ande = grid(
  columns: 2,
  column-gutter: 0.8em,
  align: center,
  prooftree(
    rule(
      name: rname[$and E$],
      $A and B$,
      $A$,
    ),
    stroke: bar,
  ),
  prooftree(
    rule(
      name: rname[$and E$],
      $A and B$,
      $B$,
    ),
    stroke: bar,
  ),
)

#let nd-rule-ori = grid(
  columns: 2,
  column-gutter: 0.8em,
  align: center,
  prooftree(
    rule(
      name: rname[$or I$],
      $A$,
      $A or B$,
    ),
    stroke: bar,
  ),
  prooftree(
    rule(
      name: rname[$or I$],
      $B$,
      $A or B$,
    ),
    stroke: bar,
  ),
)

#let nd-rule-ore = prooftree(
  rule(
    name: rname[$or E$],
    $A or B$,
    rule(
      $[A]^1$,
      $dots.v$,
      $C$,
    ),
    rule(
      $[B]^2$,
      $dots.v$,
      $C$,
    ),
    $C$,
  ),
  stroke: bar,
)

#let nd-rule-ne = prooftree(
  rule(
    name: rname[$not E$],
    $A$,
    $not A$,
    $bot$,
  ),
  stroke: bar,
)

#let nd-rule-ni = prooftree(
  rule(
    name: rname[$not I$],
    rule(
      $[A]^1$,
      $dots.v$,
      $bot$,
    ),
    $not A$,
  ),
  stroke: bar,
)

#let nd-rule-bote = prooftree(
  rule(
    name: rname[$bot E$],
    $bot$,
    $A$,
  ),
  stroke: bar,
)

#let nd-rule-ip = prooftree(
  rule(
    name: rname[IP],
    rule(
      $[not A]^1$,
      $dots.v$,
      $bot$,
    ),
    $A$,
  ),
  stroke: bar,
)

// ── Поиск с возвратом: тупик и откат на дереве целей ──
#let search-node(pos, body, note, tone, ..args) = node(
  pos,
  text(size: 1.3em)[#body \ #text(size: 0.62em, fill: tone)[#note]],
  fill: tone.lighten(88%),
  stroke: 1.1pt + tone,
  corner-radius: 4pt,
  inset: 0.3em,
  width: auto,
  height: auto,
  ..args,
)

#let search-backtrack = diagram(
  spacing: 2.2em,
  search-node((0, 0), [$p or q$], [цель], cool, name: <search-root>),
  search-node((-1.8, 1.5), [$p$], [тупик], warm, name: <search-dead>),
  search-node((1.8, 1.5), [$q$], [успех], green, name: <search-ok>),
  edge(
    <search-root>,
    <search-dead>,
    "-}>",
    stroke: 1.1pt + cool,
    label: text(fill: ink)[$or I$],
    label-side: left,
  ),
  edge(
    <search-root>,
    <search-ok>,
    "-}>",
    stroke: 1.1pt + cool,
    label: text(fill: ink)[$or I$],
    label-side: right,
  ),
  edge(
    <search-dead>,
    <search-ok>,
    "-}>",
    stroke: (paint: warm, thickness: 1.2pt, dash: "dashed"),
    label: text(fill: warm)[откат],
  ),
)
