# graphs

Graphs: modeling, algorithms, visualization.

A deliberately simple graph model — `usize` vertex ids, optional names, weighted edges, no generics and no traits — plus the classic algorithms and several ways to render a graph.

## Quick start

```bash
cargo run --example bfs_dfs
cargo run --example visualize
cargo test
```

## The model

A `Graph` stores its data twice, and both views are public.
`edges` is the edge list `(from, to, weight)`, read by the weighted algorithms (Dijkstra, Bellman–Ford, Kruskal).
`adj` holds the adjacency lists `adj[u] = [(neighbor, edge_id), ...]`, read by the traversals (BFS, DFS).

Vertices are `usize` ids in `0..n` with optional string names.
The `directed` flag chooses arrows or plain lines.
Edges may repeat, so multigraphs are allowed.
The duplication is intentional: it is how pseudocode thinks about a graph, and it keeps every algorithm short.

A second representation lives in `matrix.rs`: `AdjMatrix`, an $n \times n$ table of edge weights.
It suits dense graphs, $O(1)$ edge tests, and matrix methods such as counting walks by matrix powers.
Conversions go both ways (`AdjMatrix::from_graph`, `AdjMatrix::to_graph`).
A matrix cannot hold parallel edges, so a conversion collapses them to the lightest one.

![A weighted graph laid out by graphviz (the `dot` engine) from the DOT output of the crate](assets/graphs-demo.svg)

The figure shows the graph of the `visualize` demo: the crate writes the DOT source, and the example renders the picture with `dot -O -Tsvg`.
The DOT source is committed at [`assets/graphs-demo.dot`](assets/graphs-demo.dot), so you can lay it out with any Graphviz engine (`dot`, `neato`, `fdp`, `circo`).

## Demos

| Demo               | Shows                                                                                                                       |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `bfs_dfs`          | BFS layers and distances, DFS entry/exit times on the running example graph                                                 |
| `dijkstra`         | Dijkstra vs Bellman–Ford, negative edges and negative cycles, path reconstruction                                           |
| `mst`              | Kruskal's minimum spanning tree on a weighted graph                                                                         |
| `structure`        | Components, bridges, articulation points, bipartiteness, diameter                                                           |
| `directed`         | Topological sort, cycle detection, strongly connected components                                                            |
| `euler`            | Euler's criterion and Hierholzer's trail                                                                                    |
| `genome_assembly`  | reads -> de Bruijn graph -> Eulerian path -> assembled genome (linear and circular cases)                                   |
| `pointer_analysis` | Steensgaard's unification-based analysis of a tiny C-like program, with the points-to sets after every statement            |
| `visualize`        | one graph written as DOT, an SVG picture, and a self-contained cytoscape.js HTML page in a temp dir, with the paths printed |
| `random_graph`     | Erdős–Rényi $G(n, p)$: degrees, the handshake lemma, components, a DOT file written                                         |

`dijkstra` contrasts the two shortest-path algorithms on the same vertices.
`genome_assembly` and `pointer_analysis` apply graphs to data and to program analysis.
`visualize` produces files in a temp dir and prints their absolute paths.

## API

### Graph (`graph.rs`)

| Method                                                      | Purpose                                      |
| ----------------------------------------------------------- | -------------------------------------------- |
| `Graph::undirected()`, `Graph::directed()`                  | new empty graph                              |
| `add_node(name)`                                            | add a vertex, return its id                  |
| `add_edge(u, v)`, `add_weighted_edge(u, v, w)`              | add an edge, return its id                   |
| `add_edges(&[(u, v), ...])`                                 | add several unit-weight edges                |
| `node_count()`, `edge_count()`, `is_directed()`             | basic facts                                  |
| `node_name(u)`, `neighbors(u)`, `degree(u)`, `in_degree(u)` | read the structure                           |
| `edge_weight(e)`, `adjacent(u, v)`                          | edge lookups                                 |
| `degrees()`                                                 | all degrees (handshake lemma, histograms)    |
| `Graph::erdos_renyi(n, p, seed)`                            | random graph $G(n, p)$, reproducible by seed |

