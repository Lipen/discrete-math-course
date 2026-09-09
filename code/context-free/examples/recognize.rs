//! CYK membership over a batch of words.
//!
//! The grammar is the balanced-parentheses language `S -> ( S ) S | ε`.
//! The grammar is converted to Chomsky normal form once, then CYK decides
//! each word: the start symbol must derive the whole word.
//!
//! Run with `cargo run --example recognize`.

use context_free::{nt, recognize, t, to_cnf, Grammar, Production, Symbol};

fn body_to_string(body: &[Symbol]) -> String {
    if body.is_empty() {
        "ε".to_string()
    } else {
        body.iter()
            .map(|s| s.to_string())
            .collect::<Vec<_>>()
            .join(" ")
    }
}

fn main() {
    let g = Grammar::new(
        "S",
        vec![
            Production::new("S", vec![t("("), nt("S"), t(")"), nt("S")]),
            Production::new("S", vec![]),
        ],
    );

    println!("Grammar (balanced parentheses):");
    for p in &g.productions {
        println!("  {} -> {}", p.head, body_to_string(&p.body));
    }
    println!();

    // CYK needs Chomsky normal form, so convert once and reuse.
    let cnf = to_cnf(&g);
    println!(
        "Chomsky normal form: {} productions, same language",
        cnf.productions.len()
    );

    println!("Membership per word:");
    let words = [
        "", "()", "(())", "()()", "(()())", "((()))", "(", ")", ")(", "(()", "())",
    ];
    let mut accepted = 0;
    for w in words {
        let ok = recognize(&cnf, w);
        if ok {
            accepted += 1;
        }
        println!(
            "  {:<8} {}",
            if w.is_empty() { "ε" } else { w },
            if ok { "accept" } else { "reject" }
        );
    }
    println!();
    println!("{} of {} words are balanced", accepted, words.len());
}
