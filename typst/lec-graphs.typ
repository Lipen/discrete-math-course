#import "theme.typ": *
#show: slides.with(
  title: [Graph Theory],
  subtitle: "Discrete Math",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#import "common-lec.typ": *

// Custom operators for graph theory
#let deg = math.op("deg")
#let dist = math.op("dist")
#let diam = math.op("diam")
#let rad = math.op("rad")
#let girth = math.op("girth")
#let Center = math.op("center")
#let ecc = math.op("ecc")
#let Adj = math.op("Adj")
#let kappa = sym.kappa
#let lambda = sym.lambda
#let angle = sym.chevron


= Graph Theory
#focus-slide(
  epigraph: [The origins of graph theory are humble, even frivolous.],
  epigraph-author: "Norman L. Biggs",
  scholars: (
    (
      name: "Leonhard Euler",
      image: image("assets/Leonhard_Euler.jpg"),
    ),
    (
      name: "Arthur Cayley",
      image: image("assets/Arthur_Cayley.jpg"),
    ),
    (
      name: "William Rowan Hamilton",
      image: image("assets/William_Rowan_Hamilton.jpg"),
    ),
    (
      name: "Karl Menger",
      image: image("assets/Karl_Menger.jpg"),
    ),
    (
      name: "Philip Hall",
      image: image("assets/Philip_Hall.jpg"),
    ),
  ),
)

== Why Graph Theory?

Graphs are _everywhere_ --- they model relationships, connections, and structures.

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Real-world applications:*
    - Social networks (friendships)
    - Computer networks (routers)
    - Transportation (roads, flights)
    - Biology (protein interactions)
    - Chemistry (molecular bonds)
  ],
  [
    *Computer science applications:*
    - Data structures (linked lists, trees)
    - Algorithms (shortest paths, flows)
    - Compilers (dependency graphs)
    - Databases (query optimization)
    - AI (neural networks, knowledge graphs)
  ],
)

#Block(color: yellow)[
  *Key insight:* Graph theory provides a _universal language_ for describing discrete structures and their properties.
]

== The Seven Bridges of Königsberg

#columns(2)[
  In 1736, Leonhard Euler solved a famous puzzle:

  _Can one walk through the city of Königsberg, crossing each of its seven bridges exactly once?_

  #v(0.5em)

  Euler proved this is _impossible_ --- and in doing so, invented graph theory.

  #colbreak()

  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (1.5cm, 1cm),
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), $A$, tint: blue, name: <a>),
      blob((2, 0), $B$, tint: blue, name: <b>),
      blob((1, -1), $C$, tint: blue, name: <c>),
      blob((1, 1), $D$, tint: blue, name: <d>),
      edge(<a>, <b>, bend: 30deg),
      edge(<a>, <b>, bend: -30deg),
      edge(<a>, <c>),
      edge(<a>, <d>),
      edge(<b>, <c>),
      edge(<b>, <d>),
      edge(<c>, <d>),
    )
  ]
]

#Block(color: teal)[
  *Historical note:* This problem marks the birth of _topology_ and _graph theory_ as mathematical disciplines.
]


= Basic Definitions
#focus-slide()

== What is a Graph?

#definition[
  A _graph_ is an ordered pair $G = angle.l V, E angle.r$, where:
  - $V$ is a finite set of _vertices_ (also called _nodes_)
  - $E$ is a set of _edges_ connecting pairs of vertices
]

#note(title: "Notation")[
  - $V(G)$ denotes the vertex set of graph $G$
  - $E(G)$ denotes the edge set of graph $G$
  - $|V(G)|$ is the _order_ of $G$ (number of vertices)
  - $|E(G)|$ is the _size_ of $G$ (number of edges)
]

#example[
  $G = angle.l {a, b, c, d}, {{a,b}, {b,c}, {c,d}, {d,a}} angle.r$

  This graph has 4 vertices and 4 edges forming a cycle.
]

== Undirected vs Directed Graphs

#columns(2)[
  #definition[Undirected Graph][
    In an _undirected graph_, edges are _unordered pairs_:
    $ E subset.eq binom(V, 2) = { {u, v} | u, v in V, u != v } $
  ]

  The edge ${u, v}$ connects $u$ and $v$ symmetrically.

  #colbreak()

  #definition[Directed Graph][
    In a _directed graph_ (digraph), edges are _ordered pairs_:
    $ E subset.eq V times V $
  ]

  The edge $(u, v)$ goes _from_ $u$ _to_ $v$.
]

#v(1em)

#align(center)[
  #import fletcher: diagram, edge, node
  #grid(
    columns: 2,
    gutter: 3cm,
    [
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((0, 1), $c$, tint: blue, name: <c>),
        blob((1, 1), $d$, tint: blue, name: <d>),
        edge(<a>, <b>),
        edge(<b>, <d>),
        edge(<d>, <c>),
        edge(<c>, <a>),
      )
      #v(0.5em)
      Undirected
    ],
    [
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((0, 1), $c$, tint: blue, name: <c>),
        blob((1, 1), $d$, tint: blue, name: <d>),
        edge(<a>, <b>, "->"),
        edge(<b>, <d>, "->"),
        edge(<d>, <c>, "->"),
        edge(<c>, <a>, "->"),
      )
      #v(0.5em)
      Directed
    ],
  )
]

== Simple Graphs, Multigraphs, and Pseudographs

#definition[
  - A _simple graph_ has no _loops_ (edges from a vertex to itself) and no _multi-edges_ (multiple edges between the same pair of vertices).
  - A _multigraph_ allows _multi-edges_ but no loops.
  - A _pseudograph_ allows both loops and multi-edges.
]

#align(center)[
  #import fletcher: diagram, edge, node
  #grid(
    columns: 3,
    gutter: 2cm,
    [
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((0.5, 0.8), $c$, tint: blue, name: <c>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
      )
      #v(0.3em)
      *Simple*
    ],
    [
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((0.5, 0.8), $c$, tint: blue, name: <c>),
        edge(<a>, <b>, bend: 20deg),
        edge(<a>, <b>, bend: -20deg),
        edge(<b>, <c>),
        edge(<c>, <a>),
      )
      #v(0.3em)
      *Multigraph*
    ],
    [
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((0.5, 0.8), $c$, tint: blue, name: <c>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
        edge(<c>, <c>, bend: 130deg),
      )
      #v(0.3em)
      *Pseudograph*
    ],
  )
]

