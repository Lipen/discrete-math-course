//! The grammar model: symbols, productions, and grammars.
//!
//! A context-free grammar is a tuple `G = (V, Sigma, P, S)` where `V` is the
//! set of nonterminals, `Sigma` the terminals, `P` the productions `A -> alpha`,
//! and `S` the start symbol.
//! Here nonterminals and terminals are both named by strings.
//! A symbol is a terminal only when it appears in a production body
//! as [`Symbol::Terminal`].

use std::collections::HashSet;
/// A grammar symbol: a terminal or a nonterminal.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Symbol {
    /// A terminal: a letter the words of the language are built from.
    Terminal(String),
    /// A nonterminal: a symbol that expands via productions.
    Nonterminal(String),
}

impl Symbol {
    /// A terminal symbol.
    pub fn terminal(t: &str) -> Symbol {
        Symbol::Terminal(t.to_string())
    }

    /// A nonterminal symbol.
    pub fn nonterminal(nt: &str) -> Symbol {
        Symbol::Nonterminal(nt.to_string())
    }
}

impl std::fmt::Display for Symbol {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Symbol::Terminal(t) => write!(f, "{t}"),
            Symbol::Nonterminal(n) => write!(f, "{n}"),
        }
    }
}

/// Shorthand for a terminal symbol.
pub fn t(s: &str) -> Symbol {
    Symbol::terminal(s)
}

/// Shorthand for a nonterminal symbol.
pub fn nt(s: &str) -> Symbol {
    Symbol::nonterminal(s)
}

/// A production `head -> body`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Production {
    /// The nonterminal on the left-hand side.
    pub head: String,
    /// The replacement on the right-hand side, possibly empty.
    pub body: Vec<Symbol>,
}

impl Production {
    /// Build a production from a head and a body.
    pub fn new(head: &str, body: Vec<Symbol>) -> Production {
        Production {
            head: head.to_string(),
            body,
        }
    }
}

/// A context-free grammar `G = (V, Sigma, P, S)`.
#[derive(Debug, Clone)]
pub struct Grammar {
    /// The start symbol.
    pub start: String,
    /// All productions.
    pub productions: Vec<Production>,
    /// The nonterminals: exactly the production heads.
    pub nonterminals: HashSet<String>,
    /// The terminals appearing in production bodies.
    pub terminals: HashSet<String>,
}

impl Grammar {
    /// Build a grammar from a start symbol and a list of productions.
    ///
    /// Nonterminals are exactly the production heads.
    /// Terminals are the terminal symbols that appear in some body.
    pub fn new(start: &str, productions: Vec<Production>) -> Grammar {
        let mut nonterminals = HashSet::new();
        let mut terminals = HashSet::new();
        for p in &productions {
            nonterminals.insert(p.head.clone());
            for s in &p.body {
                if let Symbol::Terminal(t) = s {
                    terminals.insert(t.clone());
                }
            }
        }
        Grammar {
            start: start.to_string(),
            productions,
            nonterminals,
            terminals,
        }
    }

    /// Productions whose head is `nt`.
    pub fn productions_for(&self, nt: &str) -> Vec<&Production> {
        self.productions.iter().filter(|p| p.head == nt).collect()
    }

    /// Split a word string into terminal tokens by longest match.
    ///
    /// Returns `None` when some part of the word is not a known terminal.
    /// Terminals are expected to be ASCII, so byte-based slicing is safe.
    pub fn lex(&self, word: &str) -> Option<Vec<String>> {
        let mut terms: Vec<&str> = self.terminals.iter().map(|s| s.as_str()).collect();
        terms.sort_by_key(|s| std::cmp::Reverse(s.len()));
        let mut i = 0;
        let mut out = Vec::new();
        while i < word.len() {
            let rest = &word[i..];
            let mut matched = false;
            for t in &terms {
                if rest.starts_with(t) {
                    out.push(t.to_string());
                    i += t.len();
                    matched = true;
                    break;
                }
            }
            if !matched {
                return None;
            }
        }
        Some(out)
    }

