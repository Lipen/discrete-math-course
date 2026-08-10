//! Breadth-first and depth-first search on one graph.
//!
//! BFS visits the graph layer by layer and finds shortest distances from the
//! start; DFS goes deep and records entry/exit times. The graph is the same
//! one as in the chapter's BFS trace.

use graphs::{bfs, dfs, Graph};

fn main() {
    // Vertices 1..6, edges as in the BFS trace from the chapter.
    let mut g = Graph::undirected();
    for i in 1..=6 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (0, 3), (1, 2), (1, 4), (2, 5), (3, 4), (4, 5)]);

    println!("Graph: vertices 1..6, edges:");
    for e in &g.edges {
        println!("  {} -- {}", e.from + 1, e.to + 1);
    }

    println!("\n=== BFS from vertex 1 ===");
    let r = bfs(&g, 0);
    println!("Visit order: {:?}", names(&r.order));
    println!("Distances:    {:?}", r.dist);
    println!("Parents:      {:?}", parents(&r.parent));

    println!("\n=== DFS over the whole graph ===");
    let r = dfs(&g);
    println!("Visit order:  {:?}", names(&r.order));
    println!("Entry times:  {:?}", r.pre);
    println!("Exit times:   {:?}", r.post);
    println!("Finish order: {:?}", names(&r.finish));
}

fn names(ids: &[usize]) -> Vec<usize> {
    ids.iter().map(|&i| i + 1).collect()
}

fn parents(p: &[Option<usize>]) -> Vec<String> {
    p.iter()
        .map(|x| match x {
            Some(u) => (u + 1).to_string(),
            None => "--".to_string(),
        })
        .collect()
}
