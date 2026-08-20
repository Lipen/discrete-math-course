# graphs

Graphs: modeling, algorithms, visualization.

A deliberately simple graph model (no generics, no traits — just `usize` vertex ids, names, and weighted edges), the classic algorithms, and several ways to render a graph.

## Quick start

```bash
cargo run -p graphs --example bfs_dfs
cargo run -p graphs --example visualize
cargo test -p graphs
```

## The model

A `Graph` stores its data twice, and both views are public:

- `edges` — the edge list `(from, to, weight)`, read by weighted algorithms (Dijkstra, Bellman–Ford, Kruskal);
- `adj` — adjacency lists `adj[u] = [(neighbor, edge_id), ...]`, read by traversals (BFS, DFS).

Vertices are `usize` ids `0..n` with optional string names. Edges are directed or undirected depending on the `directed` flag, and may repeat (multigraphs). The duplication is intentional: it mirrors how the pseudocode thinks about a graph, and it keeps every algorithm short.

A second representation lives in `matrix.rs`: `AdjMatrix`, an `n x n` table of edge weights. It suits dense graphs, `O(1)` edge tests, and matrix methods such as counting walks by matrix powers; conversions to and from `Graph` are provided (`AdjMatrix::from_graph`, `AdjMatrix::to_graph`). A matrix cannot hold parallel edges, so a conversion collapses them to the lightest edge.

