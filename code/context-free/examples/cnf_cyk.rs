//! Chomsky normal form and the CYK algorithm.
//!
//! `S -> a S b | ε` (the language `a^n b^n`) is converted to Chomsky normal
//! form, then CYK fills a triangular table of nonterminals per substring and
//! decides membership.

use context_free::{nt, recognize, t, table, to_cnf, Grammar, Production};

fn main() {
    let g = Grammar::new(
        "S",
        vec![
            Production::new("S", vec![t("a"), nt("S"), t("b")]),
            Production::new("S", vec![]),
        ],
    );
    println!("Original grammar:");
    println!("  S -> a S b");
    println!("  S -> ε");
    println!();

    let cnf = to_cnf(&g);
    println!("Chomsky normal form:");
    for p in &cnf.productions {
        let body = if p.body.is_empty() {
            "ε".to_string()
        } else {
            p.body
                .iter()
                .map(|s| s.to_string())
                .collect::<Vec<_>>()
                .join(" ")
        };
        println!("  {} -> {}", p.head, body);
    }
    println!();

    // Membership on a few words.
    println!("recognition (CYK):");
    for w in ["", "ab", "aabb", "aaabbb", "abab", "aab", "abb", "ba"] {
        println!(
            "  {w:<8} {}",
            if recognize(&cnf, w) {
                "accept"
            } else {
                "reject"
            }
        );
    }
    println!();

    // The CYK table for "aabb".
    let tokens = cnf.lex("aabb").unwrap();
    let t = table(&cnf, &tokens);
    println!("CYK table for aabb (t[i][l] = nonterminals deriving word[i..i+l]):");
    for (i, row) in t.iter().enumerate() {
        let cells: Vec<String> = row
            .iter()
            .skip(1)
            .take(tokens.len() - i)
            .map(|set| {
                if set.is_empty() {
                    "-".to_string()
                } else {
                    let mut v: Vec<&String> = set.iter().collect();
                    v.sort();
                    v.iter().map(|s| s.as_str()).collect::<Vec<_>>().join(",")
                }
            })
            .map(|c| format!("{c:>8}"))
            .collect();
        println!("  i={i}  {}", cells.join(" "));
    }
    println!();
    println!(
        "start symbol reaches the whole word: {}",
        t[0][tokens.len()].contains("S")
    );
}
