//! Building a BDD for x XOR y.
//!
//! The demo constructs the ROBDD, evaluates it on all four assignments, prints
//! the node count, and shows that negation and satisfiability queries are cheap.

use bdd::Bdd;

fn main() {
    let mut bdd = Bdd::new();
    let x = bdd.var(0);
    let y = bdd.var(1);

    // x XOR y = ite(x, NOT y, y).
    let f = bdd.xor(x, y);

    println!(
        "BDD for x XOR y has {} node(s) (including the constant).",
        bdd.size()
    );
    println!("Truth table:");
    for (vx, vy) in [(false, false), (false, true), (true, false), (true, true)] {
        println!("  x={vx}, y={vy}  ->  x XOR y = {}", bdd.eval(f, &[vx, vy]));
    }

    // Negation is free: NOT f shares the same diagram.
    let nf = bdd.not(f);
    println!("\nNOT adds no node: still {} node(s).", bdd.size());
    println!("Truth table for NOT (x XOR y):");
    for (vx, vy) in [(false, false), (true, true), (false, true), (true, false)] {
        println!("  x={vx}, y={vy}  ->  result = {}", bdd.eval(nf, &[vx, vy]));
    }

    // Structural queries.
    println!();
    println!("Satisfying assignments: {}", bdd.sat_count(f, 2));
    println!("Is tautology?  {}", Bdd::is_tautology(f));
    println!("Is satisfiable? {}", Bdd::is_satisfiable(f));

    // Tautology check: x OR NOT x.
    let t = bdd.or(x, bdd.not(x));
    println!(
        "\nx OR NOT x is tautology? {} (edge = {t})",
        Bdd::is_tautology(t)
    );

    // Restrict: x XOR y with x=true becomes NOT y.
    let fy = bdd.restrict(f, 0, true);
    println!("\n(x XOR y) restricted to x=true gives NOT y:");
    println!("  y=false -> {}", bdd.eval(fy, &[false, false]));
    println!("  y=true  -> {}", bdd.eval(fy, &[false, true]));
}
