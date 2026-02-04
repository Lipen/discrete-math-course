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
#let dist = math.op("dist")
#let diam = math.op("diam")
#let rad = math.op("rad")
#let girth = math.op("girth")
#let Center = math.op("center")
#let ecc = math.op("ecc")
#let Adj = math.op("Adj")


#CourseOverviewPage2()


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
  *The power of abstraction:* By stripping away irrelevant details, graphs let us see the _structure_ of a problem. The same algorithm that finds the shortest route between cities also finds the fastest path in a game tree or the most efficient way to schedule tasks.
]

== The Seven Bridges of Königsberg

#columns(2)[
  In 1736, Leonhard Euler solved a famous puzzle:

  _Can one walk through the city of Königsberg, crossing each of its seven bridges exactly once?_

  #v(0.5em)

  Euler proved this is _impossible_ --- and in doing so, invented graph theory.

  #colbreak()

  #align(center)[
    #import fletcher: diagram, edge, node, shapes
    #let vertex(pos, label, name) = blob(
      pos,
      label,
      tint: blue,
      shape: shapes.circle,
      radius: 1em,
      name: name,
    )
    #diagram(
      spacing: (1.5cm, 1cm),
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), $A$, <a>),
      vertex((2, 0), $B$, <b>),
      vertex((1, -1), $C$, <c>),
      vertex((1, 1), $D$, <d>),
      edge(<a>, <b>),
      edge(<a>, <c>, bend: 30deg),
      edge(<a>, <c>, bend: -20deg),
      edge(<a>, <d>, bend: 20deg),
      edge(<a>, <d>, bend: -30deg),
      edge(<b>, <c>),
      edge(<b>, <d>),
    )
  ]
]

#Block(color: teal)[
  *Historical note:* This problem marks the birth of _topology_ and _graph theory_ as mathematical disciplines.
]


= Basic Definitions
#focus-slide()

== What is a Graph?

#Block(color: yellow)[
  *Graphs as models:* Graphs are _mathematical abstractions_ for modeling relationships, connections, and structures. Different kinds of relationships lead to different types of graphs.
]

#definition[Abstract Approach][
  A _graph_ is fundamentally a triple $G = (V, E, F)$, where:
  - $V = {v_1, v_2, ...}$ is a finite set of _abstract vertices_ (unique objects)
  - $E = {e_1, e_2, ...}$ is a finite set of _abstract edges_ (connections)
  - $F$ is a collection of _functions_ that capture the graph's structure and semantics
]

#Block(color: blue)[
  *The power of abstraction:* Vertices and edges are just _labels_ --- the functions $F$ define _all_ the meaning:
  - For _undirected_ graphs: $F = {"ends": E to binom(V, 2)}$ maps each edge to its two endpoints
  - For _directed_ graphs: $F = {"begin": E to V, "end": E to V}$ specify source and target
  - For _weighted_ graphs: add $"weight": E to RR$
  - For _hypergraphs:_ $"incidence": E to 2^V$ maps edges to _subsets_ of vertices
  - For _vertex-labeled_ graphs: add $"label": V to Sigma$ for some alphabet $Sigma$
]

#note(title: "Notation")[
  - $V(G)$ denotes the vertex set of graph $G$
  - $E(G)$ denotes the edge set of graph $G$
  - $|V(G)|$ is the _order_ of $G$ (number of vertices)
  - $|E(G)|$ is the _size_ of $G$ (number of edges)
]

#Block(color: teal)[
  *Bonus:* This abstract approach handles _multigraphs_ (parallel edges) and _loops_ naturally --- multiple edges in $E$ can map to the same endpoint pair, and a loop edge maps to a singleton set ${v}$ or has $"begin"(e) = "end"(e) = v$.
]

== Structural Representation (Alternative Approach)

#definition[Structural Approach][
  Instead of abstract edges + functions, we can _encode structure directly_ into the edge definition:
  - _Undirected:_ $E subset.eq binom(V, 2)$ (unordered pairs ${u, v}$)
  - _Directed:_ $E subset.eq V times V$ (ordered pairs $(u, v)$)
  - _Weighted:_ $E subset.eq V times V times RR$ (triples $(u, v, w)$)
  - _Loops:_ Include singletons ${v}$ in $E$ or allow $(v, v)$
]

#v(1fr, weak: true)

#Block(color: orange)[
  *Trade-offs:*
  - _Pros:_ Simpler for basic graphs; closer to programming impl (edge lists, adjacency matrices)
  - _Cons:_ Less flexible; need ad-hoc extensions for weighted graphs, hypergraphs, attributes; mixing structure with semantics
]

#v(1fr, weak: true)

#Block(color: green)[
  *In practice:* For this course, we'll mostly use the _structural representation_ for simplicity, but keep the _abstract view_ in mind --- it explains why we can freely add weights, directions, labels, etc.
]

== Undirected vs Directed Graphs

#[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )

  #grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    [
      #definition[Undirected Graph][
        In an _undirected graph_, edges are _unordered pairs_:
        $ E subset.eq binom(V, 2) = { {u, v} | u, v in V, u != v } $
      ]

      The edge ${u, v}$ connects $u$ and $v$ symmetrically.

      #align(center)[
        #grid(
          columns: 2,
          align: horizon,
          column-gutter: 1.5em,
          row-gutter: 1em,
          diagram(
            spacing: 2em,
            node-stroke: 1pt,
            edge-stroke: 1pt,
            vertex((0, 0), $a$, <a>),
            vertex((1, 0), $b$, <b>),
            vertex((0, 1), $c$, <c>),
            vertex((1, 1), $d$, <d>),
            edge(<a>, <b>),
            edge(<b>, <d>),
            edge(<d>, <c>),
            edge(<c>, <a>),
          ),
          [*Undirected*],
        )
      ]

      #Block(color: blue)[
        *Models:* Mutual relationships (friendships, two-way roads, chemical bonds)
      ]
    ],
    [
      #definition[Directed Graph][
        In a _directed graph_ (digraph), edges are _ordered pairs_:
        $ E subset.eq V times V $
      ]

      The edge $(u, v)$ goes _from_ $u$ _to_ $v$.

      #align(center)[
        #grid(
          columns: 2,
          align: horizon,
          column-gutter: 2em,
          row-gutter: 1em,
          diagram(
            spacing: 2em,
            node-stroke: 1pt,
            edge-stroke: 1pt,
            vertex((0, 0), $a$, <a>),
            vertex((1, 0), $b$, <b>),
            vertex((0, 1), $c$, <c>),
            vertex((1, 1), $d$, <d>),
            edge(<a>, <b>, "-}>"),
            edge(<b>, <d>, "-}>"),
            edge(<c>, <d>, "-}>"),
            edge(<c>, <a>, "-}>"),
          ),
          [*Directed*],
        )
      ]

      #Block(color: blue)[
        *Models:* One-way relationships (follows, #box[one-way] streets, dependencies, function calls)
      ]
    ],
  )
]

== Simple Graphs, Multigraphs, and Pseudographs

