//! Graph algorithms.
//!
//! Every algorithm is a free function taking `&Graph`.
//! The model is separate from the algorithms: the same graph can be fed to
//! any number of functions.
//!
//! Each algorithm's complexity and idea are described in its documentation;
//! working demos live in `examples/`.

use std::cmp::Reverse;
use std::collections::{BinaryHeap, VecDeque};

use crate::graph::Graph;
use crate::unionfind::UnionFind;

/// Result of a breadth-first search.
#[derive(Debug)]
pub struct BfsResult {
    /// Vertices in the order they were visited.
    pub order: Vec<usize>,
    /// Distance from the start vertex; `usize::MAX` means unreachable
    /// (a sentinel; the weighted algorithms
    /// Dijkstra and Bellman--Ford mark unreachable vertices as `None`).
    pub dist: Vec<usize>,
    /// Parent in the BFS tree; `None` for the start vertex and unreachable ones.
    pub parent: Vec<Option<usize>>,
}

/// Breadth-first search (BFS) from the vertex `start`.
///
/// Visits the graph layer by layer: first vertices at distance 1, then 2,
/// and so on. Runs in $O(V + E)$ and finds shortest paths in an unweighted
/// graph (weights are ignored).
///
/// ```
/// use graphs::{bfs, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
///
/// let res = bfs(&g, 0);
/// assert_eq!(res.dist, vec![0, 1, 2, 3]);
/// assert_eq!(res.parent, vec![None, Some(0), Some(1), Some(2)]);
/// ```
pub fn bfs(g: &Graph, start: usize) -> BfsResult {
    let n = g.node_count();
    let mut order = Vec::with_capacity(n);
    let mut dist = vec![usize::MAX; n];
    let mut parent = vec![None; n];

    let mut q = VecDeque::new();
    dist[start] = 0;
    q.push_back(start);

    while let Some(u) = q.pop_front() {
        order.push(u);
        for &(v, _) in &g.adj[u] {
            if dist[v] == usize::MAX {
                dist[v] = dist[u] + 1;
                parent[v] = Some(u);
                q.push_back(v);
            }
        }
    }
    BfsResult {
        order,
        dist,
        parent,
    }
}

/// Result of a depth-first search.
#[derive(Debug)]
pub struct DfsResult {
    /// Entry time of the vertex (1-based; 0 means not visited in this pass).
    pub pre: Vec<usize>,
    /// Exit time of the vertex.
    pub post: Vec<usize>,
    /// Parent in the DFS forest; `None` for roots.
    pub parent: Vec<Option<usize>>,
    /// Vertices in the order of first visit.
    pub order: Vec<usize>,
    /// Vertices in the order their processing finished.
    ///
    /// The reverse order is a topological order of a DAG's vertices, and it
    /// is exactly what Kosaraju's algorithm needs for strong components.
    pub finish: Vec<usize>,
}

/// Depth-first search (DFS) over all vertices of the graph.
///
/// Goes deep: recursively explores the first unvisited neighbor, then its
/// neighbor, and so on; the entry `pre` and exit `post` times carry
/// structural information about edges (tree, back, and cross edges).
/// Runs in $O(V + E)$. Recursive: may overflow the call stack on very
/// large graphs.
///
/// ```
/// use graphs::{dfs, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
///
/// let res = dfs(&g);
/// assert_eq!(res.order.len(), 3); // all vertices visited
/// assert!(res.pre.iter().all(|&t| t > 0));
/// ```
pub fn dfs(g: &Graph) -> DfsResult {
    let n = g.node_count();
    let mut res = DfsResult {
        pre: vec![0; n],
        post: vec![0; n],
        parent: vec![None; n],
        order: Vec::with_capacity(n),
        finish: Vec::with_capacity(n),
    };
    let mut time = 0usize;

    fn visit(u: usize, g: &Graph, res: &mut DfsResult, time: &mut usize) {
        *time += 1;
        res.pre[u] = *time;
        res.order.push(u);
        for &(v, _) in &g.adj[u] {
            if res.pre[v] == 0 {
                res.parent[v] = Some(u);
                visit(v, g, res, time);
            }
        }
        *time += 1;
        res.post[u] = *time;
        res.finish.push(u);
    }

    for start in 0..n {
        if res.pre[start] == 0 {
            visit(start, g, &mut res, &mut time);
        }
    }
    res
}

/// Number of connected components and the component label of every vertex.
///
/// For a directed graph this counts the *weakly* connected components:
/// edge directions are ignored.
///
/// ```
/// use graphs::{connected_components, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (2, 3)]);
///
/// let (count, comp) = connected_components(&g);
/// assert_eq!(count, 2);
/// assert_eq!(comp[0], comp[1]);
/// assert_ne!(comp[0], comp[2]);
/// assert_eq!(comp[2], comp[3]);
/// ```
pub fn connected_components(g: &Graph) -> (usize, Vec<usize>) {
    let n = g.node_count();
    let mut uf = UnionFind::new(n);
    for e in &g.edges {
        uf.union(e.from, e.to);
    }

    // Representative -> component label (0, 1, 2, ...).
    let mut label_of_root: Vec<Option<usize>> = vec![None; n];
    let mut comp = Vec::with_capacity(n);
    let mut count = 0;
    for u in 0..n {
        let root = uf.find(u);
        if label_of_root[root].is_none() {
            label_of_root[root] = Some(count);
            count += 1;
        }
        comp.push(label_of_root[root].unwrap());
    }
    (count, comp)
}

