//! η-reduction: dropping a binder that only forwards its argument.
//!
//! `λx. f x` computes the same function as `f`, so η-reduction replaces the
//! wrapper by `f`. When the bound variable is used, no η-step is possible.

use lambda::Term;

fn main() {
    let f = Term::var("f");
    let fresh = Term::abs("x", Term::app(f, Term::var("x")));
    println!("term: {fresh}");
    println!("eta:  {:?}", fresh.eta_reduce().map(|t| t.to_string()));

    let used = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
    println!("term: {used}");
    println!("eta:  {:?}", used.eta_reduce().map(|t| t.to_string()));
}
