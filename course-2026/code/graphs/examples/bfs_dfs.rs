//! Обходы в ширину и в глубину на одном графе.
//!
//! BFS обходит граф по слоям и находит кратчайшие расстояния от старта;
//! DFS идёт вглубь и записывает времена входа/выхода. Граф --- тот же, что
//! в примере главы про BFS.

use graphs::{bfs, dfs, Graph};

fn main() {
    // Вершины 1..6, рёбра как в трассировке BFS из главы.
    let mut g = Graph::undirected();
    for i in 1..=6 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (0, 3), (1, 2), (1, 4), (2, 5), (3, 4), (4, 5)]);

    println!("Граф: вершины 1..6, рёбра:");
    for e in &g.edges {
        println!("  {} -- {}", e.from + 1, e.to + 1);
    }

    println!("\n=== BFS от вершины 1 ===");
    let r = bfs(&g, 0);
    println!("Порядок обхода:  {:?}", names(&r.order));
    println!("Расстояния:      {:?}", r.dist);
    println!("Предки:          {:?}", parents(&r.parent));

    println!("\n=== DFS по всему графу ===");
    let r = dfs(&g);
    println!("Порядок обхода:  {:?}", names(&r.order));
    println!("Время входа:     {:?}", r.pre);
    println!("Время выхода:    {:?}", r.post);
    println!("Порядок завершения (finish): {:?}", names(&r.finish));
}

fn names(ids: &[usize]) -> Vec<usize> {
    ids.iter().map(|&i| i + 1).collect()
}

fn parents(p: &[Option<usize>]) -> Vec<String> {
    p.iter()
        .map(|x| match x {
            Some(u) => (u + 1).to_string(),
            None => "—".to_string(),
        })
        .collect()
}
