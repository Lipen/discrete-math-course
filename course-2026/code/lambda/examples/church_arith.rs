//! Church arithmetic: numerals, addition, multiplication, exponentiation.
//!
//! All computation is pure beta reduction -- no built-in numbers.

use lambda::{add, church, mult, power, succ, to_nat, Term};

fn main() {
    let two = church(2);
    let three = church(3);
    let four = church(4);

    // -- Successor ============================================================

    let one_more = Term::app(succ(), two.clone()).normalize(1000);
    println!("succ 2 = {}", to_nat(&one_more).unwrap());

    // -- Addition =============================================================

    let sum = Term::app(Term::app(add(), two.clone()), three.clone()).normalize(10000);
    println!("2 + 3 = {}", to_nat(&sum).unwrap());

    // -- Multiplication =======================================================

    let prod = Term::app(Term::app(mult(), three), four.clone()).normalize(10000);
    println!("3 * 4 = {}", to_nat(&prod).unwrap());

    // -- Exponentiation =======================================================

    let exp = Term::app(Term::app(power(), two), four).normalize(50000);
    println!("2^4 = {}", to_nat(&exp).unwrap());
}
