//! Sign analysis on a tiny program: where abstraction costs precision.
//!
//! The first snippet shows the cost: a positive plus a negative has unknown
//! sign. The second shows branch merging: the join of the two branches is ⊤.

use analysis::program::{assign, exec_sign, Expr, State, Stmt};
use analysis::Sign;

fn main() {
    // a := 3; b := -7; c := a + b.
    let program = vec![assign("a", 3), assign("b", -7)];
    let mut st: State<Sign> = State::new();
    exec_sign(&program, &mut st);
    let c = analysis::program::eval_sign(
        &Expr::Add(
            Box::new(Expr::Var("a".into())),
            Box::new(Expr::Var("b".into())),
        ),
        &st,
    );
    println!("a is {}, b is {}", st["a"], st["b"]);
    println!(
        "c := a + b  ->  c is {}   (the sign of 3 + (-7) is unknown)",
        c
    );

    // Branch merge: if b then y := 1 else y := -1.
    let branchy = vec![Stmt::If {
        then: vec![assign("y", 1)],
        els: vec![assign("y", -1)],
    }];
    exec_sign(&branchy, &mut st);
    println!("\nafter if/else merge: y is {}", st["y"]);
    println!("the join of + and - is unknown -- sound, but imprecise");
}
