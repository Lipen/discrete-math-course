#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#5*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Graph Theory*
    #h(1fr)
    *$#emoji.snowflake$ Spring 2026*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ],
)

#set text(12pt)
#set par(justify: true)

#show table.cell.where(y: 0): strong

#show heading.where(level: 2): set block(below: 1em, above: 1.4em)

#set heading(numbering: "1.1")

#show emph: set text(fill: blue.darken(20%))

// Custom operators for graph theory
#let dist = math.op("dist")
#let diam = math.op("diam")
#let rad = math.op("rad")
#let girth = math.op("girth")
#let Center = math.op("center")
#let ecc = math.op("ecc")
#let deg = math.op("deg")
#let Adj = math.op("Adj")
#let kappa = sym.kappa
#let lam = sym.lambda

#let pair(a, b) = $angle.l #a, #b angle.r$

// Color helpers
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)
#let Orange(x) = text(orange.darken(20%), x)

// Task list helper
#let tasklist(id, cols: 1, body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display("1.")
  })
  columns(cols, gutter: 1em)[#body]
}

// Fancy box
#let Box(body, align: left, inset: 0.8em) = std.align(align)[
  #box(
    stroke: 0.4pt + gray,
    inset: inset,
    radius: 3pt,
  )[
    #set std.align(left)
    #set text(size: 10pt, style: "italic")
    #body
  ]
]

// Fancy block
#let Block(body, ..args) = {
  block(
    body,
    inset: (x: 1em),
    stroke: (left: 3pt + gray),
    outset: (y: 3pt, left: -3pt),
    ..args,
  )
}

// ============================================================================
// PROBLEM SET
// ============================================================================

// #Box(align: right)[
//   #set text(fill: blue.darken(20%))
//   "A mathematician is a device for turning coffee into theorems."

//   #align(right)[
//     --- Paul Erdős
//   ]
// ]

// ============================================================================
// SECTION I: GRAPH BASICS AND INVARIANTS
// ============================================================================

= Section I: Graph Basics and Invariants

== Problem 1: Graph Invariants Analysis

For each of the following graphs, determine:

*Basic metrics:*
- $delta(G)$, $Delta(G)$, $kappa(G)$, $lam(G)$
- All cut vertices and bridges (if any)

*Distance metrics:*
- $ecc(v)$ for every vertex $v in V(G)$, $rad(G)$, $diam(G)$, $Center(G)$

*Structural properties:*
- Is the graph Eulerian? Hamiltonian? Bipartite? Justify each answer.
- Find: maximum clique $Q subset.eq V$, maximum stable set $S subset.eq V$, maximum matching $M subset.eq E$
- Find: minimum vertex cover $R subset.eq V$ and minimum dominating set $D subset.eq V$

#import fletcher: diagram, edge, node, shapes
#let dot(pos, lbl, name, ..args) = blob(
  pos,
  lbl,
  shape: shapes.circle,
  radius: 8pt,
  name: name,
  ..args,
)

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 2em,
  [
    *(a)* #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        dot((0, 0), $a$, <a>, tint: blue),
        dot((1, 0), $b$, <b>, tint: blue),
        dot((2, 0), $c$, <c>, tint: blue),
        dot((0, 1), $d$, <d>, tint: blue),
        dot((1, 1), $e$, <e>, tint: blue),
        dot((2, 1), $f$, <f>, tint: blue),
        dot((0, 2), $g$, <g>, tint: blue),
        dot((1, 2), $h$, <h>, tint: blue),
        dot((2, 2), $i$, <i>, tint: blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<g>, <h>),
        edge(<h>, <i>),
        edge(<a>, <d>),
        edge(<b>, <e>),
        edge(<c>, <f>),
        edge(<d>, <g>),
        edge(<e>, <h>),
        edge(<f>, <i>),
        edge(<a>, <e>),
        edge(<e>, <i>),
        edge(<c>, <e>),
        edge(<e>, <g>),
      )
    ]
  ],
  [
    *(b)* #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (13mm, 13mm),
        dot((1, 1.5), $a$, <a>, tint: blue),
        dot((0, 1), $b$, <b>, tint: blue),
        dot((2, 1), $c$, <c>, tint: blue),
        dot((0, 0), $d$, <d>, tint: blue),
        dot((1, 0), $e$, <e>, tint: blue),
        dot((2, 0), $f$, <f>, tint: blue),
        dot((3, 1), $g$, <g>, tint: blue),
        dot((3, 0), $h$, <h>, tint: blue),
        edge(<a>, <b>, bend: 20deg),
        edge(<a>, <c>, bend: -20deg),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<c>, <e>),
        edge(<c>, <f>),
        edge(<c>, <g>),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <h>),
        edge(<g>, <h>),
        edge(<b>, <c>),
      )
    ]
  ],

  [
    *(c)* #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (12mm, 12mm),
        dot((-90deg + 360deg / 8 * 0, 1), $a$, tint: blue, <a>),
        dot((-90deg + 360deg / 8 * 1, 1), $b$, tint: blue, <b>),
        dot((-90deg + 360deg / 8 * 2, 1), $c$, tint: blue, <c>),
        dot((-90deg + 360deg / 8 * 3, 1), $d$, tint: blue, <d>),
        dot((-90deg + 360deg / 8 * 4, 1), $e$, tint: blue, <e>),
        dot((-90deg + 360deg / 8 * 5, 1), $f$, tint: blue, <f>),
        dot((-90deg + 360deg / 8 * 6, 1), $g$, tint: blue, <g>),
        dot((-90deg + 360deg / 8 * 7, 1), $h$, tint: blue, <h>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <g>),
        edge(<g>, <h>),
        edge(<h>, <a>),
        edge(<a>, <c>, bend: -20deg),
        edge(<b>, <d>, bend: -20deg),
        edge(<c>, <e>),
        edge(<d>, <f>, bend: -20deg),
        edge(<e>, <g>, bend: -20deg),
        edge(<f>, <h>, bend: -20deg),
      )
    ]
  ],
  [
    *(d)* #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (13mm, 13mm),
        dot((0, 1), $a$, tint: blue, <a>),
        dot((1, 0), $b$, tint: blue, <b>),
        dot((1, 2), $c$, tint: blue, <c>),
        dot((2, 0.5), $d$, tint: blue, <d>),
        dot((2, 1.5), $e$, tint: blue, <e>),
        dot((3, 1), $f$, tint: blue, <f>),
        dot((1, 1), $g$, tint: blue, <g>),
        dot((2, 1), $h$, tint: blue, <h>),
        edge(<a>, <b>, bend: 30deg),
        edge(<a>, <c>, bend: -30deg),
        edge(<a>, <g>),
        edge(<b>, <d>),
        edge(<b>, <g>),
        edge(<c>, <e>),
        edge(<c>, <g>),
        edge(<d>, <f>),
        edge(<d>, <h>),
        edge(<e>, <f>),
        edge(<e>, <h>),
        edge(<g>, <h>),
        edge(<h>, <f>),
      )
    ]
  ],
)


