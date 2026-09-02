//! Typing well-typed and ill-typed terms with the three rules of λ→.
//!
//! Each term carries its binder annotations (`λx:σ. M`) and is checked by the var/app/abs rules in [`STerm::check`].
//! Well-typed terms get their type, and ill-typed terms are rejected with the reason.
//! This is the *checking* side: a term is correctly typed exactly when a typing tree exists.

use type_theory::checker::STerm;
use type_theory::ty::{Context, Type};

fn main() {
    let nat = Type::nat();
    let boolean = Type::boolean();

    // -- Identity: λx:σ. x : σ -> σ ============================================
    let id_nat = STerm::abs("x", nat.clone(), STerm::var("x"));
    let id_bool = STerm::abs("x", boolean.clone(), STerm::var("x"));
    println!("identity         : {}", id_nat);
    println!("  ⊢             : {}", id_nat.type_of().unwrap());
    println!("  (on Bool)     : {}", id_bool.type_of().unwrap());
    println!();

    // -- Projection / K combinator: λx:σ. λy:τ. x : σ -> τ -> σ ================
    let k = STerm::abs(
        "x",
        nat.clone(),
        STerm::abs("y", boolean.clone(), STerm::var("x")),
    );
    println!("K-combinator    : {}", k);
    println!("  ⊢             : {}", k.type_of().unwrap());
    println!("  (reads as A -> B -> A, an axiom of minimal logic)");
    println!();

    // -- A Church numeral on Nat: 2 = λf:Nat->Nat. λx:Nat. f (f x) ============
    let f = STerm::var("f");
    let x = STerm::var("x");
    let two = STerm::abs(
        "f",
        Type::arrow(nat.clone(), nat.clone()),
        STerm::abs("x", nat.clone(), STerm::app(f.clone(), STerm::app(f, x))),
    );
    println!("church 2        : {}", two);
    println!("  ⊢             : {}", two.type_of().unwrap());
    println!("  (typed on the base type Nat)");
    // Apply 2 to a function f : Nat -> Nat and a value x : Nat, and each of the two applications keeps the type Nat -> Nat, so 2 f x : Nat.
    let ctx_app = Context::new()
        .extend("f", Type::arrow(nat.clone(), nat.clone()))
        .extend("x", nat.clone());
    let twin = STerm::app(STerm::app(two, STerm::var("f")), STerm::var("x"));
    println!("  2 f x        : {}", twin.check(&ctx_app).unwrap());
    println!();

    // -- Composition: λf:B->C. λg:A->B. λx:A. g (f x) =========================
    let a = Type::base("A");
    let b = Type::base("B");
    let c = Type::base("C");
    let fv = STerm::var("f");
    let gv = STerm::var("g");
    let xv = STerm::var("x");
    let comp = STerm::abs(
        "f",
        Type::arrow(a.clone(), b.clone()),
        STerm::abs(
            "g",
            Type::arrow(b.clone(), c.clone()),
            STerm::abs("x", a.clone(), STerm::app(gv.clone(), STerm::app(fv, xv))),
        ),
    );
    println!("composition     : {}", comp);
    println!("  ⊢             : {}", comp.type_of().unwrap());
    println!("  (transitivity of implication)");
    println!();

    // -- Ill-typed terms =======================================================
    println!("== Ill-typed ==");

    // λx:Nat. x x -- x would need to be both Nat and a function.
    let bad = STerm::abs(
        "x",
        nat.clone(),
        STerm::app(STerm::var("x"), STerm::var("x")),
    );
    match bad.type_of() {
        Ok(t) => println!("λx:Nat. x x     : unexpectedly typed as {t}"),
        Err(e) => println!("λx:Nat. x x     : REJECTED -- {e}"),
    }

    // (λx:Nat. x) a with a : Bool -- the argument type must match the domain.
    let id = STerm::abs("x", nat, STerm::var("x"));
    let app = STerm::app(id, STerm::var("a"));
    let ctx = Context::new().extend("a", boolean);
    match app.check(&ctx) {
        Ok(t) => println!("(λx:Nat. x) a   : unexpectedly typed as {t}"),
        Err(e) => println!("(λx:Nat. x) a   : REJECTED with a : Bool -- {e}"),
    }

    // A free variable with no assumption.
    let unbound = STerm::app(
        STerm::abs("x", Type::nat(), STerm::var("x")),
        STerm::var("free"),
    );
    match unbound.type_of() {
        Ok(t) => println!("(λx:Nat. x) free : unexpectedly typed as {t}"),
        Err(e) => println!("(λx:Nat. x) free : REJECTED -- {e}"),
    }
}
