//! Parse trees: every reading of a word.
//!
//! A parse tree records which production applies at each node, and
//! `all_parse_trees` enumerates every tree of a word over the grammar as
//! written. Ambiguity becomes visible: the same word, several trees.
//!
//! Run with `cargo run --example parse_tree`.

use context_free::{all_parse_trees, nt, t, Grammar, Production, Symbol};

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

fn print_grammar(title: &str, g: &Grammar) {
    println!("{title}:");
    for p in &g.productions {
        println!("  {} -> {}", p.head, body_to_string(&p.body));
    }
    println!();
}

fn main() {
    // Does + or * bind tighter? This grammar does not say, so a word with
    // both operators has several readings.
    let ambiguous = Grammar::new(
        "E",
        vec![
            Production::new("E", vec![nt("E"), t("+"), nt("E")]),
            Production::new("E", vec![nt("E"), t("*"), nt("E")]),
            Production::new("E", vec![t("("), nt("E"), t(")")]),
            Production::new("E", vec![t("id")]),
        ],
    );
    print_grammar(
        "Ambiguous grammar E -> E + E | E * E | ( E ) | id",
        &ambiguous,
    );

    let tokens = ambiguous.lex("id+id*id").unwrap();
    let trees = all_parse_trees(&ambiguous, &tokens).unwrap();
    println!("word id+id*id has {} parse trees:", trees.len());
    for tree in &trees {
        println!("  tree:     {}", tree);
        println!("  grouping: {}", tree.parenthesized());
    }
    println!();

    // The textbook fix: a precedence ladder E, T, F where * binds tighter.
    let unambiguous = Grammar::new(
        "E",
        vec![
            Production::new("E", vec![nt("E"), t("+"), nt("T")]),
            Production::new("E", vec![nt("T")]),
            Production::new("T", vec![nt("T"), t("*"), nt("F")]),
            Production::new("T", vec![nt("F")]),
            Production::new("F", vec![t("("), nt("E"), t(")")]),
            Production::new("F", vec![t("id")]),
        ],
    );
    print_grammar(
        "Unambiguous grammar with the usual precedence",
        &unambiguous,
    );

    let tokens = unambiguous.lex("id+id*id").unwrap();
    let trees = all_parse_trees(&unambiguous, &tokens).unwrap();
    println!("word id+id*id has {} parse tree(s):", trees.len());
    let tree = &trees[0];
    println!("  grouping: {}", tree.parenthesized());
    println!("  leftmost derivation:");
    for form in tree.leftmost_derivation() {
        println!("    {}", body_to_string(&form));
    }
    println!();

    // A word outside the language has no tree at all.
    let tokens = unambiguous.lex("id+*id").unwrap();
    let trees = all_parse_trees(&unambiguous, &tokens).unwrap();
    println!(
        "word id+*id has {} parse trees: not in the language",
        trees.len()
    );
}
