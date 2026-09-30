//! Visualizing a BDD: DOT rendering, an indented tree dump, and the plain
//! complement-free form.
//!
//! The example builds x0 XOR x1, which exercises a complemented root edge
//! (the stored node is the negation), a complemented child edge, and a
//! shared subgraph (both branches of x0 reach the same x1 node).

use bdd::Bdd;
use std::fs;

fn main() {
    let mut bdd = Bdd::new();
    let x = bdd.var(0);
    let y = bdd.var(1);
    // x0 XOR x1 = ite(x0, NOT x1, x1): true exactly when x0 != x1. The
    // returned edge is complemented (the stored node is its negation), so
    // this small function exercises a complemented root edge, a complemented
    // child edge, and a shared subgraph all at once.
    let f = bdd.xor(x, y);

    println!("BDD size: {} node(s) (including the constant).", bdd.size());

    // Indented tree dump: a node reached a second time is printed once with
    // a `*` instead of being duplicated, and complemented edges show a `~`.
    println!("\nTree dump (shared nodes marked with *):");
    println!("{}", bdd.to_tree_string(f));

    // DOT rendering, written to a temp file (per crate convention).
    let dot = bdd.to_dot(f);
    let path = std::env::temp_dir().join("bdd_xnor.dot");
    fs::write(&path, &dot).expect("write dot file");
    println!("DOT written to: {}", path.display());
    println!("\nDOT source:\n{dot}");

    // Plain complement-free form: negation is materialized as real nodes.
    let plain = bdd.to_plain(f);
    println!(
        "\nPlain (complement-free) conversion, {} node(s):",
        plain.nodes.len()
    );
    for (i, n) in plain.nodes.iter().enumerate() {
        let kind = if i == 0 {
            "FALSE"
        } else if i == 1 {
            "TRUE"
        } else {
            "node"
        };
        let vs = if i <= 1 {
            "-".to_string()
        } else {
            n.var.to_string()
        };
        println!("  [{i}] {kind:5} var={vs:>2} lo={} hi={}", n.lo, n.hi);
    }
    println!("  root -> {}", plain.root);
}
