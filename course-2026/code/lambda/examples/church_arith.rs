//! Арифметика Чёрча из главы m21: `2 + 3 = 5` и `succ 2 = 3`.
//!
//! Вычисление --- чистая бета-редукция: никаких встроенных чисел.

use lambda::{add, church, succ, to_nat, Term};

fn main() {
    let two = church(2);
    let three = church(3);

    let sum = Term::app(Term::app(add(), two.clone()), three).normalize(10000);
    println!(
        "2 + 3 = {}",
        to_nat(&sum).expect("терм не оказался числом Чёрча")
    );

    let next = Term::app(succ(), two).normalize(1000);
    println!(
        "succ 2 = {}",
        to_nat(&next).expect("терм не оказался числом Чёрча")
    );
}
