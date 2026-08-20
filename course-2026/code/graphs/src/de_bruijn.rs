//! De Bruijn graphs and genome assembly.
//!
//! The classic genome-assembly pipeline turns short sequenced fragments
//! (reads) into one long string:
//!
//! 1. chop every read into k-mers (substrings of length `k`);
//! 2. build the de Bruijn graph: vertices are the (k-1)-mers, and every
//!    k-mer `s` becomes an edge from its first (k-1) characters to its
//!    last (k-1) characters;
//! 3. find an Eulerian path -- a trail that uses every edge exactly once;
//!    the path spells the assembled genome.
//!
//! Why does an Eulerian path give the genome? Two consecutive edges
//! `x -> y` and `y -> z` overlap in the (k-1)-mer `y`, so the second edge
//! continues exactly where the first ended: their k-mers are
//! `x + y[k-2]` and `y + z[k-2]`. Walking every edge in a trail therefore
//! concatenates the reads into one contiguous string.
//!
//! Worked example. The reads `ACG`, `CGT`, `GTA` with `k = 3`:
//!
//! - vertices (2-mers): `AC`, `CG`, `GT`, `TA`;
//! - edges (3-mers): `AC -> CG` (read `ACG`), `CG -> GT` (read `CGT`),
//!   `GT -> TA` (read `GTA`);
//! - the Eulerian path `AC -> CG -> GT -> TA` spells
//!   `AC` + `G` + `T` + `A` = `ACGTA`, the original genome.
//!
//! Reads from a circular genome close the trail into a cycle, and the
//! assembled string is a rotation of the genome -- any rotation is a valid
//! assembly.
//!
//! ```
//! use graphs::DeBruijnGraph;
//!
//! let reads = ["ACG", "CGT", "GTA"];
//! let g = DeBruijnGraph::build(&reads, 3);
//! assert_eq!(g.assemble().as_deref(), Some("ACGTA"));
//! ```

use std::collections::HashMap;

/// A de Bruijn graph built from k-mer reads.
///
/// `names[v]` is the (k-1)-mer at vertex id `v`; `adj[u]` holds pairs
/// `(to, count)` -- how many reads spell the edge `u -> to`. Both fields
/// are public: the graph is a plain structure you can read and build by
/// hand.
///
/// ```
/// use graphs::DeBruijnGraph;
///
/// let g = DeBruijnGraph::build(&["ACG", "CGT", "GTA"], 3);
/// assert_eq!(g.node_count(), 4);
/// assert_eq!(g.names, vec!["AC", "CG", "GT", "TA"]);
/// ```
#[derive(Debug, Clone)]
pub struct DeBruijnGraph {
    /// The `k` of the k-mers: vertices are (k-1)-mers, edges are k-mers.
    pub k: usize,
    /// `names[v]` -- the (k-1)-mer at vertex `v`.
    pub names: Vec<String>,
    /// `adj[u]` -- pairs (neighbor, edge count).
    pub adj: Vec<Vec<(usize, usize)>>,
    /// (k-1)-mer -> vertex id (private: ids come from `add_edge`).
    ids: HashMap<String, usize>,
}

impl DeBruijnGraph {
    /// Build the graph from reads: every substring of length `k` of every
    /// read becomes one edge (a read longer than `k` is chopped into
    /// k-mers). A read repeated twice raises the edge count twice, and the
    /// Eulerian path must use the edge as many times -- that is exactly
    /// how repeated coverage is handled.
    ///
    /// Panics if `k < 2` or a read is shorter than `k`.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// // A read longer than k is chopped into k-mers.
    /// let g = DeBruijnGraph::build(&["ACGT"], 3);
    /// assert_eq!(g.node_count(), 3); // AC, CG, GT
    /// assert_eq!(g.edge_count(), 2); // ACG, CGT
    /// ```
    pub fn build(reads: &[&str], k: usize) -> DeBruijnGraph {
        assert!(k >= 2, "k must be at least 2");
        let mut g = DeBruijnGraph {
            k,
            names: Vec::new(),
            adj: Vec::new(),
            ids: HashMap::new(),
        };
        for &read in reads {
            assert!(read.len() >= k, "read shorter than k: {read:?}");
            for i in 0..=(read.len() - k) {
                let mer = &read[i..i + k];
                let u = g.vertex_id_or_add(&mer[..k - 1]);
                let v = g.vertex_id_or_add(&mer[1..]);
                g.add_edge(u, v);
            }
        }
        g
    }

