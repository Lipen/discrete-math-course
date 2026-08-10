//! Render a graph as JSON for cytoscape.js.
//!
//! [cytoscape.js](https://js.cytoscape.org) is a browser library for
//! interactive graphs. It wants a simple JSON; the output of this function
//! goes into the `elements` option:
//!
//! ```js
//! const cy = cytoscape({ elements: <output of this function> });
//! ```
//!
//! The JSON is assembled by serde: the `NodeData`/`EdgeData` structs describe
//! the schema, and `serde_json` handles string escaping -- vertex names may
//! contain quotes, slashes, and newlines, and the JSON stays valid.

use crate::graph::Graph;
use serde::Serialize;

/// One vertex in cytoscape.js format.
#[derive(Serialize)]
struct NodeData {
    /// The vertex id as a string: edges refer to it.
    id: String,
    /// The name shown as the label.
    label: String,
}

/// One edge in cytoscape.js format.
#[derive(Serialize)]
struct EdgeData {
    id: String,
    /// The vertex the edge leaves (id as a string).
    source: String,
    /// The vertex the edge enters.
    target: String,
    /// The weight, unless it is 1 (unit weights are not labelled).
    #[serde(skip_serializing_if = "Option::is_none")]
    label: Option<String>,
}

/// The root object `{ nodes: [...], edges: [...] }`.
#[derive(Serialize)]
struct Elements {
    nodes: Vec<NodeData>,
    edges: Vec<EdgeData>,
}

/// The graph in cytoscape.js JSON format (pretty-printed).
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
    serde_json::to_string_pretty(&elements).expect("a simple schema cannot fail to serialize")
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
        let parsed: serde_json::Value = serde_json::from_str(&json).expect("JSON is valid");
        // Vertices always have a label; unit-weight edges do not.
        assert_eq!(parsed["nodes"][0]["label"], "a");
        assert!(parsed["edges"][0].get("label").is_none());
    }

    #[test]
    fn hostile_names_stay_valid_json() {
        // Quotes and slashes in a name must not break the JSON.
        let mut g = Graph::undirected();
        g.add_node("say \"hi\" \\ here");
        let json = render(&g);
        let parsed: serde_json::Value = serde_json::from_str(&json).expect("JSON is valid");
        assert_eq!(parsed["nodes"][0]["label"], "say \"hi\" \\ here");
    }
}
