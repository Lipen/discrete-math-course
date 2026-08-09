//! Nondeterministic finite automata (NFA) and the subset construction.
//!
//! A state may have several transitions on one symbol, plus epsilon transitions
//! (on the empty symbol). A word is accepted if there is a path that reads it
//! all and ends in an accepting state. Determinization (the subset
//! construction) turns an NFA into an equivalent DFA.

use std::collections::{BTreeSet, HashMap};

use crate::dfa::Dfa;

/// A nondeterministic finite automaton.
#[derive(Debug, Clone)]
pub struct Nfa {
    start: usize,
    alphabet: Vec<char>,
    /// transitions[state][symbol index] -> set of next states.
    transitions: Vec<Vec<Vec<usize>>>,
    /// epsilon[state] -> states reachable by an epsilon transition.
    epsilon: Vec<Vec<usize>>,
    accepting: Vec<bool>,
}

impl Nfa {
    /// An empty automaton with no states.
    pub fn new(alphabet: Vec<char>) -> Self {
        Nfa {
            start: 0,
            alphabet,
            transitions: Vec::new(),
            epsilon: Vec::new(),
            accepting: Vec::new(),
        }
    }

    /// Adds a state and returns its number.
    pub fn add_state(&mut self, accepting: bool) -> usize {
        let id = self.transitions.len();
        self.transitions.push(vec![Vec::new(); self.alphabet.len()]);
        self.epsilon.push(Vec::new());
        self.accepting.push(accepting);
        id
    }

    /// Sets the start state.
    pub fn set_start(&mut self, start: usize) {
        self.start = start;
    }

    /// Adds a transition on a symbol.
    ///
    /// # Panics
    ///
    /// Panics if `sym` is not in the alphabet.
    pub fn add_transition(&mut self, from: usize, sym: char, to: usize) {
        let idx = self
            .alphabet
            .iter()
            .position(|&c| c == sym)
            .expect("symbol is not in the alphabet");
        self.transitions[from][idx].push(to);
    }

    /// Adds an epsilon transition.
    pub fn add_epsilon(&mut self, from: usize, to: usize) {
        self.epsilon[from].push(to);
    }

    /// Sets the accepting flag of a state.
    pub fn set_accepting(&mut self, state: usize, accepting: bool) {
        self.accepting[state] = accepting;
    }

    /// Number of states.
    pub fn num_states(&self) -> usize {
        self.transitions.len()
    }

    /// Epsilon closure of a set of states: everything reachable by a chain of
    /// epsilon transitions.
    pub fn epsilon_closure(&self, states: &BTreeSet<usize>) -> BTreeSet<usize> {
        let mut closure = states.clone();
        let mut stack: Vec<usize> = closure.iter().copied().collect();
        while let Some(s) = stack.pop() {
            for &t in &self.epsilon[s] {
                if closure.insert(t) {
                    stack.push(t);
                }
            }
        }
        closure
    }

    /// Whether the automaton accepts a word.
    pub fn accepts(&self, word: &str) -> bool {
        let mut reachable = self.epsilon_closure(&BTreeSet::from([self.start]));
        for c in word.chars() {
            let Some(idx) = self.alphabet.iter().position(|&x| x == c) else {
                return false;
            };
            let mut next = BTreeSet::new();
            for &s in &reachable {
                next.extend(self.transitions[s][idx].iter().copied());
            }
            reachable = self.epsilon_closure(&next);
        }
        reachable.iter().any(|&s| self.accepting[s])
    }

    /// Subset construction: turns an NFA into an equivalent DFA.
    pub fn to_dfa(&self) -> Dfa {
        // DFA states are subsets of NFA states (more precisely, their epsilon closures).
        let start_set = self.epsilon_closure(&BTreeSet::from([self.start]));
        let mut subsets: Vec<BTreeSet<usize>> = vec![start_set.clone()];
        let mut index: HashMap<BTreeSet<usize>, usize> = HashMap::new();
        index.insert(start_set.clone(), 0);
        let mut rows: Vec<Vec<usize>> = Vec::new();

        let mut i = 0;
        while i < subsets.len() {
            let subset = subsets[i].clone();
            let mut row = Vec::with_capacity(self.alphabet.len());
            for sym_idx in 0..self.alphabet.len() {
                let mut next = BTreeSet::new();
                for &s in &subset {
                    next.extend(self.transitions[s][sym_idx].iter().copied());
                }
                let next = self.epsilon_closure(&next);
                if next.is_empty() {
                    row.push(usize::MAX); // trap
                } else {
                    let j = *index.entry(next.clone()).or_insert_with(|| {
                        subsets.push(next.clone());
                        subsets.len() - 1
                    });
                    row.push(j);
                }
            }
            rows.push(row);
            i += 1;
        }

        let mut dfa = Dfa::new(subsets.len(), 0, self.alphabet.clone());
        for (i, row) in rows.iter().enumerate() {
            for (sym_idx, &to) in row.iter().enumerate() {
                if to != usize::MAX {
                    dfa.set_transition(i, self.alphabet[sym_idx], to);
                }
            }
        }
        let accepting: Vec<bool> = subsets
            .iter()
            .map(|s| s.iter().any(|&st| self.accepting[st]))
            .collect();
        dfa.set_accepting(accepting);
        dfa
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// An NFA for the language of words containing "00" or "11".
    fn contains_double() -> Nfa {
        let mut nfa = Nfa::new(vec!['0', '1']);
        let q0 = nfa.add_state(false);
        let q1 = nfa.add_state(false);
        let qa = nfa.add_state(true);
        let q2 = nfa.add_state(false);
        let qb = nfa.add_state(true);
        nfa.set_start(q0);
        // Stuck on zero: 0 -> q1, then 0 -> qa (accepted "00").
        nfa.add_transition(q0, '0', q1);
        nfa.add_transition(q1, '0', qa);
        nfa.add_transition(q1, '1', q2);
        // Stuck on one: 1 -> q2, then 1 -> qb.
        nfa.add_transition(q0, '1', q2);
        nfa.add_transition(q2, '1', qb);
        nfa.add_transition(q2, '0', q1);
        // Accepting states absorb everything.
        nfa.add_transition(qa, '0', qa);
        nfa.add_transition(qa, '1', qa);
        nfa.add_transition(qb, '0', qb);
        nfa.add_transition(qb, '1', qb);
        nfa
    }

    #[test]
    fn nfa_accepts_double_words() {
        let nfa = contains_double();
        assert!(nfa.accepts("00"));
        assert!(nfa.accepts("11"));
        assert!(nfa.accepts("01011"));
        assert!(nfa.accepts("1000"));
        assert!(!nfa.accepts(""));
        assert!(!nfa.accepts("0"));
        assert!(!nfa.accepts("1"));
        assert!(!nfa.accepts("010"));
        assert!(!nfa.accepts("1010"));
    }

    #[test]
    fn subset_construction_preserves_language() {
        let nfa = contains_double();
        let dfa = nfa.to_dfa();
        for w in [
            "", "0", "1", "00", "11", "010", "1010", "01011", "1000", "010010",
        ] {
            assert_eq!(dfa.accepts(w), nfa.accepts(w), "word {w:?}");
        }
    }

    #[test]
    fn epsilon_closure_transitive() {
        let mut nfa = Nfa::new(vec!['a']);
        let s = nfa.add_state(false);
        let t = nfa.add_state(false);
        let u = nfa.add_state(false);
        nfa.add_epsilon(s, t);
        nfa.add_epsilon(t, u);
        assert_eq!(
            nfa.epsilon_closure(&BTreeSet::from([s])),
            BTreeSet::from([s, t, u])
        );
    }
}
