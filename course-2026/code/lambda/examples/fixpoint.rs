//! Fixed-point combinators: recursion without names.
//!
//! Y (call-by-name) and Z (call-by-value) turn a one-step term into a
//! recursive function. The factorial shows the pattern: Fact takes the
//! recursive call as its first argument, and Z supplies it.

use lambda::church::{church, to_nat};
use lambda::fixpoint::{fact, y, z};
use lambda::Term;

fn main() {
    // -- Y: the fixed-point equation, step by step ==========================
    // K = λf. λx. x ignores its argument, so Y K -> K (Y K) -> λx. x:
    // the fixed point of K is the identity.
    println!("Y K unfolds:");
    let k = Term::abs("f", Term::abs("x", Term::var("x")));
    for (i, step) in Term::app(y(), k).trace(10).iter().enumerate() {
        println!("  step {i}: {step}");
    }

    // -- Z: the call-by-value fixed point ====================================
    println!("\nZ = {}", z());
    println!("Z is a closed term: {}", z().free_vars().is_empty());

    // -- Factorial via Z =====================================================
    println!();
    for n in 0..=3 {
        let result = Term::app(fact(), church(n)).normalize(200_000);
        println!("fact {n} = {}", to_nat(&result).unwrap());
    }
    println!("(3! already takes ~1500 beta steps -- naive substitution is exponential)");
}