#note[
  Unless otherwise stated, "graph" means _simple undirected graph_ in this course.
]

== Adjacency and Incidence

#definition[
  - Two vertices $u$ and $v$ are _adjacent_ if there is an edge between them: ${u, v} in E$.
  - An edge $e$ is _incident_ to vertex $v$ if $v$ is an endpoint of $e$.
  - The _neighborhood_ of $v$ is $N(v) = { u in V | {u, v} in E }$.
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: green, name: <b>),
        blob((2, 0), $c$, tint: blue, name: <c>),
        blob((0.5, 0.8), $d$, tint: green, name: <d>),
        blob((1.5, 0.8), $e$, tint: green, name: <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<d>, <e>),
      )
    ]

    #colbreak()

    - $a$ and $b$ are _adjacent_
    - $a$ and $c$ are _not adjacent_
    - Edge ${a, b}$ is _incident_ to $a$ and $b$
    - $N(b) = {a, c, d, e}$
  ]
]

== Degree of a Vertex

#definition[
  The _degree_ of a vertex $v$, denoted $deg(v)$, is the number of edges incident to $v$.
  - $delta(G) = min_(v in V) deg(v)$ is the _minimum degree_
  - $Delta(G) = max_(v in V) deg(v)$ is the _maximum degree_
]

#theorem[Handshaking Lemma][
  For any graph $G = angle.l V, E angle.r$:
  $ sum_(v in V) deg(v) = 2|E| $
]

#proof[
  Each edge contributes exactly 2 to the sum of degrees (once for each endpoint).
]

#Block(color: yellow)[
  *Corollary:* The number of vertices with odd degree is always _even_.
]

== Degree Sequences

#definition[
  The _degree sequence_ of a graph is the list of vertex degrees in non-increasing order.
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((2, 0), $c$, tint: blue, name: <c>),
        blob((0.5, 0.8), $d$, tint: blue, name: <d>),
        blob((1.5, 0.8), $e$, tint: blue, name: <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<d>, <e>),
      )
    ]

    #colbreak()

    Degrees: $deg(a) = 1$, $deg(b) = 4$, $deg(c) = 1$, $deg(d) = 2$, $deg(e) = 2$

    Degree sequence: $(4, 2, 2, 1, 1)$
  ]
]

#Block(color: blue)[
  *Question:* Given a sequence of integers, can we determine if it's the degree sequence of some graph?
  This is the _graph realization problem_.
]

== Regular Graphs

#definition[
  A graph is _$r$-regular_ if every vertex has degree $r$:
  $ forall v in V: thin deg(v) = r $
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 4,
      gutter: 1.5cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
        #v(0.3em)
        *2-regular* \ (cycle $C_4$)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
          edge(<b>, <d>),
        )
        #v(0.3em)
        *3-regular* \ (complete $K_4$)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          node((0, 0), [], stroke: 1pt, shape: circle, fill: blue.lighten(80%), name: <a>),
          node((1, 0), [], stroke: 1pt, shape: circle, fill: blue.lighten(80%), name: <b>),
          node((1.3, 0.8), [], stroke: 1pt, shape: circle, fill: blue.lighten(80%), name: <c>),
          node((0.5, 1.2), [], stroke: 1pt, shape: circle, fill: blue.lighten(80%), name: <d>),
          node((-0.3, 0.8), [], stroke: 1pt, shape: circle, fill: blue.lighten(80%), name: <e>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <e>),
          edge(<e>, <a>),
        )
        #v(0.3em)
        *2-regular* \ (cycle $C_5$)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((0.5, 0.87), [], tint: blue, name: <c>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <a>),
        )
        #v(0.3em)
        *2-regular* \ (complete $K_3$)
      ],
    )
  ]
]

== Special Graphs

#definition[
  - _Null graph_: no vertices ($V = emptyset$)
  - _Trivial graph_: single vertex, no edges ($|V| = 1$, $E = emptyset$)
  - _Empty graph_ $overline(K_n)$: $n$ vertices, no edges
  - _Complete graph_ $K_n$: $n$ vertices, all pairs connected
  - _Cycle_ $C_n$: $n$ vertices in a cycle
  - _Path_ $P_n$: $n$ vertices in a line
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 4,
      gutter: 1.5cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((0.7, 0), [], tint: blue, name: <b>),
          blob((1.4, 0), [], tint: blue, name: <c>),
          blob((2.1, 0), [], tint: blue, name: <d>),
        )
        #v(0.3em)
        $overline(K_4)$ (empty)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
          edge(<b>, <d>),
        )
        #v(0.3em)
        $K_4$ (complete)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
        #v(0.3em)
        $C_4$ (cycle)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((0.7, 0), [], tint: blue, name: <b>),
          blob((1.4, 0), [], tint: blue, name: <c>),
          blob((2.1, 0), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
        )
        #v(0.3em)
        $P_4$ (path)
      ],
    )
  ]
]

#theorem[
  The complete graph $K_n$ has exactly $binom(n, 2) = (n(n-1))/2$ edges.
]

== Graph Representations: Adjacency Matrix

#definition[
  The _adjacency matrix_ $A$ of a graph $G$ with $n$ vertices is an $n times n$ matrix where:
  $ A_(i j) = cases(1 & "if" {v_i, v_j} in E, 0 & "otherwise") $
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $1$, tint: blue, name: <1>),
        blob((1, 0), $2$, tint: blue, name: <2>),
        blob((1, 1), $3$, tint: blue, name: <3>),
        blob((0, 1), $4$, tint: blue, name: <4>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <1>),
        edge(<1>, <3>),
      )
    ]

    #colbreak()

    $
      A = mat(
        0, 1, 1, 1;
        1, 0, 1, 0;
        1, 1, 0, 1;
        1, 0, 1, 0;
      )
    $
  ]
]

#Block(color: yellow)[
  *Properties:* For undirected graphs, $A$ is _symmetric_. The diagonal is all zeros for simple graphs.
]

== Graph Representations: Adjacency List

#definition[
  The _adjacency list_ representation stores, for each vertex $v$, a list of its neighbors $N(v)$.
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $1$, tint: blue, name: <1>),
        blob((1, 0), $2$, tint: blue, name: <2>),
        blob((1, 1), $3$, tint: blue, name: <3>),
        blob((0, 1), $4$, tint: blue, name: <4>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <1>),
        edge(<1>, <3>),
      )
    ]

    #colbreak()

    #table(
      columns: 2,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      [*Vertex*], [*Neighbors*],
      [$1$], [$2, 3, 4$],
      [$2$], [$1, 3$],
      [$3$], [$1, 2, 4$],
      [$4$], [$1, 3$],
    )
  ]
]

