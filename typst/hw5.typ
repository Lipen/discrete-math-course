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
  + Present your solution clearly:
    - List the order in which vertices are added to the "visited" set
    - Show the distance labels $d(v)$ and predecessor pointers $pi(v)$ after each iteration
    - Reconstruct the shortest path from $a$ to $z$ and give its total weight

  + What is the time complexity of Dijkstra's algorithm when implemented with:
    - An unsorted array for the priority queue?
    - A binary heap?
    - A Fibonacci heap?
]


== Problem 5: Find the Error

The following "proof" contains a subtle error.
Identify the error and explain why the conclusion is false and the claim is not valid.

#Block[
  *False Claim:* Every tree with $n$ vertices has a path of length $n - 1$.

  *"Proof."*

  _Base case:_ A tree with one vertex clearly has a path of length $0 = 1 - 1$. $checkmark$

  _Inductive step:_
  Assume that every tree with $n$ vertices has a path of length $n - 1$.
  Consider a tree $T$ with $n + 1$ vertices.
  This path must terminate at some leaf $u$.
  Add a new vertex $v$ and connect it to $u$ with an edge.
  The resulting tree has $n + 1$ vertices and contains a path of length $n$, which is $(n+1) - 1$. $qed$
]


// == Problem 5: Network Connectivity Analysis

// An internet service provider models their network as a graph where vertices represent routers and edges represent physical links.

// #align(center)[
//   #diagram(
//     node-stroke: 1pt,
//     edge-stroke: 1pt,
//     spacing: (15mm, 14mm),
//     vertex((0, 1), $R_1$, tint: blue, <r1>),
//     vertex((1, 0), $R_2$, tint: blue, <r2>),
//     vertex((1, 2), $R_3$, tint: blue, <r3>),
//     vertex((2, 0.5), $R_4$, tint: blue, <r4>),
//     vertex((2, 1.5), $R_5$, tint: blue, <r5>),
//     vertex((3, 1), $R_6$, tint: blue, <r6>),
//     vertex((4, 0), $R_7$, tint: blue, <r7>),
//     vertex((4, 2), $R_8$, tint: blue, <r8>),
//     vertex((5, 0.5), $R_9$, tint: blue, <r9>),
//     vertex((5, 1.5), $R_10$, tint: blue, <r10>),
//     vertex((6, 1), $R_11$, tint: blue, <r11>),
//     edge(<r1>, <r2>),
//     edge(<r1>, <r3>),
//     edge(<r2>, <r4>),
//     edge(<r3>, <r5>),
//     edge(<r2>, <r3>),
//     edge(<r4>, <r5>),
//     edge(<r4>, <r6>),
//     edge(<r5>, <r6>),
//     edge(<r6>, <r7>),
//     edge(<r6>, <r8>),
//     edge(<r7>, <r9>),
//     edge(<r8>, <r10>),
//     edge(<r7>, <r8>),
//     edge(<r9>, <r10>),
//     edge(<r9>, <r11>),
//     edge(<r10>, <r11>),
//   )
// ]

// #tasklist("prob5")[
//   + Identify all _cut vertices_ (articulation points) and all _bridges_ in this network.

//   + Find all _blocks_ (maximal biconnected components) and all _islands_ (maximal 2-edge-connected components).

//   + Draw the _block-cut tree_ and the _bridge tree_ for this graph.

//   + Compute $kappa(G)$ (vertex connectivity) and $lambda(G)$ (edge connectivity). Verify Whitney's inequality: $kappa(G) <= lambda(G) <= delta(G)$.
// ]


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

  + Which characterization(s) generalize to forests (graphs where every connected component is a tree)? State and prove the generalization.
]


== Problem 7: Prüfer Sequences and Cayley's Formula

The Prüfer sequence provides a bijection between labeled trees on $n$ vertices and sequences of length $n - 2$ with entries in ${1, 2, dots, n}$.

#align(center)[
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (14mm, 14mm),
    vertex((1, 2), $1$, tint: blue, <1>),
    vertex((2, 2), $2$, tint: blue, <2>),
    vertex((3, 2), $3$, tint: blue, <3>),
    vertex((1, 1), $4$, tint: blue, <4>),
    vertex((2, 1), $5$, tint: blue, <5>),
    vertex((3, 1), $6$, tint: blue, <6>),
    vertex((4, 1), $7$, tint: blue, <7>),
    vertex((0, 0), $8$, tint: blue, <8>),
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

  + Decode the Prüfer sequence $(3, 3, 3, 7, 7, 5)$ back into a labeled tree on 8 vertices. Draw the result.

  + Prove: In the Prüfer sequence of a labeled tree on $n$ vertices, vertex $v$ appears exactly #box[$deg(v) - 1$] times.

  + Use the bijection to prove _Cayley's formula_: There are exactly $n^(n-2)$ labeled trees on $n$ vertices.
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
  + Does $K_(2,3)$ have a Hamiltonian path? A Hamiltonian cycle? Prove your answers.

  + The $n$-dimensional _hypercube graph_ $Q_n$ has vertex set ${0,1}^n$ (all binary strings of length $n$), and two vertices are adjacent iff they differ in exactly one coordinate.

    Prove that $Q_n$ has a Hamiltonian cycle for all $n >= 2$.

  + Give an example of a graph that is:
    - 2-connected but not Hamiltonian
    - 3-regular but not Hamiltonian
]


