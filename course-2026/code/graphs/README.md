# graphs

Graphs: modeling, algorithms, visualization.

A teaching crate for the graphs chapter: a deliberately simple graph model (no generics, no traits — just `usize` vertex ids, names, and weighted edges), the classic algorithms from the chapter, and several ways to render a graph.

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

Vertices are `usize` ids `0..n` with optional string names. Edges are directed or undirected depending on the `directed` flag, and may repeat (multigraphs). The duplication is intentional: it mirrors how the chapter's pseudocode thinks about a graph, and it keeps every algorithm short.

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

### Visualization (`viz/`)

The crate does not draw layouts itself: graph layout is a hard problem, and ready tools are good at it. The crate hands them text instead:

| Backend | Output | Laid out by |
| --- | --- | --- |
| `viz::dot::render` | Graphviz DOT source | `dot`, `neato`, `fdp`, `circo` |
| `viz::cytoscape::render` | cytoscape.js JSON | cytoscape.js (`cose`, `circle`, `concentric`, ...) |
| `viz::cytoscape::render_html` | self-contained HTML page | cytoscape.js from a CDN, no server |

DOT becomes a picture with any Graphviz engine: `dot -O -Tsvg graph.dot` writes `graph.dot.svg` next to the source (the `-O` flag names the output after the input). The JSON goes straight into cytoscape.js as the `elements` option; `render_html` wraps the same JSON into a self-contained page that opens in a browser by double-click. The JSON backend uses `serde`/`serde_json` (the only external dependency of the crate): the node/edge schema is two `#[derive(Serialize)]` structs, and serde takes care of escaping, so any vertex name stays valid JSON. DOT needs only a small dedicated escaper for its own quoting rules.

## Demos

| Demo | Shows |
| --- | --- |
| `bfs_dfs` | BFS layers and distances; DFS entry/exit times on the chapter's graph |
| `dijkstra` | Dijkstra vs Bellman–Ford, negative edges, negative cycles, path reconstruction |
| `mst` | Kruskal's minimum spanning tree on a weighted graph |
| `structure` | Components, bridges, articulation points, bipartiteness, diameter |
| `directed` | Topological sort, cycle detection, strongly connected components |
| `euler` | The Euler criterion and Hierholzer's trail |
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

Every algorithm has hand-checked cases next to the code in `src/`: BFS distances on a square, Dijkstra's shortcut through a middle vertex, the Euler criterion (circuit vs path vs none), bridges/articulation points of a path, hostile vertex names staying valid JSON/DOT, and so on.