/// Strongly connected components (Kosaraju's algorithm), directed graphs only.
///
/// Two passes: DFS on the original graph gives the finish order, DFS on the
/// reversed graph in reverse finish order gives the components themselves.
/// For an undirected graph use [`connected_components`]: passing one here is
/// a mistake, and the function panics on it.
///
/// ```
/// use graphs::{strongly_connected_components, Graph};
///
/// let mut g = Graph::directed();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
///
/// let sccs = strongly_connected_components(&g);
/// assert_eq!(sccs.len(), 1); // one cycle, one component
/// assert_eq!(sccs[0].len(), 3);
/// ```
pub fn strongly_connected_components(g: &Graph) -> Vec<Vec<usize>> {
    assert!(
        g.directed,
        "strongly_connected_components is for directed graphs"
    );
    let n = g.node_count();

    // 1. Reversed graph: rev[v] holds the vertices with edges into v.
    let mut rev = vec![Vec::new(); n];
    for e in &g.edges {
        rev[e.to].push(e.from);
    }

    // 2. DFS on the reversed graph in reverse finish order.
    let finish = dfs(g).finish;
    let mut visited = vec![false; n];
    let mut sccs = Vec::new();
    for &u in finish.iter().rev() {
        if !visited[u] {
            let mut comp = Vec::new();
            collect(u, &rev, &mut visited, &mut comp);
            sccs.push(comp);
        }
    }
    sccs
}

/// Collect the whole area reachable from `u` in the reversed graph (one component).
fn collect(u: usize, rev: &[Vec<usize>], visited: &mut [bool], comp: &mut Vec<usize>) {
    visited[u] = true;
    comp.push(u);
    for &v in &rev[u] {
        if !visited[v] {
            collect(v, rev, visited, comp);
        }
    }
}

/// Whether the graph has a cycle.
///
/// An undirected graph is checked with a union-find structure (an edge that
/// joins vertices of one component closes a cycle); a directed graph -- with
/// colored DFS (gray means an edge into the current recursion stack).
///
/// ```
/// use graphs::{is_cyclic, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
/// assert!(!is_cyclic(&g));
/// g.add_edge(2, 0);
/// assert!(is_cyclic(&g));
/// ```
pub fn is_cyclic(g: &Graph) -> bool {
    if !g.directed {
        let mut uf = UnionFind::new(g.node_count());
        for e in &g.edges {
            if !uf.union(e.from, e.to) {
                return true;
            }
        }
        return false;
    }

    // Colors: 0 = white (unvisited), 1 = gray (on the stack), 2 = black (done).
    let n = g.node_count();
    let mut color = vec![0u8; n];

    fn has_cycle_from(u: usize, g: &Graph, color: &mut [u8]) -> bool {
        color[u] = 1;
        for &(v, _) in &g.adj[u] {
            if color[v] == 1 {
                return true; // edge into an ancestor on the current stack
            }
            if color[v] == 0 && has_cycle_from(v, g, color) {
                return true;
            }
        }
        color[u] = 2;
        false
    }

    for u in 0..n {
        if color[u] == 0 && has_cycle_from(u, g, &mut color) {
            return true;
        }
    }
    false
}

/// Topological sort (Kahn's algorithm), for directed acyclic graphs.
///
/// Returns `None` if the graph has a cycle (no topological order exists).
/// The order is such that every edge goes from an earlier vertex to a later
/// one. Topological sort is undefined for undirected graphs, and the
/// function panics on them.
///
/// ```
/// use graphs::{topological_sort, Graph};
///
/// let mut g = Graph::directed();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
///
/// let order = topological_sort(&g).unwrap();
/// assert_eq!(order, vec![0, 1, 2]);
/// ```
pub fn topological_sort(g: &Graph) -> Option<Vec<usize>> {
    assert!(g.directed, "topological_sort is for directed graphs");
    let n = g.node_count();

    // In-degree: how many edges enter each vertex.
    let mut indegree = vec![0usize; n];
    for e in &g.edges {
        indegree[e.to] += 1;
    }

    let mut q: VecDeque<usize> = (0..n).filter(|&u| indegree[u] == 0).collect();
    let mut order = Vec::with_capacity(n);
    while let Some(u) = q.pop_front() {
        order.push(u);
        for &(v, _) in &g.adj[u] {
            indegree[v] -= 1;
            if indegree[v] == 0 {
                q.push_back(v);
            }
        }
    }

    if order.len() == n {
        Some(order)
    } else {
        None // some vertices kept a non-zero in-degree: a cycle
    }
}

/// Distances from the source and predecessors on the shortest paths.
///
/// A pair `(dist, prev)`: `dist[v]` is the length of the shortest path to `v`
/// (`None` means unreachable), `prev[v]` is the previous vertex on that path.
pub type ShortestPaths = (Vec<Option<i64>>, Vec<Option<usize>>);

