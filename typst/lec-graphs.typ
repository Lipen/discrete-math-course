#import "theme.typ": *
#show: slides.with(
  title: [Graph Theory],
  subtitle: "Discrete Math",
  date: "Spring 2026",
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
// #let fIn = $f^"in"$ // obsolete
// #let fOut = $f^"out"$ // obsolete
#let net = math.op("net")


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
      name: "William Rowan Hamilton",
      image: image("assets/William_Rowan_Hamilton.jpg"),
    ),
    (
      name: "Paul Erdős",
      image: image("assets/Paul_Erdos.jpg"),
    ),
    (
      name: "Paul Turán",
      image: image("assets/Paul_Turan.jpg"),
    ),
    (
      name: "Frank Ramsey",
      image: image("assets/Frank_Ramsey.jpg"),
    ),
    (
      name: "Frank Harary",
      image: image("assets/Frank_Harary.jpg"),
    ),
    (
      name: "Béla Bollobás",
      image: image("assets/Bela_Bollobas.jpg"),
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
#focus-slide(
  epigraph: [All paths are not equal; if they were, they wouldn’t be paths \ but rather the points at each end.],
  epigraph-author: "H.E. Huntley",
  scholars: (
    (
      name: "Edsger Dijkstra",
      image: image("assets/Edsger_Dijkstra.jpg"),
    ),
    (
      name: "Robert Tarjan",
      image: image("assets/Robert_Tarjan.jpg"),
    ),
    (
      name: "Arthur Cayley",
      image: image("assets/Arthur_Cayley.jpg"),
    ),
    (
      name: "Heinz Prüfer",
      image: image("assets/Heinz_Prufer.jpg"),
    ),
    (
      name: "Øystein Ore",
      image: image("assets/Oystein_Ore.jpg"),
    ),
    (
      name: "Karl Menger",
      image: image("assets/Karl_Menger.jpg"),
    ),
  ),
)

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

== Walks, Trails, and Paths: Visual Example

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
  Consider the graph:
  #align(center)[
    #v(-1em)
    #diagram(
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
      edge(<b>, <e>),
    )
  ]

  - *Walk:* $a, b, d, b, c$ --- vertex $b$ is repeated #YES
  - *Trail:* $a, d, b, e, c, b$ --- all edges distinct, but vertex $b$ repeats #YES
  - *Path:* $a, d, e, c, b$ --- all vertices distinct #YES
  - *Cycle:* $b, d, e, b$ --- closed path of length 3
]

#Block(color: yellow)[
  *Why distinguish these?* The distinction is essential in algorithms:
  - DFS/BFS naturally find _paths_.
  - Euler's algorithm finds _trails_ (visiting every edge).
  - Many proofs require transforming a walk into a path.
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

#theorem[Distance is a Metric][
  For a connected graph $G$, the distance function satisfies:
  + _Non-negativity:_ $dist(u, v) >= 0$, and $dist(u, v) = 0$ iff $u = v$
  + _Symmetry:_ $dist(u, v) = dist(v, u)$
  + _Triangle inequality:_ $dist(u, w) <= dist(u, v) + dist(v, w)$
]

#Block(color: blue)[
  *Algorithm:* Breadth-first search (BFS) computes $dist(s, v)$ for all $v$ from a source $s$ in $O(n + m)$ time.
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

#pagebreak()

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
        vertex((0, 0.5), $a$, <a>, tint: green),
        vertex((0.95, 0), $b$, <b>, tint: green),
        vertex((0.59, 0.95), $c$, <c>, tint: green),
        vertex((-0.59, 0.95), $d$, <d>, tint: green),
        vertex((-0.95, 0), $e$, <e>, tint: green),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<d>, <e>),
        edge(<e>, <a>),
      ),
      [
        Cycle graph $C_5$:
        - $ecc(v) = 2$ for all $v$
        - $rad(G) = diam(G) = 2$
        - All vertices are central!
      ],
    )
  ]
]

== Radius and Diameter: Bounds

#theorem[
  For any connected graph $G$: $rad(G) <= diam(G) <= 2 dot rad(G)$
]

#proof[
  Left inequality: $min <= max$ (by definition).

  Right inequality: Let $u, v$ achieve $diam(G) = dist(u, v)$, and let $w in Center(G)$. By triangle inequality:
  $ diam(G) = dist(u, v) <= dist(u, w) + dist(w, v) <= 2 dot ecc(w) = 2 dot rad(G) $
  #qedhere
]

#Block(color: blue)[
  *Application:* The center minimizes the _worst-case_ distance to any vertex --- optimal for facility placement (servers, hospitals, emergency services).
]

== Connectivity

#definition[
  Two vertices $u$ and $v$ in an undirected graph $G$ are _connected_ if $G$ contains a path from $u$ to $v$. Otherwise, they are _disconnected_.
]

#definition[
  A graph $G$ is _connected_ if every pair of vertices in $G$ is connected (i.e., there exists a path between any two vertices).

  A graph that is not connected is called _disconnected_.
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
    #v(-1em)
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 3em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, green),
        vertex((1, 0), $b$, <b>, green),
        vertex((0.5, 0.8), $c$, <c>, green),
        vertex((2, 0.4), $d$, <d>, green),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
        edge(<b>, <d>),
      ),
      [
        *Connected:* path exists between every pair.
      ],
    )
  ]

  #align(center)[
    #grid(
      columns: 2,
      align: (center + horizon, left + top),
      column-gutter: 3em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((0.8, 0), $b$, <b>, blue),
        vertex((2, 0), $c$, <c>, red),
        vertex((2.8, 0), $d$, <d>, red),
        edge(<a>, <b>),
        edge(<c>, <d>),
      ),
      [
        *Disconnected:* no path $a$ to $c$.
      ],
    )
  ]
]

#theorem[Walk implies Path][
  If there exists a walk from $u$ to $v$, then there exists a _path_ from $u$ to $v$.
]

#proof[
  Take a shortest walk. If any vertex repeats, shortcut between occurrences to get a shorter walk --- contradiction. #qedhere
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
        edge(<a>, <b>, "-}>"),
        edge(<b>, <c>, "-}>"),
        edge(<c>, <a>, "-}>"),
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
        edge(<a>, <b>, "-}>"),
        edge(<a>, <c>, "-}>"),
        edge(<b>, <c>, "-}>"),
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
        edge(<a>, <b>, "-}>"),
        edge(<c>, <b>, "-}>"),
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
  #let bnode(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.rect,
    name: name,
  )
  #align(center)[
    #v(-2em)
    #grid(
      columns: 2,
      align: (center + horizon, center + top),
      column-gutter: 3em,
      row-gutter: 1em,
      [
        #diagram(
          spacing: 2em,
          node-stroke: 1pt,
          edge-stroke: 1pt,
          // SCC 1
          vertex((0, 0), $a$, <a>, blue),
          vertex((1, 0), $b$, <b>, blue),
          vertex((0.5, 0.8), $c$, <c>, blue),
          edge(<a>, <b>, "-}>"),
          edge(<b>, <c>, "-}>"),
          edge(<c>, <a>, "-}>"),
          // SCC 2
          vertex((2.5, 0), $d$, <d>, green),
          vertex((3.5, 0), $e$, <e>, green),
          edge(<d>, <e>, "-}>"),
          edge(<e>, <d>, "-}>"),
          // SCC 3
          vertex((3, 1), $f$, <f>, orange),
          // Edges between SCCs
          edge(<b>, <d>, "-}>"),
          edge(<c>, <f>, "-}>"),
          edge(<f>, <e>, "-}>"),
        )
      ],
      [
        #diagram(
          spacing: 2em,
          node-stroke: 1pt,
          edge-stroke: 1pt,
          bnode((0, 0), $S_1$, <S1>, blue),
          bnode((1.5, 0), $S_2$, <S2>, green),
          bnode((1.5, 1), $S_3$, <S3>, orange),
          edge(<S1>, <S2>, "-}>"),
          edge(<S1>, <S3>, "-}>"),
          edge(<S3>, <S2>, "-}>"),
        )
      ],

      [*Digraph $G$*], [*Condensation (DAG)*],
    )
  ]

  Three SCCs: #text(fill: blue)[${a, b, c}$], #text(fill: green.darken(20%))[${d, e}$], #text(fill: orange)[${f}$]. Contracting each gives a DAG.
]

#Block(color: blue)[
  *Condensation:* Contracting each SCC to a vertex always gives a DAG.
]

#place[
  #v(1em)
  #Block(color: teal)[
    *Algorithms:* SCCs in $O(n + m)$ via Kosaraju's or Tarjan's algorithm.
  ]
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

#Block(color: yellow)[
  *Why girth matters:*
  Graphs with large girth are "locally tree-like" --- they behave like trees in a neighborhood of each vertex.
  This property is exploited in coding theory (LDPC codes) and extremal graph theory.
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
  Trees are _ubiquitous_ structures with simple recursive algorithms:
  - file systems
  - parse trees
  - network design
]

== Characterizations of Trees: Unique Path

#theorem[
  A connected graph is acyclic if and only if every pair of vertices is joined by a unique path.
]<thm:unique-path>

#proof[
  _($arrow.r.double$)_ Suppose $G$ is connected and acyclic. If there were two distinct $u$-$v$ paths, their union would contain a cycle, contradiction.

  _($arrow.l.double$)_ Suppose every pair of vertices has a unique path. If a cycle existed, choose distinct vertices $u, v$ on that cycle.
  Traversing the cycle in opposite directions gives two distinct $u$-$v$ paths, contradiction.
]

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #grid(
    columns: 2,
    align: (center + horizon, left + top),
    column-gutter: 3em,
    row-gutter: 1em,
    diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), $u$, <u>, blue),
      vertex((1, 0), $x$, <x>, blue),
      vertex((2, 0), $v$, <v>, blue),
      vertex((1, 0.9), $y$, <y>, blue),
      edge(<u>, <x>, stroke: 2pt + red),
      edge(<x>, <v>, stroke: 2pt + red),
      edge(<u>, <y>, stroke: 2pt + green, bend: -30deg),
      edge(<y>, <v>, stroke: 2pt + green, bend: -30deg),
    ),
    [
      Cycle gives two distinct $u$-$v$ paths:
      - #Red[$u$-$x$-$v$]
      - #Green[$u$-$y$-$v$]

      Therefore uniqueness fails whenever a cycle exists.
    ],
  )
]

== Characterizations of Trees: Maximally Acyclic

#theorem[
  Let $T$ be a tree and let $u, v in V(T)$ be non-adjacent.
  Then the graph $T + {u, v}$ contains exactly one cycle.
]

#proof[
  Since $T$ is a tree, there is a unique $u$-$v$ path $P$ in $T$ (see @thm:unique-path).

  After adding the edge ${u, v}$, we obtain a cycle by going from $u$ to $v$ along $P$ and returning via ${u, v}$.

  Why is it the _only_ cycle?
  Any cycle in $T + {u, v}$ must use the new edge ${u, v}$.
  Otherwise that cycle would already exist in $T$, contradicting acyclicity of $T$.
  Removing ${u, v}$ from such a cycle leaves a $u$-$v$ path in $T$, and uniqueness of $P$ forces that path to be exactly $P$.
  Therefore the cycle is unique.
]

