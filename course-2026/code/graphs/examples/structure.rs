//! Graph structure: components, bridges, articulation points, bipartiteness.
//!
//! One example, several "passports" of the graph: what parts it falls apart
//! into, which edges and vertices are critical (removing them tears the
//! graph), and whether it can be colored with two colors.

use graphs::{articulation_points, bridges, connected_components, diameter, is_bipartite, Graph};

fn main() {
    // Triangle A-B-C plus a tail C-D-E.
    let mut g = Graph::undirected();
    for name in ["A", "B", "C", "D", "E"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0), (2, 3), (3, 4)]);

    println!("Graph: triangle A-B-C with tail C-D-E.");
    println!("  edges: A-B, B-C, C-A, C-D, D-E");

    let (count, comp) = connected_components(&g);
    println!("\nConnected components: {count}");
    for (u, &c) in comp.iter().enumerate() {
        println!("  {} -> component {c}", g.node_name(u));
    }

    println!("\nBridges (removal tears the graph):");
    for (u, v) in bridges(&g) {
        println!("  {} -- {}", g.node_name(u), g.node_name(v));
    }

    println!("\nArticulation points (removal tears the graph):");
    for u in articulation_points(&g) {
        println!("  {}", g.node_name(u));
    }

    match is_bipartite(&g) {
        Some(colors) => {
            println!("\nThe graph is bipartite, colors:");
            for (u, &c) in colors.iter().enumerate() {
                println!("  {} -> color {c}", g.node_name(u));
            }
        }
        None => println!("\nThe graph is NOT bipartite: the triangle is an odd cycle."),
    }

    println!("\nGraph diameter: {:?}", diameter(&g));
}
