//! Subject reduction: a typed term β-reduces preserving its type.
//!
//! If `Γ ⊢ M : σ` and `M →β M'`, then `Γ ⊢ M' : σ`.
//! The type is a static property -- it is fixed before execution and survives every step of the computation.
//!
//! The demo checks the detour term `M = (λf:A→A. λx:A. f x)(λx:A. x)` of type `A → A`, reduces it to normal form *keeping the annotations*, and checks again.
//! The type does not change.

use type_theory::checker::STerm;
use type_theory::ty::Type;

fn main() {
    let a = Type::base("A");
    let f = STerm::var("f");
    let x = STerm::var("x");

    // M0 = λf:A→A. λx:A. f x    (the "apply f to x" function)
    let m0 = STerm::abs(
        "f",
        Type::arrow(a.clone(), a.clone()),
        STerm::abs("x", a.clone(), STerm::app(f, x.clone())),
    );
    // id = λx:A. x
    let id = STerm::abs("x", a.clone(), STerm::var("x"));
    // M = M0 id
    let app = STerm::app(m0, id);

    let expected = Type::arrow(a.clone(), a.clone());
    println!("M            = {}", app);
    println!("⊢ M :        = {}", app.type_of().unwrap());
    assert_eq!(app.type_of().unwrap(), expected, "M must have type A -> A");
    println!();
    println!("== Reducing step by step (annotations kept) ==");

    let mut current = app.clone();
    let mut step = 0;
    while let Some(next) = current.beta_reduce() {
        step += 1;
        println!("  step {step}: {}", current);
        println!("         →β {}", next);
        let before = current.type_of().unwrap();
        let after = next.type_of().unwrap();
        println!("         type   {}  →  {}", before, after);
        assert_eq!(before, after, "subject reduction violated at step {step}");
        current = next;
    }

    println!();
    println!("normal form  = {}", current);
    println!("  ⊢         = {}", current.type_of().unwrap());
    assert_eq!(current.type_of().unwrap(), expected);
    assert!(current.is_normal_form());
    println!();
    println!("The type A -> A was preserved at every β-step: subject reduction.");
}
