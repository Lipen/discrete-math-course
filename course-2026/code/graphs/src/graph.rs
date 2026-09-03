//! The graph model: vertices, edges, degrees.
//!
//! `Graph` is a deliberately simple structure: no generics, no traits.
//! Vertices are numbered `0..n` and may have names.
//! Every edge has a weight (1 by default).
//! The graph stores its data twice:
//!
//! - `edges` -- the list of all edges (read by the weighted algorithms: Dijkstra, Kruskal, Bellman--Ford).
//! - `adj` -- the adjacency lists (read by the BFS/DFS traversals).
//!
//! The fields are public: the structure can be read and assembled directly in code, which makes it easier to see how a graph works inside.

/// An edge of the graph.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Edge {
    /// The vertex the edge leaves.
    pub from: usize,
    /// The vertex the edge enters.
    pub to: usize,
    /// The edge weight (an integer: algorithms that need non-negativity document it themselves).
    pub weight: i64,
}

/// A graph: directed or undirected, with vertex names and edge weights.
///
/// Methods and algorithms that take vertex ids panic if the id is outside `0..node_count()`.
/// Ids come from `add_node` and `add_edge`.
///
/// ```
/// use graphs::Graph;
///
/// let mut g = Graph::undirected();
/// let a = g.add_node("a");
/// let b = g.add_node("b");
/// g.add_edge(a, b);
///
/// assert_eq!(g.node_count(), 2);
/// assert_eq!(g.edge_count(), 1);
/// assert!(g.adjacent(a, b));
/// ```
#[derive(Debug, Clone)]
pub struct Graph {
    /// `true` -- a directed graph (edges are arrows), `false` -- undirected.
    pub directed: bool,
    /// Name of vertex `i` (for printing and for pictures).
    pub names: Vec<String>,
    /// Adjacency lists: `adj[u]` holds pairs (neighbor, edge id).
    ///
    /// In an undirected graph an edge lands in the lists of both vertices, in a directed one -- only in the source's list.
    /// A self-loop (edge `u -> u`) sits in the list once.
    pub adj: Vec<Vec<(usize, usize)>>,
    /// All edges of the graph.
    /// `edges[e]` is the edge with id `e`.
    pub edges: Vec<Edge>,
}

impl Graph {
    /// A new empty undirected graph.
    ///
    /// ```
    /// use graphs::Graph;
    /// let g = Graph::undirected();
    /// assert!(!g.is_directed());
    /// assert_eq!(g.node_count(), 0);
    /// ```
    pub fn undirected() -> Self {
        Self::new(false)
    }

    /// A new empty directed graph.
    ///
    /// ```
    /// use graphs::Graph;
    /// let g = Graph::directed();
    /// assert!(g.is_directed());
    /// assert_eq!(g.node_count(), 0);
    /// ```
    pub fn directed() -> Self {
        Self::new(true)
    }

    fn new(directed: bool) -> Self {
        Graph {
            directed,
            names: Vec::new(),
            adj: Vec::new(),
            edges: Vec::new(),
        }
    }

    /// Add a vertex with a name.
    /// Returns its id.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("A");
    /// let b = g.add_node("B");
    /// assert_eq!(a, 0);
    /// assert_eq!(b, 1);
    /// assert_eq!(g.node_name(a), "A");
    /// ```
    pub fn add_node(&mut self, name: impl Into<String>) -> usize {
        let id = self.names.len();
        self.names.push(name.into());
        self.adj.push(Vec::new());
        id
    }

    /// Add an edge with weight 1.
    /// Returns the edge id.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// let e = g.add_edge(a, b);
    /// assert_eq!(g.edge_weight(e), 1);
    /// assert!(g.adjacent(a, b));
    /// ```
    pub fn add_edge(&mut self, from: usize, to: usize) -> usize {
        self.add_weighted_edge(from, to, 1)
    }

    /// Add an edge with a weight.
    /// Returns the edge id.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// let e = g.add_weighted_edge(a, b, 5);
    /// assert_eq!(g.edge_weight(e), 5);
    /// ```
    pub fn add_weighted_edge(&mut self, from: usize, to: usize, weight: i64) -> usize {
        let id = self.edges.len();
        self.edges.push(Edge { from, to, weight });
        self.adj[from].push((to, id));
        if !self.directed && from != to {
            self.adj[to].push((from, id));
        }
        id
    }