/// Shortest paths from `start` (Dijkstra's algorithm).
///
/// Edge weights must be non-negative (checked in debug builds). Returns
/// [`ShortestPaths`]: the distance to every vertex and the predecessor on
/// the shortest path (to reconstruct the path itself).
/// Runs in $O((V + E) log V)$.
///
/// ```
/// use graphs::{dijkstra, Graph};
///
/// let mut g = Graph::directed();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_weighted_edge(0, 1, 4);
/// g.add_weighted_edge(0, 2, 1);
/// g.add_weighted_edge(2, 1, 2); // shortcut through vertex 2
///
/// let (dist, _) = dijkstra(&g, 0);
/// assert_eq!(dist, vec![Some(0), Some(3), Some(1)]);
/// ```
pub fn dijkstra(g: &Graph, start: usize) -> ShortestPaths {
    debug_assert!(
        g.edges.iter().all(|e| e.weight >= 0),
        "Dijkstra requires non-negative edge weights"
    );
    let n = g.node_count();
    let mut dist: Vec<Option<i64>> = vec![None; n];
    let mut prev = vec![None; n];

    // Rust's heap is a max-heap, so we store (distance, vertex) inside
    // Reverse: the minimum is popped first. A vertex is pushed again every
    // time its distance improves, so the heap holds stale entries too; they
    // are discarded below.
    let mut heap = BinaryHeap::new();
    dist[start] = Some(0);
    heap.push(Reverse((0, start)));

    while let Some(Reverse((d, u))) = heap.pop() {
        if dist[u] != Some(d) {
            continue; // stale entry: a shorter path to u was found earlier
        }
        for &(v, e) in &g.adj[u] {
            // Treat i64 overflow as "a path of infinite length".
            let Some(nd) = d.checked_add(g.edge_weight(e)) else {
                continue;
            };
            // dist[v] is not found yet, or the new path is shorter.
            let shorter = match dist[v] {
                None => true,
                Some(old) => nd < old,
            };
            if shorter {
                dist[v] = Some(nd);
                prev[v] = Some(u);
                heap.push(Reverse((nd, v)));
            }
        }
    }
    (dist, prev)
}

/// Shortest paths from `start` (Bellman--Ford algorithm).
///
/// Works with negative weights too: only Dijkstra's "adding an edge never
/// shortens a path" assumption fails there, while Bellman--Ford relaxes all
/// edges for $V - 1$ rounds and considers paths of any length. It only
/// breaks on negative cycles: if `start` can reach such a cycle, it returns
/// `None` (an unreachable cycle does not matter). After $k$ rounds paths of
/// at most $k$ edges are correct. Runs in $O(V E)$.
///
/// ```
/// use graphs::{bellman_ford, Graph};
///
/// let mut g = Graph::directed();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_weighted_edge(0, 1, 4);
/// g.add_weighted_edge(1, 2, -3);
///
/// let (dist, _) = bellman_ford(&g, 0).unwrap();
/// assert_eq!(dist, vec![Some(0), Some(4), Some(1)]);
/// ```
pub fn bellman_ford(g: &Graph, start: usize) -> Option<ShortestPaths> {
    let n = g.node_count();
    let mut dist: Vec<Option<i64>> = vec![None; n];
    let mut prev = vec![None; n];
    dist[start] = Some(0);

    for _ in 0..n.saturating_sub(1) {
        let mut changed = false;
        for e in &g.edges {
            if let Some(du) = dist[e.from] {
                let Some(nd) = du.checked_add(e.weight) else {
                    continue;
                };
                let shorter = match dist[e.to] {
                    None => true,
                    Some(old) => nd < old,
                };
                if shorter {
                    dist[e.to] = Some(nd);
                    prev[e.to] = Some(e.from);
                    changed = true;
                }
            }
        }
        if !changed {
            break;
        }
    }

    // One more round: if anything improved, there is a negative cycle.
    for e in &g.edges {
        if let Some(du) = dist[e.from] {
            if let Some(nd) = du.checked_add(e.weight) {
                let shorter = match dist[e.to] {
                    None => true,
                    Some(old) => nd < old,
                };
                if shorter {
                    return None;
                }
            }
        }
    }
    Some((dist, prev))
}

/// Minimum spanning tree (Kruskal's algorithm), for undirected graphs.
///
/// Sorts edges by weight and adds every edge that joins two different
/// components (checked with a union-find structure). Returns the edge ids of
/// the spanning tree; for a disconnected graph -- a spanning forest (one
/// tree per component).
///
/// ```
/// use graphs::{min_spanning_tree, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_weighted_edge(0, 1, 1);
/// g.add_weighted_edge(1, 2, 2);
/// g.add_weighted_edge(0, 2, 10);
///
/// let tree = min_spanning_tree(&g);
/// assert_eq!(tree.len(), 2); // 3 vertices, 2 edges in the tree
/// ```
pub fn min_spanning_tree(g: &Graph) -> Vec<usize> {
    assert!(!g.directed, "min_spanning_tree is for undirected graphs");

    let mut order: Vec<usize> = (0..g.edge_count()).collect();
    order.sort_by_key(|&e| g.edges[e].weight);

    let mut uf = UnionFind::new(g.node_count());
    let mut tree = Vec::new();
    for e in order {
        let edge = &g.edges[e];
        if uf.union(edge.from, edge.to) {
            tree.push(e);
        }
    }
    tree
}