    /// The set of nullable nonterminals (those that derive the empty word).
    pub fn nullable(&self) -> HashSet<String> {
        let mut null: HashSet<String> = HashSet::new();
        loop {
            let mut changed = false;
            for p in &self.productions {
                if !null.contains(&p.head) {
                    let all_nullable = p.body.iter().all(|s| match s {
                        Symbol::Nonterminal(nt) => null.contains(nt),
                        Symbol::Terminal(_) => false,
                    });
                    if all_nullable {
                        null.insert(p.head.clone());
                        changed = true;
                    }
                }
            }
            if !changed {
                break;
            }
        }
        null
    }

    /// The epsilon-free grammar: every empty-body production is dropped, and
    /// every other production is replaced by all variants where nullable
    /// nonterminals are omitted. The result generates `L(G) \ {epsilon}`.
    pub fn eliminate_epsilon(&self) -> Grammar {
        let null = self.nullable();
        let mut productions = Vec::new();
        for p in &self.productions {
            if p.body.is_empty() {
                continue;
            }
            for variant in epsilon_variants(&p.body, &null) {
                if variant.is_empty() {
                    continue;
                }
                productions.push(Production::new(&p.head, variant));
            }
        }
        let mut g = Grammar::new(&self.start, productions);
        g.dedup();
        g
    }

    /// Remove unit productions (`A -> B`).
    ///
    /// Computes the unit closure (which pairs `A =>* B` hold via unit
    /// productions only) and then expands each non-unit production to every
    /// nonterminal that reaches its head.
    pub fn remove_unit_productions(&self) -> Grammar {
        let mut units: HashSet<(String, String)> = HashSet::new();
        for nt in &self.nonterminals {
            units.insert((nt.clone(), nt.clone()));
        }
        loop {
            let mut changed = false;
            for p in &self.productions {
                if p.body.len() == 1 {
                    if let Symbol::Nonterminal(b) = &p.body[0] {
                        for (x, y) in units.clone() {
                            if y == p.head && !units.contains(&(x.clone(), b.clone())) {
                                units.insert((x.clone(), b.clone()));
                                changed = true;
                            }
                        }
                    }
                }
            }
            if !changed {
                break;
            }
        }
        let mut productions = Vec::new();
        for p in &self.productions {
            if p.body.len() == 1 && matches!(p.body[0], Symbol::Nonterminal(_)) {
                continue;
            }
            for (a, b) in &units {
                if b == &p.head {
                    productions.push(Production::new(a, p.body.clone()));
                }
            }
        }
        let mut g = Grammar::new(&self.start, productions);
        g.dedup();
        g
    }

    /// Drop duplicate productions in place.
    pub fn dedup(&mut self) {
        let mut seen = HashSet::new();
        let mut keep = Vec::new();
        for p in std::mem::take(&mut self.productions) {
            let key = (p.head.clone(), p.body.clone());
            if seen.insert(key) {
                keep.push(p);
            }
        }
        self.productions = keep;
    }
}

/// All ways to keep a subset of the nullable nonterminal positions in `body`.
fn epsilon_variants(body: &[Symbol], null: &HashSet<String>) -> Vec<Vec<Symbol>> {
    fn go(
        body: &[Symbol],
        null: &HashSet<String>,
        idx: usize,
        prefix: &mut Vec<Symbol>,
        out: &mut Vec<Vec<Symbol>>,
    ) {
        if idx == body.len() {
            out.push(prefix.clone());
            return;
        }
        let sym = &body[idx];
        // Keep the symbol.
        prefix.push(sym.clone());
        go(body, null, idx + 1, prefix, out);
        prefix.pop();
        // Omit it when it is a nullable nonterminal.
        if let Symbol::Nonterminal(n) = sym {
            if null.contains(n) {
                go(body, null, idx + 1, prefix, out);
            }
        }
    }
    let mut out = Vec::new();
    let mut prefix = Vec::new();
    go(body, null, 0, &mut prefix, &mut out);
    out
}

/// A fresh nonterminal name not already in `used`, incrementing `counter`.
pub(crate) fn fresh_name(used: &mut HashSet<String>, counter: &mut usize) -> String {
    loop {
        let name = format!("N{}", *counter);
        *counter += 1;
        if used.insert(name.clone()) {
            return name;
        }
    }
}
