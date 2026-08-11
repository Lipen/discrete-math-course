//! Step-by-step beta-reduction trace.
//!
//! Demonstrates how to inspect each reduction step, showing the term
//! before and after each beta-contraction.

use lambda::{church, Term};

fn main() {
    // (λx. λy. y x) (λz. z) a  -- a term with nested redexes
    let body = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
    let fun = Term::abs("x", body);
    let id = Term::abs("z", Term::var("z"));
    let term = Term::app(Term::app(fun, id), Term::var("a"));

    println!("Starting term:  {}", term);
    println!();

    let trace = term.trace(20);
    for (i, step) in trace.iter().enumerate() {
        if i == 0 {
            continue;
        }
        println!("After step {}:  {}", i, step);
    }
    println!();
    let final_term = trace.last().unwrap();
    println!("Normal form:  {}", final_term);
    assert!(final_term.is_normal_form());

    // -- A non-terminating term with a step limit ----------------------------
    println!();
    println!("--- Non-terminating example ---");

    // (λx. x x) (λx. x x)  -- the Ω combinator
    let self_app = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
    let omega = Term::app(self_app.clone(), self_app);
    println!("Ω = {}", omega);

    let omega_trace = omega.trace(5);
    println!("Ω after {} steps:", omega_trace.len() - 1);
    for (i, step) in omega_trace.iter().enumerate() {
        println!("  step {}: {}", i, step);
    }
    println!(
        "Still in normal form?  {}",
        omega_trace.last().unwrap().is_normal_form()
    );

    // -- Church arithmetic with trace ----------------------------------------
    println!();
    println!("--- Church succ 2 with trace ---");

    let c2 = church(2);
    let succ_term = Term::app(lambda::succ(), c2);
    println!("Starting:  {}", succ_term);

    let succ_trace = succ_term.trace(10);
    for (i, step) in succ_trace.iter().enumerate() {
        if i == 0 {
            continue;
        }
        println!("  step {}: {}", i, step);
    }
    println!(
        "Result as nat: {}",
        lambda::church::to_nat(succ_trace.last().unwrap()).unwrap()
    );
}
