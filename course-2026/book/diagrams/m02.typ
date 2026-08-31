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


// ── Схемы правил натуральной дедукции (посылки над чертой, заключение под ней) ──
#let nd-rule-iie = prooftree(
  rule(
    name: rname[$->$E],
    $A -> B$,
    $A$,
    $B$,
  ),
  stroke: bar-str,
)

#let nd-rule-iii = prooftree(
  rule(
    name: rname[$->$I],
    rule(
      $[A]^1$,
      $dots.v$,
      $B$,
    ),
    $A -> B$,
  ),
  stroke: bar-str,
)

#let nd-rule-andi = prooftree(
  rule(
    name: rname[$and$I],
    $A$,
    $B$,
    $A and B$,
  ),
  stroke: bar-str,
)

#let nd-rule-ande = prooftree(
  rule(
    name: rname[$and$E],
    $A and B$,
    $A$,
  ),
  stroke: bar-str,
)

#let nd-rule-ori = prooftree(
  rule(
    name: rname[$or$I],
    $A$,
    $A or B$,
  ),
  stroke: bar-str,
)

#let nd-rule-ore = prooftree(
  rule(
    name: rname[$or$E],
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
  stroke: bar-str,
)

#let nd-rule-ne = prooftree(
  rule(
    name: rname[$not$E],
    $A$,
    $not A$,
    $bot$,
  ),
  stroke: bar-str,
)

#let nd-rule-ni = prooftree(
  rule(
    name: rname[$not$I],
    rule(
      $[A]^1$,
      $dots.v$,
      $bot$,
    ),
    $not A$,
  ),
  stroke: bar-str,
)

#let nd-rule-bote = prooftree(
  rule(
    name: rname[$bot$ E],
    $bot$,
    $A$,
  ),
  stroke: bar-str,
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
  stroke: bar-str,
)

// ── nd-tree-comm: коммутативность конъюнкции ──
#let nd-tree-comm = prooftree(
  rule(
    name: rname[$and$I],
    rule(
      name: rname[$and$E],
      $A and B$,
      $B$,
    ),
    rule(
      name: rname[$and$E],
      $A and B$,
      $A$,
    ),
    $B and A$,
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
