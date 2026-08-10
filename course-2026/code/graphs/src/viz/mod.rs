//! Rendering graphs: how to "draw" a graph in different ways.
//!
//! The layout (where each vertex goes) is not something to draw by hand:
//! ready-made tools do that. The crate hands them text instead:
//!
//! - [`dot`]: a description for Graphviz. The `dot`, `neato`, `fdp`, `circo`
//!   utilities pick the layout themselves and draw a picture in any format;
//! - [`cytoscape`]: JSON for the cytoscape.js library. It lays the graph out
//!   on its own (the `cose`, `circle`, `concentric`, ... algorithms) and
//!   makes it interactive in the browser.
//!
//! Both formats are text, so Graphviz needs nothing but `dot` itself, and
//! cytoscape needs only `serde_json`.

pub mod cytoscape;
pub mod dot;

/// Strip characters that are invalid in DOT identifiers.
pub(crate) fn dot_id(text: &str) -> String {
    if text.is_empty() {
        return String::from("_");
    }
    let cleaned: String = text
        .chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '_' {
                c
            } else {
                '_'
            }
        })
        .collect();
    if cleaned.chars().next().unwrap().is_ascii_digit() {
        return format!("n{cleaned}");
    }
    cleaned
}