#[
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
    #grid(
      columns: 2,
      column-gutter: 3em,
      row-gutter: 1em,

      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2, 0), $c$, <c>, blue),
        vertex((1, 0.8), $d$, <d>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
      ),
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2, 0), $c$, <c>, blue),
        vertex((1, 0.8), $d$, <d>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<a>, <c>, stroke: 2pt + red, bend: -30deg),
      ),

      [*Before:* tree $T$], [*After:* $T + {a,c}$ has exactly one cycle $a$-$b$-$c$-$a$],
    )
  ]
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
    #v(-1em)
    #grid(
      columns: 2,
      column-gutter: 3em,
      row-gutter: 1em,
      ..array.zip(..data).flatten()
    )
  ]
]

#Block(color: blue)[
  *Application:* Finding minimum spanning trees (MST) is fundamental in network design --- Kruskal's and Prim's algorithms solve this in $O(m log n)$.
]

== Fundamental Cycles

#definition[
  Let $T$ be a spanning tree of $G$. For each edge $e in E(G) without E(T)$ (a _non-tree edge_), the graph $T + e$ contains exactly one cycle, called the _fundamental cycle_ of $e$ with respect to $T$.
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
  #align(center)[
    #v(-2em)
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0cm, 0cm), $a$, <a>),
      vertex((h, 0cm), $b$, <b>),
      vertex((h, h), $c$, <c>),
      vertex((0cm, h), $d$, <d>),
      // Tree edges
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<c>, <d>),
      // Non-tree edges
      edge(<d>, <a>, stroke: 2pt + red),
      edge(<a>, <c>, stroke: 2pt + orange, bend: 20deg),
    )
  ]

  Spanning tree: $a$-$b$-$c$-$d$ (black edges).

  - #text(fill: red)[Adding ${a, d}$] creates fundamental cycle $a$-$b$-$c$-$d$-$a$.
  - #text(fill: orange)[Adding ${a, c}$] creates fundamental cycle $a$-$b$-$c$-$a$.
]

#Block(color: yellow)[
  *Key insight:* Each non-tree edge generates exactly one cycle. For a graph with $n$ vertices and $m$ edges: $m - n + 1$ fundamental cycles (the _cycle rank_).
]

// NOTE: Cayley's Formula and Prüfer Sequences are candidates for practice session.
// They enrich the tree theory but are not essential for the connectivity narrative.

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
  *Historical note:* Cayley proved this in 1889. The formula counts _labeled_ trees, i.e., trees on the vertex set ${1, 2, ..., n}$. The number of _unlabeled_ (non-isomorphic) trees grows much slower.
]

#Block(color: yellow)[
  *Why $n^(n-2)$?* Prüfer sequences give a bijection between labeled trees on $[n]$ and sequences in $[n]^(n-2)$.
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
  - Encoding: Remove 1 (neighbor 3), remove 2 (neighbor 4), remove 5 (neighbor 3).
  - Prüfer sequence: $(3, 4, 3)$
]

#note(title: "Observation")[
  A vertex appears in the Prüfer sequence exactly $deg(v) - 1$ times.
  In particular, _leaves never appear_ in the sequence (they have degree 1).
]


= Connectivity Theory
#focus-slide(
  epigraph: [The question is not whether a graph is connected, \ but _how well_ it is connected.],
)

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
  #align(center)[
    #v(-1em)
    #grid(
      columns: 2,
      align: left + horizon,
      column-gutter: 2em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0.5), $a$, <a>, blue),
        vertex((0, -0.5), $b$, <b>, blue),
        vertex((1, 0), $c$, <c>, red),
        vertex((2, 0.8), $d$, <d>, blue),
        vertex((2, -0.8), $e$, <e>, blue),
        vertex((3, 0), $f$, <f>, red),
        vertex((4, 0), $g$, <g>, blue),
        edge(<a>, <b>),
        edge(<a>, <c>),
        edge(<b>, <c>),
        edge(<c>, <d>),
        edge(<c>, <e>),
        edge(<d>, <e>),
        edge(<d>, <f>),
        edge(<e>, <f>),
        edge(<f>, <g>, stroke: 4pt + orange),
      ),
      [
        - #Red[Cut vertices]: $c$, $f$
        - #text(fill: orange)[Bridge]: edge ${f, g}$
      ],
    )
  ]
]

// #Block(color: yellow)[
//   *Characterization:*
//   - Cut vertex $v$: lies on every path between some pair.
//   - Bridge $e$: lies on no cycle.
// ]

// #note[
//   Every bridge has an endpoint that is either a leaf or a cut vertex.
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
    #v(-1em)
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

#Red[$S = {a, b}$] is a $u$-$v$ separator (minimum: size 2).
#Green[$S' = {c, d}$] is also a $u$-$v$ separator (also size 2).

#note[
  A _minimum_ $u$-$v$ separator is one of smallest size.
  Its size determines how "well-connected" $u$ and $v$ are.
]

== Internally Disjoint Paths

#definition[
  Two $u$-$v$ paths are _internally vertex-disjoint_ if they share no vertices other than $u$ and $v$.

  Two $u$-$v$ paths are _edge-disjoint_ if they share no edges.
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
    #v(-2em)
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      vertex((0, 0), $u$, <u>, blue),
      vertex((1, 0.6), $a$, <a>, blue),
      vertex((1, -0.6), $b$, <b>, blue),
      vertex((2, 0), $v$, <v>, blue),
      edge(<u>, <a>, stroke: 2pt + red),
      edge(<a>, <v>, stroke: 2pt + red),
      edge(<u>, <b>, stroke: 2pt + green),
      edge(<b>, <v>, stroke: 2pt + green),
    )
  ]

  #text(fill: red)[Path 1: $u$-$a$-$v$] and #text(fill: green.darken(20%))[Path 2: $u$-$b$-$v$] are both _internally vertex-disjoint_ and _edge-disjoint_.
]

#Block(color: yellow)[
  *Key duality:* Separators _block_ paths; disjoint paths _survive_ removal of a few vertices/edges.

  _Menger's theorem quantifies this duality precisely._
]

== Vertex and Edge Connectivity

#definition[
  The _vertex connectivity_ $kappa(G)$ is the minimum size of a vertex set whose removal disconnects $G$ (or reduces it to one vertex).
]

#definition[
  The _edge connectivity_ $lambda(G)$ is the minimum size of an edge set whose removal disconnects $G$.
]

#example[
  #align(center)[
    #v(-2em)
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      [*Graph*], [*$kappa$*], [*$lambda$*], [*$delta$*],
      [$K_5$], [4], [4], [4],
      [$C_6$], [2], [2], [2],
      [Tree], [1], [1], [1],
      [Petersen], [3], [3], [3],
    )
  ]

  For $K_n$, we define $kappa(K_n) = n - 1$ (need to remove all but one vertex).
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

#Block(color: blue)[
  *Fault tolerance:* A $k$-connected network survives any $k - 1$ node failures.
]

== Whitney's Inequality

#theorem[Whitney's Inequality][
  For any graph $G$:
  $ kappa(G) <= lambda(G) <= delta(G) $
  where $delta(G)$ is the minimum degree.
]

#proof[
  - $lambda(G) <= delta(G)$:
    Let $v$ be a vertex of minimum degree.
    The set of all edges incident to $v$ is an edge cut of size $delta(G)$ (removing them isolates $v$).

  - $kappa(G) <= lambda(G)$:
    Let $F$ be a minimum edge cut separating $G$ into parts $A$ and $B$.
    We construct a vertex separator $S$ of size $<= |F|$: for each edge $e = {a, b}$ in $F$ with $a in A$ and $b in B$, include $b$ in $S$ (choosing the endpoint on one fixed side).
    Then $S$ separates any remaining vertex in $A$ from any remaining vertex in $B$, and $|S| <= |F|$. #qedhere
]

#pagebreak()

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint: blue) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .72em,
    name: name,
  )

  #grid(
    columns: 2,
    align: horizon,
    column-gutter: 2em,
    row-gutter: 1em,
    [
      #diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,

        // Outer cycle
        vertex((-90deg + 360deg / 5 * 0, 2), $1$, <p1>),
        vertex((-90deg + 360deg / 5 * 1, 2), $2$, <p2>),
        vertex((-90deg + 360deg / 5 * 2, 2), $3$, <p3>),
        vertex((-90deg + 360deg / 5 * 3, 2), $4$, <p4>),
        vertex((-90deg + 360deg / 5 * 4, 2), $5$, <p5>),

        // Inner star
        vertex((-90deg + 360deg / 5 * 0, 0.8), $1'$, <q1>, tint: green),
        vertex((-90deg + 360deg / 5 * 1, 0.8), $2'$, <q2>, tint: green),
        vertex((-90deg + 360deg / 5 * 2, 0.8), $3'$, <q3>, tint: green),
        vertex((-90deg + 360deg / 5 * 3, 0.8), $4'$, <q4>, tint: green),
        vertex((-90deg + 360deg / 5 * 4, 0.8), $5'$, <q5>, tint: green),

        edge(<p1>, <p2>),
        edge(<p2>, <p3>),
        edge(<p3>, <p4>),
        edge(<p4>, <p5>),
        edge(<p5>, <p1>),

        edge(<q1>, <q3>),
        edge(<q3>, <q5>),
        edge(<q5>, <q2>),
        edge(<q2>, <q4>),
        edge(<q4>, <q1>),

        edge(<p1>, <q1>),
        edge(<p2>, <q2>),
        edge(<p3>, <q3>),
        edge(<p4>, <q4>),
        edge(<p5>, <q5>),
      )

      *Petersen graph:* \
      $kappa = lambda = delta = 3$
    ],
    [
      #diagram(
        spacing: 2em,
        node-stroke: 1pt,
        edge-stroke: 1pt,

        vertex((-3, 1), $a$, <a>),
        vertex((-3, -1), $b$, <b>),
        vertex((-1, 1), $c$, <c>),
        vertex((-1, -1), $d$, <d>),
        vertex((1, 1), $e$, <e>),
        vertex((1, -1), $f$, <f>),
        vertex((3, 1), $g$, <g>),
        vertex((3, -1), $h$, <h>),
        vertex((0, 0), $v$, <v>, tint: red),

        // Left K4
        edge(<a>, <b>),
        edge(<a>, <c>),
        edge(<a>, <d>),
        edge(<b>, <c>),
        edge(<b>, <d>),
        edge(<c>, <d>),

        // Right K4
        edge(<e>, <f>),
        edge(<e>, <g>),
        edge(<e>, <h>),
        edge(<f>, <g>),
        edge(<f>, <h>),
        edge(<g>, <h>),

        // Attachments through v
        edge(<v>, <c>, stroke: 2pt + red),
        edge(<v>, <d>, stroke: 2pt + red),
        edge(<v>, <e>),
        edge(<v>, <f>),
        edge(<v>, <g>, bend: 10deg),
      )

      *Strict inequality example:* \
      $delta = 3$, $kappa = 1$, $lambda = 2$
    ],
  )
]

== Menger's Theorem (Vertex Form)

#theorem[Menger][
  Let $u, v$ be non-adjacent vertices in $G$. Then:
  $ max{"number of internally vertex-disjoint" u"-"v "paths"} = min{|S| : S "is a" u"-"v "separator"} $
]

