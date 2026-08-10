//! Структура графа: компоненты, мосты, точки сочленения, двудольность.
//!
//! Один пример -- несколько «паспортов» графа: на какие части он
//! распадается, какие рёбра и вершины критичны (их удаление рвёт граф),
//! можно ли раскрасить его в два цвета.

use graphs::{articulation_points, bridges, connected_components, diameter, is_bipartite, Graph};

fn main() {
    // Треугольник A-B-C плюс хвост C-D-E.
    let mut g = Graph::undirected();
    for name in ["A", "B", "C", "D", "E"] {
        g.add_node(name);
    }
    g.add_edges(&[(0, 1), (1, 2), (2, 0), (2, 3), (3, 4)]);

    println!("Граф: треугольник A-B-C с хвостом C-D-E.");
    println!("  рёбра: A-B, B-C, C-A, C-D, D-E");

    let (count, comp) = connected_components(&g);
    println!("\nКомпонент связности: {count}");
    for (u, &c) in comp.iter().enumerate() {
        println!("  {} -> компонента {c}", g.node_name(u));
    }

    println!("\nМосты (удаление рвёт граф):");
    for (u, v) in bridges(&g) {
        println!("  {} -- {}", g.node_name(u), g.node_name(v));
    }

    println!("\nТочки сочленения (удаление рвёт граф):");
    for u in articulation_points(&g) {
        println!("  {}", g.node_name(u));
    }

    match is_bipartite(&g) {
        Some(colors) => {
            println!("\nГраф двудольный, цвета:");
            for (u, &c) in colors.iter().enumerate() {
                println!("  {} -> цвет {c}", g.node_name(u));
            }
        }
        None => println!("\nГраф НЕ двудольный: в треугольнике есть нечётный цикл."),
    }

    println!("\nДиаметр графа: {:?}", diameter(&g));
}
