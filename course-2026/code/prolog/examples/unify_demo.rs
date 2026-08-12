//! Unification by hand: most general unifiers and the occurs check.
//!
//! Unification solves equations between terms. The demo walks three
//! equations: two that unify (printing the most general unifier and the
//! common term both sides reduce to) and one that fails the occurs check
//! -- a variable can never be bound to a term that contains it.
//!
//! Run with `cargo run -p prolog --example unify_demo`.

use prolog::subst::{apply, Subst};
use prolog::term::Term;
use prolog::unify::{unify, UnifyError};

fn main() {
    // p(X, a) and p(b, Y): both arguments swap bindings.
    pair(
        "p(_0, a)",
        Term::struct_("p", vec![Term::var(0), Term::atom("a")]),
        "p(b, _1)",
        Term::struct_("p", vec![Term::atom("b"), Term::var(1)]),
    );

    // p(f(X), Y) and p(Z, f(a)): nested structures.
    pair(
        "p(f(_0), _1)",
        Term::struct_(
            "p",
            vec![Term::struct_("f", vec![Term::var(0)]), Term::var(1)],
        ),
        "p(_2, f(a))",
        Term::struct_(
            "p",
            vec![Term::var(2), Term::struct_("f", vec![Term::atom("a")])],
        ),
    );

    // X = f(X): the occurs check rejects the infinite term.
    println!("unify(_0, f(_0)):");
    let mut subst = Subst::new();
    match unify(
        &Term::var(0),
        &Term::struct_("f", vec![Term::var(0)]),
        &mut subst,
    ) {
        Ok(()) => println!("  ok"),
        Err(err) => println!("  fails: {}", err),
    }
}

/// Try one equation, printing the unifier and the unified term.
fn pair(name1: &str, t1: Term, name2: &str, t2: Term) {
    println!("unify({}, {}):", name1, name2);
    let mut subst = Subst::new();
    match unify(&t1, &t2, &mut subst) {
        Ok(()) => {
            println!("  unifier: {}", format_subst(&subst));
            println!("  common:  {}", apply(&t1, &subst));
        }
        Err(UnifyError::Mismatch) => {
            println!("  fails: the terms have different structure");
        }
        Err(err) => {
            println!("  fails: {}", err);
        }
    }
}

/// Render a substitution as `{_0 -> a, _1 -> f(_2)}`, in variable order.
fn format_subst(subst: &Subst) -> String {
    let mut ids: Vec<usize> = subst.keys().copied().collect();
    ids.sort();
    let parts = ids
        .iter()
        .map(|id| format!("_{} -> {}", id, subst[id]))
        .collect::<Vec<_>>()
        .join(", ");
    format!("{{{}}}", parts)
}