#Block(color: blue)[
  *Space complexity:* Adjacency matrix uses $O(n^2)$, adjacency list uses $O(n + m)$ where $m = |E|$.
]

== Subgraphs

#definition[
  A graph $H = angle.l V', E' angle.r$ is a _subgraph_ of $G = angle.l V, E angle.r$ if $V' subset.eq V$ and $E' subset.eq E$.
  We write $H subset.eq G$.
]

#definition[
  - A _spanning subgraph_ includes all vertices: $V' = V$.
  - An _induced subgraph_ $G[S]$ on vertex set $S subset.eq V$ includes all edges between vertices in $S$:
    $ E' = { {u, v} in E | u, v in S } $
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 3,
      gutter: 2cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: blue, name: <a>),
          blob((1, 0), $b$, tint: blue, name: <b>),
          blob((1, 1), $c$, tint: blue, name: <c>),
          blob((0, 1), $d$, tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Original $G$*
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: blue, name: <a>),
          blob((1, 0), $b$, tint: blue, name: <b>),
          blob((1, 1), $c$, tint: blue, name: <c>),
          blob((0, 1), $d$, tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
        #v(0.3em)
        *Spanning subgraph*
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: green, name: <a>),
          blob((1, 0), $b$, tint: green, name: <b>),
          blob((1, 1), $c$, tint: green, name: <c>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Induced $G[{a,b,c}]$*
      ],
    )
  ]
]

== Graph Isomorphism

#definition[
  Two graphs $G_1 = angle.l V_1, E_1 angle.r$ and $G_2 = angle.l V_2, E_2 angle.r$ are _isomorphic_, written $G_1 tilde.eq G_2$, if there exists a bijection $f: V_1 -> V_2$ such that:
  $ {u, v} in E_1 <==> {f(u), f(v)} in E_2 $
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $1$, tint: blue, name: <1>),
          blob((1, 0), $2$, tint: blue, name: <2>),
          blob((1, 1), $3$, tint: blue, name: <3>),
          blob((0, 1), $4$, tint: blue, name: <4>),
          edge(<1>, <2>),
          edge(<2>, <3>),
          edge(<3>, <4>),
          edge(<4>, <1>),
        )
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0.5), $a$, tint: green, name: <a>),
          blob((0.5, 0), $b$, tint: green, name: <b>),
          blob((1, 0.5), $c$, tint: green, name: <c>),
          blob((0.5, 1), $d$, tint: green, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
      ],
    )
  ]
]

Both graphs are isomorphic to $C_4$. The bijection $f(1) = a, f(2) = b, f(3) = c, f(4) = d$ preserves adjacency.

#Block(color: orange)[
  *Warning:* Checking graph isomorphism is computationally difficult! (In NP, not known to be NP-complete or in P)
]


= Paths and Connectivity
#focus-slide()

== Walks, Trails, and Paths

#definition[
  A _walk_ in a graph is an alternating sequence of vertices and edges:
  $ v_0, e_1, v_1, e_2, v_2, ..., e_k, v_k $
  where each edge $e_i = {v_(i-1), v_i}$.

  - A _trail_ is a walk with _distinct edges_.
  - A _path_ is a walk with _distinct vertices_ (hence distinct edges).
]

#align(center)[
  #table(
    columns: 4,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    [*Type*], [*Vertices repeat?*], [*Edges repeat?*], [*Closed version*],
    [Walk], [Yes], [Yes], [Closed walk],
    [Trail], [Yes], [No], [Circuit],
    [Path], [No], [No], [Cycle],
  )
]

#note[
  A walk/trail/path is _closed_ if it starts and ends at the same vertex.
]

== Length and Distance

#definition[
  The _length_ of a walk (trail, path) is the number of edges in it.
]

#definition[
  The _distance_ $dist(u, v)$ between vertices $u$ and $v$ is the length of the shortest path from $u$ to $v$.

  If no path exists, we write $dist(u, v) = infinity$.
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: blue, name: <b>),
        blob((2, 0), $c$, tint: blue, name: <c>),
        blob((0.5, 0.8), $d$, tint: blue, name: <d>),
        blob((1.5, 0.8), $e$, tint: blue, name: <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<a>, <d>),
        edge(<d>, <e>),
        edge(<e>, <c>),
        edge(<b>, <d>),
      )
    ]

    #colbreak()

    - $dist(a, b) = 1$
    - $dist(a, c) = 2$
    - $dist(a, e) = 2$
    - Path $a$-$b$-$c$ has length 2
    - Trail $a$-$d$-$b$-$c$-$e$-$d$ has length 5
  ]
]

== Eccentricity, Radius, and Diameter

#definition[
  - _Eccentricity_ of vertex $v$: $ecc(v) = max_(u in V) dist(v, u)$
  - _Radius_ of graph: $rad(G) = min_(v in V) ecc(v)$
  - _Diameter_ of graph: $diam(G) = max_(v in V) ecc(v)$
  - _Center_ of graph: $Center(G) = { v in V | ecc(v) = rad(G) }$
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, name: <a>),
        blob((1, 0), $b$, tint: green, name: <b>),
        blob((2, 0), $c$, tint: green, name: <c>),
        blob((3, 0), $d$, tint: blue, name: <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
      )
    ]

    #colbreak()

    Path graph $P_4$:
    - $ecc(a) = ecc(d) = 3$
    - $ecc(b) = ecc(c) = 2$
    - $rad(G) = 2$, $diam(G) = 3$
    - $Center(G) = {b, c}$
  ]
]

#theorem[
  For any connected graph $G$: $rad(G) <= diam(G) <= 2 dot rad(G)$
]

== Connectivity

#definition[
  A graph $G$ is _connected_ if there exists a path between every pair of vertices.
]

#definition[
  A _connected component_ of $G$ is a maximal connected subgraph.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Component 1
      blob((0, 0), $a$, tint: blue, name: <a>),
      blob((1, 0), $b$, tint: blue, name: <b>),
      blob((0.5, 0.8), $c$, tint: blue, name: <c>),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<c>, <a>),
      // Component 2
      blob((2.5, 0), $d$, tint: green, name: <d>),
      blob((3.5, 0), $e$, tint: green, name: <e>),
      edge(<d>, <e>),
      // Component 3
      blob((5, 0.4), $f$, tint: orange, name: <f>),
    )
  ]
]

