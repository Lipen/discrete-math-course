//! Graphs: modeling, algorithms, and visualization.
//!
//! A teaching crate for the graphs chapter: a simple model without generics
//! or traits, the classic algorithms, and ways to render a graph.
//!
//! ```no_run
//! use graphs::Graph;
//!
//! let mut g = Graph::undirected();
//! let a = g.add_node("a");
//! let b = g.add_node("b");
//! let c = g.add_node("c");
//! g.add_edges(&[(a, b), (b, c), (c, a)]);
//!
//! // There is one connected component, and distances come from BFS.
//! assert_eq!(graphs::connected_components(&g).0, 1);
//! assert_eq!(graphs::distance(&g, a, c), Some(2));
//! ```

pub mod algo;
pub mod graph;
pub mod unionfind;
pub mod viz;

pub use algo::*;
pub use graph::{Edge, Graph};
pub use unionfind::UnionFind;
