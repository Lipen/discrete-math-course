//! Рендер графа в JSON для cytoscape.js.
//!
//! [cytoscape.js](https://js.cytoscape.org) --- библиотека интерактивных
//! графов для браузера. Ей нужен простой JSON; результат этой функции
//! кладётся в опцию `elements`:
//!
//! ```js
//! const cy = cytoscape({ elements: <вывод этой функции> });
//! ```

use crate::graph::Graph;

/// Граф в JSON-формате cytoscape.js.
///
/// Вершины --- `{ data: { id, label } }`, рёбра ---
/// `{ data: { id, source, target, label } }` (поля `source`/`target` ---
/// строки с номерами вершин, поэтому в `id` нельзя класть ничего другого).
pub fn render(g: &Graph) -> String {
    let mut out = String::from("{\n  \"nodes\": [\n");
    for u in 0..g.node_count() {
        let comma = if u + 1 < g.node_count() { "," } else { "" };
        out.push_str(&format!(
            "    {{\"data\": {{\"id\": \"{u}\", \"label\": \"{}\"}}}}{comma}\n",
            g.node_name(u)
        ));
    }
    out.push_str("  ],\n  \"edges\": [\n");
    for e in 0..g.edge_count() {
        let comma = if e + 1 < g.edge_count() { "," } else { "" };
        let edge = &g.edges[e];
        let label = if edge.weight == 1 {
            String::new()
        } else {
            format!(", \"label\": \"{}\"", edge.weight)
        };
        out.push_str(&format!(
            "    {{\"data\": {{\"id\": \"e{e}\", \"source\": \"{}\", \"target\": \"{}\"{label}}}}}{comma}\n",
            edge.from, edge.to
        ));
    }
    out.push_str("  ]\n}\n");
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn json_has_nodes_and_edges() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_weighted_edge(a, b, 3);
        let json = render(&g);
        assert!(json.contains("\"id\": \"0\", \"label\": \"a\""));
        assert!(json.contains("\"source\": \"0\", \"target\": \"1\""));
        assert!(json.contains("\"label\": \"3\""));
    }
}
