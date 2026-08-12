//! A miniature Prolog: terms, unification, and SLD resolution.
//!
//! This crate is a study playground for logic programming. It models the
//! core of Prolog as a mathematical system:
//!
//! - terms ([`term::Term`]) -- variables, constants, and structures;
//! - substitutions ([`subst`]) and unification with the occurs check
//!   ([`mod@unify`]);
//! - definite clauses ([`clause::Clause`]): facts and rules;
//! - a program ([`database::Database`]) and a depth-first SLD solver with
//!   backtracking ([`solver::Solver`]).
//!
//! The library deliberately stops before a full language: there is no
//! parser, no REPL, no arithmetic, and no cut or negation. Building those
//! on top of this core is a natural student project.
//!
//! The shortest end-to-end example:
//!
//! ```
//! use prolog::term::Term;
//! use prolog::goal::Goal;
//! use prolog::clause::Clause;
//! use prolog::database::Database;
//! use prolog::solver::Solver;
//!
//! let mut db = Database::new();
//! db.add(Clause::fact(Term::struct_(
//!     "parent",
//!     vec![Term::atom("alice"), Term::atom("bob")],
//! )));
//! db.add(Clause::fact(Term::struct_(
//!     "parent",
//!     vec![Term::atom("alice"), Term::atom("carol")],
//! )));
//!
//! // ?- parent(X, Y).
//! let goal = Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)]));
//! let answers = Solver::new(db).solve(&goal, 10);
//! assert_eq!(answers.len(), 2);
//! ```

pub mod clause;
pub mod database;
pub mod goal;
pub mod query;
pub mod rename;
pub mod solver;
pub mod subst;
pub mod term;
pub mod unify;

pub use clause::Clause;
pub use database::Database;
pub use goal::Goal;
pub use query::Query;
pub use rename::rename_clause;
pub use solver::{Solver, TraceEvent};
pub use subst::{apply, Subst};
pub use term::Term;
pub use unify::{unify, UnifyError};
