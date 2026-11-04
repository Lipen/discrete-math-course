//! Maximum flow and minimum cut: Edmonds--Karp on a small network.
//!
//! The network has a source S, two inner vertices A and B, and a sink T.
//! Every directed edge carries a capacity.
//! The algorithm repeatedly finds an augmenting path in the residual network,
//! prints how much it pushes along it, and finally exhibits a cut of the same total capacity.

use graphs::{max_flow, Graph};

fn main() {
    let mut g = Graph::directed();
    for name in ["S", "A", "B", "T"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 3); // S -> A
    g.add_weighted_edge(0, 2, 2); // S -> B
    g.add_weighted_edge(1, 2, 1); // A -> B
    g.add_weighted_edge(1, 3, 2); // A -> T
    g.add_weighted_edge(2, 3, 3); // B -> T
    let (source, sink) = (0, 3);

    println!("Network (capacity on each edge):");
    for e in &g.edges {
        println!(
            "  {} -> {}  cap {}",
            g.node_name(e.from),
            g.node_name(e.to),
            e.weight
        );
    }
    println!(
        "Source: {}, sink: {}",
        g.node_name(source),
        g.node_name(sink)
    );

    let res = max_flow(&g, source, sink);

    println!("\nAugmenting paths (shortest first, with the amount pushed):");
    for (i, step) in res.augmentations.iter().enumerate() {
        let names: Vec<&str> = step.path.iter().map(|&v| g.node_name(v)).collect();
        println!("  {}. {}  +{}", i + 1, names.join(" -> "), step.amount);
    }

    println!("\nFlow on each edge (flow/capacity):");
    for (e, &flow) in g.edges.iter().zip(&res.edge_flow) {
        println!(
            "  {} -> {}  {}/{}",
            g.node_name(e.from),
            g.node_name(e.to),
            flow,
            e.weight
        );
    }
    println!("Maximum flow value: {}", res.value);

    println!("\nResidual network reachable from {}:", g.node_name(source));
    let names: Vec<&str> = res
        .reachable
        .iter()
        .enumerate()
        .filter(|(_, r)| **r)
        .map(|(v, _)| g.node_name(v))
        .collect();
    println!("  {}", names.join(", "));

    println!("\nMinimum cut (edges from the reachable side to the rest):");
    let mut cut_capacity = 0;
    for &(u, v) in &res.cut {
        let capacity: i64 = g
            .edges
            .iter()
            .filter(|e| e.from == u && e.to == v)
            .map(|e| e.weight)
            .sum();
        println!(
            "  {} -> {}  cap {}",
            g.node_name(u),
            g.node_name(v),
            capacity
        );
        cut_capacity += capacity;
    }
    println!("Cut capacity: {cut_capacity}");
    println!("Max-flow min-cut equality: {}", cut_capacity == res.value);
}
