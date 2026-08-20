//! Proofs the checker rejects, and why.
//!
//! Two classic mistakes: stating a disjunction whose left disjunct does not
//! match the line cited, and referencing a line inside a subproof that has
//! already been discharged.

use fitch::{atom, check, implies, or, Just, Step};

fn main() {
    let a = atom("A");
    let b = atom("B");
    let c = atom("C");

    // From A, ∨-introduction may state A ∨ X -- but not B ∨ C.
    let wrong_disjunct = vec![
        Step { depth: 0, formula: a.clone(), just: Just::Assumption },
        Step { depth: 0, formula: or(b.clone(), c.clone()), just: Just::OrIntroLeft { disj: 1 } },
    ];

    let p = atom("P");
    let q = atom("Q");
    // The subproof hypothesis Q (line 2) is discharged by line 3; line 4
    // still tries to use it.
    let out_of_scope = vec![
        Step { depth: 0, formula: p.clone(), just: Just::Assumption },
        Step { depth: 1, formula: q.clone(), just: Just::Assumption },
        Step {
            depth: 0,
            formula: implies(q.clone(), q.clone()),
            just: Just::ImpliesIntro { assump: 2, concl: 2 },
        },
        Step { depth: 0, formula: q.clone(), just: Just::AndElimLeft { conj: 2 } },
    ];

    report("wrong disjunct", &wrong_disjunct);
    report("out-of-scope line", &out_of_scope);
}

fn report(title: &str, steps: &[Step]) {
    println!("{title}");
    for (i, s) in steps.iter().enumerate() {
        println!("{:>2}. {}{}", i + 1, "  ".repeat(s.depth), s.formula);
    }
    match check(steps) {
        Ok(()) => println!("  verdict: accepted"),
        Err(e) => println!("  verdict: rejected -- {e}"),
    }
    println!();
}
