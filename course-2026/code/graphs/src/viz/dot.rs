//! Рендер графа в формат Graphviz DOT.
//!
//! DOT -- текстовое описание графа, которое утилита `dot` (из пакета
//! graphviz) превращает в картинку:
//!
//! ```bash
//! cargo run -p graphs --example visualize > graph.dot
//! dot -Tsvg graph.dot -o graph.svg
//! ```

use crate::graph::Graph;
use crate::viz::dot_id;

/// Экранировать текст внутри DOT-строки в кавычках: `\` и `"`.
fn escape_dot_label(text: &str) -> String {
    text.replace('\\', "\\\\").replace('"', "\\\"")
}

/// Описание графа в формате DOT.
///
/// Для неориентированного графа -- блок `graph` с рёбрами `--`,
/// для ориентированного -- блок `digraph` с рёбрами `->`.
pub fn render(g: &Graph) -> String {
    // Идентификаторы вершин в DOT: из имени, но уникальные. Два разных
    // имени могут дать один id ("a b" и "a_b") -- тогда вершины сольются
    // в картинке, поэтому при совпадении добавляем суффикс.
    let mut ids = Vec::with_capacity(g.node_count());
    let mut used = std::collections::HashSet::new();
    for u in 0..g.node_count() {
        let base = dot_id(g.node_name(u));
        let mut id = base.clone();
        let mut k = 0;
        while !used.insert(id.clone()) {
            k += 1;
            id = format!("{base}_{k}");
        }
        ids.push(id);
    }

    let mut out = String::new();
    let (header, edge_op) = if g.directed {
        ("digraph G {", "->")
    } else {
        ("graph G {", "--")
    };
    out.push_str(header);
    out.push('\n');

    for (u, id) in ids.iter().enumerate() {
        out.push_str(&format!(
            "    {id} [label=\"{}\"];\n",
            escape_dot_label(g.node_name(u))
        ));
    }

    for e in &g.edges {
        let label = if e.weight == 1 {
            String::new()
        } else {
            format!(" [label=\"{}\"]", e.weight)
        };
        out.push_str(&format!(
            "    {} {edge_op} {}{label};\n",
            ids[e.from], ids[e.to],
        ));
    }

    out.push_str("}\n");
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn undirected_dot_uses_double_dash() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_weighted_edge(a, b, 5);
        let dot = render(&g);
        assert!(dot.starts_with("graph G {"));
        assert!(dot.contains("a -- b [label=\"5\"];"));
    }

    #[test]
    fn directed_dot_uses_arrow() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        let dot = render(&g);
        assert!(dot.starts_with("digraph G {"));
        assert!(dot.contains("a -> b;"));
    }

    #[test]
    fn names_with_spaces_get_clean_ids() {
        let mut g = Graph::undirected();
        let a = g.add_node("node one");
        let b = g.add_node("2");
        g.add_edge(a, b);
        let dot = render(&g);
        assert!(dot.contains("node_one [label=\"node one\"];"));
        assert!(dot.contains("n2 [label=\"2\"];"));
    }

    #[test]
    fn quotes_and_backslashes_in_labels_are_escaped() {
        let mut g = Graph::undirected();
        let a = g.add_node("a\"b");
        let b = g.add_node("c\\d");
        g.add_edge(a, b);
        let dot = render(&g);
        assert!(dot.contains("[label=\"a\\\"b\"]"));
        assert!(dot.contains("[label=\"c\\\\d\"]"));
    }

    #[test]
    fn colliding_sanitized_names_get_unique_ids() {
        // "a b" и "a_b" дают один и тот же id при санитизации: второй
        // получает суффикс, и вершины не сливаются в картинке.
        let mut g = Graph::undirected();
        let a = g.add_node("a b");
        let b = g.add_node("a_b");
        g.add_edge(a, b);
        let dot = render(&g);
        assert!(dot.contains("a_b [label=\"a b\"];"));
        assert!(dot.contains("a_b_1 [label=\"a_b\"];"));
        assert!(dot.contains("a_b -- a_b_1;"));
    }
}
