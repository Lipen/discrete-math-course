//! Ambiguity: counting parse trees and finding an ambiguous word.
//!
//! A grammar is ambiguous when some word has more than one parse tree. The
//! search here follows the book's convention: epsilon is eliminated first, so
//! a word such as `()` in `S -> S S | (S) | ε` has exactly one tree -- epsilon
//! does not manufacture spurious splits. Unit productions are removed too.

use crate::grammar::Grammar;
use crate::parse_tree::{self, MAX_PARSE_TREES};
use crate::GrammarError;

/// Count parse trees for `word` (already split into terminals) under the
/// book's ambiguity convention.
pub fn count_trees(grammar: &Grammar, tokens: &[String]) -> Result<usize, GrammarError> {
    if tokens.is_empty() {
        return Ok(if grammar.nullable().contains(&grammar.start) {
            1
        } else {
            0
        });
    }
    let g = grammar.eliminate_epsilon().remove_unit_productions();
    parse_tree::all_parse_trees(&g, tokens).map(|trees| trees.len())
}

/// The first (shortest) word with at least two parse trees, searching words
/// of up to `max_len` terminals in increasing length.
///
/// Returns `None` when no ambiguous word is found up to that length -- an
/// unambiguous certificate. A word over the parse-tree safety cap is
/// unambiguously ambiguous (it has at least [`MAX_PARSE_TREES`] trees), so it
/// is reported as the witness.
pub fn ambiguous_word(grammar: &Grammar, max_len: usize) -> Option<String> {
    let g = grammar.eliminate_epsilon().remove_unit_productions();
    let nullable_start = grammar.nullable().contains(&grammar.start);

    let mut terminals: Vec<String> = grammar.terminals.iter().cloned().collect();
    terminals.sort();

    if count_ef(&g, nullable_start, &[]) >= 2 {
        return Some(String::new());
    }
    for len in 1..=max_len {
        for w in all_words(&terminals, len) {
            if count_ef(&g, nullable_start, &w) >= 2 {
                return Some(w.join(""));
            }
        }
    }
    None
}

/// Is the grammar unambiguous on every word of up to `max_len` terminals?
pub fn is_unambiguous(grammar: &Grammar, max_len: usize) -> bool {
    ambiguous_word(grammar, max_len).is_none()
}

/// The number of parse trees for `word` in the already epsilon-free, unit-free
/// grammar `g`; overflows saturate at [`MAX_PARSE_TREES`] (which is >= 2, so
/// the word is treated as ambiguous).
fn count_ef(g: &Grammar, nullable_start: bool, tokens: &[String]) -> usize {
    if tokens.is_empty() {
        return if nullable_start { 1 } else { 0 };
    }
    match parse_tree::all_parse_trees(g, tokens) {
        Ok(trees) => trees.len(),
        Err(GrammarError::TooManyParseTrees) => MAX_PARSE_TREES,
    }
}

fn all_words(terminals: &[String], len: usize) -> Vec<Vec<String>> {
    if len == 0 {
        return vec![vec![]];
    }
    let mut out = Vec::new();
    for t in terminals {
        for rest in all_words(terminals, len - 1) {
            let mut w = vec![t.clone()];
            w.extend(rest);
            out.push(w);
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::grammar::{nt, t, Production};

    #[test]
    fn ss_a_is_ambiguous_at_aaa() {
        // S -> S S | a
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![t("a")]),
            ],
        );
        assert_eq!(ambiguous_word(&g, 3).as_deref(), Some("aaa"));
    }

    #[test]
    fn arithmetic_is_ambiguous_at_id_plus_id_star_id() {
        // E -> E + E | E * E | (E) | id
        let g = Grammar::new(
            "E",
            vec![
                Production::new("E", vec![nt("E"), t("+"), nt("E")]),
                Production::new("E", vec![nt("E"), t("*"), nt("E")]),
                Production::new("E", vec![t("("), nt("E"), t(")")]),
                Production::new("E", vec![t("id")]),
            ],
        );
        let w = ambiguous_word(&g, 5).unwrap();
        assert_eq!(count_trees(&g, &g.lex(&w).unwrap()).unwrap(), 2);
    }

    #[test]
    fn disambiguated_arithmetic_is_unambiguous() {
        // E -> E + T | T, T -> T * F | F, F -> (E) | id
        let g = Grammar::new(
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
        assert!(is_unambiguous(&g, 6));
        let tokens = g.lex("id+id*id").unwrap();
        assert_eq!(count_trees(&g, &tokens).unwrap(), 1);
    }

    #[test]
    fn dyck_is_unambiguous_but_naive_breaks_at_three_pairs() {
        // Good Dyck: S -> ( S ) S | ε
        let dyck = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("("), nt("S"), t(")"), nt("S")]),
                Production::new("S", vec![]),
            ],
        );
        assert!(is_unambiguous(&dyck, 8));

        // Naive Dyck: S -> S S | (S) | ε  -- the minimal breaking word is
        // `()()()` (two groupings: `() | ()()` and `()() | ()`).
        let naive = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![t("("), nt("S"), t(")")]),
                Production::new("S", vec![]),
            ],
        );
        assert_eq!(ambiguous_word(&naive, 6).as_deref(), Some("()()()"));
    }

    #[test]
    fn division_breaks_at_eight_over_four_over_two() {
        // E -> E / E | 8 | 4 | 2
        let g = Grammar::new(
            "E",
            vec![
                Production::new("E", vec![nt("E"), t("/"), nt("E")]),
                Production::new("E", vec![t("8")]),
                Production::new("E", vec![t("4")]),
                Production::new("E", vec![t("2")]),
            ],
        );
        let tokens = g.lex("8/4/2").unwrap();
        assert_eq!(count_trees(&g, &tokens).unwrap(), 2);
        let trees = crate::parse_tree::all_parse_trees(&g, &tokens).unwrap();
        let parens: Vec<String> = trees.iter().map(|t| t.parenthesized()).collect();
        assert!(parens.contains(&"((8 / 4) / 2)".to_string()));
        assert!(parens.contains(&"(8 / (4 / 2))".to_string()));
    }

    #[test]
    fn epsilon_cycle_does_not_hang_the_search() {
        // S -> S S | ε: eliminate_epsilon removes the cycle, so the search
        // terminates (only the empty word is in the language, with one tree).
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![]),
            ],
        );
        assert!(is_unambiguous(&g, 6));
        assert_eq!(count_trees(&g, &g.lex("").unwrap()).unwrap(), 1);
    }
}
