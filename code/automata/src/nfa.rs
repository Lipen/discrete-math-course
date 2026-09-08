//! Nondeterministic finite automata (NFA) and the subset construction.
//!
//! An NFA may have several transitions from a state on the same symbol,
//! plus epsilon transitions (on the empty string).
//! A word is accepted if there exists a path that reads the entire word
//! and ends in an accepting state.
//!
//! The subset construction ([`Nfa::to_dfa`]) turns an NFA into an
//! equivalent DFA by treating each subset of NFA states as a single DFA state.
//!
//! ```
//! use automata::Nfa;
//!
//! // An NFA for the language of words containing "ab".
//! let mut nfa = Nfa::new(vec!['a', 'b']);
//! let q0 = nfa.add_state(false);
//! let q1 = nfa.add_state(false);
//! let q2 = nfa.add_state(true);
//! nfa.set_start(q0);
//! nfa.add_transition(q0, 'a', q0).unwrap();
//! nfa.add_transition(q0, 'b', q0).unwrap();
//! nfa.add_transition(q0, 'a', q1).unwrap();
//! nfa.add_transition(q1, 'b', q2).unwrap();
//!
//! assert!(nfa.accepts("ab"));
//! assert!(nfa.accepts("aab"));
//! assert!(nfa.accepts("abab"));
//! assert!(!nfa.accepts(""));
//! assert!(!nfa.accepts("a"));
//! assert!(!nfa.accepts("ba"));
//!
//! let dfa = nfa.to_dfa();
//! assert_eq!(dfa.accepts("ab"), nfa.accepts("ab"));
//! assert_eq!(dfa.accepts("a"), nfa.accepts("a"));
//! ```

use std::collections::{BTreeSet, HashMap};
use std::fmt;

use crate::dfa::Dfa;

