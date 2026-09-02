//! Directed graphs: topological sort, cycles, strong connectivity.
//!
//! A topological order is a schedule: all "ancestors" first, then "descendants".
//! Strongly connected components are regions where any vertex can reach any other (Kosaraju's algorithm).

use graphs::{is_cyclic, strongly_connected_components, topological_sort, Graph};

fn main() {
    println!("=== Topological sort (dependencies) ===");
    let mut g = Graph::directed();
    for name in ["foundation", "walls", "roof", "windows"] {
        g.add_node(name);
    }
    // Edges: first build X, then Y.
    g.add_edges(&[(0, 1), (0, 2), (1, 3), (2, 3)]);

    match topological_sort(&g) {
        Some(order) => {
            println!("Construction order:");
            for (i, u) in order.iter().enumerate() {
                println!("  {}. {}", i + 1, g.node_name(*u));
            }
        }
        None => println!("A cycle: impossible to build!"),
    }

    println!("\n=== Cycles ===");
    println!("The dependency graph has a cycle: {}", is_cyclic(&g));
    g.add_edge(3, 0); // roof -> foundation: a cycle!
    println!("After adding \"roof -> foundation\": {}", is_cyclic(&g));
    match topological_sort(&g) {
        Some(_) => println!("  (the sort unexpectedly succeeded)"),
        None => println!("  there is no topological order anymore."),
    }

    println!("\n=== Strongly connected components (Kosaraju) ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C", "D", "E"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0), (1, 3), (3, 4)]);
    // A -> B -> C -> A form one component. D and E are singletons.

    for (i, comp) in strongly_connected_components(&g).iter().enumerate() {
        let names: Vec<&str> = comp.iter().map(|&u| g.node_name(u)).collect();
        println!("  component {}: {:?}", i + 1, names);
    }
}