    /// Add several edges with weight 1: `add_edges(&[(0, 1), (1, 2)])`.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// let c = g.add_node("c");
    /// g.add_edges(&[(a, b), (b, c)]);
    /// assert_eq!(g.edge_count(), 2);
    /// assert!(g.adjacent(a, b));
    /// assert!(g.adjacent(b, c));
    /// ```
    pub fn add_edges(&mut self, pairs: &[(usize, usize)]) {
        for &(from, to) in pairs {
            self.add_edge(from, to);
        }
    }

    /// How many vertices the graph has.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// assert_eq!(g.node_count(), 0);
    /// g.add_node("x");
    /// assert_eq!(g.node_count(), 1);
    /// ```
    pub fn node_count(&self) -> usize {
        self.names.len()
    }

    /// How many edges the graph has.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// assert_eq!(g.edge_count(), 0);
    /// g.add_node("a");
    /// g.add_node("b");
    /// g.add_edge(0, 1);
    /// assert_eq!(g.edge_count(), 1);
    /// ```
    pub fn edge_count(&self) -> usize {
        self.edges.len()
    }

    /// Whether the graph is directed.
    ///
    /// ```
    /// use graphs::Graph;
    /// assert!(Graph::directed().is_directed());
    /// assert!(!Graph::undirected().is_directed());
    /// ```
    pub fn is_directed(&self) -> bool {
        self.directed
    }

    /// Name of vertex `u`.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// g.add_node("alpha");
    /// assert_eq!(g.node_name(0), "alpha");
    /// ```
    pub fn node_name(&self, u: usize) -> &str {
        &self.names[u]
    }

    /// Neighbors of vertex `u`: pairs (neighbor, edge id).
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// let e = g.add_edge(a, b);
    /// assert_eq!(g.neighbors(a), &[(b, e)]);
    /// ```
    pub fn neighbors(&self, u: usize) -> &[(usize, usize)] {
        &self.adj[u]
    }

    /// Degree of vertex `u` -- the number of neighbors.
    ///
    /// For a directed graph this is the out-degree (the number of edges leaving `u`).
    /// See [`in_degree`](Graph::in_degree) for the edges entering the vertex.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// g.add_edge(a, b);
    /// assert_eq!(g.degree(a), 1);
    /// assert_eq!(g.degree(b), 1);
    /// ```
    pub fn degree(&self, u: usize) -> usize {
        self.adj[u].len()
    }

    /// In-degree of vertex `u` -- the number of edges entering `u`.
    ///
    /// For an undirected graph this is the same as [`degree`](Graph::degree).
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::directed();
    /// let a = g.add_node("a");
    /// let b = g.add_node("b");
    /// g.add_edge(a, b);
    /// assert_eq!(g.degree(a), 1);    // out-degree
    /// assert_eq!(g.in_degree(b), 1); // in-degree
    /// assert_eq!(g.in_degree(a), 0);
    ///
    /// let mut ug = Graph::undirected();
    /// ug.add_node("x");
    /// ug.add_node("y");
    /// ug.add_edge(0, 1);
    /// assert_eq!(ug.in_degree(0), 1); // same as degree for undirected
    /// ```
    pub fn in_degree(&self, u: usize) -> usize {
        if !self.directed {
            return self.degree(u);
        }
        self.edges.iter().filter(|e| e.to == u).count()
    }

    /// Weight of the edge with id `e`.
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// g.add_node("a");
    /// g.add_node("b");
    /// let e = g.add_weighted_edge(0, 1, 7);
    /// assert_eq!(g.edge_weight(e), 7);
    /// ```
    pub fn edge_weight(&self, e: usize) -> i64 {
        self.edges[e].weight
    }

    /// Whether there is an edge from `u` to `v` (for an undirected graph -- at least in one direction).
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// g.add_node("a");
    /// g.add_node("b");
    /// g.add_edge(0, 1);
    /// assert!(g.adjacent(0, 1));
    /// assert!(g.adjacent(1, 0));
    /// ```
    pub fn adjacent(&self, u: usize, v: usize) -> bool {
        self.adj[u].iter().any(|&(w, _)| w == v)
    }

    /// Degrees of all vertices (for the handshake lemma and histograms).
    ///
    /// ```
    /// use graphs::Graph;
    /// let mut g = Graph::undirected();
    /// for i in 0..3 { g.add_node(i.to_string()); }
    /// g.add_edges(&[(0, 1), (1, 2)]);
    /// assert_eq!(g.degrees(), vec![1, 2, 1]);
    /// ```
    pub fn degrees(&self) -> Vec<usize> {
        (0..self.node_count()).map(|u| self.degree(u)).collect()
    }