== Problem 2: Degree Sequence Puzzles

#tasklist("prob2")[

  + Which of the following sequences are _graphical_ (i.e. realizable as the degree sequence of a simple graph)? For each graphical sequence, construct a graph realizing it. For each non-graphical sequence, explain why.
    - $(5, 4, 3, 2, 2, 2)$
    - $(3, 3, 3, 3, 3, 3)$
    - $(4, 4, 3, 2, 1)$
    - $(6, 3, 3, 3, 3, 2, 2)$
    - $(1, 1, 1, 1, 1, 1)$

  + Prove or disprove: if $G$ is a graph on $n$ vertices with degree sequence $d_1 >= d_2 >= dots >= d_n$ and $d_i >= i$ for some $i < n$, then $omega(G) >= i + 1$, where $omega(G)$ is the clique number.

  + For each pair $(r,n)$ below, either construct an $r$-regular graph on $n$ vertices, or prove that no such graph exists. If a graph exists, determine whether it is unique (up to isomorphism) or if multiple non-isomorphic examples exist.
    - $(r,n) = (3,6)$
    - $(r,n) = (3,7)$
    - $(r,n) = (4,7)$
    - $(r,n) = (5,8)$
]


== Problem 3: Isomorphism Detective

Determine which graphs below are isomorphic. For isomorphic pairs, exhibit the bijection explicitly. For non-isomorphic pairs, identify a distinguishing invariant.

*Part A (Small graphs):* The following four graphs all have 7 vertices and 9 edges.

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 2em,
  [
    *Graph $H_1$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        dot((-90deg + 360deg / 7 * 0, 1.3), $1$, tint: blue, <1>),
        dot((-90deg + 360deg / 7 * 1, 1.3), $2$, tint: blue, <2>),
        dot((-90deg + 360deg / 7 * 2, 1.3), $3$, tint: blue, <3>),
        dot((-90deg + 360deg / 7 * 3, 1.3), $4$, tint: blue, <4>),
        dot((-90deg + 360deg / 7 * 4, 1.3), $5$, tint: blue, <5>),
        dot((-90deg + 360deg / 7 * 5, 1.3), $6$, tint: blue, <6>),
        dot((-90deg + 360deg / 7 * 6, 1.3), $7$, tint: blue, <7>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <5>),
        edge(<5>, <6>),
        edge(<6>, <7>),
        edge(<7>, <1>),
        edge(<1>, <3>),
        edge(<2>, <5>),
      )
    ]
  ],
  [
    *Graph $H_2$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        dot((0, 0), $a$, tint: green, <a>),
        dot((1, 0), $b$, tint: green, <b>),
        dot((2, 0), $c$, tint: green, <c>),
        dot((3, 0), $d$, tint: green, <d>),
        dot((0.5, 1), $e$, tint: green, <e>),
        dot((1.5, 1), $f$, tint: green, <f>),
        dot((2.5, 1), $g$, tint: green, <g>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<a>, <e>),
        edge(<b>, <e>),
        edge(<b>, <f>),
        edge(<c>, <f>),
        edge(<c>, <g>),
        edge(<d>, <g>),
      )
    ]
  ],

  [
    *Graph $H_3$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        dot((1, 1), $p$, tint: orange, <p>),
        dot((0, 0.5), $q$, tint: orange, <q>),
        dot((0.5, -0.3), $r$, tint: orange, <r>),
        dot((1.5, -0.3), $s$, tint: orange, <s>),
        dot((2, 0.5), $t$, tint: orange, <t>),
        dot((2, 1.5), $u$, tint: orange, <u>),
        dot((0, 1.5), $v$, tint: orange, <v>),
        edge(<p>, <q>),
        edge(<p>, <v>),
        edge(<p>, <t>),
        edge(<p>, <u>),
        edge(<q>, <r>),
        edge(<r>, <s>),
        edge(<s>, <t>),
        edge(<t>, <u>),
        edge(<q>, <v>),
      )
    ]
  ],
  [
    *Graph $H_4$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        dot((0, 1), $w$, tint: purple, <w>),
        dot((1, 0), $x$, tint: purple, <x>),
        dot((1, 2), $y$, tint: purple, <y>),
        dot((2, 0.5), $z$, tint: purple, <z>),
        dot((2, 1.5), $alpha$, tint: purple, <alpha>),
        dot((3, 1), $beta$, tint: purple, <beta>),
        dot((1.5, 1), $delta$, tint: purple, <delta>),
        edge(<w>, <x>),
        edge(<w>, <y>),
        edge(<w>, <delta>),
        edge(<x>, <z>),
        edge(<y>, <alpha>),
        edge(<z>, <beta>),
        edge(<alpha>, <beta>),
        edge(<z>, <delta>),
        edge(<alpha>, <delta>),
      )
    ]
  ],
)

