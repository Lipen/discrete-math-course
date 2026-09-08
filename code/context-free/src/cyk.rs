//! The Cocke-Younger-Kasami (CYK) algorithm.
//!
//! CYK recognizes a word against a grammar in Chomsky normal form in
//! `O(n^3)`. It fills a triangular table `t[i][l]` with the set of
//! nonterminals that derive the substring `word[i..i+l]`.

use std::collections::HashSet;

use crate::grammar::{Grammar, Symbol};

/// The CYK table: `t[i][l]` holds the nonterminals that derive the substring
/// `word[i..i+l]`. Requires a grammar in Chomsky normal form (see
/// [`crate::to_cnf`]).
pub fn table(grammar: &Grammar, word: &[String]) -> Vec<Vec<HashSet<String>>> {
    let n = word.len();
    let mut t: Vec<Vec<HashSet<String>>> = vec![vec![HashSet::new(); n + 1]; n];

    // Length 1: A -> a.
    for i in 0..n {
        for p in &grammar.productions {
            if p.body.len() == 1 {
                if let Symbol::Terminal(a) = &p.body[0] {
                    if &word[i] == a {
                        t[i][1].insert(p.head.clone());
                    }
                }
            }
        }
    }

    // Lengths >= 2: A -> B C.
    for l in 2..=n {
        for i in 0..=(n - l) {
            for p in &grammar.productions {
                if p.body.len() == 2 {
                    let (b, c) = (&p.body[0], &p.body[1]);
                    if let (Symbol::Nonterminal(bn), Symbol::Nonterminal(cn)) = (b, c) {
                        for k in 1..l {
                            if t[i][k].contains(bn) && t[i + k][l - k].contains(cn) {
                                t[i][l].insert(p.head.clone());
                            }
                        }
                    }
                }
            }
        }
    }

    t
}

/// Is `word` in the language of `grammar` (assumed to be in Chomsky normal
/// form)?
pub fn recognize(grammar: &Grammar, word: &str) -> bool {
    let tokens = match grammar.lex(word) {
        Some(t) => t,
        None => return false,
    };
    if tokens.is_empty() {
        return grammar
            .productions
            .iter()
            .any(|p| p.head == grammar.start && p.body.is_empty());
    }
    let t = table(grammar, &tokens);
    t[0][tokens.len()].contains(&grammar.start)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cnf::to_cnf;
    use crate::grammar::{nt, t, Production};

    #[test]
    fn cyk_table_for_aabb() {
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("a"), nt("S"), t("b")]),
                Production::new("S", vec![]),
            ],
        );
        let cnf = to_cnf(&g);
        let tokens = cnf.lex("aabb").unwrap();
        let t = table(&cnf, &tokens);
        // The whole word (length 4) derives the start symbol.
        assert!(t[0][4].contains("S"));
        // The middle "ab" (positions 1..3) also derives S.
        assert!(t[1][2].contains("S"));
    }

    #[test]
    fn recognizes_a_n_b_n_and_rejects_mixed() {
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("a"), nt("S"), t("b")]),
                Production::new("S", vec![]),
            ],
        );
        let cnf = to_cnf(&g);
        for ok in ["", "ab", "aabb", "aaabbb", "aaaabbbb"] {
            assert!(recognize(&cnf, ok), "should accept {ok}");
        }
        for bad in ["a", "b", "abab", "aab", "abb", "ba", "aabba"] {
            assert!(!recognize(&cnf, bad), "should reject {bad}");
        }
    }
}
