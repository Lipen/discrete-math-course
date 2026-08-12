//! Combinators: I, K, S, and the non-terminating Ω.
//!
//! Each combinator is a closed term that captures a fundamental pattern of
//! function application.

use lambda::{i, k, omega, s, Term};

fn main() {
    // -- I: identity =========================================================

    let ix = Term::app(i(), Term::var("a")).normalize(10);
    println!("I a  →  {}", ix);

    // -- K: constant =========================================================

    let kab = Term::app(Term::app(k(), Term::var("a")), Term::var("b")).normalize(10);
    println!("K a b  →  {}", kab);

    // -- S: substitution (the SKI system) ====================================

    let s_term = s();
    println!("S  =  {}", s_term);

    // SKK x  →  x  (SKK is extensionally equal to I)
    let skk = Term::app(Term::app(Term::app(s(), k()), k()), Term::var("x"));
    println!("\nS K K x  → ...");
    for (i, step) in skk.trace(20).iter().enumerate() {
        println!("  step {}: {}", i, step);
    }

    // -- Ω: non-terminating combinator =======================================

    println!("\nΩ  =  {}", omega());
    println!("Ω is in normal form?  {}", omega().is_normal_form());
    println!("Ω after 3 reductions:  {}", omega().normalize(3));
}
