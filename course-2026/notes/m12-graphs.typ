// M12 --- Graphs: the universal structure for modelling connections.
#import "common-notes.typ": *
#import "notation.typ": *
#import "diagrams/m12.typ": (
  bfs-tree, bipartite, bridge-cut, directed-graph, eulerian, graph-coloring,
  k33, k5, petersen, planar, simple-graph, spanning-tree, tree,
)

= Graphs

#chapter-overview[
  *Chapter overview.*
  Graphs are the lingua franca of discrete structures --- they model networks, dependencies, state spaces, and relationships in every domain of computer science.
  This chapter introduces fundamental definitions, major graph classes (trees, bipartite, planar, Eulerian, Hamiltonian), standard algorithms (BFS, DFS, Dijkstra), and theoretical pillars: graph coloring, planar duality, and the theorems that govern graph structure.
]

== Basic Definitions

=== Graphs and Variants

#definition[Graph][
  $G = (V, E)$: $V$ = vertices, $E$ = edges.
  + *Undirected*: edges are unordered pairs ${u, v}$.
  + *Directed*: edges (arcs) are ordered pairs $(u, v)$.
]

#definition[Special types][
  + *Simple graph*: no loops, no multiple edges.
  + *Multigraph*: loops and multiple edges allowed.
  + *$k$-regular*: every vertex has degree $k$.
]

#figure(
  petersen,
  caption: [The Petersen graph: 3-regular, 10 vertices, non-planar, vertex-transitive. A classic counterexample in graph theory.],
) <fig:petersen>

#definition[Degree][
  $"deg"(v)$ = number of incident edges.
  Directed: out-degree $"deg"^+(v)$, in-degree $"deg"^-(v)$.
]

#theorem[Handshaking lemma][
  $sum_(v in V) "deg"(v) = 2|E|$.
  Corollary: number of odd-degree vertices is even.
]

#figure(
  simple-graph,
  caption: [An undirected graph with 6 vertices and 9 edges.],
) <fig:simple-graph>

=== Representations

#proposition[Three representations][
  + *Edge list*: store all edges as pairs. $O(|E|)$ adjacency check.
  + *Adjacency matrix*: $n times n$ matrix $A$; $(A^k)_(i j)$ = number of length-$k$ walks from $i$ to $j$.
  + *Adjacency list*: per vertex, list of neighbours. Best for sparse graphs.
]

== Paths, Cycles, Connectivity

#definition[Walk, path, cycle][
  + *Walk*: sequence $v_0, ..., v_k$ with ${v_(i-1), v_i} in E$. Length = $k$.
  + *Path*: walk with no repeated vertices.
  + *Cycle*: closed walk ($v_0 = v_k$, $k >= 3$) with no other repeats.
]

#definition[Connectivity][
  + *Connected*: path between every pair.
  + *Connected component*: maximal connected subgraph.
  + *Bridge*: edge whose removal disconnects the graph.
  + *Distance* $d(u, v)$: shortest path length. *Diameter*: maximum distance.
]

#figure(
  bridge-cut,
  caption: [Edge {1,2} is a bridge --- its removal disconnects the graph. Vertex 1 is a cut-vertex (articulation point).],
) <fig:bridge-cut>

#proposition[Strong connectivity (directed)][
  In digraphs, *strong connectivity* requires directed paths in both directions between every pair.
  Strongly connected components (SCCs) are computed by Kosaraju's or Tarjan's algorithm in $O(V + E)$ via DFS.
]

#figure(
  directed-graph,
  caption: [A directed graph. Vertices 1, 2, 3 form one SCC --- each reachable from each other.],
) <fig:directed-graph>

== Trees

#definition[Tree][
  A *tree* is a connected acyclic graph. A *forest* is a disjoint union of trees.
]

#figure(
  tree,
  caption: [A tree: 10 vertices, 9 edges --- connected and acyclic.],
) <fig:tree>

