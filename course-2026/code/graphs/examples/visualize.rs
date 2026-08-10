//! Визуализация: один граф -- два формата.
//!
//! Раскладку рисуют не вручную, а готовые инструменты, поэтому пример
//! выдаёт два текстовых формата, пишет их во временную папку
//! `graphs-visualize/` и печатает пути:
//!
//! ```text
//! DOT:  /tmp/graphs-visualize/graph.dot     <- dot -Tsvg graph.dot -o graph.svg
//! JSON: /tmp/graphs-visualize/graph.json    <- для cytoscape.js
//! ```
//!
//! DOT понимает любой движок Graphviz (`dot`, `neato`, `fdp`, `circo` --
//! у каждого свой стиль раскладки), JSON -- библиотека cytoscape.js,
//! которая раскладывает и делает граф интерактивным.
//! Ничего в текущую папку пример не пишет: репозиторий остаётся чистым.

use std::fs;
use std::path::PathBuf;

use graphs::viz::{cytoscape, dot};
use graphs::Graph;

fn main() {
    let g = demo_graph();
    let out = out_dir();

    println!("Граф: \"карта дорог\" между городами");
    for e in &g.edges {
        println!(
            "  {} -- {}  вес {}",
            g.node_name(e.from),
            g.node_name(e.to),
            e.weight
        );
    }

    let dot_path = out.join("graph.dot");
    fs::write(&dot_path, dot::render(&g)).expect("не удалось записать DOT");
    println!("\nDOT:   {}", dot_path.display());
    println!(
        "  картинка любым движком Graphviz: neato -Tsvg {} -o graph.svg",
        dot_path.display()
    );

    let json_path = out.join("graph.json");
    fs::write(&json_path, cytoscape::render(&g)).expect("не удалось записать JSON");
    println!("JSON:  {}", json_path.display());
    println!("  формат cytoscape.js: подставь в опцию elements");
}

/// Выходная папка: временная директория системы + подпапка с именем примера.
fn out_dir() -> PathBuf {
    let dir = std::env::temp_dir().join("graphs-visualize");
    fs::create_dir_all(&dir).expect("не удалось создать выходную папку");
    dir
}

/// Небольшой взвешенный граф: «карта дорог» между городами.
fn demo_graph() -> Graph {
    let mut g = Graph::undirected();
    for name in ["Москва", "Питер", "Казань", "Новгород"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 700); // Москва -- Питер
    g.add_weighted_edge(0, 2, 800); // Москва -- Казань
    g.add_weighted_edge(1, 3, 180); // Питер -- Новгород
    g.add_weighted_edge(2, 3, 750); // Казань -- Новгород
    g
}
