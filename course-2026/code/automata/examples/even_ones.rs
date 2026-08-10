//! A DFA for the language of words with an even number of ones.
//!
//! State 0 means "even so far" (accepting), state 1 means "odd so far".
//! A one flips the state, a zero does not.

use automata::Dfa;

fn main() {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 0).unwrap();
    dfa.set_transition(0, '1', 1).unwrap();
    dfa.set_transition(1, '0', 1).unwrap();
    dfa.set_transition(1, '1', 0).unwrap();
    dfa.set_accepting(vec![true, false]);

    for w in ["", "0", "1", "11", "101", "1100", "111"] {
        let verdict = if dfa.accepts(w) { "accept" } else { "reject" };
        println!("{w:>4} -> {verdict}");
    }
}