#grid(
  columns: 2,
  align: (left, center),
  column-gutter: 1em,
  [
    #definition[
      - A _simple graph_ has no _loops_ (edges from a vertex to itself) and no _multi-edges_ (multiple edges between the same pair of vertices).
      - A _multigraph_ allows _multi-edges_ but no loops.
      - A _pseudograph_ allows both loops and multi-edges.
    ]

    #Block(color: teal)[
      *Abstract view:* In the function-based approach, these distinctions are natural:
      - _Simple:_ the "ends" function is _injective_ (different edges → different endpoint pairs)
      - _Multigraph:_ "ends" can be non-injective; multiple edges map to the same ${u, v}$
      - _Loops:_ "ends" can map an edge to a singleton ${v}$ (or begin$(e)$ = end$(e)$)
    ]

    #note[
      Unless otherwise stated, "graph" means _simple undirected graph_ in this course.
    ]
  ],
  [
    #align(center)[
      #import fletcher: diagram, edge, node, shapes
      #let vertex(pos, label, name) = blob(
        pos,
        label,
        tint: blue,
        shape: shapes.circle,
        radius: .8em,
        name: name,
      )
      #let data = (
        (
          diagram(
            spacing: 1.5em,
            node-stroke: 1pt,
            edge-stroke: 1pt,
            vertex((0, 0), $a$, <a>),
            vertex((1, 0), $b$, <b>),
            vertex((0.5, calc.cos(30deg)), $c$, <c>),
            edge(<a>, <b>),
            edge(<b>, <c>),
            edge(<c>, <a>),
          ),
          [*Simple*],
        ),
        (
          diagram(
            spacing: 1.5em,
            node-stroke: 1pt,
            edge-stroke: 1pt,
            vertex((0, 0), $a$, <a>),
            vertex((1, 0), $b$, <b>),
            vertex((0.5, calc.cos(30deg)), $c$, <c>),
            edge(<a>, <b>, bend: 30deg),
            edge(<a>, <b>, bend: -30deg),
            edge(<b>, <c>),
            edge(<c>, <a>),
          ),
          [*Multigraph*],
        ),
        (
          diagram(
            spacing: 1.5em,
            node-stroke: 1pt,
            edge-stroke: 1pt,
            vertex((0, 0), $a$, <a>),
            vertex((1, 0), $b$, <b>),
            vertex((0.5, calc.cos(30deg)), $c$, <c>),
            edge(<a>, <b>),
            edge(<b>, <c>),
            edge(<c>, <a>),
            edge(<c>, <c>, "-}>", bend: 130deg, loop-angle: 0deg),
          ),
          [*Pseudograph*],
        ),
      )
      #grid(
        columns: 1,
        row-gutter: 1em,
        ..data.flatten()
      )
    ]
  ],
)

== Special Graphs

#definition[
  - _Null graph_: no vertices ($V = emptyset$)
  - _Trivial graph_: single vertex, no edges ($|V| = 1$, $E = emptyset$)
  - _Empty graph_ $overline(K)_n$: $n$ vertices, no edges
  - _Complete graph_ $K_n$: $n$ vertices, all pairs connected
  - _Cycle_ $C_n$: $n$ vertices in a cycle
  - _Path_ $P_n$: $n$ vertices in a line
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, ..args) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 4pt,
    name: name,
    ..args,
  )
  #let data = (
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((0, 1), <c>),
        vertex((1, 1), <d>),
      ),
      [$overline(K)_4$ (empty)],
    ),
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((1, 1), <c>),
        vertex((0, 1), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
        edge(<b>, <d>),
      ),
      [$K_4$ (complete)],
    ),
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((1, 1), <c>),
        vertex((0, 1), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
      [$C_4$ (cycle)],
    ),
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((0.8, 0), <b>),
        vertex((1.6, 0), <c>),
        vertex((2.4, 0), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
      ),
      [$P_4$ (path)],
    ),
  )
  #align(center)[
    #v(-1.5em)
    #grid(
      columns: data.len(),
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

#theorem[
  The complete graph $K_n$ has exactly $binom(n, 2) = (n(n-1))/2$ edges.
]

== Adjacency and Incidence

#definition[
  - Two vertices $u$ and $v$ are _adjacent_ if there is an edge between them: ${u, v} in E$.
  - An edge $e$ is _incident_ to vertex $v$ if $v$ is an endpoint of $e$.
  - The _neighborhood_ of $v$ is $N(v) = { u in V | {u, v} in E }$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #align(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 4em,
      row-gutter: 1em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        blob((0, 0), $a$, tint: blue, shape: shapes.circle, name: <a>),
        blob((1, 0), $b$, tint: green, shape: shapes.circle, name: <b>),
        blob((2, 0), $c$, tint: blue, shape: shapes.circle, name: <c>),
        blob((0.5, calc.cos(30deg)), $d$, tint: green, shape: shapes.circle, name: <d>),
        blob((1.5, calc.cos(30deg)), $e$, tint: green, shape: shapes.circle, name: <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<d>, <e>),
      ),
      [
        - $a$ and $b$ are _adjacent_
        - $a$ and $c$ are _not adjacent_
        - Edge ${a, b}$ is _incident_ to $a$ and $b$
        - $N(b) = {a, c, d, e}$
      ],
    )
  ]
]

== Degree of a Vertex

#definition[
  The _degree_ of a vertex $v$, denoted $deg(v)$, is the number of edges incident to $v$.
  - $delta(G) = min_(v in V) deg(v)$ is the _minimum degree_
  - $Delta(G) = max_(v in V) deg(v)$ is the _maximum degree_
]

#theorem[Handshaking Lemma][
  For any graph $G = pair(V, E)$:
  $ sum_(v in V) deg(v) = 2 |E| $
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .9em,
    name: name,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      row-gutter: 1em,
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>),
        vertex((1, 0), $b$, <b>),
        vertex((2, 0), $c$, <c>),
        vertex((0.5, calc.cos(30deg)), $d$, <d>),
        vertex((1.5, calc.cos(30deg)), $e$, <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<d>, <e>),
      ),
      [
        Degrees: $deg(a) = 1$, $deg(b) = 4$, $deg(c) = 1$, $deg(d) = 2$, $deg(e) = 2$

        Degree sequence: $(4, 2, 2, 1, 1)$
      ],
    )
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, ..args) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 4pt,
    name: name,
    ..args,
  )
  #let h = 1
  #let tr = h * 2 / 3
  #let pr = h / (1 + calc.cos(calc.pi / 5))
  #let data = (
    (
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((0, h), <b>),
        vertex((h, h), <c>),
        vertex((h, 0), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
      [*2-regular* \ (cycle $C_4$)],
    ),
    (
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((0, h), <b>),
        vertex((h, h), <c>),
        vertex((h, 0), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
        edge(<b>, <d>),
      ),
      [*3-regular* \ (complete $K_4$)],
    ),
    (
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-90deg + 360deg / 5 * 0, pr), <a>),
        vertex((-90deg + 360deg / 5 * 1, pr), <b>),
        vertex((-90deg + 360deg / 5 * 2, pr), <c>),
        vertex((-90deg + 360deg / 5 * 3, pr), <d>),
        vertex((-90deg + 360deg / 5 * 4, pr), <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <e>),
        edge(<e>, <a>),
      ),
      [*2-regular* \ (cycle $C_5$)],
    ),
    (
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-90deg + 360deg / 3 * 0, tr), <a>),
        vertex((-90deg + 360deg / 3 * 1, tr), <b>),
        vertex((-90deg + 360deg / 3 * 2, tr), <c>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
      ),
      [*2-regular* \ (complete $K_3$)],
    ),
  )
  #align(center)[
    #grid(
      columns: data.len(),
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 2em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Graph Representations: Adjacency Matrix

#definition[
  The _adjacency matrix_ $A$ of a graph $G$ with $n$ vertices is an $n times n$ matrix where:
  $ A_(i j) = cases(1 & "if" {v_i, v_j} in E, 0 & "otherwise") $
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: center + horizon,
      column-gutter: 4em,
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $1$, <1>),
        vertex((1, 0), $2$, <2>),
        vertex((1, 1), $3$, <3>),
        vertex((0, 1), $4$, <4>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <1>),
        edge(<1>, <3>),
      ),
      $
        A = mat(
          0, 1, 1, 1;
          1, 0, 1, 0;
          1, 1, 0, 1;
          1, 0, 1, 0;
        )
      $,
    )
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: center + horizon,
      column-gutter: 4em,
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $1$, <1>),
        vertex((1, 0), $2$, <2>),
        vertex((1, 1), $3$, <3>),
        vertex((0, 1), $4$, <4>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <1>),
        edge(<1>, <3>),
      ),
      table(
        columns: 2,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
        [*Vertex*], [*Neighbors*],
        [$1$], [$2, 3, 4$],
        [$2$], [$1, 3$],
        [$3$], [$1, 2, 4$],
        [$4$], [$1, 3$],
      ),
    )
  ]
]

#Block(color: blue)[
  *Space complexity:* Adjacency matrix uses $O(n^2)$, adjacency list uses $O(n + m)$ where $m = |E|$.
]

== Subgraphs

#definition[
  A graph $H = pair(V', E')$ is a _subgraph_ of $G = pair(V, E)$, denoted $H subset.eq G$, if
  $
    V' subset.eq V quad "and" quad E' subset.eq E
  $
]