### Algorithms (`algo.rs`)

| Function                                 | Result                                                         |
| ---------------------------------------- | -------------------------------------------------------------- |
| `bfs(&g, start)`                         | order, distances, parents (BFS tree)                           |
| `dfs(&g)`                                | entry/exit times `pre`/`post`, DFS forest, finish order        |
| `connected_components(&g)`               | component count and labels (weak for directed)                 |
| `strongly_connected_components(&g)`      | Kosaraju, for directed graphs                                  |
| `is_cyclic(&g)`                          | cycle detection (union-find or DFS colors)                     |
| `topological_sort(&g)`                   | Kahn's algorithm, `None` on a cycle                            |
| `dijkstra(&g, start)`                    | shortest paths, non-negative weights                           |
| `bellman_ford(&g, start)`                | shortest paths with negative edges, `None` on a negative cycle |
| `min_spanning_tree(&g)`                  | Kruskal's algorithm, returns edge ids                          |
| `prim(&g)`                               | Prim's algorithm with a min-heap, returns edge ids             |
| `find_eulerian_path(&g)`                 | Eulerian trail via Hierholzer, `None` if none exists           |
| `is_bipartite(&g)`                       | 2-coloring, `None` on an odd cycle                             |
| `bridges(&g)`, `articulation_points(&g)` | Tarjan's lowlink algorithm                                     |
| `greedy_coloring(&g)`                    | vertex coloring in greedy order                                |
| `distance`, `eccentricity`, `diameter`   | unweighted distance measures                                   |

Picking an algorithm:

| You have                                                  | Use                                                                             |
| --------------------------------------------------------- | ------------------------------------------------------------------------------- |
| unweighted graph, need distances or a traversal           | `bfs`, `dfs`                                                                    |
| weighted graph, non-negative weights                      | `dijkstra`                                                                      |
| weighted graph with negative edges and no negative cycles | `bellman_ford`                                                                  |
| undirected graph, cheapest spanning tree                  | `min_spanning_tree` (Kruskal), `prim` (Prim)                                    |
| every edge visited exactly once                           | `find_eulerian_path`                                                            |
| directed acyclic graph, need an order                     | `topological_sort`                                                              |
| components                                                | `connected_components` (undirected), `strongly_connected_components` (directed) |
| bridges, articulation points, or a 2-coloring             | `bridges`, `articulation_points`, `is_bipartite`                                |
| colors or distance measures                               | `greedy_coloring`, `distance`, `eccentricity`, `diameter`                       |

### Union-find (`unionfind.rs`)

| Method              | Purpose                                                         |
| ------------------- | --------------------------------------------------------------- |
| `UnionFind::new(n)` | a partition of `0..n`, every element alone                      |
| `find(x)`           | the representative of the component of `x` (path compression)   |
| `union(a, b)`       | merge two components (union by size), `false` if already merged |
| `same(a, b)`        | are `a` and `b` connected                                       |
| `push()`            | add a new element as its own component                          |
| `classes()`         | the equivalence classes of the current partition                |

Runs in $O(n \alpha(n))$.
Kruskal's algorithm, undirected cycle detection, and Steensgaard's pointer analysis build on it.

### Adjacency matrix (`matrix.rs`)

| Method                            | Purpose                                          |
| --------------------------------- | ------------------------------------------------ |
| `AdjMatrix::new(n, directed)`     | an empty $n \times n$ matrix                     |
| `add_edge(u, v, w)`               | set an edge (the lighter weight wins)            |
| `has_edge(u, v)`, `weight(u, v)`  | edge tests in $O(1)$                             |
| `neighbors(u)`, `in_neighbors(u)` | in- and out-neighbors                            |
| `from_graph(&g)`, `to_graph()`    | conversion to and from `Graph`                   |
| `count_walks(u, v, len)`          | number of walks of a given length (matrix power) |

### De Bruijn graphs (`de_bruijn.rs`)

Genome assembly from reads: vertices are $(k-1)$-mers, edges are $k$-mers, and an Eulerian path over the graph spells the assembled genome.

