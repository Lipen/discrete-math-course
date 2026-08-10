//! Deterministic finite automata (DFA).
//!
//! An undefined transition leads to a trap state (index `states`);
//! `accepts` returns false once it enters the trap. Language operations
//! (complement, union, intersection, difference) and minimization
//! are built via the product construction and partition into classes.

use std::collections::HashMap;

/// A deterministic finite automaton over an alphabet of `char`.
///
/// States are integers `0..states`; transitions are given by the table
/// `delta[state][symbol index]`.
#[derive(Debug, Clone)]
pub struct Dfa {
    states: usize,
    start: usize,
    accepting: Vec<bool>,
    alphabet: Vec<char>,
    delta: Vec<Vec<usize>>,
}

impl Dfa {
    /// Creates an automaton with `states` states, start state `start`,
    /// and alphabet `alphabet`. All states are non-accepting by default.
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

    /// Sets a transition from state `from` to state `to` on symbol `sym`.
    ///
    /// # Errors
    ///
    /// Returns `Err` if `sym` is not in the alphabet.
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
    pub fn set_accepting(&mut self, accepting: Vec<bool>) {
        assert_eq!(accepting.len(), self.states);
        self.accepting = accepting;
    }

    /// Number of states.
    pub fn num_states(&self) -> usize {
        self.states
    }

    /// Whether the automaton accepts the word `word`.
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

    /// Whether the state is accepting (trap states are not).
    fn is_accepting(&self, state: usize) -> bool {
        state < self.states && self.accepting[state]
    }

    /// Complete automaton: adds an explicit sink trap state so that
    /// every symbol has a transition from every state.
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
    pub fn complement(&self) -> Dfa {
        let mut d = self.complete();
        for a in d.accepting.iter_mut() {
            *a = !*a;
        }
        d
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

    /// Union of the languages of two automata.
    pub fn union(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a || b)
    }

    /// Intersection of the languages of two automata.
    pub fn intersection(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && b)
    }

    /// Language difference: words of `self` not in `other`.
    pub fn difference(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && !b)
    }

    /// Minimization by Moore's algorithm: partition states into indistinguishable classes.
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

    fn words() -> [&'static str; 6] {
        ["", "0", "1", "10", "110", "010"]
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
    fn complement_flips_language() {
        let dfa = even_ones();
        let comp = dfa.complement();
        for w in words() {
            assert_eq!(comp.accepts(w), !dfa.accepts(w), "word {w:?}");
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
        assert!(min.states < dfa.states, "the automaton must shrink");
    }
}
