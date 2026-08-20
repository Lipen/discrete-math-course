//! A mixed-signature formula decided by the DPLL(T) driver.
//!
//! A small job shop: task A takes between 4 and 5 time units
//! (4 <= finish - start <= 5), and the deadline may lag the start by at most
//! 2 units (deadline - start <= 2). Alongside the schedule, a 4-bit secret
//! must satisfy `secret + 1 == 5`. The driver abstracts every theory atom to
//! a Boolean variable, lets the internal SAT solver pick a model, and hands
//! each model to the matching theory solver.
//!
//! The demo then shows an unsatisfiable mix: the same scheduling atoms plus
//! `secret == 0` and `secret == 1` at once -- the SAT core alone cannot see
//! the contradiction, but the bitvector theory rejects every model.

use smt::bitvec::{BoolExpr, Expr};
use smt::difference::Constraint as Diff;
use smt::driver::{Atom, Formula, Verdict};
use smt::linear::{Constraint as Lin, Rel};

fn main() {
    let finish_ge_4 = Atom::Diff(Diff { x: 0, y: 1, c: 5 });
    let finish_le_5 = Atom::Diff(Diff { x: 1, y: 0, c: -4 });
    let deadline = Atom::Diff(Diff { x: 2, y: 1, c: 2 });
    let budget = Atom::Linear(Lin {
        coeffs: vec![1, 1],
        b: 6,
        rel: Rel::Le,
    });

    let secret_plus_one = Atom::Bitvec(BoolExpr::Eq(
        Box::new(Expr::Add(
            Box::new(Expr::Var(0, 4)),
            Box::new(Expr::Const(1, 4)),
        )),
        Box::new(Expr::Const(5, 4)),
    ));

    let schedule = Formula::And(
        Box::new(Formula::And(
            Box::new(Formula::Atom(finish_ge_4)),
            Box::new(Formula::Atom(finish_le_5)),
        )),
        Box::new(Formula::Atom(deadline)),
    );
    let sat = Formula::And(
        Box::new(schedule.clone()),
        Box::new(Formula::And(
            Box::new(Formula::Atom(budget.clone())),
            Box::new(Formula::Atom(secret_plus_one)),
        )),
    );
    println!("satisfiable mix:");
    println!("  finish - start <= 5, start - finish <= -4, deadline - start <= 2");
    println!("  x + y <= 6, secret + 1 == 5 (4 bits)");
    match smt::check(&sat) {
        Ok(Verdict::Sat) => println!("  verdict: satisfiable"),
        Ok(Verdict::Unsat) => println!("  verdict: unsatisfiable"),
        Err(e) => println!("  error: {e}"),
    }

    // Two branches, each fine on its own but arithmetically contradictory:
    // branch A asks the secret to be 0 and 1 at once, branch B asks for
    // x + y <= 6 and x + y >= 7. The SAT core proposes each branch, the
    // matching theory rejects it, and the driver learns the conflict; in the
    // end no Boolean model survives.
    let secret_0 = Formula::Atom(Atom::Bitvec(BoolExpr::Eq(
        Box::new(Expr::Var(0, 4)),
        Box::new(Expr::Const(0, 4)),
    )));
    let secret_1 = Formula::Atom(Atom::Bitvec(BoolExpr::Eq(
        Box::new(Expr::Var(0, 4)),
        Box::new(Expr::Const(1, 4)),
    )));
    let budget_high = Formula::Atom(Atom::Linear(Lin {
        coeffs: vec![-1, -1],
        b: -7,
        rel: Rel::Le,
    }));
    let branch_a = Formula::And(
        Box::new(schedule.clone()),
        Box::new(Formula::And(Box::new(secret_0), Box::new(secret_1))),
    );
    let branch_b = Formula::And(
        Box::new(schedule),
        Box::new(Formula::And(
            Box::new(Formula::Atom(budget)),
            Box::new(budget_high),
        )),
    );
    let unsat = Formula::Or(Box::new(branch_a), Box::new(branch_b));
    println!("\nunsatisfiable mix:");
    println!("  (schedule AND secret == 0 AND secret == 1)");
    println!("    OR (schedule AND x + y <= 6 AND x + y >= 7)");
    match smt::check(&unsat) {
        Ok(Verdict::Sat) => println!("  verdict: satisfiable"),
        Ok(Verdict::Unsat) => println!("  verdict: unsatisfiable"),
        Err(e) => println!("  error: {e}"),
    }
}