#theorem[Equivalent characterisations][
  For a graph on $n$ vertices, these are equivalent:
  1. Connected and acyclic (a tree).
  2. Connected and has $n-1$ edges.
  3. Acyclic and has $n-1$ edges.
  4. Unique simple path between every pair.
  5. Connected and every edge is a bridge.
]

#corollary[Leaves][
  Every tree with $n >= 2$ has at least two leaves (degree-1 vertices).
]

#definition[Spanning tree][
  A subgraph that includes all vertices and is a tree. Every connected graph has one.
]

#figure(
  spanning-tree,
  caption: [A graph (all edges shown) with one spanning tree highlighted in blue.],
) <fig:spanning-tree>

#theorem[Cayley's formula][
  Number of labelled trees on $n$ vertices: $n^(n-2)$. Proof via Prüfer codes.
]

#proposition[Minimum spanning tree][
  Given a weighted connected graph, an MST minimises the sum of edge weights.
  + *Kruskal*: sort edges by weight, add lightest that does not create a cycle (union-find). $O(E log E)$.
  + *Prim*: grow tree from arbitrary start, repeatedly add lightest edge to outside vertex (priority queue). $O((V+E) log V)$.
]

== Eulerian and Hamiltonian Graphs

#definition[Eulerian][
  *Eulerian tour*: traverses every edge exactly once, returns to start.
  *Eulerian trail*: open version (different start and end).
]

#theorem[Euler's criterion][
  Connected undirected graph is Eulerian iff all degrees are even.
  Has an Eulerian trail iff exactly two vertices have odd degree.
]

#figure(
  eulerian,
  caption: [The Königsberg bridges: every vertex has odd degree (3,3,5,3) — no Eulerian tour is possible.],
) <fig:eulerian>

#remark[
  Chinese Postman Problem (shortest closed walk covering all edges) solvable in polynomial time.
]

#definition[Hamiltonian][
  *Hamiltonian cycle*: visits every vertex exactly once, returns to start.
  No simple necessary and sufficient condition --- the problem is NP-complete.
]

#theorem[Sufficient conditions][
  + *Dirac*: $"deg"(v) >= n/2$ for all $v$ → Hamiltonian.
  + *Ore*: $"deg"(u) + "deg"(v) >= n$ for all non-adjacent $u$, $v$ → Hamiltonian.
]

#remark[
  TSP (shortest Hamiltonian cycle in weighted graph) is NP-hard --- one of the most studied optimisation problems.
]

== Bipartite Graphs

#definition[Bipartite graph][
  $V = X union Y$, $X inter Y = emptyset$, all edges between $X$ and $Y$.
]

#theorem[Bipartite criterion][
  A graph is bipartite iff it has no odd-length cycle. Test: BFS 2-coloring in $O(V+E)$.
]

#figure(
  bipartite,
  caption: [A bipartite graph: vertices partitioned into two colour classes (blue and red). Edges only cross between classes.],
) <fig:bipartite>

#definition[Matching][
  A set of edges with no shared vertices. *Perfect matching* covers all vertices.
]

#theorem[Hall's marriage theorem][
  In bipartite $(X union Y, E)$, a matching covering $X$ exists iff $forall S subset.eq X: |N(S)| >= |S|$.
]

== Planarity

#definition[Planar graph][
  Can be drawn in the plane with no edge crossings. *Faces*: regions bounded by edges.
]

#theorem[Euler's formula][
  For a connected plane graph: $V - E + F = 2$.
]

#corollary[Edge bound][
  For simple planar graph with $V >= 3$: $E <= 3V - 6$.
  Consequence: every simple planar graph has a vertex of degree $<= 5$.
  $K_5$ violates the edge bound ($E=10 > 3 dot 5 - 6 = 9$) and is non-planar.
  $K_(3,3)$ is also non-planar — it satisfies $E <= 3V - 6$ but violates the stronger triangle-free bound $E <= 2V - 4$ (Kuratowski forbidden minor).
]

