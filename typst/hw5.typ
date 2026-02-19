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

#let pair(a, b) = $angle.l #a, #b angle.r$

// Color helpers
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)
#let Orange(x) = text(orange.darken(20%), x)

// Task list helper
#let tasklist(id, cols: 1, format: "1.", body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display(format)
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

// Graph drawing helpers
#import fletcher: diagram, edge, node, shapes
#let vertex(pos, lbl, name, ..args) = blob(
  pos,
  lbl,
  shape: shapes.circle,
  radius: 8pt,
  name: name,
  ..args,
)


== Problem 1: Graph Invariants Analysis

For each of the following graphs, compute the requested metrics and properties.

#grid(
  columns: 3,
  column-gutter: 2em,
  [
    *(a)* #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, tint: blue),
        vertex((1, 0), $b$, <b>, tint: blue),
        vertex((2, 0), $c$, <c>, tint: blue),
        vertex((0, 1), $d$, <d>, tint: blue),
        vertex((1, 1), $e$, <e>, tint: blue),
        vertex((2, 1), $f$, <f>, tint: blue),
        vertex((0, 2), $g$, <g>, tint: blue),
        vertex((1, 2), $h$, <h>, tint: blue),
        vertex((2, 2), $i$, <i>, tint: blue),
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
        vertex((1, 1.5), $a$, <a>, tint: blue),
        vertex((0, 1), $b$, <b>, tint: blue),
        vertex((2, 1), $c$, <c>, tint: blue),
        vertex((0, 0), $d$, <d>, tint: blue),
        vertex((1, 0), $e$, <e>, tint: blue),
        vertex((2, 0), $f$, <f>, tint: blue),
        vertex((3, 1), $g$, <g>, tint: blue),
        vertex((3, 0), $h$, <h>, tint: blue),
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
      #v(-1em)
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        spacing: (12mm, 12mm),
        vertex((-90deg + 360deg / 8 * 0, 1.3), $a$, tint: blue, <a>),
        vertex((-90deg + 360deg / 8 * 1, 1.3), $b$, tint: blue, <b>),
        vertex((-90deg + 360deg / 8 * 2, 1.3), $c$, tint: blue, <c>),
        vertex((-90deg + 360deg / 8 * 3, 1.3), $d$, tint: blue, <d>),
        vertex((-90deg + 360deg / 8 * 4, 1.3), $e$, tint: blue, <e>),
        vertex((-90deg + 360deg / 8 * 5, 1.3), $f$, tint: blue, <f>),
        vertex((-90deg + 360deg / 8 * 6, 1.3), $g$, tint: blue, <g>),
        vertex((-90deg + 360deg / 8 * 7, 1.3), $h$, tint: blue, <h>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <g>),
        edge(<g>, <h>),
        edge(<h>, <a>),
        edge(<a>, <c>, bend: -30deg),
        edge(<b>, <d>, bend: -30deg),
        edge(<c>, <e>, bend: -30deg),
        edge(<d>, <f>, bend: -30deg),
        edge(<e>, <g>, bend: -30deg),
        edge(<f>, <h>, bend: -30deg),
      )
    ]
  ],
)

#tasklist("prob1")[
  + *Basic connectivity metrics:*
    - Minimum degree $delta(G)$, maximum degree $Delta(G)$
    - Vertex connectivity $kappa(G)$, edge connectivity $lambda(G)$
    - All $(kappa - 1)$-connected components, $(lambda - 1)$-edge-connected components
    - Verify Whitney's inequality: $kappa(G) <= lambda(G) <= delta(G)$

  + *Distance metrics:*
    - $ecc(v)$ for every vertex $v in V(G)$
    - $rad(G)$, $diam(G)$, $Center(G)$, $girth(G)$
    - Verify the bounds: $rad(G) <= diam(G) <= 2 dot rad(G)$

  + *Structural properties:*
    - Is the graph Eulerian? Hamiltonian? Bipartite? Justify each answer.
    - Find: maximum clique $Q subset.eq V$, maximum stable set $S subset.eq V$, minimum dominating set $D subset.eq V$
    - Find: maximum matching $M subset.eq E$. Is $M$ perfect?
    - Find: minimum vertex cover $R subset.eq V$, minimum edge cover $F subset.eq E$
    - Find: minimum vertex coloring $C : V to {1, 2, dots, chi(G)}$
    - Find: minimum edge coloring $C : E to {1, 2, dots, chi'(G)}$
]


