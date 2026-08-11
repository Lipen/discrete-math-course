//! Finite automata and regular languages.
//!
//! DFAs, NFAs (with epsilon transitions), the subset construction, operations
//! on languages (complement, union, intersection, difference), regular
//! expressions (Thompson construction) and minimization.
//!
//! Every concept has runnable examples in `examples/`.
//!
//! ```
//! use automata::{Dfa, Nfa, parse};
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
//! // Parse a regex and match via the Thompson construction.
//! let re = parse("(a|b)*a(a|b)").unwrap();
//! let nfa = re.to_nfa();
//! assert!(nfa.accepts("aa"));
//! assert!(!nfa.accepts("ba"));
//! ```

pub mod dfa;
pub mod nfa;
pub mod regex;

pub use dfa::Dfa;
pub use nfa::Nfa;
pub use regex::{parse, RegEx};
