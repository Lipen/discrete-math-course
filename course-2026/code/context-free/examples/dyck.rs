//! The Dyck language (balanced parentheses) and its ambiguity.
//!
//! `S -> ( S ) S | ε` is unambiguous: every word has exactly one parse tree.
//! The naive variant `S -> S S | (S) | ε` is ambiguous, and its shortest
//! ambiguous word is `()()()` -- two groupings of three pairs.

use context_free::{
    all_parse_trees, ambiguous_word, count_trees, is_unambiguous, nt, t, Grammar, Production,
};

fn show_trees(grammar: &Grammar, word: &str) {
    let tokens = grammar.lex(word).unwrap();
    let trees = all_parse_trees(grammar, &tokens).expect("finite number of parse trees");
    println!("word {word}: {} parse tree(s)", trees.len());
    for (i, tree) in trees.iter().enumerate() {
        println!("  tree {}: {tree}", i + 1);
        let der = tree.leftmost_derivation();
        let steps: Vec<String> = der
            .iter()
            .map(|f| {
                f.iter()
                    .map(|s| s.to_string())
                    .collect::<Vec<_>>()
                    .join(" ")
            })
            .collect();
        println!("    leftmost:   {}", steps.join("  =>  "));
    }
}

fn main() {
    // The correct grammar for balanced parentheses.
    let dyck = Grammar::new(
        "S",
        vec![
            Production::new("S", vec![t("("), nt("S"), t(")"), nt("S")]),
            Production::new("S", vec![]),
        ],
    );
    println!("Grammar  S -> ( S ) S | ε  (Dyck language)");
    println!();

    for w in ["", "()", "(())", "()()", "(())()"] {
        show_trees(&dyck, w);
    }
    println!(
        "rejects: )(  ->  {}",
        if context_free::in_language(&dyck, ")(") {
            "accepted (ERROR)"
        } else {
            "rejected"
        }
    );
    println!();

    // Certificate of unambiguity up to length 8.
    println!(
        "Unambiguous up to 8 terminals?  {}",
        is_unambiguous(&dyck, 8)
    );
    println!();

    // The naive grammar: S -> S S | (S) | ε. Its shortest ambiguous word is
    // ()()(), with the two groupings () | ()() and ()() | ().
    let naive = Grammar::new(
        "S",
        vec![
            Production::new("S", vec![nt("S"), nt("S")]),
            Production::new("S", vec![t("("), nt("S"), t(")")]),
            Production::new("S", vec![]),
        ],
    );
    println!("Grammar  S -> S S | (S) | ε  (naive Dyck)");
    let witness = ambiguous_word(&naive, 6).expect("naive Dyck is ambiguous");
    println!("shortest ambiguous word: {witness}");
    let tokens = naive.lex(&witness).unwrap();
    println!(
        "parse trees for {witness}: {}",
        count_trees(&naive, &tokens).unwrap()
    );
    // The raw grammar has an epsilon-cycle (S -> SS together with S -> ε), so
    // enumerate the trees after epsilon-elimination, exactly as `count_trees`
    // does. The two trees are the groupings () | ()() and ()() | ().
    let ef = naive.eliminate_epsilon().remove_unit_productions();
    for tree in all_parse_trees(&ef, &tokens).unwrap() {
        println!("  {tree}");
    }
}