#figure(
  k5,
  caption: [$K_5$ --- the complete graph on 5 vertices. Non-planar: $E=10 > 3 dot 5 - 6 = 9$.],
) <fig:k5>

#figure(
  k33,
  caption: [$K_(3,3)$ --- the complete bipartite graph. Also non-planar and a Kuratowski forbidden minor.],
) <fig:k33>

#figure(
  planar,
  caption: [A planar graph with faces $f_1, ..., f_5$. Euler's formula: $V - E + F = 6 - 9 + 5 = 2$.],
) <fig:planar>

#theorem[Kuratowski's theorem][
  A graph is planar iff it contains no subdivision of $K_5$ or $K_(3,3)$.
]

== Graph Coloring

#definition[Vertex coloring][
  *Proper $k$-coloring*: adjacent vertices get different colors.
  *Chromatic number* $chi(G)$: minimum $k$.
]

#proposition[Chromatic number bounds][
  + $chi(G) <= Delta(G) + 1$ (greedy coloring bound).
  + $chi(G) = 2$ iff $G$ is bipartite and has at least one edge.
  + $chi(K_n) = n$.
]

#theorem[Four Color Theorem][
  Every planar graph is 4-colorable. (Appel-Haken, 1976 --- first major computer-assisted proof.)
]

#theorem[Vizing's theorem][
  For edge coloring: $Delta(G) <= chi'(G) <= Delta(G) + 1$.
]

#figure(
  graph-coloring,
  caption: [A 4-coloring of a graph with 6 vertices. Adjacent vertices receive different colours.],
) <fig:coloring>

#remark[
  Graph coloring models register allocation (compilers), frequency assignment (cellular), and exam scheduling.
]

== Graph Algorithms

#proposition[Core graph algorithms][
  #table(
    columns: 4,
    align: (left, left, left, left),
    table.header([*Algorithm*], [*Solves*], [*Complexity*], [*Key idea*]),
    [BFS],
    [Shortest paths, unweighted],
    [$O(V + E)$],
    [Layer-by-layer queue exploration],

    [DFS],
    [Connectivity, cycles, topo-sort],
    [$O(V + E)$],
    [Recursive backtracking, pre/post times],

    [Dijkstra],
    [Shortest paths, non-neg. weights],
    [$O((V+E) log V)$],
    [Min-heap priority queue],

    [Bellman-Ford],
    [Shortest paths, any weights],
    [$O(V E)$],
    [Edge relaxation $V-1$ rounds],

    [Kruskal],
    [Minimum spanning tree],
    [$O(E log E)$],
    [Sort edges, union-find],

    [Prim],
    [Minimum spanning tree],
    [$O((V+E) log V)$],
    [Grow tree, min-heap frontier],

    [Kahn / DFS],
    [Topological sort of DAG],
    [$O(V + E)$],
    [Remove sources / reverse postorder],

    [Kosaraju / Tarjan],
    [Strongly connected components],
    [$O(V + E)$],
    [Two-pass DFS / lowlink],
  )
]

#figure(
  bfs-tree,
  caption: [BFS from vertex 1. Bold edges form the BFS tree; grey edges are cross/skip edges. Distances $d$ from the source are shown.],
) <fig:bfs-tree>

BFS and DFS are the two fundamental traversal strategies --- almost every graph algorithm builds on one of them.
Dijkstra generalises BFS to weighted graphs; Bellman-Ford handles negative edges at the cost of higher complexity.
MST algorithms are greedy and provably optimal for the spanning tree problem.
SCC algorithms decompose a digraph into strongly connected components --- the basic building blocks.
Topological sort applies only to DAGs and is the basis of dependency resolution.

== Applications

#remark[Social networks][
  Vertices = people; edges = friendships/follows. Measures: degree centrality, betweenness, PageRank.
]

#remark[Routing][
  Internet: routers = vertices, links = edges. Dijkstra in OSPF for intra-domain routing.
]

#remark[Compiler design][
  Control-flow graph (CFG) and register interference graph (coloring allocates registers).
]
