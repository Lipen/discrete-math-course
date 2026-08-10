//! Random graphs: the Erdős--Rényi model G(n, p).
//!
//! n vertices, every edge appears independently with probability p.
//! The same seed always gives the same graph -- the examples are
//! reproducible. Along the way we check the handshake lemma: the sum of
//! degrees is even. The DOT description is written to a file, and the path
//! is printed.

use std::fs;

use graphs::viz::dot;
use graphs::{connected_components, Graph};

fn main() {
    let g = Graph::erdos_renyi(12, 0.25, 7);

    println!("G(12, 0.25), seed 7");
    println!("Vertices: {}, edges: {}", g.node_count(), g.edge_count());

    println!("\nVertex degrees:");
    let degrees = g.degrees();
    let max_deg = degrees.iter().max().copied().unwrap_or(0);
    for (u, &d) in degrees.iter().enumerate() {
        let bar = "#".repeat(d);
        println!("  {u:>2}: {d}  {bar}");
    }
    println!("  (max: {max_deg})");

    let sum: usize = degrees.iter().sum();
    println!(
        "\nSum of degrees: {sum} (even = {} -- the handshake lemma)",
        sum.is_multiple_of(2)
    );

    let (count, _) = connected_components(&g);
    println!("Connected components: {count}");

    let dir = std::env::temp_dir().join("graphs-visualize");
    fs::create_dir_all(&dir).expect("failed to create the output folder");
    let dot_path = dir.join("random-graph.dot");
    fs::write(&dot_path, dot::render(&g)).expect("failed to write DOT");
    println!("\nDOT: {}", dot_path.display());
    println!(
        "  picture: neato -Tsvg {} -o random-graph.svg",
        dot_path.display()
    );
}
