//! Минимальное остовное дерево: алгоритм Краскала.
//!
//! Остовное дерево соединяет все вершины графа минимальной суммой весов.
//! Краскал сортирует рёбра по весу и берёт каждое ребро, которое не
//! замыкает цикл (проверка системой непересекающихся множеств).

use graphs::{min_spanning_tree, Graph};

fn main() {
    let mut g = Graph::undirected();
    for name in ["A", "B", "C", "D"] {
        g.add_node(name);
    }
    g.add_weighted_edge(0, 1, 1); // A-B
    g.add_weighted_edge(1, 2, 2); // B-C
    g.add_weighted_edge(2, 3, 3); // C-D
    g.add_weighted_edge(3, 0, 10); // D-A (дорогое)
    g.add_weighted_edge(0, 2, 100); // A-C (очень дорогое)

    println!("Граф (вес --- на ребре):");
    for e in &g.edges {
        println!(
            "  {} -- {}  вес {}",
            g.node_name(e.from),
            g.node_name(e.to),
            e.weight
        );
    }

    let tree = min_spanning_tree(&g);
    let total: i64 = tree.iter().map(|&e| g.edge_weight(e)).sum();

    println!("\nМинимальное остовное дерево ({} ребро(а)):", tree.len());
    for &e in &tree {
        let edge = &g.edges[e];
        println!(
            "  {} -- {}  вес {}",
            g.node_name(edge.from),
            g.node_name(edge.to),
            edge.weight
        );
    }
    println!("Суммарный вес: {total}");
}
