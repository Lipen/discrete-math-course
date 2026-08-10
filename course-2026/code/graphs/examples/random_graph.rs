//! Случайные графы: модель Эрдёша--Реньи G(n, p).
//!
//! n вершин, каждое ребро появляется независимо с вероятностью p.
//! Один и тот же seed даёт один и тот же граф -- примеры воспроизводимы.
//! Заодно проверяем лемму о рукопожатиях: сумма степеней чётна.
//! DOT-описание пишется в файл, путь печатается в терминале.

use std::fs;

use graphs::viz::dot;
use graphs::{connected_components, Graph};

fn main() {
    let g = Graph::erdos_renyi(12, 0.25, 7);

    println!("G(12, 0.25), seed 7");
    println!("Вершин: {}, рёбер: {}", g.node_count(), g.edge_count());

    println!("\nСтепени вершин:");
    let degrees = g.degrees();
    let max_deg = degrees.iter().max().copied().unwrap_or(0);
    for (u, &d) in degrees.iter().enumerate() {
        let bar = "#".repeat(d);
        println!("  {u:>2}: {d}  {bar}");
    }
    println!("  (максимум: {max_deg})");

    let sum: usize = degrees.iter().sum();
    println!(
        "\nСумма степеней: {sum} (чётное = {} -- лемма о рукопожатиях)",
        sum.is_multiple_of(2)
    );

    let (count, _) = connected_components(&g);
    println!("Компонент связности: {count}");

    let dir = std::env::temp_dir().join("graphs-visualize");
    fs::create_dir_all(&dir).expect("не удалось создать выходную папку");
    let dot_path = dir.join("random-graph.dot");
    fs::write(&dot_path, dot::render(&g)).expect("не удалось записать DOT");
    println!("\nDOT: {}", dot_path.display());
    println!(
        "  картинка: neato -Tsvg {} -o random-graph.svg",
        dot_path.display()
    );
}