In other words: the maximum number of paths from $u$ to $v$ that share _no internal vertices_ equals the minimum number of vertices needed to separate $u$ from $v$.

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
    #v(-2em)
    #grid(
      columns: 2,
      align: (center + horizon, center + top),
      column-gutter: 3em,
      row-gutter: 1em,
      diagram(
        spacing: (2em, 2em),
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-0.3, 0.5), $u$, <u>, blue),
        vertex((1, 1), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2.3, 0.5), $v$, <v>, blue),
        edge(<u>, <a>, stroke: 2pt + red),
        edge(<a>, <v>, stroke: 2pt + red),
        edge(<u>, <b>, stroke: 2pt + green),
        edge(<b>, <v>, stroke: 2pt + green),
        edge(<a>, <b>),
      ),
      diagram(
        spacing: (2em, 2em),
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((-0.3, 0.5), $u$, <u>, blue),
        vertex((1, 1), $a$, <a>, red),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2.3, 0.5), $v$, <v>, blue),
        edge(<u>, <a>),
        edge(<a>, <v>),
        edge(<u>, <b>),
        edge(<b>, <v>),
        edge(<a>, <b>),
      ),

      [*2 disjoint paths* (max)], [*Separator ${a}$* has size 1... \ but can we do better?],
    )
  ]

  Two disjoint $u$-$v$ paths exist (max = 2). Removing only $a$ leaves $u$-$b$-$v$ connected. Need $S = {a, b}$ to separate $=>$ min separator = 2.
]

== Menger's Theorem Visualized

#align(center + horizon)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.circle,
    radius: .8em,
    name: name,
  )
  #diagram(
    spacing: 2em,
    node-stroke: 1pt,
    edge-stroke: 1pt,
    vertex((-1, 0), $a$, <a>, blue),
    vertex((1.2, -0.5), $b$, <b>, blue),
    vertex((1, -2), $c$, <c>, blue),
    vertex((1.5, 1), $d$, <d>, blue),
    vertex((3.5, 3), $e$, <e>, blue),
    vertex((3.5, 0), $f$, <f>, blue),
    vertex((4, -2), $g$, <g>, blue),
    vertex((4.5, 0.5), $h$, <h>, blue),
    vertex((4, 1.5), $k$, <k>, blue),
    vertex((5, -0.5), $m$, <m>, blue),
    vertex((8, 0), $z$, <z>, blue),
    edge(<a>, <b>),
    edge(<a>, <c>, bend: 30deg),
    edge(<a>, <e>, bend: -30deg),
    edge(<a>, <d>),
    edge(<a>, <f>),
    edge(<b>, <c>),
    edge(<b>, <g>),
    edge(<c>, <g>),
    edge(<c>, <f>),
    edge(<d>, <e>),
    edge(<d>, <f>),
    edge(<e>, <k>),
    edge(<e>, <z>, bend: -30deg),
    edge(<f>, <k>),
    edge(<f>, <h>),
    edge(<f>, <m>),
    edge(<f>, <g>),
    edge(<g>, <d>),
    edge(<g>, <h>),
    edge(<g>, <m>),
    edge(<g>, <z>, bend: 30deg),
    edge(<h>, <k>),
    edge(<h>, <z>),
    edge(<k>, <z>, bend: -20deg),
    edge(<m>, <z>),
  )
]

== Menger's Theorem (Edge Form)

#theorem[Menger][
  For any distinct vertices $u, v$ in $G$:
  $ max{"number of edge-disjoint" u"-"v "paths"} = min{|F| : F "is a" u"-"v "edge cut"} $
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
    #grid(
      columns: 2,
      align: (center + horizon, center + top),
      column-gutter: 3em,
      row-gutter: 1em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0.5), $u$, <u>, blue),
        vertex((1, 1), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2, 0.5), $c$, <c>, blue),
        vertex((3, 0.5), $v$, <v>, blue),
        edge(<u>, <a>, stroke: 2pt + red),
        edge(<a>, <c>, stroke: 2pt + red),
        edge(<c>, <v>, stroke: 2pt + red),
        edge(<u>, <b>, stroke: 2pt + green),
        edge(<b>, <c>, stroke: 2pt + green),
        edge(<a>, <b>),
      ),
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        vertex((0, 0.5), $u$, <u>, blue),
        vertex((1, 1), $a$, <a>, blue),
        vertex((1, 0), $b$, <b>, blue),
        vertex((2, 0.5), $c$, <c>, blue),
        vertex((3, 0.5), $v$, <v>, blue),
        edge(<u>, <a>),
        edge(<a>, <c>, stroke: 3pt + orange),
        edge(<c>, <v>, stroke: 3pt + orange),
        edge(<u>, <b>),
        edge(<b>, <c>),
        edge(<a>, <b>),
      ),

      [*2 edge-disjoint paths* (max)], [*Min edge cut* of size 2],
    )
  ]

  Two edge-disjoint paths (may share vertices like $c$, but no edges). Min edge cut = 2.
]

== Menger's Theorem: Significance

#Block(color: green)[
  *Max-Flow Min-Cut duality:* Menger's theorem (1927) is equivalent to the Max-Flow Min-Cut theorem (Ford–Fulkerson, 1956) with unit capacities.
]

#Block(color: blue)[
  *Why this matters:*
  - _Network reliability:_ Independent routes between nodes
  - _Routing:_ Parallel data streams
  - _VLSI:_ Non-overlapping wire paths
  - _Algorithmic foundation:_ Connectivity decomposition
]

== Menger's Theorem: Corollaries

#theorem[Global Vertex Connectivity][
  A graph $G$ is $k$-connected if and only if every pair of distinct vertices is connected by at least $k$ internally vertex-disjoint paths.
]

#theorem[Global Edge Connectivity][
  A graph $G$ is $k$-edge-connected if and only if every pair of distinct vertices is connected by at least $k$ edge-disjoint paths.
]

#example[
  The cycle $C_5$ is 2-connected. For any two vertices, there are exactly 2 internally vertex-disjoint paths (the two arcs of the cycle). Removing any single vertex leaves a path --- still connected.
]

#example[
  $K_4$ is 3-connected. Between any two vertices, there are 3 internally disjoint paths (each through one of the three remaining vertices). Removing any 2 vertices leaves at least one edge --- still connected.
]

#Block(color: yellow)[
  *Intuition:* High connectivity = many independent routes. Menger explains Whitney's inequality:
  $kappa(G) <= lambda(G) <= delta(G)$.
]

== Blocks (2-Connected Components)

#definition[
  A _block_ of a graph $G$ is a maximal connected subgraph with no cut vertex (i.e., maximal 2-connected subgraph, or a bridge, or an isolated vertex).
]

#note[
  Every edge belongs to exactly one block. Blocks share at most one vertex (a cut vertex).
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
    #v(-1em)
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Block 1 (triangle)
      vertex((0, 0), <a>, blue),
      vertex((0.5, calc.cos(30deg)), <b>, blue),
      vertex((1, 0), <c>, purple),
      edge(<a>, <b>, stroke: blue),
      edge(<b>, <c>, stroke: blue),
      edge(<c>, <a>, stroke: blue),
      // Block 2 (pentagon)
      vertex((2, -0.5), <d>, green),
      vertex((1.5, 1), <e>, green),
      vertex((2.5, 1), <f>, green),
      vertex((3, 0), <g>, purple),
      edge(<c>, <d>, stroke: green),
      edge(<d>, <g>, stroke: green),
      edge(<e>, <c>, stroke: green),
      edge(<f>, <g>, stroke: green),
      edge(<e>, <f>, stroke: green),
      edge(<e>, <d>, stroke: green),
      // Block 3 (single edge = bridge)
      vertex((4, 0.5), <h>, orange),
      edge(<g>, <h>, stroke: orange),
    )
  ]
]

Three blocks: #text(fill: blue)[blue triangle], #text(fill: green.darken(20%))[green pentagon], #text(fill: orange)[orange bridge]. #text(fill: purple)[Purple] = cut vertices.

== Whitney's Characterization of 2-Connectivity

#theorem[Whitney, 1932][
  A graph $G$ with at least 3 vertices is 2-connected if and only if every pair of vertices lies on a common cycle.
]

#proof[
  ($arrow.double.r$) If $G$ is 2-connected, Menger gives 2 internally disjoint $u$-$v$ paths forming a cycle.

  ($arrow.double.l$) If every pair lies on a cycle, then removing any vertex $v$ leaves at least one path between any $u, w$ (via the cycle not passing through $v$). Hence no cut vertex exists.
  #qedhere
]

#Block(color: yellow)[
  *Insight:* Blocks are the "robust cores" --- any two vertices in a block lie on a common cycle.
]

== Block-Cut Tree

#definition[
  The _block-cut tree_ (or _BC-tree_) of a connected graph $G$ is a bipartite tree $T$ where:
  - One part contains a node for each _block_ of $G$.
  - The other part contains a node for each _cut vertex_ of $G$.
  - A block-node $B$ is adjacent to a cut-vertex-node $v$ iff $v in B$.
]

#example[
  #import fletcher: diagram, edge, node, shapes
  #align(center)[
    #v(-1em)
    #grid(
      columns: 2,
      align: horizon,
      column-gutter: 4em,
      [
        #let vertex(pos, label, name, tint) = blob(
          pos,
          label,
          tint: tint,
          shape: shapes.circle,
          radius: .7em,
          name: name,
        )
        #diagram(
          spacing: 2em,
          node-stroke: 1pt,
          edge-stroke: 1pt,
          // Block 1
          vertex((0, 0), $a$, <a>, blue),
          vertex((1, 0), $b$, <b>, purple),
          edge(<a>, <b>, stroke: blue),
          // Block 2 (triangle)
          vertex((2, 0.5), $c$, <c>, purple),
          vertex((2, -0.5), $d$, <d>, green),
          edge(<b>, <c>, stroke: green),
          edge(<b>, <d>, stroke: green),
          edge(<c>, <d>, stroke: green),
          // Block 3
          vertex((3, 0), $e$, <e>, orange),
          edge(<c>, <e>, stroke: orange),
        )

        *Graph $G$*
      ],
      [
        #let bnode(pos, label, name, tint) = blob(
          pos,
          label,
          tint: tint,
          shape: shapes.rect,
          name: name,
        )
        #let cnode(pos, label, name) = blob(
          pos,
          label,
          tint: purple,
          shape: shapes.circle,
          radius: 0.9em,
          name: name,
        )
        #diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          bnode((0, 0), $B_1$, <B1>, blue),
          cnode((1, 0), $b$, <b>),
          bnode((2, 0), $B_2$, <B2>, green),
          cnode((3, 0), $c$, <c>),
          bnode((4, 0), $B_3$, <B3>, orange),
          edge(<B1>, <b>),
          edge(<b>, <B2>),
          edge(<B2>, <c>),
          edge(<c>, <B3>),
        )

        *Block-Cut Tree*
      ],
    )
  ]
]

#Block(color: yellow)[
  *Applications:* Dynamic programming on the block-cut tree solves many problems on general graphs.
]

== Islands (2-Edge-Connected Components)

