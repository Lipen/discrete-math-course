//! Church arithmetic from the chapter: `2 + 3 = 5` and `succ 2 = 3`.
//!
//! The computation is pure beta reduction: no built-in numbers.

use lambda::{add, church, succ, to_nat, Term};

fn main() {
    let two = church(2);
    let three = church(3);

    let sum = Term::app(Term::app(add(), two.clone()), three).normalize(10000);
    println!(
        "2 + 3 = {}",
        to_nat(&sum).expect("term did not evaluate to a Church numeral")
    );

    let next = Term::app(succ(), two).normalize(1000);
    println!(
        "succ 2 = {}",
        to_nat(&next).expect("term did not evaluate to a Church numeral")
    );
}
