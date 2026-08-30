#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import "@preview/curryst:0.6.0": rule, prooftree

#let bar-str = c-edge + t-ed
#let rname(body) = text(size: s-cap, fill: c-muted)[#body]

// ── mp-chain-tree: цепочка из двух применений MP ──
#let mp-chain-tree = prooftree(
  rule(
    name: rname[MP],
    rule(
      name: rname[MP],
      $A -> B$,
      $A$,
      $B$,
    ),
    $B -> C$,
    $C$,
  ),
  stroke: bar-str,
)

// ── nd-tree-projection: проекция конъюнкции, введённой по →I ──
#let nd-tree-projection = prooftree(
  rule(
    name: rname[$->$I],
    rule(
      name: rname[$and$E],
      $A and B$,
      $A$,
    ),
    $A and B -> A$,
  ),
  stroke: bar-str,
)

// ── seq-tree-lem: закон исключённого третьего (контракция) ──
#let seq-tree-lem = prooftree(
  rule(
    name: rname[контракция],
    rule(
      name: rname[$or R_2$],
      rule(
        name: rname[$or R_1$],
        rule(
          name: rname[$not$R],
          $A proves A$,
          $proves not A, A$,
        ),
        $proves not A, A or not A$,
      ),
      $proves A or not A, A or not A$,
    ),
    $proves A or not A$,
  ),
  stroke: bar-str,
)

// ── seq-tree-comm: коммутативность дизъюнкции ──
#let seq-tree-comm = prooftree(
  rule(
    name: rname[$or$L],
    rule(
      name: rname[$or R_2$],
      $A proves A$,
      $A proves B or A$,
    ),
    rule(
      name: rname[$or R_1$],
      $B proves B$,
      $B proves B or A$,
    ),
    $A or B proves B or A$,
  ),
  stroke: bar-str,
)

// ── res-tree-trans: транзитивность резолюции по P, Q, R ──
#let res-tree-trans = prooftree(
  rule(
    name: rname[резолюция по $R$],
    rule(
      name: rname[резолюция по $Q$],
      rule(
        name: rname[резолюция по $P$],
        $not P or Q$,
        $P$,
        $Q$,
      ),
      $not Q or R$,
      $R$,
    ),
    $not R$,
    $square$,
  ),
  stroke: bar-str,
)