#definition[
  An _island_ (or _2-edge-connected component_) is a maximal connected subgraph with no bridges.

  Equivalently: vertices $u$ and $v$ are in the same island iff they lie on a common circuit.
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
      // Island 1
      vertex((0, 0), $a$, <a>, blue),
      vertex((0.8, 0), $b$, <b>, blue),
      vertex((0.4, 0.7), $c$, <c>, blue),
      edge(<a>, <b>),
      edge(<b>, <c>),
      edge(<c>, <a>),
      // Island 2
      vertex((1.6, 0), $d$, <d>, green),
      vertex((2.4, 0), $e$, <e>, green),
      vertex((2, 0.7), $f$, <f>, green),
      // Bridge
      edge(<b>, <d>, stroke: 3pt + orange),
      edge(<d>, <e>),
      edge(<e>, <f>),
      edge(<f>, <d>),
      // Bridge
      vertex((3.2, 0.35), $g$, <g>, red),
      edge(<e>, <g>, stroke: 3pt + orange),
    )
  ]

  Three islands: #text(fill: blue)[${a,b,c}$], #text(fill: green.darken(20%))[${d,e,f}$], #text(fill: red)[${g}$]. The #text(fill: orange)[orange edges] are bridges.
]

#note[
  Islands partition vertices (no sharing). Separated by bridges.
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
  #let bnode(pos, label, name, tint) = blob(
    pos,
    label,
    tint: tint,
    shape: shapes.rect,
    name: name,
  )
  #align(center)[
    #v(-2em)
    #grid(
      columns: 2,
      align: (center + horizon, center + top),
      column-gutter: 3em,
      row-gutter: 1em,
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        // Island 1
        vertex((0, 0), $a$, <a>, blue),
        vertex((0.8, 0), $b$, <b>, blue),
        vertex((0.4, 0.7), $c$, <c>, blue),
        edge(<a>, <b>),
        edge(<b>, <c>),
        edge(<c>, <a>),
        // Bridge
        edge(<b>, <d>, stroke: 2pt + orange),
        // Island 2
        vertex((1.6, 0), $d$, <d>, green),
        vertex((2.4, 0), $e$, <e>, green),
        vertex((2, 0.7), $f$, <f>, green),
        edge(<d>, <e>),
        edge(<e>, <f>),
        edge(<f>, <d>),
        // Bridge
        vertex((3.2, 0.35), $g$, <g>, red),
        edge(<e>, <g>, stroke: 2pt + orange),
      ),
      diagram(
        node-stroke: 1pt,
        edge-stroke: 1pt,
        bnode((0, 0), $I_1$, <I1>, blue),
        bnode((1.5, 0), $I_2$, <I2>, green),
        bnode((3, 0), $I_3$, <I3>, red),
        edge(<I1>, <I2>),
        edge(<I2>, <I3>),
      ),

      [*Graph $G$*], [*Bridge Tree*],
    )
  ]
]

#v(-0.3em)
#Block(color: blue)[
  // *Analogy:*
  - Block-cut tree: decomposition by _cut vertices_ into _blocks_.
  - Bridge tree: decomposition by _bridges_ into _islands_.
]
#v(-.7em)

#theorem[
  A graph is 2-edge-connected iff its bridge tree is a single vertex (no bridges).

  A graph is 2-vertex-connected iff its block-cut tree has a single block node.
]

== Summary: Paths, Trees, and Connectivity

#columns(2)[
  *Paths & Distance*
  - Walk → Trail → Path
  - $dist(u, v)$: shortest path (metric)
  - Eccentricity, radius, diameter, center

  *Trees*
  - Connected + acyclic
  - $n$ vertices, $n-1$ edges
  - Spanning trees
  - Fundamental cycles: $m - n + 1$

  #colbreak()

  *Connectivity*
  - Cut vertices, bridges
  - $kappa(G) <= lambda(G) <= delta(G)$
  - *Menger:* max disjoint paths = min separator
  - Blocks: 2-connected components
  - Islands: 2-edge-connected
]

#Block(color: yellow)[
  *The big picture:* Menger's theorem reveals the fundamental duality between _independent routes_ and _bottlenecks_. This forms the foundation for network flow theory.
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


= Bipartite Graphs and Matchings
#focus-slide(
  // TODO: epigraph
  scholars: (
    (
      name: "Dénes Kőnig",
      image: image("assets/Denes_Konig.jpg"),
    ),
    (
      name: "Philip Hall",
      image: image("assets/Philip_Hall.jpg"),
    ),
    (
      name: "Jack Edmonds",
      image: image("assets/Jack_Edmonds.jpg"),
    ),
    (
      name: "Harold Kuhn",
      image: image("assets/Harold_Kuhn.jpg"),
    ),
    (
      name: "Leonid Mirsky",
      image: image("assets/Leonid_Mirsky.jpg"),
    ),
  ),
)

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

#proof[(sketch)][
  _($arrow.r.double$)_
  If $G = pair(X union.sq Y, E)$ is bipartite, every edge goes from $X$ to $Y$.
  Hence, along any cycle, vertices must alternate between the two parts.
  Therefore every cycle has even length.

  _($arrow.l.double$)_
  Assume $G$ has no odd cycle.
  In each connected component, pick a root $r$ and partition the vertices by _parity_ of distance from $r$:
  $X = {v | dist(r, v) "is even"}$ and $Y = {v | dist(r, v) "is odd"}$.
  Suppose an edge joined two vertices of the same parity.
  Together with shortest root-paths, this gives a closed walk of odd length, so $G$ contains an odd cycle --- contradiction.
  So all edges go between $X$ and $Y$, and $G$ is bipartite.
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
        edge(<b>, <e>),
        edge(<c>, <e>, stroke: 3pt + orange),
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
  Let $G = pair(X union Y, E)$ be a bipartite graph. For a subset $S subset.eq X$, define its _neighborhood_:
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
  - Therefore: $|N(S)| >= |M(S)| = |S|$. #h(1fr) #qedhere
]

*Direction ($arrow.l.double$):*
If Hall's condition holds, then a matching saturating $X$ exists.

This is the interesting direction.
We use *strong induction* on $n = |X|$.

== Proof (Sufficiency): Base & Strategy

*Base Case* ($n = 1$):
If $X = {x}$, Hall's condition gives $|N({x})| >= 1$, so $x$ has a neighbor $y$. The edge ${x,y}$ is a matching.

*Inductive Hypothesis*:
Assume the theorem holds for all bipartite graphs with $|X| < n$.

*Inductive Step*:
Consider $G$ with $|X| = n >= 2$. We split into two cases:
- *Case 1:* Every proper subset $S$ has _surplus_ neighbors: $|N(S)| >= |S| + 1$.
- *Case 2:* Some proper subset $S$ is _tight_: $|N(S)| = |S|$.

== Proof: Case 1 (Surplus)

*Case 1:* For all $emptyset != S subset.neq X$, we have $|N(S)| >= |S| + 1$.

_Strategy:_ Match an arbitrary edge, then use induction on the smaller graph.

+ Pick any edge ${x, y} in E$ (exists because $X != emptyset$ and Hall's condition ensures connectivity).
+ Remove both endpoints: let $G' = G - {x, y}$ and $X' = X without x$.
+ *Verify Hall's condition in $G'$:* Let $S' subset.eq X'$ be arbitrary.
  - In $G$, we have $|N_G (S')| >= |S'| + 1$ (since $S' subset.neq X$).
  - Removing $y$ from $Y$ reduces $|N(S')|$ by at most 1.
  - So $|N_G' (S')| >= |N_G (S')| - 1 >= (|S'| + 1) - 1 = |S'|$.
+ By induction, $G'$ has a matching $M'$ saturating $X'$.
+ Then $M = M' union {{x, y}}$ saturates $X$.

== Proof: Case 2 (Tight Subset)

*Case 2:* There exists $emptyset != S_0 subset.neq X$ such that $|N(S_0)| = |S_0|$.

_Strategy:_ Match $S_0$ independently, then match the rest.

+ *Match $S_0$:*
  The induced subgraph $G[S_0 union N(S_0)]$ satisfies Hall's condition (inherited from $G$).
  Since $|S_0| < n$, by induction there exists a matching $M_1$ saturating $S_0$.

+ *Match the remainder:*
  Let $G' = G - S_0 - N(S_0)$ and $X' = X without S_0$.
  We verify Hall's condition for $G'$.
  Let $A subset.eq X'$ be arbitrary.
  - In $G$: $|N_G (A union S_0)| >= |A union S_0| = |A| + |S_0|$ (Hall's condition).
  - But $N_G (A union S_0) = N_G (A) union N_G (S_0) = N_G (A) union N(S_0)$ (disjoint by construction).
  - So $|N_G (A)| + |N(S_0)| >= |A| + |S_0|$.
  - Since $|N(S_0)| = |S_0|$, we get $|N_G (A)| >= |A|$.
  - In $G'$, the neighbors of $A$ are $N_G' (A) = N_G (A) without N(S_0)$, but vertices in $N_G (A)$ were not in $N(S_0)$ (otherwise contradiction).
    So $|N_G' (A)| = |N_G (A)| >= |A|$.

+ By induction, $G'$ has a matching $M_2$ saturating $X'$.

+ Then $M = M_1 union M_2$ saturates $X$.

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
      grid(
        columns: 2,
        column-gutter: 1em,
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
          edge(<b>, <d>, bend: -100deg),
        ),
        diagram(
          node-stroke: 1pt,
          edge-stroke: 1pt,
          vertex((0.5, 0), <a>),
          vertex((0.5, 0.65), <b>),
          vertex((1, 1), <c>),
          vertex((0, 1), <d>),
          edge(<a>, <b>),
          edge(<b>, <c>),
          edge(<c>, <d>),
          edge(<d>, <a>),
          edge(<a>, <c>),
          edge(<b>, <d>),
        ),
      ),
      [$K_4$ planar embeddings],
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
  *The dual view:* Coloring vertices of a planar graph = coloring regions of a map so adjacent regions differ. Every map needs at most 4 colors!
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

#theorem[Ramsey's Theorem][
  For any positive integers $r$ and $s$, there exists a number $R(r, s)$ such that any 2-coloring of the edges of $K_n$ (with $n >= R(r, s)$) contains either a red $K_r$ or a blue $K_s$.
]

#example[
  $R(3, 3) = 6$: Among any 6 people, there are either 3 mutual friends or 3 mutual strangers.
]

#Block(color: orange)[
  *Warning:* Computing Ramsey numbers is extremely hard. We know $R(3,3) = 6$, $R(4,4) = 18$, but $R(5,5)$ is unknown!

  Famous quote by Erdős: "Suppose aliens invade the earth and threaten to obliterate it in a year's time unless human beings can find $R(5,5)$. We could marshal the world's best minds and fastest computers, and within a year we could probably calculate the value. If they digit $R(6,6)$, we would have no choice but to launch a preemptive attack."
]


= Network Flows
#focus-slide(
  epigraph: [The whole is more than the sum of its parts --- \ but the flow is limited by the narrowest channel.],
)

== Motivation: Moving Things Through Networks

Many _real-world_ problems ask: _"how much can move from A to B through a network?"_

#grid(
  columns: 3,
  gutter: 2em,
  [
    *Water networks* \
    Pipes with limited diameter \ connect a reservoir to a city.

    _How much water \ per second can flow?_
  ],
  [
    *Internet routing* \
    Routers connected by links \ with limited bandwidth.

    _How much data \ can be transferred?_
  ],
  [
    *Supply chains* \
    Factories, warehouses, trucks \ with limited capacity.

    _How many goods \ can be shipped?_
  ],
)

#v(0.5em)
#Block(color: yellow)[
  *The abstraction:* All three are instances of the same mathematical structure --- a _flow network_. \
  Once we solve the abstract problem, all concrete instances are solved.
]