This graph has 3 connected components: ${a, b, c}$, ${d, e}$, and ${f}$.

#Block(color: yellow)[
  *Key insight:* "Being in the same connected component" is an _equivalence relation_ on vertices.
]

== Girth

#definition[
  The _girth_ of a graph $G$ is the length of the shortest cycle in $G$.

  If $G$ has no cycles (is acyclic), we say $girth(G) = infinity$.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 3,
      gutter: 2cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((0.5, 0.87), [], tint: blue, name: <b>),
          blob((1, 0), [], tint: blue, name: <c>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <a>),
        )
        #v(0.3em)
        $girth = 3$
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
        #v(0.3em)
        $girth = 4$
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((2, 0), [], tint: blue, name: <c>),
          blob((3, 0), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
        )
        #v(0.3em)
        $girth = infinity$
      ],
    )
  ]
]


= Trees and Forests
#focus-slide()

== Trees: Definition

#definition[
  A _tree_ is a connected acyclic graph.

  A _forest_ is an acyclic graph (a disjoint union of trees).
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((1, 0), [], tint: blue, name: <root>),
          blob((0, 1), [], tint: blue, name: <l>),
          blob((2, 1), [], tint: blue, name: <r>),
          blob((-0.3, 2), [], tint: blue, name: <ll>),
          blob((0.5, 2), [], tint: blue, name: <lr>),
          blob((1.7, 2), [], tint: blue, name: <rl>),
          blob((2.3, 2), [], tint: blue, name: <rr>),
          edge(<root>, <l>),
          edge(<root>, <r>),
          edge(<l>, <ll>),
          edge(<l>, <lr>),
          edge(<r>, <rl>),
          edge(<r>, <rr>),
        )
        #v(0.3em)
        *A tree*
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          // Tree 1
          blob((0, 0), [], tint: blue, name: <a>),
          blob((-0.4, 1), [], tint: blue, name: <b>),
          blob((0.4, 1), [], tint: blue, name: <c>),
          edge(<a>, <b>),
          edge(<a>, <c>),
          // Tree 2
          blob((1.5, 0.5), [], tint: green, name: <d>),
          blob((2, 0.5), [], tint: green, name: <e>),
          edge(<d>, <e>),
          // Tree 3
          blob((3, 0.5), [], tint: orange, name: <f>),
        )
        #v(0.3em)
        *A forest* \ (3 trees)
      ],
    )
  ]
]

== Characterizations of Trees

#theorem[
  For a graph $G$ with $n$ vertices, the following are equivalent:
  + $G$ is a tree (connected and acyclic)
  + $G$ is connected and has exactly $n - 1$ edges
  + $G$ is acyclic and has exactly $n - 1$ edges
  + There is a _unique path_ between any two vertices
  + $G$ is _minimally connected_: removing any edge disconnects $G$
  + $G$ is _maximally acyclic_: adding any edge creates a cycle
]

#Block(color: yellow)[
  *Key insight:* Trees are the "minimal" connected graphs --- they have exactly the edges needed to connect all vertices.
]

== Rooted Trees

#definition[
  A _rooted tree_ is a tree with one designated vertex called the _root_.

  In a rooted tree:
  - The _parent_ of $v$ is the neighbor of $v$ on the path to the root
  - The _children_ of $v$ are the other neighbors of $v$
  - A _leaf_ is a vertex with no children
  - An _internal vertex_ has at least one child
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((1, 0), [root], tint: red, name: <root>),
      blob((0, 1), $a$, tint: blue, name: <a>),
      blob((2, 1), $b$, tint: blue, name: <b>),
      blob((-0.3, 2), $c$, tint: green, name: <c>),
      blob((0.5, 2), $d$, tint: green, name: <d>),
      blob((2, 2), $e$, tint: green, name: <e>),
      edge(<root>, <a>),
      edge(<root>, <b>),
      edge(<a>, <c>),
      edge(<a>, <d>),
      edge(<b>, <e>),
    )
  ]
]

- Root has children $a, b$
- Leaves: $c, d, e$ (shown in green)
- Internal vertices: root, $a, b$

== Spanning Trees

#definition[
  A _spanning tree_ of a connected graph $G$ is a spanning subgraph that is a tree.
]

#theorem[
  Every connected graph has at least one spanning tree.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: blue, name: <a>),
          blob((1, 0), $b$, tint: blue, name: <b>),
          blob((1, 1), $c$, tint: blue, name: <c>),
          blob((0, 1), $d$, tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Original graph*
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: blue, name: <a>),
          blob((1, 0), $b$, tint: blue, name: <b>),
          blob((1, 1), $c$, tint: blue, name: <c>),
          blob((0, 1), $d$, tint: blue, name: <d>),
          edge(<a>, <b>, stroke: 2pt + green),
          edge(<b>, <c>, stroke: 2pt + green),
          edge(<c>, <d>, stroke: 2pt + green),
          edge(<d>, <a>, stroke: gray + 0.5pt),
          edge(<a>, <c>, stroke: gray + 0.5pt),
        )
        #v(0.3em)
        *A spanning tree*
      ],
    )
  ]
]

#Block(color: blue)[
  *Application:* Finding minimum spanning trees (MST) is fundamental in network design.
]

== Cayley's Formula

#theorem[Cayley's Formula][
  The number of labeled trees on $n$ vertices is $n^(n-2)$.
]

#example[
  - $n = 2$: $2^0 = 1$ tree
  - $n = 3$: $3^1 = 3$ trees
  - $n = 4$: $4^2 = 16$ trees
]

#Block(color: teal)[
  *Historical note:* This beautiful formula can be proved using Prüfer sequences --- a bijection between labeled trees and sequences of length $n-2$.
]

== Prüfer Sequences

#definition[
  A _Prüfer sequence_ is a unique encoding of a labeled tree on $n$ vertices as a sequence of $n-2$ labels.
]

#Block(color: blue)[
  *Encoding algorithm:*
  + Find the leaf with the smallest label
  + Add its neighbor's label to the sequence
  + Remove the leaf from the tree
  + Repeat until 2 vertices remain
]

#example[
  Tree: $1$-$3$-$4$-$2$, $3$-$5$

  Encoding: Remove 1 (neighbor 3), remove 2 (neighbor 4), remove 5 (neighbor 3).

  Prüfer sequence: $(3, 4, 3)$
]


