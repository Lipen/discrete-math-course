//! Parse trees and their enumeration.
//!
//! A parse tree makes the structure of a derivation visible: the root is the
//! start symbol, internal nodes are nonterminals, and the concatenation of the
//! leaves is the derived word. [`all_parse_trees`] returns every parse tree of
//! a word, not just the first one.

use std::collections::HashMap;

use crate::grammar::{Grammar, Symbol};
use crate::GrammarError;

/// Safety cap on the number of parse trees built for any one nonterminal over
/// any one substring. A grammar that exceeds it -- typically an epsilon- or
/// unit-cycle, which is infinitely ambiguous -- is reported as an error
/// instead of looping forever.
pub const MAX_PARSE_TREES: usize = 100_000;

/// A parse tree: a leaf holds a terminal, a node holds a nonterminal and its
/// children (the right-hand side of the production it applies).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParseTree {
    Leaf(String),
    Node(String, Vec<ParseTree>),
}

impl ParseTree {
    /// The word spelled by the leaves, left to right.
    pub fn yield_string(&self) -> String {
        match self {
            ParseTree::Leaf(t) => t.clone(),
            ParseTree::Node(_, children) => children.iter().map(|c| c.yield_string()).collect(),
        }
    }

    /// The leaves in order.
    pub fn leaves(&self) -> Vec<String> {
        match self {
            ParseTree::Leaf(t) => vec![t.clone()],
            ParseTree::Node(_, children) => children.iter().flat_map(|c| c.leaves()).collect(),
        }
    }

    /// The unique leftmost derivation of this tree, as a sequence of
    /// sentential forms (each a `Vec<Symbol>`).
    pub fn leftmost_derivation(&self) -> Vec<Vec<Symbol>> {
        let mut steps = Vec::new();
        let mut work: Vec<&ParseTree> = vec![self];
        loop {
            let form: Vec<Symbol> = work
                .iter()
                .map(|node| match node {
                    ParseTree::Leaf(t) => Symbol::Terminal(t.clone()),
                    ParseTree::Node(nt, _) => Symbol::Nonterminal(nt.clone()),
                })
                .collect();
            steps.push(form);
            let pos = work
                .iter()
                .position(|node| matches!(node, ParseTree::Node(_, _)));
            match pos {
                None => break,
                Some(i) => {
                    let children: Vec<&ParseTree> = match work[i] {
                        ParseTree::Node(_, c) => c.iter().collect(),
                        ParseTree::Leaf(_) => unreachable!(),
                    };
                    let mut next = Vec::new();
                    next.extend(work[..i].iter().copied());
                    next.extend(children);
                    next.extend(work[i + 1..].iter().copied());
                    work = next;
                }
            }
        }
        steps
    }

    /// A fully parenthesized form: a node with exactly three children
    /// `x op y` is written `(x op y)`; anything else is flattened left to
    /// right. Useful for showing how a binary operator groups its operands.
    pub fn parenthesized(&self) -> String {
        match self {
            ParseTree::Leaf(t) => t.clone(),
            ParseTree::Node(_, children) => {
                if children.len() == 3 {
                    let op = match &children[1] {
                        ParseTree::Leaf(t) => t.clone(),
                        other => other.parenthesized(),
                    };
                    format!(
                        "({} {} {})",
                        children[0].parenthesized(),
                        op,
                        children[2].parenthesized()
                    )
                } else if children.len() == 1 {
                    children[0].parenthesized()
                } else {
                    children
                        .iter()
                        .map(|c| c.parenthesized())
                        .collect::<Vec<_>>()
                        .join(" ")
                }
            }
        }
    }
}

impl std::fmt::Display for ParseTree {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ParseTree::Leaf(t) => write!(f, "{t}"),
            ParseTree::Node(nt, children) => {
                if children.is_empty() {
                    write!(f, "{nt}->ε")
                } else {
                    let inner = children
                        .iter()
                        .map(|c| c.to_string())
                        .collect::<Vec<_>>()
                        .join(" ");
                    write!(f, "{nt}[{inner}]")
                }
            }
        }
    }
}

/// All parse trees of `word` rooted at the grammar's start symbol.
///
/// The enumerator keeps epsilon productions (a node with no children) and unit
/// productions, so the trees show the grammar exactly as written. To guarantee
/// termination it caps each `(nonterminal, substring)` at
/// [`MAX_PARSE_TREES`]; a grammar with an epsilon-cycle such as
/// `S -> S S | ε` or a unit-cycle such as `A -> B, B -> A` exceeds the cap and
/// yields [`GrammarError::TooManyParseTrees`].
///
/// The ambiguity module applies epsilon-elimination and unit-removal first,
/// which makes it safe for those grammars as well.
pub fn all_parse_trees(grammar: &Grammar, word: &[String]) -> Result<Vec<ParseTree>, GrammarError> {
    let n = word.len();
    // memo[(nonterminal, start, end)] = trees for that nonterminal over
    // word[start..end].
    let mut memo: HashMap<(String, usize, usize), Vec<ParseTree>> = HashMap::new();

    for len in 0..=n {
        for i in 0..=(n - len) {
            let j = i + len;
            // Fixed point over the current span: unit productions and epsilon
            // chains may add trees within the same span.
            loop {
                let mut added = false;
                for p in &grammar.productions {
                    let child_lists = match_body(word, &p.body, i, j, &memo)?;
                    for children in child_lists {
                        let node = ParseTree::Node(p.head.clone(), children);
                        let entry = memo.entry((p.head.clone(), i, j)).or_default();
                        if entry.len() >= MAX_PARSE_TREES {
                            return Err(GrammarError::TooManyParseTrees);
                        }
                        if !entry.contains(&node) {
                            entry.push(node);
                            added = true;
                        }
                    }
                }
                if !added {
                    break;
                }
            }
        }
    }

    Ok(memo
        .remove(&(grammar.start.clone(), 0, n))
        .unwrap_or_default())
}

