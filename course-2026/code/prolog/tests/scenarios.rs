//! Scenario tests: the core working end-to-end on classic programs.

use prolog::apply;
use prolog::term::Term;
use prolog::Clause;
use prolog::Database;
use prolog::Goal;
use prolog::Solver;
use prolog::Subst;

/// A closed list of atoms, e.g. `list(&["a", "b"])` is `[a, b]`.
fn list(items: &[&str]) -> Term {
    let mut out = Term::nil();
    for item in items.iter().rev() {
        out = Term::cons(Term::atom(*item), out);
    }
    out
}

fn answer_strings(answers: &[Subst], var: usize) -> Vec<String> {
    answers
        .iter()
        .map(|s| apply(&Term::var(var), s).to_string())
        .collect()
}

fn append_program() -> Database {
    let mut db = Database::new();
    // append([], Y, Y).
    db.add(Clause::fact(Term::struct_(
        "append",
        vec![Term::nil(), Term::var(0), Term::var(0)],
    )));
    // append([X | Xs], Y, [X | Zs]) :- append(Xs, Y, Zs).
    db.add(Clause::rule(
        Term::struct_(
            "append",
            vec![
                Term::cons(Term::var(0), Term::var(1)),
                Term::var(2),
                Term::cons(Term::var(0), Term::var(3)),
            ],
        ),
        Goal::call(Term::struct_(
            "append",
            vec![Term::var(1), Term::var(2), Term::var(3)],
        )),
    ));
    db
}

#[test]
fn append_concatenates_two_lists() {
    let db = append_program();
    let goal = Goal::call(Term::struct_(
        "append",
        vec![list(&["a", "b"]), list(&["c"]), Term::var(0)],
    ));
    let answers = Solver::new(db).solve(&goal, 3);
    assert_eq!(answers.len(), 1);
    assert_eq!(answer_strings(&answers, 0), vec!["[a, b, c]"]);
}

#[test]
fn append_splits_a_list_in_all_ways() {
    let db = append_program();
    let goal = Goal::call(Term::struct_(
        "append",
        vec![Term::var(0), Term::var(1), list(&["a", "b"])],
    ));
    let answers = Solver::new(db).solve(&goal, 10);
    let left = answer_strings(&answers, 0);
    let right = answer_strings(&answers, 1);
    assert_eq!(left, vec!["[]", "[a]", "[a, b]"]);
    assert_eq!(right, vec!["[a, b]", "[b]", "[]"]);
}

#[test]
fn reverse_reverses_a_list() {
    // The append program already provides the append the reverse rule needs.
    let mut db = append_program();
    // reverse([], []).
    db.add(Clause::fact(Term::struct_(
        "reverse",
        vec![Term::nil(), Term::nil()],
    )));
    // reverse([X | Xs], R) :- reverse(Xs, Rs), append(Rs, [X], R).
    db.add(Clause::rule(
        Term::struct_(
            "reverse",
            vec![Term::cons(Term::var(0), Term::var(1)), Term::var(2)],
        ),
        Goal::conj(vec![
            Goal::call(Term::struct_("reverse", vec![Term::var(1), Term::var(3)])),
            Goal::call(Term::struct_(
                "append",
                vec![
                    Term::var(3),
                    Term::cons(Term::var(0), Term::nil()),
                    Term::var(2),
                ],
            )),
        ]),
    ));

    let goal = Goal::call(Term::struct_(
        "reverse",
        vec![list(&["a", "b", "c"]), Term::var(0)],
    ));
    let answers = Solver::new(db).solve(&goal, 3);
    assert_eq!(answer_strings(&answers, 0), vec!["[c, b, a]"]);
}