/// Minimum spanning tree (Prim's algorithm), for undirected graphs.
///
/// Grows a tree from a start vertex: at every step it takes the lightest edge
/// crossing the cut between the tree and the rest of the graph, using a binary
/// min-heap of candidate edges. Kruskal is friendlier to sparse graphs, Prim
/// to dense ones. Returns the edge ids of the spanning tree; for a
/// disconnected graph -- a spanning forest.
///
/// ```
/// use graphs::{prim, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_weighted_edge(0, 1, 1);
/// g.add_weighted_edge(1, 2, 2);
/// g.add_weighted_edge(0, 2, 10);
///
/// let tree = prim(&g);
/// assert_eq!(tree.len(), 2); // 3 vertices, 2 edges in the tree
/// ```
pub fn prim(g: &Graph) -> Vec<usize> {
    assert!(!g.directed, "prim is for undirected graphs");

    use std::cmp::Reverse;
    use std::collections::BinaryHeap;

    let n = g.node_count();
    let mut in_tree = vec![false; n];
    let mut tree = Vec::new();

    for start in 0..n {
        if in_tree[start] {
            continue;
        }
        // Grow a tree in the component of `start`: each connected component
        // gets its own tree, so a disconnected graph yields a spanning forest.
        in_tree[start] = true;
        let mut heap: BinaryHeap<(Reverse<i64>, usize, usize)> = BinaryHeap::new();
        for &(to, e) in &g.adj[start] {
            if !in_tree[to] {
                heap.push((Reverse(g.edges[e].weight), to, e));
            }
        }
        while let Some((Reverse(_w), to, e)) = heap.pop() {
            if in_tree[to] {
                continue;
            }
            in_tree[to] = true;
            tree.push(e);
            for &(next, e2) in &g.adj[to] {
                if !in_tree[next] {
                    heap.push((Reverse(g.edges[e2].weight), next, e2));
                }
            }
        }
    }
    tree
}

/// Eulerian path: a trail that visits every edge exactly once.
///
/// Returns `None` if no such trail exists. Euler's criterion: in an
/// undirected graph either all degrees are even (then the trail is a circuit
/// and may start anywhere), or exactly two vertices have odd degree (then it
/// starts at one of them). For directed graphs the same, but by the
/// difference of out- and in-degrees. The trail itself is built by
/// Hierholzer's algorithm; if not all edges are eaten, the graph is
/// disconnected and there is no answer.
///
/// ```
/// use graphs::{find_eulerian_path, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
///
/// let trail = find_eulerian_path(&g).unwrap();
/// assert_eq!(trail[0], 0); // starts at the odd-degree vertex
/// assert_eq!(trail[2], 2); // ends at the other
/// ```
pub fn find_eulerian_path(g: &Graph) -> Option<Vec<usize>> {
    let n = g.node_count();
    if g.edge_count() == 0 {
        return if n > 0 { Some(vec![0]) } else { None };
    }

    // 1. Euler's criterion: which vertex to start at, whether a trail exists.
    let start = if g.directed {
        let mut out = vec![0usize; n];
        let mut inn = vec![0usize; n];
        for e in &g.edges {
            out[e.from] += 1;
            inn[e.to] += 1;
        }
        let mut start = None;
        let mut end = None;
        for u in 0..n {
            let diff = out[u] as i64 - inn[u] as i64;
            match diff {
                0 => {}
                1 => {
                    if start.is_some() {
                        return None;
                    }
                    start = Some(u);
                }
                -1 => {
                    if end.is_some() {
                        return None;
                    }
                    end = Some(u);
                }
                _ => return None,
            }
        }
        match start {
            Some(u) => u,
            None => (0..n).find(|&u| g.degree(u) > 0)?,
        }
    } else {
        // A self-loop (u -> u) counts 1 in the model's degree, but Euler's
        // criterion needs it to count 2: add loops to the degree.
        let mut odd = None;
        let mut odd_count = 0;
        for u in 0..n {
            let loops = g.edges.iter().filter(|e| e.from == u && e.to == u).count();
            if (g.degree(u) + loops) % 2 == 1 {
                odd_count += 1;
                odd.get_or_insert(u);
            }
        }
        if odd_count != 0 && odd_count != 2 {
            return None;
        }
        match odd {
            Some(u) => u,
            None => (0..n).find(|&u| g.degree(u) > 0)?,
        }
    };

    // 2. Hierholzer: a trail that eats edges.
    //    In an undirected graph an edge sits in both adjacency lists;
    //    `used` stops it from being eaten twice.
    let adj = g.adj.clone();
    let mut next = vec![0usize; n]; // next unexamined position in the list
    let mut used = vec![false; g.edge_count()];
    let mut stack = vec![start];
    let mut trail = Vec::new();

    while let Some(&u) = stack.last() {
        // Skip already-eaten edges. adj[u][next[u]] is a pair
        // (neighbor, edge id); if that edge is already used (from the other
        // end), the entry is no longer considered.
        while next[u] < adj[u].len() && used[adj[u][next[u]].1] {
            next[u] += 1;
        }
        if next[u] < adj[u].len() {
            let (v, e) = adj[u][next[u]];
            next[u] += 1;
            used[e] = true;
            stack.push(v);
        } else {
            trail.push(u);
            stack.pop();
        }
    }

    // 3. All edges eaten? If not, some edges lie in another component.
    if used.iter().any(|&x| !x) {
        return None;
    }
    trail.reverse();
    Some(trail)
}

