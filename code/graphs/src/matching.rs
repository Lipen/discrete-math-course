//! Maximum matching in bipartite graphs.
//!
//! A matching is a set of edges that share no endpoints.
//! In a bipartite graph the vertices split into two sides and every edge crosses the split. [`bipartite_matching`] grows a matching from empty with augmenting paths: an augmenting path starts at an unmatched vertex, alternates unmatched and matched edges, and ends at another unmatched vertex.
//! Flipping the path along its edges raises the matching size by one, and a matching with no augmenting path left is maximum.

use crate::algo::is_bipartite;
use crate::graph::Graph;

/// One augmentation of the matching.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MatchingStep {
    /// The augmenting path: alternating vertices, its ends unmatched before the step.
    pub path: Vec<usize>,
    /// The size of the matching after the step.
    pub size: usize,
}

/// A maximum matching in a bipartite graph.
#[derive(Debug, Clone)]
pub struct BipartiteMatching {
    /// The matched pairs `(left, right)`, sorted by the left vertex.
    pub pairs: Vec<(usize, usize)>,
    /// The number of matched pairs.
    pub size: usize,
    /// The 2-coloring: 0 and 1 are the two sides.
    pub color: Vec<usize>,
    /// The augmentations in the order they were found.
    pub steps: Vec<MatchingStep>,
}

/// Maximum matching of an undirected bipartite graph.
///
/// The two sides come from a BFS 2-coloring of the graph.
/// Every vertex of side 0 is tried as a root, and an augmenting path is searched with a DFS that alternates unmatched and matched edges.
/// A right vertex that is already matched is not taken directly: the search continues from its partner, so an earlier pair can be rearranged.
/// Runs in $O(V E)$.
/// Returns `None` when the graph is not bipartite, that is, when it contains an odd cycle.
///
/// ```
/// use graphs::{bipartite_matching, Graph};
///
/// // Sides: 0, 1 and 2, 3.
/// let mut g = Graph::undirected();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_edges(&[(0, 2), (0, 3), (1, 2)]);
///
/// let res = bipartite_matching(&g).unwrap();
/// assert_eq!(res.size, 2);
/// assert_eq!(res.pairs, vec![(0, 3), (1, 2)]);
/// ```
pub fn bipartite_matching(g: &Graph) -> Option<BipartiteMatching> {
    assert!(
        !g.is_directed(),
        "bipartite_matching requires an undirected graph"
    );
    let color = is_bipartite(g)?;
    let n = g.node_count();

    // `matched[v]` is the left partner of the right vertex `v`.
    let mut matched: Vec<Option<usize>> = vec![None; n];
    // Search state for one attempt: a right vertex is tried at most once per root.
    let mut seen = vec![false; n];
    // How the search reached a right vertex, and through which right vertex a left one.
    let mut via = vec![usize::MAX; n];
    let mut entered = vec![usize::MAX; n];

    let mut size = 0;
    let mut steps = Vec::new();
    for root in 0..n {
        if color[root] != 0 {
            continue;
        }
        seen.fill(false);
        via.fill(usize::MAX);
        entered.fill(usize::MAX);
        if let Some(free) = augment(
            root,
            g,
            &color,
            &mut matched,
            &mut seen,
            &mut via,
            &mut entered,
        ) {
            // The path runs from the free right vertex back to the root.
            let mut path = vec![free];
            let mut right = free;
            loop {
                let left = via[right];
                path.push(left);
                if entered[left] == usize::MAX {
                    break;
                }
                right = entered[left];
                path.push(right);
            }
            path.reverse();
            size += 1;
            steps.push(MatchingStep { path, size });
        }
    }

    let mut pairs = Vec::with_capacity(size);
    for (right, left) in matched.iter().enumerate() {
        if let Some(left) = *left {
            pairs.push((left, right));
        }
    }
    pairs.sort_unstable();

    Some(BipartiteMatching {
        pairs,
        size,
        color,
        steps,
    })
}

/// Depth-first search for an augmenting path from the left vertex `left`.
///
/// Returns the free right vertex that ends the path.
/// On success every right vertex along the path is matched to the left vertex before it.
/// Recursive: may overflow the call stack on very large graphs.
#[allow(clippy::too_many_arguments)] // the parameters are the search state, kept explicit
fn augment(
    left: usize,
    g: &Graph,
    color: &[usize],
    matched: &mut [Option<usize>],
    seen: &mut [bool],
    via: &mut [usize],
    entered: &mut [usize],
) -> Option<usize> {
    for &(right, _) in &g.adj[left] {
        if color[right] == color[left] || seen[right] {
            continue;
        }
        seen[right] = true;
        via[right] = left;
        match matched[right] {
            None => {
                matched[right] = Some(left);
                return Some(right);
            }
            Some(partner) => {
                entered[partner] = right;
                if let Some(free) = augment(partner, g, color, matched, seen, via, entered) {
                    matched[right] = Some(left);
                    return Some(free);
                }
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    fn complete_bipartite(side: usize) -> Graph {
        let mut g = Graph::undirected();
        for i in 0..2 * side {
            g.add_node(i.to_string());
        }
        for left in 0..side {
            for right in side..2 * side {
                g.add_edge(left, right);
            }
        }
        g
    }

    #[test]
    fn complete_bipartite_graph_has_a_perfect_matching() {
        let res = bipartite_matching(&complete_bipartite(3)).unwrap();
        assert_eq!(res.size, 3);
        assert_eq!(res.pairs.len(), 3);

        let mut lefts: Vec<usize> = res.pairs.iter().map(|&(l, _)| l).collect();
        let mut rights: Vec<usize> = res.pairs.iter().map(|&(_, r)| r).collect();
        lefts.sort_unstable();
        rights.sort_unstable();
        assert_eq!(lefts, vec![0, 1, 2]);
        assert_eq!(rights, vec![3, 4, 5]);
        assert_eq!(res.steps.len(), 3);
    }

    #[test]
    fn augmenting_path_reassigns_a_matched_right_vertex() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 2), (0, 3), (1, 2)]);

        let res = bipartite_matching(&g).unwrap();
        assert_eq!(res.size, 2);
        assert_eq!(res.pairs, vec![(0, 3), (1, 2)]);
        // The second step flips 0 - 2 - 1 into 0 - 3 and 1 - 2.
        assert_eq!(res.steps[1].path, vec![1, 2, 0, 3]);
        assert_eq!(res.steps[1].size, 2);
    }

    #[test]
    fn graph_without_edges_has_an_empty_matching() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        let res = bipartite_matching(&g).unwrap();
        assert_eq!(res.size, 0);
        assert!(res.pairs.is_empty());
        assert!(res.steps.is_empty());
    }

    #[test]
    fn odd_cycle_is_reported_as_not_bipartite() {
        let mut g = Graph::undirected();
        for name in ["a", "b", "c"] {
            g.add_node(name);
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        assert!(bipartite_matching(&g).is_none());
    }
}
