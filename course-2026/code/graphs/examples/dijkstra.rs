//! Кратчайшие пути: Дейкстра и Беллман--Форд.
//!
//! Дейкстра работает только с неотрицательными весами, зато быстро;
//! Беллман--Форд переживает отрицательные веса, но не отрицательные циклы.
//! Демонстрация показывает, как по предкам восстановить сам путь.

use graphs::{bellman_ford, dijkstra, Graph};

fn main() {
    println!("=== Дейкстра: кратчайшие пути от A ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C", "D"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 4); // A -> B
    g.add_weighted_edge(0, 2, 1); // A -> C
    g.add_weighted_edge(2, 1, 2); // C -> B (короче, чем напрямую!)
    g.add_weighted_edge(1, 3, 1); // B -> D
    g.add_weighted_edge(2, 3, 5); // C -> D

    let (dist, prev) = dijkstra(&g, 0);
    for (v, d) in dist.iter().enumerate() {
        println!(
            "  A -> {}: {:>2}  путь: {}",
            g.node_name(v),
            fmt(*d),
            path_to(&g, &prev, v)
        );
    }

    println!("\n=== Беллман--Форд с отрицательным ребром ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 4);
    g.add_weighted_edge(1, 2, -3); // отрицательный вес!
    g.add_weighted_edge(0, 2, 2);

    match bellman_ford(&g, 0) {
        Some((dist, prev)) => {
            for (v, d) in dist.iter().enumerate() {
                println!(
                    "  A -> {}: {:>3}  путь: {}",
                    g.node_name(v),
                    fmt(*d),
                    path_to(&g, &prev, v)
                );
            }
        }
        None => println!("  отрицательный цикл!"),
    }

    println!("\n=== Беллман--Форд обнаруживает отрицательный цикл ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 1);
    g.add_weighted_edge(1, 2, -5);
    g.add_weighted_edge(2, 1, 1); // цикл B -> C -> B веса -4
    match bellman_ford(&g, 0) {
        Some(_) => println!("  пути найдены (неожиданно!)"),
        None => println!("  отрицательный цикл: B -> C -> B веса -4"),
    }
}

fn fmt(d: Option<i64>) -> String {
    match d {
        Some(x) => x.to_string(),
        None => "недостижима".to_string(),
    }
}

/// Восстановить путь до `v` по массиву предков (в обратном порядке).
fn path_to(g: &Graph, prev: &[Option<usize>], mut v: usize) -> String {
    let mut rev = vec![g.node_name(v).to_string()];
    while let Some(p) = prev[v] {
        rev.push(g.node_name(p).to_string());
        v = p;
    }
    rev.reverse();
    rev.join(" -> ")
}