/// Whether the graph is bipartite; if so, a 2-coloring of its vertices (0 and 1).
///
/// The coloring is built by a traversal: neighbors get the opposite color; if
/// a neighbor is already colored with the same color, the graph has an odd
/// cycle and is not bipartite (`None`).
///
/// ```
/// use graphs::{is_bipartite, Graph};
///
/// // A square is bipartite.
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 3), (3, 0)]);
/// assert_eq!(is_bipartite(&g).unwrap(), vec![0, 1, 0, 1]);
///
/// // A triangle is not.
/// let mut tri = Graph::undirected();
/// for i in 0..3 { tri.add_node(i.to_string()); }
/// tri.add_edges(&[(0, 1), (1, 2), (2, 0)]);
/// assert!(is_bipartite(&tri).is_none());
/// ```
pub fn is_bipartite(g: &Graph) -> Option<Vec<usize>> {
    let n = g.node_count();
    let mut color = vec![None; n];
    let mut q = VecDeque::new();

    for start in 0..n {
        if color[start].is_some() {
            continue;
        }
        color[start] = Some(0);
        q.push_back(start);
        while let Some(u) = q.pop_front() {
            let cu = color[u].unwrap();
            for &(v, _) in &g.adj[u] {
                match color[v] {
                    None => {
                        color[v] = Some(1 - cu);
                        q.push_back(v);
                    }
                    Some(cv) if cv == cu => return None,
                    _ => {}
                }
            }
        }
    }
    Some(color.into_iter().map(|c| c.unwrap()).collect())
}

/// Bridges -- edges whose removal increases the number of connected components.
///
/// Tarjan's algorithm: a depth-first search with entry times `tin` and
/// low-link values `low` (the earliest entry time reachable via back edges).
/// An edge `(u, v)` is a bridge if $"low"(v) > "tin"(u)`. Undirected graphs
/// only; parallel edges are never bridges.
/// Recursive: may overflow the call stack on very large graphs.
///
/// ```
/// use graphs::{bridges, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
/// assert_eq!(bridges(&g), vec![(0, 1), (1, 2)]);
/// ```
pub fn bridges(g: &Graph) -> Vec<(usize, usize)> {
    assert!(!g.directed, "bridges is for undirected graphs");
    let n = g.node_count();
    let mut tin = vec![0usize; n];
    let mut low = vec![0usize; n];
    let mut timer = 0usize;
    let mut result = Vec::new();

    #[allow(clippy::too_many_arguments)] // recursive Tarjan walk: parameters are the traversal state
    fn visit(
        u: usize,
        parent_edge: Option<usize>,
        g: &Graph,
        tin: &mut [usize],
        low: &mut [usize],
        timer: &mut usize,
        result: &mut Vec<(usize, usize)>,
    ) {
        *timer += 1;
        tin[u] = *timer;
        low[u] = *timer;
        for &(v, e) in &g.adj[u] {
            if Some(e) == parent_edge {
                continue; // the edge we came along, not a back edge
            }
            if tin[v] != 0 {
                low[u] = low[u].min(tin[v]); // back edge into an ancestor
            } else {
                visit(v, Some(e), g, tin, low, timer, result);
                low[u] = low[u].min(low[v]);
                if low[v] > tin[u] {
                    result.push((u.min(v), u.max(v)));
                }
            }
        }
    }

    for start in 0..n {
        if tin[start] == 0 {
            visit(start, None, g, &mut tin, &mut low, &mut timer, &mut result);
        }
    }
    result.sort_unstable(); // deterministic output order
    result
}

/// Articulation points -- vertices whose removal increases the number of components.
///
/// The same Tarjan walk: a non-root vertex `u` is an articulation point if it
/// has a child `v` with $"low"(v) >= "tin"(u)`; the root of a DFS tree -- if
/// it has more than one child. Undirected graphs only.
/// Recursive: may overflow the call stack on very large graphs.
///
/// ```
/// use graphs::{articulation_points, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
/// assert_eq!(articulation_points(&g), vec![1, 2]);
/// ```
pub fn articulation_points(g: &Graph) -> Vec<usize> {
    assert!(!g.directed, "articulation_points is for undirected graphs");
    let n = g.node_count();
    let mut tin = vec![0usize; n];
    let mut low = vec![0usize; n];
    let mut timer = 0usize;
    let mut is_art = vec![false; n];

    #[allow(clippy::too_many_arguments)] // recursive Tarjan walk: parameters are the traversal state
    fn visit(
        u: usize,
        parent_edge: Option<usize>,
        root: usize,
        g: &Graph,
        tin: &mut [usize],
        low: &mut [usize],
        timer: &mut usize,
        is_art: &mut [bool],
    ) {
        *timer += 1;
        tin[u] = *timer;
        low[u] = *timer;
        let mut children = 0usize;
        for &(v, e) in &g.adj[u] {
            if Some(e) == parent_edge {
                continue;
            }
            if tin[v] != 0 {
                low[u] = low[u].min(tin[v]);
            } else {
                visit(v, Some(e), root, g, tin, low, timer, is_art);
                low[u] = low[u].min(low[v]);
                if low[v] >= tin[u] && u != root {
                    is_art[u] = true;
                }
                children += 1;
            }
        }
        if u == root && children > 1 {
            is_art[u] = true;
        }
    }

    for start in 0..n {
        if tin[start] == 0 {
            visit(
                start,
                None,
                start,
                g,
                &mut tin,
                &mut low,
                &mut timer,
                &mut is_art,
            );
        }
    }
    (0..n).filter(|&u| is_art[u]).collect()
}