    /// The vertex id of a (k-1)-mer, if it appears in the graph.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// let g = DeBruijnGraph::build(&["ACG", "CGT"], 3);
    /// assert_eq!(g.vertex_id("AC"), Some(0));
    /// assert_eq!(g.vertex_id("GT"), Some(2));
    /// assert_eq!(g.vertex_id("XX"), None);
    /// ```
    pub fn vertex_id(&self, mer: &str) -> Option<usize> {
        self.ids.get(mer).copied()
    }

    /// How many vertices the graph has.
    pub fn node_count(&self) -> usize {
        self.names.len()
    }

    /// How many edges the graph has, counting multiplicities.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// let g = DeBruijnGraph::build(&["ACG", "ACG", "CGT"], 3);
    /// assert_eq!(g.edge_count(), 3); // the repeated read counts twice
    /// ```
    pub fn edge_count(&self) -> usize {
        self.adj
            .iter()
            .map(|lst| lst.iter().map(|&(_, c)| c).sum::<usize>())
            .sum()
    }

    /// The k-mer spelled by the edge `u -> v`: the (k-1)-mer of `u` plus
    /// the last character of the (k-1)-mer of `v`.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// let g = DeBruijnGraph::build(&["ACG", "CGT"], 3);
    /// assert_eq!(g.edge_label(0, 1), "ACG"); // AC + G
    /// assert_eq!(g.edge_label(1, 2), "CGT"); // CG + T
    /// ```
    pub fn edge_label(&self, u: usize, v: usize) -> String {
        let mut label = String::with_capacity(self.k);
        label.push_str(&self.names[u]);
        label.push(self.names[v].chars().last().unwrap());
        label
    }

    /// An Eulerian path or cycle: a trail that uses every edge exactly
    /// once, as a sequence of vertex ids. `None` if no such trail exists.
    ///
    /// Euler's criterion for directed graphs: every vertex needs equal
    /// out- and in-degree, except at most one vertex with one more
    /// outgoing edge (the start of the trail) and at most one with one
    /// more incoming edge (the end). If every balance is zero the trail is
    /// a cycle and may start anywhere. The trail itself is built by
    /// Hierholzer's algorithm: walk edges greedily and splice the walk
    /// into the finished trail when a vertex runs out of unused edges.
    /// Runs in $O(V + E)$.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// // A path: AC -> CG -> GT -> TA.
    /// let g = DeBruijnGraph::build(&["ACG", "CGT", "GTA"], 3);
    /// let path = g.eulerian_path().unwrap();
    /// assert_eq!(path, vec![0, 1, 2, 3]);
    /// assert_eq!(g.genome_from_path(&path), "ACGTA");
    ///
    /// // A cycle: the same reads plus one that closes the loop.
    /// let g = DeBruijnGraph::build(&["ACG", "CGT", "GTA", "TAC"], 3);
    /// let cycle = g.eulerian_path().unwrap();
    /// assert_eq!(cycle.first(), cycle.last());
    /// assert_eq!(g.genome_from_path(&cycle).len(), 6); // circular genome
    /// ```
    pub fn eulerian_path(&self) -> Option<Vec<usize>> {
        let n = self.node_count();

        // Out- and in-degrees, counting multiplicities.
        let mut out = vec![0usize; n];
        let mut inn = vec![0usize; n];
        for (u, edges) in self.adj.iter().enumerate() {
            for &(v, c) in edges {
                out[u] += c;
                inn[v] += c;
            }
        }
        if out.iter().sum::<usize>() == 0 {
            return None; // no edges at all
        }

        // Euler's criterion: all balances zero, or one +1 and one -1.
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
        let start = match start {
            Some(u) => u,
            None => (0..n).find(|&u| out[u] > 0)?,
        };

        // Hierholzer with edge counts: `rest` holds the unused edges,
        // `next` the position of the next unexamined entry in each list.
        let mut rest = self.adj.clone();
        let mut next = vec![0usize; n];
        let mut stack = vec![start];
        let mut trail = Vec::new();

        while let Some(&u) = stack.last() {
            while next[u] < rest[u].len() && rest[u][next[u]].1 == 0 {
                next[u] += 1;
            }
            if next[u] < rest[u].len() {
                let (v, _) = rest[u][next[u]];
                rest[u][next[u]].1 -= 1;
                stack.push(v);
            } else {
                trail.push(u);
                stack.pop();
            }
        }

        // All edges eaten? If not, some edges lie in another component.
        for lst in &rest {
            for &(_, c) in lst {
                if c > 0 {
                    return None;
                }
            }
        }
        trail.reverse();
        Some(trail)
    }