/// A nondeterministic finite automaton with epsilon transitions.
///
/// States are added via [`add_state`](Self::add_state) and return
/// consecutive integer identifiers.
/// Transitions on symbols go to sets of states.
/// Epsilon transitions go to single states.
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
    /// Creates an empty automaton with the given alphabet.
    ///
    /// Add states one by one with [`add_state`](Self::add_state).
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let nfa = Nfa::new(vec!['a', 'b']);
    /// assert_eq!(nfa.num_states(), 0);
    /// ```
    pub fn new(alphabet: Vec<char>) -> Self {
        Nfa {
            start: 0,
            alphabet,
            transitions: Vec::new(),
            epsilon: Vec::new(),
            accepting: Vec::new(),
        }
    }

    /// Adds a state and returns its index.
    ///
    /// The state is created with the given accepting flag.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let mut nfa = Nfa::new(vec!['a']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(true);
    /// assert_eq!(q0, 0);
    /// assert_eq!(q1, 1);
    /// assert_eq!(nfa.num_states(), 2);
    /// ```
    pub fn add_state(&mut self, accepting: bool) -> usize {
        let id = self.transitions.len();
        self.transitions.push(vec![Vec::new(); self.alphabet.len()]);
        self.epsilon.push(Vec::new());
        self.accepting.push(accepting);
        id
    }

    /// Sets the start state.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let mut nfa = Nfa::new(vec!['a']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(false);
    /// nfa.set_start(q1);
    /// // q1 is now the start state.
    /// ```
    pub fn set_start(&mut self, start: usize) {
        self.start = start;
    }

    /// Adds a transition from `from` to `to` on symbol `sym`.
    ///
    /// Multiple transitions on the same symbol are allowed (that is
    /// the nondeterminism).
    ///
    /// # Errors
    ///
    /// Returns `Err` if `sym` is not in the alphabet.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let mut nfa = Nfa::new(vec!['a']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(true);
    /// nfa.add_transition(q0, 'a', q1).unwrap();
    /// assert!(nfa.add_transition(q0, 'x', q0).is_err());
    /// ```
    pub fn add_transition(&mut self, from: usize, sym: char, to: usize) -> Result<(), String> {
        let Some(idx) = self.alphabet.iter().position(|&c| c == sym) else {
            return Err(format!("symbol '{sym}' is not in the alphabet"));
        };
        self.transitions[from][idx].push(to);
        Ok(())
    }

    /// Adds an epsilon transition from `from` to `to`.
    ///
    /// An epsilon transition is a spontaneous move: the automaton can
    /// jump to the target state without reading a symbol.
    ///
    /// ```
    /// use automata::Nfa;
    /// use std::collections::BTreeSet;
    ///
    /// let mut nfa = Nfa::new(vec!['a']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(true);
    /// nfa.add_epsilon(q0, q1);
    ///
    /// // The epsilon closure of {q0} includes {q1}.
    /// let closure = nfa.epsilon_closure(&BTreeSet::from([q0]));
    /// assert!(closure.contains(&q1));
    /// ```
    pub fn add_epsilon(&mut self, from: usize, to: usize) {
        self.epsilon[from].push(to);
    }

    /// Sets the accepting flag of a state.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let mut nfa = Nfa::new(vec!['a']);
    /// let q = nfa.add_state(false);
    /// nfa.set_accepting(q, true);
    /// ```
    pub fn set_accepting(&mut self, state: usize, accepting: bool) {
        self.accepting[state] = accepting;
    }

    /// Number of states.
    pub fn num_states(&self) -> usize {
        self.transitions.len()
    }

    /// The alphabet of the automaton.
    pub fn alphabet(&self) -> &[char] {
        &self.alphabet
    }

    /// The start state.
    pub fn start(&self) -> usize {
        self.start
    }

    /// Whether `state` is an accepting state.
    pub fn is_accepting(&self, state: usize) -> bool {
        state < self.accepting.len() && self.accepting[state]
    }

    /// Epsilon closure of a set of states: everything reachable by a
    /// chain of epsilon transitions (including the original states).
    ///
    /// ```
    /// use automata::Nfa;
    /// use std::collections::BTreeSet;
    ///
    /// let mut nfa = Nfa::new(vec![]);
    /// let a = nfa.add_state(false);
    /// let b = nfa.add_state(false);
    /// let c = nfa.add_state(false);
    /// nfa.add_epsilon(a, b);
    /// nfa.add_epsilon(b, c);
    ///
    /// let closure = nfa.epsilon_closure(&BTreeSet::from([a]));
    /// assert_eq!(closure, BTreeSet::from([a, b, c]));
    /// ```
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
    ///
    /// Starting from the epsilon closure of the start state, processes
    /// each symbol by computing the set of reachable states and taking
    /// their epsilon closure.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// // NFA for "a" or "b".
    /// let mut nfa = Nfa::new(vec!['a', 'b']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(true);
    /// let q2 = nfa.add_state(true);
    /// nfa.set_start(q0);
    /// nfa.add_transition(q0, 'a', q1).unwrap();
    /// nfa.add_transition(q0, 'b', q2).unwrap();
    ///
    /// assert!(nfa.accepts("a"));
    /// assert!(nfa.accepts("b"));
    /// assert!(!nfa.accepts(""));
    /// assert!(!nfa.accepts("ab"));
    /// ```
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
    ///
    /// Each DFA state corresponds to a set (the epsilon closure of
    /// a subset) of NFA states.
    /// An empty subset maps to the DFA's implicit trap state: the
    /// transition is left undefined, which the DFA treats as rejection.
    ///
    /// ```
    /// use automata::Nfa;
    ///
    /// let mut nfa = Nfa::new(vec!['a', 'b']);
    /// let q0 = nfa.add_state(false);
    /// let q1 = nfa.add_state(false);
    /// let q2 = nfa.add_state(true);
    /// nfa.set_start(q0);
    /// nfa.add_transition(q0, 'a', q0).unwrap();
    /// nfa.add_transition(q0, 'b', q0).unwrap();
    /// nfa.add_transition(q0, 'a', q1).unwrap();
    /// nfa.add_transition(q1, 'b', q2).unwrap();
    ///
    /// let dfa = nfa.to_dfa();
    /// // The DFA accepts exactly the same words as the NFA.
    /// assert_eq!(dfa.accepts("ab"), nfa.accepts("ab"));
    /// assert_eq!(dfa.accepts("aab"), nfa.accepts("aab"));
    /// assert_eq!(dfa.accepts("ba"), nfa.accepts("ba"));
    /// ```
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
                    dfa.set_transition(i, self.alphabet[sym_idx], to)
                        .expect("symbol from the NFA's own alphabet");
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