= Bipartite Graphs
#focus-slide()

== Definition of Bipartite Graphs

#definition[
  A graph $G = angle.l V, E angle.r$ is _bipartite_ if its vertices can be partitioned into two disjoint sets $V = X union.sq Y$ such that every edge connects a vertex in $X$ to a vertex in $Y$.

  We write $G = angle.l X, Y, E angle.r$.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          // Part X
          blob((0, 0), $x_1$, tint: blue, name: <x1>),
          blob((1, 0), $x_2$, tint: blue, name: <x2>),
          blob((2, 0), $x_3$, tint: blue, name: <x3>),
          // Part Y
          blob((0.5, 1.2), $y_1$, tint: green, name: <y1>),
          blob((1.5, 1.2), $y_2$, tint: green, name: <y2>),
          // Edges
          edge(<x1>, <y1>),
          edge(<x1>, <y2>),
          edge(<x2>, <y1>),
          edge(<x3>, <y2>),
        )
        #v(0.3em)
        *Bipartite*
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), $a$, tint: blue, name: <a>),
          blob((1, 0), $b$, tint: blue, name: <b>),
          blob((0.5, 0.87), $c$, tint: blue, name: <c>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <a>),
        )
        #v(0.3em)
        *Not bipartite* \ (contains triangle)
      ],
    )
  ]
]

== Characterization of Bipartite Graphs

#theorem[
  A graph is bipartite if and only if it contains no odd-length cycles.
]

#proof[(Sketch)][
  ($arrow.r.double$) In a bipartite graph, any cycle must alternate between $X$ and $Y$, so it has even length.

  ($arrow.l.double$) If no odd cycles, we can 2-color the graph by BFS: start at any vertex, color it blue, color neighbors green, etc.
]

#Block(color: yellow)[
  *Algorithm:* Check bipartiteness using BFS/DFS in $O(n + m)$ time.
]

== Complete Bipartite Graphs

#definition[
  The _complete bipartite graph_ $K_(m,n)$ has parts of sizes $m$ and $n$, with every vertex in one part adjacent to every vertex in the other.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 3,
      gutter: 2cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <x1>),
          blob((1, 0), [], tint: blue, name: <x2>),
          blob((0.5, 1), [], tint: green, name: <y1>),
          edge(<x1>, <y1>),
          edge(<x2>, <y1>),
        )
        #v(0.3em)
        $K_(2,1)$
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <x1>),
          blob((1, 0), [], tint: blue, name: <x2>),
          blob((0, 1), [], tint: green, name: <y1>),
          blob((1, 1), [], tint: green, name: <y2>),
          edge(<x1>, <y1>),
          edge(<x1>, <y2>),
          edge(<x2>, <y1>),
          edge(<x2>, <y2>),
        )
        #v(0.3em)
        $K_(2,2)$
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <x1>),
          blob((1, 0), [], tint: blue, name: <x2>),
          blob((2, 0), [], tint: blue, name: <x3>),
          blob((0.5, 1), [], tint: green, name: <y1>),
          blob((1.5, 1), [], tint: green, name: <y2>),
          edge(<x1>, <y1>),
          edge(<x1>, <y2>),
          edge(<x2>, <y1>),
          edge(<x2>, <y2>),
          edge(<x3>, <y1>),
          edge(<x3>, <y2>),
        )
        #v(0.3em)
        $K_(3,2)$
      ],
    )
  ]
]

#note[
  $K_(m,n)$ has $m + n$ vertices and $m dot n$ edges.
]


= Matchings and Covers
#focus-slide()

== Matchings

#definition[
  A _matching_ $M subset.eq E$ is a set of pairwise non-adjacent edges (no two edges share a vertex).
]

#definition[
  - A matching is _maximal_ if no edge can be added to it.
  - A matching is _maximum_ if it has the largest possible size.
  - A _perfect matching_ covers all vertices.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 3,
      gutter: 1.5cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((2, 0), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          blob((1, 1), [], tint: blue, name: <e>),
          blob((2, 1), [], tint: blue, name: <f>),
          edge(<a>, <d>, stroke: 2pt + green),
          edge(<a>, <e>),
          edge(<b>, <d>),
          edge(<b>, <e>),
          edge(<c>, <e>),
          edge(<c>, <f>),
        )
        #v(0.3em)
        *Matching* \ (not maximal)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((2, 0), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          blob((1, 1), [], tint: blue, name: <e>),
          blob((2, 1), [], tint: blue, name: <f>),
          edge(<a>, <d>),
          edge(<a>, <e>, stroke: 2pt + green),
          edge(<b>, <d>, stroke: 2pt + green),
          edge(<b>, <e>),
          edge(<c>, <e>),
          edge(<c>, <f>, stroke: 2pt + green),
        )
        #v(0.3em)
        *Maximum* \ (perfect)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((2, 0), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          blob((1, 1), [], tint: blue, name: <e>),
          blob((2, 1), [], tint: blue, name: <f>),
          edge(<a>, <d>, stroke: 2pt + orange),
          edge(<a>, <e>),
          edge(<b>, <d>),
          edge(<b>, <e>, stroke: 2pt + orange),
          edge(<c>, <e>),
          edge(<c>, <f>),
        )
        #v(0.3em)
        *Maximal* \ (not maximum)
      ],
    )
  ]
]

== Hall's Marriage Theorem

#theorem[Hall's Marriage Theorem][
  A bipartite graph $G = angle.l X, Y, E angle.r$ has a matching that covers $X$ (saturates all vertices in $X$) if and only if for every subset $S subset.eq X$:
  $ |N(S)| >= |S| $
  where $N(S)$ is the set of neighbors of vertices in $S$.
]

#Block(color: blue)[
  *Intuition:* For every subset of people in $X$, there must be enough potential partners in $Y$.
]

#example[
  #columns(2)[
    Consider jobs $X = {j_1, j_2, j_3}$ and workers $Y = {w_1, w_2, w_3}$ with edges showing who can do which job.

    Hall's condition: every subset of jobs must have at least as many qualified workers.

    #colbreak()

    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $j_1$, tint: blue, name: <j1>),
        blob((1, 0), $j_2$, tint: blue, name: <j2>),
        blob((2, 0), $j_3$, tint: blue, name: <j3>),
        blob((0.5, 1), $w_1$, tint: green, name: <w1>),
        blob((1.5, 1), $w_2$, tint: green, name: <w2>),
        edge(<j1>, <w1>),
        edge(<j2>, <w1>),
        edge(<j2>, <w2>),
        edge(<j3>, <w2>),
      )
    ]
  ]
]