| Method                               | Purpose                                                         |
| ------------------------------------ | --------------------------------------------------------------- |
| `DeBruijnGraph::build(&reads, k)`    | build the graph from reads (long reads are chopped into k-mers) |
| `vertex_id(mer)`, `edge_label(u, v)` | look up the (k-1)-mer of a vertex, the k-mer of an edge         |
| `eulerian_path()`                    | Hierholzer's algorithm, `None` if no Eulerian path exists       |
| `genome_from_path(&path)`            | the string spelled by the trail                                 |
| `assemble()`                         | path and reconstruction in one call                             |

### Steensgaard's pointer analysis (`steensgaard.rs`)

Unification-based alias analysis for a tiny C-like language (`x = &y`, `x = y`, `x = *y`, `*x = y`).
Every variable and location is a union-find node with at most one points-to edge.
Constraints are resolved by unifying targets, which keeps the whole analysis at $O(n \alpha(n))$.

| Item                                                         | Purpose                                  |
| ------------------------------------------------------------ | ---------------------------------------- |
| `Stmt::AddrOf/Copy/Load/Store`                               | the four statement forms                 |
| `Steensgaard::new()`, `run(&program)`                        | analyze a program                        |
| `assign_addr`, `assign_copy`, `assign_deref`, `deref_assign` | one statement at a time                  |
| `points_to(name)`, `points_to_sets()`                        | the points-to sets (equivalence classes) |
| `may_alias(x, y)`                                            | may two variables be the same storage    |

### Visualization (`viz/`)

The crate does not draw layouts itself: graph layout is a hard problem, and ready-made tools are good at it.
The crate hands them text instead.

| Backend                       | Output                   | Laid out by                                        |
| ----------------------------- | ------------------------ | -------------------------------------------------- |
| `viz::dot::render`            | Graphviz DOT source      | `dot`, `neato`, `fdp`, `circo`                     |
| `viz::cytoscape::render`      | cytoscape.js JSON        | cytoscape.js (`cose`, `circle`, `concentric`, ...) |
| `viz::cytoscape::render_html` | self-contained HTML page | cytoscape.js from a CDN, no server                 |

DOT becomes a picture with any Graphviz engine: `dot -O -Tsvg graph.dot` writes `graph.dot.svg` next to the source (the `-O` flag names the output after the input).
The JSON goes straight into cytoscape.js as the `elements` option.
`render_html` wraps the same JSON into a self-contained page that opens in a browser by double-click.
The JSON backend uses `serde`/`serde_json` and the HTML wrapper uses `indoc` (together the only external dependencies of the crate).
The node/edge schema is two `#[derive(Serialize)]` structs, and serde takes care of escaping, so any vertex name stays valid JSON.
DOT needs only a small dedicated escaper for its own quoting rules.

## Integration paths (web, wasm, js, desktop)

The two backends cover the easy routes, and the same data feeds the harder ones:

- **web**: feed the JSON to cytoscape.js for pan/zoom/click, and render the DOT source server-side with graphviz.
- **wasm / js**: compile the crate with `wasm-pack`, expose `Graph` and the algorithms, and render with the same backends on the JS side.
- **bevy / egui**: skip the text backends and draw `g.adj`/`g.edges` directly — the model is just `Vec`s, so it transfers to any renderer.
- **graphviz**: the `viz::dot` output works with `dot`, `neato`, `fdp`, `circo`, and the other layout engines.

## Tests

`cargo test` runs the unit tests next to the code in `src/` and the doc tests.
Every algorithm has cases with explicit expected values: BFS distances on a square, Dijkstra's shortcut through a middle vertex, the Euler criterion (circuit vs path vs none), bridges and articulation points of a path, hostile vertex names staying valid JSON/DOT, the de Bruijn pipeline (read chopping, repeated reads, self-loops, unbalanced and disconnected graphs), the unification steps of the pointer analysis, matrix round-trips and walk counts, and union-find equivalence classes.
The doc tests in `src/` double as documentation.