    /// A random undirected Erdős--Rényi graph $G(n, p)$.
    ///
    /// `n` vertices, every edge appears independently with probability `p` (which must lie in the interval `[0, 1]`).
    /// `seed` fixes the generator, so the same seed always gives the same graph (for reproducible examples).
    ///
    /// ```
    /// use graphs::Graph;
    /// let g = Graph::erdos_renyi(5, 0.5, 42);
    /// assert_eq!(g.node_count(), 5);
    /// assert!(!g.is_directed());
    /// // The same seed gives the same graph.
    /// let h = Graph::erdos_renyi(5, 0.5, 42);
    /// assert_eq!(g.edges, h.edges);
    /// ```
    pub fn erdos_renyi(n: usize, p: f64, seed: u64) -> Graph {
        assert!((0.0..=1.0).contains(&p), "p must be in [0, 1]");
        let mut g = Graph::undirected();
        for i in 0..n {
            g.add_node(i.to_string());
        }
        let mut rng = XorShift64::new(seed);
        for u in 0..n {
            for v in (u + 1)..n {
                if rng.next_f64() < p {
                    g.add_edge(u, v);
                }
            }
        }
        g
    }
}

/// A tiny random number generator (xorshift64), kept to avoid an external dependency.
/// Good for teaching examples, not for cryptography.
struct XorShift64(u64);

impl XorShift64 {
    fn new(seed: u64) -> Self {
        XorShift64(seed | 1) // zero is forbidden
    }

    fn next_u64(&mut self) -> u64 {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        x
    }

    /// A number from the interval [0, 1).
    fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 / (1u64 << 53) as f64
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn undirected_edge_lands_in_both_lists() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        let e = g.add_edge(a, b);
        assert_eq!(g.neighbors(a), &[(b, e)]);
        assert_eq!(g.neighbors(b), &[(a, e)]);
        assert_eq!(g.degree(a), 1);
        assert_eq!(g.degree(b), 1);
        assert!(g.adjacent(a, b));
        assert!(g.adjacent(b, a));
    }

    #[test]
    fn directed_edge_lands_only_in_source_list() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        assert_eq!(g.neighbors(a).len(), 1);
        assert_eq!(g.neighbors(b).len(), 0);
        assert!(g.adjacent(a, b));
        assert!(!g.adjacent(b, a));
    }

    #[test]
    fn in_degree_counts_incoming_edges() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        let c = g.add_node("c");
        g.add_edge(a, b);
        g.add_edge(c, b);
        assert_eq!(g.in_degree(a), 0);
        assert_eq!(g.in_degree(b), 2);
        assert_eq!(g.in_degree(c), 0);
        // In an undirected graph, degree and in_degree coincide.
        let mut ug = Graph::undirected();
        ug.add_node("x");
        ug.add_node("y");
        ug.add_edge(0, 1);
        assert_eq!(ug.in_degree(0), 1);
        assert_eq!(ug.in_degree(1), 1);
    }

    #[test]
    fn self_loop_appears_once() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert_eq!(g.neighbors(a), &[(a, 0)]);
        assert_eq!(g.degree(a), 1);
    }

    #[test]
    fn weighted_edges_keep_weights() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        let e = g.add_weighted_edge(a, b, 7);
        assert_eq!(g.edge_weight(e), 7);
    }

    #[test]
    fn handshake_lemma_even_sum() {
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (1, 2), (2, 3), (3, 4)]);
        let sum: usize = g.degrees().iter().sum();
        assert_eq!(sum, 2 * g.edge_count());
    }

    #[test]
    fn erdos_renyi_deterministic() {
        let g1 = Graph::erdos_renyi(10, 0.3, 42);
        let g2 = Graph::erdos_renyi(10, 0.3, 42);
        assert_eq!(g1.edges, g2.edges);
        assert_eq!(g1.node_count(), 10);
        assert!(!g1.directed);
    }

    #[test]
    fn erdos_renyi_extremes() {
        // p = 0: no edges; p = 1: the complete graph.
        assert_eq!(Graph::erdos_renyi(5, 0.0, 1).edge_count(), 0);
        let complete = Graph::erdos_renyi(5, 1.0, 1);
        assert_eq!(complete.edge_count(), 5 * 4 / 2);
    }
}