#Block(color: blue)[
  *What we'll prove:* The maximum amount of flow you can push equals the capacity of the "tightest bottleneck" --- made precise by the *Max-Flow Min-Cut Theorem*.
]

== Flow Network

#definition[
  A _flow network_ is a tuple $N = angle.l V, E, s, t, c angle.r$ where:
  - $G = angle.l V, E angle.r$ is a directed graph,
  - $s in V$ is the _source_ and $t in V$ is the _sink_ (with $s != t$),
  - $c : E to RR_(>=0)$ is the _capacity_ function assigning a non-negative real number to each edge.

  We extend $c$ to all pairs: $c(u, v) = 0$ whenever $(u, v) notin E$.
]

#import fletcher: diagram, edge, node
#align(center)[
  #diagram(
    spacing: (4em, 2em),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0, 0), $s$, tint: green, name: <s>),
    blob((3, 0), $t$, tint: red, name: <t>),
    blob((1, -1), $a$, tint: blue, name: <na>),
    blob((1, 1), $b$, tint: blue, name: <nb>),
    blob((2, -1), $c$, tint: blue, name: <nc>),
    blob((2, 1), $d$, tint: blue, name: <nd>),
    edge(<s>, <na>, "-}>", [$16$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<s>, <nb>, "-}>", [$13$], label-side: center, label-angle: auto, bend: -30deg),
    edge(<na>, <nc>, "-}>", [$12$], label-side: center, label-angle: auto),
    edge(<nb>, <na>, "-}>", [$4$], label-side: center),
    edge(<nb>, <nd>, "-}>", [$14$], label-side: center, label-angle: auto),
    edge(<nc>, <nb>, "-}>", [$9$], label-side: center, label-angle: auto),
    edge(<nc>, <t>, "-}>", [$20$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<nd>, <nc>, "-}>", [$7$], label-side: center),
    edge(<nd>, <t>, "-}>", [$4$], label-side: center, label-angle: auto, bend: -30deg),
  )
]

#note[
  We assume every vertex lies on some $s$-$t$ path (no isolated or useless vertices).
]

== Flow

#definition[
  A _flow_ in a network $N$ is a function $f : E to RR_(>=0)$ satisfying:
  + *Capacity constraint:* $0 <= f(e) <= c(e)$ for every edge $e in E$.
  + *Flow conservation:* For every internal vertex $v in V setminus {s, t}$:
    $
      underbrace(sum_(e in "in"(v)) f(e), "flow into" v) = underbrace(sum_(e in "out"(v)) f(e), "flow out of" v)
    $
    where $"in"(v)$ and $"out"(v)$ denote the sets of incoming and outgoing edges of $v$.
]

#Block(color: yellow)[
  Flow conservation embodies _"what goes in --- must come out"_.
  - No _internal_ vertex stores or creates flow.
  - Only $s$ _produces_ flow and $t$ _absorbs_ it.
]

== Flow Value

// #definition[Local notation][
//   For a vertex $v$:
//   - $"out"(v)$ is the set of edges directed out of $v$;
//   - $"in"(v)$ is the set of edges directed into $v$.
// ]

#definition[
  The _value_ of a flow $f$, denoted $|f|$, is the net flow out of the source:
  $
    |f| = underbrace(sum_(e in "out"(s)) f(e), "out of" s)
    - underbrace(sum_(e in "in"(s)) f(e), "into" s "(= 0 if no back-edges)")
  $
]

#definition[Maximum Flow Problem][
  Given a flow network $N$, find a flow $f$ that _maximizes_ $|f|$.
]

== Flow Conservation Theorem

#theorem[
  For any feasible flow $f$, the net flow out of $s$ equals the net flow into $t$:
  $
    |f| = sum_(e in "in"(t)) f(e) - sum_(e in "out"(t)) f(e)
  $
]

#proof[
  First, define the _net flow_ at a vertex $v$:
  $
    net(v) = sum_(e in "out"(v)) f(e) - sum_(e in "in"(v)) f(e)
  $

  Summing over all vertices gives zero:
  $
    sum_(v in V) net(v)
    = sum_(v in V) sum_(e in "out"(v)) f(e)
    - sum_(v in V) sum_(e in "in"(v)) f(e)
    = 0,
  $
  because each edge $e=(u,w)$ appears once with $+f(e)$ (as outgoing from $u$) and once with $-f(e)$ (as incoming to $w$).

  For every internal vertex $v in V setminus {s,t}$, flow conservation implies $net(v)=0$, hence
  $
    sum_(v in V) net(v) = net(s) + net(t).
  $
  Therefore $net(s) + net(t) = 0$, i.e.
  $
    sum_(e in "out"(s)) f(e) - sum_(e in "in"(s)) f(e)
    = sum_(e in "in"(t)) f(e) - sum_(e in "out"(t)) f(e).
  $
  The left side is $|f|$ by definition, so
  $
    |f| = sum_(e in "in"(t)) f(e) - sum_(e in "out"(t)) f(e).
  $
]

== A Feasible Flow: Example

Each edge is labelled $f slash c$ (flow / capacity).
Edges carrying strictly less than capacity are shown normally; _saturated_ edges ($f = c$) are red.

#import fletcher: diagram, edge, node
#align(center)[
  #diagram(
    spacing: (4em, 2em),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0, 0), $s$, tint: green, name: <s>),
    blob((3, 0), $t$, tint: red, name: <t>),
    blob((1, -1), $a$, tint: blue, name: <na>),
    blob((1, 1), $b$, tint: blue, name: <nb>),
    blob((2, -1), $c$, tint: blue, name: <nc>),
    blob((2, 1), $d$, tint: blue, name: <nd>),
    edge(<s>, <na>, "-}>", [$12 slash 16$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<s>, <nb>, "-}>", [$11 slash 13$], label-side: center, label-angle: auto, bend: -30deg),
    edge(<na>, <nc>, "-}>", [$12 slash 12$], label-side: center, label-angle: auto, stroke: 2pt + red),
    edge(<nb>, <na>, "-}>", [$0 slash 4$], label-side: center),
    edge(<nb>, <nd>, "-}>", [$11 slash 14$], label-side: center, label-angle: auto),
    edge(<nc>, <nb>, "-}>", [$0 slash 9$], label-side: center, label-angle: auto),
    edge(<nc>, <t>, "-}>", [$19 slash 20$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<nd>, <nc>, "-}>", [$7 slash 7$], label-side: center, stroke: 2pt + red),
    edge(<nd>, <t>, "-}>", [$4 slash 4$], label-side: center, label-angle: auto, bend: -30deg, stroke: 2pt + red),
  )
]


*Flow value:* $|f| = 12 + 11 = 23$.

This flow turns out to be _maximum_ --- we will prove this shortly using the Min-Cut Theorem.

== Cuts

#definition[
  Let $N = (V,E,s,t,c)$ be a flow network.

  An _$s$-$t$ cut_ is an ordered pair $(A,B)$ such that
  $
    A union B = V,
    quad
    A inter B = emptyset,
    quad
    s in A, quad t in B.
  $
]

#definition[
  For a cut $(A,B)$, define the directed boundary edge sets:
  $
    delta^+(A) & := { (u,v) in E | u in A, v in B }, \
    delta^-(A) & := { (u,v) in E | u in B, v in A }.
  $
]

== Cut Capacity

#definition[
  The _capacity_ of an $s$-$t$ cut $(A,B)$ is
  $
    c(A,B) := sum_((u,v) in delta^+(A)) c(u,v).
  $
  Equivalently,
  $
    c(A,B) = sum_((u,v) in E,\ u in A,\ v in B) c(u,v).
  $
]

#note[
  Only edges _from $A$ to $B$_ count --- edges from $B$ to $A$ do not contribute to cut capacity.
]

#import fletcher: diagram, edge, node
#align(center)[
  #diagram(
    spacing: (4em, 2em),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0, 0), $s$, tint: green, name: <s>),
    blob((3, 0), $t$, tint: red, name: <t>),
    blob((1, -1), $a$, tint: green, name: <na>),
    blob((1, 1), $b$, tint: green, name: <nb>),
    blob((2, -1), $c$, tint: red, name: <nc>),
    blob((2, 1), $d$, tint: red, name: <nd>),
    edge(<s>, <na>, "-}>", [$16$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<s>, <nb>, "-}>", [$13$], label-side: center, label-angle: auto, bend: -30deg),
    edge(<na>, <nc>, "-}>", [$12$], label-side: center, label-angle: auto, stroke: 2pt + red),
    edge(<nb>, <na>, "-}>", [$4$], label-side: center),
    edge(<nb>, <nd>, "-}>", [$14$], label-side: center, label-angle: auto, stroke: 2pt + red),
    edge(<nc>, <nb>, "-}>", [$9$], label-side: center, label-angle: auto, stroke: gray),
    edge(<nc>, <t>, "-}>", [$20$], label-side: center, label-angle: auto, bend: 30deg),
    edge(<nd>, <nc>, "-}>", [$7$], label-side: center),
    edge(<nd>, <t>, "-}>", [$4$], label-side: center, label-angle: auto, bend: -30deg),
  )
]

- Cut $(A, B)$ with $A = {#Green[$s, a, b$]}$, $B = {#Red[$c, d, t$]}$.
- Red edges cross #text(green.darken(15%))[$A$]~$arrow$~#text(red.darken(15%))[$B$]: capacity $12 + 14 = 26$.
- The gray back-edge $c arrow b$ (from $B$ to $A$) does _not_ count.

#Block(color: blue)[
  Removing all $A to B$ edges _severs_ the network --- no flow can reach $t$ from $s$.

  The _cut capacity_ is the total pipe capacity you must cut to stop all flow.
]

== Net Flow Across a Cut

#definition[
  Given a flow $f$ and a cut $(A,B)$, the _net flow across the cut_ is
  $
    f(A,B) := sum_(e in delta^+(A)) f(e) - sum_(e in delta^-(A)) f(e)
  $
]

#theorem[
  For any feasible flow $f$ and any $s$-$t$ cut $(A,B)$:
  $
    f(A,B) = |f|
  $
]

#proof[
  Let $S := sum_(v in A) [limits(sum)_(e in "out"(v)) f(e) - limits(sum)_(e in "in"(v)) f(e)]$.

  Expanding by edges, all terms from edges with both endpoints in $A$ cancel, hence:
  $
    S = sum_((u,v) in delta^+(A)) f(u,v) - sum_((u,v) in delta^-(A)) f(u,v)
    = f(A,B).
  $

  #colbreak()

  Also,
  $
    S = [sum_(e in "out"(s)) f(e) - sum_(e in "in"(s)) f(e)]
    + sum_(v in A setminus {s}) [sum_(e in "out"(v)) f(e) - sum_(e in "in"(v)) f(e)].
  $
  Since $t in B$, every $v in A setminus {s}$ is internal.
  By flow conservation:
  $
    sum_(e in "out"(v)) f(e) - sum_(e in "in"(v)) f(e) = 0
  $
  Therefore,
  $
    S = sum_(e in "out"(s)) f(e) - sum_(e in "in"(s)) f(e) = |f|.
  $

  Thus $f(A,B) = S = |f|$
  $
    f(A,B) = |f|
    #qedhere
  $
]

#Block(color: yellow)[
  *Key corollary:* For any flow $f$ and any cut $(A,B)$:
  $
    |f| = f(A,B) <= c(A,B)
  $
  Every cut gives an _upper bound_ on the maximum flow value.
]