*Part B (Large graphs):* The following four graphs all have 10 vertices and 15 edges.

#grid(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 2em,
  [
    *Graph $L_1$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (10mm, 10mm),
        dot((0, 0), $1$, tint: blue, <1>),
        dot((1, 0), $2$, tint: blue, <2>),
        dot((2, 0), $3$, tint: blue, <3>),
        dot((3, 0), $4$, tint: blue, <4>),
        dot((4, 0), $5$, tint: blue, <5>),
        dot((0, 1), $6$, tint: blue, <6>),
        dot((1, 1), $7$, tint: blue, <7>),
        dot((2, 1), $8$, tint: blue, <8>),
        dot((3, 1), $9$, tint: blue, <9>),
        dot((4, 1), $10$, tint: blue, <10>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <5>),
        edge(<6>, <7>),
        edge(<7>, <8>),
        edge(<8>, <9>),
        edge(<9>, <10>),
        edge(<1>, <6>),
        edge(<2>, <7>),
        edge(<3>, <8>),
        edge(<4>, <9>),
        edge(<5>, <10>),
        edge(<2>, <8>),
        edge(<3>, <9>),
      )
    ]
  ],
  [
    *Graph $L_2$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (12mm, 12mm),
        dot((-90deg + 360deg / 10 * 0, 1.5), $a$, tint: green, <a>),
        dot((-90deg + 360deg / 10 * 1, 1.5), $b$, tint: green, <b>),
        dot((-90deg + 360deg / 10 * 2, 1.5), $c$, tint: green, <c>),
        dot((-90deg + 360deg / 10 * 3, 1.5), $d$, tint: green, <d>),
        dot((-90deg + 360deg / 10 * 4, 1.5), $e$, tint: green, <e>),
        dot((-90deg + 360deg / 10 * 5, 1.5), $f$, tint: green, <f>),
        dot((-90deg + 360deg / 10 * 6, 1.5), $g$, tint: green, <g>),
        dot((-90deg + 360deg / 10 * 7, 1.5), $h$, tint: green, <h>),
        dot((-90deg + 360deg / 10 * 8, 1.5), $i$, tint: green, <i>),
        dot((-90deg + 360deg / 10 * 9, 1.5), $j$, tint: green, <j>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <g>),
        edge(<g>, <h>),
        edge(<h>, <i>),
        edge(<i>, <j>),
        edge(<j>, <a>),
        edge(<a>, <c>, bend: -30deg),
        edge(<b>, <d>, bend: -30deg),
        edge(<c>, <e>, bend: -30deg),
        edge(<f>, <h>, bend: -30deg),
        edge(<g>, <i>, bend: -30deg),
      )
    ]
  ],

  [
    *Graph $L_3$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (11mm, 12mm),
        dot((0, 1), $p$, tint: orange, <p>),
        dot((1, 0), $q$, tint: orange, <q>),
        dot((1, 2), $r$, tint: orange, <r>),
        dot((2, 0.5), $s$, tint: orange, <s>),
        dot((2, 1.5), $t$, tint: orange, <t>),
        dot((3, 0), $u$, tint: orange, <u>),
        dot((3, 1), $v$, tint: orange, <v>),
        dot((3, 2), $w$, tint: orange, <w>),
        dot((4, 0.5), $x$, tint: orange, <x>),
        dot((4, 1.5), $y$, tint: orange, <y>),
        edge(<p>, <q>, bend: 30deg),
        edge(<p>, <r>, bend: -30deg),
        edge(<q>, <s>),
        edge(<r>, <t>),
        edge(<s>, <t>),
        edge(<s>, <u>, bend: 15deg),
        edge(<s>, <v>),
        edge(<t>, <v>),
        edge(<t>, <w>, bend: -15deg),
        edge(<u>, <x>, bend: 15deg),
        edge(<v>, <x>),
        edge(<v>, <y>),
        edge(<w>, <y>, bend: -15deg),
        edge(<x>, <y>),
        edge(<q>, <r>),
      )
    ]
  ],
  [
    *Graph $L_4$:*
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (11mm, 11mm),
        dot((1, 2.5), $alpha$, tint: purple, <alpha>),
        dot((0, 2), $beta$, tint: purple, <beta>),
        dot((2, 2), $gamma$, tint: purple, <gamma>),
        dot((0, 1), $delta$, tint: purple, <delta>),
        dot((1, 1), $epsilon$, tint: purple, <epsilon>),
        dot((2, 1), $zeta$, tint: purple, <zeta>),
        dot((3, 1), $eta$, tint: purple, <eta>),
        dot((0, 0), $theta$, tint: purple, <theta>),
        dot((1.5, 0), $iota$, tint: purple, <iota>),
        dot((3, 0), $kappa$, tint: purple, <kappa>),
        edge(<alpha>, <beta>, bend: 15deg),
        edge(<alpha>, <gamma>, bend: -15deg),
        edge(<beta>, <delta>),
        edge(<beta>, <epsilon>),
        edge(<gamma>, <epsilon>, bend: 15deg),
        edge(<gamma>, <zeta>, bend: -15deg),
        edge(<delta>, <theta>),
        edge(<delta>, <epsilon>),
        edge(<epsilon>, <iota>, bend: 15deg),
        edge(<zeta>, <eta>),
        edge(<zeta>, <iota>, bend: 15deg),
        edge(<eta>, <kappa>),
        edge(<theta>, <iota>),
        edge(<iota>, <kappa>),
        edge(<eta>, <iota>),
      )
    ]
  ],
)


// ============================================================================
// SECTION II: PATHS, CONNECTIVITY, AND SHORTEST PATHS
// ============================================================================

= Section II: Distances and Connectivity

== Problem 4: Shortest Path in a Weighted Graph <task-weighted-graph>

