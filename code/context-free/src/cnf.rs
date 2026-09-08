//! Chomsky normal form.
//!
//! A grammar is in Chomsky normal form (CNF) when every production is
//! `A -> B C` or `A -> a`, with `S -> ε` allowed only for the start symbol.
//! The conversion here is the standard one: eliminate epsilon, remove unit
//! productions, replace terminals in long right-hand sides with fresh
//! nonterminals, and split long right-hand sides into binary chains.

use std::collections::{HashMap, HashSet};

use crate::grammar::{fresh_name, Grammar, Production, Symbol};

/// Convert a grammar to Chomsky normal form.
///
/// The result contains only `A -> B C`, `A -> a`, and `S -> ε` (the last kept
/// exactly when the original start symbol is nullable). The language is
/// preserved.
pub fn to_cnf(grammar: &Grammar) -> Grammar {
    let start_nullable = grammar.nullable().contains(&grammar.start);

    let g = grammar.eliminate_epsilon().remove_unit_productions();

    let mut used: HashSet<String> = g.nonterminals.clone();
    let mut counter = 0usize;

    // Only terminals that appear inside a multi-symbol right-hand side need a
    // fresh nonterminal (a lone `A -> a` is already CNF).
    let mut needs_nt: HashSet<String> = HashSet::new();
    for p in &g.productions {
        if p.body.len() >= 2 {
            for s in &p.body {
                if let Symbol::Terminal(t) = s {
                    needs_nt.insert(t.clone());
                }
            }
        }
    }
    let mut terminal_nt: HashMap<String, String> = HashMap::new();
    for term in needs_nt {
        let name = fresh_name(&mut used, &mut counter);
        terminal_nt.insert(term, name);
    }

    let mut productions: Vec<Production> = Vec::new();

    for p in &g.productions {
        if p.body.len() == 1 {
            // A -> a: already CNF (unit productions are gone, so a single
            // symbol in the body is necessarily a terminal).
            productions.push(p.clone());
            continue;
        }

        // Replace terminals in a multi-symbol right-hand side.
        let rhs: Vec<Symbol> = p
            .body
            .iter()
            .map(|s| match s {
                Symbol::Terminal(t) => Symbol::Nonterminal(terminal_nt[t].clone()),
                Symbol::Nonterminal(n) => Symbol::Nonterminal(n.clone()),
            })
            .collect();

        // Split X1 X2 ... Xk into a binary chain.
        let mut lhs = p.head.clone();
        for idx in 0..(rhs.len() - 1) {
            let a = rhs[idx].clone();
            let b = rhs[idx + 1].clone();
            if idx == rhs.len() - 2 {
                productions.push(Production::new(&lhs, vec![a, b]));
            } else {
                let name = fresh_name(&mut used, &mut counter);
                productions.push(Production::new(
                    &lhs,
                    vec![a, Symbol::Nonterminal(name.clone())],
                ));
                lhs = name;
            }
        }
    }

    // The fresh nonterminals for terminals derive their terminal.
    for (term, name) in &terminal_nt {
        productions.push(Production::new(name, vec![Symbol::Terminal(term.clone())]));
    }

    // Restore S -> ε when the start symbol is nullable (for the empty word).
    if start_nullable {
        productions.push(Production::new(&grammar.start, vec![]));
    }

    let mut cnf = Grammar::new(&grammar.start, productions);
    cnf.dedup();
    cnf
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cyk::recognize;
    use crate::grammar::{nt, t};

    #[test]
    fn a_n_b_n_to_cnf_recognizes() {
        // S -> a S b | ε
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("a"), nt("S"), t("b")]),
                Production::new("S", vec![]),
            ],
        );
        let cnf = to_cnf(&g);
        // Every production is a valid CNF shape.
        for p in &cnf.productions {
            assert!(
                p.body.is_empty()
                    || (p.body.len() == 1 && matches!(p.body[0], Symbol::Terminal(_)))
                    || (p.body.len() == 2
                        && matches!(p.body[0], Symbol::Nonterminal(_))
                        && matches!(p.body[1], Symbol::Nonterminal(_)))
            );
        }
        assert!(recognize(&cnf, "aabb"));
        assert!(recognize(&cnf, ""));
        assert!(!recognize(&cnf, "abab"));
        assert!(recognize(&cnf, "aaabbb"));
    }

    #[test]
    fn cnf_preserves_language_for_ss_a() {
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![t("a")]),
            ],
        );
        let cnf = to_cnf(&g);
        assert!(recognize(&cnf, "a"));
        assert!(recognize(&cnf, "aa"));
        assert!(recognize(&cnf, "aaa"));
        assert!(!recognize(&cnf, ""));
    }
}
