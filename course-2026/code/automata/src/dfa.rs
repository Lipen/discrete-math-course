//! Deterministic finite automata (DFA).
//!
//! A DFA is a 5-tuple $(Q, Sigma, delta, q_0, F)$.
//! Transitions are stored as a table `delta[state][symbol_index]`.
//! An undefined transition leads to an implicit trap state (index `states`),
//! which `accepts` catches and treats as rejection.
//!
//! The module also provides language operations built via the product
//! construction -- complement, union, intersection, difference -- and
//! minimization by Moore's partition-refinement algorithm.
//!
//! ```
//! use automata::Dfa;
//!
//! // A DFA for words with an even number of '1's.
//! let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
//! dfa.set_transition(0, '0', 0).unwrap();
//! dfa.set_transition(0, '1', 1).unwrap();
//! dfa.set_transition(1, '0', 1).unwrap();
//! dfa.set_transition(1, '1', 0).unwrap();
//! dfa.set_accepting(vec![true, false]);
//!
//! assert!(dfa.accepts(""));
//! assert!(dfa.accepts("11"));
//! assert!(dfa.accepts("1010")); // two 1s = even
//! assert!(!dfa.accepts("1"));
//! assert_eq!(dfa.num_states(), 2);
//! assert_eq!(dfa.alphabet(), &['0', '1']);
//! assert_eq!(dfa.start(), 0);
//! assert!(dfa.is_accepting(0));
//! assert!(!dfa.is_accepting(1));
//! ```

use std::collections::HashMap;
use std::fmt;

/// A deterministic finite automaton over an alphabet of `char`.
///
/// States are integers `0..states`.
/// Transitions are stored as `delta[state][symbol index]`.
/// An undefined transition points to `states` (the implicit trap).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Dfa {
    states: usize,
    start: usize,
    accepting: Vec<bool>,
    alphabet: Vec<char>,
    delta: Vec<Vec<usize>>,
}

impl Dfa {
    /// Creates an automaton with `states` states, start state `start`,
    /// and the given alphabet.
    ///
    /// All states are non-accepting by default and every transition
    /// points to the trap state (`states`).
    /// Call [`set_transition`](Self::set_transition) and
    /// [`set_accepting`](Self::set_accepting) to build the transition
    /// function and mark final states.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let dfa = Dfa::new(3, 0, vec!['a', 'b']);
    /// assert_eq!(dfa.num_states(), 3);
    /// assert_eq!(dfa.alphabet(), &['a', 'b']);
    /// assert_eq!(dfa.start(), 0);
    /// // All states are non-accepting by default.
    /// assert!(!dfa.is_accepting(0));
    /// assert!(!dfa.is_accepting(1));
    /// assert!(!dfa.is_accepting(2));
    /// ```
    pub fn new(states: usize, start: usize, alphabet: Vec<char>) -> Self {
        let delta = vec![vec![states; alphabet.len()]; states];
        Dfa {
            states,
            start,
            accepting: vec![false; states],
            alphabet,
            delta,
        }
    }

    /// Sets the transition from state `from` to state `to` on symbol `sym`.
    ///
    /// Returns `Err` if `sym` is not in the alphabet.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut dfa = Dfa::new(2, 0, vec!['a']);
    /// dfa.set_transition(0, 'a', 1).unwrap();
    /// assert!(dfa.set_transition(0, 'x', 0).is_err());
    /// ```
    pub fn set_transition(&mut self, from: usize, sym: char, to: usize) -> Result<(), String> {
        let Some(idx) = self.alphabet.iter().position(|&c| c == sym) else {
            return Err(format!("symbol '{sym}' is not in the alphabet"));
        };
        self.delta[from][idx] = to;
        Ok(())
    }

    /// Marks states as accepting (one flag per state).
    ///
    /// # Panics
    ///
    /// Panics if `accepting` has a different length than the number of states.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut dfa = Dfa::new(2, 0, vec!['a']);
    /// dfa.set_accepting(vec![false, true]);
    /// assert!(!dfa.is_accepting(0));
    /// assert!(dfa.is_accepting(1));
    /// ```
    pub fn set_accepting(&mut self, accepting: Vec<bool>) {
        assert_eq!(accepting.len(), self.states);
        self.accepting = accepting;
    }

