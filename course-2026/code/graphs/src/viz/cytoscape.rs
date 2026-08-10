//! Render a graph as JSON for cytoscape.js.
//!
//! [cytoscape.js](https://js.cytoscape.org) is a browser library for
//! interactive graphs. [`render`] produces the `elements` JSON:
//!
//! ```js
//! const cy = cytoscape({ elements: <output of render> });
//! ```
//!
//! [`render_html`] goes one step further and wraps the JSON into a
//! self-contained HTML page: cytoscape.js is loaded from a CDN, so the page
//! opens in a browser without a server.
//!
//! The JSON is assembled by serde: the `NodeData`/`EdgeData` structs describe
//! the schema, and `serde_json` handles string escaping -- vertex names may
//! contain quotes, slashes, and newlines, and the JSON stays valid.

use serde::Serialize;

use crate::graph::Graph;

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

/// A self-contained HTML page with the graph, interactive in a browser.
///
/// The JSON from [`render`] is inlined into the page, and cytoscape.js is
/// loaded from a CDN, so the page needs no server and no extra files:
/// double-click the file and it works (an internet connection is only
/// needed to fetch the library once).
///
/// Vertex names go through `serde_json` escaping plus one extra rule: every
/// `<` becomes `\u003c`, so a name like `</script>` cannot break out of the
/// inline script.
pub fn render_html(g: &Graph) -> String {
    // `<` can only occur inside JSON strings, and `\u003c` is valid JSON,
    // so escaping keeps the JSON valid and the page injection-proof.
    let json = render(g).replace('<', "\\u003c");
    indoc::formatdoc! {r#"
        <!doctype html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <title>graphs -- interactive demo</title>
        <script src="https://unpkg.com/cytoscape@3.30.2/dist/cytoscape.min.js"></script>
        <style>
          html, body, #cy {{ margin: 0; width: 100%; height: 100%; }}
        </style>
        </head>
        <body>
        <div id="cy"></div>
        <script>
        const elements = {json};
        cytoscape({{
          container: document.getElementById('cy'),
          elements: elements,
          style: [
            {{
              selector: 'node',
              style: {{
                'label': 'data(label)',
                'background-color': '#4a7dbb',
                'color': '#222222',
                'text-valign': 'bottom',
                'text-margin-y': 6,
                'font-size': 14,
                'width': 28,
                'height': 28
              }}
            }},
            {{
              selector: 'edge',
              style: {{
                'label': 'data(label)',
                'curve-style': 'bezier',
                'width': 1.5,
                'line-color': '#9aa7b4',
                'font-size': 11,
                'text-background-color': '#ffffff',
                'text-background-opacity': 0.8,
                'text-background-padding': 2
              }}
            }}
          ],
          layout: {{ name: 'cose', animate: false }}
        }});
        </script>
        </body>
        </html>
    "#}
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

    #[test]
    fn html_inlines_the_json() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_weighted_edge(a, b, 3);
        let html = render_html(&g);
        assert!(html.contains("<div id=\"cy\"></div>"));
        assert!(html.contains("cytoscape({"));
        assert!(html.contains("\"label\": \"a\""));
        assert!(html.contains("data(label)"));
    }

    #[test]
    fn html_escapes_script_breaking_names() {
        // A hostile name must not break out of the inline script: the page
        // keeps exactly the two closing tags of its own script blocks.
        let mut g = Graph::undirected();
        g.add_node("</script><script>alert(1)</script>");
        let html = render_html(&g);
        assert!(html.contains("\\u003c/script>"));
        assert_eq!(html.matches("</script>").count(), 2);
    }
}
