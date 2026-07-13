// M12 --- Graphs: the universal structure for modelling connections.
#import "common-notes.typ": *
#import "notation.typ": *

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

#definition[Degree][
    $"deg"(v)$ = number of incident edges.
    Directed: out-degree $"deg"^+(v)$, in-degree $"deg"^-(v)$.
]

#theorem[Handshaking lemma][
    $sum_(v in V) "deg"(v) = 2|E|$.
    Corollary: number of odd-degree vertices is even.
]

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

Strong connectivity (directed): paths in both directions between every pair. SCCs via Kosaraju/Tarjan $O(V+E)$.

== Trees

#definition[Tree][
    A *tree* is a connected acyclic graph. A *forest* is a disjoint union of trees.
]

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

#theorem[Cayley's formula][
    Number of labelled trees on $n$ vertices: $n^(n-2)$. Proof via Prüfer codes.
]

Minimum spanning tree (MST): Kruskal $O(E log E)$, Prim $O((V+E) log V)$.

== Eulerian and Hamiltonian Graphs

#definition[Eulerian][
    *Eulerian tour*: traverses every edge exactly once, returns to start.
    *Eulerian trail*: open version (different start and end).
]

#theorem[Euler's criterion][
    Connected undirected graph is Eulerian iff all degrees are even.
    Has an Eulerian trail iff exactly two vertices have odd degree.
]

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
    $V = X union Y$, $X inter Y = nothing$, all edges between $X$ and $Y$.
]

#theorem[Bipartite criterion][
    A graph is bipartite iff it has no odd-length cycle. Test: BFS 2-coloring in $O(V+E)$.
]

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
    Consequence: every planar graph has a vertex of degree $<= 5$.
    $K_5$ ($E=10 > 9$) and $K_(3,3)$ are non-planar.
]

#theorem[Kuratowski's theorem][
    A graph is planar iff it contains no subdivision of $K_5$ or $K_(3,3)$.
]

== Graph Coloring

#definition[Vertex coloring][
    *Proper $k$-coloring*: adjacent vertices get different colors.
    *Chromatic number* $chi(G)$: minimum $k$.
]

Bounds: $chi(G) <= Delta(G) + 1$ (greedy). $chi(G) = 2$ iff bipartite with edges. $chi(K_n) = n$.

#theorem[Four Color Theorem][
    Every planar graph is 4-colorable. (Appel-Haken, 1976 --- first major computer-assisted proof.)
]

#theorem[Vizing's theorem][
    For edge coloring: $Delta(G) <= chi'(G) <= Delta(G) + 1$.
]

#remark[
    Graph coloring models register allocation (compilers), frequency assignment (cellular), and exam scheduling.
]

== Graph Algorithms

#proposition[BFS][
    Layer-by-layer exploration from source. Shortest paths in unweighted graphs. $O(V + E)$.
]

#proposition[DFS][
    Explore as far as possible along each branch. Pre/post times, edge classification.
    Applications: cycle detection, topological sort, bridges, articulation points, SCCs. $O(V + E)$.
]

#proposition[Dijkstra][
    Single-source shortest paths, non-negative weights. Min-heap priority queue: $O((V + E) log V)$.
    Fails with negative weights --- use Bellman-Ford $O(V E)$ instead.
]

#proposition[Topological sort][
    Linear ordering of DAG vertices respecting all edges.
    DFS (reverse postorder) or Kahn's algorithm (remove sources).
    Applications: build systems, task scheduling, instruction ordering.
]

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