== Problem 2: Degree Sequences and Graphical Realization

A sequence $d = (d_1, d_2, dots, d_n)$ with $d_1 >= d_2 >= dots >= d_n >= 0$ is _graphical_ if there exists a simple graph $G$ with this degree sequence.

#tasklist("prob2")[
  + For each sequence below, determine whether it is graphical.
    If yes, construct a graph realizing it.
    If no, explain why (cite the Erdős--Gallai criterion or parity/sum arguments).
    #[
      #set enum(numbering: "(a)")
      + $(5, 4, 3, 2, 2, 2)$
      + $(3, 3, 3, 3, 3, 3)$
      + $(4, 4, 3, 2, 1)$
      + $(6, 3, 3, 3, 3, 2, 2)$
      + $(1, 1, 1, 1, 1, 1)$
    ]

  // + Prove the _parity lemma_: The sum of all degrees in any graph is even.

  // + Prove or disprove: If $G$ has degree sequence $d_1 >= d_2 >= dots >= d_n$ with $d_i >= i$ for some $i < n$, then $G$ contains a clique of size at least $i + 1$.

  + The total number of non-isomorphic simple undirected graphs on $n$ vertices is given by the sequence $(1, 2, 4, 11, 34, 156, ...)$ (#link("https://oeis.org/A000088")[OEIS A000088]).
    The number of distinct degree sequences of length $n$ is given by the sequence $(1, 2, 4, 11, 31, 102, ...)$ (#link("https://oeis.org/A004251")[OEIS A004251]).
    Explain why the second sequence grows more slowly than the first, and determine which degree sequences of length $n = 5$ are reliazable by more than one graph.
]


== Problem 3: Graph Isomorphism

Determine which pairs of graphs below are isomorphic.
For each isomorphic pair, exhibit an explicit bijection $f: V(G) to V(H)$ that preserves adjacency.
For each non-isomorphic pair, identify a distinguishing invariant (degree sequence, girth, number of triangles, etc.).

#grid(
  columns: 2,
  align: left,
  column-gutter: 2em,
  row-gutter: 2em,
  [
    *Graph $H_1$:* #align(center)[
      #diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-90deg + 360deg / 7 * 0, 1.3), $1$, tint: blue, <1>),
        vertex((-90deg + 360deg / 7 * 1, 1.3), $2$, tint: blue, <2>),
        vertex((-90deg + 360deg / 7 * 2, 1.3), $3$, tint: blue, <3>),
        vertex((-90deg + 360deg / 7 * 3, 1.3), $4$, tint: blue, <4>),
        vertex((-90deg + 360deg / 7 * 4, 1.3), $5$, tint: blue, <5>),
        vertex((-90deg + 360deg / 7 * 5, 1.3), $6$, tint: blue, <6>),
        vertex((-90deg + 360deg / 7 * 6, 1.3), $7$, tint: blue, <7>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <5>),
        edge(<5>, <6>),
        edge(<6>, <7>),
        edge(<7>, <1>),
        edge(<1>, <3>, bend: -30deg),
        edge(<2>, <5>),
      )
    ]

    *Graph $H_3$:* #align(center)[
      #diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, tint: green, <a>),
        vertex((1, 0), $b$, tint: green, <b>),
        vertex((2, 0), $c$, tint: green, <c>),
        vertex((3, 0), $d$, tint: green, <d>),
        vertex((0.5, 1), $e$, tint: green, <e>),
        vertex((1.5, 1), $f$, tint: green, <f>),
        vertex((2.5, 1), $g$, tint: green, <g>),
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
    *Graph $H_2$:* #align(center)[
      #diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((1, 1), $p$, tint: orange, <p>),
        vertex((0, 0.5), $q$, tint: orange, <q>),
        vertex((0.5, -0.3), $r$, tint: orange, <r>),
        vertex((1.5, -0.3), $s$, tint: orange, <s>),
        vertex((2, 0.5), $t$, tint: orange, <t>),
        vertex((2, 1.5), $u$, tint: orange, <u>),
        vertex((0, 1.5), $v$, tint: orange, <v>),
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

    *Graph $H_4$:* #align(center)[
      #diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 1), $w$, tint: purple, <w>),
        vertex((1, 0), $x$, tint: purple, <x>),
        vertex((1, 2), $y$, tint: purple, <y>),
        vertex((2, 0.5), $z$, tint: purple, <z>),
        vertex((2, 1.5), $alpha$, tint: purple, <alpha>),
        vertex((3, 1), $beta$, tint: purple, <beta>),
        vertex((1.5, 1), $gamma$, tint: purple, <gamma>),
        edge(<w>, <x>, bend: 30deg),
        edge(<w>, <y>, bend: -30deg),
        edge(<w>, <gamma>),
        edge(<x>, <z>),
        edge(<y>, <alpha>),
        edge(<z>, <beta>),
        edge(<alpha>, <beta>),
        edge(<z>, <gamma>),
        edge(<alpha>, <gamma>),
      )
    ]
  ],
)

