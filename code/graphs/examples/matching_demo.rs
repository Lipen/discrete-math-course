//! Maximum bipartite matching with augmenting paths.
//!
//! Three workers W1..W3 and three tasks T1..T3 are the two sides of a bipartite graph.
//! An edge means the worker can do the task.
//! The algorithm tries every worker in turn and flips an alternating path when it finds one,
//! so an earlier assignment can be rearranged to free a task for the newcomer.

use graphs::{bipartite_matching, Graph};

fn main() {
    let mut g = Graph::undirected();
    for name in ["W1", "W2", "W3", "T1", "T2", "T3"] {
        g.add_node(name);
    }
    g.add_edges(&[
        (0, 3), // W1 - T1
        (0, 4), // W1 - T2
        (1, 3), // W2 - T1
        (2, 4), // W3 - T2
        (2, 5), // W3 - T3
    ]);

    println!("Workers and tasks (edges mark who can do what):");
    for e in &g.edges {
        println!("  {} -- {}", g.node_name(e.from), g.node_name(e.to));
    }

    let res = bipartite_matching(&g).expect("the graph is bipartite");

    for side in 0..2 {
        let names: Vec<&str> = res
            .color
            .iter()
            .enumerate()
            .filter(|(_, c)| **c == side)
            .map(|(v, _)| g.node_name(v))
            .collect();
        println!("\nSide {side}: {}", names.join(", "));
    }

    println!("\nAugmenting steps (alternating paths, with the size after the step):");
    for (i, step) in res.steps.iter().enumerate() {
        let names: Vec<&str> = step.path.iter().map(|&v| g.node_name(v)).collect();
        println!("  {}. {}  size {}", i + 1, names.join(" - "), step.size);
    }

    println!("\nMaximum matching ({} pair(s)):", res.size);
    for &(worker, task) in &res.pairs {
        println!("  {} -> {}", g.node_name(worker), g.node_name(task));
    }

    // An odd cycle has no two-color split, so no bipartite matching is defined for it.
    let mut triangle = Graph::undirected();
    for name in ["A", "B", "C"] {
        triangle.add_node(name);
    }
    triangle.add_edges(&[(0, 1), (1, 2), (2, 0)]);

    println!("\nNon-bipartite input (triangle A-B-C):");
    match bipartite_matching(&triangle) {
        Some(_) => println!("  matched (unexpectedly!)"),
        None => println!("  rejected: an odd cycle cannot be split into two sides"),
    }
}
