//! Визуализация: один граф -- четыре формата.
//!
//! Собери пример с сохранением вывода в файлы и открой их:
//!
//! ```bash
//! cargo run -p graphs --example visualize
//! cargo run -p graphs --example visualize > /tmp/graph.txt
//! ```
//!
//! - SVG открывается любым браузером (файл `.svg`);
//! - DOT отдаётся утилите `dot -Tsvg graph.dot -o graph.svg`;
//! - JSON -- формат cytoscape.js для интерактивных графов;
//! - HTML -- готовая страница, открывается браузером.

use graphs::viz::{cytoscape, dot, html, svg};
use graphs::Graph;

fn main() {
    let g = demo_graph();

    let svg_doc = svg::render(&g, &svg::SvgOptions::default());
    println!("=== SVG ===\n{svg_doc}");

    let dot_doc = dot::render(&g);
    println!("=== DOT ===\n{dot_doc}");

    let json = cytoscape::render(&g);
    println!("=== cytoscape.js JSON ===\n{json}");

    // HTML длинный (это целая страница); покажем только начало.
    let page = html::render(&g);
    println!("=== HTML (первые 5 строк) ===");
    for line in page.lines().take(5) {
        println!("{line}");
    }
    println!(
        "  ... (всего {} строк; сохрани в .html и открой браузером)",
        page.lines().count()
    );
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
