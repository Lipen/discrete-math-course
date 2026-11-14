//! Maximum flow and minimum cut.
//!
//! A flow network is a directed graph with a non-negative capacity on every edge, a designated source, and a designated sink.
//! A flow sends an amount along every edge: no edge carries more than its capacity, and every vertex except the source and the sink keeps as much as it receives.
//! The value of a flow is the net amount that leaves the source.
//!
//! The maximum flow equals the minimum cut: the cheapest set of edges whose removal disconnects the sink from the source has the same total capacity as the best flow. [`max_flow`] computes both in one run and returns the source side of a minimum cut.

use std::collections::VecDeque;

use crate::graph::Graph;

/// One augmentation of the flow: the path and the amount pushed along it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Augmentation {
    /// Vertex ids of the path, source first and sink last.
    pub path: Vec<usize>,
    /// Amount pushed along the path: the smallest residual capacity on it.
    pub amount: i64,
}

/// Result of [`max_flow`].
#[derive(Debug, Clone)]
pub struct MaxFlow {
    /// Value of the maximum flow: the net amount that leaves the source.
    pub value: i64,
    /// Flow on every edge of the input graph, in the order of `g.edges`.
    pub edge_flow: Vec<i64>,
    /// Vertices reachable from the source in the final residual network.
    ///
    /// These vertices form the source side of a minimum cut.
    pub reachable: Vec<bool>,
    /// Edges of a minimum cut as `(from, to)` pairs.
    ///
    /// The capacities of these edges sum to [`value`](MaxFlow::value).
    pub cut: Vec<(usize, usize)>,
    /// The augmentations in the order they were found.
    pub augmentations: Vec<Augmentation>,
}