impl fmt::Display for Nfa {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "NFA: {} states, alphabet = {:?}, start = q{}",
            self.num_states(),
            self.alphabet,
            self.start
        )?;
        let accept_set: Vec<usize> = (0..self.num_states())
            .filter(|&s| self.accepting[s])
            .collect();
        writeln!(f, "  accepting = {accept_set:?}")?;
        for s in 0..self.num_states() {
            let arrow = if s == self.start { "->" } else { " " };
            let star = if self.accepting[s] { "*" } else { " " };
            write!(f, "  {arrow}q{s}{star}:")?;
            for (sym_idx, targets) in self.transitions[s].iter().enumerate() {
                if !targets.is_empty() {
                    write!(f, " {}->{{{}}}", self.alphabet[sym_idx], fmt_set(targets))?;
                }
            }
            if !self.epsilon[s].is_empty() {
                write!(f, " ε->{{{}}}", fmt_set(&self.epsilon[s]))?;
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

/// Format a slice of usizes as a compact set string like "q0,q1".
fn fmt_set(set: &[usize]) -> String {
    let items: Vec<String> = set.iter().map(|x| format!("q{x}")).collect();
    items.join(",")
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
        nfa.add_transition(q0, '0', q1).unwrap();
        nfa.add_transition(q1, '0', qa).unwrap();
        nfa.add_transition(q1, '1', q2).unwrap();
        // Stuck on one: 1 -> q2, then 1 -> qb.
        nfa.add_transition(q0, '1', q2).unwrap();
        nfa.add_transition(q2, '1', qb).unwrap();
        nfa.add_transition(q2, '0', q1).unwrap();
        // Accepting states absorb everything.
        nfa.add_transition(qa, '0', qa).unwrap();
        nfa.add_transition(qa, '1', qa).unwrap();
        nfa.add_transition(qb, '0', qb).unwrap();
        nfa.add_transition(qb, '1', qb).unwrap();
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

    #[test]
    fn epsilon_closure_includes_self() {
        let mut nfa = Nfa::new(vec!['a']);
        let s = nfa.add_state(false);
        let closure = nfa.epsilon_closure(&BTreeSet::from([s]));
        assert!(closure.contains(&s));
    }

    #[test]
    fn nfa_with_epsilon_accepts_empty_word() {
        // An NFA where the start state has an epsilon transition to an accepting state.
        let mut nfa = Nfa::new(vec!['a']);
        let q0 = nfa.add_state(false);
        let q1 = nfa.add_state(true);
        nfa.set_start(q0);
        nfa.add_epsilon(q0, q1);
        assert!(nfa.accepts(""));
    }

    #[test]
    fn nfa_with_epsilon_preserves_language_after_to_dfa() {
        // An NFA that uses epsilon transitions.
        let mut nfa = Nfa::new(vec!['a', 'b']);
        let q0 = nfa.add_state(false);
        let q1 = nfa.add_state(false);
        let q2 = nfa.add_state(true);
        nfa.set_start(q0);
        nfa.add_epsilon(q0, q1);
        nfa.add_transition(q1, 'a', q2).unwrap();
        nfa.add_transition(q2, 'b', q0).unwrap();

        let dfa = nfa.to_dfa();
        for w in ["", "a", "b", "ab", "aba", "abab"] {
            assert_eq!(dfa.accepts(w), nfa.accepts(w), "word {w:?}");
        }
    }

    #[test]
    fn symbol_outside_alphabet_rejected_by_nfa() {
        let nfa = contains_double();
        assert!(!nfa.accepts("2"));
        assert!(!nfa.accepts("0x1"));
    }

    #[test]
    fn accessors_match_construction() {
        let nfa = contains_double();
        assert_eq!(nfa.num_states(), 5);
        assert_eq!(nfa.alphabet(), &['0', '1']);
        assert_eq!(nfa.start(), 0);
        assert!(nfa.is_accepting(2)); // qa
        assert!(nfa.is_accepting(4)); // qb
        assert!(!nfa.is_accepting(0));
    }

    #[test]
    fn display_does_not_panic() {
        let nfa = contains_double();
        let s = format!("{nfa}");
        assert!(s.contains("states"));
        assert!(s.contains("q0"));
        assert!(s.contains("q0"));
        assert!(s.contains("start"));
    }

    #[test]
    fn add_state_returns_consecutive_ids() {
        let mut nfa = Nfa::new(vec!['a']);
        assert_eq!(nfa.add_state(false), 0);
        assert_eq!(nfa.add_state(false), 1);
        assert_eq!(nfa.add_state(true), 2);
        assert_eq!(nfa.num_states(), 3);
    }
}
