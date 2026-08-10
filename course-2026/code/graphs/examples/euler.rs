//! Эйлеровы пути и циклы.
//!
//! Критерий Эйлера: у неориентированного графа либо все степени чётны
//! (есть эйлеров цикл), либо ровно две нечётные (есть эйлеров путь между
//! ними). Сам маршрут строится алгоритмом Иерархольцера.

use graphs::{find_eulerian_path, Graph};

fn main() {
    println!("=== Квадрат: все степени чётны -- эйлеров цикл ===");
    let g = square();
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  пути нет"),
    }

    println!("\n=== Путь 0-1-2-3: две нечётные степени -- эйлеров путь ===");
    let mut g = Graph::undirected();
    for i in 0..4 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  пути нет"),
    }

    println!("\n=== Звезда: четыре нечётные степени -- пути нет ===");
    let mut g = Graph::undirected();
    for i in 0..4 {
        g.add_node(i.to_string());
    }
    g.add_edges(&[(0, 1), (0, 2), (0, 3)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  пути нет (критерий Эйлера не выполнен)"),
    }

    println!("\n=== Ориентированный цикл A -> B -> C -> A ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
    match find_eulerian_path(&g) {
        Some(trail) => println!("  {}", trail_str(&g, &trail)),
        None => println!("  пути нет"),
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