== Minimum Cut

#definition[
  The _minimum $s$-$t$ cut_ is the $s$-$t$ cut with the smallest capacity:
  $
    c^* = min_((A,B):, s in A,, t in B) c(A, B)
  $
]

#Block(color: blue)[
  *Consequence of the upper bound:*
  Every flow $f$ satisfies $|f| <= c(A,B)$ for every cut $(A,B)$.

  In particular, $|f| <= c^*$ --- no flow can exceed the minimum cut capacity.

  *The central question:* can we always achieve equality? \

  --- Yes! This is the *Max-Flow Min-Cut Theorem*.
]

== Residual Network

To find maximum flows, we need to answer: _"where can we still push more flow?"_

#v(-0.5em)

#definition[
  Given a flow $f$ in network $N$, the _residual capacity_ of a pair $(u, v)$ is:
  $ c_f (u, v) = c(u, v) - f(u, v) $
  This covers both directions:
  - if $(u,v) in E$ then $c_f$ is the _remaining_ room (non-filled capacity);
  - if $(v,u) in E$ but $(u,v) notin E$, then $c_f (u,v) = f(v,u)$ (the flow we can "_cancel_" or "_undo_").
]

#v(-0.5em)

#definition[
  The _residual network_ $N_f$ consists of all pairs $(u,v)$ with $c_f (u,v) > 0$:
  - _Forward edge_ $(u,v)$: present when $f(u,v) < c(u,v)$, with capacity $c(u,v) - f(u,v)$.
  - _Backward edge_ $(v,u)$: present when $f(u,v) > 0$, with capacity $f(u,v)$.
]

#place(dy: 1em)[
  #Block(color: yellow)[
    - A _forward_ edge says "I can send more flow this way."
    - A _backward_ edge says "I can reduce the flow on this edge."
  ]
]

== Residual Network: Example

#align(center + horizon)[
  #import fletcher: diagram, edge, node
  #grid(
    columns: 2,
    align: left + top,
    column-gutter: 4em,
    [
      #align(center)[
        *Network with flow $f$* \
        #diagram(
          spacing: (5em, 2em),
          node-shape: fletcher.shapes.circle,
          edge-stroke: 1pt,
          blob((0, 0), $s$, tint: green, name: <s>),
          blob((2, 0), $t$, tint: red, name: <t>),
          blob((1, -1), $a$, tint: blue, name: <na>),
          blob((1, 1), $b$, tint: blue, name: <nb>),
          edge(
            <s>,
            <na>,
            "-}>",
            [$20 slash 20$],
            label-side: center,
            label-angle: auto,
            stroke: 2pt + red,
            bend: 30deg,
          ),
          edge(
            <s>,
            <nb>,
            "-}>",
            [$0 slash 10$],
            label-side: center,
            label-angle: auto,
            bend: -30deg,
          ),
          edge(
            <na>,
            <nb>,
            "-}>",
            [$20 slash 30$],
            label-side: center,
          ),
          edge(
            <na>,
            <t>,
            "-}>",
            [$0 slash 10$],
            label-side: center,
            label-angle: auto,
            bend: 30deg,
          ),
          edge(
            <nb>,
            <t>,
            "-}>",
            [$20 slash 20$],
            label-side: center,
            label-angle: auto,
            stroke: 2pt + red,
            bend: -30deg,
          ),
        )
      ]

      $|f| = 20$; saturated edges are #Red[red].
    ],
    [
      #align(center)[
        *Residual network $N_f$* \
        #diagram(
          spacing: (5em, 2em),
          node-shape: fletcher.shapes.circle,
          edge-stroke: 1pt,
          blob((0, 0), $s$, tint: green, name: <s>),
          blob((2, 0), $t$, tint: red, name: <t>),
          blob((1, -1), $a$, tint: blue, name: <na>),
          blob((1, 1), $b$, tint: blue, name: <nb>),
          edge(
            <s>,
            <na>,
            "<{-",
            [$20$],
            label-side: center,
            label-angle: auto,
            stroke: red,
            bend: 30deg,
          ),
          edge(
            <s>,
            <nb>,
            "-}>",
            [$10$],
            label-side: center,
            label-angle: auto,
            bend: -30deg,
          ),
          edge(
            <na>,
            <nb>,
            "-}>",
            [$10$],
            label-side: center,
            bend: -30deg,
          ),
          edge(
            <na>,
            <nb>,
            "<{-",
            [$20$],
            label-side: center,
            stroke: red,
            bend: 30deg,
          ),
          edge(
            <na>,
            <t>,
            "-}>",
            [$10$],
            label-side: center,
            label-angle: auto,
            bend: 30deg,
          ),
          edge(
            <nb>,
            <t>,
            "<{-",
            [$20$],
            label-side: center,
            label-angle: auto,
            stroke: red,
            bend: -30deg,
          ),
        )
      ]

      #Red[Red] backward edges: "undo" capacity.

      Path $s -> b -> a -> t$ exists in $N_f$: \
      an *augmenting path* with bottleneck 10!
    ],
  )
]

== Augmenting Paths

#definition[
  An _augmenting path_ is an $s$-$t$ path $P$ in the residual network $N_f$.
]

#note[
  Every edge in $P$ has positive residual capacity.
]

#definition[
  The _bottleneck_ of $P$ is $Delta = limits(min)_(e in P) c_f (e) > 0$.
]

// TODO: visualize augmenting path and bottleneck

#pagebreak()

#theorem[
  If $P$ is an augmenting path with _positive bottleneck_ $Delta > 0$, then the _augmented flow_ $f'$ (defined below) is a valid flow in $N$ with $|f'| = |f| + Delta$.
  $
    f'(u,v) = cases(
      f(u,v) + Delta & "if" (u,v) in P,
      f(u,v) - Delta & "if" (v,u) in P,
      f(u,v) & "otherwise"
    )
  $
]

*Proof:*
- *Capacity:*
  For a forward path edge $(u,v)$:
  $f'(u,v) = f(u,v) + Delta <= f(u,v) + c_f (u,v) = c(u,v)$ and $f'(u,v) >= 0$.
  For a backward path edge $(v,u) in P$ (i.e., $(u,v)$ is a real edge used in reverse): $f'(u,v) = f(u,v) - Delta >= 0$ since $Delta <= c_f (v,u) = f(u,v)$.

- *Conservation:*
  Each internal vertex $v$ of $P$ has exactly one edge of $P$ entering and one leaving.
  The $+Delta$ and $-Delta$ contributions cancel, so conservation is preserved.

- *Value:*
  The first edge of $P$ out of $s$ is a forward edge (since $s$ has no incoming edges), so $|f'| = |f| + Delta$.

== Ford-Fulkerson Algorithm

#Block(color: yellow)[
  *Idea:* Repeatedly find augmenting paths in the residual network and push flow along them until no augmenting path exists.
]

#lovelace.pseudocode-list(hooks: 0.5em)[
  - *Input:* Flow network $N = angle.l V, E, s, t, c angle.r$
  - *Output:* Maximum flow $f$
  + Set $f(e) = 0$ for all $e in E$
  + *while* there exists an $s$-$t$ path $P$ in residual network $N_f$ *do*
    + Let $Delta = min_(e in P) c_f (e)$ #h(1em) _(bottleneck)_
    + *for each* edge $(u,v) in P$ *do*
      + $f(u,v) := f(u,v) + Delta$
      + $f(v,u) := f(v,u) - Delta$ #h(1em) _(skew-symmetry)_
  + *return* $f$
]

#note(title: "Termination condition")[
  For integer capacities, each iteration increases $|f|$ by at least 1, so the algorithm terminates in at most $|f^*|$ steps.
]

#Block(color: orange)[
  *Warning:*
  With irrational capacities, Ford-Fulkerson may not terminate --- augmenting paths can reduce flow along one edge while increasing along another in an infinite cycle. \
  This motivates Edmonds-Karp (always use BFS).
]

== Ford-Fulkerson: Worked Example

#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #let vertex(pos, name, label, color, ..args) = blob(
    pos,
    label,
    name: name,
    tint: color,
    radius: 8pt,
    ..args,
  )
  #grid(
    columns: 3,
    column-gutter: 1em,
    align: top,
    [
      *Step 0: $|f| = 0$*

      #diagram(
        spacing: (2em, 2em),
        node-shape: shapes.circle,
        edge-stroke: 1pt,
        vertex((0, 0), <s>, $s$, green),
        vertex((3, 0), <t>, $t$, red),
        vertex((1, -1), <na>, $a$, blue),
        vertex((1, 1), <nb>, $b$, blue),
        vertex((2, -1), <nc>, $c$, blue),
        vertex((2, 1), <nd>, $d$, blue),
        edge(<s>, <na>, "-}>", [$4$], label-side: center, label-angle: auto, bend: 20deg),
        edge(<s>, <nb>, "-}>", [$2$], label-side: center, label-angle: auto, bend: -20deg),
        edge(<na>, <nc>, "-}>", [$3$], label-side: center, label-angle: auto),
        edge(<nb>, <nd>, "-}>", [$3$], label-side: center, label-angle: auto),
        edge(<nb>, <nc>, "-}>", [$2$], label-side: center, label-angle: auto, bend: -20deg),
        edge(<nc>, <nb>, "-}>", [$1$], label-side: center, label-angle: auto, bend: -20deg),
        edge(<nc>, <t>, "-}>", [$2$], label-side: center, label-angle: auto, bend: 20deg),
        edge(<nd>, <t>, "-}>", [$4$], label-side: center, label-angle: auto, bend: -20deg),
      )
    ],
    [
      *Step 1: $s -> b -> c -> t$, $Delta = 2$*

      #diagram(
        spacing: (3em, 2em),
        node-shape: shapes.circle,
        edge-stroke: 1pt,
        vertex((0, 0), <s>, $s$, green),
        vertex((3, 0), <t>, $t$, red),
        vertex((1, -1), <na>, $a$, blue),
        vertex((1, 1), <nb>, $b$, blue),
        vertex((2, -1), <nc>, $c$, blue),
        vertex((2, 1), <nd>, $d$, blue),
        edge(<s>, <na>, "-}>", [$0 slash 4$], label-side: center, label-angle: auto, bend: 20deg),
        edge(
          <s>,
          <nb>,
          "-}>",
          [$2 slash 2$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: -20deg,
        ),
        edge(<na>, <nc>, "-}>", [$0 slash 3$], label-side: center, label-angle: auto),
        edge(<nb>, <nd>, "-}>", [$0 slash 3$], label-side: center, label-angle: auto),
        edge(
          <nb>,
          <nc>,
          "-}>",
          [$2 slash 2$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: -20deg,
        ),
        edge(<nc>, <nb>, "-}>", [$0 slash 1$], label-side: center, label-angle: auto, bend: -20deg),
        edge(
          <nc>,
          <t>,
          "-}>",
          [$2 slash 2$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: 20deg,
        ),
        edge(<nd>, <t>, "-}>", [$0 slash 4$], label-side: center, label-angle: auto, bend: -20deg),
      )
    ],
    [
      *Step 2: $s -> a -> c -> b -> d -> t$, $Delta = 3$*

      #diagram(
        spacing: (3em, 2em),
        node-shape: shapes.circle,
        edge-stroke: 1pt,
        vertex((0, 0), <s>, $s$, green),
        vertex((3, 0), <t>, $t$, red),
        vertex((1, -1), <na>, $a$, blue),
        vertex((1, 1), <nb>, $b$, blue),
        vertex((2, -1), <nc>, $c$, blue),
        vertex((2, 1), <nd>, $d$, blue),
        edge(
          <s>,
          <na>,
          "-}>",
          [$3 slash 4$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: 20deg,
        ),
        edge(<s>, <nb>, "-}>", [$2 slash 2$], label-side: center, label-angle: auto, bend: -20deg),
        edge(<na>, <nc>, "-}>", [$3 slash 3$], label-side: center, stroke: green + 1.5pt, label-angle: auto),
        edge(<nb>, <nd>, "-}>", [$3 slash 3$], label-side: center, stroke: green + 1.5pt, label-angle: auto),
        edge(<nb>, <nc>, "-}>", [$2 slash 2$], label-side: center, label-angle: auto, bend: -20deg),
        edge(
          <nc>,
          <nb>,
          "-}>",
          [$1 slash 1$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: -20deg,
        ),
        edge(<nc>, <t>, "-}>", [$2 slash 2$], label-side: center, label-angle: auto, bend: 20deg),
        edge(
          <nd>,
          <t>,
          "-}>",
          [$3 slash 4$],
          label-side: center,
          stroke: green + 1.5pt,
          label-angle: auto,
          bend: -20deg,
        ),
      )
    ],
  )]

*After step 2:* $|f| = 5$.
No augmenting path exists in the residual network --- the algorithm terminates.

#Block(color: yellow)[
  Step 2 uses the _backward_ edge $c arrow b$ in the residual network (cancelling 1 unit of the $b arrow c$ flow from step 1) and then routes through $d$.
  Without backward edges, this path would not be possible.
]

