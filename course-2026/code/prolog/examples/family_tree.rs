//! A family tree as a clause database: facts and rules.
//!
//! This is the classic first Prolog program. Facts record who is whose
//! parent; two rules extend "parent" to "ancestor": an ancestor is a
//! parent, or a parent of an ancestor. The database holds the program
//! ready for a resolver to run; resolving a query against it is the
//! student project built on top of this crate.
//!
//! Run with `cargo run -p prolog --example family_tree`.

use prolog::clause::Clause;
use prolog::database::Database;
use prolog::goal::Goal;
use prolog::subst::{apply, Subst};
use prolog::term::Term;
use prolog::unify::unify;

/// `parent(a, b)`.
fn parent(a: &str, b: &str) -> Term {
    Term::struct_("parent", vec![Term::atom(a), Term::atom(b)])
}

/// `parent(_x, _y)`.
fn parent_term(x: usize, y: usize) -> Term {
    Term::struct_("parent", vec![Term::var(x), Term::var(y)])
}

fn main() {
    let mut db = Database::new();

    // Facts: direct parenthood.
    for (p, c) in [
        ("alice", "bob"),
        ("alice", "erin"),
        ("bob", "carol"),
        ("carol", "dave"),
    ] {
        let fact = Clause::fact(parent(p, c));
        println!("program: {}", fact);
        db.add(fact);
    }

    // Rule: ancestor(X, Y) :- parent(X, Y).
    let base = Clause::rule(
        Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
        Goal::call(parent_term(0, 1)),
    );
    println!("program: {}", base);
    db.add(base);

    // Rule: ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
    let recursive = Clause::rule(
        Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
        Goal::conj(vec![
            Goal::call(parent_term(0, 2)),
            Goal::call(Term::struct_("ancestor", vec![Term::var(2), Term::var(1)])),
        ]),
    );
    println!("program: {}", recursive);
    db.add(recursive);

    // Unification is the engine that will later match a goal against a
    // clause head. Here: match parent(_0, _1) against the fact parent(alice, bob).
    println!("\nunify(parent(_0, _1), parent(alice, bob)):");
    let mut subst = Subst::new();
    let goal = parent_term(0, 1);
    match unify(&goal, &parent("alice", "bob"), &mut subst) {
        Ok(()) => println!("  {} -> {}", goal, apply(&goal, &subst)),
        Err(err) => println!("  fails: {}", err),
    }
}
