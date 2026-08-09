//! DPLL on the two formulas from the book chapter on SAT.
//!
//! The first is the worked example from the chapter: DPLL exhausts every
//! branch and reports UNSAT. The second is a simple satisfiable formula whose
//! model the solver prints.

use sat::solve;

fn main() {
    // From the chapter: F = (x1∨x2∨x3) ∧ (¬x1∨x2) ∧ (x2∨¬x3) ∧ (¬x2∨x3) ∧ (¬x2∨¬x3).
    let unsat: Vec<Vec<i32>> = vec![
        vec![1, 2, 3],
        vec![-1, 2],
        vec![2, -3],
        vec![-2, 3],
        vec![-2, -3],
    ];
    match solve(3, &unsat) {
        Some(_) => println!("UNSAT formula: solver found a model (that is a bug!)"),
        None => println!("UNSAT formula: solver reports no model --- correct"),
    }

    // Satisfiable: (x1∨x2) ∧ (¬x1∨x2) ∧ (x2∨¬x3).
    let sat: Vec<Vec<i32>> = vec![vec![1, 2], vec![-1, 2], vec![2, -3]];
    match solve(3, &sat) {
        Some(m) => println!(
            "SAT formula: model x1 = {}, x2 = {}, x3 = {}",
            m[0] as u8, m[1] as u8, m[2] as u8
        ),
        None => println!("SAT formula: solver reports UNSAT (that is a bug!)"),
    }
}