    /// Reconstruct the genome from an Eulerian path: the (k-1)-mer of the
    /// start vertex, then the last character of every following vertex.
    /// Consecutive path vertices overlap in (k-1) characters, so this
    /// concatenates the reads spelled by the path into one string.
    ///
    /// An empty path gives an empty string.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// let g = DeBruijnGraph::build(&["ACG", "CGT", "GTA"], 3);
    /// let path = g.eulerian_path().unwrap();
    /// assert_eq!(g.genome_from_path(&path), "ACGTA");
    /// ```
    pub fn genome_from_path(&self, path: &[usize]) -> String {
        let mut genome = String::new();
        if let Some(&start) = path.first() {
            genome.push_str(&self.names[start]);
            for &v in &path[1..] {
                genome.push(self.names[v].chars().last().unwrap());
            }
        }
        genome
    }

    /// Assemble the genome in one call: find the Eulerian path, then read
    /// the string it spells. `None` if the graph has no Eulerian path.
    ///
    /// ```
    /// use graphs::DeBruijnGraph;
    ///
    /// let g = DeBruijnGraph::build(&["ACG", "CGT", "GTA"], 3);
    /// assert_eq!(g.assemble().as_deref(), Some("ACGTA"));
    /// ```
    pub fn assemble(&self) -> Option<String> {
        let path = self.eulerian_path()?;
        Some(self.genome_from_path(&path))
    }

    fn vertex_id_or_add(&mut self, mer: &str) -> usize {
        if let Some(&id) = self.ids.get(mer) {
            return id;
        }
        let id = self.names.len();
        self.names.push(mer.to_string());
        self.adj.push(Vec::new());
        self.ids.insert(mer.to_string(), id);
        id
    }

    fn add_edge(&mut self, from: usize, to: usize) {
        for entry in &mut self.adj[from] {
            if entry.0 == to {
                entry.1 += 1;
                return;
            }
        }
        self.adj[from].push((to, 1));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn repeated_reads_count_as_separate_edges() {
        // One repeated read unbalances the graph; the trail must start at
        // AC (one more outgoing edge) and end at CG (one more incoming).
        let g = DeBruijnGraph::build(&["ACG", "ACG", "CGT", "GTA", "TAC"], 3);
        assert_eq!(g.edge_count(), 5);
        let genome = g.assemble().unwrap();
        assert_eq!(genome, "ACGTACG");
        // Every read appears in the assembled string.
        for read in ["ACG", "CGT", "GTA", "TAC"] {
            assert!(genome.contains(read));
        }
    }

    #[test]
    fn self_loops_work() {
        // k = 2: one vertex "A" and a self-loop, twice.
        let g = DeBruijnGraph::build(&["AA", "AA"], 2);
        assert_eq!(g.assemble().as_deref(), Some("AAA"));
    }

    #[test]
    fn unbalanced_graph_has_no_eulerian_path() {
        // GT receives two edges but sends out one: no trail can end there.
        let g = DeBruijnGraph::build(&["ACG", "CGT", "CGT"], 3);
        assert!(g.eulerian_path().is_none());
    }

    #[test]
    fn disconnected_edges_have_no_eulerian_path() {
        // Two separate trails would need two starts.
        let g = DeBruijnGraph::build(&["ACG", "CGT", "TTA", "TAT"], 3);
        assert!(g.eulerian_path().is_none());
    }

    #[test]
    fn long_reads_are_chopped() {
        let g = DeBruijnGraph::build(&["ACGTAC"], 3);
        assert_eq!(g.edge_count(), 4); // ACG, CGT, GTA, TAC
        assert_eq!(g.names.len(), 4); // AC, CG, GT, TA
    }

    #[test]
    fn build_rejects_short_reads_and_tiny_k() {
        assert!(std::panic::catch_unwind(|| DeBruijnGraph::build(&["AC"], 3)).is_err());
        assert!(std::panic::catch_unwind(|| DeBruijnGraph::build(&["ACG"], 1)).is_err());
    }
}