== Max-Flow Min-Cut Theorem

#theorem[
  In any flow network $N$, the following three conditions are _equivalent_:
  + $f$ is a _maximum flow_.
  + There is _no augmenting path_ in the residual network $N_f$.
  + There exists an $s$-$t$ cut $(A, B)$ with $|f| = c(A, B)$.

  Moreover, when these hold, $(A, B)$ is a _minimum cut_.
]

This is one of the deepest results in combinatorics --- it equates two seemingly unrelated quantities: the maximum achievable flow and the minimum bottleneck capacity.

== Proof of Max-Flow Min-Cut

#proof[(1 $imply$ 2) Contrapositive][
  If an augmenting path $P$ exists, its bottleneck $Delta > 0$, so we can increase $|f|$.
  Hence $f$ was not maximum.
]

#proof[(3 $imply$ 1)][
  For _any_ flow $f'$ and _any_ cut $(A,B)$ we showed $|f'| <= c(A,B)$.
  Since $|f| = c(A,B)$ for this particular cut, no flow can exceed $|f|$.
  So $f$ is maximum.
]

#proof[(2 $imply$ 3)][
  Define $A = { v in V mid exists "path" s arrow.squiggly v "in" N_f }$.
  Since no augmenting path exists, $t notin A$.
  Set $B = V setminus A$.

  _All $A to B$ edges are saturated:_ if $(u,v) in E$ with $u in A$, $v in B$ had $c_f (u,v) > 0$, then $v$ would be reachable from $s$, contradicting $v in B$.
  Hence $f(u,v) = c(u,v)$ for all such edges.

  _All $B to A$ edges carry zero flow:_ if $(u,v) in E$ with $u in B$, $v in A$ had $f(u,v) > 0$, then $c_f (v,u) = f(u,v) > 0$, so the backward edge $v to u$ would be in $N_f$, making $u$ reachable --- contradicting $u in B$.

  Therefore:
  $
    |f| = f(A,B)
    = sum_(u in A,\ v in B) underbrace(f(u,v), = c(u,v))
    - sum_(u in B,\ v in A) underbrace(f(u,v), = 0)
    = c(A,B)
    #qedhere
  $
]

== Visualization of Max-Flow Min-Cut

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0cm, 0cm), $s$, tint: green, name: <s>),
    blob((1cm, 1.3cm), $1$, inset: 4pt, tint: green, name: <n1>),
    blob((1.3cm, -0.6cm), $2$, inset: 4pt, tint: green, name: <n2>),
    blob((2.5cm, -1.5cm), $3$, inset: 4pt, tint: green, name: <n3>),
    blob((2.7cm, 2cm), $4$, inset: 4pt, tint: green, name: <n4>),
    blob((2.2cm, 0.4cm), $5$, inset: 4pt, tint: green, name: <n5>),
    edge(<s>, <n1>, "-}>"),
    edge(<s>, <n2>, "-}>"),
    edge(<n1>, <n4>, "-}>"),
    edge(<n1>, <n5>, "-}>"),
    edge(<n2>, <n5>, "-}>"),
    edge(<n2>, <n3>, "-}>"),
    blob((4cm, -0.5cm), $6$, inset: 4pt, tint: red, name: <n6>),
    blob((4.5cm, 1.5cm), $7$, inset: 4pt, tint: red, name: <n7>),
    blob((5.5cm, 0.5cm), $8$, inset: 4pt, tint: red, name: <n8>),
    blob((5.5cm, -1.5cm), $9$, inset: 4pt, tint: red, name: <n9>),
    blob((7cm, -0.5cm), $t$, tint: red, name: <t>),
    edge(<n6>, <n8>, "-}>"),
    edge(<n7>, <n8>, "-}>"),
    edge(<n6>, <n9>, "-}>"),
    edge(<n8>, <n9>, "-}>"),
    edge(<n8>, <t>, "-}>"),
    edge(<n9>, <t>, "-}>"),
    edge(<n4>, <n7>, "-}>", stroke: 1.5pt + blue),
    edge(<n5>, <n6>, "-}>", stroke: 1.5pt + blue),
    edge(<n3>, <n6>, "-}>", stroke: 1.5pt + blue),
    edge(<n5>, <n7>, "<{--", stroke: gray),
    edge(<n2>, <n6>, "<{--", stroke: gray),
  )
]

- #Green[$s, 1$--$5$] = reachable set $A$ in $N_f$.
- #Red[$6$--$9$, $t$] = $B = V setminus A$.
- #Blue[Blue] edges ($A to B$) are _saturated_ ($f = c$).
- #text(fill: gray.darken(20%))[Gray] back-edges ($B to A$) are _empty_ ($f = 0$).

== Edmonds-Karp Algorithm

Ford-Fulkerson leaves the choice of augmenting path _unspecified_.
A poor choice can lead to:
- Non-termination with irrational capacities.
- $O(|f^*| dot E)$ iterations with integer capacities --- slow when $|f^*|$ is large.

#Block(color: blue)[
  *Edmonds-Karp (1972):* Always choose the _shortest_ augmenting path (fewest edges), found by BFS.
]

#theorem[
  Edmonds-Karp runs in $O(V E^2)$ time --- independent of the capacity values.
]

The key insight: with BFS shortest paths, the distance from $s$ to every vertex is non-decreasing across iterations.
Each edge can become a bottleneck at most $O(V)$ times.
Hence the total number of augmentations is $O(V E)$, and each BFS costs $O(E)$.

#pagebreak()

#Block(color: yellow)[
  *Comparison of max-flow algorithms:*
  #table(
    columns: (auto, auto, auto),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Algorithm*], [*Time complexity*], [*Key idea*]),
    [Ford-Fulkerson], [$O(|f^*| dot E)$], [Any augmenting path],
    [Edmonds-Karp], [$O(V E^2)$], [BFS shortest augmenting path],
    [Dinic's], [$O(V^2 E)$], [Blocking flows in level graph],
    [Push-relabel], [$O(V^2 sqrt(E))$], [Height-based local pushes],
  )
]

== Integrality Theorem

#theorem[Integrality of Flow][
  If all capacities in $N$ are integers, then there exists a maximum flow that is _integer-valued_ (every $f(e) in ZZ$).
]

#proof[
  Ford-Fulkerson starts with $f = 0$ (integer).
  At each step, the bottleneck $Delta$ is the minimum of integer residual capacities --- hence an integer.
  Augmenting adds $Delta$ to each edge on the path.
  By induction, every flow value remains an integer throughout, so the final flow is integer-valued.
]

#Block(color: yellow)[
  *Why this matters:* Many combinatorial problems (matchings, disjoint paths, covers) naturally have integer optimal solutions.
  The Integrality Theorem guarantees this rigorously: run max-flow on the right network to get an integer solution.
]


= Applications of Max-Flow
#focus-slide(
  epigraph: [A good algorithm is one that solves a hard problem \ by reducing it to an easy one.],
)

== Overview: Max-Flow as a Meta-Theorem

#Block(color: blue)[
  *The power of reduction:* Many combinatorial optimization problems can be formulated as max-flow instances.
  Solving them reduces to: _"construct the right network, then run Edmonds-Karp."_
  Correctness follows from Max-Flow Min-Cut; efficiency is $O(V E^2)$.
]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Matching & assignment:*
    - Maximum bipartite matching
    - Weighted bipartite assignment
    - Project-student assignment
  ],
  [
    *Connectivity:*
    - Maximum edge-disjoint paths
    - Maximum vertex-disjoint paths
    - Menger's theorem (revisited)
  ],
)
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Covering & duality:*
    - König's theorem
    - Minimum vertex cover
    - LP duality interpretation
  ],
  [
    *Optimization with constraints:*
    - Project selection (closure)
    - Survey design
    - Image segmentation
  ],
)

== Application 1: Maximum Bipartite Matching

*Problem:*
Given bipartite graph $G = (X union Y, E)$, find the largest matching.

*Reduction:*
Construct a flow network:
- Add super-source $s$ with edge $s arrow x$ of capacity 1 for all $x in X$.
- Add super-sink $t$ with edge $y arrow t$ of capacity 1 for all $y in Y$.
- Keep original edges $X times Y$ with capacity 1.
- Run max-flow on this network.

#pagebreak()

#theorem[
  The maximum flow in this network equals the size of the maximum matching in $G$.
]

#proof[
  Any integer flow of value $k$ consists of $k$ unit-flow paths $s arrow x_i arrow y_i arrow t$.
  These correspond to $k$ matching edges, pairwise distinct (each $x_i$ and $y_j$ has unit capacity toward $s$/$t$, so no two paths share an endpoint).
  Conversely, any matching of size $k$ gives a feasible integer flow of value $k$.
  By the Integrality Theorem, a maximum integer flow exists and equals the maximum matching.
]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (4em, 2em),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0, 0), $s$, tint: green, name: <s>),
    blob((1.5, -1), $x_1$, tint: blue, name: <x1>),
    blob((1.5, 0), $x_2$, tint: blue, name: <x2>),
    blob((1.5, 1), $x_3$, tint: blue, name: <x3>),
    blob((3, -1), $y_1$, tint: blue, name: <y1>),
    blob((3, 0), $y_2$, tint: blue, name: <y2>),
    blob((3, 1), $y_3$, tint: blue, name: <y3>),
    blob((4.5, 0), $t$, tint: red, name: <t>),
    edge(<s>, <x1>, "-}>", $1$, label-side: center, label-angle: auto, bend: 30deg),
    edge(<s>, <x2>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<s>, <x3>, "-}>", $1$, label-side: center, label-angle: auto, bend: -30deg),
    edge(<x1>, <y1>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<x1>, <y2>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<x2>, <y2>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<x3>, <y2>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<x3>, <y3>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<y1>, <t>, "-}>", $1$, label-side: center, label-angle: auto, bend: 30deg),
    edge(<y2>, <t>, "-}>", $1$, label-side: center, label-angle: auto),
    edge(<y3>, <t>, "-}>", $1$, label-side: center, label-angle: auto, bend: -30deg),
  )
]

