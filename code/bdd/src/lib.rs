//! Reduced ordered binary decision diagrams (ROBDDs) with complement edges.
//!
//! A BDD represents a boolean function as a directed acyclic graph built by
//! Shannon expansion: a node `(v, lo, hi)` means "if variable `v` then `hi`
//! else `lo`". Reduction removes redundant nodes (lo == hi) and merges equal
//! subgraphs, so every function has exactly one canonical diagram under a
//! fixed variable order. Complement edges store negation as a flag on the
//! edge: `NOT` costs no new node, and a function and its negation share a
//! single diagram.
//!
//! # Quick example
//!
//! ```
//! use bdd::{Bdd, Expr};
//!
//! let mut bdd = Bdd::new();
//!
//! // Build (x0 ∧ x1) ∨ (¬x0 ∧ ¬x1) -- the XNOR function.
//! let e = Expr::var(0).and(Expr::var(1))
//!     .or(Expr::var(0).not_().and(Expr::var(1).not_()));
//! let f = e.to_bdd(&mut bdd);
//!
//! assert!(bdd.eval(f, &[false, false]));
//! assert!(!bdd.eval(f, &[false, true]));
//! assert!(!bdd.eval(f, &[true, false]));
//! assert!(bdd.eval(f, &[true, true]));
//!
//! // Every function has a unique canonical edge.
//! assert_eq!(bdd.sat_count(f, 2), 2);
//! assert!(Bdd::is_satisfiable(f));
//! assert!(!Bdd::is_tautology(f));
//! ```

pub mod bdd;
pub mod expr;

pub use bdd::{Bdd, Edge, PlainBdd, PlainNode, FALSE, TRUE};
pub use expr::Expr;
