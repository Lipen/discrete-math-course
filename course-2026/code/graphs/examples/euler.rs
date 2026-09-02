//! Eulerian paths and circuits.
//!
//! Euler's criterion: in an undirected graph either all degrees are even (there is an Eulerian circuit), or exactly two are odd (there is an Eulerian path between them).
//! The trail itself is built by Hierholzer's algorithm.

use graphs::{find_eulerian_path, Graph};

fn main() {
    println!("=== Square: all degrees even -- an Eulerian circuit ===");
    let g = square();
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  no trail"),
    }

    println!("\n=== Path 0-1-2-3: two odd degrees -- an Eulerian path ===");
    let mut g = Graph::undirected();
    for i in 0..4 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  no trail"),
    }

    println!("\n=== Star: four odd degrees -- no trail ===");
    let mut g = Graph::undirected();
    for i in 0..4 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (0, 2), (0, 3)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  no trail (Euler's criterion fails)"),
    }

    println!("\n=== Directed circuit A -> B -> C -> A ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  no trail"),
    }
}

fn square() -> Graph {
    let mut g = Graph::undirected();
    for i in 0..4 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 3), (3, 0)]);
    g
}

fn trail_str(g: &Graph, trail: &[usize]) -> String {
    trail
        .iter()
        .map(|&u| g.node_name(u).to_string())
        .collect::<Vec<_>>()
        .join(" -> ")
}