#definition[
  - A _spanning subgraph_ includes all vertices: $V' = V$.
  - An _induced subgraph_ $G[S]$ on vertex set $S subset.eq V$ includes all edges between vertices in $S$:
    $ E' = { {u, v} in E | u, v in S } $
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #let data = (
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>),
        vertex((1, 0), $b$, <b>),
        vertex((1, 1), $c$, <c>),
        vertex((0, 1), $d$, <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
      ),
      [*Original $G$*],
    ),
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>),
        vertex((1, 0), $b$, <b>),
        vertex((1, 1), $c$, <c>),
        vertex((0, 1), $d$, <d>),
        edge(<a>, <b>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
      [*Spanning subgraph*],
    ),
    (
      diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>),
        vertex((1, 0), $b$, <b>),
        vertex((1, 1), $c$, <c>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<a>, <c>),
      ),
      [*Induced $G[{a,b,c}]$*],
    ),
  )
  #place(center)[
    #grid(
      columns: data.len(),
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 4em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Graph Isomorphism

#definition[
  Graphs $G_1 = pair(V_1, E_1)$ and $G_2 = pair(V_2, E_2)$ are _isomorphic_, written $G_1 tilde.eq G_2$, if there exists a bijection $phi: V_1 -> V_2$ that _preserves adjacency_:
  $
    {u, v} in E_1 quad iff quad {phi(u), phi(v)} in E_2
  $
]

#Block(color: blue)[
  *Intuition:*
  Isomorphic graphs are "the same graph" with different vertex labels.
  They have identical structure.
]

#pagebreak()

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: horizon,
      column-gutter: 2cm,
      diagram(
        spacing: 3em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $1$, <1>),
        vertex((1, 0), $2$, <2>),
        vertex((1, 1), $3$, <3>),
        vertex((0, 1), $4$, <4>),
        edge(<1>, <2>),
        edge(<2>, <3>),
        edge(<3>, <4>),
        edge(<4>, <1>),
      ),
      diagram(
        spacing: 1em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-1, 0), $a$, <a>),
        vertex((0, -1), $b$, <b>),
        vertex((1, 0), $c$, <c>),
        vertex((0, 1), $d$, <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
    )
  ]
]

Both graphs are isomorphic to $C_4$. The bijection $phi: 1 |-> a, 2 |-> b, 3 |-> c, 4 |-> d$ preserves adjacency.

#Block(color: orange)[
  *Computational mystery:*
  Graph isomorphism is in NP but _not known_ to be NP-complete or in P.

  In~2015, Babai showed it's in _quasipolynomial time_ --- a major breakthrough, but the exact complexity remains open.
]

== Summary: Graph Basics

#grid(
  columns: 2,
  column-gutter: 1em,
  row-gutter: 1em,
  [
    #Block(color: blue, width: 100%)[
      *Core concepts:*
      - A _graph_ $G = (V, E)$ is a pair of vertices and edges connecting them
      - _Directed_ vs _undirected_; _simple_ graphs vs _multigraphs_ vs _pseudographs_
      - _Degree_ $deg(v)$ counts edges incident to $v$; Handshaking Lemma: $sum deg(v) = 2|E|$
      - _Special graphs:_ Complete $K_n$, cycle $C_n$, path~$P_n$, bipartite $K_(m,n)$, hypercube $Q_n$
    ]
    #Block(color: teal, width: 100%)[
      *Coming up:* Paths, connectivity, trees, bipartite graphs, matchings, Eulerian and Hamiltonian cycles, planarity, and coloring.
    ]
  ],
  [
    #Block(color: green, width: 100%)[
      *Graph representations:*
      - _Adjacency matrix:_ $n times n$ matrix, good for dense graphs, $O(n^2)$ space
      - _Adjacency list:_ list of neighbors per vertex, good for sparse graphs, $O(n + m)$ space
    ]
    #Block(color: yellow, width: 100%)[
      *Structural concepts:*
      - _Subgraph:_ subset of vertices/edges; _induced subgraph:_ includes all edges between chosen vertices
      - _Graph isomorphism:_ bijection preserving adjacency --- graphs are "the same" up to relabeling
    ]
  ],
)


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
    [Walk], [Yes #YES], [Yes #YES], [Closed walk],
    [Trail], [Yes #YES], [No #NO], [Circuit],
    [Path], [No #NO], [No #NO], [Cycle],
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>),
        vertex((1, 0), $b$, <b>),
        vertex((2, 0), $c$, <c>),
        vertex((0.5, 0.8), $d$, <d>),
        vertex((1.5, 0.8), $e$, <e>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<a>, <d>),
        edge(<d>, <e>),
        edge(<e>, <c>),
        edge(<b>, <d>),
      ),
      [
        - $dist(a, b) = 1$
        - $dist(a, c) = 2$
        - $dist(a, e) = 2$
        - Path $a$-$b$-$c$ has length 2
        - Trail $a$-$d$-$b$-$c$-$e$-$d$ has length 5
      ],
    )
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, ..args) = blob(
    pos,
    label,
    radius: 1em,
    name: name,
    ..args,
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, tint: blue),
        vertex((1, 0), $b$, <b>, tint: green),
        vertex((2, 0), $c$, <c>, tint: green),
        vertex((3, 0), $d$, <d>, tint: blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
      ),
      [
        Path graph $P_4$:
        - $ecc(a) = ecc(d) = 3$
        - $ecc(b) = ecc(c) = 2$
        - $rad(G) = 2$, $diam(G) = 3$
        - $Center(G) = {b, c}$
      ],
    )
  ]
]

#theorem[
  For any connected graph $G$: $rad(G) <= diam(G) <= 2 dot rad(G)$
]

== Connectivity

#definition[
  Two vertices $u$ and $v$ in an undirected graph $G$ are _connected_ if $G$ contains a path from $u$ to $v$. Otherwise, they are _disconnected_.
]

#definition[
  A graph $G$ is _connected_ if every pair of vertices in $G$ is connected (i.e., there exists a path between any two vertices).

  A graph that is not connected is called _disconnected_.
]

#note[
  - A graph with a single vertex is connected (vacuously).
  - An edgeless graph with two or more vertices is disconnected.
]

== Connected Components

#definition[
  A _connected component_ of $G$ is a maximal connected subgraph.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Component 1
      vertex((0, 0), $a$, <a>, blue),
      vertex((1, 0), $b$, <b>, blue),
      vertex((0.5, calc.cos(30deg)), $c$, <c>, blue),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<c>, <a>),
      // Component 2
      vertex((2.5, calc.cos(30deg) / 2), $d$, <d>, green),
      vertex((3.5, calc.cos(30deg) / 2), $e$, <e>, green),
      edge(<d>, <e>),
      // Component 3
      vertex((5, calc.cos(30deg) / 2), $f$, <f>, orange),
    )
  ]
]

This graph has 3 connected components: ${a, b, c}$, ${d, e}$, and ${f}$.

#Block(color: yellow)[
  *Key insight:* "Being in the same connected component" is an _equivalence relation_ on vertices.
]

== Connectivity in Directed Graphs

#definition[
  A directed graph $G$ is:
  - *Weakly connected* if replacing all directed edges with undirected produces a connected graph.
  - *Unilaterally connected* (or _semiconnected_) if for every pair of vertices $u, v$, there is a directed path from $u$ to $v$ _or_ from $v$ to $u$ (or both).
  - *Strongly connected* if for every pair of vertices $u, v$, there is a directed path from $u$ to $v$ _and_ from $v$~to~$u$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, green),
        vertex((1, 0), $b$, <b>, green),
        vertex((0.5, 0.8), $c$, <c>, green),
        edge(<a>, <b>, "->"),
        edge(<b>, <c>, "->"),
        edge(<c>, <a>, "->"),
      ),
      [*Strongly connected* \ $a -> b -> c -> a$],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((0.5, 0.8), $c$, <c>, blue),
        edge(<a>, <b>, "->"),
        edge(<a>, <c>, "->"),
        edge(<b>, <c>, "->"),
      ),
      [*Unilaterally connected* \ $a -> b$, $a -> c$, $b -> c$],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, orange),
        vertex((1, 0), $b$, <b>, orange),
        vertex((0.5, 0.8), $c$, <c>, orange),
        edge(<a>, <b>, "->"),
        edge(<c>, <b>, "->"),
      ),
      [*Weakly connected* \ No path $a arrow.squiggly c$],
    ),
  )
  #place(center)[
    #grid(
      columns: 3,
      column-gutter: 2em,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Strongly Connected Components

