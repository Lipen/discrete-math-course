//! The adjacency matrix representation.
//!
//! [`Graph`] stores edges in a list and in adjacency lists --
//! the natural choice for sparse graphs and for traversals. The second
//! classic representation is the adjacency matrix: an `n x n` table where
//! the cell `(u, v)` holds the weight of the edge `u -> v` (or `None`).
//!
//! The matrix pays off when the graph is dense, when edge tests must run
//! in $O(1)$, and -- the reason it matters in a course -- when the graph
//! is studied with linear algebra: the number of walks of length `L` from
//! `u` to `v` is the entry `(u, v)` of the `L`-th power of the adjacency
//! matrix ([`AdjMatrix::count_walks`]).
//!
//! One thing a matrix cannot do is represent parallel edges: a conversion
//! from [`Graph`] collapses them and keeps the lightest
//! weight. Conversions in both directions are provided.

use crate::graph::Graph;

/// A graph stored as an `n x n` matrix of edge weights.
///
/// `w[u][v]` is the weight of the edge `u -> v`; `None` means no edge.
/// The fields are public, and the matrix can be built by hand.
///
/// ```
/// use graphs::AdjMatrix;
///
/// let mut m = AdjMatrix::new(3, true);
/// m.add_edge(0, 1, 5);
/// assert_eq!(m.node_count(), 3);
/// assert_eq!(m.weight(0, 1), Some(5));
/// assert_eq!(m.weight(1, 0), None);
/// assert!(m.has_edge(0, 1));
/// assert_eq!(m.neighbors(0), vec![1]);
/// assert_eq!(m.in_neighbors(1), vec![0]);
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AdjMatrix {
    /// `true` -- a directed graph (an arbitrary matrix), `false` -- an
    /// undirected one (a symmetric matrix).
    pub directed: bool,
    /// `w[u][v]` -- the weight of the edge `u -> v`, or `None` if there is
    /// no edge.
    pub w: Vec<Vec<Option<i64>>>,
}

impl AdjMatrix {
    /// A new empty matrix on `n` vertices (no edges).
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// let m = AdjMatrix::new(2, false);
    /// assert_eq!(m.node_count(), 2);
    /// assert_eq!(m.weight(0, 1), None);
    /// ```
    pub fn new(n: usize, directed: bool) -> Self {
        AdjMatrix {
            directed,
            w: vec![vec![None; n]; n],
        }
    }

    /// How many vertices the matrix has.
    pub fn node_count(&self) -> usize {
        self.w.len()
    }

    /// Add an edge `u -> v` with a weight (or update it).
    ///
    /// If the cell already holds an edge, the lighter weight wins -- this
    /// is what a conversion from a multigraph needs. For an undirected
    /// matrix the reverse cell is updated the same way.
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// let mut m = AdjMatrix::new(2, false);
    /// m.add_edge(0, 1, 5);
    /// m.add_edge(0, 1, 2); // a parallel edge: the lighter one survives
    /// assert_eq!(m.weight(0, 1), Some(2));
    /// assert_eq!(m.weight(1, 0), Some(2)); // undirected: symmetric
    /// ```
    pub fn add_edge(&mut self, u: usize, v: usize, weight: i64) {
        self.set_cell(u, v, weight);
        if !self.directed && u != v {
            self.set_cell(v, u, weight);
        }
    }

    fn set_cell(&mut self, u: usize, v: usize, weight: i64) {
        let cell = &mut self.w[u][v];
        *cell = Some(match *cell {
            Some(old) if old <= weight => old,
            _ => weight,
        });
    }

    /// Whether there is an edge `u -> v`.
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// let mut m = AdjMatrix::new(2, true);
    /// m.add_edge(0, 1, 1);
    /// assert!(m.has_edge(0, 1));
    /// assert!(!m.has_edge(1, 0));
    /// ```
    pub fn has_edge(&self, u: usize, v: usize) -> bool {
        self.w[u][v].is_some()
    }

    /// The weight of the edge `u -> v`, or `None`.
    pub fn weight(&self, u: usize, v: usize) -> Option<i64> {
        self.w[u][v]
    }

    /// Vertices reachable from `u` by one edge (its out-neighbors).
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// let mut m = AdjMatrix::new(3, true);
    /// m.add_edge(0, 1, 1);
    /// m.add_edge(0, 2, 1);
    /// assert_eq!(m.neighbors(0), vec![1, 2]);
    /// assert!(m.neighbors(1).is_empty());
    /// ```
    pub fn neighbors(&self, u: usize) -> Vec<usize> {
        (0..self.node_count())
            .filter(|&v| self.w[u][v].is_some())
            .collect()
    }

    /// Vertices with an edge into `u` (its in-neighbors).
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// let mut m = AdjMatrix::new(3, true);
    /// m.add_edge(0, 2, 1);
    /// m.add_edge(1, 2, 1);
    /// assert_eq!(m.in_neighbors(2), vec![0, 1]);
    /// ```
    pub fn in_neighbors(&self, u: usize) -> Vec<usize> {
        (0..self.node_count())
            .filter(|&v| self.w[v][u].is_some())
            .collect()
    }

    /// Build the matrix from a [`Graph`].
    ///
    /// Parallel edges collapse to the lightest one; self-loops are kept;
    /// vertex names are lost (the matrix stores only ids).
    ///
    /// ```
    /// use graphs::{AdjMatrix, Graph};
    ///
    /// let mut g = Graph::undirected();
    /// for i in 0..3 { g.add_node(i.to_string()); }
    /// g.add_weighted_edge(0, 1, 3);
    /// g.add_weighted_edge(1, 2, 4);
    ///
    /// let m = AdjMatrix::from_graph(&g);
    /// assert!(m.has_edge(0, 1));
    /// assert!(m.has_edge(1, 0)); // undirected: symmetric
    /// assert!(!m.has_edge(0, 2));
    /// assert_eq!(m.weight(1, 2), Some(4));
    /// ```
    pub fn from_graph(g: &Graph) -> AdjMatrix {
        let mut m = AdjMatrix::new(g.node_count(), g.directed);
        for e in &g.edges {
            m.add_edge(e.from, e.to, e.weight);
        }
        m
    }