== Problem 11: Bipartite Graphs and BFS

#tasklist("prob11")[
  + Prove the _bipartite characterization theorem_: A graph $G$ is bipartite if and only if it contains no odd cycle.

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
  + Does a perfect matching exist?
    To answer this, verify Hall's condition: For every subset #box[$S subset.eq {L_1, dots, L_6}$], check whether $|N(S)| >= |S|$.

  + Find a maximum matching. Is it perfect?

  + Now suppose $L_2$ becomes more selective and will _only_ dance with $F_1$.
    Does a perfect matching still exist?
    If Hall's condition fails, identify the violating subset $S$ and explain why no perfect matching exists.

  + State and prove _Hall's Marriage Theorem_ in full generality.
]


== Problem 13: Planarity Testing

For each graph below, determine whether it is planar.

#tasklist("prob13", cols: 2)[
  + $K_4$ (complete graph on 4 vertices)
  + $K_5$ (complete graph on 5 vertices)
  #colbreak()
  + $Q_3$ (3-dimensional hypercube)
  + The Petersen graph
]

For each planar graph, draw a planar embedding and verify Euler's formula: $n - m + f = 2$, where $n$ is the number of vertices, $m$ is the number of edges, and $f$ is the number of faces.

For each non-planar graph, prove non-planarity using one of:
- Kuratowski's theorem (find a $K_5$ or $K_(3,3)$ subdivision), or
- The inequality $m <= 3n - 6$ for simple planar graphs with $n >= 3$.


== Problem 14: Graph Coloring

#tasklist("prob14")[
  + Determine the chromatic number $chi(G)$ for each graph in Problem 1.
    For each graph, prove that $chi(G) - 1$ colors are insufficient by exhibiting an appropriate subgraph structure.

  + Find the chromatic number of each graph family below, and prove your answers:
    - $C_n$ (cycle on $n >= 3$ vertices)
    - $K_(m,n)$ (complete bipartite graph)
    - $W_n$ (wheel graph: $C_(n-1)$ plus one central vertex connected to all vertices of the cycle)

  + Prove the _greedy coloring bound_: If $G$ has maximum degree $Delta$, then $chi(G) <= Delta + 1$.

  + Construct a family of graphs demonstrating that the bound in part (c) is tight.
]


== Problem 15: Fundamental Theorems in Graph Theory

Prove each of the following theorems rigorously. Your proofs should be complete and clearly written.

#tasklist("prob15")[
  + *Triangle Inequality for Distances.* For any connected graph $G = pair(V, E)$ and any three vertices $x, y, z in V$:
    $ dist(x, z) <= dist(x, y) + dist(y, z) $

  + *Radius--Diameter Bounds.* For any connected graph $G$:
    $ rad(G) <= diam(G) <= 2 dot rad(G) $

  + *Whitney's Inequality.* For any graph $G$:
    $ kappa(G) <= lambda(G) <= delta(G) $
    where $kappa(G)$ is the vertex connectivity, $lambda(G)$ is the edge connectivity, and $delta(G)$ is the minimum degree.

  + *Handshaking Lemma.* In any graph $G = pair(V, E)$:
    $ sum_(v in V) deg(v) = 2|E| $
    Conclude that the number of vertices with odd degree is even.

  + *König's Theorem.* In any bipartite graph, the size of a maximum matching equals the size of a minimum vertex cover.
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

#tasklist("probR")[
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

#tasklist("probF")[
  + Verify the theorem for small cases. Try to construct non-windmill graphs satisfying the friendship condition with $n <= 8$ vertices.

  + Prove that any graph $G$ satisfying the friendship condition must be regular (all vertices have the same degree).

  + Using regularity, show that if $G$ is $r$-regular and satisfies the friendship condition, then either $r = 2$ or there exists a universal vertex (a vertex adjacent to all others).
]


== Problem C: Programming Project

Implement a graph theory library in your preferred programming language with the following functionality:

#tasklist("probP")[
  + *Data structures:* Implement both adjacency matrix and adjacency list representations. Support conversion between them.

  + *Basic algorithms:* Implement DFS, BFS, connected components, bipartiteness testing, and topological sorting (for directed graphs).

  + *Shortest paths:* Implement Dijkstra's algorithm for weighted graphs and BFS for unweighted graphs.

  + *Properties:* Compute degree sequence, check if Eulerian, find eccentricities/radius/diameter/center.

  + *Testing:* Test your implementation on the graphs from Problem 1. Generate a report comparing your results with manual calculations.

  + *(Bonus)* Implement Floyd--Warshall for all-pairs shortest paths, Prim's or Kruskal's MST algorithm, and a graph isomorphism checker.
]
