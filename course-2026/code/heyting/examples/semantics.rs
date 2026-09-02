//! Semantics of intuitionistic logic: posets, downset algebras and validity.
//!
//! (a) Builds the downset algebra of a three-element poset (a "V": `a < b` and `a < c`) and prints its elements and implication table.
//! (b) Evaluates the law of excluded middle `p ∨ ¬p` and double-negation elimination `¬¬p -> p` over all valuations in that algebra.
//! (c) Checks the validity of several formulas over the small enumeration of finite Heyting algebras (all up to 5 elements, see `all_finite_heyting_algebras`).

use heyting::{all_finite_heyting_algebras, all_valuations, valid, Formula, Poset};

fn main() {
    // (a) The downset algebra of the poset a < b, a < c.
    let poset = Poset::from_relations(3, &[(0, 1), (0, 2)]);
    println!("poset: 0 < 1 and 0 < 2");
    println!("downsets (order ideals): {:?}", poset.downsets());

    let a = poset.downset_algebra();
    println!("downset algebra of {} elements:", a.size());
    for i in 0..a.size() {
        println!("  {i}: {}", a.labels[i]);
    }

    println!("\nimplication table A -> B:");
    print!("      ");
    for j in 0..a.size() {
        print!("  {:>7}", a.labels[j]);
    }
    println!();
    for i in 0..a.size() {
        print!("{:>5} ", a.labels[i]);
        for j in 0..a.size() {
            print!("  {:>7}", a.labels[a.implies(i, j)]);
        }
        println!();
    }

    // (b) Excluded middle and double-negation elimination over all valuations.
    let p = Formula::atom(0);
    let lem = p.clone().or(!p.clone());
    let dne = (!(!p.clone())).implies(p.clone());

    println!("\nformula p ∨ ¬p over all valuations (element names):");
    for v in all_valuations(1, a.size()) {
        let r = lem.eval(&a, &v);
        println!("  p = {:>5}: p ∨ ¬p = {:>5}", a.labels[v[0]], a.labels[r]);
    }
    println!("\nformula ¬¬p -> p over all valuations (element names):");
    for v in all_valuations(1, a.size()) {
        let r = dne.eval(&a, &v);
        println!("  p = {:>5}: ¬¬p -> p = {:>5}", a.labels[v[0]], a.labels[r]);
    }

    // (c) Validity over the small enumeration of finite Heyting algebras.
    let algebras = all_finite_heyting_algebras();
    let mut by_size = std::collections::BTreeMap::new();
    for al in algebras {
        *by_size.entry(al.size()).or_insert(0usize) += 1;
    }
    println!("\nvalidation collection: {} algebras", algebras.len());
    println!("  counts by size: {:?}", by_size);

    let q = Formula::atom(1);
    let check = |name: &str, f: &Formula| {
        let verdict = if valid(f) { "VALID  " } else { "INVALID" };
        println!("  {name}: {verdict}");
    };
    check(
        "p -> (q -> p)          ",
        &p.clone().implies(q.clone().implies(p.clone())),
    );
    check("p -> ¬¬p               ", &p.clone().implies(!(!p.clone())));
    check("¬¬p -> p               ", &dne);
    check("p ∨ ¬p                 ", &lem);
    check(
        "((p -> q) -> p) -> p   ",
        &(p.clone().implies(q.clone()).implies(p.clone())).implies(p.clone()),
    );
}
