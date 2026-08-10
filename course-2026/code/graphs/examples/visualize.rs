//! Visualization: one graph -- two files.
//!
//! The layout is not drawn by hand but by ready-made tools, so the example
//! emits two text formats, writes them into the `graphs-visualize/` temp
//! folder and prints the paths:
//!
//! ```text
//! DOT:  /tmp/graphs-visualize/graph.dot     <- dot -Tsvg graph.dot -o graph.svg
//! JSON: /tmp/graphs-visualize/graph.json    <- for cytoscape.js
//! ```
//!
//! DOT is understood by any Graphviz engine (`dot`, `neato`, `fdp`, `circo`
//! -- each has its own layout style), JSON by cytoscape.js, which lays the
//! graph out and makes it interactive.
//! The example writes nothing into the current folder: the repository stays
//! clean.

use std::fs;
use std::path::PathBuf;

use graphs::viz::{cytoscape, dot};
use graphs::Graph;

fn main() {
    let g = demo_graph();
    let out = out_dir();

    println!("Graph: \"road map\" between cities");
    for e in &g.edges {
        println!(
            "  {} -- {}  weight {}",
            g.node_name(e.from),
            g.node_name(e.to),
            e.weight
        );
    }

    let dot_path = out.join("graph.dot");
    fs::write(&dot_path, dot::render(&g)).expect("failed to write DOT");
    println!("\nDOT:   {}", dot_path.display());
    println!(
        "  picture with any Graphviz engine: neato -Tsvg {} -o graph.svg",
        dot_path.display()
    );

    let json_path = out.join("graph.json");
    fs::write(&json_path, cytoscape::render(&g)).expect("failed to write JSON");
    println!("JSON:  {}", json_path.display());
    println!("  cytoscape.js format: put it into the elements option");
}

/// Output folder: the system temp directory plus an example-named subfolder.
fn out_dir() -> PathBuf {
    let dir = std::env::temp_dir().join("graphs-visualize");
    fs::create_dir_all(&dir).expect("failed to create the output folder");
    dir
}

/// A small weighted graph: a "road map" between cities.
fn demo_graph() -> Graph {
    let mut g = Graph::undirected();
    for name in ["Moscow", "Piter", "Kazan", "Novgorod"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 700); // Moscow -- Piter
    g.add_weighted_edge(0, 2, 800); // Moscow -- Kazan
    g.add_weighted_edge(1, 3, 180); // Piter -- Novgorod
    g.add_weighted_edge(2, 3, 750); // Kazan -- Novgorod
    g
}