    /// Number of states.
    pub fn num_states(&self) -> usize {
        self.states
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
    ///
    /// Returns `false` for the trap state (i.e. any index `>= states`).
    pub fn is_accepting(&self, state: usize) -> bool {
        state < self.states && self.accepting[state]
    }

    /// Whether the automaton accepts the word `word`.
    ///
    /// A symbol outside the alphabet immediately causes rejection.
    /// Entering the implicit trap state also causes rejection.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// // DFA that accepts exactly "a" and "aa".
    /// let mut dfa = Dfa::new(4, 0, vec!['a']);
    /// dfa.set_transition(0, 'a', 1).unwrap();
    /// dfa.set_transition(1, 'a', 2).unwrap();
    /// dfa.set_transition(2, 'a', 3).unwrap();
    /// dfa.set_transition(3, 'a', 3).unwrap();
    /// dfa.set_accepting(vec![false, true, true, false]);
    ///
    /// assert!(dfa.accepts("a"));
    /// assert!(dfa.accepts("aa"));
    /// assert!(!dfa.accepts(""));
    /// assert!(!dfa.accepts("aaa"));
    /// assert!(!dfa.accepts("b"));
    /// ```
    pub fn accepts(&self, word: &str) -> bool {
        let mut state = self.start;
        for c in word.chars() {
            let Some(idx) = self.alphabet.iter().position(|&x| x == c) else {
                return false; // symbol outside the alphabet
            };
            state = self.delta[state][idx];
            if state >= self.states {
                return false; // entered the trap state
            }
        }
        self.accepting[state]
    }

    /// Whether the language of the automaton is empty.
    ///
    /// Uses BFS from the start state: if no accepting state is reachable,
    /// the language is empty.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut dfa = Dfa::new(2, 0, vec!['a']);
    /// dfa.set_transition(0, 'a', 1).unwrap();
    /// dfa.set_transition(1, 'a', 1).unwrap();
    /// dfa.set_accepting(vec![false, false]);
    ///
    /// assert!(dfa.is_empty());
    /// ```
    pub fn is_empty(&self) -> bool {
        let mut visited = vec![false; self.states];
        let mut stack = vec![self.start];
        visited[self.start] = true;
        while let Some(s) = stack.pop() {
            if self.accepting[s] {
                return false;
            }
            for &to in &self.delta[s] {
                if to < self.states && !visited[to] {
                    visited[to] = true;
                    stack.push(to);
                }
            }
        }
        true
    }

    /// Whether two DFAs accept the same language.
    ///
    /// Builds the symmetric-difference DFA and checks whether it is empty.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// // Two different DFAs for the same language: words ending in 'a'.
    /// let mut d1 = Dfa::new(2, 0, vec!['a', 'b']);
    /// d1.set_transition(0, 'a', 1).unwrap();
    /// d1.set_transition(0, 'b', 0).unwrap();
    /// d1.set_transition(1, 'a', 1).unwrap();
    /// d1.set_transition(1, 'b', 0).unwrap();
    /// d1.set_accepting(vec![false, true]);
    ///
    /// // A 3-state version: the trap state after 'a' is explicit.
    /// let mut d2 = Dfa::new(3, 0, vec!['a', 'b']);
    /// d2.set_transition(0, 'a', 1).unwrap();
    /// d2.set_transition(0, 'b', 0).unwrap();
    /// d2.set_transition(1, 'a', 1).unwrap();
    /// d2.set_transition(1, 'b', 0).unwrap();
    /// d2.set_transition(2, 'a', 2).unwrap();
    /// d2.set_transition(2, 'b', 2).unwrap();
    /// d2.set_accepting(vec![false, true, false]);
    ///
    /// assert!(d1.equivalent_to(&d2));
    /// ```
    pub fn equivalent_to(&self, other: &Dfa) -> bool {
        let d1 = self.difference(other);
        let d2 = other.difference(self);
        d1.is_empty() && d2.is_empty()
    }

    /// Adds an explicit sink trap state so that every symbol has a
    /// transition from every state.
    ///
    /// All previously undefined transitions are redirected to the new
    /// dead state.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut dfa = Dfa::new(1, 0, vec!['a', 'b']);
    /// // Only 'a' is defined.
    /// dfa.set_transition(0, 'a', 0).unwrap();
    ///
    /// let comp = dfa.complete();
    /// assert_eq!(comp.num_states(), 2); // original + trap
    /// // Now every symbol has a transition from every state.
    /// ```
    pub fn complete(&self) -> Dfa {
        let mut d = self.clone();
        let dead = d.states;
        d.states += 1;
        d.accepting.push(false);
        d.delta.push(vec![dead; d.alphabet.len()]);
        for row in d.delta.iter_mut() {
            for to in row.iter_mut() {
                if *to >= dead {
                    *to = dead;
                }
            }
        }
        d
    }

    /// Language complement: accepting and non-accepting states swap roles.
    ///
    /// The automaton is first completed (an explicit trap state is added)
    /// so that every word over the alphabet either reaches an accepting
    /// or a non-accepting state.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// // DFA for words with an even number of '1's.
    /// let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    /// dfa.set_transition(0, '0', 0).unwrap();
    /// dfa.set_transition(0, '1', 1).unwrap();
    /// dfa.set_transition(1, '0', 1).unwrap();
    /// dfa.set_transition(1, '1', 0).unwrap();
    /// dfa.set_accepting(vec![true, false]);
    ///
    /// let comp = dfa.complement();
    /// assert_eq!(comp.accepts("1"), !dfa.accepts("1"));
    /// assert_eq!(comp.accepts("11"), !dfa.accepts("11"));
    /// ```
    pub fn complement(&self) -> Dfa {
        let mut d = self.complete();
        for a in d.accepting.iter_mut() {
            *a = !*a;
        }
        d
    }

    /// Union of the languages of two automata.
    ///
    /// Built via the product construction: the state of the result is a
    /// pair `(q1, q2)` of states from `self` and `other`.
    /// Only reachable pairs are materialised.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// // DFA for words containing 'a'.
    /// let mut has_a = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_a.set_transition(0, 'a', 1).unwrap();
    /// has_a.set_transition(0, 'b', 0).unwrap();
    /// has_a.set_transition(1, 'a', 1).unwrap();
    /// has_a.set_transition(1, 'b', 1).unwrap();
    /// has_a.set_accepting(vec![false, true]);
    ///
    /// // DFA for words containing 'b'.
    /// let mut has_b = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_b.set_transition(0, 'a', 0).unwrap();
    /// has_b.set_transition(0, 'b', 1).unwrap();
    /// has_b.set_transition(1, 'a', 1).unwrap();
    /// has_b.set_transition(1, 'b', 1).unwrap();
    /// has_b.set_accepting(vec![false, true]);
    ///
    /// let uni = has_a.union(&has_b);
    /// assert!(uni.accepts("ab"));   // has both
    /// assert!(uni.accepts("a"));    // has a
    /// assert!(uni.accepts("b"));    // has b
    /// assert!(!uni.accepts(""));    // has neither
    /// ```
    pub fn union(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a || b)
    }