/// Maximum flow from `source` to `sink`, with the minimum cut that proves it.
///
/// Edmonds--Karp: every round finds a shortest augmenting path by BFS in the residual network and pushes the smallest residual capacity along it.
/// The residual network keeps a backward arc for every edge, so a later round can cancel flow already sent.
/// Runs in $O(V E^2)$.
/// The capacities are the edge weights and must be non-negative.
/// The graph must be directed, and `source` and `sink` must differ.
///
/// ```
/// use graphs::{max_flow, Graph};
///
/// // s = 0, t = 3
/// let mut g = Graph::directed();
/// for i in 0..4 { g.add_node(i.to_string()); }
/// g.add_weighted_edge(0, 1, 3);
/// g.add_weighted_edge(0, 2, 2);
/// g.add_weighted_edge(1, 2, 1);
/// g.add_weighted_edge(1, 3, 2);
/// g.add_weighted_edge(2, 3, 3);
///
/// let res = max_flow(&g, 0, 3);
/// assert_eq!(res.value, 5);
/// assert_eq!(res.edge_flow, vec![3, 2, 1, 2, 3]);
/// // Only the source is reachable, so the cut is {0 -> 1, 0 -> 2}.
/// assert_eq!(res.reachable, vec![true, false, false, false]);
/// assert_eq!(res.cut, vec![(0, 1), (0, 2)]);
/// ```
pub fn max_flow(g: &Graph, source: usize, sink: usize) -> MaxFlow {
    assert!(g.is_directed(), "max_flow requires a directed graph");
    let n = g.node_count();
    assert!(
        source < n && sink < n,
        "source and sink must be vertex ids below node_count()"
    );
    assert_ne!(source, sink, "source and sink must differ");

    let m = g.edge_count();
    // Arc 2e is the forward arc of edge e, arc 2e + 1 is its backward arc.
    let mut residual = Vec::with_capacity(2 * m);
    let mut arcs: Vec<Vec<usize>> = vec![Vec::new(); n];
    for (e, edge) in g.edges.iter().enumerate() {
        assert!(edge.weight >= 0, "max_flow needs non-negative capacities");
        residual.push(edge.weight);
        residual.push(0);
        arcs[edge.from].push(2 * e);
        arcs[edge.to].push(2 * e + 1);
    }
    let head = |arc: usize| {
        let edge = &g.edges[arc / 2];
        if arc.is_multiple_of(2) {
            edge.to
        } else {
            edge.from
        }
    };

    let mut value = 0;
    let mut augmentations = Vec::new();
    let mut prev_node = vec![usize::MAX; n];
    let mut prev_arc = vec![usize::MAX; n];

    loop {
        prev_node.fill(usize::MAX);
        prev_arc.fill(usize::MAX);
        prev_node[source] = source;

        let mut queue = VecDeque::new();
        queue.push_back(source);
        while let Some(u) = queue.pop_front() {
            if u == sink {
                break;
            }
            for &arc in &arcs[u] {
                let v = head(arc);
                if residual[arc] > 0 && prev_node[v] == usize::MAX {
                    prev_node[v] = u;
                    prev_arc[v] = arc;
                    queue.push_back(v);
                }
            }
        }

        if prev_node[sink] == usize::MAX {
            break;
        }

        // Walk back from the sink: the bottleneck and the vertex sequence.
        let mut amount = i64::MAX;
        let mut path = vec![sink];
        let mut v = sink;
        while v != source {
            amount = amount.min(residual[prev_arc[v]]);
            v = prev_node[v];
            path.push(v);
        }
        path.reverse();

        // Push the amount and keep the backward arcs in sync.
        v = sink;
        while v != source {
            let arc = prev_arc[v];
            residual[arc] -= amount;
            residual[arc ^ 1] += amount;
            v = prev_node[v];
        }

        value += amount;
        augmentations.push(Augmentation { path, amount });
    }

    let mut reachable = vec![false; n];
    reachable[source] = true;
    let mut queue = VecDeque::new();
    queue.push_back(source);
    while let Some(u) = queue.pop_front() {
        for &arc in &arcs[u] {
            let v = head(arc);
            if residual[arc] > 0 && !reachable[v] {
                reachable[v] = true;
                queue.push_back(v);
            }
        }
    }

    let edge_flow = g
        .edges
        .iter()
        .enumerate()
        .map(|(e, edge)| edge.weight - residual[2 * e])
        .collect();
    let cut = g
        .edges
        .iter()
        .filter(|edge| reachable[edge.from] && !reachable[edge.to])
        .map(|edge| (edge.from, edge.to))
        .collect();

    MaxFlow {
        value,
        edge_flow,
        reachable,
        cut,
        augmentations,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Source 0, inner vertices 1 and 2, sink 3.
    fn small_network() -> Graph {
        let mut g = Graph::directed();
        for name in ["s", "a", "b", "t"] {
            g.add_node(name);
        }
        g.add_weighted_edge(0, 1, 3);
        g.add_weighted_edge(0, 2, 2);
        g.add_weighted_edge(1, 2, 1);
        g.add_weighted_edge(1, 3, 2);
        g.add_weighted_edge(2, 3, 3);
        g
    }

    #[test]
    fn small_network_flow_value_and_per_edge_flow() {
        let res = max_flow(&small_network(), 0, 3);
        assert_eq!(res.value, 5);
        assert_eq!(res.edge_flow, vec![3, 2, 1, 2, 3]);
        let pushed: i64 = res.augmentations.iter().map(|a| a.amount).sum();
        assert_eq!(pushed, res.value);
    }

    #[test]
    fn min_cut_capacity_equals_flow_value() {
        let g = small_network();
        let res = max_flow(&g, 0, 3);

        let cut_capacity: i64 = g
            .edges
            .iter()
            .filter(|e| res.reachable[e.from] && !res.reachable[e.to])
            .map(|e| e.weight)
            .sum();
        assert_eq!(cut_capacity, res.value);
        assert_eq!(res.cut, vec![(0, 1), (0, 2)]);
        assert!(!res.reachable[3]);
    }

    #[test]
    fn flow_is_conserved_at_inner_vertices_and_equals_sink_inflow() {
        let g = small_network();
        let res = max_flow(&g, 0, 3);

        for u in [1, 2] {
            let inflow: i64 = g
                .edges
                .iter()
                .zip(&res.edge_flow)
                .filter(|(e, _)| e.to == u)
                .map(|(_, &f)| f)
                .sum();
            let outflow: i64 = g
                .edges
                .iter()
                .zip(&res.edge_flow)
                .filter(|(e, _)| e.from == u)
                .map(|(_, &f)| f)
                .sum();
            assert_eq!(inflow, outflow);
        }

        let sink_inflow: i64 = g
            .edges
            .iter()
            .zip(&res.edge_flow)
            .filter(|(e, _)| e.to == 3)
            .map(|(_, &f)| f)
            .sum();
        assert_eq!(sink_inflow, res.value);
    }

    #[test]
    fn disconnected_network_has_zero_flow() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 7);
        g.add_weighted_edge(2, 3, 7);

        let res = max_flow(&g, 0, 3);
        assert_eq!(res.value, 0);
        assert_eq!(res.edge_flow, vec![0, 0]);
        assert_eq!(res.reachable, vec![true, true, false, false]);
        assert!(res.cut.is_empty());
        assert!(res.augmentations.is_empty());
    }

    #[test]
    fn antiparallel_edges_do_not_cancel_the_forward_flow() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 2);
        g.add_weighted_edge(1, 0, 5); // the return edge is useless for this sink
        g.add_weighted_edge(1, 2, 2);

        let res = max_flow(&g, 0, 2);
        assert_eq!(res.value, 2);
        assert_eq!(res.edge_flow, vec![2, 0, 2]);
    }
}