== Problem 4: Dijkstra's Shortest Path Algorithm

Apply *Dijkstra's algorithm* to find a shortest path from $a$ to $z$ in the weighted graph below.

#align(center)[
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (15mm, 12mm),
    vertex((0, 1), $a$, tint: green, <a>),
    vertex((1, 0), $b$, tint: blue, <b>),
    vertex((1, 1), $c$, tint: blue, <c>),
    vertex((1, 2), $d$, tint: blue, <d>),
    vertex((2, 0), $e$, tint: blue, <e>),
    vertex((2, 1), $f$, tint: blue, <f>),
    vertex((2, 2), $g$, tint: blue, <g>),
    vertex((3, 0), $h$, tint: blue, <h>),
    vertex((3, 1), $i$, tint: blue, <i>),
    vertex((3, 2), $j$, tint: blue, <j>),
    vertex((4, 0.5), $k$, tint: blue, <k>),
    vertex((4, 1.5), $l$, tint: blue, <l>),
    vertex((5, 1), $z$, tint: red, <z>),
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

#tasklist("prob4")[
  + *Trace the algorithm* step-by-step:
    - Maintain a table showing, after each iteration: the visited set $V_"visited"$, the current distance labels $d(v)$ for all $v in V$, and the predecessor pointers $pi(v)$.
    - Reconstruct a shortest path from $a$ to $z$, and compute its total weight.

  + *Correctness & Structure*:
    #[
      #set enum(numbering: "(a)")
      + State the key _invariant_ that Dijkstra maintains during execution: what is guaranteed to be true about the distances $d(v)$ for visited or yet unvisited vertices?
      + In a graph where some shortest paths are not unique, the predecessor pointers form a *shortest path DAG* rooted at $a$.
        Draw this DAG (include only edges corresponding to some $pi(v)$, and mark vertex $z$).
        How many different shortest paths from $a$ to $z$ are in this DAG?
      + Dijkstra fails on graphs with negative-weight edges.
        Give a small example (3--4 vertices, one negative edge) where the algorithm produces an incorrect result, and explain _why_ the invariant from _(a)_ is violated.
    ]
]


== Problem 5: Find the Error

The following "proof" contains a subtle error.
Identify the error and explain why the conclusion is false and the claim is not valid.

#Block[
  *False Claim:* Every tree with $n$ vertices has a path of length $n - 1$.

  *"Proof:"*

  _Base case:_ A tree with one vertex clearly has a path of length $0 = 1 - 1$.

  _Inductive step:_
  Assume that every tree with $n$ vertices has a path of length $n - 1$.
  Consider a tree $T$ with $n + 1$ vertices.
  This path must terminate at some leaf $u$.
  Add a new vertex $v$ and connect it to $u$ with an edge.
  The resulting tree has $n + 1$ vertices and contains a path of length $n$, which is $(n+1) - 1$. $qed$
]


== Problem 6: Tree Characterizations

The following are six fundamental characterizations of trees. Prove that they are all equivalent for a graph $G = pair(V, E)$ with $n = |V|$ vertices and $m = |E|$ edges.

