//! Operator precedence and ambiguity.
//!
//! `E -> E + E | E * E | (E) | id` is ambiguous: `id+id*id` has two parse
//! trees, `(id + id) * id` and `id + (id * id)`. Dividing into precedence
//! levels (`E -> E + T | T`, `T -> T * F | F`, `F -> (E) | id`) makes the tree
//! unique. Division is ambiguous even at a single precedence level, and the
//! two groupings of `8/4/2` give different values.

use context_free::{all_parse_trees, count_trees, is_unambiguous, nt, t, Grammar, Production};

fn show_trees(grammar: &Grammar, word: &str) {
    let tokens = grammar.lex(word).unwrap();
    let trees = all_parse_trees(grammar, &tokens).expect("finite number of parse trees");
    println!("word {word}: {} parse tree(s)", trees.len());
    for tree in &trees {
        println!("  {}", tree.parenthesized());
    }
}

fn main() {
    // Ambiguous arithmetic.
    let amb = Grammar::new(
        "E",
        vec![
            Production::new("E", vec![nt("E"), t("+"), nt("E")]),
            Production::new("E", vec![nt("E"), t("*"), nt("E")]),
            Production::new("E", vec![t("("), nt("E"), t(")")]),
            Production::new("E", vec![t("id")]),
        ],
    );
    println!("Grammar  E -> E + E | E * E | (E) | id  (ambiguous)");
    show_trees(&amb, "id+id*id");
    println!();

    // Disambiguated by precedence levels.
    let disamb = Grammar::new(
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
    println!("Grammar  E -> E + T | T, T -> T * F | F, F -> (E) | id  (unambiguous)");
    show_trees(&disamb, "id+id*id");
    println!(
        "Unambiguous up to 6 terminals?  {}",
        is_unambiguous(&disamb, 6)
    );
    println!();

    // One operator, one level: division is still ambiguous.
    let div = Grammar::new(
        "E",
        vec![
            Production::new("E", vec![nt("E"), t("/"), nt("E")]),
            Production::new("E", vec![t("8")]),
            Production::new("E", vec![t("4")]),
            Production::new("E", vec![t("2")]),
        ],
    );
    println!("Grammar  E -> E / E | 8 | 4 | 2  (ambiguous)");
    let tokens = div.lex("8/4/2").unwrap();
    println!(
        "word 8/4/2: {} parse tree(s)",
        count_trees(&div, &tokens).unwrap()
    );
    for tree in all_parse_trees(&div, &tokens).unwrap() {
        println!("  {}", tree.parenthesized());
    }
    println!("  values: (8/4)/2 = 1, 8/(4/2) = 4 -- grouping changes the result");
}