#definition[
  A _strongly connected component_ (SCC) of a digraph is a maximal strongly connected subgraph.
]

#Block(color: blue)[
  *Condensation graph:* If we contract each SCC to a single vertex, the result is a DAG (directed acyclic graph). This is called the _condensation_ of $G$.
]

#Block(color: teal)[
  *Algorithms:* SCCs can be found in $O(n + m)$ time using Kosaraju's algorithm or Tarjan's algorithm (both based on DFS).
]

== Girth

#definition[
  The _girth_ of a graph $G$ is the length of the shortest cycle in $G$.

  If $G$ has no cycles (is acyclic), we say $girth(G) = infinity$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((0.5, calc.cos(30deg)), <b>),
        vertex((1, 0), <c>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
      ),
      [*$girth(K_3) = 3$*],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((1, 1), <c>),
        vertex((0, 1), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
      [*$girth(C_4) = 4$*],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((0.7, 0), <b>),
        vertex((1.4, 0), <c>),
        vertex((2.1, 0), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
      ),
      [*$girth(P_4) = infinity$*],
    ),
  )
  #align(center)[
    #grid(
      columns: 3,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 4em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        spacing: (1cm, 0.8cm),
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((1, 0), <root>),
        vertex((0, 1), <l>),
        vertex((2, 1), <r>),
        vertex((-0.3, 2), <ll>),
        vertex((0.5, 2), <lr>),
        vertex((1.7, 2), <rl>),
        vertex((2.3, 2), <rr>),
        edge(<root>, <l>),
        edge(<root>, <r>),
        edge(<l>, <ll>),
        edge(<l>, <lr>),
        edge(<r>, <rl>),
        edge(<r>, <rr>),
      ),
      [*A tree*],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        // Tree 1
        vertex((0, 0), <a>),
        vertex((-0.4, 1), <b>),
        vertex((0.4, 1), <c>),
        edge(<a>, <b>),
        edge(<a>, <c>),
        // Tree 2
        vertex((1.1, 0.5), <d>),
        vertex((1.9, 0.5), <e>),
        edge(<d>, <e>),
        // Tree 3
        vertex((3, 0.5), <f>),
      ),
      [*A forest (3 trees)*],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Characterizations of Trees

#theorem[
  For a graph $G$ with $n$ vertices, the following are equivalent:
  + $G$ is a tree (connected and acyclic)
  + $G$ is connected with exactly $n - 1$ edges
  + $G$ is acyclic with exactly $n - 1$ edges
  + Any two vertices are connected by a _unique path_
  + $G$ is _minimally connected_: removing any edge disconnects it
  + $G$ is _maximally acyclic_: adding any edge creates a cycle
]

#Block(color: yellow)[
  *Why trees matter?*
  Trees appear everywhere --- file systems, parse trees, decision trees, spanning trees for network design.
  Their simple structure makes them amenable to recursive algorithms.
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint, ..args) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
    ..args,
  )
  #place(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      diagram(
        spacing: (2em, 1.5em),
        node-stroke: 1pt,
        edge-stroke: 1pt,
        node-corner-radius: 3pt,
        vertex((1, 0), [root], <root>, red, shape: shapes.rect, width: 2.5em, radius: auto),
        vertex((0, 1), $a$, <a>, blue),
        vertex((2, 1), $b$, <b>, blue),
        vertex((-0.5, 2), $c$, <c>, green),
        vertex((0.5, 2), $d$, <d>, green),
        vertex((2, 2), $e$, <e>, green),
        edge(<root>, <a>),
        edge(<root>, <b>),
        edge(<a>, <c>),
        edge(<a>, <d>),
        edge(<b>, <e>),
      ),
      [
        - #Red[Root] has children $a, b$
        - #Green[Leaves]: $c, d, e$
        - #Blue[Internal] vertices: root, $a, b$
      ],
    )
  ]
]

== Spanning Trees

#definition[
  A _spanning tree_ of a connected graph $G$ is a spanning subgraph that is a tree.
]

#theorem[
  Every connected graph has at least one spanning tree.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name) = blob(
    pos,
    label,
    tint: blue,
    shape: shapes.circle,
    radius: 0.8em,
    name: name,
  )
  #let h = 1.5cm
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0cm, 0cm), $a$, <a>),
        vertex((h, 0cm), $b$, <b>),
        vertex((h, h), $c$, <c>),
        vertex((0cm, h), $d$, <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
      ),
      [*Original graph*],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0cm, 0cm), $a$, <a>),
        vertex((h, 0cm), $b$, <b>),
        vertex((h, h), $c$, <c>),
        vertex((0cm, h), $d$, <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
      ),
      [*A spanning tree*],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      column-gutter: 3em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

#Block(color: blue)[
  *Application:* Finding minimum spanning trees (MST) is fundamental in network design.
]

== Cayley's Formula

#theorem[Cayley's Formula][
  The number of _labeled_ trees on $n$ vertices is exactly $n^(n-2)$.
]

#example[
  - $n = 2$: $2^0 = 1$ tree (just one edge)
  - $n = 3$: $3^1 = 3$ trees (three ways to pick the center)
  - $n = 4$: $4^2 = 16$ trees
  - $n = 5$: $5^3 = 125$ trees
]

#Block(color: teal)[
  Cayley's formula has many beautiful proofs.
  The most constructive uses _Prüfer sequences_ --- a bijection between labeled trees on $[n]$ and sequences in $[n]^(n-2)$.
]

#Block(color: yellow)[
  *Why $n^(n-2)$?*
  Each of the $n-2$ positions in a Prüfer sequence can be any of $n$ vertices. \
  The encoding is reversible, establishing the bijection.
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
  A graph $G = pair(V, E)$ is _bipartite_ if its vertices can be partitioned into two disjoint sets $V = X union.sq Y$ such that every edge connects a vertex in $X$ to a vertex in $Y$.

  We write $G = pair(X union Y, E)$ or $G = (X, Y, E)$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #let small(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        // Part X
        vertex((0, 0), $x_1$, <x1>, blue),
        vertex((1, 0), $x_2$, <x2>, blue),
        vertex((2, 0), $x_3$, <x3>, blue),
        // Part Y
        vertex((0.5, 1.2), $y_1$, <y1>, green),
        vertex((1.5, 1.2), $y_2$, <y2>, green),
        // Edges
        edge(<x1>, <y1>),
        edge(<x1>, <y2>),
        edge(<x2>, <y1>),
        edge(<x3>, <y2>),
      ),
      [*Bipartite*],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        small((0, 0), <a>, blue),
        small((1, 0), <b>, blue),
        small((0.5, calc.cos(30deg)), <c>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
      ),
      [*Not bipartite* \ (contains triangle)],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Characterization of Bipartite Graphs

#theorem[
  A graph is bipartite if and only if it contains no odd-length cycles.
]

#proof[(Sketch)][
  ($arrow.r.double$) In a bipartite graph, any walk alternates between $X$ and $Y$, so every cycle has even length.

  ($arrow.l.double$) If no odd cycles exist, 2-color by BFS: pick any vertex, color it blue, color all neighbors green, color their neighbors blue, etc. No conflicts arise.
]

#Block(color: yellow)[
  Bipartiteness can be checked in $O(n + m)$ time using BFS/DFS. \
  This is one of the few natural graph properties that admits efficient recognition.
]

#Block(color: orange)[
  *Note:* Checking if a graph is _3-colorable_ is NP-complete, yet _2-colorable_ (bipartite) is linear time!
]

== Complete Bipartite Graphs