#Block[
  *Theorem.* The following are equivalent:
  + $G$ is a tree (connected and acyclic).
  + $G$ is connected and $m = n - 1$.
  + $G$ is acyclic and $m = n - 1$.
  + For every pair of vertices $u, v in V$, there exists a _unique_ path from $u$ to $v$.
  + $G$ is connected, but removing any edge disconnects it.
  + $G$ is acyclic, but adding any new edge creates exactly one cycle.
]

#tasklist("prob6")[
  + Prove the equivalence by establishing a cycle of implications:
    $ (1) => (2) => (3) => (4) => (5) => (6) => (1) $

  + Which characterization(s) generalize to forests?
    State and prove.
]


#pagebreak()

== Problem 7: Prüfer Code

The Prüfer sequence provides a bijection between labeled trees on $n$ vertices and sequences of length $n - 2$ with entries in ${1, 2, dots, n}$.

#align(center)[
  #diagram(
    spacing: (2em, 1.5em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    vertex((1.3, 2), $1$, tint: blue, <1>),
    vertex((2, 2), $2$, tint: blue, <2>),
    vertex((2.7, 2), $3$, tint: blue, <3>),
    vertex((1, 1), $4$, tint: blue, <4>),
    vertex((2, 1), $5$, tint: blue, <5>),
    vertex((3, 1), $6$, tint: blue, <6>),
    vertex((4, 1), $7$, tint: blue, <7>),
    vertex((0.5, 0), $8$, tint: blue, <8>),
    vertex((1.5, 0), $9$, tint: blue, <9>),
    vertex((2.5, 0), $10$, tint: blue, <10>),
    vertex((3.5, 0), $11$, tint: blue, <11>),
    vertex((4.5, 0), $12$, tint: blue, <12>),
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

#tasklist("prob7")[
  + Encode the labeled tree above into its Prüfer sequence.

  + Decode the Prüfer sequence $(3, 3, 3, 7, 7, 5)$ back into a labeled tree. Draw the result.

  + Prove that in the Prüfer sequence the number $i$ appears exactly $deg(i) - 1$ times.
]


== Problem 8: Minimum Spanning Trees

Consider the weighted graph from Problem 4.

#tasklist("prob8")[
  + Use *Kruskal's algorithm* to find a minimum spanning tree (MST). Show the edges in the order they are considered, and mark which are added to the MST.

  + Use *Prim's algorithm* starting from vertex $a$. Show how the tree grows step by step.

  + Prove: If all edge weights in a connected graph are _distinct_, then the MST is unique.
]


== Problem 9: Eulerian Graphs

#tasklist("prob9")[
  + For which values of $n >= 3$ does the complete graph $K_n$ have an Euler circuit? An Euler path (but not a circuit)? Prove your answers.

  + For which pairs $(m, n)$ with $m, n >= 1$ does the complete bipartite graph $K_(m,n)$ have an Euler circuit? An Euler path?

  + State and prove Euler's criterion: A connected graph has an Euler circuit if and only if every vertex has even degree.
]


== Problem 10: Hamiltonian Graphs and Hypercubes

#tasklist("prob10")[
  + Determine whether $K_(2,3)$ has a Hamiltonian path and a Hamiltonian cycle.

  + The $n$-dimensional _hypercube graph_ $Q_n$ has vertex set ${0,1}^n$ (all binary strings of length $n$), and two vertices are adjacent iff they differ in exactly one coordinate.
    Prove that $Q_n$ has a Hamiltonian cycle for all $n >= 2$.

  + Give an example of a graph that is:
    #[
      #set enum(numbering: "(a)")
      + 2-connected but not Hamiltonian
      + 3-regular but not Hamiltonian
    ]
]


== Problem 11: Bipartite Graphs

#tasklist("prob11")[
  + Prove that a graph $G$ is bipartite if and only if it contains no odd cycle.

  + Describe an algorithm based on BFS (breadth-first search) that determines whether a given graph is bipartite in $O(|V| + |E|)$ time. If the graph is bipartite, your algorithm should also produce a valid 2-coloring.

  + Prove: If $G$ is bipartite and $d$-regular with $d >= 1$, then $G$ has a perfect matching.
]