Find a shortest path between $a$ and $z$ in the weighted graph below using *Dijkstra's algorithm*.

Show your work clearly:
- List vertices in the order they are processed (added to the "visited" set)
- Show the distance labels and predecessor pointers at each step
- Reconstruct the shortest path and give its total length

#align(center)[
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (15mm, 12mm),
    dot((0, 1), $a$, tint: green, <a>),
    dot((1, 0), $b$, tint: blue, <b>),
    dot((1, 1), $c$, tint: blue, <c>),
    dot((1, 2), $d$, tint: blue, <d>),
    dot((2, 0), $e$, tint: blue, <e>),
    dot((2, 1), $f$, tint: blue, <f>),
    dot((2, 2), $g$, tint: blue, <g>),
    dot((3, 0), $h$, tint: blue, <h>),
    dot((3, 1), $i$, tint: blue, <i>),
    dot((3, 2), $j$, tint: blue, <j>),
    dot((4, 0.5), $k$, tint: blue, <k>),
    dot((4, 1.5), $l$, tint: blue, <l>),
    dot((5, 1), $z$, tint: red, <z>),
    edge(<a>, <b>, [2], label-angle: auto, label-side: center),
    edge(<a>, <c>, [5], label-angle: auto, label-side: center),
    edge(<a>, <d>, [1], label-angle: auto, label-side: center),
    edge(<b>, <c>, [2], label-angle: auto, label-side: center),
    edge(<b>, <e>, [7], label-angle: auto, label-side: center),
    edge(<c>, <f>, [1], label-angle: auto, label-side: center),
    edge(<c>, <e>, [4], label-angle: auto, label-side: center),
    edge(<d>, <g>, [3], label-angle: auto, label-side: center),
    edge(<d>, <f>, [6], label-angle: auto, label-side: center),
    edge(<e>, <h>, [1], label-angle: auto, label-side: center),
    edge(<e>, <f>, [3], label-angle: auto, label-side: center),
    edge(<f>, <g>, [2], label-angle: auto, label-side: center),
    edge(<f>, <i>, [5], label-angle: auto, label-side: center),
    edge(<g>, <j>, [4], label-angle: auto, label-side: center),
    edge(<h>, <i>, [3], label-angle: auto, label-side: center),
    edge(<h>, <k>, [6], label-angle: auto, label-side: center),
    edge(<i>, <j>, [2], label-angle: auto, label-side: center),
    edge(<i>, <k>, [4], label-angle: auto, label-side: center),
    edge(<i>, <l>, [3], label-angle: auto, label-side: center),
    edge(<j>, <l>, [1], label-angle: auto, label-side: center),
    edge(<k>, <z>, [3], label-angle: auto, label-side: center),
    edge(<l>, <z>, [2], label-angle: auto, label-side: center),
  )
]


== Problem 5: Connectivity and Separators

An internet service provider models their network as a graph where vertices are routers and edges are physical links.

#align(center)[
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (15mm, 14mm),
    dot((0, 1), $R_1$, tint: blue, <r1>),
    dot((1, 0), $R_2$, tint: blue, <r2>),
    dot((1, 2), $R_3$, tint: blue, <r3>),
    dot((2, 0.5), $R_4$, tint: blue, <r4>),
    dot((2, 1.5), $R_5$, tint: blue, <r5>),
    dot((3, 1), $R_6$, tint: blue, <r6>),
    dot((4, 0), $R_7$, tint: blue, <r7>),
    dot((4, 2), $R_8$, tint: blue, <r8>),
    dot((5, 0.5), $R_9$, tint: blue, <r9>),
    dot((5, 1.5), $R_10$, tint: blue, <r10>),
    dot((6, 1), $R_11$, tint: blue, <r11>),
    edge(<r1>, <r2>),
    edge(<r1>, <r3>),
    edge(<r2>, <r4>),
    edge(<r3>, <r5>),
    edge(<r2>, <r3>),
    edge(<r4>, <r5>),
    edge(<r4>, <r6>),
    edge(<r5>, <r6>),
    edge(<r6>, <r7>),
    edge(<r6>, <r8>),
    edge(<r7>, <r9>),
    edge(<r8>, <r10>),
    edge(<r7>, <r8>),
    edge(<r9>, <r10>),
    edge(<r9>, <r11>),
    edge(<r10>, <r11>),
  )
]

#tasklist("prob5")[
  + Find all cut vertices and all bridges in this network.

  + Identify all blocks (biconnected components) and all 2-edge-connected components. Are they the same?

  + Draw the block-cut tree and the bridge tree for this graph.

  + Compute $kappa(G)$ and $lam(G)$. Verify Whitney's inequality: $kappa(G) <= lam(G) <= delta(G)$.

  + The provider wants the network to remain connected even if any single router fails. Determine the _minimum_ number of edges to add to achieve this. Give an explicit construction.

  + For 2-edge-connectivity (resilience against link failures), what is the minimum number of edges needed? Construct a solution.
]


== Problem 6: The Water Jug Problem

You have a *3-liter* jar and a *5-liter* jar.
You can fill any jar from a tap, empty any jar, or pour water from one jar to the other (stopping when the source is empty or the target is full).

#tasklist("prob6")[
  + Model the problem as a directed graph, where each vertex is a state $(a,b)$ with $0 <= a <= 3$ and $0 <= b <= 5$. What are the edges?
  + Find a shortest path from $(0, 0)$ to a state where one jar contains exactly 1 liter.
  + How many vertices and edges does the full state graph have?
  + Is the state graph strongly connected? If not, identify the strongly connected components.
]


// ============================================================================
// SECTION III: TREES
// ============================================================================

= Section III: Trees and Spanning Trees

== Problem 7: Tree Characterizations

Prove the following equivalences for a connected graph $G = pair(V, E)$ with $n = |V|$ and $m = |E|$:

#Block[
  The following are equivalent:
  + $G$ is a tree (i.e. connected and acyclic).
  + $G$ is connected and $m = n - 1$.
  + $G$ is acyclic and $m = n - 1$.
  + For every pair of vertices $u, v in V$, there exists a _unique_ path from $u$ to $v$.
  + $G$ is connected, but removing any edge disconnects it (i.e. every edge is a bridge).
  + $G$ is acyclic, but adding any new edge creates exactly one cycle.
]


== Problem 8: Prüfer Sequences

#tasklist("prob8")[
  + Encode the following labeled tree into its Prüfer sequence:
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (14mm, 14mm),
        dot((1, 2), $1$, tint: blue, <1>),
        dot((2, 2), $2$, tint: blue, <2>),
        dot((3, 2), $3$, tint: blue, <3>),
        dot((1, 1), $4$, tint: blue, <4>),
        dot((2, 1), $5$, tint: blue, <5>),
        dot((3, 1), $6$, tint: blue, <6>),
        dot((4, 1), $7$, tint: blue, <7>),
        dot((0, 0), $8$, tint: blue, <8>),
        dot((1.5, 0), $9$, tint: blue, <9>),
        dot((2.5, 0), $10$, tint: blue, <10>),
        dot((3.5, 0), $11$, tint: blue, <11>),
        dot((4.5, 0), $12$, tint: blue, <12>),
        edge(<5>, <1>),
        edge(<5>, <2>),
        edge(<5>, <3>),
        edge(<5>, <4>),
        edge(<5>, <6>),
        edge(<5>, <7>),
        edge(<4>, <8>),
        edge(<4>, <9>),
        edge(<6>, <10>),
        edge(<7>, <11>),
        edge(<7>, <12>),
      )
    ]

  + Decode the Prüfer sequence $(3, 3, 3, 7, 7, 5)$ into a labeled tree on 8 vertices. Draw the result.

  + Using Cayley's formula ($n^(n-2)$ labeled trees on $n$ vertices), how many labeled trees exist on 7 vertices? How many of these have vertex 1 as a leaf?

  + Prove: in the Prüfer sequence of a labeled tree on $n$ vertices, vertex $v$ appears exactly $deg(v) - 1$ times.
]


== Problem 9: Non-Isomorphic Trees

#tasklist("prob9")[
  + Draw all pairwise non-isomorphic unlabeled unrooted trees on 7 vertices.

  + Among the trees from the previous part, identify which ones are _caterpillars_.

  + Which of the trees from part (a) are _graceful_? Show the labeling for at least three of them.
]


== Problem 10: Minimum Spanning Trees

Consider the weighted graph from @task-weighted-graph.

#tasklist("prob10")[
  + Use *Kruskal's algorithm* to find a minimum spanning tree. Show the edges in the order they are added.

  + Use *Prim's algorithm* starting from vertex $a$. Show the tree growing step by step.

  + Are the MSTs from (a) and (b) the same? If so, prove the MST is unique for this graph. If not, explain why multiple MSTs exist.

  + Prove: if all edge weights in a connected weighted graph are _distinct_, then the MST is unique.
]


// ============================================================================
// SECTION IV: EULERIAN AND HAMILTONIAN GRAPHS
// ============================================================================

= Section IV: Eulerian and Hamiltonian Graphs

== Problem 11: Eulerian Adventures

#tasklist("prob11")[
  + For which values of $n >= 3$ does the complete graph $K_n$ have an Euler circuit? An Euler path? Prove your answer.

  + For which values of $m, n >= 1$ does the complete bipartite graph $K_(m,n)$ have an Euler circuit? An Euler path?

  + A museum has 9 rooms arranged in a $3 times 3$ grid. Adjacent rooms (sharing a wall) are connected by doorways. A tour guide wants to start in the top-left room, visit every doorway exactly once, and return to the starting room. Is this possible?

    Model the problem as a graph and determine the answer.
]


== Problem 12: Hamiltonian Challenges

#tasklist("prob12")[
  + Determine whether the _Petersen graph_ has a Hamiltonian cycle. For reference, the Petersen graph is a 3-regular graph on 10 vertices.

    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        // Outer pentagon
        dot((-90deg + 360deg / 5 * 0, 1.3), $1$, tint: blue, <1>),
        dot((-90deg + 360deg / 5 * 1, 1.3), $2$, tint: blue, <2>),
        dot((-90deg + 360deg / 5 * 2, 1.3), $3$, tint: blue, <3>),
        dot((-90deg + 360deg / 5 * 3, 1.3), $4$, tint: blue, <4>),
        dot((-90deg + 360deg / 5 * 4, 1.3), $5$, tint: blue, <5>),
        // Inner pentagram
        dot((-90deg + 360deg / 5 * 0, 0.55), $6$, tint: red, <6>),
        dot((-90deg + 360deg / 5 * 1, 0.55), $7$, tint: red, <7>),
        dot((-90deg + 360deg / 5 * 2, 0.55), $8$, tint: red, <8>),
        dot((-90deg + 360deg / 5 * 3, 0.55), $9$, tint: red, <9>),
        dot((-90deg + 360deg / 5 * 4, 0.55), $10$, tint: red, <10>),
        // Outer edges
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <5>),
        edge(<5>, <1>),
        // Spokes
        edge(<1>, <6>),
        edge(<2>, <7>),
        edge(<3>, <8>),
        edge(<4>, <9>),
        edge(<5>, <10>),
        // Inner edges (pentagram)
        edge(<6>, <8>),
        edge(<8>, <10>),
        edge(<10>, <7>),
        edge(<7>, <9>),
        edge(<9>, <6>),
      )
    ]

  + Does the graph $K_(2,3)$ have a Hamiltonian path? A Hamiltonian cycle? Justify each answer.

  + Prove that the $n$-dimensional hypercube graph $Q_n$ has a Hamiltonian cycle for all $n >= 2$.
]