#definition[
  The _complete bipartite graph_ $K_(m,n)$ has parts of sizes $m$ and $n$, with every vertex in one part adjacent to every vertex in the other.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <x1>, blue),
        vertex((1, 0), <x2>, blue),
        vertex((0.5, 1), <y1>, green),
        edge(<x1>, <y1>),
        edge(<x2>, <y1>),
      ),
      [$K_(2,1)$],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <x1>, blue),
        vertex((1, 0), <x2>, blue),
        vertex((0, 1), <y1>, green),
        vertex((1, 1), <y2>, green),
        edge(<x1>, <y1>),
        edge(<x1>, <y2>),
        edge(<x2>, <y1>),
        edge(<x2>, <y2>),
      ),
      [$K_(2,2)$],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <x1>, blue),
        vertex((1, 0), <x2>, blue),
        vertex((2, 0), <x3>, blue),
        vertex((0.5, 1), <y1>, green),
        vertex((1.5, 1), <y2>, green),
        edge(<x1>, <y1>),
        edge(<x1>, <y2>),
        edge(<x2>, <y1>),
        edge(<x2>, <y2>),
        edge(<x3>, <y1>),
        edge(<x3>, <y2>),
      ),
      [$K_(3,2)$],
    ),
  )
  #align(center)[
    #grid(
      columns: 3,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 2em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((2, 0), <c>),
        vertex((0, 1), <d>),
        vertex((1, 1), <e>),
        vertex((2, 1), <f>),
        edge(<a>, <d>, stroke: 3pt + green),
        edge(<a>, <e>),
        edge(<b>, <d>),
        edge(<b>, <e>),
        edge(<c>, <e>),
        edge(<c>, <f>),
      ),
      [*Matching* \ (not maximal)],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((2, 0), <c>),
        vertex((0, 1), <d>),
        vertex((1, 1), <e>),
        vertex((2, 1), <f>),
        edge(<a>, <d>),
        edge(<a>, <e>, stroke: 3pt + green),
        edge(<b>, <d>, stroke: 3pt + green),
        edge(<b>, <e>),
        edge(<c>, <e>),
        edge(<c>, <f>, stroke: 3pt + green),
      ),
      [*Maximum* \ (perfect)],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((2, 0), <c>),
        vertex((0, 1), <d>),
        vertex((1, 1), <e>),
        vertex((2, 1), <f>),
        edge(<a>, <d>, stroke: 3pt + orange),
        edge(<a>, <e>),
        edge(<b>, <d>),
        edge(<b>, <e>, stroke: 3pt + orange),
        edge(<c>, <e>),
        edge(<c>, <f>),
      ),
      [*Maximal* \ (not maximum)],
    ),
  )
  #place(center)[
    #grid(
      columns: 3,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 1.5cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Hall's Marriage Theorem

#definition[
  Let $G = pair(X union Y, E)$ be a bipartite graph. For a subset $S subset.eq X$, define the _neighborhood_ of $S$:
  $ N(S) = { y in Y | exists x in S: {x,y} in E } $
]

#theorem[Hall's Marriage Theorem (Hall, 1935)][
  A bipartite graph $G = pair(X union Y, E)$ has a matching that _saturates_ $X$ (i.e., every vertex in $X$ is matched) if and only if:
  $ forall S subset.eq X: |N(S)| >= |S| $
  This is called *Hall's condition* or the _marriage condition_.
]

== Examples: Hall's Condition

#Block(color: blue)[
  *Why "Marriage"?*
  Think of $X$ as people seeking partners and $Y$ as potential partners.
  Each person in $X$ knows some people in $Y$ (edges).
  Can everyone in $X$ find a distinct partner?
  Only if no group of $k$ people collectively knows fewer than $k$ partners.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: 1em,
    name: name,
  )
  #let data = (
    (
      diagram(
        spacing: 1.5em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $x_1$, <x1>, blue),
        vertex((1, 0), $x_2$, <x2>, blue),
        vertex((2, 0), $x_3$, <x3>, blue),
        vertex((0, 1), $y_1$, <y1>, green),
        vertex((1, 1), $y_2$, <y2>, green),
        vertex((2, 1), $y_3$, <y3>, green),
        edge(<x1>, <y1>),
        edge(<x1>, <y2>),
        edge(<x2>, <y2>),
        edge(<x2>, <y3>),
        edge(<x3>, <y3>),
      ),
      [
        *Satisfies Hall's Condition* \
        Every subset $S$ has $|N(S)| >= |S|$. \
        Perfect matching exists.],
    ),
    (
      diagram(
        spacing: 1.5em,
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $x_1$, <x1>, blue),
        vertex((1, 0), $x_2$, <x2>, blue),
        vertex((2, 0), $x_3$, <x3>, blue),
        vertex((0.5, 1), $y_1$, <y1>, green),
        vertex((1.5, 1), $y_2$, <y2>, green),
        edge(<x1>, <y1>),
        edge(<x2>, <y1>),
        edge(<x2>, <y2>),
        edge(<x3>, <y2>),
      ),
      [
        *Violates Hall's Condition* \
        $S = {x_1, x_2, x_3}$ has $N(S) = {y_1, y_2}$. \
        Since $|N(S)| = 2 < 3 = |S|$, no matching saturates $X$.
      ],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { bottom } else { top },
      column-gutter: 3em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== Proof of Hall's Theorem

We prove both directions.

*Direction ($arrow.r.double$):*
If a matching saturating $X$ exists, then Hall's condition holds.

#proof[
  Let $M$ be a matching that saturates $X$.
  For any $S subset.eq X$:
  - Each vertex in $S$ is matched to a distinct vertex in $Y$ (by definition of matching).
  - Let $M(S)$ be the set of partners of $S$ under $M$.
    Then $|M(S)| = |S|$.
  - Since every partner is a neighbor, $M(S) subset.eq N(S)$.
  - Therefore: $|N(S)| >= |M(S)| = |S|$. #h(1fr) $qed$
]

*Direction ($arrow.l.double$):*
If Hall's condition holds, then a matching saturating $X$ exists.

This is the interesting direction.
We use *strong induction* on $n = |X|$.

== Proof (Sufficiency): Base & Strategy

#proof[
  *Base Case* ($n = 1$):
  If $X = {x}$, Hall's condition gives $|N({x})| >= 1$, so $x$ has a neighbor $y$. The edge ${x,y}$ is a matching.

  *Inductive Hypothesis*:
  Assume the theorem holds for all bipartite graphs with $|X| < n$.

  *Inductive Step*:
  Consider $G$ with $|X| = n >= 2$. We split into two cases:
  - *Case 1:* Every proper subset $S$ has _surplus_ neighbors: $|N(S)| >= |S| + 1$.
  - *Case 2:* Some proper subset $S$ is _tight_: $|N(S)| = |S|$. #qedhere
]

== Proof: Case 1 (Surplus)

#proof[
  *Case 1:* For all $emptyset != S subset.neq X$, we have $|N(S)| >= |S| + 1$.

  _Strategy:_ Match an arbitrary edge, then use induction on the smaller graph.

  + Pick any edge ${x, y} in E$ (exists because $X != emptyset$ and Hall's condition ensures connectivity).
  + Remove both endpoints: let $G' = G - {x, y}$ and $X' = X without x$.
  + *Verify Hall's condition in $G'$:* Let $S' subset.eq X'$ be arbitrary.
    - In $G$, we have $|N_G(S')| >= |S'| + 1$ (since $S' subset.neq X$).
    - Removing $y$ from $Y$ reduces $|N(S')|$ by at most 1.
    - So $|N_{G'}(S')| >= |N_G(S')| - 1 >= (|S'| + 1) - 1 = |S'|$.
  + By induction, $G'$ has a matching $M'$ saturating $X'$.
  + Then $M = M' union {{x, y}}$ saturates $X$. #qedhere
]

== Proof: Case 2 (Tight Subset)

#proof[
  *Case 2:* There exists $emptyset != S_0 subset.neq X$ such that $|N(S_0)| = |S_0|$.

  _Strategy:_ Match $S_0$ independently, then match the rest.

  + *Match $S_0$:*
    The induced subgraph $G[S_0 union N(S_0)]$ satisfies Hall's condition (inherited from $G$).
    Since $|S_0| < n$, by induction there exists a matching $M_1$ saturating $S_0$.

  + *Match the remainder:*
    Let $G' = G - S_0 - N(S_0)$ and $X' = X without S_0$.
    We verify Hall's condition for $G'$.
    Let $A subset.eq X'$ be arbitrary.
    - In $G$: $|N_G(A union S_0)| >= |A union S_0| = |A| + |S_0|$ (Hall's condition).
    - But $N_G(A union S_0) = N_G(A) union N_G(S_0) = N_G(A) union N(S_0)$ (disjoint by construction).
    - So $|N_G(A)| + |N(S_0)| >= |A| + |S_0|$.
    - Since $|N(S_0)| = |S_0|$, we get $|N_G(A)| >= |A|$.
    - In $G'$, the neighbors of $A$ are $N_{G'}(A) = N_G(A) without N(S_0)$, but vertices in $N_G(A)$ were not in $N(S_0)$ (otherwise contradiction).
      So $|N_{G'}(A)| = |N_G(A)| >= |A|$.

  + By induction, $G'$ has a matching $M_2$ saturating $X'$.

  + Then $M = M_1 union M_2$ saturates $X$. #qedhere
]

== Vertex and Edge Covers

#definition[
  A _vertex cover_ $R subset.eq V$ is a set of vertices such that every edge has at least one endpoint in $R$.
]

#definition[
  An _edge cover_ $F subset.eq E$ is a set of edges such that every vertex is incident to at least one edge in $F$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint, ..args) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
    ..args,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>, green, radius: 7pt),
        vertex((1, 0), <b>, blue),
        vertex((1, 1), <c>, green, radius: 7pt),
        vertex((0, 1), <d>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
      ),
      [*Vertex cover* ${a, c}$],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>, blue),
        vertex((1, 0), <b>, blue),
        vertex((1, 1), <c>, blue),
        vertex((0, 1), <d>, blue),
        edge(<a>, <b>, stroke: 3pt + green),
        edge(<b>, <c>),
        edge(<c>, <d>, stroke: 3pt + green),
        edge(<d>, <a>),
        edge(<a>, <c>),
      ),
      [*Edge cover* ${{a,b}, {c,d}}$],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

