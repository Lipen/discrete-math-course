//! Ориентированные графы: топологическая сортировка, циклы, сильная связность.
//!
//! Топологический порядок -- расписание: сначала все «предки», потом
//! «потомки». Компоненты сильной связности -- области, где из любой
//! вершины можно добраться в любую другую (алгоритм Косарайю).

use graphs::{is_cyclic, strongly_connected_components, topological_sort, Graph};

fn main() {
    println!("=== Топологическая сортировка (зависимости) ===");
    let mut g = Graph::directed();
    for name in ["фундамент", "стены", "крыша", "окна"] {
        g.add_node(name);
    }
    // Рёбра: сначала строят X, потом Y.
    g.add_edges(&[(0, 1), (0, 2), (1, 3), (2, 3)]);

    match topological_sort(&g) {
        Some(order) => {
            println!("Порядок строительства:");
            for (i, u) in order.iter().enumerate() {
                println!("  {}. {}", i + 1, g.node_name(*u));
            }
        }
        None => println!("Цикл: строить невозможно!"),
    }

    println!("\n=== Циклы ===");
    println!("В графе зависимостей цикл: {}", is_cyclic(&g));
    g.add_edge(3, 0); // крыша -> фундамент: цикл!
    println!(
        "После добавления ребра \"крыша -> фундамент\": {}",
        is_cyclic(&g)
    );
    match topological_sort(&g) {
        Some(_) => println!("  (сортировка неожиданно удалась)"),
        None => println!("  топологической сортировки больше нет."),
    }

    println!("\n=== Компоненты сильной связности (Косарайю) ===");
    let mut g = Graph::directed();
    for name in ["A", "B", "C", "D", "E"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0), (1, 3), (3, 4)]);
    // A -> B -> C -> A образуют одну компоненту; D и E -- по одной.

    for (i, comp) in strongly_connected_components(&g).iter().enumerate() {
        let names: Vec<&str> = comp.iter().map(|&u| g.node_name(u)).collect();
        println!("  компонента {}: {:?}", i + 1, names);
    }
}