    /// Intersection of the languages of two automata.
    ///
    /// Built via the product construction (see [`union`](Self::union)).
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut has_a = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_a.set_transition(0, 'a', 1).unwrap();
    /// has_a.set_transition(0, 'b', 0).unwrap();
    /// has_a.set_transition(1, 'a', 1).unwrap();
    /// has_a.set_transition(1, 'b', 1).unwrap();
    /// has_a.set_accepting(vec![false, true]);
    ///
    /// let mut has_b = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_b.set_transition(0, 'a', 0).unwrap();
    /// has_b.set_transition(0, 'b', 1).unwrap();
    /// has_b.set_transition(1, 'a', 1).unwrap();
    /// has_b.set_transition(1, 'b', 1).unwrap();
    /// has_b.set_accepting(vec![false, true]);
    ///
    /// let inter = has_a.intersection(&has_b);
    /// assert!(inter.accepts("ab"));   // has both
    /// assert!(!inter.accepts("a"));   // has only a
    /// assert!(!inter.accepts("b"));   // has only b
    /// assert!(!inter.accepts(""));    // has neither
    /// ```
    pub fn intersection(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && b)
    }

    /// Language difference: words of `self` not in `other`.
    ///
    /// Built via the product construction (see [`union`](Self::union)).
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// let mut has_a = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_a.set_transition(0, 'a', 1).unwrap();
    /// has_a.set_transition(0, 'b', 0).unwrap();
    /// has_a.set_transition(1, 'a', 1).unwrap();
    /// has_a.set_transition(1, 'b', 1).unwrap();
    /// has_a.set_accepting(vec![false, true]);
    ///
    /// let mut has_b = Dfa::new(2, 0, vec!['a', 'b']);
    /// has_b.set_transition(0, 'a', 0).unwrap();
    /// has_b.set_transition(0, 'b', 1).unwrap();
    /// has_b.set_transition(1, 'a', 1).unwrap();
    /// has_b.set_transition(1, 'b', 1).unwrap();
    /// has_b.set_accepting(vec![false, true]);
    ///
    /// let diff = has_a.difference(&has_b);
    /// assert!(diff.accepts("a"));     // has a but not b
    /// assert!(!diff.accepts("ab"));   // has both
    /// assert!(!diff.accepts("b"));    // has only b
    /// ```
    pub fn difference(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && !b)
    }

    /// Minimization by Moore's algorithm: partition states into
    /// indistinguishable classes.
    ///
    /// First drops unreachable states, then iteratively refines the
    /// partition by transition signature until no further split is
    /// possible. Returns a DFA with the minimal number of states.
    ///
    /// ```
    /// use automata::Dfa;
    ///
    /// // A 3-state DFA where states 1 and 2 are indistinguishable.
    /// let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
    /// dfa.set_transition(0, '0', 1).unwrap();
    /// dfa.set_transition(0, '1', 0).unwrap();
    /// dfa.set_transition(1, '0', 2).unwrap();
    /// dfa.set_transition(1, '1', 1).unwrap();
    /// dfa.set_transition(2, '0', 1).unwrap();
    /// dfa.set_transition(2, '1', 2).unwrap();
    /// dfa.set_accepting(vec![false, true, true]);
    ///
    /// let min = dfa.minimize();
    /// assert!(min.num_states() < dfa.num_states());
    /// // The languages must be equivalent.
    /// assert!(dfa.equivalent_to(&min));
    /// ```
    pub fn minimize(&self) -> Dfa {
        // Drop unreachable states.
        let mut reachable = vec![false; self.states];
        let mut stack = vec![self.start];
        reachable[self.start] = true;
        while let Some(s) = stack.pop() {
            for &to in &self.delta[s] {
                if to < self.states && !reachable[to] {
                    reachable[to] = true;
                    stack.push(to);
                }
            }
        }

        // Initial partition: accepting versus non-accepting.
        let mut block = vec![usize::MAX; self.states];
        let mut blocks: Vec<Vec<usize>> = Vec::new();
        for s in 0..self.states {
            if !reachable[s] {
                continue;
            }
            let b = if self.accepting[s] { 0 } else { 1 };
            while blocks.len() <= b {
                blocks.push(Vec::new());
            }
            block[s] = b;
            blocks[b].push(s);
        }
        if blocks.is_empty() {
            blocks = vec![Vec::new(); 2];
        }

        // Iterative refinement by transition signature.
        loop {
            let mut new_blocks: Vec<Vec<usize>> = Vec::new();
            let mut new_block = vec![usize::MAX; self.states];
            let mut refined = false;
            for states_in_block in &blocks {
                let mut groups: HashMap<Vec<usize>, Vec<usize>> = HashMap::new();
                for &s in states_in_block {
                    let sig: Vec<usize> = self.delta[s]
                        .iter()
                        .map(|&to| {
                            if to < self.states {
                                block[to]
                            } else {
                                usize::MAX
                            }
                        })
                        .collect();
                    groups.entry(sig).or_default().push(s);
                }
                for group in groups.values() {
                    if group.len() < states_in_block.len() {
                        refined = true;
                    }
                    let nb = new_blocks.len();
                    new_blocks.push(group.clone());
                    for &s in group {
                        new_block[s] = nb;
                    }
                }
            }
            block = new_block;
            blocks = new_blocks;
            if !refined {
                break;
            }
        }

        // Build the minimal automaton: one state per block.
        let m = blocks.len();
        let start_block = block[self.start];
        let mut dfa = Dfa::new(m, start_block, self.alphabet.clone());
        for (b, group) in blocks.iter().enumerate() {
            let rep = group[0];
            for (sym_idx, &to) in self.delta[rep].iter().enumerate() {
                if to < self.states {
                    dfa.set_transition(b, self.alphabet[sym_idx], block[to])
                        .expect("symbol from the automaton's own alphabet");
                }
            }
        }
        let accepting = blocks.iter().map(|g| self.accepting[g[0]]).collect();
        dfa.set_accepting(accepting);
        dfa
    }

    // ==================================================================
    // Private helpers
    // ==================================================================

    /// State reached after a transition on a symbol (trap if undefined).
    fn next_state(&self, state: usize, sym: char) -> usize {
        if state >= self.states {
            return self.states;
        }
        let Some(idx) = self.alphabet.iter().position(|&c| c == sym) else {
            return self.states;
        };
        self.delta[state][idx]
    }

    /// Product of two automata: states are reachable pairs.
    ///
    /// Uses the union of both alphabets so symbols present only in `other`
    /// are not silently dropped into the trap.
    fn product(&self, other: &Dfa, combine: fn(bool, bool) -> bool) -> Dfa {
        let mut alphabet = self.alphabet.clone();
        for &sym in &other.alphabet {
            if !alphabet.contains(&sym) {
                alphabet.push(sym);
            }
        }

        let mut pairs: Vec<(usize, usize)> = vec![(self.start, other.start)];
        let mut index: HashMap<(usize, usize), usize> = HashMap::new();
        index.insert((self.start, other.start), 0);
        let mut rows: Vec<Vec<usize>> = Vec::new();

        let mut i = 0;
        while i < pairs.len() {
            let (q1, q2) = pairs[i];
            let mut row = Vec::with_capacity(alphabet.len());
            for &sym in &alphabet {
                let key = (self.next_state(q1, sym), other.next_state(q2, sym));
                let j = *index.entry(key).or_insert_with(|| {
                    pairs.push(key);
                    pairs.len() - 1
                });
                row.push(j);
            }
            rows.push(row);
            i += 1;
        }

        let mut dfa = Dfa::new(pairs.len(), 0, alphabet);
        for (i, row) in rows.iter().enumerate() {
            for (sym_idx, &to) in row.iter().enumerate() {
                dfa.set_transition(i, dfa.alphabet[sym_idx], to)
                    .expect("symbol from the union alphabet");
            }
        }
        let accepting = pairs
            .iter()
            .map(|&(q1, q2)| combine(self.is_accepting(q1), other.is_accepting(q2)))
            .collect();
        dfa.set_accepting(accepting);
        dfa
    }
}