== König's Theorem

#theorem[König's Theorem][
  In a bipartite graph:
  $ nu(G) = tau(G) $
  where $nu(G)$ is the size of a _maximum matching_ and $tau(G)$ is the size of a _minimum vertex cover_.
]

#Block(color: yellow)[
  *Key insight:* This equality does _not_ hold for general graphs! In a triangle $K_3$: $nu = 1$ but $tau = 2$.
]

#Block(color: blue)[
  *Connection:* König's theorem follows from the LP duality of matching and vertex cover. It also follows from the Max-Flow Min-Cut theorem on the associated network.
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint, ..args) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
    ..args,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <a>, green, radius: 7pt),
      vertex((1, 0), <b>, blue),
      vertex((2, 0), <c>, green, radius: 7pt),
      vertex((0.5, 0.8), <d>, blue),
      vertex((1.5, 0.8), <e>, blue),
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
  A _bridge_ (or _cut edge_) is an edge whose removal increases the number of connected components.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: 1em,
    name: name,
  )
  #place(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, red),
        vertex((1.5, 0.8), $c$, <c>, blue),
        vertex((1.5, -0.8), $d$, <d>, blue),
        vertex((2.5, 0), $e$, <e>, red),
        vertex((3.5, 0), $f$, <f>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<c>, <d>),
        edge(<c>, <e>),
        edge(<d>, <e>),
        edge(<e>, <f>, stroke: 4pt + orange),
      ),
      [
        - #Red[Cut vertices]: $b$, $e$
        - #text(fill: orange)[Bridge]: edge ${e, f}$
      ],
    )
  ]
]

// #Block(color: yellow)[
//   *Observation:* A vertex $v$ is a cut vertex iff it lies on _every_ path between some pair of vertices.
//   A bridge $e$ lies on _every_ path between its endpoints' "sides".
// ]

== Separators and Cuts

#definition[
  For vertices $u, v in V$, a _$u$-$v$ separator_ (or _$u$-$v$ vertex cut_) is a set $S subset.eq V without {u,v}$ such that $u$ and $v$ are in different components of $G - S$.
]

#definition[
  A _$u$-$v$ edge cut_ is a set $F subset.eq E$ such that $u$ and $v$ are in different components of $G - F$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .9em,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), $u$, <u>, blue),
      vertex((1, 0.5), $a$, <a>, red),
      vertex((1, -0.5), $b$, <b>, red),
      vertex((2, 0.5), $c$, <c>, green),
      vertex((2, -0.5), $d$, <d>, green),
      vertex((3, 0), $v$, <v>, blue),
      edge(<u>, <a>),
      edge(<u>, <b>),
      edge(<a>, <c>),
      edge(<b>, <d>),
      edge(<a>, <b>),
      edge(<c>, <d>),
      edge(<c>, <v>),
      edge(<d>, <v>),
    )
  ]
]

#Red[$S = {a, b}$] is a $u$-$v$ separator.
#Green[$S' = {c, d}$] is also a $u$-$v$ separator.

== Vertex and Edge Connectivity

#definition[
  The _vertex connectivity_ $kappa(G)$ is the minimum size of a vertex set $S$ whose removal disconnects $G$ or makes it trivial (single vertex).

  Equivalently: $kappa(G) = min_(u,v) {"minimum" u"-"v "separator size"}$ over all non-adjacent $u, v$.
]

#definition[
  The _edge connectivity_ $lambda(G)$ is the minimum size of an edge set $F$ whose removal disconnects $G$.

  Equivalently: $lambda(G) = min_(u,v) {"minimum" u"-"v "edge cut size"}$ over all $u != v$.
]

#Block(color: blue)[
  For complete graphs $K_n$: we define $kappa(K_n) = n - 1$ (need to remove all but one vertex).
]

== $k$-Connectivity

#definition[
  A graph $G$ is *$k$-vertex-connected* (or simply _$k$-connected_) if $kappa(G) >= k$.

  Equivalently: $G$ has more than $k$ vertices, and $G - S$ is connected for every set $S$ with $|S| < k$.
]

#definition[
  A graph $G$ is *$k$-edge-connected* if $lambda(G) >= k$.

  Equivalently: $G - F$ is connected for every edge set $F$ with $|F| < k$.
]

#example[
  - $K_n$ is $(n-1)$-connected (both vertex and edge).
  - $C_n$ (cycle) is 2-connected and 2-edge-connected.
  - A tree with $n >= 2$ vertices has $kappa = lambda = 1$ (every edge is a bridge).
]

== Whitney's Inequality

#theorem[Whitney's Inequality][
  For any graph $G$:
  $ kappa(G) <= lambda(G) <= delta(G) $
  where $delta(G)$ is the minimum degree.
]

#proof[
  - $lambda(G) <= delta(G)$:
    Removing all edges incident to a minimum-degree vertex disconnects it.
  - $kappa(G) <= lambda(G)$:
    Given a minimum edge cut $F$, for each edge in $F$ pick one endpoint on the "smaller side".
    This gives a vertex separator of size $<= |F|$. #qedhere
]

#Block(color: yellow)[
  *When are they equal?* For $k$-regular graphs with high girth, often $kappa = lambda = k$. For example, the Petersen graph has $kappa = lambda = delta = 3$.
]

== Menger's Theorem

#theorem[Menger's Theorem (Vertex Form)][
  Let $u, v$ be non-adjacent vertices in $G$. Then:
  $ max{"number of internally vertex-disjoint" u"-"v "paths"} = min{|S| : S "is a" u"-"v "separator"} $
]

#theorem[Menger's Theorem (Edge Form)][
  For any distinct vertices $u, v$ in $G$:
  $ max{"number of edge-disjoint" u"-"v "paths"} = min{|F| : F "is a" u"-"v "edge cut"} $
]

#Block(color: green)[
  Menger's theorem is equivalent to the Max-Flow Min-Cut theorem with unit capacities.

  The _"flow"_ (disjoint paths) and _"cut"_ (separators) are _dual_ notions.
]

== Menger's Theorem: Corollaries

#theorem[Global Vertex Connectivity][
  A graph $G$ is $k$-connected if and only if every pair of distinct vertices is connected by at least $k$ internally vertex-disjoint paths.
]

#theorem[Global Edge Connectivity][
  A graph $G$ is $k$-edge-connected if and only if every pair of distinct vertices is connected by at least $k$ edge-disjoint paths.
]

#Block(color: yellow)[
  *Intuition:* High connectivity means many "independent routes" between any two vertices. Failure of a few vertices/edges cannot disconnect the graph.
]

== Blocks (2-Connected Components)

