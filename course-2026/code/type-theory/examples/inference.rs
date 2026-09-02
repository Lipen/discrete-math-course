//! Type inference on untyped terms via unification.
//!
//! Terms carry no annotations.
//! The inferencer assigns a fresh metavariable to each binder and unifies the constraints of the var/app/abs rules.
//! A metavariable left unbound at the end generalizes to a schematic variable `a`, `b`, ... -- so the identity infers as `a -> a`, the scheme σ -> σ.

use type_theory::ty::Type;
use type_theory::{infer, Term};

fn main() {
    // -- Identity: λx. x : a -> a ==============================================
    let id = Term::abs("x", Term::var("x"));
    println!("λx. x            → {}", infer(&id).unwrap());
    println!();

    // -- K combinator: λx. λy. x : a -> b -> a =================================
    let k = Term::abs("x", Term::abs("y", Term::var("x")));
    println!("λx. λy. x        → {}", infer(&k).unwrap());
    println!("  (the scheme σ -> τ -> σ)");
    println!();

    // -- S combinator: λx. λy. λz. x z (y z) ===================================
    let x = Term::var("x");
    let y = Term::var("y");
    let z = Term::var("z");
    let s = Term::abs(
        "x",
        Term::abs(
            "y",
            Term::abs("z", Term::app(Term::app(x, z.clone()), Term::app(y, z))),
        ),
    );
    println!("λx. λy. λz. x z (y z)");
    println!("             → {}", infer(&s).unwrap());
    println!("  (the second axiom of Hilbert's calculus)");
    println!();

    // -- Church numeral 2: λf. λx. f (f x) : (a -> a) -> a -> a ================
    let f = Term::var("f");
    let x = Term::var("x");
    let two = Term::abs("f", Term::abs("x", Term::app(f.clone(), Term::app(f, x))));
    let ty = infer(&two).unwrap();
    println!("λf. λx. f (f x)  → {}", ty);
    // With base type Nat it reads (Nat -> Nat) -> Nat -> Nat.
    println!(
        "  (on Nat:      → {})",
        Type::arrow(
            Type::arrow(Type::nat(), Type::nat()),
            Type::arrow(Type::nat(), Type::nat()),
        )
    );
    println!();

    // -- Self-application ω = λx. x x is rejected ==============================
    let omega = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
    match infer(&omega) {
        Ok(t) => println!("λx. x x          → unexpectedly typed as {t}"),
        Err(e) => println!("λx. x x          → REJECTED -- {e}"),
    }
    println!("  (would need σ = σ -> τ, and the occurs check finds no finite type)");

    // -- Ω = (λx. x x)(λx. x x) is rejected too ================================
    let self_app = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
    let big_omega = Term::app(self_app.clone(), self_app);
    match infer(&big_omega) {
        Ok(t) => println!("Ω                 → unexpectedly typed as {t}"),
        Err(e) => println!("Ω                 → REJECTED -- {e}"),
    }
    println!();

    // -- A concrete constraint from the context ================================
    // (λx. x) a with a : Nat forces x : Nat, so the application is Nat.
    let app = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
    let ctx = type_theory::Context::new().extend("a", Type::nat());
    println!(
        "(λx. x) a, a:Nat → {}",
        type_theory::infer_in(&app, &ctx).unwrap()
    );
}