impl fmt::Display for Dfa {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(
            f,
            "DFA: {} states, alphabet = {:?}, start = q{}",
            self.states, self.alphabet, self.start
        )?;
        let accept_set: Vec<usize> = (0..self.states).filter(|&s| self.accepting[s]).collect();
        writeln!(f, "  accepting = {accept_set:?}")?;
        for s in 0..self.states {
            let arrow = if s == self.start { "→" } else { " " };
            let star = if self.accepting[s] { "*" } else { " " };
            write!(f, "  {arrow}q{s}{star}:")?;
            for (sym_idx, &to) in self.delta[s].iter().enumerate() {
                write!(f, " {}→", self.alphabet[sym_idx])?;
                if to < self.states {
                    write!(f, "q{to}")?;
                } else {
                    write!(f, "∅")?;
                }
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A DFA for the language of words with an even number of ones.
    fn even_ones() -> Dfa {
        let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 0).unwrap();
        dfa.set_transition(0, '1', 1).unwrap();
        dfa.set_transition(1, '0', 1).unwrap();
        dfa.set_transition(1, '1', 0).unwrap();
        dfa.set_accepting(vec![true, false]);
        dfa
    }

    /// A DFA for the language of words ending in "0".
    fn ends_with_zero() -> Dfa {
        let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 1).unwrap();
        dfa.set_transition(0, '1', 0).unwrap();
        dfa.set_transition(1, '0', 1).unwrap();
        dfa.set_transition(1, '1', 0).unwrap();
        dfa.set_accepting(vec![false, true]);
        dfa
    }