== Problem 12: Hall's Marriage Theorem

A dance school has 6 leaders and 6 followers. Each leader is willing to dance with certain followers, as shown in the table below ($times$ indicates willingness).

#align(center)[
  #table(
    columns: 7,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
    table.header([], [*$F_1$*], [*$F_2$*], [*$F_3$*], [*$F_4$*], [*$F_5$*], [*$F_6$*]),
    [*$L_1$*], [$times$], [$times$], [], [], [], [$times$],
    [*$L_2$*], [$times$], [], [$times$], [], [], [],
    [*$L_3$*], [], [$times$], [], [$times$], [], [],
    [*$L_4$*], [], [], [$times$], [], [$times$], [],
    [*$L_5$*], [], [], [], [$times$], [$times$], [],
    [*$L_6$*], [$times$], [], [], [], [], [$times$],
  )
]

#tasklist("prob12")[
  + Determine whether a perfect matching exists by verifying Hall's condition.

  + Find a maximum matching. Is it perfect?

  + Now suppose $L_2$ becomes more selective and will _only_ dance with $F_1$.
    Does a perfect matching still exist?
    If Hall's condition fails, identify the violating subset $S$ and explain why no perfect matching exists.

  + State and prove _Hall's Marriage Theorem_ in full generality.
]


== Problem 13: Graceful Graphs

A _graceful labeling_ of a graph $G$ with $m$ edges is an injective function $f: V(G) to {0, 1, 2, ..., m}$ such that the induced edge labels $|f(u) - f(v)|$ for each edge $(u, v) in E(G)$ are distinct and cover the set ${1, 2, ..., m}$.
In other words, the absolute differences of the labels of adjacent vertices are all different and cover the integers from 1 to $m$.
A graph is called _graceful_ if it has a graceful labeling.

Show that the following graphs are graceful (by explicitly constructing a graceful labeling for each).

#tasklist("prob13", cols: 3, format: "(a)")[
  #let vertex(pos, name, tint, ..args) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
    ..args,
  )

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((2, 0), <v3>, blue),
      vertex((3, 0), <v4>, blue),
      vertex((4, 0), <v5>, blue),
      edge(<v1>, <v2>),
      edge(<v1>, <v2>),
      edge(<v2>, <v3>),
      edge(<v3>, <v4>),
      edge(<v4>, <v5>),
    )

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((2, 0), <v3>, blue),
      vertex((3, 0), <v4>, blue),
      vertex((4, 0), <v5>, blue),
      vertex((2, -1), <v6>, blue),
      vertex((2, -2), <v7>, blue),
      edge(<v1>, <v2>),
      edge(<v2>, <v3>),
      edge(<v3>, <v4>),
      edge(<v4>, <v5>),
      edge(<v3>, <v6>),
      edge(<v6>, <v7>),
    )

  #colbreak()

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((2, 0), <v3>, blue),
      vertex((3, 0), <v4>, blue),
      vertex((1, -1), <v5>, blue),
      edge(<v1>, <v2>),
      edge(<v2>, <v3>),
      edge(<v3>, <v4>),
      edge(<v2>, <v5>),
    )

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((2, 0), <v3>, blue),
      vertex((3, 0), <v4>, blue),
      vertex((1, -1), <v5>, blue),
      vertex((2, -1), <v6>, blue),
      edge(<v1>, <v2>),
      edge(<v2>, <v3>),
      edge(<v3>, <v4>),
      edge(<v2>, <v5>),
      edge(<v3>, <v6>),
    )

  #colbreak()

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((2, 0), <v3>, blue),
      vertex((0, 1), <v4>, blue),
      vertex((1, 1), <v5>, blue),
      vertex((2, 1), <v6>, blue),
      edge(<v1>, <v4>),
      edge(<v1>, <v5>),
      edge(<v1>, <v6>),
      edge(<v2>, <v4>),
      edge(<v2>, <v5>),
      edge(<v2>, <v6>),
      edge(<v3>, <v4>),
      edge(<v3>, <v5>),
      edge(<v3>, <v6>),
    )

  + #diagram(
      spacing: 1.5em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <v1>, blue),
      vertex((1, 0), <v2>, blue),
      vertex((0, 1), <v3>, blue),
      vertex((1, 1), <v4>, blue),
      edge(<v1>, <v2>),
      edge(<v1>, <v3>),
      edge(<v1>, <v4>),
      edge(<v2>, <v3>),
      edge(<v2>, <v4>),
      edge(<v3>, <v4>),
    )
]

