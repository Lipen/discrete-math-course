//! A family tree: facts and rules, queried with `parent` and `ancestor`.
//!
//! This is the classic first Prolog program. Facts record who is whose
//! parent; two rules extend "parent" to "ancestor": an ancestor is a
//! parent, or a parent of an ancestor. The second rule is recursive, so
//! depth-first search walks arbitrarily far back up the tree.
//!
//! Run with `cargo run -p prolog --example family_tree`.

use prolog::clause::Clause;
use prolog::database::Database;
use prolog::goal::Goal;
use prolog::query::Query;
use prolog::solver::Solver;
use prolog::term::Term;

/// `parent(a, b)`.
fn parent(a: &str, b: &str) -> Term {
    Term::struct_("parent", vec![Term::atom(a), Term::atom(b)])
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

    // Query: every ancestor of alice.
    let query = Query::new(
        Goal::call(Term::struct_(
            "ancestor",
            vec![Term::atom("alice"), Term::var(0)],
        )),
        vec![(0, "Descendant")],
    );
    println!("\nquery: {}", query);
    let mut solver = Solver::new(db);
    solver.query(query.goal.clone());
    let mut count = 0;
    while let Some(subst) = solver.next_solution() {
        count += 1;
        println!("answer {}: {}", count, query.answer(&subst));
    }
    println!("{} answers", count);
}

fn parent_term(x: usize, y: usize) -> Term {
    Term::struct_("parent", vec![Term::var(x), Term::var(y)])
}
