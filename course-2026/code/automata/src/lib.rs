//! Finite automata and regular languages.
//!
//! DFAs, NFAs (with epsilon transitions), the subset construction, operations
//! on languages (complement, union, intersection, difference), regular
//! expressions (Thompson construction) and minimization. The worked examples
//! from the book are runnable `examples/`, and the core structures are covered
//! by tests.

pub mod dfa;
pub mod nfa;
pub mod regex;

pub use dfa::Dfa;
pub use nfa::Nfa;
pub use regex::{parse, RegEx};