// ============================================================================
// SECTION V: BIPARTITE GRAPHS AND MATCHINGS
// ============================================================================

= Section V: Matching Theory

== Problem 13: Bipartiteness Detection

#tasklist("prob13")[
  + Prove that a graph $G$ is bipartite if and only if it contains no odd cycle.

  + Describe an algorithm based on BFS that determines whether a given graph is bipartite, and if so, produces a bipartition. What is its time complexity?

  + Determine which of the following graphs are bipartite. For bipartite graphs, give the bipartition. For non-bipartite graphs, exhibit an odd cycle.
    - $C_6$ (cycle on 6 vertices)
    - $Q_3$ (3-dimensional hypercube)
    - The Petersen graph
    - $W_5$ (wheel on 6 vertices: $C_5$ + central vertex)
]


== Problem 14: Hall's Marriage Theorem --- Applications

A dance school has 6 leaders and 6 followers. Each leader is willing to dance with certain followers, as described by the bipartite graph below.
Leaders are ${L_1, dots, L_6}$, followers are ${F_1, dots, F_6}$.

#align(center)[
  #table(
    columns: 7,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([], [*$F_1$*], [*$F_2$*], [*$F_3$*], [*$F_4$*], [*$F_5$*], [*$F_6$*]),
    [*$L_1$*], [$times$], [$times$], [], [], [], [$times$],
    [*$L_2$*], [$times$], [], [$times$], [], [], [],
    [*$L_3$*], [], [$times$], [], [$times$], [], [],
    [*$L_4$*], [], [], [$times$], [], [$times$], [],
    [*$L_5$*], [], [], [], [$times$], [$times$], [],
    [*$L_6$*], [$times$], [], [], [], [], [$times$],
  )
]

#tasklist("prob14")[
  + Does a perfect matching exist? Verify Hall's condition: check $|N(S)| >= |S|$ for all $S subset.eq {L_1, dots, L_6}$.

  + Find a maximum matching. Is it perfect?

  + Now suppose $L_2$ becomes more selective: they will _only_ dance with $F_1$. Does a perfect matching still exist? If Hall's condition fails, identify the violating subset $S$.
]


== Problem 15: König's Theorem in Action

Consider the bipartite graph $G = (X, Y, E)$ where $X = {1, 2, 3, 4}$, $Y = {a, b, c, d}$, and the edges are:
$ E = {(1,a), (1,b), (2,b), (2,c), (3,c), (3,d), (4,a), (4,d)} $

#tasklist("prob15")[
  + Find a maximum matching $M$.
  + Find a minimum vertex cover $R$.
  + Verify that $|M| = |R|$ (König's theorem).
  + Find a maximum stable set $S$ and a minimum edge cover $F$. Verify the Gallai identities:
    - $alpha(G) + tau(G) = |V|$ (stability number + vertex cover number = number of vertices)
    - $alpha'(G) + tau'(G) = |V|$ (matching number + edge cover number = number of vertices, assuming no isolated vertices)
]


// ============================================================================
// SECTION VI: PLANARITY
// ============================================================================

= Section VI: Planarity

== Problem 16: Planar or Not?

For each of the following graphs, determine whether it is planar.
If planar, draw a planar embedding and count the faces, verifying Euler's formula $n - m + f = 2$.
If not planar, prove it.

#tasklist("prob16", cols: 2)[
  + $K_4$ (complete graph on 4 vertices)
  + $K_5$ (complete graph on 5 vertices)
  #colbreak()
  + $Q_3$ (3-dimensional hypercube)
  + The Petersen graph
]


== Problem 17: Euler's Formula Applications

#tasklist("prob17")[
  + Using Euler's formula, prove that every simple planar graph $G$ with $n >= 3$ vertices and $m$ edges satisfies $m <= 3n - 6$.

  + Prove the stronger bound: if $G$ is a simple _bipartite_ planar graph with $n >= 3$, then $m <= 2n - 4$.

  + Use the result of (b) to give a short proof that $K_(3,3)$ is not planar.

  + Prove that every simple planar graph has a vertex of degree at most 5.
]


== Problem 18: Drawing on the Torus

Draw $K_5$ and $K_(3,3)$ on the surface of a torus (a "donut") without edge crossings. Present each drawing with a clear description or a rectangular representation with identified opposite sides.


// ============================================================================
// SECTION VII: COLORING
// ============================================================================

= Section VII: Graph Coloring

== Problem 19: Chromatic Numbers

#tasklist("prob19")[
  + Determine $chi(G)$ for each graph in Problem 1. For each, prove that $chi(G) - 1$ colors are insufficient by exhibiting an appropriate subgraph.

  + Find the chromatic number of:
    - $C_n$ (cycle on $n >= 3$ vertices) --- express in terms of parity of $n$. Prove your answer.
    - $K_(m,n)$ (complete bipartite graph)
    - $W_n$ (wheel graph: $C_(n-1)$ + one universal vertex)
    - $Q_3$ (3-dimensional hypercube)
    - The Petersen graph

  + Prove that if $G$ is a graph with maximum degree $Delta$, then $chi(G) <= Delta + 1$.

  + Show that the bound in part (c) is tight: construct an infinite family of graphs ${G_n}$ where $chi(G_n) = Delta(G_n) + 1$ for all $n$.

  + Give an example of a graph $G$ where $chi(G) = omega(G) + 2$.

  + *Brooks' Theorem* states: If $G$ is a connected graph that is neither a complete graph nor an odd cycle, then $chi(G) <= Delta(G)$. Verify this theorem for the graphs in Problem 1.
]


== Problem 20: Edge Coloring and Scheduling

A round-robin tournament among 6 teams must be scheduled so that in each round, teams are paired and every pair plays exactly once.