== Vertex and Edge Covers

#definition[
  A _vertex cover_ $R subset.eq V$ is a set of vertices such that every edge has at least one endpoint in $R$.
]

#definition[
  An _edge cover_ $F subset.eq E$ is a set of edges such that every vertex is incident to at least one edge in $F$.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: green, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: green, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Vertex cover* ${a, c}$
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>, stroke: 2pt + green),
          edge(<b>, <c>),
          edge(<c>, <d>, stroke: 2pt + green),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Edge cover* ${{a,b}, {c,d}}$
      ],
    )
  ]
]

== König's Theorem

#theorem[König's Theorem][
  In a bipartite graph, the size of a _maximum matching_ equals the size of a _minimum vertex cover_.
]

#Block(color: yellow)[
  *Note:* This equality does _not_ hold for general graphs!
]

#theorem[
  In any graph without isolated vertices:
  $ |"minimum vertex cover"| + |"maximum stable set"| = |V| $
  $ |"minimum edge cover"| + |"maximum matching"| = |V| $
]

== Stable Sets (Independent Sets)

#definition[
  A _stable set_ (or _independent set_) $S subset.eq V$ is a set of pairwise non-adjacent vertices.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), [], tint: green, name: <a>),
      blob((1, 0), [], tint: blue, name: <b>),
      blob((2, 0), [], tint: green, name: <c>),
      blob((0.5, 0.8), [], tint: blue, name: <d>),
      blob((1.5, 0.8), [], tint: blue, name: <e>),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<b>, <d>),
      edge(<b>, <e>),
      edge(<d>, <e>),
      edge(<a>, <d>),
      edge(<c>, <e>),
    )
  ]
]

The green vertices ${a, c}$ form a stable set --- no edges between them.

#Block(color: blue)[
  *Complement relationship:* $S$ is a stable set in $G$ $<==>$ $S$ is a clique in $overline(G)$.
]


= Connectivity Theory
#focus-slide()

== Cut Vertices and Bridges

#definition[
  A _cut vertex_ (or _articulation point_) is a vertex whose removal increases the number of connected components.
]

#definition[
  A _bridge_ is an edge whose removal increases the number of connected components.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), $a$, tint: blue, name: <a>),
      blob((1, 0), $b$, tint: red, name: <b>),
      blob((1.5, 0.8), $c$, tint: blue, name: <c>),
      blob((1.5, -0.8), $d$, tint: blue, name: <d>),
      blob((2.5, 0), $e$, tint: red, name: <e>),
      blob((3.5, 0), $f$, tint: blue, name: <f>),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<b>, <d>),
      edge(<c>, <d>),
      edge(<c>, <e>),
      edge(<d>, <e>),
      edge(<e>, <f>, stroke: 2pt + orange),
    )
  ]
]

- Cut vertices: $b$, $e$ (shown in red)
- Bridge: edge ${e, f}$ (shown in orange)

== Vertex and Edge Connectivity

#definition[
  - _Vertex connectivity_ $kappa(G)$: minimum number of vertices whose removal disconnects $G$ (or makes it trivial).
  - _Edge connectivity_ $lambda(G)$: minimum number of edges whose removal disconnects $G$.
]

#definition[
  A graph is _$k$-vertex-connected_ if $kappa(G) >= k$.

  A graph is _$k$-edge-connected_ if $lambda(G) >= k$.
]

#theorem[Whitney's Inequality][
  For any graph $G$:
  $ kappa(G) <= lambda(G) <= delta(G) $
  where $delta(G)$ is the minimum degree.
]

== Menger's Theorem

#theorem[Menger's Theorem (Vertex Version)][
  Let $G$ be a graph and $u, v$ be non-adjacent vertices. The minimum number of vertices whose removal destroys all $u$-$v$ paths equals the maximum number of _internally vertex-disjoint_ $u$-$v$ paths.
]

#theorem[Menger's Theorem (Edge Version)][
  The minimum number of edges whose removal destroys all $u$-$v$ paths equals the maximum number of _edge-disjoint_ $u$-$v$ paths.
]

#Block(color: yellow)[
  *Corollary:* A graph is $k$-vertex-connected iff any two vertices are connected by $k$ internally vertex-disjoint paths.
]

#Block(color: blue)[
  *Connection to flows:* Menger's theorem is equivalent to the Max-Flow Min-Cut theorem for unit capacities!
]

== Blocks and 2-Connected Components

#definition[
  A _block_ of a graph is a maximal 2-connected subgraph.
]

#note[
  - Every edge belongs to exactly one block
  - Blocks can share at most one vertex (a cut vertex)
  - The blocks of a graph form a tree-like structure
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Block 1 (triangle)
      blob((0, 0), [], tint: blue, name: <a>),
      blob((0.5, 0.8), [], tint: blue, name: <b>),
      blob((1, 0), [], tint: purple, name: <c>),
      edge(<a>, <b>, stroke: blue),
      edge(<b>, <c>, stroke: blue),
      edge(<c>, <a>, stroke: blue),
      // Block 2 (square)
      blob((2, 0), [], tint: green, name: <d>),
      blob((2, 1), [], tint: green, name: <e>),
      blob((3, 1), [], tint: green, name: <f>),
      blob((3, 0), [], tint: purple, name: <g>),
      edge(<c>, <d>, stroke: green),
      edge(<d>, <e>, stroke: green),
      edge(<e>, <f>, stroke: green),
      edge(<f>, <g>, stroke: green),
      edge(<g>, <c>, stroke: green),
      // Block 3 (edge)
      blob((4, 0.5), [], tint: orange, name: <h>),
      edge(<g>, <h>, stroke: orange),
    )
  ]
]

Three blocks: blue triangle, green pentagon, orange edge. Cut vertices shown in purple.


= Eulerian and Hamiltonian Graphs
#focus-slide()

== Eulerian Paths and Circuits

#definition[
  - An _Eulerian trail_ is a trail that visits every edge exactly once.
  - An _Eulerian circuit_ is a closed Eulerian trail.
  - A graph is _Eulerian_ if it has an Eulerian circuit.
]

