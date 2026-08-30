//! Terms, substitutions, unification, and clause databases.
//!
//! This crate models the *data* of logic programming without the search.
//! It provides the terms a Prolog program is made of, substitutions and
//! unification with the occurs check, and a database of definite clauses
//! (facts and rules). Building the SLD resolver on top of these pieces --
//! the depth-first proof search with backtracking -- is the student
//! project.
//!
//! - terms ([`term::Term`]) -- variables, constants, and structures;
//! - substitutions ([`subst`]) and unification with the occurs check
//!   ([`mod@unify`]);
//! - definite clauses ([`clause::Clause`]): facts and rules;
//! - a program ([`database::Database`]) that indexes clauses by predicate.
//!
//! The library deliberately stops before a full language: there is no
//! parser, no REPL, no arithmetic, and no cut or negation, and no solver
//! that runs a query. Building those on top of this core is a natural
//! student project.
//!
//! The shortest end-to-end example: unify two terms, then watch the occurs
//! check reject a cyclic binding.
//!
//! ```
//! use prolog::term::Term;
//! use prolog::subst::Subst;
//! use prolog::unify::{unify, UnifyError};
//!
//! // f(_0, a) and f(b, _1) unify: {_0 -> b, _1 -> a}.
//! let mut subst = Subst::new();
//! let t1 = Term::struct_("f", vec![Term::var(0), Term::atom("a")]);
//! let t2 = Term::struct_("f", vec![Term::atom("b"), Term::var(1)]);
//! assert!(unify(&t1, &t2, &mut subst).is_ok());
//! assert_eq!(subst[&0], Term::atom("b"));
//! assert_eq!(subst[&1], Term::atom("a"));
//!
//! // _0 = f(_0) must fail: the occurs check rejects the infinite term.
//! let mut subst = Subst::new();
//! let err = unify(
//!     &Term::var(0),
//!     &Term::struct_("f", vec![Term::var(0)]),
//!     &mut subst,
//! ).unwrap_err();
//! assert_eq!(
//!     err,
//!     UnifyError::OccursCheck { var: 0, term: Term::struct_("f", vec![Term::var(0)]) }
//! );
//! ```

pub mod clause;
pub mod database;
pub mod goal;
pub mod subst;
pub mod term;
pub mod unify;

pub use clause::Clause;
pub use database::Database;
pub use goal::Goal;
pub use subst::{apply, Subst};
pub use term::Term;
pub use unify::{unify, UnifyError};