#tasklist("prob20")[
  + Model this as an edge coloring problem on $K_6$. What does each color represent?

  + Find $chi'(K_6)$. How many rounds are needed?

  + Construct an explicit schedule: assign each of the $binom(6, 2) = 15$ games to a round.

  + What if there are 7 teams? How does $chi'(K_7)$ compare to $chi'(K_6)$? Explain using Vizing's theorem.
]


// ============================================================================
// SECTION VIII: ALGORITHMS AND PROGRAMMING
// ============================================================================

= Section VIII: Algorithms and Programming

== Problem 21: Floyd--Warshall All-Pairs Shortest Paths

Floyd's algorithm computes shortest distances between _all_ pairs of vertices in a weighted graph.

#Block[
  *Input:* Weighted simple graph $G = pair(V, E)$ with $V = {v_1, dots, v_n}$ and weight function $w$, where $w(v_i, v_j) = infinity$ if ${v_i, v_j} notin E$.

  *Algorithm:*
  + Initialize $d(v_i, v_j) := w(v_i, v_j)$ for all $i, j$.
  + For $k = 1$ to $n$:
    - For all pairs $(i, j)$:
      - If $d(v_i, v_k) + d(v_k, v_j) < d(v_i, v_j)$, set $d(v_i, v_j) := d(v_i, v_k) + d(v_k, v_j)$.
]

#tasklist("prob21")[
  + Implement Floyd's algorithm in your favorite programming language. Use it to compute the all-pairs shortest distance matrix for the graph in @task-weighted-graph.

  + Prove that after the algorithm terminates, $d(v_i, v_j)$ equals the length of a shortest path from $v_i$ to $v_j$.

  + What is the time complexity of Floyd's algorithm? Compare it with running Dijkstra from each vertex.

  + Modify the algorithm to reconstruct the actual shortest path (not just the distance) between any two given vertices.

  + What happens if the graph has a _negative cycle_? Explain how to detect this from the distance matrix.
]


== Problem 22: Precedence Graph

A *precedence graph* is a directed graph where vertices represent program instructions and directed edges represent data dependencies: there is an edge from statement $S_i$ to statement $S_j$ if $S_j$ reads a variable that $S_i$ writes (and there is no intervening write).

#tasklist("prob22")[
  + Construct a precedence graph for the following program:
    #Block[
      $S_1: x := 0$\
      $S_2: y := 1$\
      $S_3: z := x + 1$\
      $S_4: w := y + z$\
      $S_5: x := z + w$\
      $S_6: y := x + 2$\
      $S_7: z := w$
    ]

  + What is the longest path in the precedence graph? What does its length represent in terms of program execution?

  + Which instructions can be executed in parallel (i.e. are not ordered by the precedence relation)?

  + Give a valid parallel execution schedule that minimizes the number of time steps, assuming unlimited processors.
]


// ============================================================================
// SECTION IX: APPLICATIONS AND MODELING
// ============================================================================

= Section IX: Applications and Modeling

== Problem 23: Social Network Analysis

A social network of 8 users is modeled as a graph where edges represent mutual friendships:

#align(center)[
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (14mm, 14mm),
    dot((0, 0), [A], tint: blue, <A>),
    dot((1, 0), [B], tint: blue, <B>),
    dot((2, 0), [C], tint: blue, <C>),
    dot((0, 1), [D], tint: blue, <D>),
    dot((1, 1), [E], tint: blue, <E>),
    dot((2, 1), [F], tint: blue, <F>),
    dot((0.5, 2), [G], tint: blue, <G>),
    dot((1.5, 2), [H], tint: blue, <H>),
    edge(<A>, <B>),
    edge(<B>, <C>),
    edge(<A>, <D>),
    edge(<B>, <E>),
    edge(<C>, <F>),
    edge(<D>, <E>),
    edge(<E>, <F>),
    edge(<D>, <G>),
    edge(<E>, <G>),
    edge(<E>, <H>),
    edge(<F>, <H>),
    edge(<G>, <H>),
  )
]

#tasklist("prob23")[
  + Find the _eccentricity_ of each user. Who is in the center of the network? What is the network's diameter?

  + Find the _maximum clique_. What does it represent socially?

  + Find the _minimum dominating set_. Interpret: if you want to spread a message so that every user either hears it directly or has a friend who hears it, what is the minimum number of users to notify?

  + The network administrator wants to ensure connectivity even if one user deactivates their account. Find $kappa(G)$. Is the network currently 2-connected?
]


== Problem 24: Map Coloring

Consider a map with 7 regions (countries).
Two regions are _adjacent_ if they share a boundary segment (not just a point).

#Block[
  Regions $A$, $B$, $C$, $D$, $E$, $F$, $G$ with adjacencies:
  - $A$ is adjacent to $B$, $C$, $D$
  - $B$ is adjacent to $A$, $C$, $E$
  - $C$ is adjacent to $A$, $B$, $D$, $E$, $F$
  - $D$ is adjacent to $A$, $C$, $F$, $G$
  - $E$ is adjacent to $B$, $C$, $F$
  - $F$ is adjacent to $C$, $D$, $E$, $G$
  - $G$ is adjacent to $D$, $F$
]

#tasklist("prob24")[
  + Draw the dual graph (vertices = regions, edges = adjacencies). Is this graph planar?

  + Verify Euler's formula: count vertices, edges, and faces (when drawn on the plane).

  + Verify the graph is planar by checking $m <= 3n - 6$.

  + Find $chi(G)$ --- the minimum number of colors needed so that adjacent regions get different colors. Provide an explicit coloring.

  + Can you always color any planar map with at most 4 colors? State the relevant theorem and explain its significance.
]


// ============================================================================
// SECTION X: PROOFS AND THEORY
// ============================================================================

= Section X: Proofs

== Problem 25: Find the Error

Find an error in the following "proof" that every tree with $n$ vertices has a path of length $n - 1$.