/// Greedy vertex coloring.
///
/// Vertices are colored in id order; each gets the smallest color
/// (0, 1, 2, ...) not used by any already-colored neighbor. The number of
/// colors depends on the vertex order and is not guaranteed minimal: on a
/// bipartite graph a bad order can make the greedy algorithm use three
/// colors even though two suffice.
///
/// ```
/// use graphs::{greedy_coloring, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
///
/// let colors = greedy_coloring(&g);
/// for e in &g.edges {
///     assert_ne!(colors[e.from], colors[e.to]);
/// }
/// ```
pub fn greedy_coloring(g: &Graph) -> Vec<usize> {
    let n = g.node_count();
    let mut color = vec![0usize; n];
    for u in 0..n {
        let mut taken = vec![false; n + 1];
        for e in &g.edges {
            let v = if e.from == u {
                e.to
            } else if e.to == u {
                e.from
            } else {
                continue;
            };
            if v < u {
                taken[color[v]] = true; // only already-colored neighbors
            }
        }
        color[u] = taken.iter().position(|&t| !t).unwrap();
    }
    color
}

/// Distance between vertices $u$ and $v$ (edges on the shortest path).
///
/// `None` if $v$ is unreachable from $u$. Weights are ignored (this is the
/// unweighted distance).
///
/// ```
/// use graphs::{distance, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
/// assert_eq!(distance(&g, 0, 2), Some(2));
/// ```
pub fn distance(g: &Graph, u: usize, v: usize) -> Option<usize> {
    let dist = bfs(g, u).dist;
    (dist[v] != usize::MAX).then_some(dist[v])
}

/// Eccentricity of a vertex: the maximum distance to reachable vertices.
///
/// ```
/// use graphs::{eccentricity, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..3 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2)]);
/// assert_eq!(eccentricity(&g, 0), Some(2));
/// ```
pub fn eccentricity(g: &Graph, u: usize) -> Option<usize> {
    bfs(g, u)
        .dist
        .into_iter()
        .filter(|&d| d != usize::MAX)
        .max()
}