#theorem[Euler's Theorem][
  A connected graph has an Eulerian circuit if and only if every vertex has _even degree_.

  A connected graph has an Eulerian trail (but not circuit) if and only if exactly _two vertices_ have odd degree.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
        )
        #v(0.3em)
        *Eulerian* \ (all degrees even)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: red, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: red, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
        #v(0.3em)
        *Has Eulerian trail* \ (2 odd vertices)
      ],
    )
  ]
]

== Hamiltonian Paths and Cycles

#definition[
  - A _Hamiltonian path_ visits every vertex exactly once.
  - A _Hamiltonian cycle_ is a cycle that visits every vertex exactly once.
  - A graph is _Hamiltonian_ if it has a Hamiltonian cycle.
]

#Block(color: orange)[
  *Warning:* Unlike Eulerian graphs, there is _no simple characterization_ of Hamiltonian graphs! Determining if a graph is Hamiltonian is NP-complete.
]

#theorem[Ore's Theorem][
  If $G$ has $n >= 3$ vertices and for every pair of non-adjacent vertices $u, v$:
  $ deg(u) + deg(v) >= n $
  then $G$ is Hamiltonian.
]

#theorem[Dirac's Theorem][
  If $G$ has $n >= 3$ vertices and $delta(G) >= n/2$, then $G$ is Hamiltonian.
]

== Eulerian vs Hamiltonian: Summary

#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    [], [*Eulerian*], [*Hamiltonian*],
    [Visits], [Every _edge_ once], [Every _vertex_ once],
    [Characterization], [Degree condition], [NP-complete to decide],
    [Algorithm], [$O(m)$ --- Hierholzer's], [Exponential (backtracking)],
    [Named after], [Euler (1736)], [Hamilton (1857)],
  )
]

#Block(color: teal)[
  *Historical note:* Hamilton sold a puzzle based on finding Hamiltonian cycles on a dodecahedron graph.
]


= Planar Graphs
#focus-slide()

== Planar Graphs: Definition

#definition[
  A graph is _planar_ if it can be drawn in the plane without edge crossings.

  A _plane graph_ is a specific planar embedding (drawing) of a planar graph.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <a>),
          blob((1, 0), [], tint: blue, name: <b>),
          blob((1, 1), [], tint: blue, name: <c>),
          blob((0, 1), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
          edge(<b>, <d>),
        )
        #v(0.3em)
        $K_4$ with crossings
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0.5, 0), [], tint: blue, name: <a>),
          blob((1, 0.5), [], tint: blue, name: <b>),
          blob((0.5, 1), [], tint: blue, name: <c>),
          blob((0, 0.5), [], tint: blue, name: <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
          edge(<b>, <d>),
        )
        #v(0.3em)
        $K_4$ planar embedding
      ],
    )
  ]
]

#Block(color: yellow)[
  $K_4$ is planar --- it can be redrawn without crossings.
]

== Faces and Euler's Formula

#definition[
  A _face_ of a plane graph is a connected region bounded by edges. The unbounded region is the _outer face_.
]

#theorem[Euler's Formula][
  For any connected plane graph with $v$ vertices, $e$ edges, and $f$ faces:
  $ v - e + f = 2 $
]

#example[
  #columns(2)[
    #import fletcher: diagram, edge, node
    #align(center)[
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), [], tint: blue, name: <a>),
        blob((1, 0), [], tint: blue, name: <b>),
        blob((1, 1), [], tint: blue, name: <c>),
        blob((0, 1), [], tint: blue, name: <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
      )
    ]

    #colbreak()

    - Vertices: $v = 4$
    - Edges: $e = 5$
    - Faces: $f = 3$ (2 inner + 1 outer)

    Check: $4 - 5 + 3 = 2$ ✓
  ]
]

== Consequences of Euler's Formula

#theorem[
  For any simple planar graph with $v >= 3$ vertices and $e$ edges:
  $ e <= 3v - 6 $
]

#proof[
  Each face has at least 3 edges on its boundary, and each edge borders at most 2 faces.
  So $3f <= 2e$, giving $f <= 2e/3$.

  By Euler's formula: $2 = v - e + f <= v - e + 2e/3 = v - e/3$.

  Therefore $e <= 3v - 6$.
]

#theorem[
  For any simple planar bipartite graph with $v >= 3$ vertices:
  $ e <= 2v - 4 $
]

#Block(color: yellow)[
  *Corollary:* $K_5$ and $K_(3,3)$ are _not_ planar.
]

== Kuratowski's Theorem

#theorem[Kuratowski's Theorem][
  A graph is planar if and only if it contains no subdivision of $K_5$ or $K_(3,3)$ as a subgraph.
]

#definition[
  A _subdivision_ of a graph $G$ is obtained by replacing edges with paths.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #grid(
      columns: 2,
      gutter: 3cm,
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0.5, 0), [], tint: red, name: <a>),
          blob((0, 0.75), [], tint: red, name: <b>),
          blob((0.25, 1.5), [], tint: red, name: <c>),
          blob((0.75, 1.5), [], tint: red, name: <d>),
          blob((1, 0.75), [], tint: red, name: <e>),
          edge(<a>, <b>),
          edge(<a>, <c>),
          edge(<a>, <d>),
          edge(<a>, <e>),
          edge(<b>, <c>),
          edge(<b>, <d>),
          edge(<b>, <e>),
          edge(<c>, <d>),
          edge(<c>, <e>),
          edge(<d>, <e>),
        )
        #v(0.3em)
        $K_5$ (not planar)
      ],
      [
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          blob((0, 0), [], tint: blue, name: <x1>),
          blob((1, 0), [], tint: blue, name: <x2>),
          blob((2, 0), [], tint: blue, name: <x3>),
          blob((0, 1), [], tint: green, name: <y1>),
          blob((1, 1), [], tint: green, name: <y2>),
          blob((2, 1), [], tint: green, name: <y3>),
          edge(<x1>, <y1>),
          edge(<x1>, <y2>),
          edge(<x1>, <y3>),
          edge(<x2>, <y1>),
          edge(<x2>, <y2>),
          edge(<x2>, <y3>),
          edge(<x3>, <y1>),
          edge(<x3>, <y2>),
          edge(<x3>, <y3>),
        )
        #v(0.3em)
        $K_(3,3)$ (not planar)
      ],
    )
  ]
]


= Graph Coloring
#focus-slide()

== Vertex Coloring

#definition[
  A _(proper) vertex coloring_ of a graph assigns colors to vertices such that adjacent vertices receive different colors.
]