#Block[
  *"Proof."*
  _Base case:_ A tree with one vertex clearly has a path of length 0. $checkmark$

  _Inductive step:_ Assume that a tree with $n$ vertices has a path of length $n - 1$, which has $u$ as its terminal vertex.
  Add a vertex $v$ and the edge from $u$ to $v$.
  The resulting tree has $n + 1$ vertices and has a path of length $n$. $qed$
]


== Problem 26: Prove Rigorously

Prove the following theorems:

#tasklist("prob26")[
  + *Triangle Inequality.* For any connected graph $G = pair(V, E)$:
    $ forall x, y, z in V: quad dist(x, y) + dist(y, z) >= dist(x, z) $

  + *Radius--Diameter bounds.* For any connected graph $G$: $ rad(G) <= diam(G) <= 2 dot rad(G) $

  + *Whitney's Inequality.* For any graph $G$: $ kappa(G) <= lam(G) <= delta(G) $

  + *Euler's criterion.* A connected graph $G$ has an Euler circuit if and only if every vertex has even degree.

  + *Statement.* Every $r$-regular bipartite graph ($r >= 1$) has a perfect matching.
]


== Problem 27: Ramsey Warm-Up

#tasklist("prob27")[
  + Prove that $R(3, 3) = 6$, i.e. among any 6 people, there exist either 3 mutual friends or 3 mutual strangers.

  + Show that $R(3, 4) <= 10$.

  + Prove that for all $r, s >= 2$: $R(r, s) <= R(r-1, s) + R(r, s-1)$.
]


// ============================================================================
// SECTION XI: GRAPH DENSITY AND FAMILIES
// ============================================================================

= Section XI: Graph Families and Density

== Problem 28: Sparse, Dense, or Neither?

The *density* of a graph $G = pair(V, E)$ is $rho(G) = frac(2|E|, |V| dot (|V| - 1))$.
A family of graphs $G_n$ ($n = 1, 2, dots$) is *sparse* if $lim_(n -> oo) rho(G_n) = 0$, and *dense* if the limit is a positive constant.

For each family below, compute $rho(G_n)$ and classify it as sparse, dense, or neither:

#tasklist("prob28", cols: 2)[
  + $K_n$ (complete graph)
  + $C_n$ (cycle graph)
  + $K_(n,n)$ (complete bipartite)
  #colbreak()
  + $Q_n$ (hypercube graph: $2^n$ vertices)
  + $W_n$ (wheel graph: $C_(n-1)$ + center)
  + $P_n$ (path graph)
]


== Problem 29: Hypercube Graphs

The $n$-dimensional *hypercube graph* $Q_n$ has $2^n$ vertices, each labeled by a binary string of length $n$. Two vertices are adjacent iff their labels differ in exactly one bit.

#tasklist("prob29")[
  + Draw $Q_1$, $Q_2$, $Q_3$. Verify that $Q_n$ is $n$-regular with $n dot 2^(n-1)$ edges.

  + Prove that $Q_n$ is bipartite for all $n >= 1$.

  + Prove that $Q_n$ is $n$-vertex-connected.

  + What is the diameter of $Q_n$? Prove your answer.

  + How many Hamiltonian cycles does $Q_3$ have? (You may find this by exhaustive enumeration or by using symmetry arguments.)
]

// ============================================================================
// SECTION XII: CHALLENGE PROBLEMS
// ============================================================================

= Section XII: Challenge Problems

== Problem 30: The Friendship Theorem (Challenge)

The *Friendship Theorem* (Erdős, Rényi, Sós, 1966) states: if $G$ is a simple graph in which every pair of _distinct_ vertices has _exactly one_ common neighbor, then $G$ is a _windmill graph_ $"Wd"(n)$ (i.e., $n$ triangles all sharing a single common vertex).

#tasklist("prob30")[
  + Verify the theorem for small cases: For $n <= 5$, try to construct graphs satisfying the friendship condition. How many different windmill graphs can you find?

  + Let $G$ satisfy the friendship condition. Prove that $G$ must be regular (all vertices have the same degree).

  + *(Optional, very challenging)* Using part (b), prove that if $G$ is $r$-regular and satisfies the friendship condition, then either $r = 2$ (giving $C_5$), or there exists a universal vertex (adjacent to all others).
]


== Problem 31: Bridges of Saint Petersburg

Consider the map of central Saint Petersburg with its islands (Vasilyevsky Island, Petrogradskaya Storona, Hare Island, etc.) and bridges connecting them.

#tasklist("prob31")[
  + Identify at least 5 landmasses and the bridges connecting them. Model this as a multigraph.
  + Is an Euler circuit possible through all bridges? An Euler path? Justify using degree analysis.
  + If an Euler circuit is impossible, what is the _minimum_ number of bridges you would need to add (or duplicate) to make it possible? Explain your reasoning.
]


== Problem 32: Graph Theory in Practice (Mini-Project)

Write a program (in Python, Java, C++, or any language of your choice) that implements a graph data structure and computes various properties.

#Block[
  *Note:* This is a substantial programming task. Your instructor may assign this as a separate mini-project with its own deadline. Focus on code clarity, efficiency, and correctness. Include test cases and documentation.
]

#tasklist("prob32")[
  + Implement a graph data structure supporting both adjacency matrix and adjacency list representations. Include methods to:
    - Add/remove vertices and edges
    - Check adjacency
    - Get neighbors of a vertex

  + Implement algorithms to compute:
    - Degree sequence
    - Whether the graph is connected (using DFS or BFS)
    - Whether the graph is bipartite (with 2-coloring if yes)
    - Connected components (for disconnected graphs)
    - All-pairs shortest distances (BFS for unweighted graphs)
    - Eccentricity, radius, diameter, and center

  + Test your implementation on the graphs from Problem 1. Generate a report comparing your program's output with your manual calculations. Identify and explain any discrepancies.

  + *(Bonus)* Extend your program to handle weighted graphs and implement Dijkstra's algorithm for single-source shortest paths.
]