    /// Build a [`Graph`] with the same edges and weights.
    ///
    /// The matrix stores no names, so vertices are named `"0"`, `"1"`,
    /// ... in id order. In an undirected matrix every edge is stored
    /// twice (symmetric cells); the graph gets it once.
    ///
    /// ```
    /// use graphs::{AdjMatrix, Graph};
    ///
    /// let mut g = Graph::undirected();
    /// for i in 0..3 { g.add_node(i.to_string()); }
    /// g.add_weighted_edge(0, 1, 3);
    /// g.add_weighted_edge(1, 2, 4);
    ///
    /// let back = AdjMatrix::from_graph(&g).to_graph();
    /// assert_eq!(back.edges, g.edges); // same edges, same weights
    /// ```
    pub fn to_graph(&self) -> Graph {
        let mut g = if self.directed {
            Graph::directed()
        } else {
            Graph::undirected()
        };
        for i in 0..self.node_count() {
            g.add_node(i.to_string());
        }
        for u in 0..self.node_count() {
            for v in 0..self.node_count() {
                if let Some(w) = self.w[u][v] {
                    // Undirected: the reverse cell is the same edge.
                    if !self.directed && u > v {
                        continue;
                    }
                    g.add_weighted_edge(u, v, w);
                }
            }
        }
        g
    }

    /// The number of walks of length `len` from `u` to `v`.
    ///
    /// A walk may repeat vertices and edges; this is exactly the entry
    /// `(u, v)` of the `len`-th power of the boolean adjacency matrix.
    /// Counts are `u64`: they can overflow on big graphs and lengths.
    ///
    /// ```
    /// use graphs::AdjMatrix;
    ///
    /// // A directed triangle 0 -> 1 -> 2 -> 0.
    /// let mut m = AdjMatrix::new(3, true);
    /// m.add_edge(0, 1, 1);
    /// m.add_edge(1, 2, 1);
    /// m.add_edge(2, 0, 1);
    ///
    /// // Length 2: 0 -> 1 -> 2 is the only walk from 0 to 2.
    /// assert_eq!(m.count_walks(0, 2, 2), 1);
    /// // Length 3: 0 -> 1 -> 2 -> 0 closes the triangle.
    /// assert_eq!(m.count_walks(0, 0, 3), 1);
    /// // Length 1 from 0 to 1.
    /// assert_eq!(m.count_walks(0, 1, 1), 1);
    /// ```
    pub fn count_walks(&self, u: usize, v: usize, len: usize) -> u64 {
        let n = self.node_count();
        // Start vector: one walk of length 0 at u.
        let mut walks = vec![0u64; n];
        walks[u] = 1;
        for _ in 0..len {
            // One step: extend every existing walk along the edges.
            let mut next = vec![0u64; n];
            for (a, &wa) in walks.iter().enumerate() {
                if wa == 0 {
                    continue;
                }
                for (b, cell) in self.w[a].iter().enumerate() {
                    if cell.is_some() {
                        next[b] += wa;
                    }
                }
            }
            walks = next;
        }
        walks[v]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn undirected_matrix_is_symmetric() {
        let mut m = AdjMatrix::new(3, false);
        m.add_edge(0, 1, 7);
        m.add_edge(2, 2, 1); // self-loop, no symmetric partner needed
        assert_eq!(m.weight(0, 1), Some(7));
        assert_eq!(m.weight(1, 0), Some(7));
        assert_eq!(m.weight(2, 2), Some(1));
        assert_eq!(m.neighbors(0), vec![1]);
        assert_eq!(m.in_neighbors(1), vec![0]);
    }

    #[test]
    fn conversion_round_trip_preserves_edges() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 5);
        g.add_weighted_edge(1, 2, -3);
        g.add_weighted_edge(2, 0, 9);
        let back = AdjMatrix::from_graph(&g).to_graph();
        assert_eq!(back.edges, g.edges);
        assert!(back.directed);
    }

    #[test]
    fn parallel_edges_collapse_to_the_lightest() {
        let mut g = Graph::undirected();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 5);
        g.add_weighted_edge(0, 1, 2);
        g.add_weighted_edge(0, 1, 7);
        let m = AdjMatrix::from_graph(&g);
        assert_eq!(m.weight(0, 1), Some(2));
        let back = m.to_graph();
        assert_eq!(back.edge_count(), 1); // one edge survives
        assert_eq!(back.edge_weight(0), 2);
    }

    #[test]
    fn count_walks_on_a_square() {
        // An undirected square: 0-1-2-3-0.
        let mut m = AdjMatrix::new(4, false);
        m.add_edge(0, 1, 1);
        m.add_edge(1, 2, 1);
        m.add_edge(2, 3, 1);
        m.add_edge(3, 0, 1);
        // Two walks of length 2 from 0 back to 0: 0-1-0 and 0-3-0.
        assert_eq!(m.count_walks(0, 0, 2), 2);
        // Two walks of length 2 from 0 to 2: 0-1-2 and 0-3-2.
        assert_eq!(m.count_walks(0, 2, 2), 2);
        // No walks of odd length between opposite corners (bipartite).
        assert_eq!(m.count_walks(0, 2, 1), 0);
    }
}
