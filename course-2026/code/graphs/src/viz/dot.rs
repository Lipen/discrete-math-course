//! Рендер графа в формат Graphviz DOT.
//!
//! DOT --- текстовое описание графа, которое утилита `dot` (из пакета
//! graphviz) превращает в картинку:
//!
//! ```bash
//! cargo run -p graphs --example visualize > graph.dot
//! dot -Tsvg graph.dot -o graph.svg
//! ```

use crate::graph::Graph;
use crate::viz::{dot_id, escape};

/// Описание графа в формате DOT.
///
/// Для неориентированного графа --- блок `graph` с рёбрами `--`,
/// для ориентированного --- блок `digraph` с рёбрами `->`.
pub fn render(g: &Graph) -> String {
    let mut out = String::new();
    let (header, edge_op) = if g.directed {
        ("digraph G {", "->")
    } else {
        ("graph G {", "--")
    };
    out.push_str(header);
    out.push('\n');

    for u in 0..g.node_count() {
        out.push_str(&format!(
            "    {} [label=\"{}\"];\n",
            dot_id(g.node_name(u)),
            escape(g.node_name(u))
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
            dot_id(g.node_name(e.from)),
            dot_id(g.node_name(e.to)),
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
}
