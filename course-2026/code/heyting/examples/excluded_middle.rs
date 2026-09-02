//! Where the law of excluded middle fails.
//!
//! Classically `p ∨ ¬p` is always true.
//! In the three-element Heyting algebra the middle element 1/2 is "not yet constructed": neither 1/2 nor its negation is true, so `p ∨ ¬p = 1/2 ≠ 1`.
//! Double-negation elimination `¬¬p -> p` fails at the same element.

use heyting::Value;

fn main() {
    println!("p ∨ ¬p  (law of excluded middle)");
    for p in [Value::Bot, Value::Mid, Value::Top] {
        let lem = p.join(!p);
        let verdict = if lem == Value::Top { "holds" } else { "FAILS" };
        println!("  p = {p:?}: p ∨ ¬p = {lem:?}   {verdict}");
    }

    println!("\n¬¬p -> p  (double-negation elimination)");
    for p in [Value::Bot, Value::Mid, Value::Top] {
        let dne = (!(!p)).implies(p);
        let verdict = if dne == Value::Top { "holds" } else { "FAILS" };
        println!("  p = {p:?}: ¬¬p -> p = {dne:?}   {verdict}");
    }
}