#definition[
  A graph is _$k$-colorable_ if it has a proper coloring using at most $k$ colors.

  The _chromatic number_ $chi(G)$ is the minimum $k$ such that $G$ is $k$-colorable.
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), [], tint: red, name: <a>),
      blob((1, 0), [], tint: blue, name: <b>),
      blob((2, 0), [], tint: red, name: <c>),
      blob((0.5, 0.8), [], tint: green, name: <d>),
      blob((1.5, 0.8), [], tint: green, name: <e>),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<a>, <d>),
      edge(<d>, <b>),
      edge(<b>, <e>),
      edge(<e>, <c>),
      edge(<d>, <e>),
    )
  ]
]

This graph is 3-colorable. Is $chi(G) = 3$?

== Chromatic Number: Bounds

#theorem[
  For any graph $G$:
  $ omega(G) <= chi(G) <= Delta(G) + 1 $
  where $omega(G)$ is the size of the largest clique and $Delta(G)$ is the maximum degree.
]

#theorem[Brooks' Theorem][
  For any connected graph $G$ that is not a complete graph or an odd cycle:
  $ chi(G) <= Delta(G) $
]

#Block(color: yellow)[
  *Note:* Computing $chi(G)$ is NP-hard, but 2-colorability (bipartiteness) can be checked in polynomial time.
]

== The Four Color Theorem

#theorem[Four Color Theorem][
  Every planar graph is 4-colorable.
]

#Block(color: teal)[
  *Historical note:*
  - Conjectured in 1852 by Francis Guthrie
  - Proved in 1976 by Appel and Haken using a computer
  - First major theorem proved with computer assistance
  - The proof checked ~1,500 configurations!
]

#Block(color: blue)[
  *Application:* Any map can be colored with 4 colors such that no adjacent regions share a color.
]

== Edge Coloring

#definition[
  An _edge coloring_ assigns colors to edges such that edges sharing a vertex receive different colors.

  The _chromatic index_ $chi'(G)$ is the minimum number of colors needed.
]

#theorem[Vizing's Theorem][
  For any simple graph $G$:
  $ Delta(G) <= chi'(G) <= Delta(G) + 1 $
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), [], tint: blue, name: <a>),
      blob((0.5, 0.87), [], tint: blue, name: <b>),
      blob((1, 0), [], tint: blue, name: <c>),
      edge(<a>, <b>, stroke: 2pt + red),
      edge(<b>, <c>, stroke: 2pt + green),
      edge(<c>, <a>, stroke: 2pt + blue),
    )
  ]
]

Triangle $K_3$ needs 3 colors: $chi'(K_3) = 3 = Delta + 1$.


= Cliques and Stable Sets
#focus-slide()

== Cliques

#definition[
  A _clique_ is a subset of vertices $Q subset.eq V$ such that every pair of vertices in $Q$ is adjacent.

  Equivalently, $Q$ induces a complete subgraph.
]

#definition[
  - _Clique number_ $omega(G)$: size of the largest clique
  - A clique is _maximal_ if no vertex can be added
  - A clique is _maximum_ if it has the largest possible size
]

#example[
  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      blob((0, 0), [], tint: green, name: <a>),
      blob((1, 0), [], tint: green, name: <b>),
      blob((0.5, 0.8), [], tint: green, name: <c>),
      blob((2, 0), [], tint: blue, name: <d>),
      blob((1.5, 0.8), [], tint: blue, name: <e>),
      edge(<a>, <b>, stroke: 2pt + green),
      edge(<b>, <c>, stroke: 2pt + green),
      edge(<c>, <a>, stroke: 2pt + green),
      edge(<b>, <d>),
      edge(<b>, <e>),
      edge(<d>, <e>),
      edge(<c>, <e>),
    )
  ]
]

Maximum clique ${a, b, c}$ shown in green. $omega(G) = 3$.

== Ramsey Theory: A Taste

#theorem[Ramsey's Theorem (simplified)][
  For any positive integers $r$ and $s$, there exists a number $R(r, s)$ such that any 2-coloring of the edges of $K_n$ (with $n >= R(r, s)$) contains either a red $K_r$ or a blue $K_s$.
]

#example[
  $R(3, 3) = 6$: Among any 6 people, there are either 3 mutual friends or 3 mutual strangers.
]

#Block(color: orange)[
  *Warning:* Computing Ramsey numbers is extremely hard. We know $R(3,3) = 6$, $R(4,4) = 18$, but $R(5,5)$ is unknown!

  Famous quote by Erdős: "Suppose aliens invade the earth and threaten to obliterate it in a year's time unless human beings can find $R(5,5)$. We could marshal the world's best minds and fastest computers, and within a year we could probably calculate the value. If they digit$R(6,6)$, we would have no choice but to launch a preemptive attack."
]


= Summary and Connections
#focus-slide()

== Graph Theory: Key Concepts

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Structural properties:*
    - Degree, adjacency, incidence
    - Paths, cycles, connectivity
    - Trees, spanning trees
    - Bipartiteness
    - Planarity
  ],
  [
    *Optimization problems:*
    - Matchings (Hall, König)
    - Vertex/edge covers
    - Coloring (chromatic number)
    - Cliques and stable sets
    - Connectivity (Menger)
  ],
)

#Block(color: yellow)[
  *Key theorems to remember:*
  - Handshaking lemma: $sum deg(v) = 2|E|$
  - Euler's formula: $v - e + f = 2$
  - Hall's marriage theorem
  - Menger's theorem
  - Four color theorem
]

== What's Next: Flow Networks

#Block(color: blue)[
  *Coming up:* Network flows generalize many graph concepts:
  - Maximum matchings $arrow.r$ maximum flow
  - Menger's theorem $arrow.r$ max-flow min-cut
  - Hall's theorem $arrow.r$ flow feasibility
]

Graph theory provides the foundation for:
- Algorithms (BFS, DFS, shortest paths)
- Network design and optimization
- Formal language theory (automata are labeled graphs!)
- Combinatorics and counting


== Exercises

+ Prove that every tree with $n >= 2$ vertices has at least 2 leaves.
+ Show that the Petersen graph is not planar.
+ Find the chromatic number of $C_n$ for all $n >= 3$.
+ Prove König's theorem using Hall's theorem.
+ For which values of $n$ does $K_n$ have an Eulerian circuit?
+ Find all graphs $G$ with $kappa(G) = lambda(G) = delta(G)$.
+ Prove that every 2-connected graph has no cut vertices.
+ Show that a graph is bipartite iff it has no odd cycles.