![A weighted graph, laid out by graphviz (the `dot` engine) from the crate's DOT output](assets/graphs-demo.svg)

The figure above is the `visualize` demo graph: the crate writes the DOT source, and the example renders the picture itself with `dot -O -Tsvg` (the `dot` engine lays the graph out hierarchically).

## API

### Graph (`graph.rs`)

| Method | Purpose |
| --- | --- |
| `Graph::undirected()`, `Graph::directed()` | New empty graph |
| `add_node(name)` | Add a vertex, return its id |
| `add_edge(u, v)`, `add_weighted_edge(u, v, w)` | Add an edge, return its id |
| `add_edges(&[(u, v), ...])` | Add several unit-weight edges |
| `node_count()`, `edge_count()`, `is_directed()` | Basic facts |
| `node_name(u)`, `neighbors(u)`, `degree(u)`, `in_degree(u)` | Read the structure |
| `edge_weight(e)`, `adjacent(u, v)` | Edge lookups |
| `degrees()` | All degrees (handshake lemma, histograms) |
| `Graph::erdos_renyi(n, p, seed)` | Random graph $G(n, p)$, reproducible |

### Algorithms (`algo.rs`)

| Function | Result |
| --- | --- |
| `bfs(&g, start)` | Order, distances, parents (BFS tree) |
| `dfs(&g)` | Entry/exit times `pre`/`post`, DFS forest, finish order |
| `connected_components(&g)` | Component count and labels (weak for directed) |
| `strongly_connected_components(&g)` | Kosaraju, for directed graphs |
| `is_cyclic(&g)` | Cycle detection (union-find / DFS colors) |
| `topological_sort(&g)` | Kahn's algorithm, `None` on a cycle |
| `dijkstra(&g, start)` | Shortest paths, non-negative weights |
| `bellman_ford(&g, start)` | Shortest paths with negative edges, `None` on a negative cycle |
| `min_spanning_tree(&g)` | Kruskal's algorithm, returns edge ids |
| `prim(&g)` | Prim's algorithm, min-heap, returns edge ids |
| `find_eulerian_path(&g)` | Eulerian trail via Hierholzer, `None` if none exists |
| `is_bipartite(&g)` | 2-coloring, `None` on an odd cycle |
| `bridges(&g)`, `articulation_points(&g)` | Tarjan's lowlink algorithm |
| `greedy_coloring(&g)` | Vertex coloring, greedy order |
| `distance`, `eccentricity`, `diameter` | Unweighted distance measures |

Picking an algorithm:

| You have | Use |
| --- | --- |
| unweighted graph, need distances or a traversal | `bfs`, `dfs` |
| weighted graph, non-negative weights | `dijkstra` |
| weighted graph with negative edges (no negative cycles) | `bellman_ford` |
| undirected graph, cheapest spanning tree | `min_spanning_tree` (Kruskal), `prim` (Prim) |
| need to visit every edge exactly once | `find_eulerian_path` |
| directed acyclic graph, need an order | `topological_sort` |
| need components | `connected_components` (undirected), `strongly_connected_components` (directed) |
| need bridges, articulation points, or a 2-coloring | `bridges`, `articulation_points`, `is_bipartite` |
| need colors or distance measures | `greedy_coloring`, `distance`, `eccentricity`, `diameter` |

### Union-find (`unionfind.rs`)

| Method | Purpose |
| --- | --- |
| `UnionFind::new(n)` | A partition of `0..n`, every element alone |
| `find(x)` | The representative of `x`'s component (path compression) |
| `union(a, b)` | Merge two components (union by size); `false` if already merged |
| `same(a, b)` | Are `a` and `b` connected? |
| `push()` | Add a new element as its own component |
| `classes()` | The equivalence classes of the current partition |

Runs in $O(n \alpha(n))$; used by Kruskal's algorithm, undirected cycle detection, and Steensgaard's pointer analysis.

### Adjacency matrix (`matrix.rs`)

| Method | Purpose |
| --- | --- |
| `AdjMatrix::new(n, directed)` | An empty `n x n` matrix |
| `add_edge(u, v, w)` | Set an edge (the lighter weight wins) |
| `has_edge(u, v)`, `weight(u, v)` | Edge tests in $O(1)$ |
| `neighbors(u)`, `in_neighbors(u)` | In- and out-neighbors |
| `from_graph(&g)`, `to_graph()` | Conversion to and from `Graph` |
| `count_walks(u, v, len)` | Number of walks of a given length (matrix power) |

### De Bruijn graphs (`de_bruijn.rs`)

Genome assembly from reads: vertices are (k-1)-mers, edges are k-mers, and an Eulerian path over the graph spells the assembled genome.

| Method | Purpose |
| --- | --- |
| `DeBruijnGraph::build(&reads, k)` | Build the graph from reads (long reads are chopped into k-mers) |
| `vertex_id(mer)`, `edge_label(u, v)` | Look up the (k-1)-mer of a vertex, the k-mer of an edge |
| `eulerian_path()` | Hierholzer's algorithm; `None` if no Eulerian path exists |
| `genome_from_path(&path)` | The string spelled by the trail |
| `assemble()` | Path + reconstruction in one call |

### Steensgaard's pointer analysis (`steensgaard.rs`)

Unification-based alias analysis for a tiny C-like language (`x = &y`, `x = y`, `x = *y`, `*x = y`). Every variable and location is a union-find node with at most one points-to edge; constraints are resolved by unifying targets, which is what keeps the whole analysis at $O(n \alpha(n))$.

| Item | Purpose |
| --- | --- |
| `Stmt::AddrOf/Copy/Load/Store` | The four statement forms |
| `Steensgaard::new()`, `run(&program)` | Analyze a program |
| `assign_addr`, `assign_copy`, `assign_deref`, `deref_assign` | One statement at a time |
| `points_to(name)`, `points_to_sets()` | The points-to sets (equivalence classes) |
| `may_alias(x, y)` | May two variables be the same storage? |

### Visualization (`viz/`)

The crate does not draw layouts itself: graph layout is a hard problem, and ready tools are good at it. The crate hands them text instead:

| Backend | Output | Laid out by |
| --- | --- | --- |
| `viz::dot::render` | Graphviz DOT source | `dot`, `neato`, `fdp`, `circo` |
| `viz::cytoscape::render` | cytoscape.js JSON | cytoscape.js (`cose`, `circle`, `concentric`, ...) |
| `viz::cytoscape::render_html` | self-contained HTML page | cytoscape.js from a CDN, no server |

DOT becomes a picture with any Graphviz engine: `dot -O -Tsvg graph.dot` writes `graph.dot.svg` next to the source (the `-O` flag names the output after the input). The JSON goes straight into cytoscape.js as the `elements` option; `render_html` wraps the same JSON into a self-contained page that opens in a browser by double-click. The JSON backend uses `serde`/`serde_json` and the HTML wrapper uses `indoc` (together the crate's only external dependencies): the node/edge schema is two `#[derive(Serialize)]` structs, and serde takes care of escaping, so any vertex name stays valid JSON. DOT needs only a small dedicated escaper for its own quoting rules.

## Demos

| Demo | Shows |
| --- | --- |
| `bfs_dfs` | BFS layers and distances; DFS entry/exit times on the running example graph |
| `dijkstra` | Dijkstra vs Bellman–Ford, negative edges, negative cycles, path reconstruction |
| `mst` | Kruskal's minimum spanning tree on a weighted graph |
| `structure` | Components, bridges, articulation points, bipartiteness, diameter |
| `directed` | Topological sort, cycle detection, strongly connected components |
| `euler` | The Euler criterion and Hierholzer's trail |
| `genome_assembly` | Reads -> de Bruijn graph -> Eulerian path -> assembled genome (linear and circular cases) |
| `pointer_analysis` | Steensgaard's unification-based analysis on a tiny C-like program, with the points-to sets after every statement |
| `visualize` | One graph written as DOT, an SVG picture (rendered with `dot -O -Tsvg`), and a self-contained cytoscape.js HTML page in a temp dir; prints the paths |
| `random_graph` | Erdős–Rényi $G(n, p)$: degrees, handshake lemma, components; writes a DOT file |

## Integration paths (web, wasm, js, desktop)

The two backends cover the easy routes; the same data feeds the harder ones:

- **web**: feed the JSON to cytoscape.js for pan/zoom/click; the DOT source renders server-side with graphviz;
- **wasm / js**: compile the crate with `wasm-pack`, expose `Graph` + algorithms, and render with the same backends on the JS side;
- **bevy / egui**: skip the text backends and draw `g.adj`/`g.edges` directly — the model is just `Vec`s, so it transfers to any renderer;
- **graphviz**: `viz::dot` output works with `dot`, `neato`, `fdp`, `circo` and the other layout engines.

## Tests

```bash
cargo test -p graphs
```

Every algorithm has hand-checked cases next to the code in `src/`: BFS distances on a square, Dijkstra's shortcut through a middle vertex, the Euler criterion (circuit vs path vs none), bridges/articulation points of a path, hostile vertex names staying valid JSON/DOT, the de Bruijn pipeline (read chopping, repeated reads, self-loops, unbalanced and disconnected graphs), the unification steps of the pointer analysis, matrix round-trips and walk counts, and union-find equivalence classes. The doctests in `src/` double as documentation: `cargo test -p graphs` runs them all.
