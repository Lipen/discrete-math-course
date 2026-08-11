//! Constant propagation: where knowing exact values helps, and where we lose them.
//!
//! Three programs illustrate the constant domain:
//! 1. Constants are preserved through arithmetic.
//! 2. Branches destroy constant information (1 ⊔ 2 = ⊤).
//! 3. Zero times unknown is zero -- a key insight of constant propagation.

use analysis::program::{assign, exec_const, Expr, State, Stmt};
use analysis::Const;

fn main() {
    // -- Program 1: constants preserved through arithmetic --
    println!("=== Program 1: constants propagate through arithmetic ===");
    // x := 5; y := x + 3; z := y * 2
    let program = vec![
        assign("x", 5),
        Stmt::Assign(
            "y".into(),
            Expr::Add(Box::new(Expr::Var("x".into())), Box::new(Expr::Const(3))),
        ),
        Stmt::Assign(
            "z".into(),
            Expr::Mul(Box::new(Expr::Var("y".into())), Box::new(Expr::Const(2))),
        ),
    ];
    let mut st: State<Const> = State::new();
    exec_const(&program, &mut st);
    println!("x := 5     ->  x = {}", st["x"]);
    println!("y := x + 3 ->  y = {}", st["y"]);
    println!("z := y * 2 ->  z = {}", st["z"]);
    println!("all three values are known constants\n");

    // -- Program 2: branch loses precision --
    println!("=== Program 2: branches destroy constants ===");
    // if ... then w := 1 else w := 2
    // u := w * 3
    let mut st: State<Const> = State::new();
    let branchy = vec![
        Stmt::If {
            then: vec![assign("w", 1)],
            els: vec![assign("w", 2)],
        },
        Stmt::Assign(
            "u".into(),
            Expr::Mul(Box::new(Expr::Var("w".into())), Box::new(Expr::Const(3))),
        ),
    ];
    exec_const(&branchy, &mut st);
    println!("if ... then w := 1 else w := 2");
    println!("w = 1 ⊔ 2 = {}", st["w"]);
    println!("u := w * 3 = {} * 3 = {}", st["w"], st["u"]);
    println!("the branch merges two different constants into ⊤\n");

    // -- Program 3: zero kills uncertainty --
    println!("=== Program 3: zero times unknown is zero ===");
    // t := 0
    // if ... then v := 10 else v := 20
    // s := t * v
    let program = vec![
        assign("t", 0),
        Stmt::If {
            then: vec![assign("v", 10)],
            els: vec![assign("v", 20)],
        },
        Stmt::Assign(
            "s".into(),
            Expr::Mul(
                Box::new(Expr::Var("t".into())),
                Box::new(Expr::Var("v".into())),
            ),
        ),
    ];
    let mut st: State<Const> = State::new();
    exec_const(&program, &mut st);
    println!("t := 0");
    println!("if ... then v := 10 else v := 20");
    println!("s := t * v");
    println!();
    println!("t = {}", st["t"]);
    println!("v = {}  (10 ⊔ 20)", st["v"]);
    println!("s = {}  (0 * ⊤ = 0)", st["s"]);
    println!("zero times anything is zero, even when the other operand is unknown");
}
