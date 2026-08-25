// m02 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import "@preview/curryst:0.6.0": rule, prooftree

#let mp-chain-tree = prooftree(
  rule(
    name: [MP],
    rule(
      name: [MP],
      $A -> B$,
      $A$,
      $B$,
    ),
    $B -> C$,
    $C$,
  ),
)

#let nd-tree-projection = prooftree(
  rule(
    name: [$->$I],
    rule(
      name: [$and$E],
      $A and B$,
      $A$,
    ),
    $A and B -> A$,
  ),
)

#let seq-tree-lem = prooftree(
  rule(
    name: [контракция],
    rule(
      name: [$or R_1$],
      rule(
        name: [$or R_2$],
        rule(
          name: [$not$R],
          $A proves A$,
          $proves not A, A$,
        ),
        $proves not A, A or not A$,
      ),
      $proves A or not A, A or not A$,
    ),
    $proves A or not A$,
  ),
)

#let seq-tree-comm = prooftree(
  rule(
    name: [$or$L],
    rule(
      name: [$or R_2$],
      $A proves A$,
      $A proves B or A$,
    ),
    rule(
      name: [$or R_1$],
      $B proves B$,
      $B proves B or A$,
    ),
    $A or B proves B or A$,
  ),
)

#let res-tree-trans = prooftree(
  rule(
    name: [резолюция по $R$],
    rule(
      name: [резолюция по $Q$],
      rule(
        name: [резолюция по $P$],
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
)
