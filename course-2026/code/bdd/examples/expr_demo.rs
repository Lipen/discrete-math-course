//! Building BDDs from boolean expressions.
//!
//! The `Expr` type lets you write formulas as Rust expressions and convert
//! them to BDDs. This demo shows equivalence checking, tautology detection,
//! and model counting -- all enabled by the canonical representation.

use bdd::{Bdd, Expr};

fn main() {
    let mut bdd = Bdd::new();

    // -- XNOR expressed two ways ===========================================
    //   (x ∧ y) ∨ (¬x ∧ ¬y)
    let x = Expr::var(0);
    let y = Expr::var(1);

    let xnor1 = x
        .clone()
        .and(y.clone())
        .or(x.clone().not_().and(y.clone().not_()));

    //   x ↔ y  =  (x -> y) ∧ (y -> x)
    let xnor2 = x
        .clone()
        .implies(y.clone())
        .and(y.clone().implies(x.clone()));

    let f1 = xnor1.to_bdd(&mut bdd);
    let f2 = xnor2.to_bdd(&mut bdd);

    println!("XNOR built two ways:");
    println!("  (x ∧ y) ∨ (¬x ∧ ¬y)  -> edge {f1}");
    println!("  (x -> y) ∧ (y -> x)    -> edge {f2}");
    println!("  Same BDD? {}", f1 == f2);
    println!("  Satisfying assignments: {}", bdd.sat_count(f1, 2));

    // Truth table.
    println!("  Truth table:");
    for (vx, vy) in [(false, false), (false, true), (true, false), (true, true)] {
        println!("    x={vx}, y={vy} -> {}", bdd.eval(f1, &[vx, vy]));
    }

    // -- Transitivity of implication (tautology) ===========================
    println!("\n-- Checking a tautology --");
    let z = Expr::var(2);
    // (x -> y) ∧ (y -> z)  ->  (x -> z)
    let premise = x
        .clone()
        .implies(y.clone())
        .and(y.clone().implies(z.clone()));
    let conclusion = x.clone().implies(z.clone());
    let transitivity = premise.implies(conclusion);

    let t = transitivity.to_bdd(&mut bdd);
    println!("  (x -> y) ∧ (y -> z) -> (x -> z)");
    println!("  Is tautology? {}", Bdd::is_tautology(t));
    println!("  Node count: {}", bdd.size());

    // -- Contradiction ====================================================
    println!("\n-- An unsatisfiable formula --");
    // x ∧ ¬x
    let contradiction = x.clone().and(x.not_());
    let c = contradiction.to_bdd(&mut bdd);
    println!("  x ∧ ¬x");
    println!("  Is satisfiable? {}", Bdd::is_satisfiable(c));
    println!("  Satisfying assignments: {}", bdd.sat_count(c, 1));
}
