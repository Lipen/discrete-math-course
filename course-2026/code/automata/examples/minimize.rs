//! DFA minimization by Moore's algorithm.
//!
//! An automaton with a redundant (indistinguishable) state is compressed to a
//! minimal number of states; the language is preserved.

use automata::Dfa;

fn main() {
    // The language of words containing at least one 0; states 1 and 2 are indistinguishable.
    let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 1).unwrap();
    dfa.set_transition(0, '1', 0).unwrap();
    dfa.set_transition(1, '0', 2).unwrap();
    dfa.set_transition(1, '1', 1).unwrap();
    dfa.set_transition(2, '0', 1).unwrap();
    dfa.set_transition(2, '1', 2).unwrap();
    dfa.set_accepting(vec![false, true, true]); // 1 and 2 are indistinguishable

    let min = dfa.minimize();
    println!(
        "Original DFA: {} states, minimal: {} states",
        dfa.num_states(),
        min.num_states()
    );

    for w in ["", "0", "1", "00", "010", "1010", "00100"] {
        let a = dfa.accepts(w);
        let b = min.accepts(w);
        let mark = if a == b { "ok" } else { "ERROR" };
        println!("{w:>6}: before={a:<5} after={b:<5} {mark}");
    }
}
