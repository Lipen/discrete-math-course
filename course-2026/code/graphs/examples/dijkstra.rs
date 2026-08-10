//! Shortest paths: Dijkstra and Bellman--Ford.
//!
//! Dijkstra works only with non-negative weights, but is fast; Bellman--Ford
//! survives negative weights, but not negative cycles. The demo shows how to
//! reconstruct the path itself from the predecessors.

use graphs::{bellman_ford, dijkstra, Graph};

fn main() {
    println!("=== Dijkstra: shortest paths from A ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C", "D"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 4); // A -> B
    g.add_weighted_edge(0, 2, 1); // A -> C
    g.add_weighted_edge(2, 1, 2); // C -> B (shorter than the direct edge!)
    g.add_weighted_edge(1, 3, 1); // B -> D
    g.add_weighted_edge(2, 3, 5); // C -> D

    let (dist, prev) = dijkstra(&g, 0);
    for (v, d) in dist.iter().enumerate() {
        println!(
            "  A -> {}: {:>2}  path: {}",
            g.node_name(v),
            fmt(*d),
            path_to(&g, &prev, v)
        );
    }

    println!("\n=== Bellman--Ford with a negative edge ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 4);
    g.add_weighted_edge(1, 2, -3); // a negative weight!
    g.add_weighted_edge(0, 2, 2);

    match bellman_ford(&g, 0) {
        Some((dist, prev)) => {
            for (v, d) in dist.iter().enumerate() {
                println!(
                    "  A -> {}: {:>3}  path: {}",
                    g.node_name(v),
                    fmt(*d),
                    path_to(&g, &prev, v)
                );
            }
        }
        None => println!("  negative cycle!"),
    }

    println!("\n=== Bellman--Ford detects a negative cycle ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 1);
    g.add_weighted_edge(1, 2, -5);
    g.add_weighted_edge(2, 1, 1); // cycle B -> C -> B of weight -4
    match bellman_ford(&g, 0) {
        Some(_) => println!("  paths found (unexpectedly!)"),
        None => println!("  negative cycle: B -> C -> B of weight -4"),
    }
}

fn fmt(d: Option<i64>) -> String {
    match d {
        Some(x) => x.to_string(),
        None => "unreachable".to_string(),
    }
}

/// Reconstruct the path to `v` from the predecessors (reversed order).
fn path_to(g: &Graph, prev: &[Option<usize>], mut v: usize) -> String {
    let mut rev = vec![g.node_name(v).to_string()];
    while let Some(p) = prev[v] {
        rev.push(g.node_name(p).to_string());
        v = p;
    }
    rev.reverse();
    rev.join(" -> ")
}
