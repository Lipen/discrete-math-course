//! How variable ordering affects ROBDD size.
//!
//! The crate fixes the variable order by index: `var(i)` is tested before
//! `var(j)` whenever `i < j`. To see the same function under two different
//! orders, build it once with its paired variables consecutive and once with
//! them scattered.
//!
//! The function is `(a ∧ b) ∨ (c ∧ d)`. Under the natural order `[a, b, c, d]`
//! each conjunction lines up with the order and the diagram stays compact.
//! Under the interleaved order `[a, c, b, d]` a conjunction must remember its
//! first variable while the other is still undecided, so the diagram grows.

use bdd::Bdd;

fn main() {
    // Natural order: `a` and `b` (also `c` and `d`) are consecutive.
    let mut natural = Bdd::new();
    let (a, b, c, d) = (
        natural.var(0),
        natural.var(1),
        natural.var(2),
        natural.var(3),
    );
    let ab = natural.and(a, b);
    let cd = natural.and(c, d);
    let f_natural = natural.or(ab, cd);
    println!(
        "Order [a, b, c, d]: {} node(s) for (x0 ∧ x1) ∨ (x2 ∧ x3)",
        natural.size()
    );
    println!("  sat_count = {}", natural.sat_count(f_natural, 4));

    // Interleaved order: rename `b` and `c` so that paired variables are no
    // longer adjacent. This is the same function, only the indices (and thus
    // the test order) differ.
    let mut interleaved = Bdd::new();
    let (a, c, b, d) = (
        interleaved.var(0),
        interleaved.var(1),
        interleaved.var(2),
        interleaved.var(3),
    );
    let ab = interleaved.and(a, b);
    let cd = interleaved.and(c, d);
    let f_interleaved = interleaved.or(ab, cd);
    println!(
        "Order [a, c, b, d]: {} node(s) for (x0 ∧ x2) ∨ (x1 ∧ x3)",
        interleaved.size()
    );
    println!("  sat_count = {}", interleaved.sat_count(f_interleaved, 4));

    // Both formulas have the same number of models (7 of 16 assignments) --
    // they are the same function up to the variable rename -- but the
    // interleaved order costs an extra node. With more conjunctions this gap
    // grows exponentially, which is why variable ordering matters.
}