== Problem 14: Fundamental Theorems

Prove each of the following theorems rigorously. Your proofs should be complete and clearly written.

#tasklist("prob14")[
  + *(Triangle inequality)* For any graph $G$ and any three vertices $u, v, w in V(G)$, we have:
    $ d(u, w) <= d(u, v) + d(v, w) $

  // + *(Whitney)* For any graph $G$, $kappa(G) <= lambda(G) <= delta(G)$.

  // + *(Dirac)* If a graph $G$ on $n >= 3$ vertices has minimum degree $delta(G) >= n/2$, then $G$ is Hamiltonian.

  + *(Harary)* Every block of a block graph is a clique.

    A _block graph_ $H = B(G)$ is an intersection graph of all blocks (biconnected components) of $G$, i.e. each vertex $v in V(H)$ corresponds to a block of $G$, and there is an edge ${u,v} in E(H)$ iff "blocks" $u$ and $v$ share a cut vertex.

  + *(König)* In any bipartite graph, the size of a maximum matching equals the size of a minimum vertex cover.

    _Hint:_ Use Hall's Theorem or construct a matching--cover correspondence via residual networks.
]


== Problem 15: Network Flows

Consider the following flow network $N = (V, E, s, t, c)$ with source $s$ and sink $t$.

#align(center)[
  #diagram(
    spacing: 2em,
    node-stroke: 1pt,
    edge-stroke: 1pt,
    vertex((0, 1), $s$, tint: green, <s>),
    vertex((1, 2), $a$, tint: blue, <a>),
    vertex((1, 0), $b$, tint: blue, <b>),
    vertex((3, 2), $c$, tint: blue, <c>),
    vertex((2, 1), $d$, tint: blue, <d>),
    vertex((3, 0), $e$, tint: blue, <e>),
    vertex((4, 1), $t$, tint: red, <t>),
    edge(<s>, <a>, [10], label-angle: auto, label-side: center),
    edge(<s>, <b>, [8], label-angle: auto, label-side: center),
    edge(<b>, <a>, [3], label-angle: auto, label-side: center),
    edge(<a>, <c>, [5], label-angle: auto, label-side: center),
    edge(<a>, <d>, [4], label-angle: auto, label-side: center),
    edge(<b>, <d>, [10], label-angle: auto, label-side: center),
    edge(<b>, <e>, [3], label-angle: auto, label-side: center),
    edge(<d>, <c>, [3], label-angle: auto, label-side: center),
    edge(<e>, <d>, [9.], label-angle: auto, label-side: center),
    edge(<c>, <t>, [8], label-angle: auto, label-side: center),
    edge(<d>, <t>, [7], label-angle: auto, label-side: center),
    edge(<e>, <t>, [10], label-angle: auto, label-side: center),
  )
]

#tasklist("prob15")[
  + *Ford--Fulkerson execution.* Starting from zero flow, perform augmentations until no augmenting path exists.
    - At each iteration, specify the chosen augmenting path and its bottleneck.
    - Give the updated flow value $|f|$ and describe all changed residual capacities.
    - Your solution must include at least one iteration that uses a backward residual edge.

  + *Max-flow/min-cut certificate.*
    - Compute a maximum flow value.
    - Extract one minimum $s$-$t$ cut $(S, T)$ from the final residual network.
    - Verify numerically that $|f| = c(S, T)$.

  + *Sensitivity analysis.*
    - Increase the capacity of edge $(d, t)$ by 2 and recompute the new maximum flow value.
    - Identify one edge whose +1 capacity increase does *not* change the maximum flow, and justify via minimum cuts.

  + Prove the *integrality theorem*: if all capacities are integers, then there exists a maximum flow with integer values on all edges.

  // + *Theory-to-graph connection (unit capacities).*
  //   Let all capacities be 1 in a directed graph with source $s$ and sink $t$.
  //   Prove that the maximum flow value equals the maximum number of pairwise edge-disjoint $s$-$t$ paths.
]