    fn words() -> [&'static str; 7] {
        ["", "0", "1", "10", "110", "010", "0011"]
    }

    #[test]
    fn even_ones_accepts_correct_words() {
        let dfa = even_ones();
        assert!(dfa.accepts(""));
        assert!(dfa.accepts("0"));
        assert!(dfa.accepts("11"));
        assert!(dfa.accepts("1100"));
        assert!(dfa.accepts("101")); // two ones, even count
        assert!(!dfa.accepts("1"));
        assert!(!dfa.accepts("10")); // one one, odd count
        assert!(!dfa.accepts("111"));
    }

    #[test]
    fn symbol_outside_alphabet_is_rejected() {
        let dfa = even_ones();
        assert!(!dfa.accepts("2"));
        assert!(!dfa.accepts("01a"));
    }

    #[test]
    fn accessors_match_construction() {
        let dfa = even_ones();
        assert_eq!(dfa.num_states(), 2);
        assert_eq!(dfa.alphabet(), &['0', '1']);
        assert_eq!(dfa.start(), 0);
        assert!(dfa.is_accepting(0));
        assert!(!dfa.is_accepting(1));
    }

    #[test]
    fn empty_is_empty_when_no_accepting_reachable() {
        let mut dfa = Dfa::new(2, 0, vec!['a']);
        dfa.set_transition(0, 'a', 1).unwrap();
        dfa.set_transition(1, 'a', 1).unwrap();
        dfa.set_accepting(vec![false, false]);
        assert!(dfa.is_empty());
    }

