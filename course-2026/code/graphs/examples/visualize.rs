//! Визуализация: один граф -- четыре файла.
//!
//! Пример рендерит граф во все доступные форматы, пишет файлы во
//! временную папку `graphs-visualize/` и печатает их пути:
//!
//! ```text
//! SVG:   /tmp/graphs-visualize/graph.svg      <- открой браузером
//! DOT:   /tmp/graphs-visualize/graph.dot      <- dot -Tsvg graph.dot -o graph.svg
//! JSON:  /tmp/graphs-visualize/graph.json     <- для cytoscape.js
//! HTML:  /tmp/graphs-visualize/graph.html     <- открой браузером
//! ```
//!
//! Ничего в текущую папку пример не пишет: репозиторий остаётся чистым,
//! а файлы легко найти (пути печатаются в терминале).

use std::fs;
use std::path::PathBuf;

use graphs::viz::{cytoscape, dot, html, svg};
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

    let svg_path = out.join("graph.svg");
    fs::write(&svg_path, svg::render(&g, &svg::SvgOptions::default()))
        .expect("не удалось записать SVG");
    println!("\nSVG:   {}", svg_path.display());

    let dot_path = out.join("graph.dot");
    fs::write(&dot_path, dot::render(&g)).expect("не удалось записать DOT");
    println!("DOT:   {}", dot_path.display());
    println!(
        "  конвертация в картинку: dot -Tsvg {} -o {}.svg",
        dot_path.display(),
        dot_path.display()
    );

    let json_path = out.join("graph.json");
    fs::write(&json_path, cytoscape::render(&g)).expect("не удалось записать JSON");
    println!("JSON:  {}", json_path.display());
    println!("  это формат cytoscape.js: подставь в опцию elements");

    let html_path = out.join("graph.html");
    fs::write(&html_path, html::render(&g)).expect("не удалось записать HTML");
    println!("HTML:  {}", html_path.display());
    println!("  открой в браузере: xdg-open {}", html_path.display());
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