// ============================================================================
// OPTIONAL PROBLEMS
// ============================================================================

#pagebreak()

#v(1em)
#align(center)[
  #text(size: 14pt, weight: "bold")[Optional Challenge Problems]
]
#v(0.5em)

#Block[
  The following problems are optional.
  They are more challenging and are intended for students who wish to explore deeper topics in graph theory.
  These problems will _not_ count toward your grade but may earn bonus points.
]

#v(1em)


== Problem A: Ramsey Theory

The _Ramsey number_ $R(r, s)$ is the minimum $n$ such that any 2-coloring of the edges of $K_n$ (complete graph) contains either a red $K_r$ or a blue $K_s$.

#tasklist("probA")[
  + Prove that $R(3, 3) = 6$ by showing:
    - Any edge-coloring of $K_5$ with two colors can avoid monochromatic triangles (construct an example).
    - Any edge-coloring of $K_6$ with two colors must contain a monochromatic triangle.

  + Show that $R(3, 4) <= 10$ by using a similar argument.

  + Prove the _Ramsey recurrence_: For all $r, s >= 2$,
    $ R(r, s) <= R(r-1, s) + R(r, s-1) $

  + Use the recurrence to show that $R(4, 4) <= 18$.
]


== Problem B: The Friendship Theorem

The _Friendship Theorem_ (Erdős, Rényi, Sós, 1966) states:

#Block[
  If $G$ is a finite simple graph in which every pair of _distinct_ vertices has _exactly one_ common neighbor, then $G$ is a _windmill graph_: $n$ triangles all sharing a single common vertex.
]

#tasklist("probB")[
  + Verify the theorem for small cases. Try to construct non-windmill graphs satisfying the friendship condition with $n <= 8$ vertices.

  + Prove that any graph $G$ satisfying the friendship condition must be regular (all vertices have the same degree).

  + Using regularity, show that if $G$ is $r$-regular and satisfies the friendship condition, then either $r = 2$ or there exists a universal vertex (a vertex adjacent to all others).
]


== Problem C: Network Flows

Design and implement a production-quality max-flow solver.

#tasklist("probC")[
  + Implement *Edmonds--Karp* (BFS-based Ford–Fulkerson) for directed graphs with non-negative integer edge capacities.

    Your code must produce three deliverables per run:
    - (1) *Maximum flow value* $|f^*|$ from source $s$ to sink $t$
    - (2) *One minimum cut* $(S, T)$ extracted from the residual network
    - (3) *Flow decomposition:* express the solution as a sum of edge-disjoint $s$-$t$ paths (with multiplicities) and identify any residual cycles

  + Test on three progressively complex instances:
    - The flow network from Problem 15
    - Random sparse network: $|V| = 30, |E| approx 60$ with random integer capacities $c(e) in [1..20]$
    - Random dense network: $|V| = 30, |E| approx 300$ with same capacity distribution

    For each test, verify the _max-flow/min-cut duality_: $|f^*| = c(S, T)$ numerically.

  + Across varying sizes ($|V| in {10, 20, ..., 100}$), measure and report:
    - *Execution time* (wall-clock seconds, average of 3 runs per size)
    - *Iteration count:* number of augmenting paths found until termination
    - *Empirical scaling:* does runtime grow as $cal(O)(|V| dot |E|^2)$ or faster? Compare fit quality to theoretical bound.
    - *Runtime plots:* present as a figure (runtime vs $|V|$ with fitted curve)

  + *(Bonus):*
    Implement *Dinic's algorithm* (blocking flows; theoretical bound $O(|V|^2 |E|)$) and benchmark against Edmonds–Karp on the same test suite.
    Which dominates on sparse vs dense graphs?
    Explain the observed crossover point.

  + *(Bonus):*
    Formulate one real-world problem (e.g., airline crew scheduling, data routing, bipartite matching) as a max-flow instance with 20+ vertices.
    Solve it using your implementation and interpret the flow decomposition.
]