    #[test]
    fn empty_is_false_when_accepting_reachable() {
        let dfa = even_ones();
        assert!(!dfa.is_empty());
    }

    #[test]
    fn complete_adds_trap_state() {
        let dfa = even_ones();
        let comp = dfa.complete();
        assert_eq!(comp.num_states(), dfa.num_states() + 1);
        // The completed automaton must still accept the same words.
        for w in words() {
            assert_eq!(comp.accepts(w), dfa.accepts(w), "word {w:?}");
        }
    }

    #[test]
    fn complement_flips_language() {
        let dfa = even_ones();
        let comp = dfa.complement();
        for w in words() {
            assert_eq!(comp.accepts(w), !dfa.accepts(w), "word {w:?}");
        }
    }

    #[test]
    fn complement_of_complement_is_original() {
        let dfa = even_ones();
        let double = dfa.complement().complement();
        for w in words() {
            assert_eq!(double.accepts(w), dfa.accepts(w), "word {w:?}");
        }
    }

    #[test]
    fn union_and_intersection_via_product() {
        let even = even_ones();
        let end0 = ends_with_zero();
        let union = even.union(&end0);
        let inter = even.intersection(&end0);
        for w in words() {
            assert_eq!(
                union.accepts(w),
                even.accepts(w) || end0.accepts(w),
                "union {w:?}"
            );
            assert_eq!(
                inter.accepts(w),
                even.accepts(w) && end0.accepts(w),
                "inter {w:?}"
            );
        }
    }