#definition[
  A _block_ of a graph $G$ is a maximal connected subgraph with no cut vertex (i.e., maximal 2-connected subgraph, or a bridge, or an isolated vertex).
]

#note[
  - A 2-connected graph is its own single block.
  - Every edge belongs to exactly one block.
  - Blocks can share at most one vertex --- and that vertex is a cut vertex.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Block 1 (triangle)
      vertex((0, 0), <a>, blue),
      vertex((0.5, 0.8), <b>, blue),
      vertex((1, 0), <c>, purple),
      edge(<a>, <b>, stroke: blue),
      edge(<b>, <c>, stroke: blue),
      edge(<c>, <a>, stroke: blue),
      // Block 2 (pentagon)
      vertex((2, 0), <d>, green),
      vertex((2, 1), <e>, green),
      vertex((3, 1), <f>, green),
      vertex((3, 0), <g>, purple),
      edge(<c>, <d>, stroke: green),
      edge(<d>, <e>, stroke: green),
      edge(<e>, <f>, stroke: green),
      edge(<f>, <g>, stroke: green),
      edge(<g>, <c>, stroke: green),
      // Block 3 (single edge = bridge)
      vertex((4, 0.5), <h>, orange),
      edge(<g>, <h>, stroke: orange),
    )
  ]
]

Three blocks: #text(fill: blue)[blue triangle], #text(fill: green.darken(20%))[green pentagon], #text(fill: orange)[orange bridge]. #text(fill: purple)[Purple] = cut vertices.

== Block-Cut Tree

#definition[
  The _block-cut tree_ (or _BC-tree_) of a connected graph $G$ is a bipartite tree $T$ where:
  - One part contains a node for each _block_ of $G$.
  - The other part contains a node for each _cut vertex_ of $G$.
  - A block-node $B$ is adjacent to a cut-vertex-node $v$ iff $v in B$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #grid(
    columns: 2,
    column-gutter: 2em,
    align: center + horizon,
    [
      #let vertex(pos, label, name, tint) = blob(pos, label, tint: tint, shape: shapes.circle, radius: .7em, name: name)
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        // Block 1
        vertex((0, 0), $a$, <a>, blue),
        vertex((0.7, 0), $b$, <b>, purple),
        edge(<a>, <b>, stroke: blue),
        // Block 2 (triangle)
        vertex((1.2, 0.5), $c$, <c>, green),
        vertex((1.2, -0.5), $d$, <d>, green),
        edge(<b>, <c>, stroke: green),
        edge(<b>, <d>, stroke: green),
        edge(<c>, <d>, stroke: green),
        // Block 3
        vertex((2, 0), $e$, <e>, purple),
        vertex((2.7, 0), $f$, <f>, orange),
        edge(<c>, <e>, stroke: orange),
        edge(<e>, <f>, stroke: orange),
      )

      *Graph $G$*
    ],
    [
      #let bnode(pos, label, name, tint) = blob(pos, label, tint: tint, shape: shapes.rect, radius: .6em, name: name)
      #let cnode(pos, label, name) = blob(pos, label, tint: purple, shape: shapes.circle, radius: .6em, name: name)
      #diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        bnode((0, 0), $B_1$, <B1>, blue),
        cnode((1, 0), $b$, <b>),
        bnode((2, 0), $B_2$, <B2>, green),
        cnode((3, 0.5), $c$, <c>),
        cnode((3, -0.5), $e$, <e>),
        bnode((4, 0), $B_3$, <B3>, orange),
        edge(<B1>, <b>),
        edge(<b>, <B2>),
        edge(<B2>, <c>),
        edge(<B2>, <e>),
        edge(<c>, <B3>),
        edge(<e>, <B3>),
      )

      *Block-Cut Tree*
    ],
  )
]

#Block(color: yellow)[
  *Applications:* The block-cut tree decomposes $G$ into 2-connected pieces. Many problems can be solved by dynamic programming on this tree.
]

== Islands (2-Edge-Connected Components)

#definition[
  An _island_ (or _2-edge-connected component_) is a maximal subgraph with no bridges.

  Equivalently: vertices $u$ and $v$ are in the same island iff they lie on a common cycle.
]

#note[
  - Islands are separated by bridges.
  - Every vertex belongs to exactly one island.
  - Unlike blocks, islands partition the vertex set (not just edges).
]

== Blocks vs Islands

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((0.8, 0), $b$, <b>, blue),
        vertex((0.4, 0.7), $c$, <c>, blue),
        vertex((1.6, 0), $d$, <d>, green),
        vertex((2.4, 0), $e$, <e>, green),
        vertex((2, 0.7), $f$, <f>, green),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
        edge(<b>, <d>, stroke: 3pt + orange),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <d>),
      ),
      [
        *Islands* \
        #text(fill: blue)[Blue] and #text(fill: green.darken(20%))[green] are 2-edge-connected components. \
        #text(fill: orange)[Orange] = bridge.
      ],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((0.8, 0), $b$, <b>, purple),
        vertex((0.4, 0.7), $c$, <c>, blue),
        vertex((1.6, 0), $d$, <d>, purple),
        vertex((2.4, 0), $e$, <e>, green),
        vertex((2, 0.7), $f$, <f>, green),
        edge(<a>, <b>, stroke: blue),
        edge(<b>, <c>, stroke: blue),
        edge(<c>, <a>, stroke: blue),
        edge(<b>, <d>, stroke: orange),
        edge(<d>, <e>, stroke: green),
        edge(<e>, <f>, stroke: green),
        edge(<f>, <d>, stroke: green),
      ),
      [
        *Blocks* \
        #text(fill: blue)[Blue triangle], #text(fill: green.darken(20%))[green triangle], #text(fill: orange)[orange bridge]. \
        #text(fill: purple)[Purple] = cut vertices $b$ and $d$.
      ],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      column-gutter: 2em,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

#Block(color: yellow)[
  *Key difference:*
  - *Blocks* = 2-vertex-connectivity: no cut vertices within a block.
  - *Islands* = 2-edge-connectivity: no bridges within an island.

  Blocks may share cut vertices; islands partition vertices.
]

== Bridge Tree

#definition[
  The _bridge tree_ (or _island tree_) of a connected graph $G$ is obtained by contracting each island to a single vertex. The edges of this tree are exactly the bridges of $G$.
]

#Block(color: blue)[
  *Analogy:*
  - Block-cut tree: decomposition by _cut vertices_ into _blocks_.
  - Bridge tree: decomposition by _bridges_ into _islands_.
]

#theorem[
  A graph is 2-edge-connected iff its bridge tree is a single vertex (no bridges).

  A graph is 2-vertex-connected iff its block-cut tree has a single block node.
]


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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let h = 1cm
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0cm, 0cm), <a>, blue),
        vertex((h, 0cm), <b>, blue),
        vertex((h, h), <c>, blue),
        vertex((0cm, h), <d>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
      ),
      [*Eulerian* \ (all degrees even)],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0cm, 0cm), <a>, red),
        vertex((h, 0cm), <b>, blue),
        vertex((h, h), <c>, blue),
        vertex((0cm, h), <d>, red),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
      ),
      [*Has Eulerian trail* \ (2 odd vertices)],
    ),
  )
  #place(center, dy: -.5em)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
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
  *Warning:* Unlike Eulerian graphs, there is _no simple characterization_ of Hamiltonian graphs!

  Determining if a graph is Hamiltonian is NP-complete.
]

== Sufficient Conditions for Hamiltonicity

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
  *Historical note:* Hamilton sold a puzzle ("Icosian game") based on finding Hamiltonian cycles on a dodecahedron graph.

  The dodecahedral graph has exactly 30 distinct Hamiltonian cycles.
]


= Planar Graphs
#focus-slide()

== Planar Graphs: Definition

#definition[
  A graph is _planar_ if it can be drawn in the plane without edge crossings.

  A _plane graph_ is a specific planar embedding (drawing) of a planar graph.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <a>),
        vertex((1, 0), <b>),
        vertex((1, 1), <c>),
        vertex((0, 1), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
        edge(<b>, <d>),
      ),
      [$K_4$ with crossings],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0.5, 0), <a>),
        vertex((1, 0.5), <b>),
        vertex((0.5, 1), <c>),
        vertex((0, 0.5), <d>),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <a>),
        edge(<a>, <c>),
        edge(<b>, <d>),
      ),
      [$K_4$ planar embedding],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

