//! Building a BDD for x XOR y, the example from the boolean-algebra chapter.
//!
//! The demo constructs the ROBDD, evaluates it on all four assignments, and
//! prints the node count to show how small the diagram is.

use bdd::Bdd;

fn main() {
    let mut bdd = Bdd::new();
    let x = bdd.var(0);
    let y = bdd.var(1);

    // x XOR y = ite(x, ¬y, y).
    let f = bdd.xor(x, y);

    println!(
        "BDD for x XOR y has {} node(s) (including the constant).",
        bdd.size()
    );
    for (x, y) in [(false, false), (false, true), (true, false), (true, true)] {
        println!("x={x}, y={y}  ->  x XOR y = {}", bdd.eval(f, &[x, y]));
    }

    // Negation is free: ¬f shares the same diagram.
    let nf = bdd.not(f);
    println!("\nNOT adds no node: still {} node(s).", bdd.size());
    for (x, y) in [(false, false), (true, true)] {
        println!("x={x}, y={y}  ->  ¬(x XOR y) = {}", bdd.eval(nf, &[x, y]));
    }
}
