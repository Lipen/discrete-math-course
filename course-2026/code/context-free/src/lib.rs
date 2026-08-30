//! Context-free grammars and languages.
//!
//! A context-free grammar generates a language by rules `A -> alpha`, where a
//! nonterminal is replaced by a string of terminals and nonterminals. The same
//! word can have several parse trees. This crate models grammars, enumerates
//! every parse tree of a word, converts grammars to Chomsky normal form, and
//! recognizes words with CYK.
//!
//! ```
//! use context_free::{Grammar, Production, recognize, to_cnf, t, nt};
//!
//! // S -> a S b | ε   (the language a^n b^n)
//! let g = Grammar::new("S", vec![
//!     Production::new("S", vec![t("a"), nt("S"), t("b")]),
//!     Production::new("S", vec![]),
//! ]);
//!
//! let cnf = to_cnf(&g);
//! assert!(recognize(&cnf, "aabb"));
//! assert!(!recognize(&cnf, "abab"));
//! assert!(recognize(&cnf, ""));
//! ```

pub mod cnf;
pub mod cyk;
pub mod grammar;
pub mod parse_tree;

use std::fmt;

/// An error from enumerating parse trees.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GrammarError {
    /// A word has more parse trees than the safety cap permits -- typically an
    /// epsilon- or unit-cycle in the grammar, which is infinitely ambiguous.
    TooManyParseTrees,
}

impl fmt::Display for GrammarError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            GrammarError::TooManyParseTrees => {
                write!(f, "too many parse trees (infinite ambiguity?)")
            }
        }
    }
}

impl std::error::Error for GrammarError {}

pub use cnf::to_cnf;
pub use cyk::{recognize, table};
pub use grammar::{nt, t, Grammar, Production, Symbol};
pub use parse_tree::{all_parse_trees, in_language, ParseTree, MAX_PARSE_TREES};