/// Diameter of the graph: the maximum distance over all pairs of vertices.
///
/// For a disconnected graph -- the maximum within components (vertices in
/// different components have no distance). An empty graph gives `None`.
///
/// ```
/// use graphs::{diameter, Graph};
///
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 1), (1, 2), (2, 3), (3, 0)]);
/// assert_eq!(diameter(&g), Some(2));
/// ```
pub fn diameter(g: &Graph) -> Option<usize> {
    let mut best: Option<usize> = None;
    for u in 0..g.node_count() {
        if let Some(d) = eccentricity(g, u) {
            best = Some(best.map_or(d, |b| b.max(d)));
        }
    }
    best
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Undirected square 0-1-2-3-0.
    fn square() -> Graph {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 3), (3, 0)]);
        g
    }

    /// Undirected path 0-1-2-3.
    fn path() -> Graph {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
        g
    }

    #[test]
    fn bfs_distances_on_square() {
        let res = bfs(&square(), 0);
        assert_eq!(res.dist, vec![0, 1, 2, 1]);
        assert_eq!(res.parent, vec![None, Some(0), Some(1), Some(0)]);
    }

    #[test]
    fn bfs_marks_unreachable_as_max() {
        let mut g = Graph::undirected();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 1);
        let res = bfs(&g, 0);
        assert_eq!(res.dist[2], usize::MAX);
    }

    #[test]
    fn dfs_pre_post_intervals_nest() {
        // DFS parent: pre(parent) < pre(child) < post(child) < post(parent).
        let res = dfs(&path());
        for u in 0..4 {
            if let Some(p) = res.parent[u] {
                assert!(res.pre[p] < res.pre[u]);
                assert!(res.post[u] < res.post[p]);
            }
        }
    }

    #[test]
    fn connected_components_count() {
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (3, 4)]);
        let (count, comp) = connected_components(&g);
        assert_eq!(count, 2);
        assert_eq!(comp[0], comp[1]);
        assert_eq!(comp[0], comp[2]);
        assert_eq!(comp[3], comp[4]);
        assert_ne!(comp[0], comp[3]);
    }

    #[test]
    fn scc_of_cycle_with_tail() {
        let mut g = Graph::directed();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 0), (1, 3), (3, 4)]);
        let sccs = strongly_connected_components(&g);
        assert_eq!(sccs.len(), 3);
        let mut sizes: Vec<usize> = sccs.iter().map(|c| c.len()).collect();
        sizes.sort_unstable();
        assert_eq!(sizes, vec![1, 1, 3]);
    }

    #[test]
    fn cycle_detection() {
        assert!(is_cyclic(&square()));
        assert!(!is_cyclic(&path()));

        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert!(is_cyclic(&g)); // a self-loop is a cycle

        let mut d = Graph::directed();
        for i in 0..3 {
            d.add_node(i.to_string());
        }
        d.add_edges(&[(0, 1), (1, 2)]);
        assert!(!is_cyclic(&d));
        d.add_edge(2, 0);
        assert!(is_cyclic(&d));
    }

    #[test]
    fn topological_sort_orders_prerequisites() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (1, 3), (2, 3)]);
        let order = topological_sort(&g).unwrap();
        assert_eq!(order[0], 0);
        assert_eq!(order[3], 3);
    }

    #[test]
    fn topological_sort_rejects_cycles() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        assert!(topological_sort(&g).is_none());
    }

    #[test]
    fn dijkstra_finds_shortcut_through_middle() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 4);
        g.add_weighted_edge(0, 2, 1);
        g.add_weighted_edge(2, 1, 2);
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0), Some(3), Some(1)]);
    }

    #[test]
    fn dijkstra_unreachable_is_none() {
        let mut g = Graph::directed();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist[1], None);
    }

    #[test]
    fn bellman_ford_handles_negative_edges() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 4);
        g.add_weighted_edge(1, 2, -3);
        let (dist, _) = bellman_ford(&g, 0).unwrap();
        assert_eq!(dist, vec![Some(0), Some(4), Some(1)]);
    }

    #[test]
    fn bellman_ford_detects_negative_cycle() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(1, 2, -5);
        g.add_weighted_edge(2, 1, 1); // cycle 1 -> 2 -> 1 of weight -4
        assert!(bellman_ford(&g, 0).is_none());
    }

    #[test]
    fn bellman_ford_unreachable_negative_cycle_is_ok() {
        // A negative cycle unreachable from start does not break the algorithm.
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 5); // start -> 1
        g.add_weighted_edge(2, 3, 1);
        g.add_weighted_edge(3, 2, -5); // negative cycle 2 <-> 3, unreachable from 0
        let (dist, _) = bellman_ford(&g, 0).unwrap();
        assert_eq!(dist[1], Some(5));
        assert_eq!(dist[2], None); // unreachable
    }

    #[test]
    fn kruskal_builds_spanning_tree() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(1, 2, 2);
        g.add_weighted_edge(2, 3, 3);
        g.add_weighted_edge(3, 0, 10);
        g.add_weighted_edge(0, 2, 100);
        let tree = min_spanning_tree(&g);
        assert_eq!(tree.len(), 3); // 4 vertices, 3 edges
        let total: i64 = tree.iter().map(|&e| g.edge_weight(e)).sum();
        assert_eq!(total, 6);
    }

    #[test]
    fn mst_disconnected_graph_returns_spanning_forest() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(2, 3, 2);
        let tree = min_spanning_tree(&g);
        // Two components, each needs one edge to connect its two vertices.
        assert_eq!(tree.len(), 2);
    }

    #[test]
    fn prim_builds_spanning_tree() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(1, 2, 2);
        g.add_weighted_edge(2, 3, 3);
        g.add_weighted_edge(3, 0, 10);
        g.add_weighted_edge(0, 2, 100);
        let tree = prim(&g);
        assert_eq!(tree.len(), 3); // 4 vertices, 3 edges
        let total: i64 = tree.iter().map(|&e| g.edge_weight(e)).sum();
        assert_eq!(total, 6);
    }

    #[test]
    fn prim_disconnected_graph_returns_spanning_forest() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(2, 3, 2);
        let tree = prim(&g);
        // Two components, each needs one edge to connect its two vertices.
        assert_eq!(tree.len(), 2);
    }

    #[test]
    fn eulerian_circuit_on_square() {
        let trail = find_eulerian_path(&square()).unwrap();
        assert_eq!(trail.len(), 5); // 4 edges, 5 vertices
        assert_eq!(trail[0], trail[4]); // it is a circuit
                                        // Every edge is used exactly once -- check in pairs.
        let mut used = 0;
        for w in trail.windows(2) {
            if square().adjacent(w[0], w[1]) {
                used += 1;
            }
        }
        assert_eq!(used, 4);
    }

    #[test]
    fn eulerian_path_with_two_odd_vertices() {
        // Path 0-1-2-3: odd degrees at 0 and 3.
        let trail = find_eulerian_path(&path()).unwrap();
        assert_eq!(trail.len(), 4); // 3 edges, 4 vertices
        assert_eq!(trail[0], 0);
        assert_eq!(trail[3], 3);
    }

    #[test]
    fn star_is_not_eulerian() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (0, 3)]); // three odd degrees
        assert!(find_eulerian_path(&g).is_none());
    }

    #[test]
    fn disconnected_even_graph_has_no_eulerian_path() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 0), (2, 3), (3, 2)]); // two separate cycles
        assert!(find_eulerian_path(&g).is_none());
    }

    #[test]
    fn bipartite_square_ok_triangle_not() {
        assert_eq!(is_bipartite(&square()).unwrap(), vec![0, 1, 0, 1]);
        let mut tri = Graph::undirected();
        for i in 0..3 {
            tri.add_node(i.to_string());
        }
        tri.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        assert!(is_bipartite(&tri).is_none());
    }

    #[test]
    fn bridges_of_path_are_all_edges() {
        let bs = bridges(&path());
        assert_eq!(bs, vec![(0, 1), (1, 2), (2, 3)]);
    }

    #[test]
    fn square_has_no_bridges() {
        assert!(bridges(&square()).is_empty());
    }

    #[test]
    fn articulation_points_of_path() {
        assert_eq!(articulation_points(&path()), vec![1, 2]);
    }

    #[test]
    fn articulation_points_of_square_empty() {
        assert!(articulation_points(&square()).is_empty());
    }

    #[test]
    fn greedy_coloring_of_triangle_uses_three_colors() {
        let mut tri = Graph::undirected();
        for i in 0..3 {
            tri.add_node(i.to_string());
        }
        tri.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        let colors = greedy_coloring(&tri);
        assert_eq!(colors.iter().max().unwrap() + 1, 3);
        // Neighbors always get different colors.
        for e in &tri.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn distance_diameter_on_square() {
        assert_eq!(distance(&square(), 0, 2), Some(2));
        assert_eq!(diameter(&square()), Some(2));
    }

    #[test]
    fn empty_graph_edge_cases() {
        let g = Graph::undirected();
        assert_eq!(connected_components(&g), (0, vec![]));
        assert!(diameter(&g).is_none());
        assert!(!is_cyclic(&g));
        assert!(min_spanning_tree(&g).is_empty());
        assert!(find_eulerian_path(&g).is_none());
        assert!(greedy_coloring(&g).is_empty());
        // Topological sort and SCC are for directed graphs only.
        let d = Graph::directed();
        assert_eq!(topological_sort(&d), Some(vec![]));
        assert!(strongly_connected_components(&d).is_empty());
    }

    #[test]
    fn single_vertex_edge_cases() {
        let mut g = Graph::undirected();
        g.add_node("only");
        assert_eq!(diameter(&g), Some(0));
        assert_eq!(find_eulerian_path(&g), Some(vec![0]));
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0)]);
    }

    #[test]
    fn parallel_edges_form_a_cycle_and_no_bridge() {
        let mut g = Graph::undirected();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 1);
        g.add_edge(0, 1);
        assert!(is_cyclic(&g));
        assert!(bridges(&g).is_empty());
    }

    #[test]
    fn dijkstra_on_undirected_graph() {
        let mut g = Graph::undirected();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 2);
        g.add_weighted_edge(1, 2, 3);
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0), Some(2), Some(5)]);
    }

    #[test]
    fn euler_path_on_directed_chain() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2)]);
        assert_eq!(find_eulerian_path(&g), Some(vec![0, 1, 2]));
    }

    #[test]
    fn topological_sort_of_edgeless_graph_is_identity() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        assert_eq!(topological_sort(&g), Some(vec![0, 1, 2, 3]));
    }

    #[test]
    fn greedy_coloring_of_star_uses_two_colors() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (0, 3)]);
        let colors = greedy_coloring(&g);
        assert!(*colors.iter().max().unwrap() <= 1);
        // Neighbors always get different colors.
        for e in &g.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn greedy_coloring_of_square_uses_two_colors() {
        // Classic greedy on a 4-cycle gets away with two colors.
        let colors = greedy_coloring(&square());
        assert!(*colors.iter().max().unwrap() <= 1);
    }

    #[test]
    fn greedy_coloring_bipartite_bad_order_uses_three() {
        // Bipartite graph (parts {0, 2, 4} and {1, 3}), yet the greedy
        // algorithm in natural vertex order uses three colors: vertex 4 sees
        // neighbor 1 colored 1 and neighbor 3 colored 0 -- only color 2 is free.
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (3, 4), (1, 4)]);
        assert!(is_bipartite(&g).is_some());
        let colors = greedy_coloring(&g);
        assert_eq!(colors, vec![0, 1, 0, 0, 2]);
        for e in &g.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn eccentricity_of_square_corner() {
        assert_eq!(eccentricity(&square(), 0), Some(2));
    }

    #[test]
    fn euler_circuit_with_self_loop() {
        // A self-loop counts 2 in Euler's criterion: the circuit exists.
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert_eq!(find_eulerian_path(&g), Some(vec![0, 0]));
    }

    #[test]
    fn euler_rejects_two_loops_and_a_tail() {
        // Loops (2 + 2) and edge 0-1: vertex 1 has odd degree -- a path exists.
        let mut g = Graph::undirected();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 0);
        g.add_edge(0, 0);
        g.add_edge(0, 1);
        let trail = find_eulerian_path(&g).unwrap();
        assert_eq!(trail.len(), 4); // 3 edges
    }

    #[test]
    #[should_panic(expected = "is for directed graphs")]
    fn topological_sort_rejects_undirected() {
        topological_sort(&square());
    }

    #[test]
    #[should_panic(expected = "is for directed graphs")]
    fn scc_rejects_undirected() {
        strongly_connected_components(&square());
    }
}
