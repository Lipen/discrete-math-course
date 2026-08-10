//! Рендер графа в JSON для cytoscape.js.
//!
//! [cytoscape.js](https://js.cytoscape.org) --- библиотека интерактивных
//! графов для браузера. Ей нужен простой JSON; результат этой функции
//! кладётся в опцию `elements`:
//!
//! ```js
//! const cy = cytoscape({ elements: <вывод этой функции> });
//! ```
//!
//! JSON собирает serde: структуры `NodeData`/`EdgeData` описывают схему,
//! а `serde_json` берёт на себя экранирование строк --- имена вершин могут
//! содержать кавычки, слеши и переводы строк, и JSON останется валидным.

use crate::graph::Graph;
use serde::Serialize;

/// Одна вершина в формате cytoscape.js.
#[derive(Serialize)]
struct NodeData {
    /// Номер вершины как строка: на него ссылаются рёбра.
    id: String,
    /// Имя для подписи.
    label: String,
}

/// Одно ребро в формате cytoscape.js.
#[derive(Serialize)]
struct EdgeData {
    id: String,
    /// Вершина, из которой ребро выходит (номер как строка).
    source: String,
    /// Вершина, в которую ребро входит.
    target: String,
    /// Вес, если он не единичный (единичный вес не подписываем).
    #[serde(skip_serializing_if = "Option::is_none")]
    label: Option<String>,
}

/// Корневой объект `{ nodes: [...], edges: [...] }`.
#[derive(Serialize)]
struct Elements {
    nodes: Vec<NodeData>,
    edges: Vec<EdgeData>,
}

/// Граф в JSON-формате cytoscape.js (pretty-printed).
pub fn render(g: &Graph) -> String {
    let elements = Elements {
        nodes: (0..g.node_count())
            .map(|u| NodeData {
                id: u.to_string(),
                label: g.node_name(u).to_string(),
            })
            .collect(),
        edges: g
            .edges
            .iter()
            .enumerate()
            .map(|(e, edge)| EdgeData {
                id: format!("e{e}"),
                source: edge.from.to_string(),
                target: edge.to.to_string(),
                label: (edge.weight != 1).then(|| edge.weight.to_string()),
            })
            .collect(),
    };
    serde_json::to_string_pretty(&elements).expect("простая схема не может не сериализоваться")
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
        assert!(json.contains("\"id\": \"0\","));
        assert!(json.contains("\"label\": \"a\""));
        assert!(json.contains("\"source\": \"0\""));
        assert!(json.contains("\"target\": \"1\""));
        assert!(json.contains("\"label\": \"3\""));
    }

    #[test]
    fn unit_weight_edges_have_no_label() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        let json = render(&g);
        let parsed: serde_json::Value = serde_json::from_str(&json).expect("JSON валиден");
        // У вершин label есть всегда, у ребра с единичным весом --- нет.
        assert_eq!(parsed["nodes"][0]["label"], "a");
        assert!(parsed["edges"][0].get("label").is_none());
    }

    #[test]
    fn hostile_names_stay_valid_json() {
        // Кавычки и слеши в имени не должны ломать JSON.
        let mut g = Graph::undirected();
        g.add_node("say \"hi\" \\ here");
        let json = render(&g);
        let parsed: serde_json::Value = serde_json::from_str(&json).expect("JSON валиден");
        assert_eq!(parsed["nodes"][0]["label"], "say \"hi\" \\ here");
    }
}