#Block(color: yellow)[
  $K_4$ is planar --- it can be redrawn without crossings.
]

== Faces and Euler's Formula

#definition[
  A _face_ of a plane graph is a connected region bounded by edges. The unbounded region is the _outer face_ (or _infinite face_).
]

#theorem[Euler's Polyhedron Formula][
  For any connected plane graph with $n$ vertices, $m$ edges, and $f$ faces:
  $ n - m + f = 2 $
]

#Block(color: teal)[
  *Deep insight:* The quantity $n - m + f$ is called the _Euler characteristic_. It equals 2 for any surface homeomorphic to a sphere. For a torus, it equals 0. This connects graph theory to topology!
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #place(center, dy: -.5em)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 2em,
      align(center)[
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          vertex((0, 0), <a>),
          vertex((1, 0), <b>),
          vertex((1, 1), <c>),
          vertex((0, 1), <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
        )
      ],
      [
        - Vertices: $n = 4$
        - Edges: $m = 5$
        - Faces: $f = 3$ (2 inner + 1 outer)

        Check: $4 - 5 + 3 = 2$ #YES
      ],
    )
  ]
]

== Consequences of Euler's Formula

#theorem[
  For any simple planar graph with $n >= 3$ vertices and $m$ edges:
  $ m <= 3n - 6 $
]

#proof[
  Each face has $>= 3$ edges on its boundary, and each edge borders at most 2 faces.
  So $3f <= 2m$, giving $f <= (2m)/3$.

  By Euler's formula: $2 = n - m + f <= n - m + (2m)/3 = n - m/3$.
  Therefore $m <= 3n - 6$.
]

#theorem[
  For any simple planar _bipartite_ graph with $n >= 3$ vertices:
  $ m <= 2n - 4 $
]

#Block(color: yellow)[
  *Corollary:* $K_5$ (with 10 edges but $3 dot 5 - 6 = 9$) and $K_(3,3)$ (with 9 edges but $2 dot 6 - 4 = 8$) are _not_ planar.
]

== Kuratowski's Theorem

#theorem[Kuratowski's Theorem][
  A graph is planar if and only if it contains no subdivision of $K_5$ or $K_(3,3)$ as a subgraph.
]

#definition[
  A _subdivision_ of a graph $G$ is obtained by replacing edges with paths.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #let data = (
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-90deg + 360deg / 5 * 0, 1), <a>, red),
        vertex((-90deg + 360deg / 5 * 1, 1), <b>, red),
        vertex((-90deg + 360deg / 5 * 2, 1), <c>, red),
        vertex((-90deg + 360deg / 5 * 3, 1), <d>, red),
        vertex((-90deg + 360deg / 5 * 4, 1), <e>, red),
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
      ),
      [$K_5$ (not planar)],
    ),
    (
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), <x1>, blue),
        vertex((1, 0), <x2>, blue),
        vertex((2, 0), <x3>, blue),
        vertex((0, 1), <y1>, green),
        vertex((1, 1), <y2>, green),
        vertex((2, 1), <y3>, green),
        edge(<x1>, <y1>),
        edge(<x1>, <y2>),
        edge(<x1>, <y3>),
        edge(<x2>, <y1>),
        edge(<x2>, <y2>),
        edge(<x2>, <y3>),
        edge(<x3>, <y1>),
        edge(<x3>, <y2>),
        edge(<x3>, <y3>),
      ),
      [$K_(3,3)$ (not planar)],
    ),
  )
  #align(center)[
    #grid(
      columns: 2,
      align: (x, y) => center + if y == 0 { horizon } else { top },
      column-gutter: 3cm,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <a>, red),
      vertex((1, 0), <b>, blue),
      vertex((2, 0), <c>, red),
      vertex((0.5, 0.8), <d>, green),
      vertex((1.5, 0.8), <e>, green),
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
  where $omega(G)$ is the _clique number_ and $Delta(G)$ is the maximum degree.
]

#proof[(Lower bound)][
  A clique of size $k$ needs $k$ different colors.
]

#theorem[Brooks' Theorem][
  For any connected graph $G$ that is not a complete graph or an odd cycle:
  $ chi(G) <= Delta(G) $
]

#Block(color: yellow)[
  Computing $chi(G)$ is NP-hard, but checking 2-colorability is $cal(O)(n+m)$.
]

== The Four Color Theorem

#theorem[Four Color Theorem][
  Every planar graph is 4-colorable: $chi(G) <= 4$ for all planar $G$.
]

#Block(color: teal)[
  *A controversial proof:*
  - Conjectured in 1852 by Francis Guthrie
  - Proved in 1976 by Appel and Haken _using a computer_
  - First major theorem requiring computational verification
  - Checked ~1,500 "unavoidable" configurations
  - Sparked debates: Is a computer-assisted proof a "real" proof?
]

#Block(color: blue)[
  *The dual view:* Coloring vertices of a planar graph = coloring regions of a map so adjacent regions differ. Every map needs at most 4 colors!\n]

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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name) = blob(
    pos,
    [],
    tint: blue,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <a>),
      vertex((0.5, 0.87), <b>),
      vertex((1, 0), <c>),
      edge(<a>, <b>, stroke: 3pt + red),
      edge(<b>, <c>, stroke: 3pt + green),
      edge(<c>, <a>, stroke: 3pt + blue),
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
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, tint) = blob(
    pos,
    [],
    tint: tint,
    shape: shapes.circle,
    radius: 5pt,
    name: name,
  )
  #align(center)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), <a>, green),
      vertex((1, 0), <b>, green),
      vertex((0.5, 0.8), <c>, green),
      vertex((2, 0), <d>, blue),
      vertex((1.5, 0.8), <e>, blue),
      edge(<a>, <b>, stroke: 3pt + green),
      edge(<b>, <c>, stroke: 3pt + green),
      edge(<c>, <a>, stroke: 3pt + green),
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

  Famous quote by Erdős: "Suppose aliens invade the earth and threaten to obliterate it in a year's time unless human beings can find $R(5,5)$. We could marshal the world's best minds and fastest computers, and within a year we could probably calculate the value. If they digit $R(6,6)$, we would have no choice but to launch a preemptive attack."
]


= Summary and Connections
#focus-slide()

== Graph Theory: Key Concepts

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Structural concepts:*
    - Degree, adjacency, neighborhoods
    - Paths, cycles, connectivity
    - Trees, spanning trees, forests
    - Bipartiteness (2-colorability)
    - Planarity (Euler's formula)
  ],
  [
    *Optimization problems:*
    - Matchings (Hall, König)
    - Vertex/edge covers
    - Graph coloring ($chi$, $chi'$)
    - Cliques and stable sets
    - Connectivity (Menger)
  ],
)

#Block(color: yellow)[
  *Foundational theorems:*
  - Handshaking: $sum deg(v) = 2m$
  - Euler's formula: $n - m + f = 2$
  - Hall's marriage theorem (matchings $<->$ neighborhoods)
  - Menger's theorem (paths $<->$ cuts)
  - Four color theorem (planarity $->$ 4-colorability)
]

== What's Next: Flow Networks

#Block(color: blue)[
  *Coming up:* Network flows unify and generalize graph theory:
  - Maximum bipartite matching $=$ max flow in unit network
  - Menger's theorem $=$ max-flow min-cut with unit capacities
  - Hall's condition $=$ flow feasibility check
  - König's theorem $=$ LP duality for bipartite matching
]

Graph theory provides the foundation for:
- Algorithms (BFS, DFS, shortest paths, MST)
- Network design and optimization
- Formal language theory (automata are directed labeled graphs!)
- Combinatorics, counting, and probabilistic methods


== Exercises

+ Prove that every tree with $n >= 2$ vertices has at least 2 leaves.
+ Show that the Petersen graph is not planar.
+ Find the chromatic number of $C_n$ for all $n >= 3$.
+ Prove König's theorem using Hall's theorem.
+ For which values of $n$ does $K_n$ have an Eulerian circuit?
+ Find all graphs $G$ with $kappa(G) = lambda(G) = delta(G)$.
+ Prove that every 2-connected graph has no cut vertices.
+ Show that a graph is bipartite iff it has no odd cycles.