/// Is `word` in the language of `grammar`?
///
/// Membership is decided by CYK on the grammar's Chomsky normal form, so it
/// always terminates regardless of ambiguity.
pub fn in_language(grammar: &Grammar, word: &str) -> bool {
    crate::cyk::recognize(&crate::to_cnf(grammar), word)
}

/// Enumerate every way to match `body` over `word[i..j]`, as a list of child
/// lists. Each child list has `body.len()` subtrees, one per body symbol.
/// Capped at [`MAX_PARSE_TREES`].
fn match_body(
    word: &[String],
    body: &[Symbol],
    i: usize,
    j: usize,
    memo: &HashMap<(String, usize, usize), Vec<ParseTree>>,
) -> Result<Vec<Vec<ParseTree>>, GrammarError> {
    if body.is_empty() {
        return Ok(if i == j { vec![vec![]] } else { vec![] });
    }
    let (first, rest) = body.split_at(1);
    let mut out = Vec::new();
    for k in i..=j {
        let first_trees: Vec<ParseTree> = match &first[0] {
            Symbol::Terminal(t) => {
                if k == i + 1 && i < word.len() && &word[i] == t {
                    vec![ParseTree::Leaf(t.clone())]
                } else {
                    vec![]
                }
            }
            Symbol::Nonterminal(nt) => memo.get(&(nt.clone(), i, k)).cloned().unwrap_or_default(),
        };
        if first_trees.is_empty() {
            continue;
        }
        let rest_lists = match_body(word, rest, k, j, memo)?;
        for ft in &first_trees {
            for rl in &rest_lists {
                let mut children = Vec::with_capacity(body.len());
                children.push(ft.clone());
                children.extend(rl.iter().cloned());
                out.push(children);
                if out.len() > MAX_PARSE_TREES {
                    return Err(GrammarError::TooManyParseTrees);
                }
            }
        }
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::grammar::{nt, t, Production};

    #[test]
    fn a_n_b_n_has_exactly_one_tree() {
        // S -> a S b | ε
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("a"), nt("S"), t("b")]),
                Production::new("S", vec![]),
            ],
        );
        let tokens = g.lex("aabb").unwrap();
        let trees = all_parse_trees(&g, &tokens).unwrap();
        assert_eq!(trees.len(), 1);
        assert_eq!(trees[0].yield_string(), "aabb");
        let der = trees[0].leftmost_derivation();
        assert_eq!(der.len(), 4); // S -> aSb -> aaSbb -> aabb
    }

    #[test]
    fn leftmost_derivation_matches_book() {
        // S -> a S b | ε on "ab".
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![t("a"), nt("S"), t("b")]),
                Production::new("S", vec![]),
            ],
        );
        let tokens = g.lex("ab").unwrap();
        let trees = all_parse_trees(&g, &tokens).unwrap();
        assert_eq!(trees.len(), 1);
        let der = trees[0].leftmost_derivation();
        let forms: Vec<String> = der
            .iter()
            .map(|form| {
                form.iter()
                    .map(|s| s.to_string())
                    .collect::<Vec<_>>()
                    .join(" ")
            })
            .collect();
        assert_eq!(forms, vec!["S", "a S b", "a b"]);
    }

    #[test]
    fn s_ss_a_has_two_trees_for_aaa() {
        // S -> S S | a
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![t("a")]),
            ],
        );
        let tokens = g.lex("aaa").unwrap();
        let trees = all_parse_trees(&g, &tokens).unwrap();
        assert_eq!(trees.len(), 2);
    }

    #[test]
    fn arithmetic_has_two_trees_for_id_plus_id_star_id() {
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
        let tokens = g.lex("id+id*id").unwrap();
        let trees = all_parse_trees(&g, &tokens).unwrap();
        assert_eq!(trees.len(), 2);
        let parens: Vec<String> = trees.iter().map(|t| t.parenthesized()).collect();
        assert!(parens.contains(&"(id + (id * id))".to_string()));
        assert!(parens.contains(&"((id + id) * id)".to_string()));
    }

    #[test]
    fn epsilon_cycle_is_reported_not_hung() {
        // S -> S S | ε has infinitely many trees for every word: the cap must
        // turn the runaway enumeration into an error.
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![]),
            ],
        );
        let tokens = g.lex("").unwrap();
        assert_eq!(
            all_parse_trees(&g, &tokens),
            Err(GrammarError::TooManyParseTrees)
        );
    }

    #[test]
    fn membership_terminates_for_epsilon_cycle() {
        // S -> S S | ε generates exactly { ε }; membership must not hang.
        let g = Grammar::new(
            "S",
            vec![
                Production::new("S", vec![nt("S"), nt("S")]),
                Production::new("S", vec![]),
            ],
        );
        assert!(in_language(&g, ""));
        assert!(!in_language(&g, "a"));
    }
}