    #[test]
    fn difference_self_minus_self_is_empty() {
        let dfa = even_ones();
        let diff = dfa.difference(&dfa);
        assert!(diff.is_empty());
    }

    #[test]
    fn difference_self_minus_other() {
        let even = even_ones();
        let end0 = ends_with_zero();
        let diff = even.difference(&end0);
        for w in words() {
            assert_eq!(
                diff.accepts(w),
                even.accepts(w) && !end0.accepts(w),
                "word {w:?}"
            );
        }
    }

    #[test]
    fn equivalent_to_self() {
        let dfa = even_ones();
        assert!(dfa.equivalent_to(&dfa));
    }

    #[test]
    fn equivalent_different_struct_same_language() {
        // A 3-state DFA where states 1 and 2 are indistinguishable.
        let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 1).unwrap();
        dfa.set_transition(0, '1', 0).unwrap();
        dfa.set_transition(1, '0', 2).unwrap();
        dfa.set_transition(1, '1', 1).unwrap();
        dfa.set_transition(2, '0', 1).unwrap();
        dfa.set_transition(2, '1', 2).unwrap();
        dfa.set_accepting(vec![false, true, true]);

        let min = dfa.minimize();
        assert!(dfa.equivalent_to(&min));
    }

    #[test]
    fn not_equivalent_different_languages() {
        let even = even_ones();
        let end0 = ends_with_zero();
        assert!(!even.equivalent_to(&end0));
    }

    #[test]
    fn minimize_preserves_language() {
        // An automaton with a redundant (duplicate) state.
        let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 1).unwrap();
        dfa.set_transition(0, '1', 0).unwrap();
        dfa.set_transition(1, '0', 2).unwrap();
        dfa.set_transition(1, '1', 1).unwrap();
        dfa.set_transition(2, '0', 1).unwrap();
        dfa.set_transition(2, '1', 2).unwrap();
        dfa.set_accepting(vec![false, true, true]); // states 1 and 2 are indistinguishable

        let min = dfa.minimize();
        for w in words() {
            assert_eq!(min.accepts(w), dfa.accepts(w), "word {w:?}");
        }
        assert!(
            min.num_states() < dfa.num_states(),
            "the automaton must shrink"
        );
    }

    #[test]
    fn minimize_already_minimal() {
        let dfa = even_ones();
        let min = dfa.minimize();
        assert_eq!(min.num_states(), dfa.num_states());
    }

    #[test]
    fn union_contains_original_languages() {
        let even = even_ones();
        let end0 = ends_with_zero();
        let uni = even.union(&end0);
        for w in words() {
            if even.accepts(w) || end0.accepts(w) {
                assert!(uni.accepts(w), "union must accept {w:?}");
            }
        }
    }

    #[test]
    fn intersection_contained_in_both() {
        let even = even_ones();
        let end0 = ends_with_zero();
        let inter = even.intersection(&end0);
        for w in words() {
            if inter.accepts(w) {
                assert!(even.accepts(w) && end0.accepts(w), "word {w:?}");
            }
        }
    }

    #[test]
    fn product_with_different_alphabets() {
        // even_ones has alphabet {0,1}, create a DFA with extra symbol.
        let mut dfa = Dfa::new(1, 0, vec!['0', '1', '2']);
        dfa.set_transition(0, '0', 0).unwrap();
        dfa.set_transition(0, '1', 0).unwrap();
        dfa.set_transition(0, '2', 0).unwrap();
        dfa.set_accepting(vec![true]);

        let inter = even_ones().intersection(&dfa);
        // The intersection should still work (alphabets are merged).
        assert!(inter.accepts(""));
        assert!(!inter.accepts("1"));
    }

    #[test]
    fn display_does_not_panic() {
        let dfa = even_ones();
        let s = format!("{dfa}");
        assert!(s.contains("states"));
        assert!(s.contains("q0"));
        assert!(s.contains("q1"));
    }
}
