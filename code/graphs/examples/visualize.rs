//! Visualization: one graph -- a picture and two editable sources.
//!
//! The layout is drawn by ready-made tools, so the example writes the graph in three files into the `graphs-visualize/` temp folder and prints their absolute paths:
//!
//! - `graph.dot` -- the Graphviz DOT source.
//! - `graph.dot.svg` -- the picture, rendered right here by the `dot` engine (`dot -O -Tsvg graph.dot`).
//!   Open it in a browser to preview.
//! - `graph.html` -- the same graph as a self-contained page: cytoscape.js reads the JSON inlined into the page and makes the graph interactive.
//!
//! The example writes nothing into the current folder: the repository stays clean.
//! If the `dot` utility is not installed, the SVG is skipped with a hint -- the DOT source is still there for any Graphviz engine.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use graphs::viz::{cytoscape, dot};
use graphs::Graph;

fn main() {
    let g = demo_graph();
    let out = out_dir();

    println!("Graph: \"road map\" between cities (weights in km)");
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
    println!("\nDOT:  {}", dot_path.display());

    match render_svg(&dot_path) {
        Ok(()) => {
            let svg_path = out.join("graph.dot.svg");
            println!("SVG:  {}   <-- open in a browser", svg_path.display());
        }
        Err(msg) => println!("SVG:  not rendered ({msg})"),
    }

    let html_path = out.join("graph.html");
    fs::write(&html_path, cytoscape::render_html(&g)).expect("failed to write HTML");
    println!("HTML: {}   <-- open in a browser", html_path.display());

    let json_path = out.join("graph.json");
    fs::write(&json_path, cytoscape::render(&g)).expect("failed to write JSON");
    println!(
        "JSON: {}   <-- same data, for your own code",
        json_path.display()
    );
}

/// Renders the picture with the `dot` engine: `dot -O -Tsvg` writes `graph.dot.svg` next to the source file.
fn render_svg(dot_path: &Path) -> Result<(), String> {
    let output = Command::new("dot")
        .arg("-O") // output file is named after the input: graph.dot.svg
        .arg("-Tsvg")
        .arg(dot_path)
        .output()
        .map_err(|e| format!("`dot` not found ({e}): install graphviz and run again"))?;
    if output.status.success() {
        Ok(())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).trim().to_string())
    }
}

/// Output folder: the system temp directory plus an example-named subfolder.
fn out_dir() -> PathBuf {
    let dir = std::env::temp_dir().join("graphs-visualize");
    fs::create_dir_all(&dir).expect("failed to create the output folder");
    dir
}

/// A small weighted graph: a "road map" between cities, distances in km.
fn demo_graph() -> Graph {
    let mut g = Graph::undirected();
    for name in [
        "Moscow", "Piter", "Novgorod", "Nizhny", "Kazan", "Samara", "Rostov",
    ] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 700); // Moscow -- Piter
    g.add_weighted_edge(0, 2, 530); // Moscow -- Novgorod
    g.add_weighted_edge(1, 2, 180); // Piter -- Novgorod
    g.add_weighted_edge(0, 3, 400); // Moscow -- Nizhny
    g.add_weighted_edge(0, 4, 800); // Moscow -- Kazan
    g.add_weighted_edge(3, 4, 400); // Nizhny -- Kazan
    g.add_weighted_edge(4, 5, 350); // Kazan -- Samara
    g.add_weighted_edge(0, 6, 1100); // Moscow -- Rostov
    g.add_weighted_edge(4, 6, 980); // Kazan -- Rostov
    g
}
