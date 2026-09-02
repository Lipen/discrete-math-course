//! Minimum spanning tree: Kruskal's algorithm.
//!
//! A spanning tree connects all vertices with the minimum total edge weight.
//! Kruskal sorts edges by weight and takes every edge that does not close a cycle (checked with a union-find structure).

use graphs::{min_spanning_tree, Graph};

fn main() {
    let mut g = Graph::undirected();
    for name in ["A", "B", "C", "D"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 1); // A-B
    g.add_weighted_edge(1, 2, 2); // B-C
    g.add_weighted_edge(2, 3, 3); // C-D
    g.add_weighted_edge(3, 0, 10); // D-A (expensive)
    g.add_weighted_edge(0, 2, 100); // A-C (very expensive)

    println!("Graph (weight on each edge):");
    for e in &g.edges {
        println!(
            "  {} -- {}  weight {}",
            g.node_name(e.from),
            g.node_name(e.to),
            e.weight
        );
    }

    let tree = min_spanning_tree(&g);
    let total: i64 = tree.iter().map(|&e| g.edge_weight(e)).sum();

    println!("\nMinimum spanning tree ({} edge(s)):", tree.len());
    for &e in &tree {
        let edge = &g.edges[e];
        println!(
            "  {} -- {}  weight {}",
            g.node_name(edge.from),
            g.node_name(edge.to),
            edge.weight
        );
    }
    println!("Total weight: {total}");
}
