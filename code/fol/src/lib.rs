//! First-order logic: terms, formulas, and finite models.
//!
//! A first-order language has a [`signature::Signature`] of constants, function symbols, and predicate symbols.
//! From these we build [`term::Term`]s (variables, constants, function applications) and [`formula::Formula`]s (atoms, equality, the connectives `¬ ∧ ∨ ->`, and the quantifiers `∀` and `∃`).
//!
//! A [`structure::Structure`] gives the symbols a meaning: a non-empty domain, a value for each constant, a total function for each function symbol, and a relation for each predicate symbol.
//! [`structure::Structure::eval`] computes the truth of a sentence by Tarski's definition, with quantifiers ranging over the whole domain.
//!
//! [`formula::Formula::substitute`] replaces a free variable by a term, renaming a bound variable first when capture would otherwise occur.
//! Over a fixed finite domain there are finitely many structures.
//! [`enumerate::enumerate_structures`] lists them all, and [`enumerate::satisfiable_over`] / [`enumerate::valid_over`] decide satisfiability and validity by exhaustion.
//!
//! ```
//! use fol::formula::{exists, forall, pred};
//! use fol::structure::Structure;
//! use fol::term::var;
//!
//! // "Everyone loves someone": ∀x ∃y L(x, y).
//! let everyone_loves_someone =
//!     forall("x", exists("y", pred("L", vec![var("x"), var("y")])));
//!
//! // A two-person world where each loves the other: L = {(a, b), (b, a)}.
//! let mut rel = std::collections::HashSet::new();
//! rel.insert(vec!["a".to_string(), "b".to_string()]);
//! rel.insert(vec!["b".to_string(), "a".to_string()]);
//! let model = Structure::new(vec!["a".to_string(), "b".to_string()])
//!     .with_predicate("L", rel);
//!
//! assert_eq!(model.eval(&everyone_loves_someone), Ok(true));
//! ```

pub mod enumerate;
pub mod error;
pub mod formula;
pub mod signature;
pub mod structure;
pub mod term;