== Application 2: König's Theorem via Max-Flow

#theorem[König][
  In a bipartite graph, the size of the maximum matching equals the size of the minimum vertex cover.
]

#proof[(via max-flow)][
  Let the max-flow (= max matching) have value $k$.

  - By Max-Flow Min-Cut, there exists a cut $(A, B)$ with $c(A, B) = k$.
  - In this unit-capacity bipartite network, every finite-capacity cut edge corresponds to exactly one vertex: a $s$-side cut edge $s arrow x$ (capacity 1) to some $x in X$, or a $t$-side cut edge $y arrow t$ (capacity 1) to some $y in Y$.
  - The set of these vertices forms a vertex cover of size $k$ (every original edge $x y in E$ must be covered, for otherwise the path $s arrow x arrow y arrow t$ would cross the cut at zero cost, yielding $c(A,B) < k$).

  Conversely, any vertex cover of size $k$ defines a cut of capacity $k$. \
  Hence, $"max matching" = k = "min vertex cover"$.
]

#Block(color: yellow)[
  *Deeper:* König's theorem is an instance of _LP duality_.
  The LP relaxations of max matching and min vertex cover are dual programs.
  For bipartite graphs, both LPs have integer optimal solutions, so the LP optimum equals the integer optimum --- and the two coincide.
]

== Application 3: Menger's Theorem via Max-Flow

*Edge-disjoint paths:*
Replace each undirected edge $\{u,v\}$ with two directed edges $(u,v)$ and $(v,u)$, each of capacity 1.
The max flow from $s$ to $t$ equals the maximum number of edge-disjoint $s$-$t$ paths.
The min cut equals the minimum edge separator --- this is precisely *Menger's theorem (edge form)*.

*Vertex-disjoint paths:*
Replace each internal vertex $v$ with a pair $v_"in", v_"out"$ connected by an edge of capacity 1.
All original edges become arcs from $u_"out"$ to $v_"in"$ with capacity $infinity$.

#import fletcher: diagram, edge, node
#align(center)[
  #diagram(
    spacing: (1.5cm, 0.9cm),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0, 0), $s$, tint: green, name: <s>),
    blob((1.5, 0.8), $a_"in"$, tint: blue, name: <ain>, inset: 3pt),
    blob((3, 0.8), $a_"out"$, tint: blue, name: <aout>, inset: 3pt),
    blob((1.5, -0.8), $b_"in"$, tint: blue, name: <bin>, inset: 3pt),
    blob((3, -0.8), $b_"out"$, tint: blue, name: <bout>, inset: 3pt),
    blob((4.5, 0), $t$, tint: red, name: <t>),
    edge(<s>, <ain>, "-}>")[$infinity$],
    edge(<s>, <bin>, "-}>")[$infinity$],
    edge(<ain>, <aout>, "-}>")[$1$],
    edge(<bin>, <bout>, "-}>")[$1$],
    edge(<aout>, <t>, "-}>")[$infinity$],
    edge(<bout>, <t>, "-}>")[$infinity$],
    edge(<aout>, <bin>, "-}>")[$infinity$],
  )
]

The max flow in this network equals the maximum number of internally vertex-disjoint $s$-$t$ paths. \
The min cut equals the minimum vertex separator --- this is *Menger's theorem (vertex form)*.

== Application 4: Project Selection (Closure Problem)

*Problem:*
You have a set of _projects_ $P$, each with a profit $p_i$ (which may be negative).
Some projects _depend on_ others: selecting $i$ forces you to also select $j$ for each dependency $i arrow j$.
Find a feasible set $S subset.eq P$ maximizing $sum_(i in S) p_i$.

*Reduction to min-cut:*
- Source $s$, sink $t$.
- For each profitable project $i$ ($p_i > 0$): add edge $s arrow i$ with capacity $p_i$.
- For each costly project $i$ ($p_i < 0$): add edge $i arrow t$ with capacity $|p_i|$.
- For each dependency $i arrow j$: add edge $i arrow j$ with capacity $infinity$.

#theorem[
  $"Max profit" = (sum_(p_i > 0) p_i) - "min cut"(s, t)$.
]

#Block(color: blue)[
  *Intuition:*
  The min cut separates _selected_ ($A$, containing $s$) from _not selected_ ($B$, containing $t$).
  Cutting $s arrow i$ means forgoing the profit of project $i$.
  Cutting $j arrow t$ means project $j$ is excluded at cost $|p_j|$.
  Infinite-capacity dependency edges cannot be cut, enforcing the selection constraints.
]

== Real-World Applications

#columns(2)[
  *Direct flow problems:*
  - Pipeline throughput (oil, gas, water)
  - Internet bandwidth allocation
  - Airline scheduling (crew assignment)
  - Traffic flow optimization

  #colbreak()

  *Combinatorial optimization:*
  - Job scheduling on machines
  - Hospital-patient matching
  - Image segmentation (min-cut)
  - Baseball elimination (Schwartz 1966)
  - Open-pit mining (project selection)
]

#v(0.5em)
#Block(color: teal)[
  *Historical note:* The Max-Flow Min-Cut theorem was proved independently by Ford & Fulkerson (1956) and by Elias, Feinstein & Shannon (1956) --- the latter motivated by information theory.
  It is one of the landmark results connecting graph theory, linear programming, and combinatorics.
]

#Block(color: yellow)[
  *Baseball elimination (Schwartz 1966):* Team $i$ is _eliminated_ from winning if and only if the max flow in a specific network falls below a threshold.
  This surprised many sports analysts who assumed playoff standings were easy to compute by hand!
]

== Edmonds-Karp: Implementation

The implementation follows directly from the algorithm: use BFS to find the shortest augmenting path, then update the residual graph by augmenting along it.
Store the residual graph as an adjacency structure with explicit reverse edges.

```python
from collections import deque

def bfs(cap, s, t, parent):
    visited = {s}
    queue = deque([s])
    while queue:
        u = queue.popleft()
        for v, c in cap[u].items():
            if v not in visited and c > 0:
                visited.add(v)
                parent[v] = u
                if v == t:
                    return True
                queue.append(v)
    return False

def max_flow(cap, s, t):
    flow = 0
    while True:
        parent = {}
        if not bfs(cap, s, t, parent):
            break  # No augmenting path
        # Find bottleneck along BFS path
        path_flow, v = float('inf'), t
        while v != s:
            u = parent[v]
            path_flow = min(path_flow, cap[u][v])
            v = u
        # Augment (update residual capacities)
        v = t
        while v != s:
            u = parent[v]
            cap[u][v] -= path_flow
            cap[v][u] += path_flow  # reverse edge
            v = u
        flow += path_flow
    return flow
```

#note[
  `cap` is a dictionary of dictionaries.
  Initialize `cap[v][u] = 0` for every reverse edge before running.
  The `cap[v][u] += path_flow` line automatically maintains the residual backward capacity.
]

== Summary: Network Flow Landscape

#align(center)[
  #table(
    columns: (2fr, 2fr, 1.5fr),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Problem*], [*Reduction*], [*Complexity*]),
    [Max bipartite matching], [Unit network], [$O(E sqrt(V))$],
    [Max edge-disjoint $s$-$t$ paths], [Direct (unit caps)], [$O(E^2)$],
    [Max vertex-disjoint $s$-$t$ paths], [Vertex splitting], [$O(V dot E)$],
    [Menger's theorem], [Unit network], [Follows from above],
    [Hall's theorem], [Unit bipartite net], [Follows from matching],
    [König's theorem], [Min-cut duality], [Follows from matching],
    [Project selection], [Closure via min-cut], [$O(V^2 E)$],
  )
]

#v(0.3em)
#Block(color: yellow)[
  *Meta-theorem:* Max-Flow Min-Cut is a special case of _LP strong duality_.
  Many "maximum equals minimum" results in combinatorics --- Hall, König, Menger, Dilworth --- are all instances of this single unifying principle.
]

== Network Flows: Exercises

+ Trace Ford-Fulkerson on the network from the "Worked Example" slide and verify $|f^*| = 5$.
+ Find the minimum $s$-$t$ cut in the network and confirm its capacity equals the max flow.
+ Reduce the following bipartite matching to a max-flow problem and find the answer: $X = {1,2,3}$, $Y = {a,b,c}$, edges: $1$-$a$, $1$-$b$, $2$-$b$, $3$-$b$, $3$-$c$.
+ Apply vertex splitting to find the maximum number of internally vertex-disjoint $s$-$t$ paths in your favourite small graph.
+ Three projects $P = {A, B, C}$ with profits $p_A = 10$, $p_B = -5$, $p_C = 8$, dependencies $A arrow B$. Set up the min-cut network and determine the optimal selection.
+ Prove that the minimum cut $(A, B)$ found by the proof of Max-Flow Min-Cut satisfies $c(A,B) = |f|$ without using the theorem itself.


= Summary and Connections
#focus-slide()

== Graph Theory: Key Concepts

#grid(
  columns: (1fr, 1fr, 1fr),
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
  [
    *Network flows:*
    - Flow networks (capacity, conservation)
    - Max-flow min-cut theorem
    - Ford-Fulkerson / Edmonds-Karp
    - Applications (matching, paths)
    - Integrality theorem
  ],
)

#Block(color: yellow)[
  *Foundational theorems:*
  - Handshaking: $sum deg(v) = 2m$
  - Euler's formula: $n - m + f = 2$
  - Hall's marriage theorem (matchings $<->$ neighborhoods)
  - Menger's theorem (paths $<->$ cuts)
  - Max-Flow Min-Cut theorem ($max |f| = min c(A,B)$)
]

== Graph Theory & Flows: The Big Picture

#Block(color: blue)[
  *Network flows unify graph theory:*
  - Maximum bipartite matching $=$ max flow in a unit network
  - Menger's theorem $=$ max-flow min-cut with unit capacities
  - Hall's condition $=$ feasibility of a flow in a bipartite network
  - König's theorem $=$ strong LP duality for bipartite matching
]

#Block(color: yellow)[
  *One theorem rules them all:* Max-Flow $=$ Min-Cut is an instance of _LP strong duality_. The combinatorial "max $=$ min" theorems of Hall, König, Menger, and Dilworth are all special cases of this single algebraic principle.
]

Graph theory provides the foundation for:
- Algorithms (BFS, DFS, shortest paths, MST, max-flow)
- Network design and optimization
- Formal language theory (automata are directed labeled graphs!)


// == Exercises
//
// + Prove that every tree with $n >= 2$ vertices has at least 2 leaves.
// + Show that the Petersen graph is not planar.
// + Find the chromatic number of $C_n$ for all $n >= 3$.
// + Prove König's theorem using Hall's theorem.
// + For which values of $n$ does $K_n$ have an Eulerian circuit?
// + Find all graphs $G$ with $kappa(G) = lambda(G) = delta(G)$.
// + Prove that every 2-connected graph has no cut vertices.
// + Show that a graph is bipartite iff it has no odd cycles.
