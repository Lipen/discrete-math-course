//! DPLL on a small unsatisfiable formula, then on a satisfiable one.
//!
//! The first run exhausts every branch and reports UNSAT.
//! The second run finds a model and prints it.
//!
//! Run with `cargo run --example dpll_demo`.

use sat::cnf::{neg, pos, Cnf};
use sat::solve_traced;

fn main() {
    println!("=== Example 1: unsatisfiable formula ===\n");

    // F = (x1 ∨ x2 ∨ x3) ∧ (¬x1 ∨ x2) ∧ (x2 ∨ ¬x3) ∧ (¬x2 ∨ x3) ∧ (¬x2 ∨ ¬x3)
    let unsat = Cnf::new(
        3,
        vec![
            vec![pos(1), pos(2), pos(3)],
            vec![neg(1), pos(2)],
            vec![pos(2), neg(3)],
            vec![neg(2), pos(3)],
            vec![neg(2), neg(3)],
        ],
    )
    .unwrap();
    solve_traced(&unsat);

    println!("\n=== Example 2: satisfiable formula ===\n");

    // (x1 ∨ x2) ∧ (¬x1 ∨ x2) ∧ (x2 ∨ ¬x3)
    let sat_formula = Cnf::new(
        3,
        vec![
            vec![pos(1), pos(2)],
            vec![neg(1), pos(2)],
            vec![pos(2), neg(3)],
        ],
    )
    .unwrap();
    solve_traced(&sat_formula);
}
