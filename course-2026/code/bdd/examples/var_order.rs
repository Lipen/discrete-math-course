//! How variable ordering affects BDD size.
//!
//! The function `(x0 ∧ x1) ∨ (x2 ∧ x3)` is built with two different variable
//! orders and the resulting node counts are compared. With the natural order
//! `[0, 1, 2, 3]` the BDD is compact; an interleaved order `[0, 2, 1, 3]`
//! forces the diagram to duplicate subgraphs.

use bdd::Bdd;

fn main() {
    let f_components = |bdd: &mut Bdd, a: u32, b: u32, c: u32, d: u32| {
        let xa = bdd.var(a);
        let xb = bdd.var(b);
        let xc = bdd.var(c);
        let xd = bdd.var(d);
        let left = bdd.and(xa, xb);
        let right = bdd.and(xc, xd);
        bdd.or(left, right)
    };

    // Natural order: variables appear in the same order as in the formula.
    let mut bdd1 = Bdd::new();
    let f1 = f_components(&mut bdd1, 0, 1, 2, 3);
    println!(
        "Order [0, 1, 2, 3]: {} node(s) for (x0 ∧ x1) ∨ (x2 ∧ x3)",
        bdd1.size()
    );
    println!("  sat_count = {}", bdd1.sat_count(f1, 4));

    // Interleaved order: grouping related variables is harder for the BDD.
    let mut bdd2 = Bdd::new();
    let f2 = f_components(&mut bdd2, 0, 2, 1, 3);
    println!(
        "Order [0, 2, 1, 3]: {} node(s) for (x0 ∧ x2) ∨ (x1 ∧ x3)",
        bdd2.size()
    );
    println!("  sat_count = {}", bdd2.sat_count(f2, 4));

    // The functions are different syntactically, but both represent the same
    // kind of formula (a disjunction of two conjunctions). The point is that
    // variable ordering matters: the same logical function can have a much
    // larger BDD under an unfortunate ordering.

    // A more dramatic example: building the same function under two orders
    // by renaming variables back.
    println!("\n-- Same function, different orders --");
    let mut bdd_a = Bdd::new();
    let fa = {
        let x0 = bdd_a.var(0);
        let x1 = bdd_a.var(1);
        let x2 = bdd_a.var(2);
        let x3 = bdd_a.var(3);
        let left = bdd_a.and(x0, x1);
        let right = bdd_a.and(x2, x3);
        bdd_a.or(left, right)
    };
    println!("Interleaved [0,1,2,3]: {} node(s)", bdd_a.size());
    println!("  sat_count = {}", bdd_a.sat_count(fa, 4));

    let mut bdd_b = Bdd::new();
    let fb = {
        // Same function but with interleaved variable order:
        // map [0->0, 1->2, 2->1, 3->3], i.e. (x0 ∧ x2) ∨ (x1 ∧ x3).
        let x0 = bdd_b.var(0);
        let x1 = bdd_b.var(1);
        let x2 = bdd_b.var(2);
        let x3 = bdd_b.var(3);
        let left = bdd_b.and(x0, x2);
        let right = bdd_b.and(x1, x3);
        bdd_b.or(left, right)
    };
    println!("Sequential [0,2,1,3]: {} node(s)", bdd_b.size());
    println!("  sat_count = {}", bdd_b.sat_count(fb, 4));
}
