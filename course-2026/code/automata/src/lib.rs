//! Finite automata and regular languages.
//!
//! DFAs, NFAs (with epsilon transitions), the subset construction and
//! operations on languages (complement, union, intersection, difference).
//!
//! Every concept has runnable examples in `examples/`.
//!
//! ```
//! use automata::{Dfa, Nfa};
//!
//! // Build a DFA for words with an even number of '1's.
//! let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
//! dfa.set_transition(0, '0', 0).unwrap();
//! dfa.set_transition(0, '1', 1).unwrap();
//! dfa.set_transition(1, '0', 1).unwrap();
//! dfa.set_transition(1, '1', 0).unwrap();
//! dfa.set_accepting(vec![true, false]);
//!
//! assert!(dfa.accepts(""));
//! assert!(dfa.accepts("11"));
//! assert!(!dfa.accepts("1"));
//!
//! // Determinize the NFA for words containing "ab".
//! let mut nfa = Nfa::new(vec!['a', 'b']);
//! let q0 = nfa.add_state(false);
//! let q1 = nfa.add_state(false);
//! let q2 = nfa.add_state(true);
//! nfa.set_start(q0);
//! nfa.add_transition(q0, 'a', q0).unwrap();
//! nfa.add_transition(q0, 'b', q0).unwrap();
//! nfa.add_transition(q0, 'a', q1).unwrap();
//! nfa.add_transition(q1, 'b', q2).unwrap();
//! let dfa = nfa.to_dfa();
//! assert!(dfa.accepts("ab"));
//! assert!(!dfa.accepts("ba"));
//! ```

pub mod dfa;
pub mod nfa;

pub use dfa::Dfa;
pub use nfa::Nfa;
