//! A difference-logic (DL) satisfiability solver.
//!
//! Difference logic is a fragment of linear integer arithmetic: conjunctions
//! of literals of the form `x - y <= c`. Satisfiability reduces to detecting a
//! negative cycle in a weighted directed graph (Bellman--Ford).
//!
//! ```
//! use smt::difference::{Constraint, solve};
//!
//! // 4 <= x - y <= 5  (i.e. x - y <= 5 and y - x <= -4)
//! let cs = vec![
//!     Constraint { x: 0, y: 1, c: 5 },
//!     Constraint { x: 1, y: 0, c: -4 },
//! ];
//!
//! let a = solve(&cs).unwrap();
//! assert!(a[0] - a[1] <= 5);
//! assert!(a[1] - a[0] <= -4);
//! ```

pub mod difference;

pub use difference::{solve, Constraint};
